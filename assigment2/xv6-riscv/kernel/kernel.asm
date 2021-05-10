
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
    80000068:	ebc78793          	addi	a5,a5,-324 # 80006f20 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	07878793          	addi	a5,a5,120 # 80001126 <main>
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
    80000122:	a46080e7          	jalr	-1466(ra) # 80002b64 <either_copyin>
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
    80000188:	a84080e7          	jalr	-1404(ra) # 80000c08 <acquire>
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
    800001b6:	b66080e7          	jalr	-1178(ra) # 80001d18 <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	49e080e7          	jalr	1182(ra) # 80002662 <sleep>
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
    80000204:	90e080e7          	jalr	-1778(ra) # 80002b0e <either_copyout>
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
    80000222:	a9e080e7          	jalr	-1378(ra) # 80000cbc <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00012517          	auipc	a0,0x12
    80000230:	f5450513          	addi	a0,a0,-172 # 80012180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a88080e7          	jalr	-1400(ra) # 80000cbc <release>
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
    800002c8:	944080e7          	jalr	-1724(ra) # 80000c08 <acquire>

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
    800002e6:	8d8080e7          	jalr	-1832(ra) # 80002bba <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	e9650513          	addi	a0,a0,-362 # 80012180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	9ca080e7          	jalr	-1590(ra) # 80000cbc <release>
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
    8000043a:	3b6080e7          	jalr	950(ra) # 800027ec <wakeup>
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
    8000044c:	bd858593          	addi	a1,a1,-1064 # 80009020 <etext+0x20>
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
    80000468:	0003f797          	auipc	a5,0x3f
    8000046c:	b0878793          	addi	a5,a5,-1272 # 8003ef70 <devsw>
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
    800004ae:	ba660613          	addi	a2,a2,-1114 # 80009050 <digits>
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
    80000546:	ae650513          	addi	a0,a0,-1306 # 80009028 <etext+0x28>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00009517          	auipc	a0,0x9
    80000560:	bf450513          	addi	a0,a0,-1036 # 80009150 <digits+0x100>
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
    800005da:	a7ab0b13          	addi	s6,s6,-1414 # 80009050 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00012517          	auipc	a0,0x12
    800005ec:	c4050513          	addi	a0,a0,-960 # 80012228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	618080e7          	jalr	1560(ra) # 80000c08 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00009517          	auipc	a0,0x9
    800005fe:	a3e50513          	addi	a0,a0,-1474 # 80009038 <etext+0x38>
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
    800006f8:	93c48493          	addi	s1,s1,-1732 # 80009030 <etext+0x30>
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
    80000752:	56e080e7          	jalr	1390(ra) # 80000cbc <release>
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
    8000076e:	8de58593          	addi	a1,a1,-1826 # 80009048 <etext+0x48>
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
    800007be:	8ae58593          	addi	a1,a1,-1874 # 80009068 <digits+0x18>
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
    800007ea:	3d6080e7          	jalr	982(ra) # 80000bbc <push_off>

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
    80000808:	0ff4f513          	zext.b	a0,s1
    8000080c:	100007b7          	lui	a5,0x10000
    80000810:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000814:	00000097          	auipc	ra,0x0
    80000818:	448080e7          	jalr	1096(ra) # 80000c5c <pop_off>
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
    80000886:	f6a080e7          	jalr	-150(ra) # 800027ec <wakeup>
    
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
    800008ca:	342080e7          	jalr	834(ra) # 80000c08 <acquire>
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
    80000912:	d54080e7          	jalr	-684(ra) # 80002662 <sleep>
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
    8000094e:	372080e7          	jalr	882(ra) # 80000cbc <release>
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
    8000097c:	0ff57513          	zext.b	a0,a0
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
    800009ba:	252080e7          	jalr	594(ra) # 80000c08 <acquire>
  uartstart();
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	e68080e7          	jalr	-408(ra) # 80000826 <uartstart>
  release(&uart_tx_lock);
    800009c6:	8526                	mv	a0,s1
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	2f4080e7          	jalr	756(ra) # 80000cbc <release>
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
    800009ee:	00042797          	auipc	a5,0x42
    800009f2:	61278793          	addi	a5,a5,1554 # 80043000 <end>
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
    80000a0a:	572080e7          	jalr	1394(ra) # 80000f78 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0e:	00012917          	auipc	s2,0x12
    80000a12:	87290913          	addi	s2,s2,-1934 # 80012280 <kmem>
    80000a16:	854a                	mv	a0,s2
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	1f0080e7          	jalr	496(ra) # 80000c08 <acquire>
  r->next = kmem.freelist;
    80000a20:	01893783          	ld	a5,24(s2)
    80000a24:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a26:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a2a:	854a                	mv	a0,s2
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	290080e7          	jalr	656(ra) # 80000cbc <release>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6902                	ld	s2,0(sp)
    80000a3c:	6105                	addi	sp,sp,32
    80000a3e:	8082                	ret
    panic("kfree");
    80000a40:	00008517          	auipc	a0,0x8
    80000a44:	63050513          	addi	a0,a0,1584 # 80009070 <digits+0x20>
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
    80000aa6:	5d658593          	addi	a1,a1,1494 # 80009078 <digits+0x28>
    80000aaa:	00011517          	auipc	a0,0x11
    80000aae:	7d650513          	addi	a0,a0,2006 # 80012280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00042517          	auipc	a0,0x42
    80000ac2:	54250513          	addi	a0,a0,1346 # 80043000 <end>
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
    80000aee:	11e080e7          	jalr	286(ra) # 80000c08 <acquire>
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
    80000b06:	1ba080e7          	jalr	442(ra) # 80000cbc <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	468080e7          	jalr	1128(ra) # 80000f78 <memset>
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
    80000b30:	190080e7          	jalr	400(ra) # 80000cbc <release>
  if(r)
    80000b34:	b7d5                	j	80000b18 <kalloc+0x42>

0000000080000b36 <initlock>:
      
struct bsemaphore bsemaphores[MAX_BSEM];

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

0000000080000b4c <initsemaphores>:

void
initsemaphores(){
    80000b4c:	1141                	addi	sp,sp,-16
    80000b4e:	e422                	sd	s0,8(sp)
    80000b50:	0800                	addi	s0,sp,16
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b52:	00011797          	auipc	a5,0x11
    80000b56:	74e78793          	addi	a5,a5,1870 # 800122a0 <bsemaphores>
    sem->state = SUNUSED;
    sem->s = 1;
    80000b5a:	4605                	li	a2,1
  lk->name = name;
    80000b5c:	00008697          	auipc	a3,0x8
    80000b60:	52468693          	addi	a3,a3,1316 # 80009080 <digits+0x30>
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b64:	00013717          	auipc	a4,0x13
    80000b68:	b3c70713          	addi	a4,a4,-1220 # 800136a0 <pid_lock>
    sem->state = SUNUSED;
    80000b6c:	0007ae23          	sw	zero,28(a5)
    sem->s = 1;
    80000b70:	cf90                	sw	a2,24(a5)
    sem->waiting = 0;
    80000b72:	0207a023          	sw	zero,32(a5)
  lk->name = name;
    80000b76:	e794                	sd	a3,8(a5)
  lk->locked = 0;
    80000b78:	0007a023          	sw	zero,0(a5)
  lk->cpu = 0;
    80000b7c:	0007b823          	sd	zero,16(a5)
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b80:	02878793          	addi	a5,a5,40
    80000b84:	fee794e3          	bne	a5,a4,80000b6c <initsemaphores+0x20>
    initlock(&sem->s_lock,"lock");
  }
}
    80000b88:	6422                	ld	s0,8(sp)
    80000b8a:	0141                	addi	sp,sp,16
    80000b8c:	8082                	ret

0000000080000b8e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8e:	411c                	lw	a5,0(a0)
    80000b90:	e399                	bnez	a5,80000b96 <holding+0x8>
    80000b92:	4501                	li	a0,0
  return r;
}
    80000b94:	8082                	ret
{
    80000b96:	1101                	addi	sp,sp,-32
    80000b98:	ec06                	sd	ra,24(sp)
    80000b9a:	e822                	sd	s0,16(sp)
    80000b9c:	e426                	sd	s1,8(sp)
    80000b9e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba0:	6904                	ld	s1,16(a0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	152080e7          	jalr	338(ra) # 80001cf4 <mycpu>
    80000baa:	40a48533          	sub	a0,s1,a0
    80000bae:	00153513          	seqz	a0,a0
}
    80000bb2:	60e2                	ld	ra,24(sp)
    80000bb4:	6442                	ld	s0,16(sp)
    80000bb6:	64a2                	ld	s1,8(sp)
    80000bb8:	6105                	addi	sp,sp,32
    80000bba:	8082                	ret

0000000080000bbc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbc:	1101                	addi	sp,sp,-32
    80000bbe:	ec06                	sd	ra,24(sp)
    80000bc0:	e822                	sd	s0,16(sp)
    80000bc2:	e426                	sd	s1,8(sp)
    80000bc4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc6:	100024f3          	csrr	s1,sstatus
    80000bca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd0:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	120080e7          	jalr	288(ra) # 80001cf4 <mycpu>
    80000bdc:	5d3c                	lw	a5,120(a0)
    80000bde:	cf89                	beqz	a5,80000bf8 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be0:	00001097          	auipc	ra,0x1
    80000be4:	114080e7          	jalr	276(ra) # 80001cf4 <mycpu>
    80000be8:	5d3c                	lw	a5,120(a0)
    80000bea:	2785                	addiw	a5,a5,1
    80000bec:	dd3c                	sw	a5,120(a0)
}
    80000bee:	60e2                	ld	ra,24(sp)
    80000bf0:	6442                	ld	s0,16(sp)
    80000bf2:	64a2                	ld	s1,8(sp)
    80000bf4:	6105                	addi	sp,sp,32
    80000bf6:	8082                	ret
    mycpu()->intena = old;
    80000bf8:	00001097          	auipc	ra,0x1
    80000bfc:	0fc080e7          	jalr	252(ra) # 80001cf4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c00:	8085                	srli	s1,s1,0x1
    80000c02:	8885                	andi	s1,s1,1
    80000c04:	dd64                	sw	s1,124(a0)
    80000c06:	bfe9                	j	80000be0 <push_off+0x24>

0000000080000c08 <acquire>:
acquire(struct spinlock *lk){
    80000c08:	1101                	addi	sp,sp,-32
    80000c0a:	ec06                	sd	ra,24(sp)
    80000c0c:	e822                	sd	s0,16(sp)
    80000c0e:	e426                	sd	s1,8(sp)
    80000c10:	1000                	addi	s0,sp,32
    80000c12:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	fa8080e7          	jalr	-88(ra) # 80000bbc <push_off>
  if(holding(lk)){
    80000c1c:	8526                	mv	a0,s1
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	f70080e7          	jalr	-144(ra) # 80000b8e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c26:	4705                	li	a4,1
  if(holding(lk)){
    80000c28:	e115                	bnez	a0,80000c4c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2a:	87ba                	mv	a5,a4
    80000c2c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c30:	2781                	sext.w	a5,a5
    80000c32:	ffe5                	bnez	a5,80000c2a <acquire+0x22>
  __sync_synchronize();
    80000c34:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	0bc080e7          	jalr	188(ra) # 80001cf4 <mycpu>
    80000c40:	e888                	sd	a0,16(s1)
}
    80000c42:	60e2                	ld	ra,24(sp)
    80000c44:	6442                	ld	s0,16(sp)
    80000c46:	64a2                	ld	s1,8(sp)
    80000c48:	6105                	addi	sp,sp,32
    80000c4a:	8082                	ret
    panic("acquire");
    80000c4c:	00008517          	auipc	a0,0x8
    80000c50:	43c50513          	addi	a0,a0,1084 # 80009088 <digits+0x38>
    80000c54:	00000097          	auipc	ra,0x0
    80000c58:	8da080e7          	jalr	-1830(ra) # 8000052e <panic>

0000000080000c5c <pop_off>:

void
pop_off(void)
{
    80000c5c:	1141                	addi	sp,sp,-16
    80000c5e:	e406                	sd	ra,8(sp)
    80000c60:	e022                	sd	s0,0(sp)
    80000c62:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c64:	00001097          	auipc	ra,0x1
    80000c68:	090080e7          	jalr	144(ra) # 80001cf4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c70:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c72:	e78d                	bnez	a5,80000c9c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c74:	5d3c                	lw	a5,120(a0)
    80000c76:	02f05b63          	blez	a5,80000cac <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c7a:	37fd                	addiw	a5,a5,-1
    80000c7c:	0007871b          	sext.w	a4,a5
    80000c80:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c82:	eb09                	bnez	a4,80000c94 <pop_off+0x38>
    80000c84:	5d7c                	lw	a5,124(a0)
    80000c86:	c799                	beqz	a5,80000c94 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c8c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c90:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c94:	60a2                	ld	ra,8(sp)
    80000c96:	6402                	ld	s0,0(sp)
    80000c98:	0141                	addi	sp,sp,16
    80000c9a:	8082                	ret
    panic("pop_off - interruptible");
    80000c9c:	00008517          	auipc	a0,0x8
    80000ca0:	3f450513          	addi	a0,a0,1012 # 80009090 <digits+0x40>
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	88a080e7          	jalr	-1910(ra) # 8000052e <panic>
    panic("pop_off");
    80000cac:	00008517          	auipc	a0,0x8
    80000cb0:	3fc50513          	addi	a0,a0,1020 # 800090a8 <digits+0x58>
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	87a080e7          	jalr	-1926(ra) # 8000052e <panic>

0000000080000cbc <release>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cc8:	00000097          	auipc	ra,0x0
    80000ccc:	ec6080e7          	jalr	-314(ra) # 80000b8e <holding>
    80000cd0:	c115                	beqz	a0,80000cf4 <release+0x38>
  lk->cpu = 0;
    80000cd2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cd6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cda:	0f50000f          	fence	iorw,ow
    80000cde:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000ce2:	00000097          	auipc	ra,0x0
    80000ce6:	f7a080e7          	jalr	-134(ra) # 80000c5c <pop_off>
}
    80000cea:	60e2                	ld	ra,24(sp)
    80000cec:	6442                	ld	s0,16(sp)
    80000cee:	64a2                	ld	s1,8(sp)
    80000cf0:	6105                	addi	sp,sp,32
    80000cf2:	8082                	ret
    panic("release");
    80000cf4:	00008517          	auipc	a0,0x8
    80000cf8:	3bc50513          	addi	a0,a0,956 # 800090b0 <digits+0x60>
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	832080e7          	jalr	-1998(ra) # 8000052e <panic>

0000000080000d04 <bsem_alloc>:
/////////// bsemaphore/////////////// 

// Allocates a new binary semaphore and returns its descriptor(-1 if failure). You are not
// restricted on the binary semaphore internal structure, but the newly allocated binary
// semaphore should be in unlocked state.
int bsem_alloc(){
    80000d04:	1101                	addi	sp,sp,-32
    80000d06:	ec06                	sd	ra,24(sp)
    80000d08:	e822                	sd	s0,16(sp)
    80000d0a:	e426                	sd	s1,8(sp)
    80000d0c:	e04a                	sd	s2,0(sp)
    80000d0e:	1000                	addi	s0,sp,32
  
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000d10:	00011497          	auipc	s1,0x11
    80000d14:	59048493          	addi	s1,s1,1424 # 800122a0 <bsemaphores>
    80000d18:	00013917          	auipc	s2,0x13
    80000d1c:	98890913          	addi	s2,s2,-1656 # 800136a0 <pid_lock>
    acquire(&sem->s_lock);
    80000d20:	8526                	mv	a0,s1
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	ee6080e7          	jalr	-282(ra) # 80000c08 <acquire>
    if(sem->state == SUNUSED)
    80000d2a:	4cdc                	lw	a5,28(s1)
    80000d2c:	c395                	beqz	a5,80000d50 <bsem_alloc+0x4c>
      goto found;
    release(&sem->s_lock);
    80000d2e:	8526                	mv	a0,s1
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	f8c080e7          	jalr	-116(ra) # 80000cbc <release>
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000d38:	02848493          	addi	s1,s1,40
    80000d3c:	ff2492e3          	bne	s1,s2,80000d20 <bsem_alloc+0x1c>
  }
  panic("Semaphore BOMB");
    80000d40:	00008517          	auipc	a0,0x8
    80000d44:	37850513          	addi	a0,a0,888 # 800090b8 <digits+0x68>
    80000d48:	fffff097          	auipc	ra,0xfffff
    80000d4c:	7e6080e7          	jalr	2022(ra) # 8000052e <panic>

  // found free semaphore
  found:
  sem->state=SUSED;
    80000d50:	4785                	li	a5,1
    80000d52:	ccdc                	sw	a5,28(s1)
  sem->s=1;
    80000d54:	cc9c                	sw	a5,24(s1)
  sem->waiting=0;
    80000d56:	0204a023          	sw	zero,32(s1)
  release(&sem->s_lock);
    80000d5a:	8526                	mv	a0,s1
    80000d5c:	00000097          	auipc	ra,0x0
    80000d60:	f60080e7          	jalr	-160(ra) # 80000cbc <release>

  return (int)(sem - bsemaphores);
    80000d64:	00011517          	auipc	a0,0x11
    80000d68:	53c50513          	addi	a0,a0,1340 # 800122a0 <bsemaphores>
    80000d6c:	40a48533          	sub	a0,s1,a0
    80000d70:	850d                	srai	a0,a0,0x3
    80000d72:	00008797          	auipc	a5,0x8
    80000d76:	28e7b783          	ld	a5,654(a5) # 80009000 <etext>
    80000d7a:	02f5053b          	mulw	a0,a0,a5
  
}
    80000d7e:	60e2                	ld	ra,24(sp)
    80000d80:	6442                	ld	s0,16(sp)
    80000d82:	64a2                	ld	s1,8(sp)
    80000d84:	6902                	ld	s2,0(sp)
    80000d86:	6105                	addi	sp,sp,32
    80000d88:	8082                	ret

0000000080000d8a <bsem_free>:

// Call the free function with the semaphore down
void
bsem_free(int sem_index){
    80000d8a:	1101                	addi	sp,sp,-32
    80000d8c:	ec06                	sd	ra,24(sp)
    80000d8e:	e822                	sd	s0,16(sp)
    80000d90:	e426                	sd	s1,8(sp)
    80000d92:	e04a                	sd	s2,0(sp)
    80000d94:	1000                	addi	s0,sp,32
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000d96:	08000793          	li	a5,128
    80000d9a:	04a7e963          	bltu	a5,a0,80000dec <bsem_free+0x62>
    80000d9e:	892a                	mv	s2,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
  acquire(&bsem->s_lock);
    80000da0:	00251493          	slli	s1,a0,0x2
    80000da4:	94aa                	add	s1,s1,a0
    80000da6:	048e                	slli	s1,s1,0x3
    80000da8:	00011797          	auipc	a5,0x11
    80000dac:	4f878793          	addi	a5,a5,1272 # 800122a0 <bsemaphores>
    80000db0:	94be                	add	s1,s1,a5
    80000db2:	8526                	mv	a0,s1
    80000db4:	00000097          	auipc	ra,0x0
    80000db8:	e54080e7          	jalr	-428(ra) # 80000c08 <acquire>
  if(bsem->state == SUNUSED ){
    80000dbc:	4cdc                	lw	a5,28(s1)
    80000dbe:	cf9d                	beqz	a5,80000dfc <bsem_free+0x72>
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }
 
  bsem->state = SUNUSED;
    80000dc0:	00291793          	slli	a5,s2,0x2
    80000dc4:	97ca                	add	a5,a5,s2
    80000dc6:	078e                	slli	a5,a5,0x3
    80000dc8:	00011717          	auipc	a4,0x11
    80000dcc:	4d870713          	addi	a4,a4,1240 # 800122a0 <bsemaphores>
    80000dd0:	97ba                	add	a5,a5,a4
    80000dd2:	0007ae23          	sw	zero,28(a5)
  release(&bsem->s_lock);
    80000dd6:	8526                	mv	a0,s1
    80000dd8:	00000097          	auipc	ra,0x0
    80000ddc:	ee4080e7          	jalr	-284(ra) # 80000cbc <release>
}
    80000de0:	60e2                	ld	ra,24(sp)
    80000de2:	6442                	ld	s0,16(sp)
    80000de4:	64a2                	ld	s1,8(sp)
    80000de6:	6902                	ld	s2,0(sp)
    80000de8:	6105                	addi	sp,sp,32
    80000dea:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000dec:	00008517          	auipc	a0,0x8
    80000df0:	2dc50513          	addi	a0,a0,732 # 800090c8 <digits+0x78>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	73a080e7          	jalr	1850(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000dfc:	8526                	mv	a0,s1
    80000dfe:	00000097          	auipc	ra,0x0
    80000e02:	ebe080e7          	jalr	-322(ra) # 80000cbc <release>
    panic("fack semaphore is not alloced in bsem_down");
    80000e06:	00008517          	auipc	a0,0x8
    80000e0a:	2f250513          	addi	a0,a0,754 # 800090f8 <digits+0xa8>
    80000e0e:	fffff097          	auipc	ra,0xfffff
    80000e12:	720080e7          	jalr	1824(ra) # 8000052e <panic>

0000000080000e16 <bsem_down>:

// Attempt to acquire (lock) the semaphore, in case that it is already acquired (locked),
// block the current thread until it is unlocked and then acquire it./
void
bsem_down(int sem_index){
    80000e16:	7179                	addi	sp,sp,-48
    80000e18:	f406                	sd	ra,40(sp)
    80000e1a:	f022                	sd	s0,32(sp)
    80000e1c:	ec26                	sd	s1,24(sp)
    80000e1e:	e84a                	sd	s2,16(sp)
    80000e20:	e44e                	sd	s3,8(sp)
    80000e22:	1800                	addi	s0,sp,48
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000e24:	08000793          	li	a5,128
    80000e28:	0aa7e063          	bltu	a5,a0,80000ec8 <bsem_down+0xb2>
    80000e2c:	89aa                	mv	s3,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
    80000e2e:	00251493          	slli	s1,a0,0x2
    80000e32:	94aa                	add	s1,s1,a0
    80000e34:	048e                	slli	s1,s1,0x3
    80000e36:	00011797          	auipc	a5,0x11
    80000e3a:	46a78793          	addi	a5,a5,1130 # 800122a0 <bsemaphores>
    80000e3e:	94be                	add	s1,s1,a5
  acquire(&bsem->s_lock);
    80000e40:	8526                	mv	a0,s1
    80000e42:	00000097          	auipc	ra,0x0
    80000e46:	dc6080e7          	jalr	-570(ra) # 80000c08 <acquire>
  if(bsem->state == SUNUSED ){  // can happen if other thread freed the semaphore or invlid input -> unsupported
    80000e4a:	4cdc                	lw	a5,28(s1)
    80000e4c:	c7d1                	beqz	a5,80000ed8 <bsem_down+0xc2>
    release(&bsem->s_lock);
    return;
  }

  bsem->waiting++;
    80000e4e:	00299793          	slli	a5,s3,0x2
    80000e52:	97ce                	add	a5,a5,s3
    80000e54:	00379713          	slli	a4,a5,0x3
    80000e58:	00011797          	auipc	a5,0x11
    80000e5c:	44878793          	addi	a5,a5,1096 # 800122a0 <bsemaphores>
    80000e60:	97ba                	add	a5,a5,a4
    80000e62:	5398                	lw	a4,32(a5)
    80000e64:	2705                	addiw	a4,a4,1
    80000e66:	d398                	sw	a4,32(a5)
  while(bsem->s == 0){// sleep until semaphore is unlocked
    80000e68:	4f9c                	lw	a5,24(a5)
    80000e6a:	e785                	bnez	a5,80000e92 <bsem_down+0x7c>
    80000e6c:	00299913          	slli	s2,s3,0x2
    80000e70:	994e                	add	s2,s2,s3
    80000e72:	00391793          	slli	a5,s2,0x3
    80000e76:	00011917          	auipc	s2,0x11
    80000e7a:	42a90913          	addi	s2,s2,1066 # 800122a0 <bsemaphores>
    80000e7e:	993e                	add	s2,s2,a5
    sleep(bsem, &bsem->s_lock);
    80000e80:	85a6                	mv	a1,s1
    80000e82:	8526                	mv	a0,s1
    80000e84:	00001097          	auipc	ra,0x1
    80000e88:	7de080e7          	jalr	2014(ra) # 80002662 <sleep>
  while(bsem->s == 0){// sleep until semaphore is unlocked
    80000e8c:	01892783          	lw	a5,24(s2)
    80000e90:	dbe5                	beqz	a5,80000e80 <bsem_down+0x6a>
  }
  bsem->waiting--;
    80000e92:	00011697          	auipc	a3,0x11
    80000e96:	40e68693          	addi	a3,a3,1038 # 800122a0 <bsemaphores>
    80000e9a:	00299793          	slli	a5,s3,0x2
    80000e9e:	01378733          	add	a4,a5,s3
    80000ea2:	070e                	slli	a4,a4,0x3
    80000ea4:	9736                	add	a4,a4,a3
    80000ea6:	5310                	lw	a2,32(a4)
    80000ea8:	367d                	addiw	a2,a2,-1
    80000eaa:	d310                	sw	a2,32(a4)

  bsem->s = 0;
    80000eac:	00072c23          	sw	zero,24(a4)
  release(&bsem->s_lock);
    80000eb0:	8526                	mv	a0,s1
    80000eb2:	00000097          	auipc	ra,0x0
    80000eb6:	e0a080e7          	jalr	-502(ra) # 80000cbc <release>
}
    80000eba:	70a2                	ld	ra,40(sp)
    80000ebc:	7402                	ld	s0,32(sp)
    80000ebe:	64e2                	ld	s1,24(sp)
    80000ec0:	6942                	ld	s2,16(sp)
    80000ec2:	69a2                	ld	s3,8(sp)
    80000ec4:	6145                	addi	sp,sp,48
    80000ec6:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000ec8:	00008517          	auipc	a0,0x8
    80000ecc:	20050513          	addi	a0,a0,512 # 800090c8 <digits+0x78>
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	65e080e7          	jalr	1630(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000ed8:	8526                	mv	a0,s1
    80000eda:	00000097          	auipc	ra,0x0
    80000ede:	de2080e7          	jalr	-542(ra) # 80000cbc <release>
    return;
    80000ee2:	bfe1                	j	80000eba <bsem_down+0xa4>

0000000080000ee4 <bsem_up>:

void bsem_up(int sem_index){
    80000ee4:	1101                	addi	sp,sp,-32
    80000ee6:	ec06                	sd	ra,24(sp)
    80000ee8:	e822                	sd	s0,16(sp)
    80000eea:	e426                	sd	s1,8(sp)
    80000eec:	e04a                	sd	s2,0(sp)
    80000eee:	1000                	addi	s0,sp,32
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000ef0:	08000793          	li	a5,128
    80000ef4:	04a7ee63          	bltu	a5,a0,80000f50 <bsem_up+0x6c>
    80000ef8:	892a                	mv	s2,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
    80000efa:	00251493          	slli	s1,a0,0x2
    80000efe:	94aa                	add	s1,s1,a0
    80000f00:	048e                	slli	s1,s1,0x3
    80000f02:	00011797          	auipc	a5,0x11
    80000f06:	39e78793          	addi	a5,a5,926 # 800122a0 <bsemaphores>
    80000f0a:	94be                	add	s1,s1,a5
  acquire(&bsem->s_lock);
    80000f0c:	8526                	mv	a0,s1
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	cfa080e7          	jalr	-774(ra) # 80000c08 <acquire>
   if(bsem->state == SUNUSED ){  // can happen if other thread freed the semaphore or invlid input -> unsupported
    80000f16:	4cdc                	lw	a5,28(s1)
    80000f18:	c7a1                	beqz	a5,80000f60 <bsem_up+0x7c>
    release(&bsem->s_lock);
    return;
  }

  bsem->s++;
    80000f1a:	00011697          	auipc	a3,0x11
    80000f1e:	38668693          	addi	a3,a3,902 # 800122a0 <bsemaphores>
    80000f22:	00291793          	slli	a5,s2,0x2
    80000f26:	01278733          	add	a4,a5,s2
    80000f2a:	070e                	slli	a4,a4,0x3
    80000f2c:	9736                	add	a4,a4,a3
    80000f2e:	4f10                	lw	a2,24(a4)
    80000f30:	2605                	addiw	a2,a2,1
    80000f32:	cf10                	sw	a2,24(a4)

  if(bsem->waiting > 0)
    80000f34:	531c                	lw	a5,32(a4)
    80000f36:	02f04b63          	bgtz	a5,80000f6c <bsem_up+0x88>
    wakeup(bsem);
  
  release(&bsem->s_lock);
    80000f3a:	8526                	mv	a0,s1
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	d80080e7          	jalr	-640(ra) # 80000cbc <release>
}
    80000f44:	60e2                	ld	ra,24(sp)
    80000f46:	6442                	ld	s0,16(sp)
    80000f48:	64a2                	ld	s1,8(sp)
    80000f4a:	6902                	ld	s2,0(sp)
    80000f4c:	6105                	addi	sp,sp,32
    80000f4e:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000f50:	00008517          	auipc	a0,0x8
    80000f54:	17850513          	addi	a0,a0,376 # 800090c8 <digits+0x78>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	5d6080e7          	jalr	1494(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000f60:	8526                	mv	a0,s1
    80000f62:	00000097          	auipc	ra,0x0
    80000f66:	d5a080e7          	jalr	-678(ra) # 80000cbc <release>
    return;
    80000f6a:	bfe9                	j	80000f44 <bsem_up+0x60>
    wakeup(bsem);
    80000f6c:	8526                	mv	a0,s1
    80000f6e:	00002097          	auipc	ra,0x2
    80000f72:	87e080e7          	jalr	-1922(ra) # 800027ec <wakeup>
    80000f76:	b7d1                	j	80000f3a <bsem_up+0x56>

0000000080000f78 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000f78:	1141                	addi	sp,sp,-16
    80000f7a:	e422                	sd	s0,8(sp)
    80000f7c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000f7e:	ca19                	beqz	a2,80000f94 <memset+0x1c>
    80000f80:	87aa                	mv	a5,a0
    80000f82:	1602                	slli	a2,a2,0x20
    80000f84:	9201                	srli	a2,a2,0x20
    80000f86:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000f8a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000f8e:	0785                	addi	a5,a5,1
    80000f90:	fee79de3          	bne	a5,a4,80000f8a <memset+0x12>
  }
  return dst;
}
    80000f94:	6422                	ld	s0,8(sp)
    80000f96:	0141                	addi	sp,sp,16
    80000f98:	8082                	ret

0000000080000f9a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000f9a:	1141                	addi	sp,sp,-16
    80000f9c:	e422                	sd	s0,8(sp)
    80000f9e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000fa0:	ca05                	beqz	a2,80000fd0 <memcmp+0x36>
    80000fa2:	fff6069b          	addiw	a3,a2,-1
    80000fa6:	1682                	slli	a3,a3,0x20
    80000fa8:	9281                	srli	a3,a3,0x20
    80000faa:	0685                	addi	a3,a3,1
    80000fac:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000fae:	00054783          	lbu	a5,0(a0)
    80000fb2:	0005c703          	lbu	a4,0(a1)
    80000fb6:	00e79863          	bne	a5,a4,80000fc6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000fba:	0505                	addi	a0,a0,1
    80000fbc:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000fbe:	fed518e3          	bne	a0,a3,80000fae <memcmp+0x14>
  }

  return 0;
    80000fc2:	4501                	li	a0,0
    80000fc4:	a019                	j	80000fca <memcmp+0x30>
      return *s1 - *s2;
    80000fc6:	40e7853b          	subw	a0,a5,a4
}
    80000fca:	6422                	ld	s0,8(sp)
    80000fcc:	0141                	addi	sp,sp,16
    80000fce:	8082                	ret
  return 0;
    80000fd0:	4501                	li	a0,0
    80000fd2:	bfe5                	j	80000fca <memcmp+0x30>

0000000080000fd4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000fd4:	1141                	addi	sp,sp,-16
    80000fd6:	e422                	sd	s0,8(sp)
    80000fd8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000fda:	02a5e563          	bltu	a1,a0,80001004 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000fde:	fff6069b          	addiw	a3,a2,-1
    80000fe2:	ce11                	beqz	a2,80000ffe <memmove+0x2a>
    80000fe4:	1682                	slli	a3,a3,0x20
    80000fe6:	9281                	srli	a3,a3,0x20
    80000fe8:	0685                	addi	a3,a3,1
    80000fea:	96ae                	add	a3,a3,a1
    80000fec:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000fee:	0585                	addi	a1,a1,1
    80000ff0:	0785                	addi	a5,a5,1
    80000ff2:	fff5c703          	lbu	a4,-1(a1)
    80000ff6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000ffa:	fed59ae3          	bne	a1,a3,80000fee <memmove+0x1a>

  return dst;
}
    80000ffe:	6422                	ld	s0,8(sp)
    80001000:	0141                	addi	sp,sp,16
    80001002:	8082                	ret
  if(s < d && s + n > d){
    80001004:	02061713          	slli	a4,a2,0x20
    80001008:	9301                	srli	a4,a4,0x20
    8000100a:	00e587b3          	add	a5,a1,a4
    8000100e:	fcf578e3          	bgeu	a0,a5,80000fde <memmove+0xa>
    d += n;
    80001012:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80001014:	fff6069b          	addiw	a3,a2,-1
    80001018:	d27d                	beqz	a2,80000ffe <memmove+0x2a>
    8000101a:	02069613          	slli	a2,a3,0x20
    8000101e:	9201                	srli	a2,a2,0x20
    80001020:	fff64613          	not	a2,a2
    80001024:	963e                	add	a2,a2,a5
      *--d = *--s;
    80001026:	17fd                	addi	a5,a5,-1
    80001028:	177d                	addi	a4,a4,-1
    8000102a:	0007c683          	lbu	a3,0(a5)
    8000102e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001032:	fef61ae3          	bne	a2,a5,80001026 <memmove+0x52>
    80001036:	b7e1                	j	80000ffe <memmove+0x2a>

0000000080001038 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80001038:	1141                	addi	sp,sp,-16
    8000103a:	e406                	sd	ra,8(sp)
    8000103c:	e022                	sd	s0,0(sp)
    8000103e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80001040:	00000097          	auipc	ra,0x0
    80001044:	f94080e7          	jalr	-108(ra) # 80000fd4 <memmove>
}
    80001048:	60a2                	ld	ra,8(sp)
    8000104a:	6402                	ld	s0,0(sp)
    8000104c:	0141                	addi	sp,sp,16
    8000104e:	8082                	ret

0000000080001050 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001050:	1141                	addi	sp,sp,-16
    80001052:	e422                	sd	s0,8(sp)
    80001054:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001056:	ce11                	beqz	a2,80001072 <strncmp+0x22>
    80001058:	00054783          	lbu	a5,0(a0)
    8000105c:	cf89                	beqz	a5,80001076 <strncmp+0x26>
    8000105e:	0005c703          	lbu	a4,0(a1)
    80001062:	00f71a63          	bne	a4,a5,80001076 <strncmp+0x26>
    n--, p++, q++;
    80001066:	367d                	addiw	a2,a2,-1
    80001068:	0505                	addi	a0,a0,1
    8000106a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000106c:	f675                	bnez	a2,80001058 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000106e:	4501                	li	a0,0
    80001070:	a809                	j	80001082 <strncmp+0x32>
    80001072:	4501                	li	a0,0
    80001074:	a039                	j	80001082 <strncmp+0x32>
  if(n == 0)
    80001076:	ca09                	beqz	a2,80001088 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001078:	00054503          	lbu	a0,0(a0)
    8000107c:	0005c783          	lbu	a5,0(a1)
    80001080:	9d1d                	subw	a0,a0,a5
}
    80001082:	6422                	ld	s0,8(sp)
    80001084:	0141                	addi	sp,sp,16
    80001086:	8082                	ret
    return 0;
    80001088:	4501                	li	a0,0
    8000108a:	bfe5                	j	80001082 <strncmp+0x32>

000000008000108c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000108c:	1141                	addi	sp,sp,-16
    8000108e:	e422                	sd	s0,8(sp)
    80001090:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001092:	872a                	mv	a4,a0
    80001094:	8832                	mv	a6,a2
    80001096:	367d                	addiw	a2,a2,-1
    80001098:	01005963          	blez	a6,800010aa <strncpy+0x1e>
    8000109c:	0705                	addi	a4,a4,1
    8000109e:	0005c783          	lbu	a5,0(a1)
    800010a2:	fef70fa3          	sb	a5,-1(a4)
    800010a6:	0585                	addi	a1,a1,1
    800010a8:	f7f5                	bnez	a5,80001094 <strncpy+0x8>
    ;
  while(n-- > 0)
    800010aa:	86ba                	mv	a3,a4
    800010ac:	00c05c63          	blez	a2,800010c4 <strncpy+0x38>
    *s++ = 0;
    800010b0:	0685                	addi	a3,a3,1
    800010b2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800010b6:	fff6c793          	not	a5,a3
    800010ba:	9fb9                	addw	a5,a5,a4
    800010bc:	010787bb          	addw	a5,a5,a6
    800010c0:	fef048e3          	bgtz	a5,800010b0 <strncpy+0x24>
  return os;
}
    800010c4:	6422                	ld	s0,8(sp)
    800010c6:	0141                	addi	sp,sp,16
    800010c8:	8082                	ret

00000000800010ca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800010ca:	1141                	addi	sp,sp,-16
    800010cc:	e422                	sd	s0,8(sp)
    800010ce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800010d0:	02c05363          	blez	a2,800010f6 <safestrcpy+0x2c>
    800010d4:	fff6069b          	addiw	a3,a2,-1
    800010d8:	1682                	slli	a3,a3,0x20
    800010da:	9281                	srli	a3,a3,0x20
    800010dc:	96ae                	add	a3,a3,a1
    800010de:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800010e0:	00d58963          	beq	a1,a3,800010f2 <safestrcpy+0x28>
    800010e4:	0585                	addi	a1,a1,1
    800010e6:	0785                	addi	a5,a5,1
    800010e8:	fff5c703          	lbu	a4,-1(a1)
    800010ec:	fee78fa3          	sb	a4,-1(a5)
    800010f0:	fb65                	bnez	a4,800010e0 <safestrcpy+0x16>
    ;
  *s = 0;
    800010f2:	00078023          	sb	zero,0(a5)
  return os;
}
    800010f6:	6422                	ld	s0,8(sp)
    800010f8:	0141                	addi	sp,sp,16
    800010fa:	8082                	ret

00000000800010fc <strlen>:

int
strlen(const char *s)
{
    800010fc:	1141                	addi	sp,sp,-16
    800010fe:	e422                	sd	s0,8(sp)
    80001100:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001102:	00054783          	lbu	a5,0(a0)
    80001106:	cf91                	beqz	a5,80001122 <strlen+0x26>
    80001108:	0505                	addi	a0,a0,1
    8000110a:	87aa                	mv	a5,a0
    8000110c:	4685                	li	a3,1
    8000110e:	9e89                	subw	a3,a3,a0
    80001110:	00f6853b          	addw	a0,a3,a5
    80001114:	0785                	addi	a5,a5,1
    80001116:	fff7c703          	lbu	a4,-1(a5)
    8000111a:	fb7d                	bnez	a4,80001110 <strlen+0x14>
    ;
  return n;
}
    8000111c:	6422                	ld	s0,8(sp)
    8000111e:	0141                	addi	sp,sp,16
    80001120:	8082                	ret
  for(n = 0; s[n]; n++)
    80001122:	4501                	li	a0,0
    80001124:	bfe5                	j	8000111c <strlen+0x20>

0000000080001126 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001126:	1141                	addi	sp,sp,-16
    80001128:	e406                	sd	ra,8(sp)
    8000112a:	e022                	sd	s0,0(sp)
    8000112c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000112e:	00001097          	auipc	ra,0x1
    80001132:	bb6080e7          	jalr	-1098(ra) # 80001ce4 <cpuid>

    initsemaphores(); //init semaphores array

    started = 1;
  } else {
    while(started == 0)
    80001136:	00009717          	auipc	a4,0x9
    8000113a:	ee270713          	addi	a4,a4,-286 # 8000a018 <started>
  if(cpuid() == 0){
    8000113e:	c139                	beqz	a0,80001184 <main+0x5e>
    while(started == 0)
    80001140:	431c                	lw	a5,0(a4)
    80001142:	2781                	sext.w	a5,a5
    80001144:	dff5                	beqz	a5,80001140 <main+0x1a>
      ;
    __sync_synchronize();
    80001146:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000114a:	00001097          	auipc	ra,0x1
    8000114e:	b9a080e7          	jalr	-1126(ra) # 80001ce4 <cpuid>
    80001152:	85aa                	mv	a1,a0
    80001154:	00008517          	auipc	a0,0x8
    80001158:	fec50513          	addi	a0,a0,-20 # 80009140 <digits+0xf0>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	41c080e7          	jalr	1052(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80001164:	00000097          	auipc	ra,0x0
    80001168:	0e0080e7          	jalr	224(ra) # 80001244 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000116c:	00002097          	auipc	ra,0x2
    80001170:	1d6080e7          	jalr	470(ra) # 80003342 <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80001174:	00006097          	auipc	ra,0x6
    80001178:	dec080e7          	jalr	-532(ra) # 80006f60 <plicinithart>
  }

  scheduler();        
    8000117c:	00001097          	auipc	ra,0x1
    80001180:	2d6080e7          	jalr	726(ra) # 80002452 <scheduler>
    consoleinit();
    80001184:	fffff097          	auipc	ra,0xfffff
    80001188:	2bc080e7          	jalr	700(ra) # 80000440 <consoleinit>
    printfinit();
    8000118c:	fffff097          	auipc	ra,0xfffff
    80001190:	5cc080e7          	jalr	1484(ra) # 80000758 <printfinit>
    printf("\n");
    80001194:	00008517          	auipc	a0,0x8
    80001198:	fbc50513          	addi	a0,a0,-68 # 80009150 <digits+0x100>
    8000119c:	fffff097          	auipc	ra,0xfffff
    800011a0:	3dc080e7          	jalr	988(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    800011a4:	00008517          	auipc	a0,0x8
    800011a8:	f8450513          	addi	a0,a0,-124 # 80009128 <digits+0xd8>
    800011ac:	fffff097          	auipc	ra,0xfffff
    800011b0:	3cc080e7          	jalr	972(ra) # 80000578 <printf>
    printf("\n");
    800011b4:	00008517          	auipc	a0,0x8
    800011b8:	f9c50513          	addi	a0,a0,-100 # 80009150 <digits+0x100>
    800011bc:	fffff097          	auipc	ra,0xfffff
    800011c0:	3bc080e7          	jalr	956(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	8d6080e7          	jalr	-1834(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	318080e7          	jalr	792(ra) # 800014e4 <kvminit>
    kvminithart();   // turn on paging
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	070080e7          	jalr	112(ra) # 80001244 <kvminithart>
    procinit();      // process table
    800011dc:	00001097          	auipc	ra,0x1
    800011e0:	9da080e7          	jalr	-1574(ra) # 80001bb6 <procinit>
    trapinit();      // trap vectors
    800011e4:	00002097          	auipc	ra,0x2
    800011e8:	136080e7          	jalr	310(ra) # 8000331a <trapinit>
    trapinithart();  // install kernel trap vector
    800011ec:	00002097          	auipc	ra,0x2
    800011f0:	156080e7          	jalr	342(ra) # 80003342 <trapinithart>
    plicinit();      // set up interrupt controller
    800011f4:	00006097          	auipc	ra,0x6
    800011f8:	d56080e7          	jalr	-682(ra) # 80006f4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800011fc:	00006097          	auipc	ra,0x6
    80001200:	d64080e7          	jalr	-668(ra) # 80006f60 <plicinithart>
    binit();         // buffer cache
    80001204:	00003097          	auipc	ra,0x3
    80001208:	e88080e7          	jalr	-376(ra) # 8000408c <binit>
    iinit();         // inode cache
    8000120c:	00003097          	auipc	ra,0x3
    80001210:	51a080e7          	jalr	1306(ra) # 80004726 <iinit>
    fileinit();      // file table
    80001214:	00004097          	auipc	ra,0x4
    80001218:	4c6080e7          	jalr	1222(ra) # 800056da <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000121c:	00006097          	auipc	ra,0x6
    80001220:	e66080e7          	jalr	-410(ra) # 80007082 <virtio_disk_init>
    userinit();      // first user process
    80001224:	00001097          	auipc	ra,0x1
    80001228:	f74080e7          	jalr	-140(ra) # 80002198 <userinit>
    __sync_synchronize();
    8000122c:	0ff0000f          	fence
    initsemaphores(); //init semaphores array
    80001230:	00000097          	auipc	ra,0x0
    80001234:	91c080e7          	jalr	-1764(ra) # 80000b4c <initsemaphores>
    started = 1;
    80001238:	4785                	li	a5,1
    8000123a:	00009717          	auipc	a4,0x9
    8000123e:	dcf72f23          	sw	a5,-546(a4) # 8000a018 <started>
    80001242:	bf2d                	j	8000117c <main+0x56>

0000000080001244 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e422                	sd	s0,8(sp)
    80001248:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000124a:	00009797          	auipc	a5,0x9
    8000124e:	dd67b783          	ld	a5,-554(a5) # 8000a020 <kernel_pagetable>
    80001252:	83b1                	srli	a5,a5,0xc
    80001254:	577d                	li	a4,-1
    80001256:	177e                	slli	a4,a4,0x3f
    80001258:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000125a:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000125e:	12000073          	sfence.vma
  sfence_vma();
}
    80001262:	6422                	ld	s0,8(sp)
    80001264:	0141                	addi	sp,sp,16
    80001266:	8082                	ret

0000000080001268 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001268:	7139                	addi	sp,sp,-64
    8000126a:	fc06                	sd	ra,56(sp)
    8000126c:	f822                	sd	s0,48(sp)
    8000126e:	f426                	sd	s1,40(sp)
    80001270:	f04a                	sd	s2,32(sp)
    80001272:	ec4e                	sd	s3,24(sp)
    80001274:	e852                	sd	s4,16(sp)
    80001276:	e456                	sd	s5,8(sp)
    80001278:	e05a                	sd	s6,0(sp)
    8000127a:	0080                	addi	s0,sp,64
    8000127c:	84aa                	mv	s1,a0
    8000127e:	89ae                	mv	s3,a1
    80001280:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001282:	57fd                	li	a5,-1
    80001284:	83e9                	srli	a5,a5,0x1a
    80001286:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001288:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000128a:	04b7f263          	bgeu	a5,a1,800012ce <walk+0x66>
    panic("walk");
    8000128e:	00008517          	auipc	a0,0x8
    80001292:	eca50513          	addi	a0,a0,-310 # 80009158 <digits+0x108>
    80001296:	fffff097          	auipc	ra,0xfffff
    8000129a:	298080e7          	jalr	664(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000129e:	060a8663          	beqz	s5,8000130a <walk+0xa2>
    800012a2:	00000097          	auipc	ra,0x0
    800012a6:	834080e7          	jalr	-1996(ra) # 80000ad6 <kalloc>
    800012aa:	84aa                	mv	s1,a0
    800012ac:	c529                	beqz	a0,800012f6 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800012ae:	6605                	lui	a2,0x1
    800012b0:	4581                	li	a1,0
    800012b2:	00000097          	auipc	ra,0x0
    800012b6:	cc6080e7          	jalr	-826(ra) # 80000f78 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800012ba:	00c4d793          	srli	a5,s1,0xc
    800012be:	07aa                	slli	a5,a5,0xa
    800012c0:	0017e793          	ori	a5,a5,1
    800012c4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800012c8:	3a5d                	addiw	s4,s4,-9
    800012ca:	036a0063          	beq	s4,s6,800012ea <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800012ce:	0149d933          	srl	s2,s3,s4
    800012d2:	1ff97913          	andi	s2,s2,511
    800012d6:	090e                	slli	s2,s2,0x3
    800012d8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800012da:	00093483          	ld	s1,0(s2)
    800012de:	0014f793          	andi	a5,s1,1
    800012e2:	dfd5                	beqz	a5,8000129e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800012e4:	80a9                	srli	s1,s1,0xa
    800012e6:	04b2                	slli	s1,s1,0xc
    800012e8:	b7c5                	j	800012c8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800012ea:	00c9d513          	srli	a0,s3,0xc
    800012ee:	1ff57513          	andi	a0,a0,511
    800012f2:	050e                	slli	a0,a0,0x3
    800012f4:	9526                	add	a0,a0,s1
}
    800012f6:	70e2                	ld	ra,56(sp)
    800012f8:	7442                	ld	s0,48(sp)
    800012fa:	74a2                	ld	s1,40(sp)
    800012fc:	7902                	ld	s2,32(sp)
    800012fe:	69e2                	ld	s3,24(sp)
    80001300:	6a42                	ld	s4,16(sp)
    80001302:	6aa2                	ld	s5,8(sp)
    80001304:	6b02                	ld	s6,0(sp)
    80001306:	6121                	addi	sp,sp,64
    80001308:	8082                	ret
        return 0;
    8000130a:	4501                	li	a0,0
    8000130c:	b7ed                	j	800012f6 <walk+0x8e>

000000008000130e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000130e:	57fd                	li	a5,-1
    80001310:	83e9                	srli	a5,a5,0x1a
    80001312:	00b7f463          	bgeu	a5,a1,8000131a <walkaddr+0xc>
    return 0;
    80001316:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001318:	8082                	ret
{
    8000131a:	1141                	addi	sp,sp,-16
    8000131c:	e406                	sd	ra,8(sp)
    8000131e:	e022                	sd	s0,0(sp)
    80001320:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001322:	4601                	li	a2,0
    80001324:	00000097          	auipc	ra,0x0
    80001328:	f44080e7          	jalr	-188(ra) # 80001268 <walk>
  if(pte == 0)
    8000132c:	c105                	beqz	a0,8000134c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000132e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001330:	0117f693          	andi	a3,a5,17
    80001334:	4745                	li	a4,17
    return 0;
    80001336:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001338:	00e68663          	beq	a3,a4,80001344 <walkaddr+0x36>
}
    8000133c:	60a2                	ld	ra,8(sp)
    8000133e:	6402                	ld	s0,0(sp)
    80001340:	0141                	addi	sp,sp,16
    80001342:	8082                	ret
  pa = PTE2PA(*pte);
    80001344:	00a7d513          	srli	a0,a5,0xa
    80001348:	0532                	slli	a0,a0,0xc
  return pa;
    8000134a:	bfcd                	j	8000133c <walkaddr+0x2e>
    return 0;
    8000134c:	4501                	li	a0,0
    8000134e:	b7fd                	j	8000133c <walkaddr+0x2e>

0000000080001350 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001350:	715d                	addi	sp,sp,-80
    80001352:	e486                	sd	ra,72(sp)
    80001354:	e0a2                	sd	s0,64(sp)
    80001356:	fc26                	sd	s1,56(sp)
    80001358:	f84a                	sd	s2,48(sp)
    8000135a:	f44e                	sd	s3,40(sp)
    8000135c:	f052                	sd	s4,32(sp)
    8000135e:	ec56                	sd	s5,24(sp)
    80001360:	e85a                	sd	s6,16(sp)
    80001362:	e45e                	sd	s7,8(sp)
    80001364:	0880                	addi	s0,sp,80
    80001366:	8aaa                	mv	s5,a0
    80001368:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000136a:	777d                	lui	a4,0xfffff
    8000136c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001370:	167d                	addi	a2,a2,-1
    80001372:	00b609b3          	add	s3,a2,a1
    80001376:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000137a:	893e                	mv	s2,a5
    8000137c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001380:	6b85                	lui	s7,0x1
    80001382:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001386:	4605                	li	a2,1
    80001388:	85ca                	mv	a1,s2
    8000138a:	8556                	mv	a0,s5
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	edc080e7          	jalr	-292(ra) # 80001268 <walk>
    80001394:	c51d                	beqz	a0,800013c2 <mappages+0x72>
    if(*pte & PTE_V)
    80001396:	611c                	ld	a5,0(a0)
    80001398:	8b85                	andi	a5,a5,1
    8000139a:	ef81                	bnez	a5,800013b2 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000139c:	80b1                	srli	s1,s1,0xc
    8000139e:	04aa                	slli	s1,s1,0xa
    800013a0:	0164e4b3          	or	s1,s1,s6
    800013a4:	0014e493          	ori	s1,s1,1
    800013a8:	e104                	sd	s1,0(a0)
    if(a == last)
    800013aa:	03390863          	beq	s2,s3,800013da <mappages+0x8a>
    a += PGSIZE;
    800013ae:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800013b0:	bfc9                	j	80001382 <mappages+0x32>
      panic("remap");
    800013b2:	00008517          	auipc	a0,0x8
    800013b6:	dae50513          	addi	a0,a0,-594 # 80009160 <digits+0x110>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	174080e7          	jalr	372(ra) # 8000052e <panic>
      return -1;
    800013c2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800013c4:	60a6                	ld	ra,72(sp)
    800013c6:	6406                	ld	s0,64(sp)
    800013c8:	74e2                	ld	s1,56(sp)
    800013ca:	7942                	ld	s2,48(sp)
    800013cc:	79a2                	ld	s3,40(sp)
    800013ce:	7a02                	ld	s4,32(sp)
    800013d0:	6ae2                	ld	s5,24(sp)
    800013d2:	6b42                	ld	s6,16(sp)
    800013d4:	6ba2                	ld	s7,8(sp)
    800013d6:	6161                	addi	sp,sp,80
    800013d8:	8082                	ret
  return 0;
    800013da:	4501                	li	a0,0
    800013dc:	b7e5                	j	800013c4 <mappages+0x74>

00000000800013de <kvmmap>:
{
    800013de:	1141                	addi	sp,sp,-16
    800013e0:	e406                	sd	ra,8(sp)
    800013e2:	e022                	sd	s0,0(sp)
    800013e4:	0800                	addi	s0,sp,16
    800013e6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800013e8:	86b2                	mv	a3,a2
    800013ea:	863e                	mv	a2,a5
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	f64080e7          	jalr	-156(ra) # 80001350 <mappages>
    800013f4:	e509                	bnez	a0,800013fe <kvmmap+0x20>
}
    800013f6:	60a2                	ld	ra,8(sp)
    800013f8:	6402                	ld	s0,0(sp)
    800013fa:	0141                	addi	sp,sp,16
    800013fc:	8082                	ret
    panic("kvmmap");
    800013fe:	00008517          	auipc	a0,0x8
    80001402:	d6a50513          	addi	a0,a0,-662 # 80009168 <digits+0x118>
    80001406:	fffff097          	auipc	ra,0xfffff
    8000140a:	128080e7          	jalr	296(ra) # 8000052e <panic>

000000008000140e <kvmmake>:
{
    8000140e:	1101                	addi	sp,sp,-32
    80001410:	ec06                	sd	ra,24(sp)
    80001412:	e822                	sd	s0,16(sp)
    80001414:	e426                	sd	s1,8(sp)
    80001416:	e04a                	sd	s2,0(sp)
    80001418:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6bc080e7          	jalr	1724(ra) # 80000ad6 <kalloc>
    80001422:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001424:	6605                	lui	a2,0x1
    80001426:	4581                	li	a1,0
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	b50080e7          	jalr	-1200(ra) # 80000f78 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001430:	4719                	li	a4,6
    80001432:	6685                	lui	a3,0x1
    80001434:	10000637          	lui	a2,0x10000
    80001438:	100005b7          	lui	a1,0x10000
    8000143c:	8526                	mv	a0,s1
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	fa0080e7          	jalr	-96(ra) # 800013de <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001446:	4719                	li	a4,6
    80001448:	6685                	lui	a3,0x1
    8000144a:	10001637          	lui	a2,0x10001
    8000144e:	100015b7          	lui	a1,0x10001
    80001452:	8526                	mv	a0,s1
    80001454:	00000097          	auipc	ra,0x0
    80001458:	f8a080e7          	jalr	-118(ra) # 800013de <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000145c:	4719                	li	a4,6
    8000145e:	004006b7          	lui	a3,0x400
    80001462:	0c000637          	lui	a2,0xc000
    80001466:	0c0005b7          	lui	a1,0xc000
    8000146a:	8526                	mv	a0,s1
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	f72080e7          	jalr	-142(ra) # 800013de <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001474:	00008917          	auipc	s2,0x8
    80001478:	b8c90913          	addi	s2,s2,-1140 # 80009000 <etext>
    8000147c:	4729                	li	a4,10
    8000147e:	80008697          	auipc	a3,0x80008
    80001482:	b8268693          	addi	a3,a3,-1150 # 9000 <_entry-0x7fff7000>
    80001486:	4605                	li	a2,1
    80001488:	067e                	slli	a2,a2,0x1f
    8000148a:	85b2                	mv	a1,a2
    8000148c:	8526                	mv	a0,s1
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	f50080e7          	jalr	-176(ra) # 800013de <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001496:	4719                	li	a4,6
    80001498:	46c5                	li	a3,17
    8000149a:	06ee                	slli	a3,a3,0x1b
    8000149c:	412686b3          	sub	a3,a3,s2
    800014a0:	864a                	mv	a2,s2
    800014a2:	85ca                	mv	a1,s2
    800014a4:	8526                	mv	a0,s1
    800014a6:	00000097          	auipc	ra,0x0
    800014aa:	f38080e7          	jalr	-200(ra) # 800013de <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800014ae:	4729                	li	a4,10
    800014b0:	6685                	lui	a3,0x1
    800014b2:	00007617          	auipc	a2,0x7
    800014b6:	b4e60613          	addi	a2,a2,-1202 # 80008000 <_trampoline>
    800014ba:	040005b7          	lui	a1,0x4000
    800014be:	15fd                	addi	a1,a1,-1
    800014c0:	05b2                	slli	a1,a1,0xc
    800014c2:	8526                	mv	a0,s1
    800014c4:	00000097          	auipc	ra,0x0
    800014c8:	f1a080e7          	jalr	-230(ra) # 800013de <kvmmap>
  proc_mapstacks(kpgtbl);
    800014cc:	8526                	mv	a0,s1
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	600080e7          	jalr	1536(ra) # 80001ace <proc_mapstacks>
}
    800014d6:	8526                	mv	a0,s1
    800014d8:	60e2                	ld	ra,24(sp)
    800014da:	6442                	ld	s0,16(sp)
    800014dc:	64a2                	ld	s1,8(sp)
    800014de:	6902                	ld	s2,0(sp)
    800014e0:	6105                	addi	sp,sp,32
    800014e2:	8082                	ret

00000000800014e4 <kvminit>:
{
    800014e4:	1141                	addi	sp,sp,-16
    800014e6:	e406                	sd	ra,8(sp)
    800014e8:	e022                	sd	s0,0(sp)
    800014ea:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	f22080e7          	jalr	-222(ra) # 8000140e <kvmmake>
    800014f4:	00009797          	auipc	a5,0x9
    800014f8:	b2a7b623          	sd	a0,-1236(a5) # 8000a020 <kernel_pagetable>
}
    800014fc:	60a2                	ld	ra,8(sp)
    800014fe:	6402                	ld	s0,0(sp)
    80001500:	0141                	addi	sp,sp,16
    80001502:	8082                	ret

0000000080001504 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001504:	715d                	addi	sp,sp,-80
    80001506:	e486                	sd	ra,72(sp)
    80001508:	e0a2                	sd	s0,64(sp)
    8000150a:	fc26                	sd	s1,56(sp)
    8000150c:	f84a                	sd	s2,48(sp)
    8000150e:	f44e                	sd	s3,40(sp)
    80001510:	f052                	sd	s4,32(sp)
    80001512:	ec56                	sd	s5,24(sp)
    80001514:	e85a                	sd	s6,16(sp)
    80001516:	e45e                	sd	s7,8(sp)
    80001518:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000151a:	03459793          	slli	a5,a1,0x34
    8000151e:	e795                	bnez	a5,8000154a <uvmunmap+0x46>
    80001520:	8a2a                	mv	s4,a0
    80001522:	892e                	mv	s2,a1
    80001524:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001526:	0632                	slli	a2,a2,0xc
    80001528:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000152c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000152e:	6b05                	lui	s6,0x1
    80001530:	0735e263          	bltu	a1,s3,80001594 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001534:	60a6                	ld	ra,72(sp)
    80001536:	6406                	ld	s0,64(sp)
    80001538:	74e2                	ld	s1,56(sp)
    8000153a:	7942                	ld	s2,48(sp)
    8000153c:	79a2                	ld	s3,40(sp)
    8000153e:	7a02                	ld	s4,32(sp)
    80001540:	6ae2                	ld	s5,24(sp)
    80001542:	6b42                	ld	s6,16(sp)
    80001544:	6ba2                	ld	s7,8(sp)
    80001546:	6161                	addi	sp,sp,80
    80001548:	8082                	ret
    panic("uvmunmap: not aligned");
    8000154a:	00008517          	auipc	a0,0x8
    8000154e:	c2650513          	addi	a0,a0,-986 # 80009170 <digits+0x120>
    80001552:	fffff097          	auipc	ra,0xfffff
    80001556:	fdc080e7          	jalr	-36(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    8000155a:	00008517          	auipc	a0,0x8
    8000155e:	c2e50513          	addi	a0,a0,-978 # 80009188 <digits+0x138>
    80001562:	fffff097          	auipc	ra,0xfffff
    80001566:	fcc080e7          	jalr	-52(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    8000156a:	00008517          	auipc	a0,0x8
    8000156e:	c2e50513          	addi	a0,a0,-978 # 80009198 <digits+0x148>
    80001572:	fffff097          	auipc	ra,0xfffff
    80001576:	fbc080e7          	jalr	-68(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    8000157a:	00008517          	auipc	a0,0x8
    8000157e:	c3650513          	addi	a0,a0,-970 # 800091b0 <digits+0x160>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fac080e7          	jalr	-84(ra) # 8000052e <panic>
    *pte = 0;
    8000158a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000158e:	995a                	add	s2,s2,s6
    80001590:	fb3972e3          	bgeu	s2,s3,80001534 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001594:	4601                	li	a2,0
    80001596:	85ca                	mv	a1,s2
    80001598:	8552                	mv	a0,s4
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	cce080e7          	jalr	-818(ra) # 80001268 <walk>
    800015a2:	84aa                	mv	s1,a0
    800015a4:	d95d                	beqz	a0,8000155a <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800015a6:	6108                	ld	a0,0(a0)
    800015a8:	00157793          	andi	a5,a0,1
    800015ac:	dfdd                	beqz	a5,8000156a <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800015ae:	3ff57793          	andi	a5,a0,1023
    800015b2:	fd7784e3          	beq	a5,s7,8000157a <uvmunmap+0x76>
    if(do_free){
    800015b6:	fc0a8ae3          	beqz	s5,8000158a <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800015ba:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800015bc:	0532                	slli	a0,a0,0xc
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	41c080e7          	jalr	1052(ra) # 800009da <kfree>
    800015c6:	b7d1                	j	8000158a <uvmunmap+0x86>

00000000800015c8 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800015c8:	1101                	addi	sp,sp,-32
    800015ca:	ec06                	sd	ra,24(sp)
    800015cc:	e822                	sd	s0,16(sp)
    800015ce:	e426                	sd	s1,8(sp)
    800015d0:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800015d2:	fffff097          	auipc	ra,0xfffff
    800015d6:	504080e7          	jalr	1284(ra) # 80000ad6 <kalloc>
    800015da:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800015dc:	c519                	beqz	a0,800015ea <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800015de:	6605                	lui	a2,0x1
    800015e0:	4581                	li	a1,0
    800015e2:	00000097          	auipc	ra,0x0
    800015e6:	996080e7          	jalr	-1642(ra) # 80000f78 <memset>
  return pagetable;
}
    800015ea:	8526                	mv	a0,s1
    800015ec:	60e2                	ld	ra,24(sp)
    800015ee:	6442                	ld	s0,16(sp)
    800015f0:	64a2                	ld	s1,8(sp)
    800015f2:	6105                	addi	sp,sp,32
    800015f4:	8082                	ret

00000000800015f6 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800015f6:	7179                	addi	sp,sp,-48
    800015f8:	f406                	sd	ra,40(sp)
    800015fa:	f022                	sd	s0,32(sp)
    800015fc:	ec26                	sd	s1,24(sp)
    800015fe:	e84a                	sd	s2,16(sp)
    80001600:	e44e                	sd	s3,8(sp)
    80001602:	e052                	sd	s4,0(sp)
    80001604:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001606:	6785                	lui	a5,0x1
    80001608:	04f67863          	bgeu	a2,a5,80001658 <uvminit+0x62>
    8000160c:	8a2a                	mv	s4,a0
    8000160e:	89ae                	mv	s3,a1
    80001610:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	4c4080e7          	jalr	1220(ra) # 80000ad6 <kalloc>
    8000161a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000161c:	6605                	lui	a2,0x1
    8000161e:	4581                	li	a1,0
    80001620:	00000097          	auipc	ra,0x0
    80001624:	958080e7          	jalr	-1704(ra) # 80000f78 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001628:	4779                	li	a4,30
    8000162a:	86ca                	mv	a3,s2
    8000162c:	6605                	lui	a2,0x1
    8000162e:	4581                	li	a1,0
    80001630:	8552                	mv	a0,s4
    80001632:	00000097          	auipc	ra,0x0
    80001636:	d1e080e7          	jalr	-738(ra) # 80001350 <mappages>
  memmove(mem, src, sz);
    8000163a:	8626                	mv	a2,s1
    8000163c:	85ce                	mv	a1,s3
    8000163e:	854a                	mv	a0,s2
    80001640:	00000097          	auipc	ra,0x0
    80001644:	994080e7          	jalr	-1644(ra) # 80000fd4 <memmove>
}
    80001648:	70a2                	ld	ra,40(sp)
    8000164a:	7402                	ld	s0,32(sp)
    8000164c:	64e2                	ld	s1,24(sp)
    8000164e:	6942                	ld	s2,16(sp)
    80001650:	69a2                	ld	s3,8(sp)
    80001652:	6a02                	ld	s4,0(sp)
    80001654:	6145                	addi	sp,sp,48
    80001656:	8082                	ret
    panic("inituvm: more than a page");
    80001658:	00008517          	auipc	a0,0x8
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800091c8 <digits+0x178>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ece080e7          	jalr	-306(ra) # 8000052e <panic>

0000000080001668 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001668:	1101                	addi	sp,sp,-32
    8000166a:	ec06                	sd	ra,24(sp)
    8000166c:	e822                	sd	s0,16(sp)
    8000166e:	e426                	sd	s1,8(sp)
    80001670:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001672:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001674:	00b67d63          	bgeu	a2,a1,8000168e <uvmdealloc+0x26>
    80001678:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000167a:	6785                	lui	a5,0x1
    8000167c:	17fd                	addi	a5,a5,-1
    8000167e:	00f60733          	add	a4,a2,a5
    80001682:	767d                	lui	a2,0xfffff
    80001684:	8f71                	and	a4,a4,a2
    80001686:	97ae                	add	a5,a5,a1
    80001688:	8ff1                	and	a5,a5,a2
    8000168a:	00f76863          	bltu	a4,a5,8000169a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000168e:	8526                	mv	a0,s1
    80001690:	60e2                	ld	ra,24(sp)
    80001692:	6442                	ld	s0,16(sp)
    80001694:	64a2                	ld	s1,8(sp)
    80001696:	6105                	addi	sp,sp,32
    80001698:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000169a:	8f99                	sub	a5,a5,a4
    8000169c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000169e:	4685                	li	a3,1
    800016a0:	0007861b          	sext.w	a2,a5
    800016a4:	85ba                	mv	a1,a4
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	e5e080e7          	jalr	-418(ra) # 80001504 <uvmunmap>
    800016ae:	b7c5                	j	8000168e <uvmdealloc+0x26>

00000000800016b0 <uvmalloc>:
  if(newsz < oldsz)
    800016b0:	0ab66163          	bltu	a2,a1,80001752 <uvmalloc+0xa2>
{
    800016b4:	7139                	addi	sp,sp,-64
    800016b6:	fc06                	sd	ra,56(sp)
    800016b8:	f822                	sd	s0,48(sp)
    800016ba:	f426                	sd	s1,40(sp)
    800016bc:	f04a                	sd	s2,32(sp)
    800016be:	ec4e                	sd	s3,24(sp)
    800016c0:	e852                	sd	s4,16(sp)
    800016c2:	e456                	sd	s5,8(sp)
    800016c4:	0080                	addi	s0,sp,64
    800016c6:	8aaa                	mv	s5,a0
    800016c8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800016ca:	6985                	lui	s3,0x1
    800016cc:	19fd                	addi	s3,s3,-1
    800016ce:	95ce                	add	a1,a1,s3
    800016d0:	79fd                	lui	s3,0xfffff
    800016d2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800016d6:	08c9f063          	bgeu	s3,a2,80001756 <uvmalloc+0xa6>
    800016da:	894e                	mv	s2,s3
    mem = kalloc();
    800016dc:	fffff097          	auipc	ra,0xfffff
    800016e0:	3fa080e7          	jalr	1018(ra) # 80000ad6 <kalloc>
    800016e4:	84aa                	mv	s1,a0
    if(mem == 0){
    800016e6:	c51d                	beqz	a0,80001714 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800016e8:	6605                	lui	a2,0x1
    800016ea:	4581                	li	a1,0
    800016ec:	00000097          	auipc	ra,0x0
    800016f0:	88c080e7          	jalr	-1908(ra) # 80000f78 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800016f4:	4779                	li	a4,30
    800016f6:	86a6                	mv	a3,s1
    800016f8:	6605                	lui	a2,0x1
    800016fa:	85ca                	mv	a1,s2
    800016fc:	8556                	mv	a0,s5
    800016fe:	00000097          	auipc	ra,0x0
    80001702:	c52080e7          	jalr	-942(ra) # 80001350 <mappages>
    80001706:	e905                	bnez	a0,80001736 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001708:	6785                	lui	a5,0x1
    8000170a:	993e                	add	s2,s2,a5
    8000170c:	fd4968e3          	bltu	s2,s4,800016dc <uvmalloc+0x2c>
  return newsz;
    80001710:	8552                	mv	a0,s4
    80001712:	a809                	j	80001724 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001714:	864e                	mv	a2,s3
    80001716:	85ca                	mv	a1,s2
    80001718:	8556                	mv	a0,s5
    8000171a:	00000097          	auipc	ra,0x0
    8000171e:	f4e080e7          	jalr	-178(ra) # 80001668 <uvmdealloc>
      return 0;
    80001722:	4501                	li	a0,0
}
    80001724:	70e2                	ld	ra,56(sp)
    80001726:	7442                	ld	s0,48(sp)
    80001728:	74a2                	ld	s1,40(sp)
    8000172a:	7902                	ld	s2,32(sp)
    8000172c:	69e2                	ld	s3,24(sp)
    8000172e:	6a42                	ld	s4,16(sp)
    80001730:	6aa2                	ld	s5,8(sp)
    80001732:	6121                	addi	sp,sp,64
    80001734:	8082                	ret
      kfree(mem);
    80001736:	8526                	mv	a0,s1
    80001738:	fffff097          	auipc	ra,0xfffff
    8000173c:	2a2080e7          	jalr	674(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001740:	864e                	mv	a2,s3
    80001742:	85ca                	mv	a1,s2
    80001744:	8556                	mv	a0,s5
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	f22080e7          	jalr	-222(ra) # 80001668 <uvmdealloc>
      return 0;
    8000174e:	4501                	li	a0,0
    80001750:	bfd1                	j	80001724 <uvmalloc+0x74>
    return oldsz;
    80001752:	852e                	mv	a0,a1
}
    80001754:	8082                	ret
  return newsz;
    80001756:	8532                	mv	a0,a2
    80001758:	b7f1                	j	80001724 <uvmalloc+0x74>

000000008000175a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000175a:	7179                	addi	sp,sp,-48
    8000175c:	f406                	sd	ra,40(sp)
    8000175e:	f022                	sd	s0,32(sp)
    80001760:	ec26                	sd	s1,24(sp)
    80001762:	e84a                	sd	s2,16(sp)
    80001764:	e44e                	sd	s3,8(sp)
    80001766:	e052                	sd	s4,0(sp)
    80001768:	1800                	addi	s0,sp,48
    8000176a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000176c:	84aa                	mv	s1,a0
    8000176e:	6905                	lui	s2,0x1
    80001770:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001772:	4985                	li	s3,1
    80001774:	a821                	j	8000178c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001776:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001778:	0532                	slli	a0,a0,0xc
    8000177a:	00000097          	auipc	ra,0x0
    8000177e:	fe0080e7          	jalr	-32(ra) # 8000175a <freewalk>
      pagetable[i] = 0;
    80001782:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001786:	04a1                	addi	s1,s1,8
    80001788:	03248163          	beq	s1,s2,800017aa <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000178c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000178e:	00f57793          	andi	a5,a0,15
    80001792:	ff3782e3          	beq	a5,s3,80001776 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001796:	8905                	andi	a0,a0,1
    80001798:	d57d                	beqz	a0,80001786 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000179a:	00008517          	auipc	a0,0x8
    8000179e:	a4e50513          	addi	a0,a0,-1458 # 800091e8 <digits+0x198>
    800017a2:	fffff097          	auipc	ra,0xfffff
    800017a6:	d8c080e7          	jalr	-628(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    800017aa:	8552                	mv	a0,s4
    800017ac:	fffff097          	auipc	ra,0xfffff
    800017b0:	22e080e7          	jalr	558(ra) # 800009da <kfree>
}
    800017b4:	70a2                	ld	ra,40(sp)
    800017b6:	7402                	ld	s0,32(sp)
    800017b8:	64e2                	ld	s1,24(sp)
    800017ba:	6942                	ld	s2,16(sp)
    800017bc:	69a2                	ld	s3,8(sp)
    800017be:	6a02                	ld	s4,0(sp)
    800017c0:	6145                	addi	sp,sp,48
    800017c2:	8082                	ret

00000000800017c4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800017c4:	1101                	addi	sp,sp,-32
    800017c6:	ec06                	sd	ra,24(sp)
    800017c8:	e822                	sd	s0,16(sp)
    800017ca:	e426                	sd	s1,8(sp)
    800017cc:	1000                	addi	s0,sp,32
    800017ce:	84aa                	mv	s1,a0
  if(sz > 0)
    800017d0:	e999                	bnez	a1,800017e6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800017d2:	8526                	mv	a0,s1
    800017d4:	00000097          	auipc	ra,0x0
    800017d8:	f86080e7          	jalr	-122(ra) # 8000175a <freewalk>
}
    800017dc:	60e2                	ld	ra,24(sp)
    800017de:	6442                	ld	s0,16(sp)
    800017e0:	64a2                	ld	s1,8(sp)
    800017e2:	6105                	addi	sp,sp,32
    800017e4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800017e6:	6605                	lui	a2,0x1
    800017e8:	167d                	addi	a2,a2,-1
    800017ea:	962e                	add	a2,a2,a1
    800017ec:	4685                	li	a3,1
    800017ee:	8231                	srli	a2,a2,0xc
    800017f0:	4581                	li	a1,0
    800017f2:	00000097          	auipc	ra,0x0
    800017f6:	d12080e7          	jalr	-750(ra) # 80001504 <uvmunmap>
    800017fa:	bfe1                	j	800017d2 <uvmfree+0xe>

00000000800017fc <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800017fc:	c679                	beqz	a2,800018ca <uvmcopy+0xce>
{
    800017fe:	715d                	addi	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	addi	s0,sp,80
    80001814:	8b2a                	mv	s6,a0
    80001816:	8aae                	mv	s5,a1
    80001818:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000181a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000181c:	4601                	li	a2,0
    8000181e:	85ce                	mv	a1,s3
    80001820:	855a                	mv	a0,s6
    80001822:	00000097          	auipc	ra,0x0
    80001826:	a46080e7          	jalr	-1466(ra) # 80001268 <walk>
    8000182a:	c531                	beqz	a0,80001876 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000182c:	6118                	ld	a4,0(a0)
    8000182e:	00177793          	andi	a5,a4,1
    80001832:	cbb1                	beqz	a5,80001886 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001834:	00a75593          	srli	a1,a4,0xa
    80001838:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000183c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001840:	fffff097          	auipc	ra,0xfffff
    80001844:	296080e7          	jalr	662(ra) # 80000ad6 <kalloc>
    80001848:	892a                	mv	s2,a0
    8000184a:	c939                	beqz	a0,800018a0 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000184c:	6605                	lui	a2,0x1
    8000184e:	85de                	mv	a1,s7
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	784080e7          	jalr	1924(ra) # 80000fd4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001858:	8726                	mv	a4,s1
    8000185a:	86ca                	mv	a3,s2
    8000185c:	6605                	lui	a2,0x1
    8000185e:	85ce                	mv	a1,s3
    80001860:	8556                	mv	a0,s5
    80001862:	00000097          	auipc	ra,0x0
    80001866:	aee080e7          	jalr	-1298(ra) # 80001350 <mappages>
    8000186a:	e515                	bnez	a0,80001896 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000186c:	6785                	lui	a5,0x1
    8000186e:	99be                	add	s3,s3,a5
    80001870:	fb49e6e3          	bltu	s3,s4,8000181c <uvmcopy+0x20>
    80001874:	a081                	j	800018b4 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001876:	00008517          	auipc	a0,0x8
    8000187a:	98250513          	addi	a0,a0,-1662 # 800091f8 <digits+0x1a8>
    8000187e:	fffff097          	auipc	ra,0xfffff
    80001882:	cb0080e7          	jalr	-848(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    80001886:	00008517          	auipc	a0,0x8
    8000188a:	99250513          	addi	a0,a0,-1646 # 80009218 <digits+0x1c8>
    8000188e:	fffff097          	auipc	ra,0xfffff
    80001892:	ca0080e7          	jalr	-864(ra) # 8000052e <panic>
      kfree(mem);
    80001896:	854a                	mv	a0,s2
    80001898:	fffff097          	auipc	ra,0xfffff
    8000189c:	142080e7          	jalr	322(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800018a0:	4685                	li	a3,1
    800018a2:	00c9d613          	srli	a2,s3,0xc
    800018a6:	4581                	li	a1,0
    800018a8:	8556                	mv	a0,s5
    800018aa:	00000097          	auipc	ra,0x0
    800018ae:	c5a080e7          	jalr	-934(ra) # 80001504 <uvmunmap>
  return -1;
    800018b2:	557d                	li	a0,-1
}
    800018b4:	60a6                	ld	ra,72(sp)
    800018b6:	6406                	ld	s0,64(sp)
    800018b8:	74e2                	ld	s1,56(sp)
    800018ba:	7942                	ld	s2,48(sp)
    800018bc:	79a2                	ld	s3,40(sp)
    800018be:	7a02                	ld	s4,32(sp)
    800018c0:	6ae2                	ld	s5,24(sp)
    800018c2:	6b42                	ld	s6,16(sp)
    800018c4:	6ba2                	ld	s7,8(sp)
    800018c6:	6161                	addi	sp,sp,80
    800018c8:	8082                	ret
  return 0;
    800018ca:	4501                	li	a0,0
}
    800018cc:	8082                	ret

00000000800018ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800018ce:	1141                	addi	sp,sp,-16
    800018d0:	e406                	sd	ra,8(sp)
    800018d2:	e022                	sd	s0,0(sp)
    800018d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800018d6:	4601                	li	a2,0
    800018d8:	00000097          	auipc	ra,0x0
    800018dc:	990080e7          	jalr	-1648(ra) # 80001268 <walk>
  if(pte == 0)
    800018e0:	c901                	beqz	a0,800018f0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800018e2:	611c                	ld	a5,0(a0)
    800018e4:	9bbd                	andi	a5,a5,-17
    800018e6:	e11c                	sd	a5,0(a0)
}
    800018e8:	60a2                	ld	ra,8(sp)
    800018ea:	6402                	ld	s0,0(sp)
    800018ec:	0141                	addi	sp,sp,16
    800018ee:	8082                	ret
    panic("uvmclear");
    800018f0:	00008517          	auipc	a0,0x8
    800018f4:	94850513          	addi	a0,a0,-1720 # 80009238 <digits+0x1e8>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	c36080e7          	jalr	-970(ra) # 8000052e <panic>

0000000080001900 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001900:	c6bd                	beqz	a3,8000196e <copyout+0x6e>
{
    80001902:	715d                	addi	sp,sp,-80
    80001904:	e486                	sd	ra,72(sp)
    80001906:	e0a2                	sd	s0,64(sp)
    80001908:	fc26                	sd	s1,56(sp)
    8000190a:	f84a                	sd	s2,48(sp)
    8000190c:	f44e                	sd	s3,40(sp)
    8000190e:	f052                	sd	s4,32(sp)
    80001910:	ec56                	sd	s5,24(sp)
    80001912:	e85a                	sd	s6,16(sp)
    80001914:	e45e                	sd	s7,8(sp)
    80001916:	e062                	sd	s8,0(sp)
    80001918:	0880                	addi	s0,sp,80
    8000191a:	8b2a                	mv	s6,a0
    8000191c:	8c2e                	mv	s8,a1
    8000191e:	8a32                	mv	s4,a2
    80001920:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001922:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001924:	6a85                	lui	s5,0x1
    80001926:	a015                	j	8000194a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001928:	9562                	add	a0,a0,s8
    8000192a:	0004861b          	sext.w	a2,s1
    8000192e:	85d2                	mv	a1,s4
    80001930:	41250533          	sub	a0,a0,s2
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	6a0080e7          	jalr	1696(ra) # 80000fd4 <memmove>

    len -= n;
    8000193c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001940:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001942:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001946:	02098263          	beqz	s3,8000196a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000194a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000194e:	85ca                	mv	a1,s2
    80001950:	855a                	mv	a0,s6
    80001952:	00000097          	auipc	ra,0x0
    80001956:	9bc080e7          	jalr	-1604(ra) # 8000130e <walkaddr>
    if(pa0 == 0)
    8000195a:	cd01                	beqz	a0,80001972 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000195c:	418904b3          	sub	s1,s2,s8
    80001960:	94d6                	add	s1,s1,s5
    if(n > len)
    80001962:	fc99f3e3          	bgeu	s3,s1,80001928 <copyout+0x28>
    80001966:	84ce                	mv	s1,s3
    80001968:	b7c1                	j	80001928 <copyout+0x28>
  }
  return 0;
    8000196a:	4501                	li	a0,0
    8000196c:	a021                	j	80001974 <copyout+0x74>
    8000196e:	4501                	li	a0,0
}
    80001970:	8082                	ret
      return -1;
    80001972:	557d                	li	a0,-1
}
    80001974:	60a6                	ld	ra,72(sp)
    80001976:	6406                	ld	s0,64(sp)
    80001978:	74e2                	ld	s1,56(sp)
    8000197a:	7942                	ld	s2,48(sp)
    8000197c:	79a2                	ld	s3,40(sp)
    8000197e:	7a02                	ld	s4,32(sp)
    80001980:	6ae2                	ld	s5,24(sp)
    80001982:	6b42                	ld	s6,16(sp)
    80001984:	6ba2                	ld	s7,8(sp)
    80001986:	6c02                	ld	s8,0(sp)
    80001988:	6161                	addi	sp,sp,80
    8000198a:	8082                	ret

000000008000198c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000198c:	caa5                	beqz	a3,800019fc <copyin+0x70>
{
    8000198e:	715d                	addi	sp,sp,-80
    80001990:	e486                	sd	ra,72(sp)
    80001992:	e0a2                	sd	s0,64(sp)
    80001994:	fc26                	sd	s1,56(sp)
    80001996:	f84a                	sd	s2,48(sp)
    80001998:	f44e                	sd	s3,40(sp)
    8000199a:	f052                	sd	s4,32(sp)
    8000199c:	ec56                	sd	s5,24(sp)
    8000199e:	e85a                	sd	s6,16(sp)
    800019a0:	e45e                	sd	s7,8(sp)
    800019a2:	e062                	sd	s8,0(sp)
    800019a4:	0880                	addi	s0,sp,80
    800019a6:	8b2a                	mv	s6,a0
    800019a8:	8a2e                	mv	s4,a1
    800019aa:	8c32                	mv	s8,a2
    800019ac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800019ae:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019b0:	6a85                	lui	s5,0x1
    800019b2:	a01d                	j	800019d8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800019b4:	018505b3          	add	a1,a0,s8
    800019b8:	0004861b          	sext.w	a2,s1
    800019bc:	412585b3          	sub	a1,a1,s2
    800019c0:	8552                	mv	a0,s4
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	612080e7          	jalr	1554(ra) # 80000fd4 <memmove>

    len -= n;
    800019ca:	409989b3          	sub	s3,s3,s1
    dst += n;
    800019ce:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800019d0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800019d4:	02098263          	beqz	s3,800019f8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800019d8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019dc:	85ca                	mv	a1,s2
    800019de:	855a                	mv	a0,s6
    800019e0:	00000097          	auipc	ra,0x0
    800019e4:	92e080e7          	jalr	-1746(ra) # 8000130e <walkaddr>
    if(pa0 == 0)
    800019e8:	cd01                	beqz	a0,80001a00 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800019ea:	418904b3          	sub	s1,s2,s8
    800019ee:	94d6                	add	s1,s1,s5
    if(n > len)
    800019f0:	fc99f2e3          	bgeu	s3,s1,800019b4 <copyin+0x28>
    800019f4:	84ce                	mv	s1,s3
    800019f6:	bf7d                	j	800019b4 <copyin+0x28>
  }
  return 0;
    800019f8:	4501                	li	a0,0
    800019fa:	a021                	j	80001a02 <copyin+0x76>
    800019fc:	4501                	li	a0,0
}
    800019fe:	8082                	ret
      return -1;
    80001a00:	557d                	li	a0,-1
}
    80001a02:	60a6                	ld	ra,72(sp)
    80001a04:	6406                	ld	s0,64(sp)
    80001a06:	74e2                	ld	s1,56(sp)
    80001a08:	7942                	ld	s2,48(sp)
    80001a0a:	79a2                	ld	s3,40(sp)
    80001a0c:	7a02                	ld	s4,32(sp)
    80001a0e:	6ae2                	ld	s5,24(sp)
    80001a10:	6b42                	ld	s6,16(sp)
    80001a12:	6ba2                	ld	s7,8(sp)
    80001a14:	6c02                	ld	s8,0(sp)
    80001a16:	6161                	addi	sp,sp,80
    80001a18:	8082                	ret

0000000080001a1a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a1a:	c6c5                	beqz	a3,80001ac2 <copyinstr+0xa8>
{
    80001a1c:	715d                	addi	sp,sp,-80
    80001a1e:	e486                	sd	ra,72(sp)
    80001a20:	e0a2                	sd	s0,64(sp)
    80001a22:	fc26                	sd	s1,56(sp)
    80001a24:	f84a                	sd	s2,48(sp)
    80001a26:	f44e                	sd	s3,40(sp)
    80001a28:	f052                	sd	s4,32(sp)
    80001a2a:	ec56                	sd	s5,24(sp)
    80001a2c:	e85a                	sd	s6,16(sp)
    80001a2e:	e45e                	sd	s7,8(sp)
    80001a30:	0880                	addi	s0,sp,80
    80001a32:	8a2a                	mv	s4,a0
    80001a34:	8b2e                	mv	s6,a1
    80001a36:	8bb2                	mv	s7,a2
    80001a38:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001a3a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a3c:	6985                	lui	s3,0x1
    80001a3e:	a035                	j	80001a6a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a40:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001a44:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a46:	0017b793          	seqz	a5,a5
    80001a4a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a4e:	60a6                	ld	ra,72(sp)
    80001a50:	6406                	ld	s0,64(sp)
    80001a52:	74e2                	ld	s1,56(sp)
    80001a54:	7942                	ld	s2,48(sp)
    80001a56:	79a2                	ld	s3,40(sp)
    80001a58:	7a02                	ld	s4,32(sp)
    80001a5a:	6ae2                	ld	s5,24(sp)
    80001a5c:	6b42                	ld	s6,16(sp)
    80001a5e:	6ba2                	ld	s7,8(sp)
    80001a60:	6161                	addi	sp,sp,80
    80001a62:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a64:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a68:	c8a9                	beqz	s1,80001aba <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001a6a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a6e:	85ca                	mv	a1,s2
    80001a70:	8552                	mv	a0,s4
    80001a72:	00000097          	auipc	ra,0x0
    80001a76:	89c080e7          	jalr	-1892(ra) # 8000130e <walkaddr>
    if(pa0 == 0)
    80001a7a:	c131                	beqz	a0,80001abe <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001a7c:	41790833          	sub	a6,s2,s7
    80001a80:	984e                	add	a6,a6,s3
    if(n > max)
    80001a82:	0104f363          	bgeu	s1,a6,80001a88 <copyinstr+0x6e>
    80001a86:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001a88:	955e                	add	a0,a0,s7
    80001a8a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001a8e:	fc080be3          	beqz	a6,80001a64 <copyinstr+0x4a>
    80001a92:	985a                	add	a6,a6,s6
    80001a94:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001a96:	41650633          	sub	a2,a0,s6
    80001a9a:	14fd                	addi	s1,s1,-1
    80001a9c:	9b26                	add	s6,s6,s1
    80001a9e:	00f60733          	add	a4,a2,a5
    80001aa2:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbc000>
    80001aa6:	df49                	beqz	a4,80001a40 <copyinstr+0x26>
        *dst = *p;
    80001aa8:	00e78023          	sb	a4,0(a5)
      --max;
    80001aac:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001ab0:	0785                	addi	a5,a5,1
    while(n > 0){
    80001ab2:	ff0796e3          	bne	a5,a6,80001a9e <copyinstr+0x84>
      dst++;
    80001ab6:	8b42                	mv	s6,a6
    80001ab8:	b775                	j	80001a64 <copyinstr+0x4a>
    80001aba:	4781                	li	a5,0
    80001abc:	b769                	j	80001a46 <copyinstr+0x2c>
      return -1;
    80001abe:	557d                	li	a0,-1
    80001ac0:	b779                	j	80001a4e <copyinstr+0x34>
  int got_null = 0;
    80001ac2:	4781                	li	a5,0
  if(got_null){
    80001ac4:	0017b793          	seqz	a5,a5
    80001ac8:	40f00533          	neg	a0,a5
}
    80001acc:	8082                	ret

0000000080001ace <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001ace:	711d                	addi	sp,sp,-96
    80001ad0:	ec86                	sd	ra,88(sp)
    80001ad2:	e8a2                	sd	s0,80(sp)
    80001ad4:	e4a6                	sd	s1,72(sp)
    80001ad6:	e0ca                	sd	s2,64(sp)
    80001ad8:	fc4e                	sd	s3,56(sp)
    80001ada:	f852                	sd	s4,48(sp)
    80001adc:	f456                	sd	s5,40(sp)
    80001ade:	f05a                	sd	s6,32(sp)
    80001ae0:	ec5e                	sd	s7,24(sp)
    80001ae2:	e862                	sd	s8,16(sp)
    80001ae4:	e466                	sd	s9,8(sp)
    80001ae6:	e06a                	sd	s10,0(sp)
    80001ae8:	1080                	addi	s0,sp,96
    80001aea:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001aec:	00013997          	auipc	s3,0x13
    80001af0:	88498993          	addi	s3,s3,-1916 # 80014370 <proc+0x848>
    80001af4:	00034d17          	auipc	s10,0x34
    80001af8:	a7cd0d13          	addi	s10,s10,-1412 # 80035570 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001afc:	7c7d                	lui	s8,0xfffff
    80001afe:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbc7b8>
    80001b02:	00007c97          	auipc	s9,0x7
    80001b06:	506cbc83          	ld	s9,1286(s9) # 80009008 <etext+0x8>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    80001b0a:	00007b97          	auipc	s7,0x7
    80001b0e:	506b8b93          	addi	s7,s7,1286 # 80009010 <etext+0x10>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001b12:	04000ab7          	lui	s5,0x4000
    80001b16:	1afd                	addi	s5,s5,-1
    80001b18:	0ab2                	slli	s5,s5,0xc
    80001b1a:	a839                	j	80001b38 <proc_mapstacks+0x6a>
        panic("kalloc");
    80001b1c:	00007517          	auipc	a0,0x7
    80001b20:	72c50513          	addi	a0,a0,1836 # 80009248 <digits+0x1f8>
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	a0a080e7          	jalr	-1526(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b2c:	6785                	lui	a5,0x1
    80001b2e:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80001b32:	99be                	add	s3,s3,a5
    80001b34:	07a98363          	beq	s3,s10,80001b9a <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001b38:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    80001b3c:	01898933          	add	s2,s3,s8
    80001b40:	00012797          	auipc	a5,0x12
    80001b44:	fe878793          	addi	a5,a5,-24 # 80013b28 <proc>
    80001b48:	40f90933          	sub	s2,s2,a5
    80001b4c:	40395913          	srai	s2,s2,0x3
    80001b50:	03990933          	mul	s2,s2,s9
    80001b54:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001b58:	84d2                	mv	s1,s4
      char *pa = kalloc();
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	f7c080e7          	jalr	-132(ra) # 80000ad6 <kalloc>
    80001b62:	862a                	mv	a2,a0
      if(pa == 0)
    80001b64:	dd45                	beqz	a0,80001b1c <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    80001b66:	414485b3          	sub	a1,s1,s4
    80001b6a:	858d                	srai	a1,a1,0x3
    80001b6c:	000bb783          	ld	a5,0(s7)
    80001b70:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001b74:	012585bb          	addw	a1,a1,s2
    80001b78:	2585                	addiw	a1,a1,1
    80001b7a:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b7e:	4719                	li	a4,6
    80001b80:	6685                	lui	a3,0x1
    80001b82:	40ba85b3          	sub	a1,s5,a1
    80001b86:	855a                	mv	a0,s6
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	856080e7          	jalr	-1962(ra) # 800013de <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001b90:	0b848493          	addi	s1,s1,184
    80001b94:	fd3493e3          	bne	s1,s3,80001b5a <proc_mapstacks+0x8c>
    80001b98:	bf51                	j	80001b2c <proc_mapstacks+0x5e>
    }
  }
}
    80001b9a:	60e6                	ld	ra,88(sp)
    80001b9c:	6446                	ld	s0,80(sp)
    80001b9e:	64a6                	ld	s1,72(sp)
    80001ba0:	6906                	ld	s2,64(sp)
    80001ba2:	79e2                	ld	s3,56(sp)
    80001ba4:	7a42                	ld	s4,48(sp)
    80001ba6:	7aa2                	ld	s5,40(sp)
    80001ba8:	7b02                	ld	s6,32(sp)
    80001baa:	6be2                	ld	s7,24(sp)
    80001bac:	6c42                	ld	s8,16(sp)
    80001bae:	6ca2                	ld	s9,8(sp)
    80001bb0:	6d02                	ld	s10,0(sp)
    80001bb2:	6125                	addi	sp,sp,96
    80001bb4:	8082                	ret

0000000080001bb6 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001bb6:	7159                	addi	sp,sp,-112
    80001bb8:	f486                	sd	ra,104(sp)
    80001bba:	f0a2                	sd	s0,96(sp)
    80001bbc:	eca6                	sd	s1,88(sp)
    80001bbe:	e8ca                	sd	s2,80(sp)
    80001bc0:	e4ce                	sd	s3,72(sp)
    80001bc2:	e0d2                	sd	s4,64(sp)
    80001bc4:	fc56                	sd	s5,56(sp)
    80001bc6:	f85a                	sd	s6,48(sp)
    80001bc8:	f45e                	sd	s7,40(sp)
    80001bca:	f062                	sd	s8,32(sp)
    80001bcc:	ec66                	sd	s9,24(sp)
    80001bce:	e86a                	sd	s10,16(sp)
    80001bd0:	e46e                	sd	s11,8(sp)
    80001bd2:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    80001bd4:	00007597          	auipc	a1,0x7
    80001bd8:	67c58593          	addi	a1,a1,1660 # 80009250 <digits+0x200>
    80001bdc:	00012517          	auipc	a0,0x12
    80001be0:	ac450513          	addi	a0,a0,-1340 # 800136a0 <pid_lock>
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	f52080e7          	jalr	-174(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001bec:	00007597          	auipc	a1,0x7
    80001bf0:	66c58593          	addi	a1,a1,1644 # 80009258 <digits+0x208>
    80001bf4:	00012517          	auipc	a0,0x12
    80001bf8:	ac450513          	addi	a0,a0,-1340 # 800136b8 <tid_lock>
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	f3a080e7          	jalr	-198(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c04:	00007597          	auipc	a1,0x7
    80001c08:	65c58593          	addi	a1,a1,1628 # 80009260 <digits+0x210>
    80001c0c:	00012517          	auipc	a0,0x12
    80001c10:	ac450513          	addi	a0,a0,-1340 # 800136d0 <wait_lock>
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	f22080e7          	jalr	-222(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001c1c:	00012997          	auipc	s3,0x12
    80001c20:	75498993          	addi	s3,s3,1876 # 80014370 <proc+0x848>
    80001c24:	00012c17          	auipc	s8,0x12
    80001c28:	f04c0c13          	addi	s8,s8,-252 # 80013b28 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001c2c:	8de2                	mv	s11,s8
    80001c2e:	00007d17          	auipc	s10,0x7
    80001c32:	3dad0d13          	addi	s10,s10,986 # 80009008 <etext+0x8>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    80001c36:	00007b97          	auipc	s7,0x7
    80001c3a:	642b8b93          	addi	s7,s7,1602 # 80009278 <digits+0x228>
        int thread_index = (int)(t-p->kthreads);
    80001c3e:	00007b17          	auipc	s6,0x7
    80001c42:	3d2b0b13          	addi	s6,s6,978 # 80009010 <etext+0x10>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001c46:	04000ab7          	lui	s5,0x4000
    80001c4a:	1afd                	addi	s5,s5,-1
    80001c4c:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001c4e:	6c85                	lui	s9,0x1
    80001c50:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    80001c54:	a809                	j	80001c66 <procinit+0xb0>
    80001c56:	9c66                	add	s8,s8,s9
    80001c58:	99e6                	add	s3,s3,s9
    80001c5a:	00033797          	auipc	a5,0x33
    80001c5e:	0ce78793          	addi	a5,a5,206 # 80034d28 <tickslock>
    80001c62:	06fc0263          	beq	s8,a5,80001cc6 <procinit+0x110>
      initlock(&p->lock, "proc");
    80001c66:	00007597          	auipc	a1,0x7
    80001c6a:	60a58593          	addi	a1,a1,1546 # 80009270 <digits+0x220>
    80001c6e:	8562                	mv	a0,s8
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	ec6080e7          	jalr	-314(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001c78:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    80001c7c:	41bc0933          	sub	s2,s8,s11
    80001c80:	40395913          	srai	s2,s2,0x3
    80001c84:	000d3783          	ld	a5,0(s10)
    80001c88:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001c8c:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001c90:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    80001c92:	85de                	mv	a1,s7
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	ea0080e7          	jalr	-352(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001c9e:	414487b3          	sub	a5,s1,s4
    80001ca2:	878d                	srai	a5,a5,0x3
    80001ca4:	000b3703          	ld	a4,0(s6)
    80001ca8:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001cac:	012787bb          	addw	a5,a5,s2
    80001cb0:	2785                	addiw	a5,a5,1
    80001cb2:	00d7979b          	slliw	a5,a5,0xd
    80001cb6:	40fa87b3          	sub	a5,s5,a5
    80001cba:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001cbc:	0b848493          	addi	s1,s1,184
    80001cc0:	fd3499e3          	bne	s1,s3,80001c92 <procinit+0xdc>
    80001cc4:	bf49                	j	80001c56 <procinit+0xa0>
      }
  }
}
    80001cc6:	70a6                	ld	ra,104(sp)
    80001cc8:	7406                	ld	s0,96(sp)
    80001cca:	64e6                	ld	s1,88(sp)
    80001ccc:	6946                	ld	s2,80(sp)
    80001cce:	69a6                	ld	s3,72(sp)
    80001cd0:	6a06                	ld	s4,64(sp)
    80001cd2:	7ae2                	ld	s5,56(sp)
    80001cd4:	7b42                	ld	s6,48(sp)
    80001cd6:	7ba2                	ld	s7,40(sp)
    80001cd8:	7c02                	ld	s8,32(sp)
    80001cda:	6ce2                	ld	s9,24(sp)
    80001cdc:	6d42                	ld	s10,16(sp)
    80001cde:	6da2                	ld	s11,8(sp)
    80001ce0:	6165                	addi	sp,sp,112
    80001ce2:	8082                	ret

0000000080001ce4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
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
struct cpu*
mycpu(void) {
    80001cf4:	1141                	addi	sp,sp,-16
    80001cf6:	e422                	sd	s0,8(sp)
    80001cf8:	0800                	addi	s0,sp,16
    80001cfa:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001cfc:	0007851b          	sext.w	a0,a5
    80001d00:	00451793          	slli	a5,a0,0x4
    80001d04:	97aa                	add	a5,a5,a0
    80001d06:	078e                	slli	a5,a5,0x3
  return c;
}
    80001d08:	00012517          	auipc	a0,0x12
    80001d0c:	9e050513          	addi	a0,a0,-1568 # 800136e8 <cpus>
    80001d10:	953e                	add	a0,a0,a5
    80001d12:	6422                	ld	s0,8(sp)
    80001d14:	0141                	addi	sp,sp,16
    80001d16:	8082                	ret

0000000080001d18 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001d18:	1101                	addi	sp,sp,-32
    80001d1a:	ec06                	sd	ra,24(sp)
    80001d1c:	e822                	sd	s0,16(sp)
    80001d1e:	e426                	sd	s1,8(sp)
    80001d20:	1000                	addi	s0,sp,32
  push_off();
    80001d22:	fffff097          	auipc	ra,0xfffff
    80001d26:	e9a080e7          	jalr	-358(ra) # 80000bbc <push_off>
    80001d2a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d2c:	0007871b          	sext.w	a4,a5
    80001d30:	00471793          	slli	a5,a4,0x4
    80001d34:	97ba                	add	a5,a5,a4
    80001d36:	078e                	slli	a5,a5,0x3
    80001d38:	00012717          	auipc	a4,0x12
    80001d3c:	96870713          	addi	a4,a4,-1688 # 800136a0 <pid_lock>
    80001d40:	97ba                	add	a5,a5,a4
    80001d42:	67a4                	ld	s1,72(a5)
  pop_off();
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	f18080e7          	jalr	-232(ra) # 80000c5c <pop_off>
  return p;
}//
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	60e2                	ld	ra,24(sp)
    80001d50:	6442                	ld	s0,16(sp)
    80001d52:	64a2                	ld	s1,8(sp)
    80001d54:	6105                	addi	sp,sp,32
    80001d56:	8082                	ret

0000000080001d58 <mykthread>:

struct kthread*
mykthread(void){
    80001d58:	1101                	addi	sp,sp,-32
    80001d5a:	ec06                	sd	ra,24(sp)
    80001d5c:	e822                	sd	s0,16(sp)
    80001d5e:	e426                	sd	s1,8(sp)
    80001d60:	1000                	addi	s0,sp,32
  push_off();
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	e5a080e7          	jalr	-422(ra) # 80000bbc <push_off>
    80001d6a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001d6c:	0007871b          	sext.w	a4,a5
    80001d70:	00471793          	slli	a5,a4,0x4
    80001d74:	97ba                	add	a5,a5,a4
    80001d76:	078e                	slli	a5,a5,0x3
    80001d78:	00012717          	auipc	a4,0x12
    80001d7c:	92870713          	addi	a4,a4,-1752 # 800136a0 <pid_lock>
    80001d80:	97ba                	add	a5,a5,a4
    80001d82:	67e4                	ld	s1,200(a5)
  pop_off();
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	ed8080e7          	jalr	-296(ra) # 80000c5c <pop_off>
  return t;  
}
    80001d8c:	8526                	mv	a0,s1
    80001d8e:	60e2                	ld	ra,24(sp)
    80001d90:	6442                	ld	s0,16(sp)
    80001d92:	64a2                	ld	s1,8(sp)
    80001d94:	6105                	addi	sp,sp,32
    80001d96:	8082                	ret

0000000080001d98 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001d98:	1141                	addi	sp,sp,-16
    80001d9a:	e406                	sd	ra,8(sp)
    80001d9c:	e022                	sd	s0,0(sp)
    80001d9e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	fb8080e7          	jalr	-72(ra) # 80001d58 <mykthread>
    80001da8:	fffff097          	auipc	ra,0xfffff
    80001dac:	f14080e7          	jalr	-236(ra) # 80000cbc <release>

  if (first) {
    80001db0:	00008797          	auipc	a5,0x8
    80001db4:	b507a783          	lw	a5,-1200(a5) # 80009900 <first.1>
    80001db8:	eb89                	bnez	a5,80001dca <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001dba:	00002097          	auipc	ra,0x2
    80001dbe:	85a080e7          	jalr	-1958(ra) # 80003614 <usertrapret>
}
    80001dc2:	60a2                	ld	ra,8(sp)
    80001dc4:	6402                	ld	s0,0(sp)
    80001dc6:	0141                	addi	sp,sp,16
    80001dc8:	8082                	ret
    first = 0;
    80001dca:	00008797          	auipc	a5,0x8
    80001dce:	b207ab23          	sw	zero,-1226(a5) # 80009900 <first.1>
    fsinit(ROOTDEV);
    80001dd2:	4505                	li	a0,1
    80001dd4:	00003097          	auipc	ra,0x3
    80001dd8:	8d2080e7          	jalr	-1838(ra) # 800046a6 <fsinit>
    80001ddc:	bff9                	j	80001dba <forkret+0x22>

0000000080001dde <allocpid>:
allocpid() {
    80001dde:	1101                	addi	sp,sp,-32
    80001de0:	ec06                	sd	ra,24(sp)
    80001de2:	e822                	sd	s0,16(sp)
    80001de4:	e426                	sd	s1,8(sp)
    80001de6:	e04a                	sd	s2,0(sp)
    80001de8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dea:	00012917          	auipc	s2,0x12
    80001dee:	8b690913          	addi	s2,s2,-1866 # 800136a0 <pid_lock>
    80001df2:	854a                	mv	a0,s2
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	e14080e7          	jalr	-492(ra) # 80000c08 <acquire>
  pid = nextpid;
    80001dfc:	00008797          	auipc	a5,0x8
    80001e00:	b0c78793          	addi	a5,a5,-1268 # 80009908 <nextpid>
    80001e04:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e06:	0014871b          	addiw	a4,s1,1
    80001e0a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e0c:	854a                	mv	a0,s2
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	eae080e7          	jalr	-338(ra) # 80000cbc <release>
}
    80001e16:	8526                	mv	a0,s1
    80001e18:	60e2                	ld	ra,24(sp)
    80001e1a:	6442                	ld	s0,16(sp)
    80001e1c:	64a2                	ld	s1,8(sp)
    80001e1e:	6902                	ld	s2,0(sp)
    80001e20:	6105                	addi	sp,sp,32
    80001e22:	8082                	ret

0000000080001e24 <alloctid>:
alloctid() {
    80001e24:	1101                	addi	sp,sp,-32
    80001e26:	ec06                	sd	ra,24(sp)
    80001e28:	e822                	sd	s0,16(sp)
    80001e2a:	e426                	sd	s1,8(sp)
    80001e2c:	e04a                	sd	s2,0(sp)
    80001e2e:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001e30:	00012917          	auipc	s2,0x12
    80001e34:	88890913          	addi	s2,s2,-1912 # 800136b8 <tid_lock>
    80001e38:	854a                	mv	a0,s2
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	dce080e7          	jalr	-562(ra) # 80000c08 <acquire>
  tid = nexttid;
    80001e42:	00008797          	auipc	a5,0x8
    80001e46:	ac278793          	addi	a5,a5,-1342 # 80009904 <nexttid>
    80001e4a:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001e4c:	0014871b          	addiw	a4,s1,1
    80001e50:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001e52:	854a                	mv	a0,s2
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	e68080e7          	jalr	-408(ra) # 80000cbc <release>
}
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	60e2                	ld	ra,24(sp)
    80001e60:	6442                	ld	s0,16(sp)
    80001e62:	64a2                	ld	s1,8(sp)
    80001e64:	6902                	ld	s2,0(sp)
    80001e66:	6105                	addi	sp,sp,32
    80001e68:	8082                	ret

0000000080001e6a <init_thread>:
init_thread(struct kthread *t){
    80001e6a:	1101                	addi	sp,sp,-32
    80001e6c:	ec06                	sd	ra,24(sp)
    80001e6e:	e822                	sd	s0,16(sp)
    80001e70:	e426                	sd	s1,8(sp)
    80001e72:	1000                	addi	s0,sp,32
    80001e74:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001e76:	4785                	li	a5,1
    80001e78:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001e7a:	00000097          	auipc	ra,0x0
    80001e7e:	faa080e7          	jalr	-86(ra) # 80001e24 <alloctid>
    80001e82:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001e84:	07000613          	li	a2,112
    80001e88:	4581                	li	a1,0
    80001e8a:	04848513          	addi	a0,s1,72
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	0ea080e7          	jalr	234(ra) # 80000f78 <memset>
  t->context.ra = (uint64)forkret;
    80001e96:	00000797          	auipc	a5,0x0
    80001e9a:	f0278793          	addi	a5,a5,-254 # 80001d98 <forkret>
    80001e9e:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001ea0:	7c9c                	ld	a5,56(s1)
    80001ea2:	6705                	lui	a4,0x1
    80001ea4:	97ba                	add	a5,a5,a4
    80001ea6:	e8bc                	sd	a5,80(s1)
}
    80001ea8:	4501                	li	a0,0
    80001eaa:	60e2                	ld	ra,24(sp)
    80001eac:	6442                	ld	s0,16(sp)
    80001eae:	64a2                	ld	s1,8(sp)
    80001eb0:	6105                	addi	sp,sp,32
    80001eb2:	8082                	ret

0000000080001eb4 <proc_pagetable>:
{
    80001eb4:	1101                	addi	sp,sp,-32
    80001eb6:	ec06                	sd	ra,24(sp)
    80001eb8:	e822                	sd	s0,16(sp)
    80001eba:	e426                	sd	s1,8(sp)
    80001ebc:	e04a                	sd	s2,0(sp)
    80001ebe:	1000                	addi	s0,sp,32
    80001ec0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	706080e7          	jalr	1798(ra) # 800015c8 <uvmcreate>
    80001eca:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ecc:	c121                	beqz	a0,80001f0c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ece:	4729                	li	a4,10
    80001ed0:	00006697          	auipc	a3,0x6
    80001ed4:	13068693          	addi	a3,a3,304 # 80008000 <_trampoline>
    80001ed8:	6605                	lui	a2,0x1
    80001eda:	040005b7          	lui	a1,0x4000
    80001ede:	15fd                	addi	a1,a1,-1
    80001ee0:	05b2                	slli	a1,a1,0xc
    80001ee2:	fffff097          	auipc	ra,0xfffff
    80001ee6:	46e080e7          	jalr	1134(ra) # 80001350 <mappages>
    80001eea:	02054863          	bltz	a0,80001f1a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001eee:	4719                	li	a4,6
    80001ef0:	04893683          	ld	a3,72(s2)
    80001ef4:	6605                	lui	a2,0x1
    80001ef6:	020005b7          	lui	a1,0x2000
    80001efa:	15fd                	addi	a1,a1,-1
    80001efc:	05b6                	slli	a1,a1,0xd
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	450080e7          	jalr	1104(ra) # 80001350 <mappages>
    80001f08:	02054163          	bltz	a0,80001f2a <proc_pagetable+0x76>
}
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	60e2                	ld	ra,24(sp)
    80001f10:	6442                	ld	s0,16(sp)
    80001f12:	64a2                	ld	s1,8(sp)
    80001f14:	6902                	ld	s2,0(sp)
    80001f16:	6105                	addi	sp,sp,32
    80001f18:	8082                	ret
    uvmfree(pagetable, 0);
    80001f1a:	4581                	li	a1,0
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	8a6080e7          	jalr	-1882(ra) # 800017c4 <uvmfree>
    return 0;
    80001f26:	4481                	li	s1,0
    80001f28:	b7d5                	j	80001f0c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f2a:	4681                	li	a3,0
    80001f2c:	4605                	li	a2,1
    80001f2e:	040005b7          	lui	a1,0x4000
    80001f32:	15fd                	addi	a1,a1,-1
    80001f34:	05b2                	slli	a1,a1,0xc
    80001f36:	8526                	mv	a0,s1
    80001f38:	fffff097          	auipc	ra,0xfffff
    80001f3c:	5cc080e7          	jalr	1484(ra) # 80001504 <uvmunmap>
    uvmfree(pagetable, 0);
    80001f40:	4581                	li	a1,0
    80001f42:	8526                	mv	a0,s1
    80001f44:	00000097          	auipc	ra,0x0
    80001f48:	880080e7          	jalr	-1920(ra) # 800017c4 <uvmfree>
    return 0;
    80001f4c:	4481                	li	s1,0
    80001f4e:	bf7d                	j	80001f0c <proc_pagetable+0x58>

0000000080001f50 <proc_freepagetable>:
{
    80001f50:	1101                	addi	sp,sp,-32
    80001f52:	ec06                	sd	ra,24(sp)
    80001f54:	e822                	sd	s0,16(sp)
    80001f56:	e426                	sd	s1,8(sp)
    80001f58:	e04a                	sd	s2,0(sp)
    80001f5a:	1000                	addi	s0,sp,32
    80001f5c:	84aa                	mv	s1,a0
    80001f5e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f60:	4681                	li	a3,0
    80001f62:	4605                	li	a2,1
    80001f64:	040005b7          	lui	a1,0x4000
    80001f68:	15fd                	addi	a1,a1,-1
    80001f6a:	05b2                	slli	a1,a1,0xc
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	598080e7          	jalr	1432(ra) # 80001504 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001f74:	4681                	li	a3,0
    80001f76:	4605                	li	a2,1
    80001f78:	020005b7          	lui	a1,0x2000
    80001f7c:	15fd                	addi	a1,a1,-1
    80001f7e:	05b6                	slli	a1,a1,0xd
    80001f80:	8526                	mv	a0,s1
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	582080e7          	jalr	1410(ra) # 80001504 <uvmunmap>
  uvmfree(pagetable, sz);
    80001f8a:	85ca                	mv	a1,s2
    80001f8c:	8526                	mv	a0,s1
    80001f8e:	00000097          	auipc	ra,0x0
    80001f92:	836080e7          	jalr	-1994(ra) # 800017c4 <uvmfree>
}
    80001f96:	60e2                	ld	ra,24(sp)
    80001f98:	6442                	ld	s0,16(sp)
    80001f9a:	64a2                	ld	s1,8(sp)
    80001f9c:	6902                	ld	s2,0(sp)
    80001f9e:	6105                	addi	sp,sp,32
    80001fa0:	8082                	ret

0000000080001fa2 <freeproc>:
{
    80001fa2:	7179                	addi	sp,sp,-48
    80001fa4:	f406                	sd	ra,40(sp)
    80001fa6:	f022                	sd	s0,32(sp)
    80001fa8:	ec26                	sd	s1,24(sp)
    80001faa:	e84a                	sd	s2,16(sp)
    80001fac:	e44e                	sd	s3,8(sp)
    80001fae:	1800                	addi	s0,sp,48
    80001fb0:	892a                	mv	s2,a0
   if(p->threads_tf_start)
    80001fb2:	6528                	ld	a0,72(a0)
    80001fb4:	c509                	beqz	a0,80001fbe <freeproc+0x1c>
    kfree((void*)p->threads_tf_start);
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	a24080e7          	jalr	-1500(ra) # 800009da <kfree>
   p->threads_tf_start = 0;
    80001fbe:	04093423          	sd	zero,72(s2)
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001fc2:	28890493          	addi	s1,s2,648
    80001fc6:	6985                	lui	s3,0x1
    80001fc8:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001fcc:	99ca                	add	s3,s3,s2
    acquire(&t->lock);
    80001fce:	8526                	mv	a0,s1
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	c38080e7          	jalr	-968(ra) # 80000c08 <acquire>
  t->tid = 0;
    80001fd8:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001fdc:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001fe0:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001fe4:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001fe8:	0004ac23          	sw	zero,24(s1)
    release(&t->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	cce080e7          	jalr	-818(ra) # 80000cbc <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001ff6:	0b848493          	addi	s1,s1,184
    80001ffa:	fc999ae3          	bne	s3,s1,80001fce <freeproc+0x2c>
  p->user_trapframe_backup = 0;
    80001ffe:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80002002:	04093503          	ld	a0,64(s2)
    80002006:	c519                	beqz	a0,80002014 <freeproc+0x72>
    proc_freepagetable(p->pagetable, p->sz);
    80002008:	03893583          	ld	a1,56(s2)
    8000200c:	00000097          	auipc	ra,0x0
    80002010:	f44080e7          	jalr	-188(ra) # 80001f50 <proc_freepagetable>
  p->pagetable = 0;
    80002014:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80002018:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    8000201c:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80002020:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80002024:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80002028:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    8000202c:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80002030:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80002034:	00092c23          	sw	zero,24(s2)
}
    80002038:	70a2                	ld	ra,40(sp)
    8000203a:	7402                	ld	s0,32(sp)
    8000203c:	64e2                	ld	s1,24(sp)
    8000203e:	6942                	ld	s2,16(sp)
    80002040:	69a2                	ld	s3,8(sp)
    80002042:	6145                	addi	sp,sp,48
    80002044:	8082                	ret

0000000080002046 <allocproc>:
{
    80002046:	7179                	addi	sp,sp,-48
    80002048:	f406                	sd	ra,40(sp)
    8000204a:	f022                	sd	s0,32(sp)
    8000204c:	ec26                	sd	s1,24(sp)
    8000204e:	e84a                	sd	s2,16(sp)
    80002050:	e44e                	sd	s3,8(sp)
    80002052:	e052                	sd	s4,0(sp)
    80002054:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80002056:	00012497          	auipc	s1,0x12
    8000205a:	ad248493          	addi	s1,s1,-1326 # 80013b28 <proc>
    8000205e:	6985                	lui	s3,0x1
    80002060:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002064:	00033a17          	auipc	s4,0x33
    80002068:	cc4a0a13          	addi	s4,s4,-828 # 80034d28 <tickslock>
    acquire(&p->lock);
    8000206c:	8926                	mv	s2,s1
    8000206e:	8526                	mv	a0,s1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	b98080e7          	jalr	-1128(ra) # 80000c08 <acquire>
    if(p->state == UNUSED) {
    80002078:	4c9c                	lw	a5,24(s1)
    8000207a:	cb99                	beqz	a5,80002090 <allocproc+0x4a>
      release(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	c3e080e7          	jalr	-962(ra) # 80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002086:	94ce                	add	s1,s1,s3
    80002088:	ff4492e3          	bne	s1,s4,8000206c <allocproc+0x26>
  return 0;
    8000208c:	4481                	li	s1,0
    8000208e:	a845                	j	8000213e <allocproc+0xf8>
  p->pid = allocpid();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	d4e080e7          	jalr	-690(ra) # 80001dde <allocpid>
    80002098:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    8000209a:	4785                	li	a5,1
    8000209c:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    8000209e:	fffff097          	auipc	ra,0xfffff
    800020a2:	a38080e7          	jalr	-1480(ra) # 80000ad6 <kalloc>
    800020a6:	89aa                	mv	s3,a0
    800020a8:	e4a8                	sd	a0,72(s1)
    800020aa:	0f848713          	addi	a4,s1,248
    800020ae:	1f848793          	addi	a5,s1,504
    800020b2:	27848693          	addi	a3,s1,632
    800020b6:	cd49                	beqz	a0,80002150 <allocproc+0x10a>
    p->signal_handlers[i] = SIG_DFL;
    800020b8:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    800020bc:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    800020c0:	0721                	addi	a4,a4,8
    800020c2:	0791                	addi	a5,a5,4
    800020c4:	fed79ae3          	bne	a5,a3,800020b8 <allocproc+0x72>
  p->signal_mask= 0;
    800020c8:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    800020cc:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    800020d0:	4785                	li	a5,1
    800020d2:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    800020d4:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    800020d8:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    800020dc:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    800020e0:	8526                	mv	a0,s1
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	dd2080e7          	jalr	-558(ra) # 80001eb4 <proc_pagetable>
    800020ea:	89aa                	mv	s3,a0
    800020ec:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    800020ee:	cd2d                	beqz	a0,80002168 <allocproc+0x122>
    800020f0:	2a048793          	addi	a5,s1,672
    800020f4:	64b8                	ld	a4,72(s1)
    800020f6:	6685                	lui	a3,0x1
    800020f8:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    800020fc:	9936                	add	s2,s2,a3
    t->tid=-1;
    800020fe:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80002100:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80002104:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80002108:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     
    8000210a:	f798                	sd	a4,40(a5)
    t->killed = 0;
    8000210c:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80002110:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80002114:	0b878793          	addi	a5,a5,184
    80002118:	12070713          	addi	a4,a4,288
    8000211c:	ff2792e3          	bne	a5,s2,80002100 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80002120:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80002124:	854a                	mv	a0,s2
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	ae2080e7          	jalr	-1310(ra) # 80000c08 <acquire>
  if(init_thread(t) == -1){
    8000212e:	854a                	mv	a0,s2
    80002130:	00000097          	auipc	ra,0x0
    80002134:	d3a080e7          	jalr	-710(ra) # 80001e6a <init_thread>
    80002138:	57fd                	li	a5,-1
    8000213a:	04f50363          	beq	a0,a5,80002180 <allocproc+0x13a>
}
    8000213e:	8526                	mv	a0,s1
    80002140:	70a2                	ld	ra,40(sp)
    80002142:	7402                	ld	s0,32(sp)
    80002144:	64e2                	ld	s1,24(sp)
    80002146:	6942                	ld	s2,16(sp)
    80002148:	69a2                	ld	s3,8(sp)
    8000214a:	6a02                	ld	s4,0(sp)
    8000214c:	6145                	addi	sp,sp,48
    8000214e:	8082                	ret
    freeproc(p);
    80002150:	8526                	mv	a0,s1
    80002152:	00000097          	auipc	ra,0x0
    80002156:	e50080e7          	jalr	-432(ra) # 80001fa2 <freeproc>
    release(&p->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	b60080e7          	jalr	-1184(ra) # 80000cbc <release>
    return 0;
    80002164:	84ce                	mv	s1,s3
    80002166:	bfe1                	j	8000213e <allocproc+0xf8>
    freeproc(p);
    80002168:	8526                	mv	a0,s1
    8000216a:	00000097          	auipc	ra,0x0
    8000216e:	e38080e7          	jalr	-456(ra) # 80001fa2 <freeproc>
    release(&p->lock);
    80002172:	8526                	mv	a0,s1
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	b48080e7          	jalr	-1208(ra) # 80000cbc <release>
    return 0;
    8000217c:	84ce                	mv	s1,s3
    8000217e:	b7c1                	j	8000213e <allocproc+0xf8>
    freeproc(p);
    80002180:	8526                	mv	a0,s1
    80002182:	00000097          	auipc	ra,0x0
    80002186:	e20080e7          	jalr	-480(ra) # 80001fa2 <freeproc>
    release(&p->lock);  
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b30080e7          	jalr	-1232(ra) # 80000cbc <release>
    return 0;
    80002194:	4481                	li	s1,0
    80002196:	b765                	j	8000213e <allocproc+0xf8>

0000000080002198 <userinit>:
{
    80002198:	1101                	addi	sp,sp,-32
    8000219a:	ec06                	sd	ra,24(sp)
    8000219c:	e822                	sd	s0,16(sp)
    8000219e:	e426                	sd	s1,8(sp)
    800021a0:	1000                	addi	s0,sp,32
  p = allocproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	ea4080e7          	jalr	-348(ra) # 80002046 <allocproc>
    800021aa:	84aa                	mv	s1,a0
  initproc = p;
    800021ac:	00008797          	auipc	a5,0x8
    800021b0:	e6a7be23          	sd	a0,-388(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800021b4:	03400613          	li	a2,52
    800021b8:	00007597          	auipc	a1,0x7
    800021bc:	75858593          	addi	a1,a1,1880 # 80009910 <initcode>
    800021c0:	6128                	ld	a0,64(a0)
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	434080e7          	jalr	1076(ra) # 800015f6 <uvminit>
  p->sz = PGSIZE;
    800021ca:	6785                	lui	a5,0x1
    800021cc:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    800021ce:	2c84b703          	ld	a4,712(s1)
    800021d2:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    800021d6:	2c84b703          	ld	a4,712(s1)
    800021da:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800021dc:	4641                	li	a2,16
    800021de:	00007597          	auipc	a1,0x7
    800021e2:	0a258593          	addi	a1,a1,162 # 80009280 <digits+0x230>
    800021e6:	0d848513          	addi	a0,s1,216
    800021ea:	fffff097          	auipc	ra,0xfffff
    800021ee:	ee0080e7          	jalr	-288(ra) # 800010ca <safestrcpy>
  p->cwd = namei("/");
    800021f2:	00007517          	auipc	a0,0x7
    800021f6:	09e50513          	addi	a0,a0,158 # 80009290 <digits+0x240>
    800021fa:	00003097          	auipc	ra,0x3
    800021fe:	ed8080e7          	jalr	-296(ra) # 800050d2 <namei>
    80002202:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80002204:	4789                	li	a5,2
    80002206:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80002208:	478d                	li	a5,3
    8000220a:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	aac080e7          	jalr	-1364(ra) # 80000cbc <release>
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
    80002218:	28848513          	addi	a0,s1,648
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	aa0080e7          	jalr	-1376(ra) # 80000cbc <release>
}
    80002224:	60e2                	ld	ra,24(sp)
    80002226:	6442                	ld	s0,16(sp)
    80002228:	64a2                	ld	s1,8(sp)
    8000222a:	6105                	addi	sp,sp,32
    8000222c:	8082                	ret

000000008000222e <growproc>:
{
    8000222e:	1101                	addi	sp,sp,-32
    80002230:	ec06                	sd	ra,24(sp)
    80002232:	e822                	sd	s0,16(sp)
    80002234:	e426                	sd	s1,8(sp)
    80002236:	e04a                	sd	s2,0(sp)
    80002238:	1000                	addi	s0,sp,32
    8000223a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	adc080e7          	jalr	-1316(ra) # 80001d18 <myproc>
    80002244:	892a                	mv	s2,a0
  sz = p->sz;
    80002246:	7d0c                	ld	a1,56(a0)
    80002248:	0005861b          	sext.w	a2,a1
  if(n > 0){
    8000224c:	00904f63          	bgtz	s1,8000226a <growproc+0x3c>
  } else if(n < 0){
    80002250:	0204cc63          	bltz	s1,80002288 <growproc+0x5a>
  p->sz = sz;
    80002254:	1602                	slli	a2,a2,0x20
    80002256:	9201                	srli	a2,a2,0x20
    80002258:	02c93c23          	sd	a2,56(s2)
  return 0;
    8000225c:	4501                	li	a0,0
}
    8000225e:	60e2                	ld	ra,24(sp)
    80002260:	6442                	ld	s0,16(sp)
    80002262:	64a2                	ld	s1,8(sp)
    80002264:	6902                	ld	s2,0(sp)
    80002266:	6105                	addi	sp,sp,32
    80002268:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000226a:	9e25                	addw	a2,a2,s1
    8000226c:	1602                	slli	a2,a2,0x20
    8000226e:	9201                	srli	a2,a2,0x20
    80002270:	1582                	slli	a1,a1,0x20
    80002272:	9181                	srli	a1,a1,0x20
    80002274:	6128                	ld	a0,64(a0)
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	43a080e7          	jalr	1082(ra) # 800016b0 <uvmalloc>
    8000227e:	0005061b          	sext.w	a2,a0
    80002282:	fa69                	bnez	a2,80002254 <growproc+0x26>
      return -1;
    80002284:	557d                	li	a0,-1
    80002286:	bfe1                	j	8000225e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002288:	9e25                	addw	a2,a2,s1
    8000228a:	1602                	slli	a2,a2,0x20
    8000228c:	9201                	srli	a2,a2,0x20
    8000228e:	1582                	slli	a1,a1,0x20
    80002290:	9181                	srli	a1,a1,0x20
    80002292:	6128                	ld	a0,64(a0)
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	3d4080e7          	jalr	980(ra) # 80001668 <uvmdealloc>
    8000229c:	0005061b          	sext.w	a2,a0
    800022a0:	bf55                	j	80002254 <growproc+0x26>

00000000800022a2 <fork>:
{
    800022a2:	7139                	addi	sp,sp,-64
    800022a4:	fc06                	sd	ra,56(sp)
    800022a6:	f822                	sd	s0,48(sp)
    800022a8:	f426                	sd	s1,40(sp)
    800022aa:	f04a                	sd	s2,32(sp)
    800022ac:	ec4e                	sd	s3,24(sp)
    800022ae:	e852                	sd	s4,16(sp)
    800022b0:	e456                	sd	s5,8(sp)
    800022b2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800022b4:	00000097          	auipc	ra,0x0
    800022b8:	a64080e7          	jalr	-1436(ra) # 80001d18 <myproc>
    800022bc:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    800022be:	00000097          	auipc	ra,0x0
    800022c2:	a9a080e7          	jalr	-1382(ra) # 80001d58 <mykthread>
    800022c6:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	d7e080e7          	jalr	-642(ra) # 80002046 <allocproc>
    800022d0:	16050f63          	beqz	a0,8000244e <fork+0x1ac>
    800022d4:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800022d6:	0389b603          	ld	a2,56(s3)
    800022da:	612c                	ld	a1,64(a0)
    800022dc:	0409b503          	ld	a0,64(s3)
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	51c080e7          	jalr	1308(ra) # 800017fc <uvmcopy>
    800022e8:	06054763          	bltz	a0,80002356 <fork+0xb4>
  np->sz = p->sz;
    800022ec:	0389b783          	ld	a5,56(s3)
    800022f0:	02f93c23          	sd	a5,56(s2)
  acquire(&wait_lock);
    800022f4:	00011517          	auipc	a0,0x11
    800022f8:	3dc50513          	addi	a0,a0,988 # 800136d0 <wait_lock>
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	90c080e7          	jalr	-1780(ra) # 80000c08 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    80002304:	60b4                	ld	a3,64(s1)
    80002306:	87b6                	mv	a5,a3
    80002308:	2c893703          	ld	a4,712(s2)
    8000230c:	12068693          	addi	a3,a3,288
    80002310:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002314:	6788                	ld	a0,8(a5)
    80002316:	6b8c                	ld	a1,16(a5)
    80002318:	6f90                	ld	a2,24(a5)
    8000231a:	01073023          	sd	a6,0(a4)
    8000231e:	e708                	sd	a0,8(a4)
    80002320:	eb0c                	sd	a1,16(a4)
    80002322:	ef10                	sd	a2,24(a4)
    80002324:	02078793          	addi	a5,a5,32
    80002328:	02070713          	addi	a4,a4,32
    8000232c:	fed792e3          	bne	a5,a3,80002310 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  
    80002330:	2c893783          	ld	a5,712(s2)
    80002334:	0607b823          	sd	zero,112(a5)
  release(&wait_lock);////////////////////////////////////////////////////////////////check
    80002338:	00011517          	auipc	a0,0x11
    8000233c:	39850513          	addi	a0,a0,920 # 800136d0 <wait_lock>
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	97c080e7          	jalr	-1668(ra) # 80000cbc <release>
  for(i = 0; i < NOFILE; i++)
    80002348:	05098493          	addi	s1,s3,80
    8000234c:	05090a13          	addi	s4,s2,80
    80002350:	0d098a93          	addi	s5,s3,208
    80002354:	a00d                	j	80002376 <fork+0xd4>
    freeproc(np);
    80002356:	854a                	mv	a0,s2
    80002358:	00000097          	auipc	ra,0x0
    8000235c:	c4a080e7          	jalr	-950(ra) # 80001fa2 <freeproc>
    release(&np->lock);
    80002360:	854a                	mv	a0,s2
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	95a080e7          	jalr	-1702(ra) # 80000cbc <release>
    return -1;
    8000236a:	5a7d                	li	s4,-1
    8000236c:	a0f9                	j	8000243a <fork+0x198>
  for(i = 0; i < NOFILE; i++)
    8000236e:	04a1                	addi	s1,s1,8
    80002370:	0a21                	addi	s4,s4,8
    80002372:	01548b63          	beq	s1,s5,80002388 <fork+0xe6>
    if(p->ofile[i])
    80002376:	6088                	ld	a0,0(s1)
    80002378:	d97d                	beqz	a0,8000236e <fork+0xcc>
      np->ofile[i] = filedup(p->ofile[i]);
    8000237a:	00003097          	auipc	ra,0x3
    8000237e:	3f2080e7          	jalr	1010(ra) # 8000576c <filedup>
    80002382:	00aa3023          	sd	a0,0(s4)
    80002386:	b7e5                	j	8000236e <fork+0xcc>
  np->cwd = idup(p->cwd);
    80002388:	0d09b503          	ld	a0,208(s3)
    8000238c:	00002097          	auipc	ra,0x2
    80002390:	554080e7          	jalr	1364(ra) # 800048e0 <idup>
    80002394:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002398:	4641                	li	a2,16
    8000239a:	0d898593          	addi	a1,s3,216
    8000239e:	0d890513          	addi	a0,s2,216
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	d28080e7          	jalr	-728(ra) # 800010ca <safestrcpy>
  np->signal_mask = p->signal_mask;
    800023aa:	0ec9a783          	lw	a5,236(s3)
    800023ae:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    800023b2:	0f898693          	addi	a3,s3,248
    800023b6:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    800023ba:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    800023be:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    800023c2:	6290                	ld	a2,0(a3)
    800023c4:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    800023c6:	00f98633          	add	a2,s3,a5
    800023ca:	420c                	lw	a1,0(a2)
    800023cc:	00f90633          	add	a2,s2,a5
    800023d0:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    800023d2:	06a1                	addi	a3,a3,8
    800023d4:	0721                	addi	a4,a4,8
    800023d6:	0791                	addi	a5,a5,4
    800023d8:	fea795e3          	bne	a5,a0,800023c2 <fork+0x120>
  np-> pending_signals=0;
    800023dc:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    800023e0:	02492a03          	lw	s4,36(s2)
  release(&np->lock);
    800023e4:	854a                	mv	a0,s2
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	8d6080e7          	jalr	-1834(ra) # 80000cbc <release>
  acquire(&wait_lock);
    800023ee:	00011497          	auipc	s1,0x11
    800023f2:	2e248493          	addi	s1,s1,738 # 800136d0 <wait_lock>
    800023f6:	8526                	mv	a0,s1
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	810080e7          	jalr	-2032(ra) # 80000c08 <acquire>
  np->parent = p;
    80002400:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	8b6080e7          	jalr	-1866(ra) # 80000cbc <release>
  acquire(&np->lock);
    8000240e:	854a                	mv	a0,s2
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	7f8080e7          	jalr	2040(ra) # 80000c08 <acquire>
  np->state = RUNNABLE;   
    80002418:	4789                	li	a5,2
    8000241a:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    8000241e:	478d                	li	a5,3
    80002420:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    80002424:	28890513          	addi	a0,s2,648
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	894080e7          	jalr	-1900(ra) # 80000cbc <release>
  release(&np->lock);
    80002430:	854a                	mv	a0,s2
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	88a080e7          	jalr	-1910(ra) # 80000cbc <release>
}
    8000243a:	8552                	mv	a0,s4
    8000243c:	70e2                	ld	ra,56(sp)
    8000243e:	7442                	ld	s0,48(sp)
    80002440:	74a2                	ld	s1,40(sp)
    80002442:	7902                	ld	s2,32(sp)
    80002444:	69e2                	ld	s3,24(sp)
    80002446:	6a42                	ld	s4,16(sp)
    80002448:	6aa2                	ld	s5,8(sp)
    8000244a:	6121                	addi	sp,sp,64
    8000244c:	8082                	ret
    return -1;
    8000244e:	5a7d                	li	s4,-1
    80002450:	b7ed                	j	8000243a <fork+0x198>

0000000080002452 <scheduler>:
{
    80002452:	711d                	addi	sp,sp,-96
    80002454:	ec86                	sd	ra,88(sp)
    80002456:	e8a2                	sd	s0,80(sp)
    80002458:	e4a6                	sd	s1,72(sp)
    8000245a:	e0ca                	sd	s2,64(sp)
    8000245c:	fc4e                	sd	s3,56(sp)
    8000245e:	f852                	sd	s4,48(sp)
    80002460:	f456                	sd	s5,40(sp)
    80002462:	f05a                	sd	s6,32(sp)
    80002464:	ec5e                	sd	s7,24(sp)
    80002466:	e862                	sd	s8,16(sp)
    80002468:	e466                	sd	s9,8(sp)
    8000246a:	1080                	addi	s0,sp,96
    8000246c:	8792                	mv	a5,tp
  int id = r_tp();
    8000246e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002470:	00479713          	slli	a4,a5,0x4
    80002474:	00f706b3          	add	a3,a4,a5
    80002478:	00369613          	slli	a2,a3,0x3
    8000247c:	00011697          	auipc	a3,0x11
    80002480:	22468693          	addi	a3,a3,548 # 800136a0 <pid_lock>
    80002484:	96b2                	add	a3,a3,a2
    80002486:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    8000248a:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    8000248e:	00011717          	auipc	a4,0x11
    80002492:	26270713          	addi	a4,a4,610 # 800136f0 <cpus+0x8>
    80002496:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    8000249a:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000249c:	6a85                	lui	s5,0x1
    8000249e:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800024a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024aa:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800024ae:	00011917          	auipc	s2,0x11
    800024b2:	67a90913          	addi	s2,s2,1658 # 80013b28 <proc>
    800024b6:	a8a9                	j	80002510 <scheduler+0xbe>
          release(&t->lock);
    800024b8:	8526                	mv	a0,s1
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	802080e7          	jalr	-2046(ra) # 80000cbc <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800024c2:	0b848493          	addi	s1,s1,184
    800024c6:	03348e63          	beq	s1,s3,80002502 <scheduler+0xb0>
          acquire(&t->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	73c080e7          	jalr	1852(ra) # 80000c08 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {          
    800024d4:	4c9c                	lw	a5,24(s1)
    800024d6:	ff4791e3          	bne	a5,s4,800024b8 <scheduler+0x66>
    800024da:	58dc                	lw	a5,52(s1)
    800024dc:	fff1                	bnez	a5,800024b8 <scheduler+0x66>
            t->state = TRUNNING;
    800024de:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    800024e2:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    800024e6:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    800024ea:	04848593          	addi	a1,s1,72
    800024ee:	855e                	mv	a0,s7
    800024f0:	00001097          	auipc	ra,0x1
    800024f4:	dc0080e7          	jalr	-576(ra) # 800032b0 <swtch>
            c->proc = 0;
    800024f8:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    800024fc:	0c0b3423          	sd	zero,200(s6)
    80002500:	bf65                	j	800024b8 <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002502:	9956                	add	s2,s2,s5
    80002504:	00033797          	auipc	a5,0x33
    80002508:	82478793          	addi	a5,a5,-2012 # 80034d28 <tickslock>
    8000250c:	f8f90be3          	beq	s2,a5,800024a2 <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002510:	01892703          	lw	a4,24(s2)
    80002514:	4789                	li	a5,2
    80002516:	fef716e3          	bne	a4,a5,80002502 <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000251a:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {          
    8000251e:	4a0d                	li	s4,3
            t->state = TRUNNING;
    80002520:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002522:	015909b3          	add	s3,s2,s5
    80002526:	b755                	j	800024ca <scheduler+0x78>

0000000080002528 <sched>:
{
    80002528:	7179                	addi	sp,sp,-48
    8000252a:	f406                	sd	ra,40(sp)
    8000252c:	f022                	sd	s0,32(sp)
    8000252e:	ec26                	sd	s1,24(sp)
    80002530:	e84a                	sd	s2,16(sp)
    80002532:	e44e                	sd	s3,8(sp)
    80002534:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	7e2080e7          	jalr	2018(ra) # 80001d18 <myproc>
  struct kthread *t=mykthread();
    8000253e:	00000097          	auipc	ra,0x0
    80002542:	81a080e7          	jalr	-2022(ra) # 80001d58 <mykthread>
    80002546:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	646080e7          	jalr	1606(ra) # 80000b8e <holding>
    80002550:	c959                	beqz	a0,800025e6 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002552:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002554:	0007871b          	sext.w	a4,a5
    80002558:	00471793          	slli	a5,a4,0x4
    8000255c:	97ba                	add	a5,a5,a4
    8000255e:	078e                	slli	a5,a5,0x3
    80002560:	00011717          	auipc	a4,0x11
    80002564:	14070713          	addi	a4,a4,320 # 800136a0 <pid_lock>
    80002568:	97ba                	add	a5,a5,a4
    8000256a:	0c07a703          	lw	a4,192(a5)
    8000256e:	4785                	li	a5,1
    80002570:	08f71363          	bne	a4,a5,800025f6 <sched+0xce>
  if(t->state == TRUNNING){
    80002574:	4c98                	lw	a4,24(s1)
    80002576:	4791                	li	a5,4
    80002578:	08f70763          	beq	a4,a5,80002606 <sched+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000257c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002580:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002582:	ebd1                	bnez	a5,80002616 <sched+0xee>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002584:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002586:	00011917          	auipc	s2,0x11
    8000258a:	11a90913          	addi	s2,s2,282 # 800136a0 <pid_lock>
    8000258e:	0007871b          	sext.w	a4,a5
    80002592:	00471793          	slli	a5,a4,0x4
    80002596:	97ba                	add	a5,a5,a4
    80002598:	078e                	slli	a5,a5,0x3
    8000259a:	97ca                	add	a5,a5,s2
    8000259c:	0c47a983          	lw	s3,196(a5)
    800025a0:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    800025a2:	0007859b          	sext.w	a1,a5
    800025a6:	00459793          	slli	a5,a1,0x4
    800025aa:	97ae                	add	a5,a5,a1
    800025ac:	078e                	slli	a5,a5,0x3
    800025ae:	00011597          	auipc	a1,0x11
    800025b2:	14258593          	addi	a1,a1,322 # 800136f0 <cpus+0x8>
    800025b6:	95be                	add	a1,a1,a5
    800025b8:	04848513          	addi	a0,s1,72
    800025bc:	00001097          	auipc	ra,0x1
    800025c0:	cf4080e7          	jalr	-780(ra) # 800032b0 <swtch>
    800025c4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800025c6:	0007871b          	sext.w	a4,a5
    800025ca:	00471793          	slli	a5,a4,0x4
    800025ce:	97ba                	add	a5,a5,a4
    800025d0:	078e                	slli	a5,a5,0x3
    800025d2:	97ca                	add	a5,a5,s2
    800025d4:	0d37a223          	sw	s3,196(a5)
}
    800025d8:	70a2                	ld	ra,40(sp)
    800025da:	7402                	ld	s0,32(sp)
    800025dc:	64e2                	ld	s1,24(sp)
    800025de:	6942                	ld	s2,16(sp)
    800025e0:	69a2                	ld	s3,8(sp)
    800025e2:	6145                	addi	sp,sp,48
    800025e4:	8082                	ret
    panic("sched t->lock");
    800025e6:	00007517          	auipc	a0,0x7
    800025ea:	cb250513          	addi	a0,a0,-846 # 80009298 <digits+0x248>
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	f40080e7          	jalr	-192(ra) # 8000052e <panic>
    panic("sched locks");
    800025f6:	00007517          	auipc	a0,0x7
    800025fa:	cb250513          	addi	a0,a0,-846 # 800092a8 <digits+0x258>
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	f30080e7          	jalr	-208(ra) # 8000052e <panic>
    panic("sched running");
    80002606:	00007517          	auipc	a0,0x7
    8000260a:	cb250513          	addi	a0,a0,-846 # 800092b8 <digits+0x268>
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	f20080e7          	jalr	-224(ra) # 8000052e <panic>
    panic("sched interruptible");
    80002616:	00007517          	auipc	a0,0x7
    8000261a:	cb250513          	addi	a0,a0,-846 # 800092c8 <digits+0x278>
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	f10080e7          	jalr	-240(ra) # 8000052e <panic>

0000000080002626 <yield>:
{
    80002626:	1101                	addi	sp,sp,-32
    80002628:	ec06                	sd	ra,24(sp)
    8000262a:	e822                	sd	s0,16(sp)
    8000262c:	e426                	sd	s1,8(sp)
    8000262e:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	728080e7          	jalr	1832(ra) # 80001d58 <mykthread>
    80002638:	84aa                	mv	s1,a0
  acquire(&t->lock);
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	5ce080e7          	jalr	1486(ra) # 80000c08 <acquire>
  t->state = TRUNNABLE;
    80002642:	478d                	li	a5,3
    80002644:	cc9c                	sw	a5,24(s1)
  sched();
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	ee2080e7          	jalr	-286(ra) # 80002528 <sched>
  release(&t->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	66c080e7          	jalr	1644(ra) # 80000cbc <release>
}
    80002658:	60e2                	ld	ra,24(sp)
    8000265a:	6442                	ld	s0,16(sp)
    8000265c:	64a2                	ld	s1,8(sp)
    8000265e:	6105                	addi	sp,sp,32
    80002660:	8082                	ret

0000000080002662 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002662:	7179                	addi	sp,sp,-48
    80002664:	f406                	sd	ra,40(sp)
    80002666:	f022                	sd	s0,32(sp)
    80002668:	ec26                	sd	s1,24(sp)
    8000266a:	e84a                	sd	s2,16(sp)
    8000266c:	e44e                	sd	s3,8(sp)
    8000266e:	1800                	addi	s0,sp,48
    80002670:	89aa                	mv	s3,a0
    80002672:	892e                	mv	s2,a1
  struct kthread *t=mykthread();
    80002674:	fffff097          	auipc	ra,0xfffff
    80002678:	6e4080e7          	jalr	1764(ra) # 80001d58 <mykthread>
    8000267c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	58a080e7          	jalr	1418(ra) # 80000c08 <acquire>
  release(lk);
    80002686:	854a                	mv	a0,s2
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	634080e7          	jalr	1588(ra) # 80000cbc <release>

  // Go to sleep.
  t->chan = chan;
    80002690:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    80002694:	4789                	li	a5,2
    80002696:	cc9c                	sw	a5,24(s1)

  sched();
    80002698:	00000097          	auipc	ra,0x0
    8000269c:	e90080e7          	jalr	-368(ra) # 80002528 <sched>

  // Tidy up.
  t->chan = 0;
    800026a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    800026a4:	8526                	mv	a0,s1
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	616080e7          	jalr	1558(ra) # 80000cbc <release>

  acquire(lk);
    800026ae:	854a                	mv	a0,s2
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	558080e7          	jalr	1368(ra) # 80000c08 <acquire>
}
    800026b8:	70a2                	ld	ra,40(sp)
    800026ba:	7402                	ld	s0,32(sp)
    800026bc:	64e2                	ld	s1,24(sp)
    800026be:	6942                	ld	s2,16(sp)
    800026c0:	69a2                	ld	s3,8(sp)
    800026c2:	6145                	addi	sp,sp,48
    800026c4:	8082                	ret

00000000800026c6 <wait>:
{
    800026c6:	715d                	addi	sp,sp,-80
    800026c8:	e486                	sd	ra,72(sp)
    800026ca:	e0a2                	sd	s0,64(sp)
    800026cc:	fc26                	sd	s1,56(sp)
    800026ce:	f84a                	sd	s2,48(sp)
    800026d0:	f44e                	sd	s3,40(sp)
    800026d2:	f052                	sd	s4,32(sp)
    800026d4:	ec56                	sd	s5,24(sp)
    800026d6:	e85a                	sd	s6,16(sp)
    800026d8:	e45e                	sd	s7,8(sp)
    800026da:	0880                	addi	s0,sp,80
    800026dc:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800026de:	fffff097          	auipc	ra,0xfffff
    800026e2:	63a080e7          	jalr	1594(ra) # 80001d18 <myproc>
    800026e6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026e8:	00011517          	auipc	a0,0x11
    800026ec:	fe850513          	addi	a0,a0,-24 # 800136d0 <wait_lock>
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	518080e7          	jalr	1304(ra) # 80000c08 <acquire>
        if(np->state == ZOMBIE){
    800026f8:	4b0d                	li	s6,3
        havekids = 1;
    800026fa:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026fc:	6985                	lui	s3,0x1
    800026fe:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002702:	00032a17          	auipc	s4,0x32
    80002706:	626a0a13          	addi	s4,s4,1574 # 80034d28 <tickslock>
    havekids = 0;
    8000270a:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    8000270c:	00011497          	auipc	s1,0x11
    80002710:	41c48493          	addi	s1,s1,1052 # 80013b28 <proc>
    80002714:	a0b5                	j	80002780 <wait+0xba>
          pid = np->pid;
    80002716:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000271a:	000b8e63          	beqz	s7,80002736 <wait+0x70>
    8000271e:	4691                	li	a3,4
    80002720:	02048613          	addi	a2,s1,32
    80002724:	85de                	mv	a1,s7
    80002726:	04093503          	ld	a0,64(s2)
    8000272a:	fffff097          	auipc	ra,0xfffff
    8000272e:	1d6080e7          	jalr	470(ra) # 80001900 <copyout>
    80002732:	02054563          	bltz	a0,8000275c <wait+0x96>
          freeproc(np);
    80002736:	8526                	mv	a0,s1
    80002738:	00000097          	auipc	ra,0x0
    8000273c:	86a080e7          	jalr	-1942(ra) # 80001fa2 <freeproc>
          release(&np->lock);
    80002740:	8526                	mv	a0,s1
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	57a080e7          	jalr	1402(ra) # 80000cbc <release>
          release(&wait_lock);
    8000274a:	00011517          	auipc	a0,0x11
    8000274e:	f8650513          	addi	a0,a0,-122 # 800136d0 <wait_lock>
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	56a080e7          	jalr	1386(ra) # 80000cbc <release>
          return pid;
    8000275a:	a09d                	j	800027c0 <wait+0xfa>
            release(&np->lock);
    8000275c:	8526                	mv	a0,s1
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	55e080e7          	jalr	1374(ra) # 80000cbc <release>
            release(&wait_lock);
    80002766:	00011517          	auipc	a0,0x11
    8000276a:	f6a50513          	addi	a0,a0,-150 # 800136d0 <wait_lock>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	54e080e7          	jalr	1358(ra) # 80000cbc <release>
            return -1;
    80002776:	59fd                	li	s3,-1
    80002778:	a0a1                	j	800027c0 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    8000277a:	94ce                	add	s1,s1,s3
    8000277c:	03448463          	beq	s1,s4,800027a4 <wait+0xde>
      if(np->parent == p){
    80002780:	789c                	ld	a5,48(s1)
    80002782:	ff279ce3          	bne	a5,s2,8000277a <wait+0xb4>
        acquire(&np->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	480080e7          	jalr	1152(ra) # 80000c08 <acquire>
        if(np->state == ZOMBIE){
    80002790:	4c9c                	lw	a5,24(s1)
    80002792:	f96782e3          	beq	a5,s6,80002716 <wait+0x50>
        release(&np->lock);
    80002796:	8526                	mv	a0,s1
    80002798:	ffffe097          	auipc	ra,0xffffe
    8000279c:	524080e7          	jalr	1316(ra) # 80000cbc <release>
        havekids = 1;
    800027a0:	8756                	mv	a4,s5
    800027a2:	bfe1                	j	8000277a <wait+0xb4>
    if(!havekids || p->killed==1){
    800027a4:	c709                	beqz	a4,800027ae <wait+0xe8>
    800027a6:	01c92783          	lw	a5,28(s2)
    800027aa:	03579763          	bne	a5,s5,800027d8 <wait+0x112>
      release(&wait_lock);
    800027ae:	00011517          	auipc	a0,0x11
    800027b2:	f2250513          	addi	a0,a0,-222 # 800136d0 <wait_lock>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	506080e7          	jalr	1286(ra) # 80000cbc <release>
      return -1;
    800027be:	59fd                	li	s3,-1
}
    800027c0:	854e                	mv	a0,s3
    800027c2:	60a6                	ld	ra,72(sp)
    800027c4:	6406                	ld	s0,64(sp)
    800027c6:	74e2                	ld	s1,56(sp)
    800027c8:	7942                	ld	s2,48(sp)
    800027ca:	79a2                	ld	s3,40(sp)
    800027cc:	7a02                	ld	s4,32(sp)
    800027ce:	6ae2                	ld	s5,24(sp)
    800027d0:	6b42                	ld	s6,16(sp)
    800027d2:	6ba2                	ld	s7,8(sp)
    800027d4:	6161                	addi	sp,sp,80
    800027d6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800027d8:	00011597          	auipc	a1,0x11
    800027dc:	ef858593          	addi	a1,a1,-264 # 800136d0 <wait_lock>
    800027e0:	854a                	mv	a0,s2
    800027e2:	00000097          	auipc	ra,0x0
    800027e6:	e80080e7          	jalr	-384(ra) # 80002662 <sleep>
    havekids = 0;
    800027ea:	b705                	j	8000270a <wait+0x44>

00000000800027ec <wakeup>:
// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
// returns true if someone was waiting, else false
int
wakeup(void *chan)
{
    800027ec:	7159                	addi	sp,sp,-112
    800027ee:	f486                	sd	ra,104(sp)
    800027f0:	f0a2                	sd	s0,96(sp)
    800027f2:	eca6                	sd	s1,88(sp)
    800027f4:	e8ca                	sd	s2,80(sp)
    800027f6:	e4ce                	sd	s3,72(sp)
    800027f8:	e0d2                	sd	s4,64(sp)
    800027fa:	fc56                	sd	s5,56(sp)
    800027fc:	f85a                	sd	s6,48(sp)
    800027fe:	f45e                	sd	s7,40(sp)
    80002800:	f062                	sd	s8,32(sp)
    80002802:	ec66                	sd	s9,24(sp)
    80002804:	e86a                	sd	s10,16(sp)
    80002806:	e46e                	sd	s11,8(sp)
    80002808:	1880                	addi	s0,sp,112
    8000280a:	8baa                	mv	s7,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    8000280c:	fffff097          	auipc	ra,0xfffff
    80002810:	54c080e7          	jalr	1356(ra) # 80001d58 <mykthread>
    80002814:	8a2a                	mv	s4,a0
  int waited = 0;


  for(p = proc; p < &proc[NPROC]; p++) {
    80002816:	00011917          	auipc	s2,0x11
    8000281a:	59a90913          	addi	s2,s2,1434 # 80013db0 <proc+0x288>
    8000281e:	00032b17          	auipc	s6,0x32
    80002822:	792b0b13          	addi	s6,s6,1938 # 80034fb0 <bcache+0x270>
  int waited = 0;
    80002826:	4c01                	li	s8,0
    // acquire(&p->lock);
    if(p->state == RUNNABLE){
    80002828:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    8000282a:	4d0d                	li	s10,3
            waited = 1;
    8000282c:	4c85                	li	s9,1
  for(p = proc; p < &proc[NPROC]; p++) {
    8000282e:	6a85                	lui	s5,0x1
    80002830:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
    80002834:	a835                	j	80002870 <wakeup+0x84>
          }
          release(&t->lock);
    80002836:	8526                	mv	a0,s1
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	484080e7          	jalr	1156(ra) # 80000cbc <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002840:	0b848493          	addi	s1,s1,184
    80002844:	03b48363          	beq	s1,s11,8000286a <wakeup+0x7e>
        if(t != my_t){
    80002848:	fe9a0ce3          	beq	s4,s1,80002840 <wakeup+0x54>
          acquire(&t->lock);
    8000284c:	8526                	mv	a0,s1
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	3ba080e7          	jalr	954(ra) # 80000c08 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    80002856:	4c9c                	lw	a5,24(s1)
    80002858:	fd379fe3          	bne	a5,s3,80002836 <wakeup+0x4a>
    8000285c:	709c                	ld	a5,32(s1)
    8000285e:	fd779ce3          	bne	a5,s7,80002836 <wakeup+0x4a>
            t->state = TRUNNABLE;
    80002862:	01a4ac23          	sw	s10,24(s1)
            waited = 1;
    80002866:	8c66                	mv	s8,s9
    80002868:	b7f9                	j	80002836 <wakeup+0x4a>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000286a:	9956                	add	s2,s2,s5
    8000286c:	012b0a63          	beq	s6,s2,80002880 <wakeup+0x94>
    if(p->state == RUNNABLE){
    80002870:	84ca                	mv	s1,s2
    80002872:	d9092783          	lw	a5,-624(s2)
    80002876:	ff379ae3          	bne	a5,s3,8000286a <wakeup+0x7e>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000287a:	5c090d93          	addi	s11,s2,1472
    8000287e:	b7e9                	j	80002848 <wakeup+0x5c>
      }
    }
  }

  return waited;
}
    80002880:	8562                	mv	a0,s8
    80002882:	70a6                	ld	ra,104(sp)
    80002884:	7406                	ld	s0,96(sp)
    80002886:	64e6                	ld	s1,88(sp)
    80002888:	6946                	ld	s2,80(sp)
    8000288a:	69a6                	ld	s3,72(sp)
    8000288c:	6a06                	ld	s4,64(sp)
    8000288e:	7ae2                	ld	s5,56(sp)
    80002890:	7b42                	ld	s6,48(sp)
    80002892:	7ba2                	ld	s7,40(sp)
    80002894:	7c02                	ld	s8,32(sp)
    80002896:	6ce2                	ld	s9,24(sp)
    80002898:	6d42                	ld	s10,16(sp)
    8000289a:	6da2                	ld	s11,8(sp)
    8000289c:	6165                	addi	sp,sp,112
    8000289e:	8082                	ret

00000000800028a0 <reparent>:
{
    800028a0:	7139                	addi	sp,sp,-64
    800028a2:	fc06                	sd	ra,56(sp)
    800028a4:	f822                	sd	s0,48(sp)
    800028a6:	f426                	sd	s1,40(sp)
    800028a8:	f04a                	sd	s2,32(sp)
    800028aa:	ec4e                	sd	s3,24(sp)
    800028ac:	e852                	sd	s4,16(sp)
    800028ae:	e456                	sd	s5,8(sp)
    800028b0:	0080                	addi	s0,sp,64
    800028b2:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800028b4:	00011497          	auipc	s1,0x11
    800028b8:	27448493          	addi	s1,s1,628 # 80013b28 <proc>
      pp->parent = initproc;
    800028bc:	00007a97          	auipc	s5,0x7
    800028c0:	76ca8a93          	addi	s5,s5,1900 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800028c4:	6905                	lui	s2,0x1
    800028c6:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800028ca:	00032a17          	auipc	s4,0x32
    800028ce:	45ea0a13          	addi	s4,s4,1118 # 80034d28 <tickslock>
    800028d2:	a021                	j	800028da <reparent+0x3a>
    800028d4:	94ca                	add	s1,s1,s2
    800028d6:	01448d63          	beq	s1,s4,800028f0 <reparent+0x50>
    if(pp->parent == p){
    800028da:	789c                	ld	a5,48(s1)
    800028dc:	ff379ce3          	bne	a5,s3,800028d4 <reparent+0x34>
      pp->parent = initproc;
    800028e0:	000ab503          	ld	a0,0(s5)
    800028e4:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    800028e6:	00000097          	auipc	ra,0x0
    800028ea:	f06080e7          	jalr	-250(ra) # 800027ec <wakeup>
    800028ee:	b7dd                	j	800028d4 <reparent+0x34>
}
    800028f0:	70e2                	ld	ra,56(sp)
    800028f2:	7442                	ld	s0,48(sp)
    800028f4:	74a2                	ld	s1,40(sp)
    800028f6:	7902                	ld	s2,32(sp)
    800028f8:	69e2                	ld	s3,24(sp)
    800028fa:	6a42                	ld	s4,16(sp)
    800028fc:	6aa2                	ld	s5,8(sp)
    800028fe:	6121                	addi	sp,sp,64
    80002900:	8082                	ret

0000000080002902 <exit_proccess>:
{
    80002902:	7139                	addi	sp,sp,-64
    80002904:	fc06                	sd	ra,56(sp)
    80002906:	f822                	sd	s0,48(sp)
    80002908:	f426                	sd	s1,40(sp)
    8000290a:	f04a                	sd	s2,32(sp)
    8000290c:	ec4e                	sd	s3,24(sp)
    8000290e:	e852                	sd	s4,16(sp)
    80002910:	e456                	sd	s5,8(sp)
    80002912:	0080                	addi	s0,sp,64
    80002914:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	402080e7          	jalr	1026(ra) # 80001d18 <myproc>
    8000291e:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	438080e7          	jalr	1080(ra) # 80001d58 <mykthread>
    80002928:	8a2a                	mv	s4,a0
  if(p == initproc)
    8000292a:	00007797          	auipc	a5,0x7
    8000292e:	6fe7b783          	ld	a5,1790(a5) # 8000a028 <initproc>
    80002932:	05098493          	addi	s1,s3,80
    80002936:	0d098913          	addi	s2,s3,208
    8000293a:	03379363          	bne	a5,s3,80002960 <exit_proccess+0x5e>
    panic("init exiting");
    8000293e:	00007517          	auipc	a0,0x7
    80002942:	9a250513          	addi	a0,a0,-1630 # 800092e0 <digits+0x290>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	be8080e7          	jalr	-1048(ra) # 8000052e <panic>
      fileclose(f);
    8000294e:	00003097          	auipc	ra,0x3
    80002952:	e70080e7          	jalr	-400(ra) # 800057be <fileclose>
      p->ofile[fd] = 0;
    80002956:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000295a:	04a1                	addi	s1,s1,8
    8000295c:	01248563          	beq	s1,s2,80002966 <exit_proccess+0x64>
    if(p->ofile[fd]){
    80002960:	6088                	ld	a0,0(s1)
    80002962:	f575                	bnez	a0,8000294e <exit_proccess+0x4c>
    80002964:	bfdd                	j	8000295a <exit_proccess+0x58>
  begin_op();
    80002966:	00003097          	auipc	ra,0x3
    8000296a:	98c080e7          	jalr	-1652(ra) # 800052f2 <begin_op>
  iput(p->cwd);
    8000296e:	0d09b503          	ld	a0,208(s3)
    80002972:	00002097          	auipc	ra,0x2
    80002976:	166080e7          	jalr	358(ra) # 80004ad8 <iput>
  end_op();
    8000297a:	00003097          	auipc	ra,0x3
    8000297e:	9f8080e7          	jalr	-1544(ra) # 80005372 <end_op>
  p->cwd = 0;
    80002982:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    80002986:	00011497          	auipc	s1,0x11
    8000298a:	d4a48493          	addi	s1,s1,-694 # 800136d0 <wait_lock>
    8000298e:	8526                	mv	a0,s1
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	278080e7          	jalr	632(ra) # 80000c08 <acquire>
  reparent(p);
    80002998:	854e                	mv	a0,s3
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	f06080e7          	jalr	-250(ra) # 800028a0 <reparent>
  wakeup(p->parent);
    800029a2:	0309b503          	ld	a0,48(s3)
    800029a6:	00000097          	auipc	ra,0x0
    800029aa:	e46080e7          	jalr	-442(ra) # 800027ec <wakeup>
  acquire(&p->lock);
    800029ae:	854e                	mv	a0,s3
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	258080e7          	jalr	600(ra) # 80000c08 <acquire>
  p->xstate = status;
    800029b8:	0359a023          	sw	s5,32(s3)
  p->state = ZOMBIE;
    800029bc:	478d                	li	a5,3
    800029be:	00f9ac23          	sw	a5,24(s3)
  t->state=TZOMBIE;
    800029c2:	4795                	li	a5,5
    800029c4:	00fa2c23          	sw	a5,24(s4)
  release(&wait_lock);
    800029c8:	8526                	mv	a0,s1
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	2f2080e7          	jalr	754(ra) # 80000cbc <release>
  acquire(&t->lock);
    800029d2:	8552                	mv	a0,s4
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	234080e7          	jalr	564(ra) # 80000c08 <acquire>
  release(&p->lock);// ze po achav :) 
    800029dc:	854e                	mv	a0,s3
    800029de:	ffffe097          	auipc	ra,0xffffe
    800029e2:	2de080e7          	jalr	734(ra) # 80000cbc <release>
  sched();
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	b42080e7          	jalr	-1214(ra) # 80002528 <sched>
  panic("zombie exit");
    800029ee:	00007517          	auipc	a0,0x7
    800029f2:	90250513          	addi	a0,a0,-1790 # 800092f0 <digits+0x2a0>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b38080e7          	jalr	-1224(ra) # 8000052e <panic>

00000000800029fe <kthread_exit>:
kthread_exit(int status){
    800029fe:	7179                	addi	sp,sp,-48
    80002a00:	f406                	sd	ra,40(sp)
    80002a02:	f022                	sd	s0,32(sp)
    80002a04:	ec26                	sd	s1,24(sp)
    80002a06:	e84a                	sd	s2,16(sp)
    80002a08:	e44e                	sd	s3,8(sp)
    80002a0a:	e052                	sd	s4,0(sp)
    80002a0c:	1800                	addi	s0,sp,48
    80002a0e:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	308080e7          	jalr	776(ra) # 80001d18 <myproc>
    80002a18:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	33e080e7          	jalr	830(ra) # 80001d58 <mykthread>
    80002a22:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002a24:	854a                	mv	a0,s2
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	1e2080e7          	jalr	482(ra) # 80000c08 <acquire>
  p->active_threads--;
    80002a2e:	02892783          	lw	a5,40(s2)
    80002a32:	37fd                	addiw	a5,a5,-1
    80002a34:	00078a1b          	sext.w	s4,a5
    80002a38:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    80002a3c:	854a                	mv	a0,s2
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	27e080e7          	jalr	638(ra) # 80000cbc <release>
  acquire(&t->lock);
    80002a46:	8526                	mv	a0,s1
    80002a48:	ffffe097          	auipc	ra,0xffffe
    80002a4c:	1c0080e7          	jalr	448(ra) # 80000c08 <acquire>
  t->xstate = status;
    80002a50:	0334a623          	sw	s3,44(s1)
  t->state  = TZOMBIE;
    80002a54:	4795                	li	a5,5
    80002a56:	cc9c                	sw	a5,24(s1)
  release(&t->lock);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	262080e7          	jalr	610(ra) # 80000cbc <release>
  wakeup(t);
    80002a62:	8526                	mv	a0,s1
    80002a64:	00000097          	auipc	ra,0x0
    80002a68:	d88080e7          	jalr	-632(ra) # 800027ec <wakeup>
  if(curr_active_threads==0){
    80002a6c:	000a1763          	bnez	s4,80002a7a <kthread_exit+0x7c>
    exit_proccess(status);
    80002a70:	854e                	mv	a0,s3
    80002a72:	00000097          	auipc	ra,0x0
    80002a76:	e90080e7          	jalr	-368(ra) # 80002902 <exit_proccess>
    acquire(&t->lock);
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	18c080e7          	jalr	396(ra) # 80000c08 <acquire>
    sched();
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	aa4080e7          	jalr	-1372(ra) # 80002528 <sched>
    panic("zombie thread exit");
    80002a8c:	00007517          	auipc	a0,0x7
    80002a90:	87450513          	addi	a0,a0,-1932 # 80009300 <digits+0x2b0>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	a9a080e7          	jalr	-1382(ra) # 8000052e <panic>

0000000080002a9c <exit>:
exit(int status){
    80002a9c:	7139                	addi	sp,sp,-64
    80002a9e:	fc06                	sd	ra,56(sp)
    80002aa0:	f822                	sd	s0,48(sp)
    80002aa2:	f426                	sd	s1,40(sp)
    80002aa4:	f04a                	sd	s2,32(sp)
    80002aa6:	ec4e                	sd	s3,24(sp)
    80002aa8:	e852                	sd	s4,16(sp)
    80002aaa:	e456                	sd	s5,8(sp)
    80002aac:	e05a                	sd	s6,0(sp)
    80002aae:	0080                	addi	s0,sp,64
    80002ab0:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	266080e7          	jalr	614(ra) # 80001d18 <myproc>
    80002aba:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	29c080e7          	jalr	668(ra) # 80001d58 <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ac4:	28890493          	addi	s1,s2,648
    80002ac8:	6505                	lui	a0,0x1
    80002aca:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80002ace:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002ad0:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002ad2:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002ad4:	4b0d                	li	s6,3
    80002ad6:	a811                	j	80002aea <exit+0x4e>
    release(&t->lock);
    80002ad8:	8526                	mv	a0,s1
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	1e2080e7          	jalr	482(ra) # 80000cbc <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ae2:	0b848493          	addi	s1,s1,184
    80002ae6:	00990f63          	beq	s2,s1,80002b04 <exit+0x68>
    acquire(&t->lock);
    80002aea:	8526                	mv	a0,s1
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	11c080e7          	jalr	284(ra) # 80000c08 <acquire>
    t->killed = 1;
    80002af4:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002af8:	4c9c                	lw	a5,24(s1)
    80002afa:	fd379fe3          	bne	a5,s3,80002ad8 <exit+0x3c>
      t->state = TRUNNABLE;
    80002afe:	0164ac23          	sw	s6,24(s1)
    80002b02:	bfd9                	j	80002ad8 <exit+0x3c>
  kthread_exit(status);
    80002b04:	8556                	mv	a0,s5
    80002b06:	00000097          	auipc	ra,0x0
    80002b0a:	ef8080e7          	jalr	-264(ra) # 800029fe <kthread_exit>

0000000080002b0e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	e44e                	sd	s3,8(sp)
    80002b1a:	e052                	sd	s4,0(sp)
    80002b1c:	1800                	addi	s0,sp,48
    80002b1e:	84aa                	mv	s1,a0
    80002b20:	892e                	mv	s2,a1
    80002b22:	89b2                	mv	s3,a2
    80002b24:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	1f2080e7          	jalr	498(ra) # 80001d18 <myproc>
  if(user_dst){
    80002b2e:	c08d                	beqz	s1,80002b50 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002b30:	86d2                	mv	a3,s4
    80002b32:	864e                	mv	a2,s3
    80002b34:	85ca                	mv	a1,s2
    80002b36:	6128                	ld	a0,64(a0)
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	dc8080e7          	jalr	-568(ra) # 80001900 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002b40:	70a2                	ld	ra,40(sp)
    80002b42:	7402                	ld	s0,32(sp)
    80002b44:	64e2                	ld	s1,24(sp)
    80002b46:	6942                	ld	s2,16(sp)
    80002b48:	69a2                	ld	s3,8(sp)
    80002b4a:	6a02                	ld	s4,0(sp)
    80002b4c:	6145                	addi	sp,sp,48
    80002b4e:	8082                	ret
    memmove((char *)dst, src, len);
    80002b50:	000a061b          	sext.w	a2,s4
    80002b54:	85ce                	mv	a1,s3
    80002b56:	854a                	mv	a0,s2
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	47c080e7          	jalr	1148(ra) # 80000fd4 <memmove>
    return 0;
    80002b60:	8526                	mv	a0,s1
    80002b62:	bff9                	j	80002b40 <either_copyout+0x32>

0000000080002b64 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002b64:	7179                	addi	sp,sp,-48
    80002b66:	f406                	sd	ra,40(sp)
    80002b68:	f022                	sd	s0,32(sp)
    80002b6a:	ec26                	sd	s1,24(sp)
    80002b6c:	e84a                	sd	s2,16(sp)
    80002b6e:	e44e                	sd	s3,8(sp)
    80002b70:	e052                	sd	s4,0(sp)
    80002b72:	1800                	addi	s0,sp,48
    80002b74:	892a                	mv	s2,a0
    80002b76:	84ae                	mv	s1,a1
    80002b78:	89b2                	mv	s3,a2
    80002b7a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	19c080e7          	jalr	412(ra) # 80001d18 <myproc>
  if(user_src){
    80002b84:	c08d                	beqz	s1,80002ba6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002b86:	86d2                	mv	a3,s4
    80002b88:	864e                	mv	a2,s3
    80002b8a:	85ca                	mv	a1,s2
    80002b8c:	6128                	ld	a0,64(a0)
    80002b8e:	fffff097          	auipc	ra,0xfffff
    80002b92:	dfe080e7          	jalr	-514(ra) # 8000198c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002b96:	70a2                	ld	ra,40(sp)
    80002b98:	7402                	ld	s0,32(sp)
    80002b9a:	64e2                	ld	s1,24(sp)
    80002b9c:	6942                	ld	s2,16(sp)
    80002b9e:	69a2                	ld	s3,8(sp)
    80002ba0:	6a02                	ld	s4,0(sp)
    80002ba2:	6145                	addi	sp,sp,48
    80002ba4:	8082                	ret
    memmove(dst, (char*)src, len);
    80002ba6:	000a061b          	sext.w	a2,s4
    80002baa:	85ce                	mv	a1,s3
    80002bac:	854a                	mv	a0,s2
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	426080e7          	jalr	1062(ra) # 80000fd4 <memmove>
    return 0;
    80002bb6:	8526                	mv	a0,s1
    80002bb8:	bff9                	j	80002b96 <either_copyin+0x32>

0000000080002bba <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002bba:	715d                	addi	sp,sp,-80
    80002bbc:	e486                	sd	ra,72(sp)
    80002bbe:	e0a2                	sd	s0,64(sp)
    80002bc0:	fc26                	sd	s1,56(sp)
    80002bc2:	f84a                	sd	s2,48(sp)
    80002bc4:	f44e                	sd	s3,40(sp)
    80002bc6:	f052                	sd	s4,32(sp)
    80002bc8:	ec56                	sd	s5,24(sp)
    80002bca:	e85a                	sd	s6,16(sp)
    80002bcc:	e45e                	sd	s7,8(sp)
    80002bce:	e062                	sd	s8,0(sp)
    80002bd0:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002bd2:	00006517          	auipc	a0,0x6
    80002bd6:	57e50513          	addi	a0,a0,1406 # 80009150 <digits+0x100>
    80002bda:	ffffe097          	auipc	ra,0xffffe
    80002bde:	99e080e7          	jalr	-1634(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002be2:	00011497          	auipc	s1,0x11
    80002be6:	01e48493          	addi	s1,s1,30 # 80013c00 <proc+0xd8>
    80002bea:	00032997          	auipc	s3,0x32
    80002bee:	21698993          	addi	s3,s3,534 # 80034e00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002bf2:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002bf4:	00006a17          	auipc	s4,0x6
    80002bf8:	724a0a13          	addi	s4,s4,1828 # 80009318 <digits+0x2c8>
    printf("%d %s %s", p->pid, state, p->name);
    80002bfc:	00006b17          	auipc	s6,0x6
    80002c00:	724b0b13          	addi	s6,s6,1828 # 80009320 <digits+0x2d0>
    printf("\n");
    80002c04:	00006a97          	auipc	s5,0x6
    80002c08:	54ca8a93          	addi	s5,s5,1356 # 80009150 <digits+0x100>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c0c:	00006c17          	auipc	s8,0x6
    80002c10:	73cc0c13          	addi	s8,s8,1852 # 80009348 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c14:	6905                	lui	s2,0x1
    80002c16:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002c1a:	a005                	j	80002c3a <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002c1c:	f4c6a583          	lw	a1,-180(a3)
    80002c20:	855a                	mv	a0,s6
    80002c22:	ffffe097          	auipc	ra,0xffffe
    80002c26:	956080e7          	jalr	-1706(ra) # 80000578 <printf>
    printf("\n");
    80002c2a:	8556                	mv	a0,s5
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	94c080e7          	jalr	-1716(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c34:	94ca                	add	s1,s1,s2
    80002c36:	03348263          	beq	s1,s3,80002c5a <procdump+0xa0>
    if(p->state == UNUSED)
    80002c3a:	86a6                	mv	a3,s1
    80002c3c:	f404a783          	lw	a5,-192(s1)
    80002c40:	dbf5                	beqz	a5,80002c34 <procdump+0x7a>
      state = "???";
    80002c42:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002c44:	fcfbece3          	bltu	s7,a5,80002c1c <procdump+0x62>
    80002c48:	02079713          	slli	a4,a5,0x20
    80002c4c:	01d75793          	srli	a5,a4,0x1d
    80002c50:	97e2                	add	a5,a5,s8
    80002c52:	6390                	ld	a2,0(a5)
    80002c54:	f661                	bnez	a2,80002c1c <procdump+0x62>
      state = "???";
    80002c56:	8652                	mv	a2,s4
    80002c58:	b7d1                	j	80002c1c <procdump+0x62>
  }
}
    80002c5a:	60a6                	ld	ra,72(sp)
    80002c5c:	6406                	ld	s0,64(sp)
    80002c5e:	74e2                	ld	s1,56(sp)
    80002c60:	7942                	ld	s2,48(sp)
    80002c62:	79a2                	ld	s3,40(sp)
    80002c64:	7a02                	ld	s4,32(sp)
    80002c66:	6ae2                	ld	s5,24(sp)
    80002c68:	6b42                	ld	s6,16(sp)
    80002c6a:	6ba2                	ld	s7,8(sp)
    80002c6c:	6c02                	ld	s8,0(sp)
    80002c6e:	6161                	addi	sp,sp,80
    80002c70:	8082                	ret

0000000080002c72 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002c72:	1141                	addi	sp,sp,-16
    80002c74:	e422                	sd	s0,8(sp)
    80002c76:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002c78:	000207b7          	lui	a5,0x20
    80002c7c:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c80:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002c82:	00153513          	seqz	a0,a0
    80002c86:	6422                	ld	s0,8(sp)
    80002c88:	0141                	addi	sp,sp,16
    80002c8a:	8082                	ret

0000000080002c8c <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002c8c:	7179                	addi	sp,sp,-48
    80002c8e:	f406                	sd	ra,40(sp)
    80002c90:	f022                	sd	s0,32(sp)
    80002c92:	ec26                	sd	s1,24(sp)
    80002c94:	e84a                	sd	s2,16(sp)
    80002c96:	e44e                	sd	s3,8(sp)
    80002c98:	1800                	addi	s0,sp,48
    80002c9a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	07c080e7          	jalr	124(ra) # 80001d18 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002ca4:	000207b7          	lui	a5,0x20
    80002ca8:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002cac:	00f977b3          	and	a5,s2,a5
    return -1;
    80002cb0:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002cb2:	ef99                	bnez	a5,80002cd0 <sigprocmask+0x44>
    80002cb4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002cb6:	ffffe097          	auipc	ra,0xffffe
    80002cba:	f52080e7          	jalr	-174(ra) # 80000c08 <acquire>
  int old_procmask = p->signal_mask;
    80002cbe:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002cc2:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002cc6:	8526                	mv	a0,s1
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	ff4080e7          	jalr	-12(ra) # 80000cbc <release>
  
  return old_procmask;
}
    80002cd0:	854e                	mv	a0,s3
    80002cd2:	70a2                	ld	ra,40(sp)
    80002cd4:	7402                	ld	s0,32(sp)
    80002cd6:	64e2                	ld	s1,24(sp)
    80002cd8:	6942                	ld	s2,16(sp)
    80002cda:	69a2                	ld	s3,8(sp)
    80002cdc:	6145                	addi	sp,sp,48
    80002cde:	8082                	ret

0000000080002ce0 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002ce0:	0005079b          	sext.w	a5,a0
    80002ce4:	477d                	li	a4,31
    80002ce6:	0cf76a63          	bltu	a4,a5,80002dba <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002cea:	7139                	addi	sp,sp,-64
    80002cec:	fc06                	sd	ra,56(sp)
    80002cee:	f822                	sd	s0,48(sp)
    80002cf0:	f426                	sd	s1,40(sp)
    80002cf2:	f04a                	sd	s2,32(sp)
    80002cf4:	ec4e                	sd	s3,24(sp)
    80002cf6:	e852                	sd	s4,16(sp)
    80002cf8:	0080                	addi	s0,sp,64
    80002cfa:	84aa                	mv	s1,a0
    80002cfc:	89ae                	mv	s3,a1
    80002cfe:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002d00:	37dd                	addiw	a5,a5,-9
    80002d02:	9bdd                	andi	a5,a5,-9
    80002d04:	2781                	sext.w	a5,a5
    80002d06:	cfc5                	beqz	a5,80002dbe <sigaction+0xde>
    80002d08:	cdcd                	beqz	a1,80002dc2 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	00e080e7          	jalr	14(ra) # 80001d18 <myproc>
    80002d12:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002d14:	4691                	li	a3,4
    80002d16:	00898613          	addi	a2,s3,8
    80002d1a:	fcc40593          	addi	a1,s0,-52
    80002d1e:	6128                	ld	a0,64(a0)
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	c6c080e7          	jalr	-916(ra) # 8000198c <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002d28:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002d2c:	000207b7          	lui	a5,0x20
    80002d30:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002d34:	8ff9                	and	a5,a5,a4
    80002d36:	ebc1                	bnez	a5,80002dc6 <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002d38:	854a                	mv	a0,s2
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	ece080e7          	jalr	-306(ra) # 80000c08 <acquire>

  if(oldact!=0){
    80002d42:	020a0b63          	beqz	s4,80002d78 <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002d46:	01f48613          	addi	a2,s1,31
    80002d4a:	060e                	slli	a2,a2,0x3
    80002d4c:	46a1                	li	a3,8
    80002d4e:	964a                	add	a2,a2,s2
    80002d50:	85d2                	mv	a1,s4
    80002d52:	04093503          	ld	a0,64(s2)
    80002d56:	fffff097          	auipc	ra,0xfffff
    80002d5a:	baa080e7          	jalr	-1110(ra) # 80001900 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002d5e:	07e48613          	addi	a2,s1,126
    80002d62:	060a                	slli	a2,a2,0x2
    80002d64:	4691                	li	a3,4
    80002d66:	964a                	add	a2,a2,s2
    80002d68:	008a0593          	addi	a1,s4,8
    80002d6c:	04093503          	ld	a0,64(s2)
    80002d70:	fffff097          	auipc	ra,0xfffff
    80002d74:	b90080e7          	jalr	-1136(ra) # 80001900 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002d78:	07c48793          	addi	a5,s1,124
    80002d7c:	078a                	slli	a5,a5,0x2
    80002d7e:	97ca                	add	a5,a5,s2
    80002d80:	fcc42703          	lw	a4,-52(s0)
    80002d84:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002d86:	04fd                	addi	s1,s1,31
    80002d88:	048e                	slli	s1,s1,0x3
    80002d8a:	46a1                	li	a3,8
    80002d8c:	864e                	mv	a2,s3
    80002d8e:	009905b3          	add	a1,s2,s1
    80002d92:	04093503          	ld	a0,64(s2)
    80002d96:	fffff097          	auipc	ra,0xfffff
    80002d9a:	bf6080e7          	jalr	-1034(ra) # 8000198c <copyin>

  release(&p->lock);
    80002d9e:	854a                	mv	a0,s2
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	f1c080e7          	jalr	-228(ra) # 80000cbc <release>



  return 0;
    80002da8:	4501                	li	a0,0
}
    80002daa:	70e2                	ld	ra,56(sp)
    80002dac:	7442                	ld	s0,48(sp)
    80002dae:	74a2                	ld	s1,40(sp)
    80002db0:	7902                	ld	s2,32(sp)
    80002db2:	69e2                	ld	s3,24(sp)
    80002db4:	6a42                	ld	s4,16(sp)
    80002db6:	6121                	addi	sp,sp,64
    80002db8:	8082                	ret
    return -1;
    80002dba:	557d                	li	a0,-1
}
    80002dbc:	8082                	ret
    return -1;
    80002dbe:	557d                	li	a0,-1
    80002dc0:	b7ed                	j	80002daa <sigaction+0xca>
    80002dc2:	557d                	li	a0,-1
    80002dc4:	b7dd                	j	80002daa <sigaction+0xca>
    return -1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	b7cd                	j	80002daa <sigaction+0xca>

0000000080002dca <sigret>:

void 
sigret(void){
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	e04a                	sd	s2,0(sp)
    80002dd4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	f42080e7          	jalr	-190(ra) # 80001d18 <myproc>
    80002dde:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	f78080e7          	jalr	-136(ra) # 80001d58 <mykthread>
    80002de8:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002dea:	12000693          	li	a3,288
    80002dee:	2784b603          	ld	a2,632(s1)
    80002df2:	612c                	ld	a1,64(a0)
    80002df4:	60a8                	ld	a0,64(s1)
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	b96080e7          	jalr	-1130(ra) # 8000198c <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002dfe:	8526                	mv	a0,s1
    80002e00:	ffffe097          	auipc	ra,0xffffe
    80002e04:	e08080e7          	jalr	-504(ra) # 80000c08 <acquire>

  t->trapframe->sp += sizeof(struct trapframe);
    80002e08:	04093703          	ld	a4,64(s2)
    80002e0c:	7b1c                	ld	a5,48(a4)
    80002e0e:	12078793          	addi	a5,a5,288
    80002e12:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002e14:	0f04a783          	lw	a5,240(s1)
    80002e18:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002e1c:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002e20:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002e24:	8526                	mv	a0,s1
    80002e26:	ffffe097          	auipc	ra,0xffffe
    80002e2a:	e96080e7          	jalr	-362(ra) # 80000cbc <release>
}
    80002e2e:	60e2                	ld	ra,24(sp)
    80002e30:	6442                	ld	s0,16(sp)
    80002e32:	64a2                	ld	s1,8(sp)
    80002e34:	6902                	ld	s2,0(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002e3a:	1141                	addi	sp,sp,-16
    80002e3c:	e422                	sd	s0,8(sp)
    80002e3e:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002e40:	0e852703          	lw	a4,232(a0)
    80002e44:	4785                	li	a5,1
    80002e46:	00b795bb          	sllw	a1,a5,a1
    80002e4a:	00b777b3          	and	a5,a4,a1
    80002e4e:	2781                	sext.w	a5,a5
    80002e50:	e781                	bnez	a5,80002e58 <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002e52:	8db9                	xor	a1,a1,a4
    80002e54:	0eb52423          	sw	a1,232(a0)
}
    80002e58:	6422                	ld	s0,8(sp)
    80002e5a:	0141                	addi	sp,sp,16
    80002e5c:	8082                	ret

0000000080002e5e <kill>:
{
    80002e5e:	7139                	addi	sp,sp,-64
    80002e60:	fc06                	sd	ra,56(sp)
    80002e62:	f822                	sd	s0,48(sp)
    80002e64:	f426                	sd	s1,40(sp)
    80002e66:	f04a                	sd	s2,32(sp)
    80002e68:	ec4e                	sd	s3,24(sp)
    80002e6a:	e852                	sd	s4,16(sp)
    80002e6c:	e456                	sd	s5,8(sp)
    80002e6e:	0080                	addi	s0,sp,64
    80002e70:	892a                	mv	s2,a0
    80002e72:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002e74:	00011497          	auipc	s1,0x11
    80002e78:	cb448493          	addi	s1,s1,-844 # 80013b28 <proc>
    80002e7c:	6985                	lui	s3,0x1
    80002e7e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002e82:	00032a17          	auipc	s4,0x32
    80002e86:	ea6a0a13          	addi	s4,s4,-346 # 80034d28 <tickslock>
    acquire(&p->lock);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	ffffe097          	auipc	ra,0xffffe
    80002e90:	d7c080e7          	jalr	-644(ra) # 80000c08 <acquire>
    if(p->pid == pid){
    80002e94:	50dc                	lw	a5,36(s1)
    80002e96:	01278c63          	beq	a5,s2,80002eae <kill+0x50>
    release(&p->lock);
    80002e9a:	8526                	mv	a0,s1
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	e20080e7          	jalr	-480(ra) # 80000cbc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002ea4:	94ce                	add	s1,s1,s3
    80002ea6:	ff4492e3          	bne	s1,s4,80002e8a <kill+0x2c>
  return -1;
    80002eaa:	557d                	li	a0,-1
    80002eac:	a051                	j	80002f30 <kill+0xd2>
      if(p->state != RUNNABLE){
    80002eae:	4c98                	lw	a4,24(s1)
    80002eb0:	4789                	li	a5,2
    80002eb2:	06f71963          	bne	a4,a5,80002f24 <kill+0xc6>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002eb6:	01ea8793          	addi	a5,s5,30
    80002eba:	078e                	slli	a5,a5,0x3
    80002ebc:	97a6                	add	a5,a5,s1
    80002ebe:	6798                	ld	a4,8(a5)
    80002ec0:	4785                	li	a5,1
    80002ec2:	08f70063          	beq	a4,a5,80002f42 <kill+0xe4>
      turn_on_bit(p,signum);
    80002ec6:	85d6                	mv	a1,s5
    80002ec8:	8526                	mv	a0,s1
    80002eca:	00000097          	auipc	ra,0x0
    80002ece:	f70080e7          	jalr	-144(ra) # 80002e3a <turn_on_bit>
      release(&p->lock);
    80002ed2:	8526                	mv	a0,s1
    80002ed4:	ffffe097          	auipc	ra,0xffffe
    80002ed8:	de8080e7          	jalr	-536(ra) # 80000cbc <release>
      if(signum == SIGKILL){
    80002edc:	47a5                	li	a5,9
      return 0;
    80002ede:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002ee0:	04fa9863          	bne	s5,a5,80002f30 <kill+0xd2>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ee4:	28848913          	addi	s2,s1,648
    80002ee8:	6785                	lui	a5,0x1
    80002eea:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002eee:	94be                	add	s1,s1,a5
          if(t->state == TRUNNABLE){
    80002ef0:	498d                	li	s3,3
            if(t->state == TSLEEPING){
    80002ef2:	4a09                	li	s4,2
          if(t->state == TRUNNABLE){
    80002ef4:	01892783          	lw	a5,24(s2)
    80002ef8:	07378663          	beq	a5,s3,80002f64 <kill+0x106>
            acquire(&t->lock);
    80002efc:	854a                	mv	a0,s2
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	d0a080e7          	jalr	-758(ra) # 80000c08 <acquire>
            if(t->state == TSLEEPING){
    80002f06:	01892783          	lw	a5,24(s2)
    80002f0a:	05478363          	beq	a5,s4,80002f50 <kill+0xf2>
            release(&t->lock);
    80002f0e:	854a                	mv	a0,s2
    80002f10:	ffffe097          	auipc	ra,0xffffe
    80002f14:	dac080e7          	jalr	-596(ra) # 80000cbc <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002f18:	0b890913          	addi	s2,s2,184
    80002f1c:	fc991ce3          	bne	s2,s1,80002ef4 <kill+0x96>
      return 0;
    80002f20:	4501                	li	a0,0
    80002f22:	a039                	j	80002f30 <kill+0xd2>
        release(&p->lock);
    80002f24:	8526                	mv	a0,s1
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	d96080e7          	jalr	-618(ra) # 80000cbc <release>
        return -1;
    80002f2e:	557d                	li	a0,-1
}
    80002f30:	70e2                	ld	ra,56(sp)
    80002f32:	7442                	ld	s0,48(sp)
    80002f34:	74a2                	ld	s1,40(sp)
    80002f36:	7902                	ld	s2,32(sp)
    80002f38:	69e2                	ld	s3,24(sp)
    80002f3a:	6a42                	ld	s4,16(sp)
    80002f3c:	6aa2                	ld	s5,8(sp)
    80002f3e:	6121                	addi	sp,sp,64
    80002f40:	8082                	ret
        release(&p->lock);
    80002f42:	8526                	mv	a0,s1
    80002f44:	ffffe097          	auipc	ra,0xffffe
    80002f48:	d78080e7          	jalr	-648(ra) # 80000cbc <release>
        return 1;
    80002f4c:	4505                	li	a0,1
    80002f4e:	b7cd                	j	80002f30 <kill+0xd2>
              t->state = TRUNNABLE;
    80002f50:	478d                	li	a5,3
    80002f52:	00f92c23          	sw	a5,24(s2)
              release(&t->lock);
    80002f56:	854a                	mv	a0,s2
    80002f58:	ffffe097          	auipc	ra,0xffffe
    80002f5c:	d64080e7          	jalr	-668(ra) # 80000cbc <release>
      return 0;
    80002f60:	4501                	li	a0,0
              break;
    80002f62:	b7f9                	j	80002f30 <kill+0xd2>
      return 0;
    80002f64:	4501                	li	a0,0
    80002f66:	b7e9                	j	80002f30 <kill+0xd2>

0000000080002f68 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002f68:	1141                	addi	sp,sp,-16
    80002f6a:	e422                	sd	s0,8(sp)
    80002f6c:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002f6e:	0e852703          	lw	a4,232(a0)
    80002f72:	4785                	li	a5,1
    80002f74:	00b795bb          	sllw	a1,a5,a1
    80002f78:	00b777b3          	and	a5,a4,a1
    80002f7c:	2781                	sext.w	a5,a5
    80002f7e:	c781                	beqz	a5,80002f86 <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002f80:	8db9                	xor	a1,a1,a4
    80002f82:	0eb52423          	sw	a1,232(a0)
}
    80002f86:	6422                	ld	s0,8(sp)
    80002f88:	0141                	addi	sp,sp,16
    80002f8a:	8082                	ret

0000000080002f8c <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002f8c:	7139                	addi	sp,sp,-64
    80002f8e:	fc06                	sd	ra,56(sp)
    80002f90:	f822                	sd	s0,48(sp)
    80002f92:	f426                	sd	s1,40(sp)
    80002f94:	f04a                	sd	s2,32(sp)
    80002f96:	ec4e                	sd	s3,24(sp)
    80002f98:	e852                	sd	s4,16(sp)
    80002f9a:	e456                	sd	s5,8(sp)
    80002f9c:	e05a                	sd	s6,0(sp)
    80002f9e:	0080                	addi	s0,sp,64
    80002fa0:	8b2a                	mv	s6,a0
    80002fa2:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002fa4:	fffff097          	auipc	ra,0xfffff
    80002fa8:	d74080e7          	jalr	-652(ra) # 80001d18 <myproc>
    80002fac:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	daa080e7          	jalr	-598(ra) # 80001d58 <mykthread>
    80002fb6:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002fb8:	288a0493          	addi	s1,s4,648
    80002fbc:	6905                	lui	s2,0x1
    80002fbe:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002fc2:	9952                	add	s2,s2,s4
    80002fc4:	a861                	j	8000305c <kthread_create+0xd0>
  t->tid = 0;
    80002fc6:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002fca:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002fce:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002fd2:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002fd6:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	e8e080e7          	jalr	-370(ra) # 80001e6a <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    80002fe4:	0409b683          	ld	a3,64(s3)
    80002fe8:	87b6                	mv	a5,a3
    80002fea:	60b8                	ld	a4,64(s1)
    80002fec:	12068693          	addi	a3,a3,288
    80002ff0:	0007b803          	ld	a6,0(a5)
    80002ff4:	6788                	ld	a0,8(a5)
    80002ff6:	6b8c                	ld	a1,16(a5)
    80002ff8:	6f90                	ld	a2,24(a5)
    80002ffa:	01073023          	sd	a6,0(a4)
    80002ffe:	e708                	sd	a0,8(a4)
    80003000:	eb0c                	sd	a1,16(a4)
    80003002:	ef10                	sd	a2,24(a4)
    80003004:	02078793          	addi	a5,a5,32
    80003008:	02070713          	addi	a4,a4,32
    8000300c:	fed792e3          	bne	a5,a3,80002ff0 <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80003010:	60b8                	ld	a4,64(s1)
    80003012:	6785                	lui	a5,0x1
    80003014:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80003018:	9abe                	add	s5,s5,a5
    8000301a:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    8000301e:	60bc                	ld	a5,64(s1)
    80003020:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    80003024:	8526                	mv	a0,s1
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	c96080e7          	jalr	-874(ra) # 80000cbc <release>
          acquire(&p->lock);
    8000302e:	8552                	mv	a0,s4
    80003030:	ffffe097          	auipc	ra,0xffffe
    80003034:	bd8080e7          	jalr	-1064(ra) # 80000c08 <acquire>
          p->active_threads++;
    80003038:	028a2783          	lw	a5,40(s4)
    8000303c:	2785                	addiw	a5,a5,1
    8000303e:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80003042:	8552                	mv	a0,s4
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	c78080e7          	jalr	-904(ra) # 80000cbc <release>
          other_t->state = TRUNNABLE;
    8000304c:	478d                	li	a5,3
    8000304e:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80003050:	5888                	lw	a0,48(s1)
    80003052:	a02d                	j	8000307c <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80003054:	0b848493          	addi	s1,s1,184
    80003058:	02990163          	beq	s2,s1,8000307a <kthread_create+0xee>
    if(curr_t != other_t){
    8000305c:	fe998ce3          	beq	s3,s1,80003054 <kthread_create+0xc8>
      acquire(&other_t->lock);
    80003060:	8526                	mv	a0,s1
    80003062:	ffffe097          	auipc	ra,0xffffe
    80003066:	ba6080e7          	jalr	-1114(ra) # 80000c08 <acquire>
      if(other_t->state == TUNUSED){
    8000306a:	4c9c                	lw	a5,24(s1)
    8000306c:	dfa9                	beqz	a5,80002fc6 <kthread_create+0x3a>
      }
      release(&other_t->lock);
    8000306e:	8526                	mv	a0,s1
    80003070:	ffffe097          	auipc	ra,0xffffe
    80003074:	c4c080e7          	jalr	-948(ra) # 80000cbc <release>
    80003078:	bff1                	j	80003054 <kthread_create+0xc8>
    }
  }
  return -1;
    8000307a:	557d                	li	a0,-1
}
    8000307c:	70e2                	ld	ra,56(sp)
    8000307e:	7442                	ld	s0,48(sp)
    80003080:	74a2                	ld	s1,40(sp)
    80003082:	7902                	ld	s2,32(sp)
    80003084:	69e2                	ld	s3,24(sp)
    80003086:	6a42                	ld	s4,16(sp)
    80003088:	6aa2                	ld	s5,8(sp)
    8000308a:	6b02                	ld	s6,0(sp)
    8000308c:	6121                	addi	sp,sp,64
    8000308e:	8082                	ret

0000000080003090 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80003090:	715d                	addi	sp,sp,-80
    80003092:	e486                	sd	ra,72(sp)
    80003094:	e0a2                	sd	s0,64(sp)
    80003096:	fc26                	sd	s1,56(sp)
    80003098:	f84a                	sd	s2,48(sp)
    8000309a:	f44e                	sd	s3,40(sp)
    8000309c:	f052                	sd	s4,32(sp)
    8000309e:	ec56                	sd	s5,24(sp)
    800030a0:	e85a                	sd	s6,16(sp)
    800030a2:	e45e                	sd	s7,8(sp)
    800030a4:	0880                	addi	s0,sp,80
    800030a6:	8a2a                	mv	s4,a0
    800030a8:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    800030aa:	fffff097          	auipc	ra,0xfffff
    800030ae:	c6e080e7          	jalr	-914(ra) # 80001d18 <myproc>
    800030b2:	8aaa                	mv	s5,a0
  struct kthread *t = mykthread();
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	ca4080e7          	jalr	-860(ra) # 80001d58 <mykthread>



  if(thread_id == t->tid)
    800030bc:	591c                	lw	a5,48(a0)
    800030be:	17478a63          	beq	a5,s4,80003232 <kthread_join+0x1a2>
    800030c2:	89aa                	mv	s3,a0
    return -1;
  acquire(&wait_lock);
    800030c4:	00010517          	auipc	a0,0x10
    800030c8:	60c50513          	addi	a0,a0,1548 # 800136d0 <wait_lock>
    800030cc:	ffffe097          	auipc	ra,0xffffe
    800030d0:	b3c080e7          	jalr	-1220(ra) # 80000c08 <acquire>
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    800030d4:	288a8913          	addi	s2,s5,648
    800030d8:	6485                	lui	s1,0x1
    800030da:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    800030de:	94d6                	add	s1,s1,s5
    800030e0:	a039                	j	800030ee <kthread_join+0x5e>
    800030e2:	84ca                	mv	s1,s2
    800030e4:	a825                	j	8000311c <kthread_join+0x8c>
    800030e6:	0b890913          	addi	s2,s2,184
    800030ea:	02990363          	beq	s2,s1,80003110 <kthread_join+0x80>
    if(nt != t){
    800030ee:	ff298ce3          	beq	s3,s2,800030e6 <kthread_join+0x56>
      acquire(&nt->lock);
    800030f2:	854a                	mv	a0,s2
    800030f4:	ffffe097          	auipc	ra,0xffffe
    800030f8:	b14080e7          	jalr	-1260(ra) # 80000c08 <acquire>

      if(nt->tid == thread_id){
    800030fc:	03092783          	lw	a5,48(s2)
    80003100:	ff4781e3          	beq	a5,s4,800030e2 <kthread_join+0x52>
        //found target thread 
        goto found;
      }
      release(&nt->lock);
    80003104:	854a                	mv	a0,s2
    80003106:	ffffe097          	auipc	ra,0xffffe
    8000310a:	bb6080e7          	jalr	-1098(ra) # 80000cbc <release>
    8000310e:	bfe1                	j	800030e6 <kthread_join+0x56>
    }
  }

  if(nt->tid != thread_id){
    80003110:	6785                	lui	a5,0x1
    80003112:	97d6                	add	a5,a5,s5
    80003114:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    80003118:	09479c63          	bne	a5,s4,800031b0 <kthread_join+0x120>
    release(&wait_lock);
    return -1;
  }
  found:
  for(;;){
      if(nt->state==TZOMBIE){
    8000311c:	4c9c                	lw	a5,24(s1)
    8000311e:	4715                	li	a4,5
    80003120:	04e78163          	beq	a5,a4,80003162 <kthread_join+0xd2>
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003124:	00010b97          	auipc	s7,0x10
    80003128:	5acb8b93          	addi	s7,s7,1452 # 800136d0 <wait_lock>
      if(nt->state==TZOMBIE){
    8000312c:	4915                	li	s2,5
      else if(nt->state==TUNUSED){ // in case someone already free that thread
    8000312e:	cbd5                	beqz	a5,800031e2 <kthread_join+0x152>
    if(t->killed || nt->tid!=thread_id){
    80003130:	0289a783          	lw	a5,40(s3)
    80003134:	e3e5                	bnez	a5,80003214 <kthread_join+0x184>
    80003136:	589c                	lw	a5,48(s1)
    80003138:	0d479e63          	bne	a5,s4,80003214 <kthread_join+0x184>
    release(&nt->lock);
    8000313c:	8526                	mv	a0,s1
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	b7e080e7          	jalr	-1154(ra) # 80000cbc <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80003146:	85de                	mv	a1,s7
    80003148:	8526                	mv	a0,s1
    8000314a:	fffff097          	auipc	ra,0xfffff
    8000314e:	518080e7          	jalr	1304(ra) # 80002662 <sleep>
    acquire(&nt->lock);
    80003152:	8526                	mv	a0,s1
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	ab4080e7          	jalr	-1356(ra) # 80000c08 <acquire>
      if(nt->state==TZOMBIE){
    8000315c:	4c9c                	lw	a5,24(s1)
    8000315e:	fd2798e3          	bne	a5,s2,8000312e <kthread_join+0x9e>
        if(status != 0 && copyout(p->pagetable, (uint64)status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80003162:	000b0e63          	beqz	s6,8000317e <kthread_join+0xee>
    80003166:	4691                	li	a3,4
    80003168:	02c48613          	addi	a2,s1,44
    8000316c:	85da                	mv	a1,s6
    8000316e:	040ab503          	ld	a0,64(s5)
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	78e080e7          	jalr	1934(ra) # 80001900 <copyout>
    8000317a:	04054563          	bltz	a0,800031c4 <kthread_join+0x134>
  t->tid = 0;
    8000317e:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80003182:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80003186:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    8000318a:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    8000318e:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    80003192:	8526                	mv	a0,s1
    80003194:	ffffe097          	auipc	ra,0xffffe
    80003198:	b28080e7          	jalr	-1240(ra) # 80000cbc <release>
        release(&wait_lock);  //  successfull join     
    8000319c:	00010517          	auipc	a0,0x10
    800031a0:	53450513          	addi	a0,a0,1332 # 800136d0 <wait_lock>
    800031a4:	ffffe097          	auipc	ra,0xffffe
    800031a8:	b18080e7          	jalr	-1256(ra) # 80000cbc <release>
        return 0;
    800031ac:	4501                	li	a0,0
    800031ae:	a059                	j	80003234 <kthread_join+0x1a4>
    release(&wait_lock);
    800031b0:	00010517          	auipc	a0,0x10
    800031b4:	52050513          	addi	a0,a0,1312 # 800136d0 <wait_lock>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	b04080e7          	jalr	-1276(ra) # 80000cbc <release>
    return -1;
    800031c0:	557d                	li	a0,-1
    800031c2:	a88d                	j	80003234 <kthread_join+0x1a4>
           release(&nt->lock);
    800031c4:	8526                	mv	a0,s1
    800031c6:	ffffe097          	auipc	ra,0xffffe
    800031ca:	af6080e7          	jalr	-1290(ra) # 80000cbc <release>
           release(&wait_lock);
    800031ce:	00010517          	auipc	a0,0x10
    800031d2:	50250513          	addi	a0,a0,1282 # 800136d0 <wait_lock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ae6080e7          	jalr	-1306(ra) # 80000cbc <release>
           return -1;                   
    800031de:	557d                	li	a0,-1
    800031e0:	a891                	j	80003234 <kthread_join+0x1a4>
  t->tid = 0;
    800031e2:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    800031e6:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    800031ea:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    800031ee:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    800031f2:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    800031f6:	8526                	mv	a0,s1
    800031f8:	ffffe097          	auipc	ra,0xffffe
    800031fc:	ac4080e7          	jalr	-1340(ra) # 80000cbc <release>
        release(&wait_lock);  //  successfull join
    80003200:	00010517          	auipc	a0,0x10
    80003204:	4d050513          	addi	a0,a0,1232 # 800136d0 <wait_lock>
    80003208:	ffffe097          	auipc	ra,0xffffe
    8000320c:	ab4080e7          	jalr	-1356(ra) # 80000cbc <release>
        return 1; //thread already exited
    80003210:	4505                	li	a0,1
    80003212:	a00d                	j	80003234 <kthread_join+0x1a4>
      release(&nt->lock);
    80003214:	8526                	mv	a0,s1
    80003216:	ffffe097          	auipc	ra,0xffffe
    8000321a:	aa6080e7          	jalr	-1370(ra) # 80000cbc <release>
      release(&wait_lock);
    8000321e:	00010517          	auipc	a0,0x10
    80003222:	4b250513          	addi	a0,a0,1202 # 800136d0 <wait_lock>
    80003226:	ffffe097          	auipc	ra,0xffffe
    8000322a:	a96080e7          	jalr	-1386(ra) # 80000cbc <release>
      return -1;
    8000322e:	557d                	li	a0,-1
    80003230:	a011                	j	80003234 <kthread_join+0x1a4>
    return -1;
    80003232:	557d                	li	a0,-1
  }
}
    80003234:	60a6                	ld	ra,72(sp)
    80003236:	6406                	ld	s0,64(sp)
    80003238:	74e2                	ld	s1,56(sp)
    8000323a:	7942                	ld	s2,48(sp)
    8000323c:	79a2                	ld	s3,40(sp)
    8000323e:	7a02                	ld	s4,32(sp)
    80003240:	6ae2                	ld	s5,24(sp)
    80003242:	6b42                	ld	s6,16(sp)
    80003244:	6ba2                	ld	s7,8(sp)
    80003246:	6161                	addi	sp,sp,80
    80003248:	8082                	ret

000000008000324a <kthread_join_all>:

int
kthread_join_all(){
    8000324a:	7179                	addi	sp,sp,-48
    8000324c:	f406                	sd	ra,40(sp)
    8000324e:	f022                	sd	s0,32(sp)
    80003250:	ec26                	sd	s1,24(sp)
    80003252:	e84a                	sd	s2,16(sp)
    80003254:	e44e                	sd	s3,8(sp)
    80003256:	e052                	sd	s4,0(sp)
    80003258:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    8000325a:	fffff097          	auipc	ra,0xfffff
    8000325e:	abe080e7          	jalr	-1346(ra) # 80001d18 <myproc>
    80003262:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80003264:	fffff097          	auipc	ra,0xfffff
    80003268:	af4080e7          	jalr	-1292(ra) # 80001d58 <mykthread>
    8000326c:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000326e:	28898493          	addi	s1,s3,648
    80003272:	6505                	lui	a0,0x1
    80003274:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80003278:	99aa                	add	s3,s3,a0
  int res = 1;
    8000327a:	4905                	li	s2,1
    8000327c:	a029                	j	80003286 <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    8000327e:	0b848493          	addi	s1,s1,184
    80003282:	00998e63          	beq	s3,s1,8000329e <kthread_join_all+0x54>
    if(nt != t){
    80003286:	fe9a0ce3          	beq	s4,s1,8000327e <kthread_join_all+0x34>
      res &= kthread_join(nt->tid,0);
    8000328a:	4581                	li	a1,0
    8000328c:	5888                	lw	a0,48(s1)
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	e02080e7          	jalr	-510(ra) # 80003090 <kthread_join>
    80003296:	01257933          	and	s2,a0,s2
    8000329a:	2901                	sext.w	s2,s2
    8000329c:	b7cd                	j	8000327e <kthread_join_all+0x34>
    }
  }

  return res;
}
    8000329e:	854a                	mv	a0,s2
    800032a0:	70a2                	ld	ra,40(sp)
    800032a2:	7402                	ld	s0,32(sp)
    800032a4:	64e2                	ld	s1,24(sp)
    800032a6:	6942                	ld	s2,16(sp)
    800032a8:	69a2                	ld	s3,8(sp)
    800032aa:	6a02                	ld	s4,0(sp)
    800032ac:	6145                	addi	sp,sp,48
    800032ae:	8082                	ret

00000000800032b0 <swtch>:
    800032b0:	00153023          	sd	ra,0(a0)
    800032b4:	00253423          	sd	sp,8(a0)
    800032b8:	e900                	sd	s0,16(a0)
    800032ba:	ed04                	sd	s1,24(a0)
    800032bc:	03253023          	sd	s2,32(a0)
    800032c0:	03353423          	sd	s3,40(a0)
    800032c4:	03453823          	sd	s4,48(a0)
    800032c8:	03553c23          	sd	s5,56(a0)
    800032cc:	05653023          	sd	s6,64(a0)
    800032d0:	05753423          	sd	s7,72(a0)
    800032d4:	05853823          	sd	s8,80(a0)
    800032d8:	05953c23          	sd	s9,88(a0)
    800032dc:	07a53023          	sd	s10,96(a0)
    800032e0:	07b53423          	sd	s11,104(a0)
    800032e4:	0005b083          	ld	ra,0(a1)
    800032e8:	0085b103          	ld	sp,8(a1)
    800032ec:	6980                	ld	s0,16(a1)
    800032ee:	6d84                	ld	s1,24(a1)
    800032f0:	0205b903          	ld	s2,32(a1)
    800032f4:	0285b983          	ld	s3,40(a1)
    800032f8:	0305ba03          	ld	s4,48(a1)
    800032fc:	0385ba83          	ld	s5,56(a1)
    80003300:	0405bb03          	ld	s6,64(a1)
    80003304:	0485bb83          	ld	s7,72(a1)
    80003308:	0505bc03          	ld	s8,80(a1)
    8000330c:	0585bc83          	ld	s9,88(a1)
    80003310:	0605bd03          	ld	s10,96(a1)
    80003314:	0685bd83          	ld	s11,104(a1)
    80003318:	8082                	ret

000000008000331a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000331a:	1141                	addi	sp,sp,-16
    8000331c:	e406                	sd	ra,8(sp)
    8000331e:	e022                	sd	s0,0(sp)
    80003320:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003322:	00006597          	auipc	a1,0x6
    80003326:	04658593          	addi	a1,a1,70 # 80009368 <states.0+0x20>
    8000332a:	00032517          	auipc	a0,0x32
    8000332e:	9fe50513          	addi	a0,a0,-1538 # 80034d28 <tickslock>
    80003332:	ffffe097          	auipc	ra,0xffffe
    80003336:	804080e7          	jalr	-2044(ra) # 80000b36 <initlock>
}
    8000333a:	60a2                	ld	ra,8(sp)
    8000333c:	6402                	ld	s0,0(sp)
    8000333e:	0141                	addi	sp,sp,16
    80003340:	8082                	ret

0000000080003342 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003342:	1141                	addi	sp,sp,-16
    80003344:	e422                	sd	s0,8(sp)
    80003346:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003348:	00004797          	auipc	a5,0x4
    8000334c:	b4878793          	addi	a5,a5,-1208 # 80006e90 <kernelvec>
    80003350:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003354:	6422                	ld	s0,8(sp)
    80003356:	0141                	addi	sp,sp,16
    80003358:	8082                	ret

000000008000335a <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    8000335a:	0e852303          	lw	t1,232(a0)
    8000335e:	0f850813          	addi	a6,a0,248
    80003362:	4685                	li	a3,1
    80003364:	4701                	li	a4,0
    80003366:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003368:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    8000336a:	4ecd                	li	t4,19
    8000336c:	a801                	j	8000337c <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    8000336e:	0006879b          	sext.w	a5,a3
    80003372:	04fe4663          	blt	t3,a5,800033be <check_should_cont+0x64>
    80003376:	2705                	addiw	a4,a4,1
    80003378:	2685                	addiw	a3,a3,1
    8000337a:	0821                	addi	a6,a6,8
    8000337c:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    80003380:	00e8963b          	sllw	a2,a7,a4
    80003384:	00c377b3          	and	a5,t1,a2
    80003388:	2781                	sext.w	a5,a5
    8000338a:	d3f5                	beqz	a5,8000336e <check_should_cont+0x14>
    8000338c:	0ec52783          	lw	a5,236(a0)
    80003390:	8ff1                	and	a5,a5,a2
    80003392:	2781                	sext.w	a5,a5
    80003394:	ffe9                	bnez	a5,8000336e <check_should_cont+0x14>
    80003396:	00083783          	ld	a5,0(a6)
    8000339a:	01d78563          	beq	a5,t4,800033a4 <check_should_cont+0x4a>
    8000339e:	fdd598e3          	bne	a1,t4,8000336e <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    800033a2:	fbf1                	bnez	a5,80003376 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    800033a4:	1141                	addi	sp,sp,-16
    800033a6:	e406                	sd	ra,8(sp)
    800033a8:	e022                	sd	s0,0(sp)
    800033aa:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    800033ac:	00000097          	auipc	ra,0x0
    800033b0:	bbc080e7          	jalr	-1092(ra) # 80002f68 <turn_off_bit>
        return 1;
    800033b4:	4505                	li	a0,1
      }
  }
  return 0;
}
    800033b6:	60a2                	ld	ra,8(sp)
    800033b8:	6402                	ld	s0,0(sp)
    800033ba:	0141                	addi	sp,sp,16
    800033bc:	8082                	ret
  return 0;
    800033be:	4501                	li	a0,0
}
    800033c0:	8082                	ret

00000000800033c2 <handle_stop>:



void
handle_stop(struct proc* p){
    800033c2:	7139                	addi	sp,sp,-64
    800033c4:	fc06                	sd	ra,56(sp)
    800033c6:	f822                	sd	s0,48(sp)
    800033c8:	f426                	sd	s1,40(sp)
    800033ca:	f04a                	sd	s2,32(sp)
    800033cc:	ec4e                	sd	s3,24(sp)
    800033ce:	e852                	sd	s4,16(sp)
    800033d0:	e456                	sd	s5,8(sp)
    800033d2:	e05a                	sd	s6,0(sp)
    800033d4:	0080                	addi	s0,sp,64
    800033d6:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    800033d8:	fffff097          	auipc	ra,0xfffff
    800033dc:	980080e7          	jalr	-1664(ra) # 80001d58 <mykthread>
    800033e0:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800033e2:	28898493          	addi	s1,s3,648
    800033e6:	6a05                	lui	s4,0x1
    800033e8:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800033ec:	9a4e                	add	s4,s4,s3
    800033ee:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800033f0:	4b05                	li	s6,1
    800033f2:	a029                	j	800033fc <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800033f4:	0b890913          	addi	s2,s2,184
    800033f8:	03490163          	beq	s2,s4,8000341a <handle_stop+0x58>
    if(t!=curr_t){
    800033fc:	ff2a8ce3          	beq	s5,s2,800033f4 <handle_stop+0x32>
      acquire(&t->lock);
    80003400:	854a                	mv	a0,s2
    80003402:	ffffe097          	auipc	ra,0xffffe
    80003406:	806080e7          	jalr	-2042(ra) # 80000c08 <acquire>
      t->frozen=1;
    8000340a:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    8000340e:	854a                	mv	a0,s2
    80003410:	ffffe097          	auipc	ra,0xffffe
    80003414:	8ac080e7          	jalr	-1876(ra) # 80000cbc <release>
    80003418:	bff1                	j	800033f4 <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    8000341a:	854e                	mv	a0,s3
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	f3e080e7          	jalr	-194(ra) # 8000335a <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003424:	0e89a783          	lw	a5,232(s3)
    80003428:	2007f793          	andi	a5,a5,512
    8000342c:	e795                	bnez	a5,80003458 <handle_stop+0x96>
    8000342e:	e50d                	bnez	a0,80003458 <handle_stop+0x96>
    
    yield();
    80003430:	fffff097          	auipc	ra,0xfffff
    80003434:	1f6080e7          	jalr	502(ra) # 80002626 <yield>
    should_cont = check_should_cont(p);  
    80003438:	854e                	mv	a0,s3
    8000343a:	00000097          	auipc	ra,0x0
    8000343e:	f20080e7          	jalr	-224(ra) # 8000335a <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003442:	0e89a783          	lw	a5,232(s3)
    80003446:	2007f793          	andi	a5,a5,512
    8000344a:	e799                	bnez	a5,80003458 <handle_stop+0x96>
    8000344c:	d175                	beqz	a0,80003430 <handle_stop+0x6e>
    8000344e:	a029                	j	80003458 <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003450:	0b848493          	addi	s1,s1,184
    80003454:	03448163          	beq	s1,s4,80003476 <handle_stop+0xb4>
    if(t!=curr_t){
    80003458:	fe9a8ce3          	beq	s5,s1,80003450 <handle_stop+0x8e>
      acquire(&t->lock);
    8000345c:	8526                	mv	a0,s1
    8000345e:	ffffd097          	auipc	ra,0xffffd
    80003462:	7aa080e7          	jalr	1962(ra) # 80000c08 <acquire>
      t->frozen=0;
    80003466:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    8000346a:	8526                	mv	a0,s1
    8000346c:	ffffe097          	auipc	ra,0xffffe
    80003470:	850080e7          	jalr	-1968(ra) # 80000cbc <release>
    80003474:	bff1                	j	80003450 <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    80003476:	0e89a783          	lw	a5,232(s3)
    8000347a:	2007f793          	andi	a5,a5,512
    8000347e:	c781                	beqz	a5,80003486 <handle_stop+0xc4>
    p->killed=1;
    80003480:	4785                	li	a5,1
    80003482:	00f9ae23          	sw	a5,28(s3)
}
    80003486:	70e2                	ld	ra,56(sp)
    80003488:	7442                	ld	s0,48(sp)
    8000348a:	74a2                	ld	s1,40(sp)
    8000348c:	7902                	ld	s2,32(sp)
    8000348e:	69e2                	ld	s3,24(sp)
    80003490:	6a42                	ld	s4,16(sp)
    80003492:	6aa2                	ld	s5,8(sp)
    80003494:	6b02                	ld	s6,0(sp)
    80003496:	6121                	addi	sp,sp,64
    80003498:	8082                	ret

000000008000349a <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    8000349a:	711d                	addi	sp,sp,-96
    8000349c:	ec86                	sd	ra,88(sp)
    8000349e:	e8a2                	sd	s0,80(sp)
    800034a0:	e4a6                	sd	s1,72(sp)
    800034a2:	e0ca                	sd	s2,64(sp)
    800034a4:	fc4e                	sd	s3,56(sp)
    800034a6:	f852                	sd	s4,48(sp)
    800034a8:	f456                	sd	s5,40(sp)
    800034aa:	f05a                	sd	s6,32(sp)
    800034ac:	ec5e                	sd	s7,24(sp)
    800034ae:	e862                	sd	s8,16(sp)
    800034b0:	e466                	sd	s9,8(sp)
    800034b2:	e06a                	sd	s10,0(sp)
    800034b4:	1080                	addi	s0,sp,96
    800034b6:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    800034b8:	fffff097          	auipc	ra,0xfffff
    800034bc:	8a0080e7          	jalr	-1888(ra) # 80001d58 <mykthread>
    800034c0:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800034c2:	0f898913          	addi	s2,s3,248
    800034c6:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800034c8:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    800034ca:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    800034cc:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800034ce:	4b85                	li	s7,1
        switch (sig_num)
    800034d0:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800034d2:	02000a93          	li	s5,32
    800034d6:	a0a1                	j	8000351e <check_pending_signals+0x84>
        switch (sig_num)
    800034d8:	03648163          	beq	s1,s6,800034fa <check_pending_signals+0x60>
    800034dc:	03a48763          	beq	s1,s10,8000350a <check_pending_signals+0x70>
            acquire(&p->lock);
    800034e0:	854e                	mv	a0,s3
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	726080e7          	jalr	1830(ra) # 80000c08 <acquire>
            p->killed = 1;
    800034ea:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800034ee:	854e                	mv	a0,s3
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	7cc080e7          	jalr	1996(ra) # 80000cbc <release>
    800034f8:	a809                	j	8000350a <check_pending_signals+0x70>
            handle_stop(p);
    800034fa:	854e                	mv	a0,s3
    800034fc:	00000097          	auipc	ra,0x0
    80003500:	ec6080e7          	jalr	-314(ra) # 800033c2 <handle_stop>
            break;
    80003504:	a019                	j	8000350a <check_pending_signals+0x70>
        p->killed=1;
    80003506:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    8000350a:	85a6                	mv	a1,s1
    8000350c:	854e                	mv	a0,s3
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	a5a080e7          	jalr	-1446(ra) # 80002f68 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    80003516:	2485                	addiw	s1,s1,1
    80003518:	0921                	addi	s2,s2,8
    8000351a:	0d548963          	beq	s1,s5,800035ec <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    8000351e:	009a173b          	sllw	a4,s4,s1
    80003522:	0e89a783          	lw	a5,232(s3)
    80003526:	8ff9                	and	a5,a5,a4
    80003528:	2781                	sext.w	a5,a5
    8000352a:	d7f5                	beqz	a5,80003516 <check_pending_signals+0x7c>
    8000352c:	0ec9a783          	lw	a5,236(s3)
    80003530:	8f7d                	and	a4,a4,a5
    80003532:	2701                	sext.w	a4,a4
    80003534:	f36d                	bnez	a4,80003516 <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    80003536:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    8000353a:	df59                	beqz	a4,800034d8 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    8000353c:	fd8705e3          	beq	a4,s8,80003506 <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003540:	0d670463          	beq	a4,s6,80003608 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003544:	fd7703e3          	beq	a4,s7,8000350a <check_pending_signals+0x70>
    80003548:	2809a703          	lw	a4,640(s3)
    8000354c:	ff5d                	bnez	a4,8000350a <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    8000354e:	07c48713          	addi	a4,s1,124
    80003552:	070a                	slli	a4,a4,0x2
    80003554:	974e                	add	a4,a4,s3
    80003556:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    80003558:	4685                	li	a3,1
    8000355a:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    8000355e:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    80003562:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    80003566:	040cb703          	ld	a4,64(s9)
    8000356a:	7b1c                	ld	a5,48(a4)
    8000356c:	ee078793          	addi	a5,a5,-288
    80003570:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    80003572:	040cb783          	ld	a5,64(s9)
    80003576:	7b8c                	ld	a1,48(a5)
    80003578:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    8000357c:	12000693          	li	a3,288
    80003580:	040cb603          	ld	a2,64(s9)
    80003584:	0409b503          	ld	a0,64(s3)
    80003588:	ffffe097          	auipc	ra,0xffffe
    8000358c:	378080e7          	jalr	888(ra) # 80001900 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    80003590:	00004697          	auipc	a3,0x4
    80003594:	f9068693          	addi	a3,a3,-112 # 80007520 <end_sigret>
    80003598:	00004617          	auipc	a2,0x4
    8000359c:	f8060613          	addi	a2,a2,-128 # 80007518 <call_sigret>
        t->trapframe->sp -= size;
    800035a0:	040cb703          	ld	a4,64(s9)
    800035a4:	40d605b3          	sub	a1,a2,a3
    800035a8:	7b1c                	ld	a5,48(a4)
    800035aa:	97ae                	add	a5,a5,a1
    800035ac:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    800035ae:	040cb783          	ld	a5,64(s9)
    800035b2:	8e91                	sub	a3,a3,a2
    800035b4:	7b8c                	ld	a1,48(a5)
    800035b6:	0409b503          	ld	a0,64(s3)
    800035ba:	ffffe097          	auipc	ra,0xffffe
    800035be:	346080e7          	jalr	838(ra) # 80001900 <copyout>
        t->trapframe->a0 = sig_num;
    800035c2:	040cb783          	ld	a5,64(s9)
    800035c6:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    800035c8:	040cb783          	ld	a5,64(s9)
    800035cc:	7b98                	ld	a4,48(a5)
    800035ce:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    800035d0:	040cb703          	ld	a4,64(s9)
    800035d4:	01e48793          	addi	a5,s1,30
    800035d8:	078e                	slli	a5,a5,0x3
    800035da:	97ce                	add	a5,a5,s3
    800035dc:	679c                	ld	a5,8(a5)
    800035de:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    800035e0:	85a6                	mv	a1,s1
    800035e2:	854e                	mv	a0,s3
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	984080e7          	jalr	-1660(ra) # 80002f68 <turn_off_bit>
    }
  }
}
    800035ec:	60e6                	ld	ra,88(sp)
    800035ee:	6446                	ld	s0,80(sp)
    800035f0:	64a6                	ld	s1,72(sp)
    800035f2:	6906                	ld	s2,64(sp)
    800035f4:	79e2                	ld	s3,56(sp)
    800035f6:	7a42                	ld	s4,48(sp)
    800035f8:	7aa2                	ld	s5,40(sp)
    800035fa:	7b02                	ld	s6,32(sp)
    800035fc:	6be2                	ld	s7,24(sp)
    800035fe:	6c42                	ld	s8,16(sp)
    80003600:	6ca2                	ld	s9,8(sp)
    80003602:	6d02                	ld	s10,0(sp)
    80003604:	6125                	addi	sp,sp,96
    80003606:	8082                	ret
        handle_stop(p);
    80003608:	854e                	mv	a0,s3
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	db8080e7          	jalr	-584(ra) # 800033c2 <handle_stop>
    80003612:	bde5                	j	8000350a <check_pending_signals+0x70>

0000000080003614 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003614:	1101                	addi	sp,sp,-32
    80003616:	ec06                	sd	ra,24(sp)
    80003618:	e822                	sd	s0,16(sp)
    8000361a:	e426                	sd	s1,8(sp)
    8000361c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000361e:	ffffe097          	auipc	ra,0xffffe
    80003622:	6fa080e7          	jalr	1786(ra) # 80001d18 <myproc>
    80003626:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    80003628:	ffffe097          	auipc	ra,0xffffe
    8000362c:	730080e7          	jalr	1840(ra) # 80001d58 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003630:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003634:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003636:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000363a:	00005617          	auipc	a2,0x5
    8000363e:	9c660613          	addi	a2,a2,-1594 # 80008000 <_trampoline>
    80003642:	00005697          	auipc	a3,0x5
    80003646:	9be68693          	addi	a3,a3,-1602 # 80008000 <_trampoline>
    8000364a:	8e91                	sub	a3,a3,a2
    8000364c:	040007b7          	lui	a5,0x4000
    80003650:	17fd                	addi	a5,a5,-1
    80003652:	07b2                	slli	a5,a5,0xc
    80003654:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003656:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    8000365a:	6138                	ld	a4,64(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000365c:	180026f3          	csrr	a3,satp
    80003660:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80003662:	6138                	ld	a4,64(a0)
    80003664:	7d14                	ld	a3,56(a0)
    80003666:	6585                	lui	a1,0x1
    80003668:	96ae                	add	a3,a3,a1
    8000366a:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    8000366c:	6138                	ld	a4,64(a0)
    8000366e:	00000697          	auipc	a3,0x0
    80003672:	15868693          	addi	a3,a3,344 # 800037c6 <usertrap>
    80003676:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003678:	6138                	ld	a4,64(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000367a:	8692                	mv	a3,tp
    8000367c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000367e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003682:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003686:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000368a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    8000368e:	6138                	ld	a4,64(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003690:	6f18                	ld	a4,24(a4)
    80003692:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003696:	60ac                	ld	a1,64(s1)
    80003698:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    8000369a:	28848493          	addi	s1,s1,648
    8000369e:	8d05                	sub	a0,a0,s1
    800036a0:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800036a2:	00006717          	auipc	a4,0x6
    800036a6:	96e73703          	ld	a4,-1682(a4) # 80009010 <etext+0x10>
    800036aa:	02e5053b          	mulw	a0,a0,a4
    800036ae:	00351693          	slli	a3,a0,0x3
    800036b2:	9536                	add	a0,a0,a3
    800036b4:	0516                	slli	a0,a0,0x5
    800036b6:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800036ba:	00005717          	auipc	a4,0x5
    800036be:	9d670713          	addi	a4,a4,-1578 # 80008090 <userret>
    800036c2:	8f11                	sub	a4,a4,a2
    800036c4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800036c6:	577d                	li	a4,-1
    800036c8:	177e                	slli	a4,a4,0x3f
    800036ca:	8dd9                	or	a1,a1,a4
    800036cc:	16fd                	addi	a3,a3,-1
    800036ce:	06b6                	slli	a3,a3,0xd
    800036d0:	9536                	add	a0,a0,a3
    800036d2:	9782                	jalr	a5

}
    800036d4:	60e2                	ld	ra,24(sp)
    800036d6:	6442                	ld	s0,16(sp)
    800036d8:	64a2                	ld	s1,8(sp)
    800036da:	6105                	addi	sp,sp,32
    800036dc:	8082                	ret

00000000800036de <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800036de:	1101                	addi	sp,sp,-32
    800036e0:	ec06                	sd	ra,24(sp)
    800036e2:	e822                	sd	s0,16(sp)
    800036e4:	e426                	sd	s1,8(sp)
    800036e6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800036e8:	00031497          	auipc	s1,0x31
    800036ec:	64048493          	addi	s1,s1,1600 # 80034d28 <tickslock>
    800036f0:	8526                	mv	a0,s1
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	516080e7          	jalr	1302(ra) # 80000c08 <acquire>
  ticks++;
    800036fa:	00007517          	auipc	a0,0x7
    800036fe:	93650513          	addi	a0,a0,-1738 # 8000a030 <ticks>
    80003702:	411c                	lw	a5,0(a0)
    80003704:	2785                	addiw	a5,a5,1
    80003706:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003708:	fffff097          	auipc	ra,0xfffff
    8000370c:	0e4080e7          	jalr	228(ra) # 800027ec <wakeup>
  release(&tickslock);
    80003710:	8526                	mv	a0,s1
    80003712:	ffffd097          	auipc	ra,0xffffd
    80003716:	5aa080e7          	jalr	1450(ra) # 80000cbc <release>
}
    8000371a:	60e2                	ld	ra,24(sp)
    8000371c:	6442                	ld	s0,16(sp)
    8000371e:	64a2                	ld	s1,8(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret

0000000080003724 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003724:	1101                	addi	sp,sp,-32
    80003726:	ec06                	sd	ra,24(sp)
    80003728:	e822                	sd	s0,16(sp)
    8000372a:	e426                	sd	s1,8(sp)
    8000372c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000372e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003732:	00074d63          	bltz	a4,8000374c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003736:	57fd                	li	a5,-1
    80003738:	17fe                	slli	a5,a5,0x3f
    8000373a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000373c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000373e:	06f70363          	beq	a4,a5,800037a4 <devintr+0x80>
  }
}
    80003742:	60e2                	ld	ra,24(sp)
    80003744:	6442                	ld	s0,16(sp)
    80003746:	64a2                	ld	s1,8(sp)
    80003748:	6105                	addi	sp,sp,32
    8000374a:	8082                	ret
     (scause & 0xff) == 9){
    8000374c:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80003750:	46a5                	li	a3,9
    80003752:	fed792e3          	bne	a5,a3,80003736 <devintr+0x12>
    int irq = plic_claim();
    80003756:	00004097          	auipc	ra,0x4
    8000375a:	842080e7          	jalr	-1982(ra) # 80006f98 <plic_claim>
    8000375e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003760:	47a9                	li	a5,10
    80003762:	02f50763          	beq	a0,a5,80003790 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003766:	4785                	li	a5,1
    80003768:	02f50963          	beq	a0,a5,8000379a <devintr+0x76>
    return 1;
    8000376c:	4505                	li	a0,1
    } else if(irq){
    8000376e:	d8f1                	beqz	s1,80003742 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003770:	85a6                	mv	a1,s1
    80003772:	00006517          	auipc	a0,0x6
    80003776:	bfe50513          	addi	a0,a0,-1026 # 80009370 <states.0+0x28>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	dfe080e7          	jalr	-514(ra) # 80000578 <printf>
      plic_complete(irq);
    80003782:	8526                	mv	a0,s1
    80003784:	00004097          	auipc	ra,0x4
    80003788:	838080e7          	jalr	-1992(ra) # 80006fbc <plic_complete>
    return 1;
    8000378c:	4505                	li	a0,1
    8000378e:	bf55                	j	80003742 <devintr+0x1e>
      uartintr();
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	1fa080e7          	jalr	506(ra) # 8000098a <uartintr>
    80003798:	b7ed                	j	80003782 <devintr+0x5e>
      virtio_disk_intr();
    8000379a:	00004097          	auipc	ra,0x4
    8000379e:	cb4080e7          	jalr	-844(ra) # 8000744e <virtio_disk_intr>
    800037a2:	b7c5                	j	80003782 <devintr+0x5e>
    if(cpuid() == 0){
    800037a4:	ffffe097          	auipc	ra,0xffffe
    800037a8:	540080e7          	jalr	1344(ra) # 80001ce4 <cpuid>
    800037ac:	c901                	beqz	a0,800037bc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800037ae:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800037b2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800037b4:	14479073          	csrw	sip,a5
    return 2;
    800037b8:	4509                	li	a0,2
    800037ba:	b761                	j	80003742 <devintr+0x1e>
      clockintr();
    800037bc:	00000097          	auipc	ra,0x0
    800037c0:	f22080e7          	jalr	-222(ra) # 800036de <clockintr>
    800037c4:	b7ed                	j	800037ae <devintr+0x8a>

00000000800037c6 <usertrap>:
{
    800037c6:	1101                	addi	sp,sp,-32
    800037c8:	ec06                	sd	ra,24(sp)
    800037ca:	e822                	sd	s0,16(sp)
    800037cc:	e426                	sd	s1,8(sp)
    800037ce:	e04a                	sd	s2,0(sp)
    800037d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800037d2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800037d6:	1007f793          	andi	a5,a5,256
    800037da:	efc9                	bnez	a5,80003874 <usertrap+0xae>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800037dc:	00003797          	auipc	a5,0x3
    800037e0:	6b478793          	addi	a5,a5,1716 # 80006e90 <kernelvec>
    800037e4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800037e8:	ffffe097          	auipc	ra,0xffffe
    800037ec:	530080e7          	jalr	1328(ra) # 80001d18 <myproc>
    800037f0:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    800037f2:	ffffe097          	auipc	ra,0xffffe
    800037f6:	566080e7          	jalr	1382(ra) # 80001d58 <mykthread>
    800037fa:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    800037fc:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800037fe:	14102773          	csrr	a4,sepc
    80003802:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003804:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80003808:	47a1                	li	a5,8
    8000380a:	08f71963          	bne	a4,a5,8000389c <usertrap+0xd6>
    if(t->killed == 1)
    8000380e:	5518                	lw	a4,40(a0)
    80003810:	4785                	li	a5,1
    80003812:	06f70963          	beq	a4,a5,80003884 <usertrap+0xbe>
    else if(p->killed)
    80003816:	4cdc                	lw	a5,28(s1)
    80003818:	efa5                	bnez	a5,80003890 <usertrap+0xca>
    t->trapframe->epc += 4;
    8000381a:	04093703          	ld	a4,64(s2)
    8000381e:	6f1c                	ld	a5,24(a4)
    80003820:	0791                	addi	a5,a5,4
    80003822:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003824:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003828:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000382c:	10079073          	csrw	sstatus,a5
    syscall();
    80003830:	00000097          	auipc	ra,0x0
    80003834:	364080e7          	jalr	868(ra) # 80003b94 <syscall>
  acquire(&p->lock);
    80003838:	8526                	mv	a0,s1
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	3ce080e7          	jalr	974(ra) # 80000c08 <acquire>
  if(!p->handling_sig_flag){
    80003842:	2844a783          	lw	a5,644(s1)
    80003846:	c3dd                	beqz	a5,800038ec <usertrap+0x126>
  release(&p->lock);
    80003848:	8526                	mv	a0,s1
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	472080e7          	jalr	1138(ra) # 80000cbc <release>
  if(t->killed == 1)
    80003852:	02892703          	lw	a4,40(s2)
    80003856:	4785                	li	a5,1
    80003858:	0af70f63          	beq	a4,a5,80003916 <usertrap+0x150>
  else if(p->killed)
    8000385c:	4cdc                	lw	a5,28(s1)
    8000385e:	e3f1                	bnez	a5,80003922 <usertrap+0x15c>
  usertrapret();
    80003860:	00000097          	auipc	ra,0x0
    80003864:	db4080e7          	jalr	-588(ra) # 80003614 <usertrapret>
}
    80003868:	60e2                	ld	ra,24(sp)
    8000386a:	6442                	ld	s0,16(sp)
    8000386c:	64a2                	ld	s1,8(sp)
    8000386e:	6902                	ld	s2,0(sp)
    80003870:	6105                	addi	sp,sp,32
    80003872:	8082                	ret
    panic("usertrap: not from user mode");
    80003874:	00006517          	auipc	a0,0x6
    80003878:	b1c50513          	addi	a0,a0,-1252 # 80009390 <states.0+0x48>
    8000387c:	ffffd097          	auipc	ra,0xffffd
    80003880:	cb2080e7          	jalr	-846(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    80003884:	557d                	li	a0,-1
    80003886:	fffff097          	auipc	ra,0xfffff
    8000388a:	178080e7          	jalr	376(ra) # 800029fe <kthread_exit>
    8000388e:	b771                	j	8000381a <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003890:	557d                	li	a0,-1
    80003892:	fffff097          	auipc	ra,0xfffff
    80003896:	20a080e7          	jalr	522(ra) # 80002a9c <exit>
    8000389a:	b741                	j	8000381a <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    8000389c:	00000097          	auipc	ra,0x0
    800038a0:	e88080e7          	jalr	-376(ra) # 80003724 <devintr>
    800038a4:	c909                	beqz	a0,800038b6 <usertrap+0xf0>
  if(which_dev == 2)
    800038a6:	4789                	li	a5,2
    800038a8:	f8f518e3          	bne	a0,a5,80003838 <usertrap+0x72>
    yield();
    800038ac:	fffff097          	auipc	ra,0xfffff
    800038b0:	d7a080e7          	jalr	-646(ra) # 80002626 <yield>
    800038b4:	b751                	j	80003838 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800038b6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800038ba:	50d0                	lw	a2,36(s1)
    800038bc:	00006517          	auipc	a0,0x6
    800038c0:	af450513          	addi	a0,a0,-1292 # 800093b0 <states.0+0x68>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	cb4080e7          	jalr	-844(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038cc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800038d0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800038d4:	00006517          	auipc	a0,0x6
    800038d8:	b0c50513          	addi	a0,a0,-1268 # 800093e0 <states.0+0x98>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	c9c080e7          	jalr	-868(ra) # 80000578 <printf>
    t->killed = 1;
    800038e4:	4785                	li	a5,1
    800038e6:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    800038ea:	b7b9                	j	80003838 <usertrap+0x72>
    p->handling_sig_flag = 1;
    800038ec:	4785                	li	a5,1
    800038ee:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    800038f2:	8526                	mv	a0,s1
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	3c8080e7          	jalr	968(ra) # 80000cbc <release>
    check_pending_signals(p);
    800038fc:	8526                	mv	a0,s1
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	b9c080e7          	jalr	-1124(ra) # 8000349a <check_pending_signals>
    acquire(&p->lock);
    80003906:	8526                	mv	a0,s1
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	300080e7          	jalr	768(ra) # 80000c08 <acquire>
    p->handling_sig_flag = 0;
    80003910:	2804a223          	sw	zero,644(s1)
    80003914:	bf15                	j	80003848 <usertrap+0x82>
    kthread_exit(-1); // Kill current thread
    80003916:	557d                	li	a0,-1
    80003918:	fffff097          	auipc	ra,0xfffff
    8000391c:	0e6080e7          	jalr	230(ra) # 800029fe <kthread_exit>
    80003920:	b781                	j	80003860 <usertrap+0x9a>
    exit(-1); // Kill the hole procces
    80003922:	557d                	li	a0,-1
    80003924:	fffff097          	auipc	ra,0xfffff
    80003928:	178080e7          	jalr	376(ra) # 80002a9c <exit>
    8000392c:	bf15                	j	80003860 <usertrap+0x9a>

000000008000392e <kerneltrap>:
{
    8000392e:	7179                	addi	sp,sp,-48
    80003930:	f406                	sd	ra,40(sp)
    80003932:	f022                	sd	s0,32(sp)
    80003934:	ec26                	sd	s1,24(sp)
    80003936:	e84a                	sd	s2,16(sp)
    80003938:	e44e                	sd	s3,8(sp)
    8000393a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000393c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003940:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003944:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003948:	1004f793          	andi	a5,s1,256
    8000394c:	cb85                	beqz	a5,8000397c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000394e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003952:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003954:	ef85                	bnez	a5,8000398c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003956:	00000097          	auipc	ra,0x0
    8000395a:	dce080e7          	jalr	-562(ra) # 80003724 <devintr>
    8000395e:	cd1d                	beqz	a0,8000399c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003960:	4789                	li	a5,2
    80003962:	08f50763          	beq	a0,a5,800039f0 <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003966:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000396a:	10049073          	csrw	sstatus,s1
}
    8000396e:	70a2                	ld	ra,40(sp)
    80003970:	7402                	ld	s0,32(sp)
    80003972:	64e2                	ld	s1,24(sp)
    80003974:	6942                	ld	s2,16(sp)
    80003976:	69a2                	ld	s3,8(sp)
    80003978:	6145                	addi	sp,sp,48
    8000397a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000397c:	00006517          	auipc	a0,0x6
    80003980:	a8450513          	addi	a0,a0,-1404 # 80009400 <states.0+0xb8>
    80003984:	ffffd097          	auipc	ra,0xffffd
    80003988:	baa080e7          	jalr	-1110(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    8000398c:	00006517          	auipc	a0,0x6
    80003990:	a9c50513          	addi	a0,a0,-1380 # 80009428 <states.0+0xe0>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	b9a080e7          	jalr	-1126(ra) # 8000052e <panic>
    printf("proc %d recieved kernel trap\n",myproc()->pid);
    8000399c:	ffffe097          	auipc	ra,0xffffe
    800039a0:	37c080e7          	jalr	892(ra) # 80001d18 <myproc>
    800039a4:	514c                	lw	a1,36(a0)
    800039a6:	00006517          	auipc	a0,0x6
    800039aa:	aa250513          	addi	a0,a0,-1374 # 80009448 <states.0+0x100>
    800039ae:	ffffd097          	auipc	ra,0xffffd
    800039b2:	bca080e7          	jalr	-1078(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    800039b6:	85ce                	mv	a1,s3
    800039b8:	00006517          	auipc	a0,0x6
    800039bc:	ab050513          	addi	a0,a0,-1360 # 80009468 <states.0+0x120>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	bb8080e7          	jalr	-1096(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800039c8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800039cc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800039d0:	00006517          	auipc	a0,0x6
    800039d4:	aa850513          	addi	a0,a0,-1368 # 80009478 <states.0+0x130>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	ba0080e7          	jalr	-1120(ra) # 80000578 <printf>
    panic("kerneltrap");
    800039e0:	00006517          	auipc	a0,0x6
    800039e4:	ab050513          	addi	a0,a0,-1360 # 80009490 <states.0+0x148>
    800039e8:	ffffd097          	auipc	ra,0xffffd
    800039ec:	b46080e7          	jalr	-1210(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800039f0:	ffffe097          	auipc	ra,0xffffe
    800039f4:	328080e7          	jalr	808(ra) # 80001d18 <myproc>
    800039f8:	d53d                	beqz	a0,80003966 <kerneltrap+0x38>
    800039fa:	ffffe097          	auipc	ra,0xffffe
    800039fe:	35e080e7          	jalr	862(ra) # 80001d58 <mykthread>
    80003a02:	d135                	beqz	a0,80003966 <kerneltrap+0x38>
    80003a04:	ffffe097          	auipc	ra,0xffffe
    80003a08:	354080e7          	jalr	852(ra) # 80001d58 <mykthread>
    80003a0c:	4d18                	lw	a4,24(a0)
    80003a0e:	4791                	li	a5,4
    80003a10:	f4f71be3          	bne	a4,a5,80003966 <kerneltrap+0x38>
    yield();
    80003a14:	fffff097          	auipc	ra,0xfffff
    80003a18:	c12080e7          	jalr	-1006(ra) # 80002626 <yield>
    80003a1c:	b7a9                	j	80003966 <kerneltrap+0x38>

0000000080003a1e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003a1e:	1101                	addi	sp,sp,-32
    80003a20:	ec06                	sd	ra,24(sp)
    80003a22:	e822                	sd	s0,16(sp)
    80003a24:	e426                	sd	s1,8(sp)
    80003a26:	1000                	addi	s0,sp,32
    80003a28:	84aa                	mv	s1,a0

  struct kthread *t = mykthread();
    80003a2a:	ffffe097          	auipc	ra,0xffffe
    80003a2e:	32e080e7          	jalr	814(ra) # 80001d58 <mykthread>
  switch (n) {
    80003a32:	4795                	li	a5,5
    80003a34:	0497e163          	bltu	a5,s1,80003a76 <argraw+0x58>
    80003a38:	048a                	slli	s1,s1,0x2
    80003a3a:	00006717          	auipc	a4,0x6
    80003a3e:	a8e70713          	addi	a4,a4,-1394 # 800094c8 <states.0+0x180>
    80003a42:	94ba                	add	s1,s1,a4
    80003a44:	409c                	lw	a5,0(s1)
    80003a46:	97ba                	add	a5,a5,a4
    80003a48:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003a4a:	613c                	ld	a5,64(a0)
    80003a4c:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003a4e:	60e2                	ld	ra,24(sp)
    80003a50:	6442                	ld	s0,16(sp)
    80003a52:	64a2                	ld	s1,8(sp)
    80003a54:	6105                	addi	sp,sp,32
    80003a56:	8082                	ret
    return t->trapframe->a1;
    80003a58:	613c                	ld	a5,64(a0)
    80003a5a:	7fa8                	ld	a0,120(a5)
    80003a5c:	bfcd                	j	80003a4e <argraw+0x30>
    return t->trapframe->a2;
    80003a5e:	613c                	ld	a5,64(a0)
    80003a60:	63c8                	ld	a0,128(a5)
    80003a62:	b7f5                	j	80003a4e <argraw+0x30>
    return t->trapframe->a3;
    80003a64:	613c                	ld	a5,64(a0)
    80003a66:	67c8                	ld	a0,136(a5)
    80003a68:	b7dd                	j	80003a4e <argraw+0x30>
    return t->trapframe->a4;
    80003a6a:	613c                	ld	a5,64(a0)
    80003a6c:	6bc8                	ld	a0,144(a5)
    80003a6e:	b7c5                	j	80003a4e <argraw+0x30>
    return t->trapframe->a5;
    80003a70:	613c                	ld	a5,64(a0)
    80003a72:	6fc8                	ld	a0,152(a5)
    80003a74:	bfe9                	j	80003a4e <argraw+0x30>
  panic("argraw");
    80003a76:	00006517          	auipc	a0,0x6
    80003a7a:	a2a50513          	addi	a0,a0,-1494 # 800094a0 <states.0+0x158>
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	ab0080e7          	jalr	-1360(ra) # 8000052e <panic>

0000000080003a86 <fetchaddr>:
{
    80003a86:	1101                	addi	sp,sp,-32
    80003a88:	ec06                	sd	ra,24(sp)
    80003a8a:	e822                	sd	s0,16(sp)
    80003a8c:	e426                	sd	s1,8(sp)
    80003a8e:	e04a                	sd	s2,0(sp)
    80003a90:	1000                	addi	s0,sp,32
    80003a92:	84aa                	mv	s1,a0
    80003a94:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003a96:	ffffe097          	auipc	ra,0xffffe
    80003a9a:	282080e7          	jalr	642(ra) # 80001d18 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003a9e:	7d1c                	ld	a5,56(a0)
    80003aa0:	02f4f863          	bgeu	s1,a5,80003ad0 <fetchaddr+0x4a>
    80003aa4:	00848713          	addi	a4,s1,8
    80003aa8:	02e7e663          	bltu	a5,a4,80003ad4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003aac:	46a1                	li	a3,8
    80003aae:	8626                	mv	a2,s1
    80003ab0:	85ca                	mv	a1,s2
    80003ab2:	6128                	ld	a0,64(a0)
    80003ab4:	ffffe097          	auipc	ra,0xffffe
    80003ab8:	ed8080e7          	jalr	-296(ra) # 8000198c <copyin>
    80003abc:	00a03533          	snez	a0,a0
    80003ac0:	40a00533          	neg	a0,a0
}
    80003ac4:	60e2                	ld	ra,24(sp)
    80003ac6:	6442                	ld	s0,16(sp)
    80003ac8:	64a2                	ld	s1,8(sp)
    80003aca:	6902                	ld	s2,0(sp)
    80003acc:	6105                	addi	sp,sp,32
    80003ace:	8082                	ret
    return -1;
    80003ad0:	557d                	li	a0,-1
    80003ad2:	bfcd                	j	80003ac4 <fetchaddr+0x3e>
    80003ad4:	557d                	li	a0,-1
    80003ad6:	b7fd                	j	80003ac4 <fetchaddr+0x3e>

0000000080003ad8 <fetchstr>:
{
    80003ad8:	7179                	addi	sp,sp,-48
    80003ada:	f406                	sd	ra,40(sp)
    80003adc:	f022                	sd	s0,32(sp)
    80003ade:	ec26                	sd	s1,24(sp)
    80003ae0:	e84a                	sd	s2,16(sp)
    80003ae2:	e44e                	sd	s3,8(sp)
    80003ae4:	1800                	addi	s0,sp,48
    80003ae6:	892a                	mv	s2,a0
    80003ae8:	84ae                	mv	s1,a1
    80003aea:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003aec:	ffffe097          	auipc	ra,0xffffe
    80003af0:	22c080e7          	jalr	556(ra) # 80001d18 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003af4:	86ce                	mv	a3,s3
    80003af6:	864a                	mv	a2,s2
    80003af8:	85a6                	mv	a1,s1
    80003afa:	6128                	ld	a0,64(a0)
    80003afc:	ffffe097          	auipc	ra,0xffffe
    80003b00:	f1e080e7          	jalr	-226(ra) # 80001a1a <copyinstr>
  if(err < 0)
    80003b04:	00054763          	bltz	a0,80003b12 <fetchstr+0x3a>
  return strlen(buf);
    80003b08:	8526                	mv	a0,s1
    80003b0a:	ffffd097          	auipc	ra,0xffffd
    80003b0e:	5f2080e7          	jalr	1522(ra) # 800010fc <strlen>
}
    80003b12:	70a2                	ld	ra,40(sp)
    80003b14:	7402                	ld	s0,32(sp)
    80003b16:	64e2                	ld	s1,24(sp)
    80003b18:	6942                	ld	s2,16(sp)
    80003b1a:	69a2                	ld	s3,8(sp)
    80003b1c:	6145                	addi	sp,sp,48
    80003b1e:	8082                	ret

0000000080003b20 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003b20:	1101                	addi	sp,sp,-32
    80003b22:	ec06                	sd	ra,24(sp)
    80003b24:	e822                	sd	s0,16(sp)
    80003b26:	e426                	sd	s1,8(sp)
    80003b28:	1000                	addi	s0,sp,32
    80003b2a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	ef2080e7          	jalr	-270(ra) # 80003a1e <argraw>
    80003b34:	c088                	sw	a0,0(s1)
  return 0;
}
    80003b36:	4501                	li	a0,0
    80003b38:	60e2                	ld	ra,24(sp)
    80003b3a:	6442                	ld	s0,16(sp)
    80003b3c:	64a2                	ld	s1,8(sp)
    80003b3e:	6105                	addi	sp,sp,32
    80003b40:	8082                	ret

0000000080003b42 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003b42:	1101                	addi	sp,sp,-32
    80003b44:	ec06                	sd	ra,24(sp)
    80003b46:	e822                	sd	s0,16(sp)
    80003b48:	e426                	sd	s1,8(sp)
    80003b4a:	1000                	addi	s0,sp,32
    80003b4c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003b4e:	00000097          	auipc	ra,0x0
    80003b52:	ed0080e7          	jalr	-304(ra) # 80003a1e <argraw>
    80003b56:	e088                	sd	a0,0(s1)
  return 0;
}
    80003b58:	4501                	li	a0,0
    80003b5a:	60e2                	ld	ra,24(sp)
    80003b5c:	6442                	ld	s0,16(sp)
    80003b5e:	64a2                	ld	s1,8(sp)
    80003b60:	6105                	addi	sp,sp,32
    80003b62:	8082                	ret

0000000080003b64 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003b64:	1101                	addi	sp,sp,-32
    80003b66:	ec06                	sd	ra,24(sp)
    80003b68:	e822                	sd	s0,16(sp)
    80003b6a:	e426                	sd	s1,8(sp)
    80003b6c:	e04a                	sd	s2,0(sp)
    80003b6e:	1000                	addi	s0,sp,32
    80003b70:	84ae                	mv	s1,a1
    80003b72:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003b74:	00000097          	auipc	ra,0x0
    80003b78:	eaa080e7          	jalr	-342(ra) # 80003a1e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003b7c:	864a                	mv	a2,s2
    80003b7e:	85a6                	mv	a1,s1
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	f58080e7          	jalr	-168(ra) # 80003ad8 <fetchstr>
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	64a2                	ld	s1,8(sp)
    80003b8e:	6902                	ld	s2,0(sp)
    80003b90:	6105                	addi	sp,sp,32
    80003b92:	8082                	ret

0000000080003b94 <syscall>:
[SYS_bsem_up] sys_bsem_up
};

void
syscall(void)
{
    80003b94:	7179                	addi	sp,sp,-48
    80003b96:	f406                	sd	ra,40(sp)
    80003b98:	f022                	sd	s0,32(sp)
    80003b9a:	ec26                	sd	s1,24(sp)
    80003b9c:	e84a                	sd	s2,16(sp)
    80003b9e:	e44e                	sd	s3,8(sp)
    80003ba0:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003ba2:	ffffe097          	auipc	ra,0xffffe
    80003ba6:	176080e7          	jalr	374(ra) # 80001d18 <myproc>
    80003baa:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003bac:	ffffe097          	auipc	ra,0xffffe
    80003bb0:	1ac080e7          	jalr	428(ra) # 80001d58 <mykthread>
    80003bb4:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003bb6:	04053983          	ld	s3,64(a0)
    80003bba:	0a89b783          	ld	a5,168(s3)
    80003bbe:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003bc2:	37fd                	addiw	a5,a5,-1
    80003bc4:	477d                	li	a4,31
    80003bc6:	00f76f63          	bltu	a4,a5,80003be4 <syscall+0x50>
    80003bca:	00369713          	slli	a4,a3,0x3
    80003bce:	00006797          	auipc	a5,0x6
    80003bd2:	91278793          	addi	a5,a5,-1774 # 800094e0 <syscalls>
    80003bd6:	97ba                	add	a5,a5,a4
    80003bd8:	639c                	ld	a5,0(a5)
    80003bda:	c789                	beqz	a5,80003be4 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003bdc:	9782                	jalr	a5
    80003bde:	06a9b823          	sd	a0,112(s3)
    80003be2:	a005                	j	80003c02 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003be4:	0d890613          	addi	a2,s2,216
    80003be8:	02492583          	lw	a1,36(s2)
    80003bec:	00006517          	auipc	a0,0x6
    80003bf0:	8bc50513          	addi	a0,a0,-1860 # 800094a8 <states.0+0x160>
    80003bf4:	ffffd097          	auipc	ra,0xffffd
    80003bf8:	984080e7          	jalr	-1660(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003bfc:	60bc                	ld	a5,64(s1)
    80003bfe:	577d                	li	a4,-1
    80003c00:	fbb8                	sd	a4,112(a5)
  }
}
    80003c02:	70a2                	ld	ra,40(sp)
    80003c04:	7402                	ld	s0,32(sp)
    80003c06:	64e2                	ld	s1,24(sp)
    80003c08:	6942                	ld	s2,16(sp)
    80003c0a:	69a2                	ld	s3,8(sp)
    80003c0c:	6145                	addi	sp,sp,48
    80003c0e:	8082                	ret

0000000080003c10 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003c10:	1101                	addi	sp,sp,-32
    80003c12:	ec06                	sd	ra,24(sp)
    80003c14:	e822                	sd	s0,16(sp)
    80003c16:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003c18:	fec40593          	addi	a1,s0,-20
    80003c1c:	4501                	li	a0,0
    80003c1e:	00000097          	auipc	ra,0x0
    80003c22:	f02080e7          	jalr	-254(ra) # 80003b20 <argint>
    return -1;
    80003c26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003c28:	00054963          	bltz	a0,80003c3a <sys_exit+0x2a>
  exit(n);
    80003c2c:	fec42503          	lw	a0,-20(s0)
    80003c30:	fffff097          	auipc	ra,0xfffff
    80003c34:	e6c080e7          	jalr	-404(ra) # 80002a9c <exit>
  return 0;  // not reached
    80003c38:	4781                	li	a5,0
}
    80003c3a:	853e                	mv	a0,a5
    80003c3c:	60e2                	ld	ra,24(sp)
    80003c3e:	6442                	ld	s0,16(sp)
    80003c40:	6105                	addi	sp,sp,32
    80003c42:	8082                	ret

0000000080003c44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003c44:	1141                	addi	sp,sp,-16
    80003c46:	e406                	sd	ra,8(sp)
    80003c48:	e022                	sd	s0,0(sp)
    80003c4a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003c4c:	ffffe097          	auipc	ra,0xffffe
    80003c50:	0cc080e7          	jalr	204(ra) # 80001d18 <myproc>
}
    80003c54:	5148                	lw	a0,36(a0)
    80003c56:	60a2                	ld	ra,8(sp)
    80003c58:	6402                	ld	s0,0(sp)
    80003c5a:	0141                	addi	sp,sp,16
    80003c5c:	8082                	ret

0000000080003c5e <sys_fork>:

uint64
sys_fork(void)
{
    80003c5e:	1141                	addi	sp,sp,-16
    80003c60:	e406                	sd	ra,8(sp)
    80003c62:	e022                	sd	s0,0(sp)
    80003c64:	0800                	addi	s0,sp,16
  return fork();
    80003c66:	ffffe097          	auipc	ra,0xffffe
    80003c6a:	63c080e7          	jalr	1596(ra) # 800022a2 <fork>
}
    80003c6e:	60a2                	ld	ra,8(sp)
    80003c70:	6402                	ld	s0,0(sp)
    80003c72:	0141                	addi	sp,sp,16
    80003c74:	8082                	ret

0000000080003c76 <sys_wait>:

uint64
sys_wait(void)
{
    80003c76:	1101                	addi	sp,sp,-32
    80003c78:	ec06                	sd	ra,24(sp)
    80003c7a:	e822                	sd	s0,16(sp)
    80003c7c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003c7e:	fe840593          	addi	a1,s0,-24
    80003c82:	4501                	li	a0,0
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	ebe080e7          	jalr	-322(ra) # 80003b42 <argaddr>
    80003c8c:	87aa                	mv	a5,a0
    return -1;
    80003c8e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003c90:	0007c863          	bltz	a5,80003ca0 <sys_wait+0x2a>
  return wait(p);
    80003c94:	fe843503          	ld	a0,-24(s0)
    80003c98:	fffff097          	auipc	ra,0xfffff
    80003c9c:	a2e080e7          	jalr	-1490(ra) # 800026c6 <wait>
}
    80003ca0:	60e2                	ld	ra,24(sp)
    80003ca2:	6442                	ld	s0,16(sp)
    80003ca4:	6105                	addi	sp,sp,32
    80003ca6:	8082                	ret

0000000080003ca8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003ca8:	7179                	addi	sp,sp,-48
    80003caa:	f406                	sd	ra,40(sp)
    80003cac:	f022                	sd	s0,32(sp)
    80003cae:	ec26                	sd	s1,24(sp)
    80003cb0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003cb2:	fdc40593          	addi	a1,s0,-36
    80003cb6:	4501                	li	a0,0
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	e68080e7          	jalr	-408(ra) # 80003b20 <argint>
    return -1;
    80003cc0:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003cc2:	00054f63          	bltz	a0,80003ce0 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003cc6:	ffffe097          	auipc	ra,0xffffe
    80003cca:	052080e7          	jalr	82(ra) # 80001d18 <myproc>
    80003cce:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003cd0:	fdc42503          	lw	a0,-36(s0)
    80003cd4:	ffffe097          	auipc	ra,0xffffe
    80003cd8:	55a080e7          	jalr	1370(ra) # 8000222e <growproc>
    80003cdc:	00054863          	bltz	a0,80003cec <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003ce0:	8526                	mv	a0,s1
    80003ce2:	70a2                	ld	ra,40(sp)
    80003ce4:	7402                	ld	s0,32(sp)
    80003ce6:	64e2                	ld	s1,24(sp)
    80003ce8:	6145                	addi	sp,sp,48
    80003cea:	8082                	ret
    return -1;
    80003cec:	54fd                	li	s1,-1
    80003cee:	bfcd                	j	80003ce0 <sys_sbrk+0x38>

0000000080003cf0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003cf0:	7139                	addi	sp,sp,-64
    80003cf2:	fc06                	sd	ra,56(sp)
    80003cf4:	f822                	sd	s0,48(sp)
    80003cf6:	f426                	sd	s1,40(sp)
    80003cf8:	f04a                	sd	s2,32(sp)
    80003cfa:	ec4e                	sd	s3,24(sp)
    80003cfc:	e852                	sd	s4,16(sp)
    80003cfe:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003d00:	fcc40593          	addi	a1,s0,-52
    80003d04:	4501                	li	a0,0
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	e1a080e7          	jalr	-486(ra) # 80003b20 <argint>
    return -1;
    80003d0e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003d10:	06054763          	bltz	a0,80003d7e <sys_sleep+0x8e>
  acquire(&tickslock);
    80003d14:	00031517          	auipc	a0,0x31
    80003d18:	01450513          	addi	a0,a0,20 # 80034d28 <tickslock>
    80003d1c:	ffffd097          	auipc	ra,0xffffd
    80003d20:	eec080e7          	jalr	-276(ra) # 80000c08 <acquire>
  ticks0 = ticks;
    80003d24:	00006997          	auipc	s3,0x6
    80003d28:	30c9a983          	lw	s3,780(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003d2c:	fcc42783          	lw	a5,-52(s0)
    80003d30:	cf95                	beqz	a5,80003d6c <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003d32:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003d34:	00031a17          	auipc	s4,0x31
    80003d38:	ff4a0a13          	addi	s4,s4,-12 # 80034d28 <tickslock>
    80003d3c:	00006497          	auipc	s1,0x6
    80003d40:	2f448493          	addi	s1,s1,756 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003d44:	ffffe097          	auipc	ra,0xffffe
    80003d48:	fd4080e7          	jalr	-44(ra) # 80001d18 <myproc>
    80003d4c:	4d5c                	lw	a5,28(a0)
    80003d4e:	05278163          	beq	a5,s2,80003d90 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003d52:	85d2                	mv	a1,s4
    80003d54:	8526                	mv	a0,s1
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	90c080e7          	jalr	-1780(ra) # 80002662 <sleep>
  while(ticks - ticks0 < n){
    80003d5e:	409c                	lw	a5,0(s1)
    80003d60:	413787bb          	subw	a5,a5,s3
    80003d64:	fcc42703          	lw	a4,-52(s0)
    80003d68:	fce7eee3          	bltu	a5,a4,80003d44 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003d6c:	00031517          	auipc	a0,0x31
    80003d70:	fbc50513          	addi	a0,a0,-68 # 80034d28 <tickslock>
    80003d74:	ffffd097          	auipc	ra,0xffffd
    80003d78:	f48080e7          	jalr	-184(ra) # 80000cbc <release>
  return 0;
    80003d7c:	4781                	li	a5,0
}
    80003d7e:	853e                	mv	a0,a5
    80003d80:	70e2                	ld	ra,56(sp)
    80003d82:	7442                	ld	s0,48(sp)
    80003d84:	74a2                	ld	s1,40(sp)
    80003d86:	7902                	ld	s2,32(sp)
    80003d88:	69e2                	ld	s3,24(sp)
    80003d8a:	6a42                	ld	s4,16(sp)
    80003d8c:	6121                	addi	sp,sp,64
    80003d8e:	8082                	ret
      release(&tickslock);
    80003d90:	00031517          	auipc	a0,0x31
    80003d94:	f9850513          	addi	a0,a0,-104 # 80034d28 <tickslock>
    80003d98:	ffffd097          	auipc	ra,0xffffd
    80003d9c:	f24080e7          	jalr	-220(ra) # 80000cbc <release>
      return -1;
    80003da0:	57fd                	li	a5,-1
    80003da2:	bff1                	j	80003d7e <sys_sleep+0x8e>

0000000080003da4 <sys_kill>:

uint64
sys_kill(void)
{
    80003da4:	1101                	addi	sp,sp,-32
    80003da6:	ec06                	sd	ra,24(sp)
    80003da8:	e822                	sd	s0,16(sp)
    80003daa:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003dac:	fec40593          	addi	a1,s0,-20
    80003db0:	4501                	li	a0,0
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	d6e080e7          	jalr	-658(ra) # 80003b20 <argint>
    80003dba:	87aa                	mv	a5,a0
    return -1;
    80003dbc:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003dbe:	0207c963          	bltz	a5,80003df0 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003dc2:	fe840593          	addi	a1,s0,-24
    80003dc6:	4505                	li	a0,1
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	d58080e7          	jalr	-680(ra) # 80003b20 <argint>
    80003dd0:	02054463          	bltz	a0,80003df8 <sys_kill+0x54>
    80003dd4:	fe842583          	lw	a1,-24(s0)
    80003dd8:	0005871b          	sext.w	a4,a1
    80003ddc:	47fd                	li	a5,31
    return -1;
    80003dde:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003de0:	00e7e863          	bltu	a5,a4,80003df0 <sys_kill+0x4c>
  return kill(pid, signum);
    80003de4:	fec42503          	lw	a0,-20(s0)
    80003de8:	fffff097          	auipc	ra,0xfffff
    80003dec:	076080e7          	jalr	118(ra) # 80002e5e <kill>
}
    80003df0:	60e2                	ld	ra,24(sp)
    80003df2:	6442                	ld	s0,16(sp)
    80003df4:	6105                	addi	sp,sp,32
    80003df6:	8082                	ret
    return -1;
    80003df8:	557d                	li	a0,-1
    80003dfa:	bfdd                	j	80003df0 <sys_kill+0x4c>

0000000080003dfc <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003dfc:	1101                	addi	sp,sp,-32
    80003dfe:	ec06                	sd	ra,24(sp)
    80003e00:	e822                	sd	s0,16(sp)
    80003e02:	e426                	sd	s1,8(sp)
    80003e04:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003e06:	00031517          	auipc	a0,0x31
    80003e0a:	f2250513          	addi	a0,a0,-222 # 80034d28 <tickslock>
    80003e0e:	ffffd097          	auipc	ra,0xffffd
    80003e12:	dfa080e7          	jalr	-518(ra) # 80000c08 <acquire>
  xticks = ticks;
    80003e16:	00006497          	auipc	s1,0x6
    80003e1a:	21a4a483          	lw	s1,538(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003e1e:	00031517          	auipc	a0,0x31
    80003e22:	f0a50513          	addi	a0,a0,-246 # 80034d28 <tickslock>
    80003e26:	ffffd097          	auipc	ra,0xffffd
    80003e2a:	e96080e7          	jalr	-362(ra) # 80000cbc <release>
  return xticks;
}
    80003e2e:	02049513          	slli	a0,s1,0x20
    80003e32:	9101                	srli	a0,a0,0x20
    80003e34:	60e2                	ld	ra,24(sp)
    80003e36:	6442                	ld	s0,16(sp)
    80003e38:	64a2                	ld	s1,8(sp)
    80003e3a:	6105                	addi	sp,sp,32
    80003e3c:	8082                	ret

0000000080003e3e <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003e3e:	1101                	addi	sp,sp,-32
    80003e40:	ec06                	sd	ra,24(sp)
    80003e42:	e822                	sd	s0,16(sp)
    80003e44:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003e46:	fec40593          	addi	a1,s0,-20
    80003e4a:	4501                	li	a0,0
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	cd4080e7          	jalr	-812(ra) # 80003b20 <argint>
    80003e54:	87aa                	mv	a5,a0
    return -1;
    80003e56:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003e58:	0007ca63          	bltz	a5,80003e6c <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003e5c:	fec42503          	lw	a0,-20(s0)
    80003e60:	fffff097          	auipc	ra,0xfffff
    80003e64:	e2c080e7          	jalr	-468(ra) # 80002c8c <sigprocmask>
    80003e68:	1502                	slli	a0,a0,0x20
    80003e6a:	9101                	srli	a0,a0,0x20
}
    80003e6c:	60e2                	ld	ra,24(sp)
    80003e6e:	6442                	ld	s0,16(sp)
    80003e70:	6105                	addi	sp,sp,32
    80003e72:	8082                	ret

0000000080003e74 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003e74:	7179                	addi	sp,sp,-48
    80003e76:	f406                	sd	ra,40(sp)
    80003e78:	f022                	sd	s0,32(sp)
    80003e7a:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003e7c:	fec40593          	addi	a1,s0,-20
    80003e80:	4501                	li	a0,0
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	c9e080e7          	jalr	-866(ra) # 80003b20 <argint>
    return -1;
    80003e8a:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003e8c:	04054163          	bltz	a0,80003ece <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003e90:	fe040593          	addi	a1,s0,-32
    80003e94:	4505                	li	a0,1
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	cac080e7          	jalr	-852(ra) # 80003b42 <argaddr>
    return -1;
    80003e9e:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003ea0:	02054763          	bltz	a0,80003ece <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003ea4:	fd840593          	addi	a1,s0,-40
    80003ea8:	4509                	li	a0,2
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	c98080e7          	jalr	-872(ra) # 80003b42 <argaddr>
    return -1;
    80003eb2:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003eb4:	00054d63          	bltz	a0,80003ece <sys_sigaction+0x5a>

  return sigaction(signum,(struct sigaction*)newact, (struct sigaction*)oldact);
    80003eb8:	fd843603          	ld	a2,-40(s0)
    80003ebc:	fe043583          	ld	a1,-32(s0)
    80003ec0:	fec42503          	lw	a0,-20(s0)
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	e1c080e7          	jalr	-484(ra) # 80002ce0 <sigaction>
    80003ecc:	87aa                	mv	a5,a0
  
}
    80003ece:	853e                	mv	a0,a5
    80003ed0:	70a2                	ld	ra,40(sp)
    80003ed2:	7402                	ld	s0,32(sp)
    80003ed4:	6145                	addi	sp,sp,48
    80003ed6:	8082                	ret

0000000080003ed8 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003ed8:	1141                	addi	sp,sp,-16
    80003eda:	e406                	sd	ra,8(sp)
    80003edc:	e022                	sd	s0,0(sp)
    80003ede:	0800                	addi	s0,sp,16
  sigret();
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	eea080e7          	jalr	-278(ra) # 80002dca <sigret>
  return 0;
}
    80003ee8:	4501                	li	a0,0
    80003eea:	60a2                	ld	ra,8(sp)
    80003eec:	6402                	ld	s0,0(sp)
    80003eee:	0141                	addi	sp,sp,16
    80003ef0:	8082                	ret

0000000080003ef2 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003ef2:	1101                	addi	sp,sp,-32
    80003ef4:	ec06                	sd	ra,24(sp)
    80003ef6:	e822                	sd	s0,16(sp)
    80003ef8:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003efa:	fe840593          	addi	a1,s0,-24
    80003efe:	4501                	li	a0,0
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	c42080e7          	jalr	-958(ra) # 80003b42 <argaddr>
    return -1;
    80003f08:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0)
    80003f0a:	02054563          	bltz	a0,80003f34 <sys_kthread_create+0x42>
  if(argaddr(1, &stack) < 0) 
    80003f0e:	fe040593          	addi	a1,s0,-32
    80003f12:	4505                	li	a0,1
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	c2e080e7          	jalr	-978(ra) # 80003b42 <argaddr>
    return -1;
    80003f1c:	57fd                	li	a5,-1
  if(argaddr(1, &stack) < 0) 
    80003f1e:	00054b63          	bltz	a0,80003f34 <sys_kthread_create+0x42>
  return kthread_create((void*)start_func, (void *)stack);
    80003f22:	fe043583          	ld	a1,-32(s0)
    80003f26:	fe843503          	ld	a0,-24(s0)
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	062080e7          	jalr	98(ra) # 80002f8c <kthread_create>
    80003f32:	87aa                	mv	a5,a0
}
    80003f34:	853e                	mv	a0,a5
    80003f36:	60e2                	ld	ra,24(sp)
    80003f38:	6442                	ld	s0,16(sp)
    80003f3a:	6105                	addi	sp,sp,32
    80003f3c:	8082                	ret

0000000080003f3e <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003f3e:	1141                	addi	sp,sp,-16
    80003f40:	e406                	sd	ra,8(sp)
    80003f42:	e022                	sd	s0,0(sp)
    80003f44:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003f46:	ffffe097          	auipc	ra,0xffffe
    80003f4a:	e12080e7          	jalr	-494(ra) # 80001d58 <mykthread>
}
    80003f4e:	5908                	lw	a0,48(a0)
    80003f50:	60a2                	ld	ra,8(sp)
    80003f52:	6402                	ld	s0,0(sp)
    80003f54:	0141                	addi	sp,sp,16
    80003f56:	8082                	ret

0000000080003f58 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003f60:	fec40593          	addi	a1,s0,-20
    80003f64:	4501                	li	a0,0
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	bba080e7          	jalr	-1094(ra) # 80003b20 <argint>
    return -1;
    80003f6e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f70:	00054963          	bltz	a0,80003f82 <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80003f74:	fec42503          	lw	a0,-20(s0)
    80003f78:	fffff097          	auipc	ra,0xfffff
    80003f7c:	a86080e7          	jalr	-1402(ra) # 800029fe <kthread_exit>
  
  return 0;  // not reached
    80003f80:	4781                	li	a5,0
}
    80003f82:	853e                	mv	a0,a5
    80003f84:	60e2                	ld	ra,24(sp)
    80003f86:	6442                	ld	s0,16(sp)
    80003f88:	6105                	addi	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <sys_kthread_join>:

uint64 
sys_kthread_join(void){
    80003f8c:	1101                	addi	sp,sp,-32
    80003f8e:	ec06                	sd	ra,24(sp)
    80003f90:	e822                	sd	s0,16(sp)
    80003f92:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003f94:	fec40593          	addi	a1,s0,-20
    80003f98:	4501                	li	a0,0
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	b86080e7          	jalr	-1146(ra) # 80003b20 <argint>
    return -1;
    80003fa2:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003fa4:	02054563          	bltz	a0,80003fce <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003fa8:	fe040593          	addi	a1,s0,-32
    80003fac:	4505                	li	a0,1
    80003fae:	00000097          	auipc	ra,0x0
    80003fb2:	b94080e7          	jalr	-1132(ra) # 80003b42 <argaddr>
    return -1;
    80003fb6:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003fb8:	00054b63          	bltz	a0,80003fce <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, (int *)status);
    80003fbc:	fe043583          	ld	a1,-32(s0)
    80003fc0:	fec42503          	lw	a0,-20(s0)
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	0cc080e7          	jalr	204(ra) # 80003090 <kthread_join>
    80003fcc:	87aa                	mv	a5,a0
}
    80003fce:	853e                	mv	a0,a5
    80003fd0:	60e2                	ld	ra,24(sp)
    80003fd2:	6442                	ld	s0,16(sp)
    80003fd4:	6105                	addi	sp,sp,32
    80003fd6:	8082                	ret

0000000080003fd8 <sys_bsem_alloc>:




uint64 
sys_bsem_alloc(void){
    80003fd8:	1141                	addi	sp,sp,-16
    80003fda:	e406                	sd	ra,8(sp)
    80003fdc:	e022                	sd	s0,0(sp)
    80003fde:	0800                	addi	s0,sp,16
  return bsem_alloc();
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	d24080e7          	jalr	-732(ra) # 80000d04 <bsem_alloc>
}
    80003fe8:	60a2                	ld	ra,8(sp)
    80003fea:	6402                	ld	s0,0(sp)
    80003fec:	0141                	addi	sp,sp,16
    80003fee:	8082                	ret

0000000080003ff0 <sys_bsem_free>:

uint64 
sys_bsem_free(void){
    80003ff0:	1101                	addi	sp,sp,-32
    80003ff2:	ec06                	sd	ra,24(sp)
    80003ff4:	e822                	sd	s0,16(sp)
    80003ff6:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    80003ff8:	fec40593          	addi	a1,s0,-20
    80003ffc:	4501                	li	a0,0
    80003ffe:	00000097          	auipc	ra,0x0
    80004002:	b22080e7          	jalr	-1246(ra) # 80003b20 <argint>
    return -1;
    80004006:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    80004008:	00054963          	bltz	a0,8000401a <sys_bsem_free+0x2a>
  bsem_free(sem);
    8000400c:	fec42503          	lw	a0,-20(s0)
    80004010:	ffffd097          	auipc	ra,0xffffd
    80004014:	d7a080e7          	jalr	-646(ra) # 80000d8a <bsem_free>
  return 0;
    80004018:	4781                	li	a5,0
}
    8000401a:	853e                	mv	a0,a5
    8000401c:	60e2                	ld	ra,24(sp)
    8000401e:	6442                	ld	s0,16(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <sys_bsem_down>:

uint64 
sys_bsem_down(void){
    80004024:	1101                	addi	sp,sp,-32
    80004026:	ec06                	sd	ra,24(sp)
    80004028:	e822                	sd	s0,16(sp)
    8000402a:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    8000402c:	fec40593          	addi	a1,s0,-20
    80004030:	4501                	li	a0,0
    80004032:	00000097          	auipc	ra,0x0
    80004036:	aee080e7          	jalr	-1298(ra) # 80003b20 <argint>
    return -1;
    8000403a:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    8000403c:	00054963          	bltz	a0,8000404e <sys_bsem_down+0x2a>
  bsem_down(sem);
    80004040:	fec42503          	lw	a0,-20(s0)
    80004044:	ffffd097          	auipc	ra,0xffffd
    80004048:	dd2080e7          	jalr	-558(ra) # 80000e16 <bsem_down>
  return 0;
    8000404c:	4781                	li	a5,0
}
    8000404e:	853e                	mv	a0,a5
    80004050:	60e2                	ld	ra,24(sp)
    80004052:	6442                	ld	s0,16(sp)
    80004054:	6105                	addi	sp,sp,32
    80004056:	8082                	ret

0000000080004058 <sys_bsem_up>:

uint64 
sys_bsem_up(void){
    80004058:	1101                	addi	sp,sp,-32
    8000405a:	ec06                	sd	ra,24(sp)
    8000405c:	e822                	sd	s0,16(sp)
    8000405e:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    80004060:	fec40593          	addi	a1,s0,-20
    80004064:	4501                	li	a0,0
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	aba080e7          	jalr	-1350(ra) # 80003b20 <argint>
    return -1;
    8000406e:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    80004070:	00054963          	bltz	a0,80004082 <sys_bsem_up+0x2a>
      
  bsem_up(sem);
    80004074:	fec42503          	lw	a0,-20(s0)
    80004078:	ffffd097          	auipc	ra,0xffffd
    8000407c:	e6c080e7          	jalr	-404(ra) # 80000ee4 <bsem_up>
  return 0;
    80004080:	4781                	li	a5,0
}
    80004082:	853e                	mv	a0,a5
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	6105                	addi	sp,sp,32
    8000408a:	8082                	ret

000000008000408c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000408c:	7179                	addi	sp,sp,-48
    8000408e:	f406                	sd	ra,40(sp)
    80004090:	f022                	sd	s0,32(sp)
    80004092:	ec26                	sd	s1,24(sp)
    80004094:	e84a                	sd	s2,16(sp)
    80004096:	e44e                	sd	s3,8(sp)
    80004098:	e052                	sd	s4,0(sp)
    8000409a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000409c:	00005597          	auipc	a1,0x5
    800040a0:	54c58593          	addi	a1,a1,1356 # 800095e8 <syscalls+0x108>
    800040a4:	00031517          	auipc	a0,0x31
    800040a8:	c9c50513          	addi	a0,a0,-868 # 80034d40 <bcache>
    800040ac:	ffffd097          	auipc	ra,0xffffd
    800040b0:	a8a080e7          	jalr	-1398(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800040b4:	00039797          	auipc	a5,0x39
    800040b8:	c8c78793          	addi	a5,a5,-884 # 8003cd40 <bcache+0x8000>
    800040bc:	00039717          	auipc	a4,0x39
    800040c0:	eec70713          	addi	a4,a4,-276 # 8003cfa8 <bcache+0x8268>
    800040c4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800040c8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800040cc:	00031497          	auipc	s1,0x31
    800040d0:	c8c48493          	addi	s1,s1,-884 # 80034d58 <bcache+0x18>
    b->next = bcache.head.next;
    800040d4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800040d6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800040d8:	00005a17          	auipc	s4,0x5
    800040dc:	518a0a13          	addi	s4,s4,1304 # 800095f0 <syscalls+0x110>
    b->next = bcache.head.next;
    800040e0:	2b893783          	ld	a5,696(s2)
    800040e4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800040e6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800040ea:	85d2                	mv	a1,s4
    800040ec:	01048513          	addi	a0,s1,16
    800040f0:	00001097          	auipc	ra,0x1
    800040f4:	4c0080e7          	jalr	1216(ra) # 800055b0 <initsleeplock>
    bcache.head.next->prev = b;
    800040f8:	2b893783          	ld	a5,696(s2)
    800040fc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800040fe:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004102:	45848493          	addi	s1,s1,1112
    80004106:	fd349de3          	bne	s1,s3,800040e0 <binit+0x54>
  }
}
    8000410a:	70a2                	ld	ra,40(sp)
    8000410c:	7402                	ld	s0,32(sp)
    8000410e:	64e2                	ld	s1,24(sp)
    80004110:	6942                	ld	s2,16(sp)
    80004112:	69a2                	ld	s3,8(sp)
    80004114:	6a02                	ld	s4,0(sp)
    80004116:	6145                	addi	sp,sp,48
    80004118:	8082                	ret

000000008000411a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000411a:	7179                	addi	sp,sp,-48
    8000411c:	f406                	sd	ra,40(sp)
    8000411e:	f022                	sd	s0,32(sp)
    80004120:	ec26                	sd	s1,24(sp)
    80004122:	e84a                	sd	s2,16(sp)
    80004124:	e44e                	sd	s3,8(sp)
    80004126:	1800                	addi	s0,sp,48
    80004128:	892a                	mv	s2,a0
    8000412a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000412c:	00031517          	auipc	a0,0x31
    80004130:	c1450513          	addi	a0,a0,-1004 # 80034d40 <bcache>
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	ad4080e7          	jalr	-1324(ra) # 80000c08 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000413c:	00039497          	auipc	s1,0x39
    80004140:	ebc4b483          	ld	s1,-324(s1) # 8003cff8 <bcache+0x82b8>
    80004144:	00039797          	auipc	a5,0x39
    80004148:	e6478793          	addi	a5,a5,-412 # 8003cfa8 <bcache+0x8268>
    8000414c:	02f48f63          	beq	s1,a5,8000418a <bread+0x70>
    80004150:	873e                	mv	a4,a5
    80004152:	a021                	j	8000415a <bread+0x40>
    80004154:	68a4                	ld	s1,80(s1)
    80004156:	02e48a63          	beq	s1,a4,8000418a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000415a:	449c                	lw	a5,8(s1)
    8000415c:	ff279ce3          	bne	a5,s2,80004154 <bread+0x3a>
    80004160:	44dc                	lw	a5,12(s1)
    80004162:	ff3799e3          	bne	a5,s3,80004154 <bread+0x3a>
      b->refcnt++;
    80004166:	40bc                	lw	a5,64(s1)
    80004168:	2785                	addiw	a5,a5,1
    8000416a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000416c:	00031517          	auipc	a0,0x31
    80004170:	bd450513          	addi	a0,a0,-1068 # 80034d40 <bcache>
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	b48080e7          	jalr	-1208(ra) # 80000cbc <release>
      acquiresleep(&b->lock);
    8000417c:	01048513          	addi	a0,s1,16
    80004180:	00001097          	auipc	ra,0x1
    80004184:	46a080e7          	jalr	1130(ra) # 800055ea <acquiresleep>
      return b;
    80004188:	a8b9                	j	800041e6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000418a:	00039497          	auipc	s1,0x39
    8000418e:	e664b483          	ld	s1,-410(s1) # 8003cff0 <bcache+0x82b0>
    80004192:	00039797          	auipc	a5,0x39
    80004196:	e1678793          	addi	a5,a5,-490 # 8003cfa8 <bcache+0x8268>
    8000419a:	00f48863          	beq	s1,a5,800041aa <bread+0x90>
    8000419e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800041a0:	40bc                	lw	a5,64(s1)
    800041a2:	cf81                	beqz	a5,800041ba <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800041a4:	64a4                	ld	s1,72(s1)
    800041a6:	fee49de3          	bne	s1,a4,800041a0 <bread+0x86>
  panic("bget: no buffers");
    800041aa:	00005517          	auipc	a0,0x5
    800041ae:	44e50513          	addi	a0,a0,1102 # 800095f8 <syscalls+0x118>
    800041b2:	ffffc097          	auipc	ra,0xffffc
    800041b6:	37c080e7          	jalr	892(ra) # 8000052e <panic>
      b->dev = dev;
    800041ba:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800041be:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800041c2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800041c6:	4785                	li	a5,1
    800041c8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800041ca:	00031517          	auipc	a0,0x31
    800041ce:	b7650513          	addi	a0,a0,-1162 # 80034d40 <bcache>
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	aea080e7          	jalr	-1302(ra) # 80000cbc <release>
      acquiresleep(&b->lock);
    800041da:	01048513          	addi	a0,s1,16
    800041de:	00001097          	auipc	ra,0x1
    800041e2:	40c080e7          	jalr	1036(ra) # 800055ea <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800041e6:	409c                	lw	a5,0(s1)
    800041e8:	cb89                	beqz	a5,800041fa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800041ea:	8526                	mv	a0,s1
    800041ec:	70a2                	ld	ra,40(sp)
    800041ee:	7402                	ld	s0,32(sp)
    800041f0:	64e2                	ld	s1,24(sp)
    800041f2:	6942                	ld	s2,16(sp)
    800041f4:	69a2                	ld	s3,8(sp)
    800041f6:	6145                	addi	sp,sp,48
    800041f8:	8082                	ret
    virtio_disk_rw(b, 0);
    800041fa:	4581                	li	a1,0
    800041fc:	8526                	mv	a0,s1
    800041fe:	00003097          	auipc	ra,0x3
    80004202:	fc8080e7          	jalr	-56(ra) # 800071c6 <virtio_disk_rw>
    b->valid = 1;
    80004206:	4785                	li	a5,1
    80004208:	c09c                	sw	a5,0(s1)
  return b;
    8000420a:	b7c5                	j	800041ea <bread+0xd0>

000000008000420c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000420c:	1101                	addi	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	e426                	sd	s1,8(sp)
    80004214:	1000                	addi	s0,sp,32
    80004216:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004218:	0541                	addi	a0,a0,16
    8000421a:	00001097          	auipc	ra,0x1
    8000421e:	46a080e7          	jalr	1130(ra) # 80005684 <holdingsleep>
    80004222:	cd01                	beqz	a0,8000423a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004224:	4585                	li	a1,1
    80004226:	8526                	mv	a0,s1
    80004228:	00003097          	auipc	ra,0x3
    8000422c:	f9e080e7          	jalr	-98(ra) # 800071c6 <virtio_disk_rw>
}
    80004230:	60e2                	ld	ra,24(sp)
    80004232:	6442                	ld	s0,16(sp)
    80004234:	64a2                	ld	s1,8(sp)
    80004236:	6105                	addi	sp,sp,32
    80004238:	8082                	ret
    panic("bwrite");
    8000423a:	00005517          	auipc	a0,0x5
    8000423e:	3d650513          	addi	a0,a0,982 # 80009610 <syscalls+0x130>
    80004242:	ffffc097          	auipc	ra,0xffffc
    80004246:	2ec080e7          	jalr	748(ra) # 8000052e <panic>

000000008000424a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	e04a                	sd	s2,0(sp)
    80004254:	1000                	addi	s0,sp,32
    80004256:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004258:	01050913          	addi	s2,a0,16
    8000425c:	854a                	mv	a0,s2
    8000425e:	00001097          	auipc	ra,0x1
    80004262:	426080e7          	jalr	1062(ra) # 80005684 <holdingsleep>
    80004266:	c92d                	beqz	a0,800042d8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004268:	854a                	mv	a0,s2
    8000426a:	00001097          	auipc	ra,0x1
    8000426e:	3d6080e7          	jalr	982(ra) # 80005640 <releasesleep>

  acquire(&bcache.lock);
    80004272:	00031517          	auipc	a0,0x31
    80004276:	ace50513          	addi	a0,a0,-1330 # 80034d40 <bcache>
    8000427a:	ffffd097          	auipc	ra,0xffffd
    8000427e:	98e080e7          	jalr	-1650(ra) # 80000c08 <acquire>
  b->refcnt--;
    80004282:	40bc                	lw	a5,64(s1)
    80004284:	37fd                	addiw	a5,a5,-1
    80004286:	0007871b          	sext.w	a4,a5
    8000428a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000428c:	eb05                	bnez	a4,800042bc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000428e:	68bc                	ld	a5,80(s1)
    80004290:	64b8                	ld	a4,72(s1)
    80004292:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004294:	64bc                	ld	a5,72(s1)
    80004296:	68b8                	ld	a4,80(s1)
    80004298:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000429a:	00039797          	auipc	a5,0x39
    8000429e:	aa678793          	addi	a5,a5,-1370 # 8003cd40 <bcache+0x8000>
    800042a2:	2b87b703          	ld	a4,696(a5)
    800042a6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800042a8:	00039717          	auipc	a4,0x39
    800042ac:	d0070713          	addi	a4,a4,-768 # 8003cfa8 <bcache+0x8268>
    800042b0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800042b2:	2b87b703          	ld	a4,696(a5)
    800042b6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800042b8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800042bc:	00031517          	auipc	a0,0x31
    800042c0:	a8450513          	addi	a0,a0,-1404 # 80034d40 <bcache>
    800042c4:	ffffd097          	auipc	ra,0xffffd
    800042c8:	9f8080e7          	jalr	-1544(ra) # 80000cbc <release>
}
    800042cc:	60e2                	ld	ra,24(sp)
    800042ce:	6442                	ld	s0,16(sp)
    800042d0:	64a2                	ld	s1,8(sp)
    800042d2:	6902                	ld	s2,0(sp)
    800042d4:	6105                	addi	sp,sp,32
    800042d6:	8082                	ret
    panic("brelse");
    800042d8:	00005517          	auipc	a0,0x5
    800042dc:	34050513          	addi	a0,a0,832 # 80009618 <syscalls+0x138>
    800042e0:	ffffc097          	auipc	ra,0xffffc
    800042e4:	24e080e7          	jalr	590(ra) # 8000052e <panic>

00000000800042e8 <bpin>:

void
bpin(struct buf *b) {
    800042e8:	1101                	addi	sp,sp,-32
    800042ea:	ec06                	sd	ra,24(sp)
    800042ec:	e822                	sd	s0,16(sp)
    800042ee:	e426                	sd	s1,8(sp)
    800042f0:	1000                	addi	s0,sp,32
    800042f2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800042f4:	00031517          	auipc	a0,0x31
    800042f8:	a4c50513          	addi	a0,a0,-1460 # 80034d40 <bcache>
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	90c080e7          	jalr	-1780(ra) # 80000c08 <acquire>
  b->refcnt++;
    80004304:	40bc                	lw	a5,64(s1)
    80004306:	2785                	addiw	a5,a5,1
    80004308:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000430a:	00031517          	auipc	a0,0x31
    8000430e:	a3650513          	addi	a0,a0,-1482 # 80034d40 <bcache>
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	9aa080e7          	jalr	-1622(ra) # 80000cbc <release>
}
    8000431a:	60e2                	ld	ra,24(sp)
    8000431c:	6442                	ld	s0,16(sp)
    8000431e:	64a2                	ld	s1,8(sp)
    80004320:	6105                	addi	sp,sp,32
    80004322:	8082                	ret

0000000080004324 <bunpin>:

void
bunpin(struct buf *b) {
    80004324:	1101                	addi	sp,sp,-32
    80004326:	ec06                	sd	ra,24(sp)
    80004328:	e822                	sd	s0,16(sp)
    8000432a:	e426                	sd	s1,8(sp)
    8000432c:	1000                	addi	s0,sp,32
    8000432e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004330:	00031517          	auipc	a0,0x31
    80004334:	a1050513          	addi	a0,a0,-1520 # 80034d40 <bcache>
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	8d0080e7          	jalr	-1840(ra) # 80000c08 <acquire>
  b->refcnt--;
    80004340:	40bc                	lw	a5,64(s1)
    80004342:	37fd                	addiw	a5,a5,-1
    80004344:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004346:	00031517          	auipc	a0,0x31
    8000434a:	9fa50513          	addi	a0,a0,-1542 # 80034d40 <bcache>
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	96e080e7          	jalr	-1682(ra) # 80000cbc <release>
}
    80004356:	60e2                	ld	ra,24(sp)
    80004358:	6442                	ld	s0,16(sp)
    8000435a:	64a2                	ld	s1,8(sp)
    8000435c:	6105                	addi	sp,sp,32
    8000435e:	8082                	ret

0000000080004360 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004360:	1101                	addi	sp,sp,-32
    80004362:	ec06                	sd	ra,24(sp)
    80004364:	e822                	sd	s0,16(sp)
    80004366:	e426                	sd	s1,8(sp)
    80004368:	e04a                	sd	s2,0(sp)
    8000436a:	1000                	addi	s0,sp,32
    8000436c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000436e:	00d5d59b          	srliw	a1,a1,0xd
    80004372:	00039797          	auipc	a5,0x39
    80004376:	0aa7a783          	lw	a5,170(a5) # 8003d41c <sb+0x1c>
    8000437a:	9dbd                	addw	a1,a1,a5
    8000437c:	00000097          	auipc	ra,0x0
    80004380:	d9e080e7          	jalr	-610(ra) # 8000411a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004384:	0074f713          	andi	a4,s1,7
    80004388:	4785                	li	a5,1
    8000438a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000438e:	14ce                	slli	s1,s1,0x33
    80004390:	90d9                	srli	s1,s1,0x36
    80004392:	00950733          	add	a4,a0,s1
    80004396:	05874703          	lbu	a4,88(a4)
    8000439a:	00e7f6b3          	and	a3,a5,a4
    8000439e:	c69d                	beqz	a3,800043cc <bfree+0x6c>
    800043a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800043a2:	94aa                	add	s1,s1,a0
    800043a4:	fff7c793          	not	a5,a5
    800043a8:	8ff9                	and	a5,a5,a4
    800043aa:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800043ae:	00001097          	auipc	ra,0x1
    800043b2:	11c080e7          	jalr	284(ra) # 800054ca <log_write>
  brelse(bp);
    800043b6:	854a                	mv	a0,s2
    800043b8:	00000097          	auipc	ra,0x0
    800043bc:	e92080e7          	jalr	-366(ra) # 8000424a <brelse>
}
    800043c0:	60e2                	ld	ra,24(sp)
    800043c2:	6442                	ld	s0,16(sp)
    800043c4:	64a2                	ld	s1,8(sp)
    800043c6:	6902                	ld	s2,0(sp)
    800043c8:	6105                	addi	sp,sp,32
    800043ca:	8082                	ret
    panic("freeing free block");
    800043cc:	00005517          	auipc	a0,0x5
    800043d0:	25450513          	addi	a0,a0,596 # 80009620 <syscalls+0x140>
    800043d4:	ffffc097          	auipc	ra,0xffffc
    800043d8:	15a080e7          	jalr	346(ra) # 8000052e <panic>

00000000800043dc <balloc>:
{
    800043dc:	711d                	addi	sp,sp,-96
    800043de:	ec86                	sd	ra,88(sp)
    800043e0:	e8a2                	sd	s0,80(sp)
    800043e2:	e4a6                	sd	s1,72(sp)
    800043e4:	e0ca                	sd	s2,64(sp)
    800043e6:	fc4e                	sd	s3,56(sp)
    800043e8:	f852                	sd	s4,48(sp)
    800043ea:	f456                	sd	s5,40(sp)
    800043ec:	f05a                	sd	s6,32(sp)
    800043ee:	ec5e                	sd	s7,24(sp)
    800043f0:	e862                	sd	s8,16(sp)
    800043f2:	e466                	sd	s9,8(sp)
    800043f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800043f6:	00039797          	auipc	a5,0x39
    800043fa:	00e7a783          	lw	a5,14(a5) # 8003d404 <sb+0x4>
    800043fe:	cbd1                	beqz	a5,80004492 <balloc+0xb6>
    80004400:	8baa                	mv	s7,a0
    80004402:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004404:	00039b17          	auipc	s6,0x39
    80004408:	ffcb0b13          	addi	s6,s6,-4 # 8003d400 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000440c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000440e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004410:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004412:	6c89                	lui	s9,0x2
    80004414:	a831                	j	80004430 <balloc+0x54>
    brelse(bp);
    80004416:	854a                	mv	a0,s2
    80004418:	00000097          	auipc	ra,0x0
    8000441c:	e32080e7          	jalr	-462(ra) # 8000424a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004420:	015c87bb          	addw	a5,s9,s5
    80004424:	00078a9b          	sext.w	s5,a5
    80004428:	004b2703          	lw	a4,4(s6)
    8000442c:	06eaf363          	bgeu	s5,a4,80004492 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004430:	41fad79b          	sraiw	a5,s5,0x1f
    80004434:	0137d79b          	srliw	a5,a5,0x13
    80004438:	015787bb          	addw	a5,a5,s5
    8000443c:	40d7d79b          	sraiw	a5,a5,0xd
    80004440:	01cb2583          	lw	a1,28(s6)
    80004444:	9dbd                	addw	a1,a1,a5
    80004446:	855e                	mv	a0,s7
    80004448:	00000097          	auipc	ra,0x0
    8000444c:	cd2080e7          	jalr	-814(ra) # 8000411a <bread>
    80004450:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004452:	004b2503          	lw	a0,4(s6)
    80004456:	000a849b          	sext.w	s1,s5
    8000445a:	8662                	mv	a2,s8
    8000445c:	faa4fde3          	bgeu	s1,a0,80004416 <balloc+0x3a>
      m = 1 << (bi % 8);
    80004460:	41f6579b          	sraiw	a5,a2,0x1f
    80004464:	01d7d69b          	srliw	a3,a5,0x1d
    80004468:	00c6873b          	addw	a4,a3,a2
    8000446c:	00777793          	andi	a5,a4,7
    80004470:	9f95                	subw	a5,a5,a3
    80004472:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004476:	4037571b          	sraiw	a4,a4,0x3
    8000447a:	00e906b3          	add	a3,s2,a4
    8000447e:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80004482:	00d7f5b3          	and	a1,a5,a3
    80004486:	cd91                	beqz	a1,800044a2 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004488:	2605                	addiw	a2,a2,1
    8000448a:	2485                	addiw	s1,s1,1
    8000448c:	fd4618e3          	bne	a2,s4,8000445c <balloc+0x80>
    80004490:	b759                	j	80004416 <balloc+0x3a>
  panic("balloc: out of blocks");
    80004492:	00005517          	auipc	a0,0x5
    80004496:	1a650513          	addi	a0,a0,422 # 80009638 <syscalls+0x158>
    8000449a:	ffffc097          	auipc	ra,0xffffc
    8000449e:	094080e7          	jalr	148(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800044a2:	974a                	add	a4,a4,s2
    800044a4:	8fd5                	or	a5,a5,a3
    800044a6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800044aa:	854a                	mv	a0,s2
    800044ac:	00001097          	auipc	ra,0x1
    800044b0:	01e080e7          	jalr	30(ra) # 800054ca <log_write>
        brelse(bp);
    800044b4:	854a                	mv	a0,s2
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	d94080e7          	jalr	-620(ra) # 8000424a <brelse>
  bp = bread(dev, bno);
    800044be:	85a6                	mv	a1,s1
    800044c0:	855e                	mv	a0,s7
    800044c2:	00000097          	auipc	ra,0x0
    800044c6:	c58080e7          	jalr	-936(ra) # 8000411a <bread>
    800044ca:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800044cc:	40000613          	li	a2,1024
    800044d0:	4581                	li	a1,0
    800044d2:	05850513          	addi	a0,a0,88
    800044d6:	ffffd097          	auipc	ra,0xffffd
    800044da:	aa2080e7          	jalr	-1374(ra) # 80000f78 <memset>
  log_write(bp);
    800044de:	854a                	mv	a0,s2
    800044e0:	00001097          	auipc	ra,0x1
    800044e4:	fea080e7          	jalr	-22(ra) # 800054ca <log_write>
  brelse(bp);
    800044e8:	854a                	mv	a0,s2
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	d60080e7          	jalr	-672(ra) # 8000424a <brelse>
}
    800044f2:	8526                	mv	a0,s1
    800044f4:	60e6                	ld	ra,88(sp)
    800044f6:	6446                	ld	s0,80(sp)
    800044f8:	64a6                	ld	s1,72(sp)
    800044fa:	6906                	ld	s2,64(sp)
    800044fc:	79e2                	ld	s3,56(sp)
    800044fe:	7a42                	ld	s4,48(sp)
    80004500:	7aa2                	ld	s5,40(sp)
    80004502:	7b02                	ld	s6,32(sp)
    80004504:	6be2                	ld	s7,24(sp)
    80004506:	6c42                	ld	s8,16(sp)
    80004508:	6ca2                	ld	s9,8(sp)
    8000450a:	6125                	addi	sp,sp,96
    8000450c:	8082                	ret

000000008000450e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000450e:	7179                	addi	sp,sp,-48
    80004510:	f406                	sd	ra,40(sp)
    80004512:	f022                	sd	s0,32(sp)
    80004514:	ec26                	sd	s1,24(sp)
    80004516:	e84a                	sd	s2,16(sp)
    80004518:	e44e                	sd	s3,8(sp)
    8000451a:	e052                	sd	s4,0(sp)
    8000451c:	1800                	addi	s0,sp,48
    8000451e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004520:	47ad                	li	a5,11
    80004522:	04b7fe63          	bgeu	a5,a1,8000457e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004526:	ff45849b          	addiw	s1,a1,-12
    8000452a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000452e:	0ff00793          	li	a5,255
    80004532:	0ae7e463          	bltu	a5,a4,800045da <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004536:	08052583          	lw	a1,128(a0)
    8000453a:	c5b5                	beqz	a1,800045a6 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000453c:	00092503          	lw	a0,0(s2)
    80004540:	00000097          	auipc	ra,0x0
    80004544:	bda080e7          	jalr	-1062(ra) # 8000411a <bread>
    80004548:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000454a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000454e:	02049713          	slli	a4,s1,0x20
    80004552:	01e75593          	srli	a1,a4,0x1e
    80004556:	00b784b3          	add	s1,a5,a1
    8000455a:	0004a983          	lw	s3,0(s1)
    8000455e:	04098e63          	beqz	s3,800045ba <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004562:	8552                	mv	a0,s4
    80004564:	00000097          	auipc	ra,0x0
    80004568:	ce6080e7          	jalr	-794(ra) # 8000424a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000456c:	854e                	mv	a0,s3
    8000456e:	70a2                	ld	ra,40(sp)
    80004570:	7402                	ld	s0,32(sp)
    80004572:	64e2                	ld	s1,24(sp)
    80004574:	6942                	ld	s2,16(sp)
    80004576:	69a2                	ld	s3,8(sp)
    80004578:	6a02                	ld	s4,0(sp)
    8000457a:	6145                	addi	sp,sp,48
    8000457c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000457e:	02059793          	slli	a5,a1,0x20
    80004582:	01e7d593          	srli	a1,a5,0x1e
    80004586:	00b504b3          	add	s1,a0,a1
    8000458a:	0504a983          	lw	s3,80(s1)
    8000458e:	fc099fe3          	bnez	s3,8000456c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004592:	4108                	lw	a0,0(a0)
    80004594:	00000097          	auipc	ra,0x0
    80004598:	e48080e7          	jalr	-440(ra) # 800043dc <balloc>
    8000459c:	0005099b          	sext.w	s3,a0
    800045a0:	0534a823          	sw	s3,80(s1)
    800045a4:	b7e1                	j	8000456c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800045a6:	4108                	lw	a0,0(a0)
    800045a8:	00000097          	auipc	ra,0x0
    800045ac:	e34080e7          	jalr	-460(ra) # 800043dc <balloc>
    800045b0:	0005059b          	sext.w	a1,a0
    800045b4:	08b92023          	sw	a1,128(s2)
    800045b8:	b751                	j	8000453c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800045ba:	00092503          	lw	a0,0(s2)
    800045be:	00000097          	auipc	ra,0x0
    800045c2:	e1e080e7          	jalr	-482(ra) # 800043dc <balloc>
    800045c6:	0005099b          	sext.w	s3,a0
    800045ca:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800045ce:	8552                	mv	a0,s4
    800045d0:	00001097          	auipc	ra,0x1
    800045d4:	efa080e7          	jalr	-262(ra) # 800054ca <log_write>
    800045d8:	b769                	j	80004562 <bmap+0x54>
  panic("bmap: out of range");
    800045da:	00005517          	auipc	a0,0x5
    800045de:	07650513          	addi	a0,a0,118 # 80009650 <syscalls+0x170>
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	f4c080e7          	jalr	-180(ra) # 8000052e <panic>

00000000800045ea <iget>:
{
    800045ea:	7179                	addi	sp,sp,-48
    800045ec:	f406                	sd	ra,40(sp)
    800045ee:	f022                	sd	s0,32(sp)
    800045f0:	ec26                	sd	s1,24(sp)
    800045f2:	e84a                	sd	s2,16(sp)
    800045f4:	e44e                	sd	s3,8(sp)
    800045f6:	e052                	sd	s4,0(sp)
    800045f8:	1800                	addi	s0,sp,48
    800045fa:	89aa                	mv	s3,a0
    800045fc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800045fe:	00039517          	auipc	a0,0x39
    80004602:	e2250513          	addi	a0,a0,-478 # 8003d420 <itable>
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	602080e7          	jalr	1538(ra) # 80000c08 <acquire>
  empty = 0;
    8000460e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004610:	00039497          	auipc	s1,0x39
    80004614:	e2848493          	addi	s1,s1,-472 # 8003d438 <itable+0x18>
    80004618:	0003b697          	auipc	a3,0x3b
    8000461c:	8b068693          	addi	a3,a3,-1872 # 8003eec8 <log>
    80004620:	a039                	j	8000462e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004622:	02090b63          	beqz	s2,80004658 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004626:	08848493          	addi	s1,s1,136
    8000462a:	02d48a63          	beq	s1,a3,8000465e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000462e:	449c                	lw	a5,8(s1)
    80004630:	fef059e3          	blez	a5,80004622 <iget+0x38>
    80004634:	4098                	lw	a4,0(s1)
    80004636:	ff3716e3          	bne	a4,s3,80004622 <iget+0x38>
    8000463a:	40d8                	lw	a4,4(s1)
    8000463c:	ff4713e3          	bne	a4,s4,80004622 <iget+0x38>
      ip->ref++;
    80004640:	2785                	addiw	a5,a5,1
    80004642:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004644:	00039517          	auipc	a0,0x39
    80004648:	ddc50513          	addi	a0,a0,-548 # 8003d420 <itable>
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	670080e7          	jalr	1648(ra) # 80000cbc <release>
      return ip;
    80004654:	8926                	mv	s2,s1
    80004656:	a03d                	j	80004684 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004658:	f7f9                	bnez	a5,80004626 <iget+0x3c>
    8000465a:	8926                	mv	s2,s1
    8000465c:	b7e9                	j	80004626 <iget+0x3c>
  if(empty == 0)
    8000465e:	02090c63          	beqz	s2,80004696 <iget+0xac>
  ip->dev = dev;
    80004662:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004666:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000466a:	4785                	li	a5,1
    8000466c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004670:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004674:	00039517          	auipc	a0,0x39
    80004678:	dac50513          	addi	a0,a0,-596 # 8003d420 <itable>
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	640080e7          	jalr	1600(ra) # 80000cbc <release>
}
    80004684:	854a                	mv	a0,s2
    80004686:	70a2                	ld	ra,40(sp)
    80004688:	7402                	ld	s0,32(sp)
    8000468a:	64e2                	ld	s1,24(sp)
    8000468c:	6942                	ld	s2,16(sp)
    8000468e:	69a2                	ld	s3,8(sp)
    80004690:	6a02                	ld	s4,0(sp)
    80004692:	6145                	addi	sp,sp,48
    80004694:	8082                	ret
    panic("iget: no inodes");
    80004696:	00005517          	auipc	a0,0x5
    8000469a:	fd250513          	addi	a0,a0,-46 # 80009668 <syscalls+0x188>
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	e90080e7          	jalr	-368(ra) # 8000052e <panic>

00000000800046a6 <fsinit>:
fsinit(int dev) {
    800046a6:	7179                	addi	sp,sp,-48
    800046a8:	f406                	sd	ra,40(sp)
    800046aa:	f022                	sd	s0,32(sp)
    800046ac:	ec26                	sd	s1,24(sp)
    800046ae:	e84a                	sd	s2,16(sp)
    800046b0:	e44e                	sd	s3,8(sp)
    800046b2:	1800                	addi	s0,sp,48
    800046b4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800046b6:	4585                	li	a1,1
    800046b8:	00000097          	auipc	ra,0x0
    800046bc:	a62080e7          	jalr	-1438(ra) # 8000411a <bread>
    800046c0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800046c2:	00039997          	auipc	s3,0x39
    800046c6:	d3e98993          	addi	s3,s3,-706 # 8003d400 <sb>
    800046ca:	02000613          	li	a2,32
    800046ce:	05850593          	addi	a1,a0,88
    800046d2:	854e                	mv	a0,s3
    800046d4:	ffffd097          	auipc	ra,0xffffd
    800046d8:	900080e7          	jalr	-1792(ra) # 80000fd4 <memmove>
  brelse(bp);
    800046dc:	8526                	mv	a0,s1
    800046de:	00000097          	auipc	ra,0x0
    800046e2:	b6c080e7          	jalr	-1172(ra) # 8000424a <brelse>
  if(sb.magic != FSMAGIC)
    800046e6:	0009a703          	lw	a4,0(s3)
    800046ea:	102037b7          	lui	a5,0x10203
    800046ee:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800046f2:	02f71263          	bne	a4,a5,80004716 <fsinit+0x70>
  initlog(dev, &sb);
    800046f6:	00039597          	auipc	a1,0x39
    800046fa:	d0a58593          	addi	a1,a1,-758 # 8003d400 <sb>
    800046fe:	854a                	mv	a0,s2
    80004700:	00001097          	auipc	ra,0x1
    80004704:	b4c080e7          	jalr	-1204(ra) # 8000524c <initlog>
}
    80004708:	70a2                	ld	ra,40(sp)
    8000470a:	7402                	ld	s0,32(sp)
    8000470c:	64e2                	ld	s1,24(sp)
    8000470e:	6942                	ld	s2,16(sp)
    80004710:	69a2                	ld	s3,8(sp)
    80004712:	6145                	addi	sp,sp,48
    80004714:	8082                	ret
    panic("invalid file system");
    80004716:	00005517          	auipc	a0,0x5
    8000471a:	f6250513          	addi	a0,a0,-158 # 80009678 <syscalls+0x198>
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	e10080e7          	jalr	-496(ra) # 8000052e <panic>

0000000080004726 <iinit>:
{
    80004726:	7179                	addi	sp,sp,-48
    80004728:	f406                	sd	ra,40(sp)
    8000472a:	f022                	sd	s0,32(sp)
    8000472c:	ec26                	sd	s1,24(sp)
    8000472e:	e84a                	sd	s2,16(sp)
    80004730:	e44e                	sd	s3,8(sp)
    80004732:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004734:	00005597          	auipc	a1,0x5
    80004738:	f5c58593          	addi	a1,a1,-164 # 80009690 <syscalls+0x1b0>
    8000473c:	00039517          	auipc	a0,0x39
    80004740:	ce450513          	addi	a0,a0,-796 # 8003d420 <itable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	3f2080e7          	jalr	1010(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000474c:	00039497          	auipc	s1,0x39
    80004750:	cfc48493          	addi	s1,s1,-772 # 8003d448 <itable+0x28>
    80004754:	0003a997          	auipc	s3,0x3a
    80004758:	78498993          	addi	s3,s3,1924 # 8003eed8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000475c:	00005917          	auipc	s2,0x5
    80004760:	f3c90913          	addi	s2,s2,-196 # 80009698 <syscalls+0x1b8>
    80004764:	85ca                	mv	a1,s2
    80004766:	8526                	mv	a0,s1
    80004768:	00001097          	auipc	ra,0x1
    8000476c:	e48080e7          	jalr	-440(ra) # 800055b0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004770:	08848493          	addi	s1,s1,136
    80004774:	ff3498e3          	bne	s1,s3,80004764 <iinit+0x3e>
}
    80004778:	70a2                	ld	ra,40(sp)
    8000477a:	7402                	ld	s0,32(sp)
    8000477c:	64e2                	ld	s1,24(sp)
    8000477e:	6942                	ld	s2,16(sp)
    80004780:	69a2                	ld	s3,8(sp)
    80004782:	6145                	addi	sp,sp,48
    80004784:	8082                	ret

0000000080004786 <ialloc>:
{
    80004786:	715d                	addi	sp,sp,-80
    80004788:	e486                	sd	ra,72(sp)
    8000478a:	e0a2                	sd	s0,64(sp)
    8000478c:	fc26                	sd	s1,56(sp)
    8000478e:	f84a                	sd	s2,48(sp)
    80004790:	f44e                	sd	s3,40(sp)
    80004792:	f052                	sd	s4,32(sp)
    80004794:	ec56                	sd	s5,24(sp)
    80004796:	e85a                	sd	s6,16(sp)
    80004798:	e45e                	sd	s7,8(sp)
    8000479a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000479c:	00039717          	auipc	a4,0x39
    800047a0:	c7072703          	lw	a4,-912(a4) # 8003d40c <sb+0xc>
    800047a4:	4785                	li	a5,1
    800047a6:	04e7fa63          	bgeu	a5,a4,800047fa <ialloc+0x74>
    800047aa:	8aaa                	mv	s5,a0
    800047ac:	8bae                	mv	s7,a1
    800047ae:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800047b0:	00039a17          	auipc	s4,0x39
    800047b4:	c50a0a13          	addi	s4,s4,-944 # 8003d400 <sb>
    800047b8:	00048b1b          	sext.w	s6,s1
    800047bc:	0044d793          	srli	a5,s1,0x4
    800047c0:	018a2583          	lw	a1,24(s4)
    800047c4:	9dbd                	addw	a1,a1,a5
    800047c6:	8556                	mv	a0,s5
    800047c8:	00000097          	auipc	ra,0x0
    800047cc:	952080e7          	jalr	-1710(ra) # 8000411a <bread>
    800047d0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800047d2:	05850993          	addi	s3,a0,88
    800047d6:	00f4f793          	andi	a5,s1,15
    800047da:	079a                	slli	a5,a5,0x6
    800047dc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800047de:	00099783          	lh	a5,0(s3)
    800047e2:	c785                	beqz	a5,8000480a <ialloc+0x84>
    brelse(bp);
    800047e4:	00000097          	auipc	ra,0x0
    800047e8:	a66080e7          	jalr	-1434(ra) # 8000424a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800047ec:	0485                	addi	s1,s1,1
    800047ee:	00ca2703          	lw	a4,12(s4)
    800047f2:	0004879b          	sext.w	a5,s1
    800047f6:	fce7e1e3          	bltu	a5,a4,800047b8 <ialloc+0x32>
  panic("ialloc: no inodes");
    800047fa:	00005517          	auipc	a0,0x5
    800047fe:	ea650513          	addi	a0,a0,-346 # 800096a0 <syscalls+0x1c0>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	d2c080e7          	jalr	-724(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    8000480a:	04000613          	li	a2,64
    8000480e:	4581                	li	a1,0
    80004810:	854e                	mv	a0,s3
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	766080e7          	jalr	1894(ra) # 80000f78 <memset>
      dip->type = type;
    8000481a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000481e:	854a                	mv	a0,s2
    80004820:	00001097          	auipc	ra,0x1
    80004824:	caa080e7          	jalr	-854(ra) # 800054ca <log_write>
      brelse(bp);
    80004828:	854a                	mv	a0,s2
    8000482a:	00000097          	auipc	ra,0x0
    8000482e:	a20080e7          	jalr	-1504(ra) # 8000424a <brelse>
      return iget(dev, inum);
    80004832:	85da                	mv	a1,s6
    80004834:	8556                	mv	a0,s5
    80004836:	00000097          	auipc	ra,0x0
    8000483a:	db4080e7          	jalr	-588(ra) # 800045ea <iget>
}
    8000483e:	60a6                	ld	ra,72(sp)
    80004840:	6406                	ld	s0,64(sp)
    80004842:	74e2                	ld	s1,56(sp)
    80004844:	7942                	ld	s2,48(sp)
    80004846:	79a2                	ld	s3,40(sp)
    80004848:	7a02                	ld	s4,32(sp)
    8000484a:	6ae2                	ld	s5,24(sp)
    8000484c:	6b42                	ld	s6,16(sp)
    8000484e:	6ba2                	ld	s7,8(sp)
    80004850:	6161                	addi	sp,sp,80
    80004852:	8082                	ret

0000000080004854 <iupdate>:
{
    80004854:	1101                	addi	sp,sp,-32
    80004856:	ec06                	sd	ra,24(sp)
    80004858:	e822                	sd	s0,16(sp)
    8000485a:	e426                	sd	s1,8(sp)
    8000485c:	e04a                	sd	s2,0(sp)
    8000485e:	1000                	addi	s0,sp,32
    80004860:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004862:	415c                	lw	a5,4(a0)
    80004864:	0047d79b          	srliw	a5,a5,0x4
    80004868:	00039597          	auipc	a1,0x39
    8000486c:	bb05a583          	lw	a1,-1104(a1) # 8003d418 <sb+0x18>
    80004870:	9dbd                	addw	a1,a1,a5
    80004872:	4108                	lw	a0,0(a0)
    80004874:	00000097          	auipc	ra,0x0
    80004878:	8a6080e7          	jalr	-1882(ra) # 8000411a <bread>
    8000487c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000487e:	05850793          	addi	a5,a0,88
    80004882:	40c8                	lw	a0,4(s1)
    80004884:	893d                	andi	a0,a0,15
    80004886:	051a                	slli	a0,a0,0x6
    80004888:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000488a:	04449703          	lh	a4,68(s1)
    8000488e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004892:	04649703          	lh	a4,70(s1)
    80004896:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000489a:	04849703          	lh	a4,72(s1)
    8000489e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800048a2:	04a49703          	lh	a4,74(s1)
    800048a6:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800048aa:	44f8                	lw	a4,76(s1)
    800048ac:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800048ae:	03400613          	li	a2,52
    800048b2:	05048593          	addi	a1,s1,80
    800048b6:	0531                	addi	a0,a0,12
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	71c080e7          	jalr	1820(ra) # 80000fd4 <memmove>
  log_write(bp);
    800048c0:	854a                	mv	a0,s2
    800048c2:	00001097          	auipc	ra,0x1
    800048c6:	c08080e7          	jalr	-1016(ra) # 800054ca <log_write>
  brelse(bp);
    800048ca:	854a                	mv	a0,s2
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	97e080e7          	jalr	-1666(ra) # 8000424a <brelse>
}
    800048d4:	60e2                	ld	ra,24(sp)
    800048d6:	6442                	ld	s0,16(sp)
    800048d8:	64a2                	ld	s1,8(sp)
    800048da:	6902                	ld	s2,0(sp)
    800048dc:	6105                	addi	sp,sp,32
    800048de:	8082                	ret

00000000800048e0 <idup>:
{
    800048e0:	1101                	addi	sp,sp,-32
    800048e2:	ec06                	sd	ra,24(sp)
    800048e4:	e822                	sd	s0,16(sp)
    800048e6:	e426                	sd	s1,8(sp)
    800048e8:	1000                	addi	s0,sp,32
    800048ea:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800048ec:	00039517          	auipc	a0,0x39
    800048f0:	b3450513          	addi	a0,a0,-1228 # 8003d420 <itable>
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	314080e7          	jalr	788(ra) # 80000c08 <acquire>
  ip->ref++;
    800048fc:	449c                	lw	a5,8(s1)
    800048fe:	2785                	addiw	a5,a5,1
    80004900:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004902:	00039517          	auipc	a0,0x39
    80004906:	b1e50513          	addi	a0,a0,-1250 # 8003d420 <itable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	3b2080e7          	jalr	946(ra) # 80000cbc <release>
}
    80004912:	8526                	mv	a0,s1
    80004914:	60e2                	ld	ra,24(sp)
    80004916:	6442                	ld	s0,16(sp)
    80004918:	64a2                	ld	s1,8(sp)
    8000491a:	6105                	addi	sp,sp,32
    8000491c:	8082                	ret

000000008000491e <ilock>:
{
    8000491e:	1101                	addi	sp,sp,-32
    80004920:	ec06                	sd	ra,24(sp)
    80004922:	e822                	sd	s0,16(sp)
    80004924:	e426                	sd	s1,8(sp)
    80004926:	e04a                	sd	s2,0(sp)
    80004928:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000492a:	c115                	beqz	a0,8000494e <ilock+0x30>
    8000492c:	84aa                	mv	s1,a0
    8000492e:	451c                	lw	a5,8(a0)
    80004930:	00f05f63          	blez	a5,8000494e <ilock+0x30>
  acquiresleep(&ip->lock);
    80004934:	0541                	addi	a0,a0,16
    80004936:	00001097          	auipc	ra,0x1
    8000493a:	cb4080e7          	jalr	-844(ra) # 800055ea <acquiresleep>
  if(ip->valid == 0){
    8000493e:	40bc                	lw	a5,64(s1)
    80004940:	cf99                	beqz	a5,8000495e <ilock+0x40>
}
    80004942:	60e2                	ld	ra,24(sp)
    80004944:	6442                	ld	s0,16(sp)
    80004946:	64a2                	ld	s1,8(sp)
    80004948:	6902                	ld	s2,0(sp)
    8000494a:	6105                	addi	sp,sp,32
    8000494c:	8082                	ret
    panic("ilock");
    8000494e:	00005517          	auipc	a0,0x5
    80004952:	d6a50513          	addi	a0,a0,-662 # 800096b8 <syscalls+0x1d8>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	bd8080e7          	jalr	-1064(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000495e:	40dc                	lw	a5,4(s1)
    80004960:	0047d79b          	srliw	a5,a5,0x4
    80004964:	00039597          	auipc	a1,0x39
    80004968:	ab45a583          	lw	a1,-1356(a1) # 8003d418 <sb+0x18>
    8000496c:	9dbd                	addw	a1,a1,a5
    8000496e:	4088                	lw	a0,0(s1)
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	7aa080e7          	jalr	1962(ra) # 8000411a <bread>
    80004978:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000497a:	05850593          	addi	a1,a0,88
    8000497e:	40dc                	lw	a5,4(s1)
    80004980:	8bbd                	andi	a5,a5,15
    80004982:	079a                	slli	a5,a5,0x6
    80004984:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004986:	00059783          	lh	a5,0(a1)
    8000498a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000498e:	00259783          	lh	a5,2(a1)
    80004992:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004996:	00459783          	lh	a5,4(a1)
    8000499a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000499e:	00659783          	lh	a5,6(a1)
    800049a2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800049a6:	459c                	lw	a5,8(a1)
    800049a8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800049aa:	03400613          	li	a2,52
    800049ae:	05b1                	addi	a1,a1,12
    800049b0:	05048513          	addi	a0,s1,80
    800049b4:	ffffc097          	auipc	ra,0xffffc
    800049b8:	620080e7          	jalr	1568(ra) # 80000fd4 <memmove>
    brelse(bp);
    800049bc:	854a                	mv	a0,s2
    800049be:	00000097          	auipc	ra,0x0
    800049c2:	88c080e7          	jalr	-1908(ra) # 8000424a <brelse>
    ip->valid = 1;
    800049c6:	4785                	li	a5,1
    800049c8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800049ca:	04449783          	lh	a5,68(s1)
    800049ce:	fbb5                	bnez	a5,80004942 <ilock+0x24>
      panic("ilock: no type");
    800049d0:	00005517          	auipc	a0,0x5
    800049d4:	cf050513          	addi	a0,a0,-784 # 800096c0 <syscalls+0x1e0>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	b56080e7          	jalr	-1194(ra) # 8000052e <panic>

00000000800049e0 <iunlock>:
{
    800049e0:	1101                	addi	sp,sp,-32
    800049e2:	ec06                	sd	ra,24(sp)
    800049e4:	e822                	sd	s0,16(sp)
    800049e6:	e426                	sd	s1,8(sp)
    800049e8:	e04a                	sd	s2,0(sp)
    800049ea:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800049ec:	c905                	beqz	a0,80004a1c <iunlock+0x3c>
    800049ee:	84aa                	mv	s1,a0
    800049f0:	01050913          	addi	s2,a0,16
    800049f4:	854a                	mv	a0,s2
    800049f6:	00001097          	auipc	ra,0x1
    800049fa:	c8e080e7          	jalr	-882(ra) # 80005684 <holdingsleep>
    800049fe:	cd19                	beqz	a0,80004a1c <iunlock+0x3c>
    80004a00:	449c                	lw	a5,8(s1)
    80004a02:	00f05d63          	blez	a5,80004a1c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004a06:	854a                	mv	a0,s2
    80004a08:	00001097          	auipc	ra,0x1
    80004a0c:	c38080e7          	jalr	-968(ra) # 80005640 <releasesleep>
}
    80004a10:	60e2                	ld	ra,24(sp)
    80004a12:	6442                	ld	s0,16(sp)
    80004a14:	64a2                	ld	s1,8(sp)
    80004a16:	6902                	ld	s2,0(sp)
    80004a18:	6105                	addi	sp,sp,32
    80004a1a:	8082                	ret
    panic("iunlock");
    80004a1c:	00005517          	auipc	a0,0x5
    80004a20:	cb450513          	addi	a0,a0,-844 # 800096d0 <syscalls+0x1f0>
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	b0a080e7          	jalr	-1270(ra) # 8000052e <panic>

0000000080004a2c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004a2c:	7179                	addi	sp,sp,-48
    80004a2e:	f406                	sd	ra,40(sp)
    80004a30:	f022                	sd	s0,32(sp)
    80004a32:	ec26                	sd	s1,24(sp)
    80004a34:	e84a                	sd	s2,16(sp)
    80004a36:	e44e                	sd	s3,8(sp)
    80004a38:	e052                	sd	s4,0(sp)
    80004a3a:	1800                	addi	s0,sp,48
    80004a3c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004a3e:	05050493          	addi	s1,a0,80
    80004a42:	08050913          	addi	s2,a0,128
    80004a46:	a021                	j	80004a4e <itrunc+0x22>
    80004a48:	0491                	addi	s1,s1,4
    80004a4a:	01248d63          	beq	s1,s2,80004a64 <itrunc+0x38>
    if(ip->addrs[i]){
    80004a4e:	408c                	lw	a1,0(s1)
    80004a50:	dde5                	beqz	a1,80004a48 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004a52:	0009a503          	lw	a0,0(s3)
    80004a56:	00000097          	auipc	ra,0x0
    80004a5a:	90a080e7          	jalr	-1782(ra) # 80004360 <bfree>
      ip->addrs[i] = 0;
    80004a5e:	0004a023          	sw	zero,0(s1)
    80004a62:	b7dd                	j	80004a48 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004a64:	0809a583          	lw	a1,128(s3)
    80004a68:	e185                	bnez	a1,80004a88 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004a6a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004a6e:	854e                	mv	a0,s3
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	de4080e7          	jalr	-540(ra) # 80004854 <iupdate>
}
    80004a78:	70a2                	ld	ra,40(sp)
    80004a7a:	7402                	ld	s0,32(sp)
    80004a7c:	64e2                	ld	s1,24(sp)
    80004a7e:	6942                	ld	s2,16(sp)
    80004a80:	69a2                	ld	s3,8(sp)
    80004a82:	6a02                	ld	s4,0(sp)
    80004a84:	6145                	addi	sp,sp,48
    80004a86:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004a88:	0009a503          	lw	a0,0(s3)
    80004a8c:	fffff097          	auipc	ra,0xfffff
    80004a90:	68e080e7          	jalr	1678(ra) # 8000411a <bread>
    80004a94:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004a96:	05850493          	addi	s1,a0,88
    80004a9a:	45850913          	addi	s2,a0,1112
    80004a9e:	a021                	j	80004aa6 <itrunc+0x7a>
    80004aa0:	0491                	addi	s1,s1,4
    80004aa2:	01248b63          	beq	s1,s2,80004ab8 <itrunc+0x8c>
      if(a[j])
    80004aa6:	408c                	lw	a1,0(s1)
    80004aa8:	dde5                	beqz	a1,80004aa0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004aaa:	0009a503          	lw	a0,0(s3)
    80004aae:	00000097          	auipc	ra,0x0
    80004ab2:	8b2080e7          	jalr	-1870(ra) # 80004360 <bfree>
    80004ab6:	b7ed                	j	80004aa0 <itrunc+0x74>
    brelse(bp);
    80004ab8:	8552                	mv	a0,s4
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	790080e7          	jalr	1936(ra) # 8000424a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004ac2:	0809a583          	lw	a1,128(s3)
    80004ac6:	0009a503          	lw	a0,0(s3)
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	896080e7          	jalr	-1898(ra) # 80004360 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004ad2:	0809a023          	sw	zero,128(s3)
    80004ad6:	bf51                	j	80004a6a <itrunc+0x3e>

0000000080004ad8 <iput>:
{
    80004ad8:	1101                	addi	sp,sp,-32
    80004ada:	ec06                	sd	ra,24(sp)
    80004adc:	e822                	sd	s0,16(sp)
    80004ade:	e426                	sd	s1,8(sp)
    80004ae0:	e04a                	sd	s2,0(sp)
    80004ae2:	1000                	addi	s0,sp,32
    80004ae4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004ae6:	00039517          	auipc	a0,0x39
    80004aea:	93a50513          	addi	a0,a0,-1734 # 8003d420 <itable>
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	11a080e7          	jalr	282(ra) # 80000c08 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004af6:	4498                	lw	a4,8(s1)
    80004af8:	4785                	li	a5,1
    80004afa:	02f70363          	beq	a4,a5,80004b20 <iput+0x48>
  ip->ref--;
    80004afe:	449c                	lw	a5,8(s1)
    80004b00:	37fd                	addiw	a5,a5,-1
    80004b02:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004b04:	00039517          	auipc	a0,0x39
    80004b08:	91c50513          	addi	a0,a0,-1764 # 8003d420 <itable>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	1b0080e7          	jalr	432(ra) # 80000cbc <release>
}
    80004b14:	60e2                	ld	ra,24(sp)
    80004b16:	6442                	ld	s0,16(sp)
    80004b18:	64a2                	ld	s1,8(sp)
    80004b1a:	6902                	ld	s2,0(sp)
    80004b1c:	6105                	addi	sp,sp,32
    80004b1e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004b20:	40bc                	lw	a5,64(s1)
    80004b22:	dff1                	beqz	a5,80004afe <iput+0x26>
    80004b24:	04a49783          	lh	a5,74(s1)
    80004b28:	fbf9                	bnez	a5,80004afe <iput+0x26>
    acquiresleep(&ip->lock);
    80004b2a:	01048913          	addi	s2,s1,16
    80004b2e:	854a                	mv	a0,s2
    80004b30:	00001097          	auipc	ra,0x1
    80004b34:	aba080e7          	jalr	-1350(ra) # 800055ea <acquiresleep>
    release(&itable.lock);
    80004b38:	00039517          	auipc	a0,0x39
    80004b3c:	8e850513          	addi	a0,a0,-1816 # 8003d420 <itable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	17c080e7          	jalr	380(ra) # 80000cbc <release>
    itrunc(ip);
    80004b48:	8526                	mv	a0,s1
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	ee2080e7          	jalr	-286(ra) # 80004a2c <itrunc>
    ip->type = 0;
    80004b52:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004b56:	8526                	mv	a0,s1
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	cfc080e7          	jalr	-772(ra) # 80004854 <iupdate>
    ip->valid = 0;
    80004b60:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004b64:	854a                	mv	a0,s2
    80004b66:	00001097          	auipc	ra,0x1
    80004b6a:	ada080e7          	jalr	-1318(ra) # 80005640 <releasesleep>
    acquire(&itable.lock);
    80004b6e:	00039517          	auipc	a0,0x39
    80004b72:	8b250513          	addi	a0,a0,-1870 # 8003d420 <itable>
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	092080e7          	jalr	146(ra) # 80000c08 <acquire>
    80004b7e:	b741                	j	80004afe <iput+0x26>

0000000080004b80 <iunlockput>:
{
    80004b80:	1101                	addi	sp,sp,-32
    80004b82:	ec06                	sd	ra,24(sp)
    80004b84:	e822                	sd	s0,16(sp)
    80004b86:	e426                	sd	s1,8(sp)
    80004b88:	1000                	addi	s0,sp,32
    80004b8a:	84aa                	mv	s1,a0
  iunlock(ip);
    80004b8c:	00000097          	auipc	ra,0x0
    80004b90:	e54080e7          	jalr	-428(ra) # 800049e0 <iunlock>
  iput(ip);
    80004b94:	8526                	mv	a0,s1
    80004b96:	00000097          	auipc	ra,0x0
    80004b9a:	f42080e7          	jalr	-190(ra) # 80004ad8 <iput>
}
    80004b9e:	60e2                	ld	ra,24(sp)
    80004ba0:	6442                	ld	s0,16(sp)
    80004ba2:	64a2                	ld	s1,8(sp)
    80004ba4:	6105                	addi	sp,sp,32
    80004ba6:	8082                	ret

0000000080004ba8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004ba8:	1141                	addi	sp,sp,-16
    80004baa:	e422                	sd	s0,8(sp)
    80004bac:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004bae:	411c                	lw	a5,0(a0)
    80004bb0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004bb2:	415c                	lw	a5,4(a0)
    80004bb4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004bb6:	04451783          	lh	a5,68(a0)
    80004bba:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004bbe:	04a51783          	lh	a5,74(a0)
    80004bc2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004bc6:	04c56783          	lwu	a5,76(a0)
    80004bca:	e99c                	sd	a5,16(a1)
}
    80004bcc:	6422                	ld	s0,8(sp)
    80004bce:	0141                	addi	sp,sp,16
    80004bd0:	8082                	ret

0000000080004bd2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004bd2:	457c                	lw	a5,76(a0)
    80004bd4:	0ed7e963          	bltu	a5,a3,80004cc6 <readi+0xf4>
{
    80004bd8:	7159                	addi	sp,sp,-112
    80004bda:	f486                	sd	ra,104(sp)
    80004bdc:	f0a2                	sd	s0,96(sp)
    80004bde:	eca6                	sd	s1,88(sp)
    80004be0:	e8ca                	sd	s2,80(sp)
    80004be2:	e4ce                	sd	s3,72(sp)
    80004be4:	e0d2                	sd	s4,64(sp)
    80004be6:	fc56                	sd	s5,56(sp)
    80004be8:	f85a                	sd	s6,48(sp)
    80004bea:	f45e                	sd	s7,40(sp)
    80004bec:	f062                	sd	s8,32(sp)
    80004bee:	ec66                	sd	s9,24(sp)
    80004bf0:	e86a                	sd	s10,16(sp)
    80004bf2:	e46e                	sd	s11,8(sp)
    80004bf4:	1880                	addi	s0,sp,112
    80004bf6:	8baa                	mv	s7,a0
    80004bf8:	8c2e                	mv	s8,a1
    80004bfa:	8ab2                	mv	s5,a2
    80004bfc:	84b6                	mv	s1,a3
    80004bfe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004c00:	9f35                	addw	a4,a4,a3
    return 0;
    80004c02:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004c04:	0ad76063          	bltu	a4,a3,80004ca4 <readi+0xd2>
  if(off + n > ip->size)
    80004c08:	00e7f463          	bgeu	a5,a4,80004c10 <readi+0x3e>
    n = ip->size - off;
    80004c0c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004c10:	0a0b0963          	beqz	s6,80004cc2 <readi+0xf0>
    80004c14:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c16:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004c1a:	5cfd                	li	s9,-1
    80004c1c:	a82d                	j	80004c56 <readi+0x84>
    80004c1e:	020a1d93          	slli	s11,s4,0x20
    80004c22:	020ddd93          	srli	s11,s11,0x20
    80004c26:	05890793          	addi	a5,s2,88
    80004c2a:	86ee                	mv	a3,s11
    80004c2c:	963e                	add	a2,a2,a5
    80004c2e:	85d6                	mv	a1,s5
    80004c30:	8562                	mv	a0,s8
    80004c32:	ffffe097          	auipc	ra,0xffffe
    80004c36:	edc080e7          	jalr	-292(ra) # 80002b0e <either_copyout>
    80004c3a:	05950d63          	beq	a0,s9,80004c94 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004c3e:	854a                	mv	a0,s2
    80004c40:	fffff097          	auipc	ra,0xfffff
    80004c44:	60a080e7          	jalr	1546(ra) # 8000424a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004c48:	013a09bb          	addw	s3,s4,s3
    80004c4c:	009a04bb          	addw	s1,s4,s1
    80004c50:	9aee                	add	s5,s5,s11
    80004c52:	0569f763          	bgeu	s3,s6,80004ca0 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004c56:	000ba903          	lw	s2,0(s7)
    80004c5a:	00a4d59b          	srliw	a1,s1,0xa
    80004c5e:	855e                	mv	a0,s7
    80004c60:	00000097          	auipc	ra,0x0
    80004c64:	8ae080e7          	jalr	-1874(ra) # 8000450e <bmap>
    80004c68:	0005059b          	sext.w	a1,a0
    80004c6c:	854a                	mv	a0,s2
    80004c6e:	fffff097          	auipc	ra,0xfffff
    80004c72:	4ac080e7          	jalr	1196(ra) # 8000411a <bread>
    80004c76:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004c78:	3ff4f613          	andi	a2,s1,1023
    80004c7c:	40cd07bb          	subw	a5,s10,a2
    80004c80:	413b073b          	subw	a4,s6,s3
    80004c84:	8a3e                	mv	s4,a5
    80004c86:	2781                	sext.w	a5,a5
    80004c88:	0007069b          	sext.w	a3,a4
    80004c8c:	f8f6f9e3          	bgeu	a3,a5,80004c1e <readi+0x4c>
    80004c90:	8a3a                	mv	s4,a4
    80004c92:	b771                	j	80004c1e <readi+0x4c>
      brelse(bp);
    80004c94:	854a                	mv	a0,s2
    80004c96:	fffff097          	auipc	ra,0xfffff
    80004c9a:	5b4080e7          	jalr	1460(ra) # 8000424a <brelse>
      tot = -1;
    80004c9e:	59fd                	li	s3,-1
  }
  return tot;
    80004ca0:	0009851b          	sext.w	a0,s3
}
    80004ca4:	70a6                	ld	ra,104(sp)
    80004ca6:	7406                	ld	s0,96(sp)
    80004ca8:	64e6                	ld	s1,88(sp)
    80004caa:	6946                	ld	s2,80(sp)
    80004cac:	69a6                	ld	s3,72(sp)
    80004cae:	6a06                	ld	s4,64(sp)
    80004cb0:	7ae2                	ld	s5,56(sp)
    80004cb2:	7b42                	ld	s6,48(sp)
    80004cb4:	7ba2                	ld	s7,40(sp)
    80004cb6:	7c02                	ld	s8,32(sp)
    80004cb8:	6ce2                	ld	s9,24(sp)
    80004cba:	6d42                	ld	s10,16(sp)
    80004cbc:	6da2                	ld	s11,8(sp)
    80004cbe:	6165                	addi	sp,sp,112
    80004cc0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004cc2:	89da                	mv	s3,s6
    80004cc4:	bff1                	j	80004ca0 <readi+0xce>
    return 0;
    80004cc6:	4501                	li	a0,0
}
    80004cc8:	8082                	ret

0000000080004cca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004cca:	457c                	lw	a5,76(a0)
    80004ccc:	10d7e863          	bltu	a5,a3,80004ddc <writei+0x112>
{
    80004cd0:	7159                	addi	sp,sp,-112
    80004cd2:	f486                	sd	ra,104(sp)
    80004cd4:	f0a2                	sd	s0,96(sp)
    80004cd6:	eca6                	sd	s1,88(sp)
    80004cd8:	e8ca                	sd	s2,80(sp)
    80004cda:	e4ce                	sd	s3,72(sp)
    80004cdc:	e0d2                	sd	s4,64(sp)
    80004cde:	fc56                	sd	s5,56(sp)
    80004ce0:	f85a                	sd	s6,48(sp)
    80004ce2:	f45e                	sd	s7,40(sp)
    80004ce4:	f062                	sd	s8,32(sp)
    80004ce6:	ec66                	sd	s9,24(sp)
    80004ce8:	e86a                	sd	s10,16(sp)
    80004cea:	e46e                	sd	s11,8(sp)
    80004cec:	1880                	addi	s0,sp,112
    80004cee:	8b2a                	mv	s6,a0
    80004cf0:	8c2e                	mv	s8,a1
    80004cf2:	8ab2                	mv	s5,a2
    80004cf4:	8936                	mv	s2,a3
    80004cf6:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004cf8:	00e687bb          	addw	a5,a3,a4
    80004cfc:	0ed7e263          	bltu	a5,a3,80004de0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004d00:	00043737          	lui	a4,0x43
    80004d04:	0ef76063          	bltu	a4,a5,80004de4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004d08:	0c0b8863          	beqz	s7,80004dd8 <writei+0x10e>
    80004d0c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004d0e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004d12:	5cfd                	li	s9,-1
    80004d14:	a091                	j	80004d58 <writei+0x8e>
    80004d16:	02099d93          	slli	s11,s3,0x20
    80004d1a:	020ddd93          	srli	s11,s11,0x20
    80004d1e:	05848793          	addi	a5,s1,88
    80004d22:	86ee                	mv	a3,s11
    80004d24:	8656                	mv	a2,s5
    80004d26:	85e2                	mv	a1,s8
    80004d28:	953e                	add	a0,a0,a5
    80004d2a:	ffffe097          	auipc	ra,0xffffe
    80004d2e:	e3a080e7          	jalr	-454(ra) # 80002b64 <either_copyin>
    80004d32:	07950263          	beq	a0,s9,80004d96 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004d36:	8526                	mv	a0,s1
    80004d38:	00000097          	auipc	ra,0x0
    80004d3c:	792080e7          	jalr	1938(ra) # 800054ca <log_write>
    brelse(bp);
    80004d40:	8526                	mv	a0,s1
    80004d42:	fffff097          	auipc	ra,0xfffff
    80004d46:	508080e7          	jalr	1288(ra) # 8000424a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004d4a:	01498a3b          	addw	s4,s3,s4
    80004d4e:	0129893b          	addw	s2,s3,s2
    80004d52:	9aee                	add	s5,s5,s11
    80004d54:	057a7663          	bgeu	s4,s7,80004da0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004d58:	000b2483          	lw	s1,0(s6)
    80004d5c:	00a9559b          	srliw	a1,s2,0xa
    80004d60:	855a                	mv	a0,s6
    80004d62:	fffff097          	auipc	ra,0xfffff
    80004d66:	7ac080e7          	jalr	1964(ra) # 8000450e <bmap>
    80004d6a:	0005059b          	sext.w	a1,a0
    80004d6e:	8526                	mv	a0,s1
    80004d70:	fffff097          	auipc	ra,0xfffff
    80004d74:	3aa080e7          	jalr	938(ra) # 8000411a <bread>
    80004d78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004d7a:	3ff97513          	andi	a0,s2,1023
    80004d7e:	40ad07bb          	subw	a5,s10,a0
    80004d82:	414b873b          	subw	a4,s7,s4
    80004d86:	89be                	mv	s3,a5
    80004d88:	2781                	sext.w	a5,a5
    80004d8a:	0007069b          	sext.w	a3,a4
    80004d8e:	f8f6f4e3          	bgeu	a3,a5,80004d16 <writei+0x4c>
    80004d92:	89ba                	mv	s3,a4
    80004d94:	b749                	j	80004d16 <writei+0x4c>
      brelse(bp);
    80004d96:	8526                	mv	a0,s1
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	4b2080e7          	jalr	1202(ra) # 8000424a <brelse>
  }

  if(off > ip->size)
    80004da0:	04cb2783          	lw	a5,76(s6)
    80004da4:	0127f463          	bgeu	a5,s2,80004dac <writei+0xe2>
    ip->size = off;
    80004da8:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004dac:	855a                	mv	a0,s6
    80004dae:	00000097          	auipc	ra,0x0
    80004db2:	aa6080e7          	jalr	-1370(ra) # 80004854 <iupdate>

  return tot;
    80004db6:	000a051b          	sext.w	a0,s4
}
    80004dba:	70a6                	ld	ra,104(sp)
    80004dbc:	7406                	ld	s0,96(sp)
    80004dbe:	64e6                	ld	s1,88(sp)
    80004dc0:	6946                	ld	s2,80(sp)
    80004dc2:	69a6                	ld	s3,72(sp)
    80004dc4:	6a06                	ld	s4,64(sp)
    80004dc6:	7ae2                	ld	s5,56(sp)
    80004dc8:	7b42                	ld	s6,48(sp)
    80004dca:	7ba2                	ld	s7,40(sp)
    80004dcc:	7c02                	ld	s8,32(sp)
    80004dce:	6ce2                	ld	s9,24(sp)
    80004dd0:	6d42                	ld	s10,16(sp)
    80004dd2:	6da2                	ld	s11,8(sp)
    80004dd4:	6165                	addi	sp,sp,112
    80004dd6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004dd8:	8a5e                	mv	s4,s7
    80004dda:	bfc9                	j	80004dac <writei+0xe2>
    return -1;
    80004ddc:	557d                	li	a0,-1
}
    80004dde:	8082                	ret
    return -1;
    80004de0:	557d                	li	a0,-1
    80004de2:	bfe1                	j	80004dba <writei+0xf0>
    return -1;
    80004de4:	557d                	li	a0,-1
    80004de6:	bfd1                	j	80004dba <writei+0xf0>

0000000080004de8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004de8:	1141                	addi	sp,sp,-16
    80004dea:	e406                	sd	ra,8(sp)
    80004dec:	e022                	sd	s0,0(sp)
    80004dee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004df0:	4639                	li	a2,14
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	25e080e7          	jalr	606(ra) # 80001050 <strncmp>
}
    80004dfa:	60a2                	ld	ra,8(sp)
    80004dfc:	6402                	ld	s0,0(sp)
    80004dfe:	0141                	addi	sp,sp,16
    80004e00:	8082                	ret

0000000080004e02 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004e02:	7139                	addi	sp,sp,-64
    80004e04:	fc06                	sd	ra,56(sp)
    80004e06:	f822                	sd	s0,48(sp)
    80004e08:	f426                	sd	s1,40(sp)
    80004e0a:	f04a                	sd	s2,32(sp)
    80004e0c:	ec4e                	sd	s3,24(sp)
    80004e0e:	e852                	sd	s4,16(sp)
    80004e10:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004e12:	04451703          	lh	a4,68(a0)
    80004e16:	4785                	li	a5,1
    80004e18:	00f71a63          	bne	a4,a5,80004e2c <dirlookup+0x2a>
    80004e1c:	892a                	mv	s2,a0
    80004e1e:	89ae                	mv	s3,a1
    80004e20:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e22:	457c                	lw	a5,76(a0)
    80004e24:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004e26:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e28:	e79d                	bnez	a5,80004e56 <dirlookup+0x54>
    80004e2a:	a8a5                	j	80004ea2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004e2c:	00005517          	auipc	a0,0x5
    80004e30:	8ac50513          	addi	a0,a0,-1876 # 800096d8 <syscalls+0x1f8>
    80004e34:	ffffb097          	auipc	ra,0xffffb
    80004e38:	6fa080e7          	jalr	1786(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004e3c:	00005517          	auipc	a0,0x5
    80004e40:	8b450513          	addi	a0,a0,-1868 # 800096f0 <syscalls+0x210>
    80004e44:	ffffb097          	auipc	ra,0xffffb
    80004e48:	6ea080e7          	jalr	1770(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e4c:	24c1                	addiw	s1,s1,16
    80004e4e:	04c92783          	lw	a5,76(s2)
    80004e52:	04f4f763          	bgeu	s1,a5,80004ea0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e56:	4741                	li	a4,16
    80004e58:	86a6                	mv	a3,s1
    80004e5a:	fc040613          	addi	a2,s0,-64
    80004e5e:	4581                	li	a1,0
    80004e60:	854a                	mv	a0,s2
    80004e62:	00000097          	auipc	ra,0x0
    80004e66:	d70080e7          	jalr	-656(ra) # 80004bd2 <readi>
    80004e6a:	47c1                	li	a5,16
    80004e6c:	fcf518e3          	bne	a0,a5,80004e3c <dirlookup+0x3a>
    if(de.inum == 0)
    80004e70:	fc045783          	lhu	a5,-64(s0)
    80004e74:	dfe1                	beqz	a5,80004e4c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004e76:	fc240593          	addi	a1,s0,-62
    80004e7a:	854e                	mv	a0,s3
    80004e7c:	00000097          	auipc	ra,0x0
    80004e80:	f6c080e7          	jalr	-148(ra) # 80004de8 <namecmp>
    80004e84:	f561                	bnez	a0,80004e4c <dirlookup+0x4a>
      if(poff)
    80004e86:	000a0463          	beqz	s4,80004e8e <dirlookup+0x8c>
        *poff = off;
    80004e8a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004e8e:	fc045583          	lhu	a1,-64(s0)
    80004e92:	00092503          	lw	a0,0(s2)
    80004e96:	fffff097          	auipc	ra,0xfffff
    80004e9a:	754080e7          	jalr	1876(ra) # 800045ea <iget>
    80004e9e:	a011                	j	80004ea2 <dirlookup+0xa0>
  return 0;
    80004ea0:	4501                	li	a0,0
}
    80004ea2:	70e2                	ld	ra,56(sp)
    80004ea4:	7442                	ld	s0,48(sp)
    80004ea6:	74a2                	ld	s1,40(sp)
    80004ea8:	7902                	ld	s2,32(sp)
    80004eaa:	69e2                	ld	s3,24(sp)
    80004eac:	6a42                	ld	s4,16(sp)
    80004eae:	6121                	addi	sp,sp,64
    80004eb0:	8082                	ret

0000000080004eb2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004eb2:	711d                	addi	sp,sp,-96
    80004eb4:	ec86                	sd	ra,88(sp)
    80004eb6:	e8a2                	sd	s0,80(sp)
    80004eb8:	e4a6                	sd	s1,72(sp)
    80004eba:	e0ca                	sd	s2,64(sp)
    80004ebc:	fc4e                	sd	s3,56(sp)
    80004ebe:	f852                	sd	s4,48(sp)
    80004ec0:	f456                	sd	s5,40(sp)
    80004ec2:	f05a                	sd	s6,32(sp)
    80004ec4:	ec5e                	sd	s7,24(sp)
    80004ec6:	e862                	sd	s8,16(sp)
    80004ec8:	e466                	sd	s9,8(sp)
    80004eca:	1080                	addi	s0,sp,96
    80004ecc:	84aa                	mv	s1,a0
    80004ece:	8aae                	mv	s5,a1
    80004ed0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004ed2:	00054703          	lbu	a4,0(a0)
    80004ed6:	02f00793          	li	a5,47
    80004eda:	02f70263          	beq	a4,a5,80004efe <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	e3a080e7          	jalr	-454(ra) # 80001d18 <myproc>
    80004ee6:	6968                	ld	a0,208(a0)
    80004ee8:	00000097          	auipc	ra,0x0
    80004eec:	9f8080e7          	jalr	-1544(ra) # 800048e0 <idup>
    80004ef0:	89aa                	mv	s3,a0
  while(*path == '/')
    80004ef2:	02f00913          	li	s2,47
  len = path - s;
    80004ef6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004ef8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004efa:	4b85                	li	s7,1
    80004efc:	a865                	j	80004fb4 <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004efe:	4585                	li	a1,1
    80004f00:	4505                	li	a0,1
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	6e8080e7          	jalr	1768(ra) # 800045ea <iget>
    80004f0a:	89aa                	mv	s3,a0
    80004f0c:	b7dd                	j	80004ef2 <namex+0x40>
      iunlockput(ip);
    80004f0e:	854e                	mv	a0,s3
    80004f10:	00000097          	auipc	ra,0x0
    80004f14:	c70080e7          	jalr	-912(ra) # 80004b80 <iunlockput>
      return 0;
    80004f18:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004f1a:	854e                	mv	a0,s3
    80004f1c:	60e6                	ld	ra,88(sp)
    80004f1e:	6446                	ld	s0,80(sp)
    80004f20:	64a6                	ld	s1,72(sp)
    80004f22:	6906                	ld	s2,64(sp)
    80004f24:	79e2                	ld	s3,56(sp)
    80004f26:	7a42                	ld	s4,48(sp)
    80004f28:	7aa2                	ld	s5,40(sp)
    80004f2a:	7b02                	ld	s6,32(sp)
    80004f2c:	6be2                	ld	s7,24(sp)
    80004f2e:	6c42                	ld	s8,16(sp)
    80004f30:	6ca2                	ld	s9,8(sp)
    80004f32:	6125                	addi	sp,sp,96
    80004f34:	8082                	ret
      iunlock(ip);
    80004f36:	854e                	mv	a0,s3
    80004f38:	00000097          	auipc	ra,0x0
    80004f3c:	aa8080e7          	jalr	-1368(ra) # 800049e0 <iunlock>
      return ip;
    80004f40:	bfe9                	j	80004f1a <namex+0x68>
      iunlockput(ip);
    80004f42:	854e                	mv	a0,s3
    80004f44:	00000097          	auipc	ra,0x0
    80004f48:	c3c080e7          	jalr	-964(ra) # 80004b80 <iunlockput>
      return 0;
    80004f4c:	89e6                	mv	s3,s9
    80004f4e:	b7f1                	j	80004f1a <namex+0x68>
  len = path - s;
    80004f50:	40b48633          	sub	a2,s1,a1
    80004f54:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004f58:	099c5463          	bge	s8,s9,80004fe0 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004f5c:	4639                	li	a2,14
    80004f5e:	8552                	mv	a0,s4
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	074080e7          	jalr	116(ra) # 80000fd4 <memmove>
  while(*path == '/')
    80004f68:	0004c783          	lbu	a5,0(s1)
    80004f6c:	01279763          	bne	a5,s2,80004f7a <namex+0xc8>
    path++;
    80004f70:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004f72:	0004c783          	lbu	a5,0(s1)
    80004f76:	ff278de3          	beq	a5,s2,80004f70 <namex+0xbe>
    ilock(ip);
    80004f7a:	854e                	mv	a0,s3
    80004f7c:	00000097          	auipc	ra,0x0
    80004f80:	9a2080e7          	jalr	-1630(ra) # 8000491e <ilock>
    if(ip->type != T_DIR){
    80004f84:	04499783          	lh	a5,68(s3)
    80004f88:	f97793e3          	bne	a5,s7,80004f0e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004f8c:	000a8563          	beqz	s5,80004f96 <namex+0xe4>
    80004f90:	0004c783          	lbu	a5,0(s1)
    80004f94:	d3cd                	beqz	a5,80004f36 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004f96:	865a                	mv	a2,s6
    80004f98:	85d2                	mv	a1,s4
    80004f9a:	854e                	mv	a0,s3
    80004f9c:	00000097          	auipc	ra,0x0
    80004fa0:	e66080e7          	jalr	-410(ra) # 80004e02 <dirlookup>
    80004fa4:	8caa                	mv	s9,a0
    80004fa6:	dd51                	beqz	a0,80004f42 <namex+0x90>
    iunlockput(ip);
    80004fa8:	854e                	mv	a0,s3
    80004faa:	00000097          	auipc	ra,0x0
    80004fae:	bd6080e7          	jalr	-1066(ra) # 80004b80 <iunlockput>
    ip = next;
    80004fb2:	89e6                	mv	s3,s9
  while(*path == '/')
    80004fb4:	0004c783          	lbu	a5,0(s1)
    80004fb8:	05279763          	bne	a5,s2,80005006 <namex+0x154>
    path++;
    80004fbc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004fbe:	0004c783          	lbu	a5,0(s1)
    80004fc2:	ff278de3          	beq	a5,s2,80004fbc <namex+0x10a>
  if(*path == 0)
    80004fc6:	c79d                	beqz	a5,80004ff4 <namex+0x142>
    path++;
    80004fc8:	85a6                	mv	a1,s1
  len = path - s;
    80004fca:	8cda                	mv	s9,s6
    80004fcc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004fce:	01278963          	beq	a5,s2,80004fe0 <namex+0x12e>
    80004fd2:	dfbd                	beqz	a5,80004f50 <namex+0x9e>
    path++;
    80004fd4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004fd6:	0004c783          	lbu	a5,0(s1)
    80004fda:	ff279ce3          	bne	a5,s2,80004fd2 <namex+0x120>
    80004fde:	bf8d                	j	80004f50 <namex+0x9e>
    memmove(name, s, len);
    80004fe0:	2601                	sext.w	a2,a2
    80004fe2:	8552                	mv	a0,s4
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	ff0080e7          	jalr	-16(ra) # 80000fd4 <memmove>
    name[len] = 0;
    80004fec:	9cd2                	add	s9,s9,s4
    80004fee:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004ff2:	bf9d                	j	80004f68 <namex+0xb6>
  if(nameiparent){
    80004ff4:	f20a83e3          	beqz	s5,80004f1a <namex+0x68>
    iput(ip);
    80004ff8:	854e                	mv	a0,s3
    80004ffa:	00000097          	auipc	ra,0x0
    80004ffe:	ade080e7          	jalr	-1314(ra) # 80004ad8 <iput>
    return 0;
    80005002:	4981                	li	s3,0
    80005004:	bf19                	j	80004f1a <namex+0x68>
  if(*path == 0)
    80005006:	d7fd                	beqz	a5,80004ff4 <namex+0x142>
  while(*path != '/' && *path != 0)
    80005008:	0004c783          	lbu	a5,0(s1)
    8000500c:	85a6                	mv	a1,s1
    8000500e:	b7d1                	j	80004fd2 <namex+0x120>

0000000080005010 <dirlink>:
{
    80005010:	7139                	addi	sp,sp,-64
    80005012:	fc06                	sd	ra,56(sp)
    80005014:	f822                	sd	s0,48(sp)
    80005016:	f426                	sd	s1,40(sp)
    80005018:	f04a                	sd	s2,32(sp)
    8000501a:	ec4e                	sd	s3,24(sp)
    8000501c:	e852                	sd	s4,16(sp)
    8000501e:	0080                	addi	s0,sp,64
    80005020:	892a                	mv	s2,a0
    80005022:	8a2e                	mv	s4,a1
    80005024:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005026:	4601                	li	a2,0
    80005028:	00000097          	auipc	ra,0x0
    8000502c:	dda080e7          	jalr	-550(ra) # 80004e02 <dirlookup>
    80005030:	e93d                	bnez	a0,800050a6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005032:	04c92483          	lw	s1,76(s2)
    80005036:	c49d                	beqz	s1,80005064 <dirlink+0x54>
    80005038:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000503a:	4741                	li	a4,16
    8000503c:	86a6                	mv	a3,s1
    8000503e:	fc040613          	addi	a2,s0,-64
    80005042:	4581                	li	a1,0
    80005044:	854a                	mv	a0,s2
    80005046:	00000097          	auipc	ra,0x0
    8000504a:	b8c080e7          	jalr	-1140(ra) # 80004bd2 <readi>
    8000504e:	47c1                	li	a5,16
    80005050:	06f51163          	bne	a0,a5,800050b2 <dirlink+0xa2>
    if(de.inum == 0)
    80005054:	fc045783          	lhu	a5,-64(s0)
    80005058:	c791                	beqz	a5,80005064 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000505a:	24c1                	addiw	s1,s1,16
    8000505c:	04c92783          	lw	a5,76(s2)
    80005060:	fcf4ede3          	bltu	s1,a5,8000503a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80005064:	4639                	li	a2,14
    80005066:	85d2                	mv	a1,s4
    80005068:	fc240513          	addi	a0,s0,-62
    8000506c:	ffffc097          	auipc	ra,0xffffc
    80005070:	020080e7          	jalr	32(ra) # 8000108c <strncpy>
  de.inum = inum;
    80005074:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005078:	4741                	li	a4,16
    8000507a:	86a6                	mv	a3,s1
    8000507c:	fc040613          	addi	a2,s0,-64
    80005080:	4581                	li	a1,0
    80005082:	854a                	mv	a0,s2
    80005084:	00000097          	auipc	ra,0x0
    80005088:	c46080e7          	jalr	-954(ra) # 80004cca <writei>
    8000508c:	872a                	mv	a4,a0
    8000508e:	47c1                	li	a5,16
  return 0;
    80005090:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005092:	02f71863          	bne	a4,a5,800050c2 <dirlink+0xb2>
}
    80005096:	70e2                	ld	ra,56(sp)
    80005098:	7442                	ld	s0,48(sp)
    8000509a:	74a2                	ld	s1,40(sp)
    8000509c:	7902                	ld	s2,32(sp)
    8000509e:	69e2                	ld	s3,24(sp)
    800050a0:	6a42                	ld	s4,16(sp)
    800050a2:	6121                	addi	sp,sp,64
    800050a4:	8082                	ret
    iput(ip);
    800050a6:	00000097          	auipc	ra,0x0
    800050aa:	a32080e7          	jalr	-1486(ra) # 80004ad8 <iput>
    return -1;
    800050ae:	557d                	li	a0,-1
    800050b0:	b7dd                	j	80005096 <dirlink+0x86>
      panic("dirlink read");
    800050b2:	00004517          	auipc	a0,0x4
    800050b6:	64e50513          	addi	a0,a0,1614 # 80009700 <syscalls+0x220>
    800050ba:	ffffb097          	auipc	ra,0xffffb
    800050be:	474080e7          	jalr	1140(ra) # 8000052e <panic>
    panic("dirlink");
    800050c2:	00004517          	auipc	a0,0x4
    800050c6:	74e50513          	addi	a0,a0,1870 # 80009810 <syscalls+0x330>
    800050ca:	ffffb097          	auipc	ra,0xffffb
    800050ce:	464080e7          	jalr	1124(ra) # 8000052e <panic>

00000000800050d2 <namei>:

struct inode*
namei(char *path)
{
    800050d2:	1101                	addi	sp,sp,-32
    800050d4:	ec06                	sd	ra,24(sp)
    800050d6:	e822                	sd	s0,16(sp)
    800050d8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800050da:	fe040613          	addi	a2,s0,-32
    800050de:	4581                	li	a1,0
    800050e0:	00000097          	auipc	ra,0x0
    800050e4:	dd2080e7          	jalr	-558(ra) # 80004eb2 <namex>
}
    800050e8:	60e2                	ld	ra,24(sp)
    800050ea:	6442                	ld	s0,16(sp)
    800050ec:	6105                	addi	sp,sp,32
    800050ee:	8082                	ret

00000000800050f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800050f0:	1141                	addi	sp,sp,-16
    800050f2:	e406                	sd	ra,8(sp)
    800050f4:	e022                	sd	s0,0(sp)
    800050f6:	0800                	addi	s0,sp,16
    800050f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800050fa:	4585                	li	a1,1
    800050fc:	00000097          	auipc	ra,0x0
    80005100:	db6080e7          	jalr	-586(ra) # 80004eb2 <namex>
}
    80005104:	60a2                	ld	ra,8(sp)
    80005106:	6402                	ld	s0,0(sp)
    80005108:	0141                	addi	sp,sp,16
    8000510a:	8082                	ret

000000008000510c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000510c:	1101                	addi	sp,sp,-32
    8000510e:	ec06                	sd	ra,24(sp)
    80005110:	e822                	sd	s0,16(sp)
    80005112:	e426                	sd	s1,8(sp)
    80005114:	e04a                	sd	s2,0(sp)
    80005116:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005118:	0003a917          	auipc	s2,0x3a
    8000511c:	db090913          	addi	s2,s2,-592 # 8003eec8 <log>
    80005120:	01892583          	lw	a1,24(s2)
    80005124:	02892503          	lw	a0,40(s2)
    80005128:	fffff097          	auipc	ra,0xfffff
    8000512c:	ff2080e7          	jalr	-14(ra) # 8000411a <bread>
    80005130:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005132:	02c92683          	lw	a3,44(s2)
    80005136:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005138:	02d05863          	blez	a3,80005168 <write_head+0x5c>
    8000513c:	0003a797          	auipc	a5,0x3a
    80005140:	dbc78793          	addi	a5,a5,-580 # 8003eef8 <log+0x30>
    80005144:	05c50713          	addi	a4,a0,92
    80005148:	36fd                	addiw	a3,a3,-1
    8000514a:	02069613          	slli	a2,a3,0x20
    8000514e:	01e65693          	srli	a3,a2,0x1e
    80005152:	0003a617          	auipc	a2,0x3a
    80005156:	daa60613          	addi	a2,a2,-598 # 8003eefc <log+0x34>
    8000515a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000515c:	4390                	lw	a2,0(a5)
    8000515e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005160:	0791                	addi	a5,a5,4
    80005162:	0711                	addi	a4,a4,4
    80005164:	fed79ce3          	bne	a5,a3,8000515c <write_head+0x50>
  }
  bwrite(buf);
    80005168:	8526                	mv	a0,s1
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	0a2080e7          	jalr	162(ra) # 8000420c <bwrite>
  brelse(buf);
    80005172:	8526                	mv	a0,s1
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	0d6080e7          	jalr	214(ra) # 8000424a <brelse>
}
    8000517c:	60e2                	ld	ra,24(sp)
    8000517e:	6442                	ld	s0,16(sp)
    80005180:	64a2                	ld	s1,8(sp)
    80005182:	6902                	ld	s2,0(sp)
    80005184:	6105                	addi	sp,sp,32
    80005186:	8082                	ret

0000000080005188 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005188:	0003a797          	auipc	a5,0x3a
    8000518c:	d6c7a783          	lw	a5,-660(a5) # 8003eef4 <log+0x2c>
    80005190:	0af05d63          	blez	a5,8000524a <install_trans+0xc2>
{
    80005194:	7139                	addi	sp,sp,-64
    80005196:	fc06                	sd	ra,56(sp)
    80005198:	f822                	sd	s0,48(sp)
    8000519a:	f426                	sd	s1,40(sp)
    8000519c:	f04a                	sd	s2,32(sp)
    8000519e:	ec4e                	sd	s3,24(sp)
    800051a0:	e852                	sd	s4,16(sp)
    800051a2:	e456                	sd	s5,8(sp)
    800051a4:	e05a                	sd	s6,0(sp)
    800051a6:	0080                	addi	s0,sp,64
    800051a8:	8b2a                	mv	s6,a0
    800051aa:	0003aa97          	auipc	s5,0x3a
    800051ae:	d4ea8a93          	addi	s5,s5,-690 # 8003eef8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800051b2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800051b4:	0003a997          	auipc	s3,0x3a
    800051b8:	d1498993          	addi	s3,s3,-748 # 8003eec8 <log>
    800051bc:	a00d                	j	800051de <install_trans+0x56>
    brelse(lbuf);
    800051be:	854a                	mv	a0,s2
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	08a080e7          	jalr	138(ra) # 8000424a <brelse>
    brelse(dbuf);
    800051c8:	8526                	mv	a0,s1
    800051ca:	fffff097          	auipc	ra,0xfffff
    800051ce:	080080e7          	jalr	128(ra) # 8000424a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800051d2:	2a05                	addiw	s4,s4,1
    800051d4:	0a91                	addi	s5,s5,4
    800051d6:	02c9a783          	lw	a5,44(s3)
    800051da:	04fa5e63          	bge	s4,a5,80005236 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800051de:	0189a583          	lw	a1,24(s3)
    800051e2:	014585bb          	addw	a1,a1,s4
    800051e6:	2585                	addiw	a1,a1,1
    800051e8:	0289a503          	lw	a0,40(s3)
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	f2e080e7          	jalr	-210(ra) # 8000411a <bread>
    800051f4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800051f6:	000aa583          	lw	a1,0(s5)
    800051fa:	0289a503          	lw	a0,40(s3)
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	f1c080e7          	jalr	-228(ra) # 8000411a <bread>
    80005206:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005208:	40000613          	li	a2,1024
    8000520c:	05890593          	addi	a1,s2,88
    80005210:	05850513          	addi	a0,a0,88
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	dc0080e7          	jalr	-576(ra) # 80000fd4 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000521c:	8526                	mv	a0,s1
    8000521e:	fffff097          	auipc	ra,0xfffff
    80005222:	fee080e7          	jalr	-18(ra) # 8000420c <bwrite>
    if(recovering == 0)
    80005226:	f80b1ce3          	bnez	s6,800051be <install_trans+0x36>
      bunpin(dbuf);
    8000522a:	8526                	mv	a0,s1
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	0f8080e7          	jalr	248(ra) # 80004324 <bunpin>
    80005234:	b769                	j	800051be <install_trans+0x36>
}
    80005236:	70e2                	ld	ra,56(sp)
    80005238:	7442                	ld	s0,48(sp)
    8000523a:	74a2                	ld	s1,40(sp)
    8000523c:	7902                	ld	s2,32(sp)
    8000523e:	69e2                	ld	s3,24(sp)
    80005240:	6a42                	ld	s4,16(sp)
    80005242:	6aa2                	ld	s5,8(sp)
    80005244:	6b02                	ld	s6,0(sp)
    80005246:	6121                	addi	sp,sp,64
    80005248:	8082                	ret
    8000524a:	8082                	ret

000000008000524c <initlog>:
{
    8000524c:	7179                	addi	sp,sp,-48
    8000524e:	f406                	sd	ra,40(sp)
    80005250:	f022                	sd	s0,32(sp)
    80005252:	ec26                	sd	s1,24(sp)
    80005254:	e84a                	sd	s2,16(sp)
    80005256:	e44e                	sd	s3,8(sp)
    80005258:	1800                	addi	s0,sp,48
    8000525a:	892a                	mv	s2,a0
    8000525c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000525e:	0003a497          	auipc	s1,0x3a
    80005262:	c6a48493          	addi	s1,s1,-918 # 8003eec8 <log>
    80005266:	00004597          	auipc	a1,0x4
    8000526a:	4aa58593          	addi	a1,a1,1194 # 80009710 <syscalls+0x230>
    8000526e:	8526                	mv	a0,s1
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	8c6080e7          	jalr	-1850(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80005278:	0149a583          	lw	a1,20(s3)
    8000527c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000527e:	0109a783          	lw	a5,16(s3)
    80005282:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005284:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005288:	854a                	mv	a0,s2
    8000528a:	fffff097          	auipc	ra,0xfffff
    8000528e:	e90080e7          	jalr	-368(ra) # 8000411a <bread>
  log.lh.n = lh->n;
    80005292:	4d34                	lw	a3,88(a0)
    80005294:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80005296:	02d05663          	blez	a3,800052c2 <initlog+0x76>
    8000529a:	05c50793          	addi	a5,a0,92
    8000529e:	0003a717          	auipc	a4,0x3a
    800052a2:	c5a70713          	addi	a4,a4,-934 # 8003eef8 <log+0x30>
    800052a6:	36fd                	addiw	a3,a3,-1
    800052a8:	02069613          	slli	a2,a3,0x20
    800052ac:	01e65693          	srli	a3,a2,0x1e
    800052b0:	06050613          	addi	a2,a0,96
    800052b4:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800052b6:	4390                	lw	a2,0(a5)
    800052b8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800052ba:	0791                	addi	a5,a5,4
    800052bc:	0711                	addi	a4,a4,4
    800052be:	fed79ce3          	bne	a5,a3,800052b6 <initlog+0x6a>
  brelse(buf);
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	f88080e7          	jalr	-120(ra) # 8000424a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800052ca:	4505                	li	a0,1
    800052cc:	00000097          	auipc	ra,0x0
    800052d0:	ebc080e7          	jalr	-324(ra) # 80005188 <install_trans>
  log.lh.n = 0;
    800052d4:	0003a797          	auipc	a5,0x3a
    800052d8:	c207a023          	sw	zero,-992(a5) # 8003eef4 <log+0x2c>
  write_head(); // clear the log
    800052dc:	00000097          	auipc	ra,0x0
    800052e0:	e30080e7          	jalr	-464(ra) # 8000510c <write_head>
}
    800052e4:	70a2                	ld	ra,40(sp)
    800052e6:	7402                	ld	s0,32(sp)
    800052e8:	64e2                	ld	s1,24(sp)
    800052ea:	6942                	ld	s2,16(sp)
    800052ec:	69a2                	ld	s3,8(sp)
    800052ee:	6145                	addi	sp,sp,48
    800052f0:	8082                	ret

00000000800052f2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800052f2:	1101                	addi	sp,sp,-32
    800052f4:	ec06                	sd	ra,24(sp)
    800052f6:	e822                	sd	s0,16(sp)
    800052f8:	e426                	sd	s1,8(sp)
    800052fa:	e04a                	sd	s2,0(sp)
    800052fc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800052fe:	0003a517          	auipc	a0,0x3a
    80005302:	bca50513          	addi	a0,a0,-1078 # 8003eec8 <log>
    80005306:	ffffc097          	auipc	ra,0xffffc
    8000530a:	902080e7          	jalr	-1790(ra) # 80000c08 <acquire>
  while(1){
    if(log.committing){
    8000530e:	0003a497          	auipc	s1,0x3a
    80005312:	bba48493          	addi	s1,s1,-1094 # 8003eec8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005316:	4979                	li	s2,30
    80005318:	a039                	j	80005326 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000531a:	85a6                	mv	a1,s1
    8000531c:	8526                	mv	a0,s1
    8000531e:	ffffd097          	auipc	ra,0xffffd
    80005322:	344080e7          	jalr	836(ra) # 80002662 <sleep>
    if(log.committing){
    80005326:	50dc                	lw	a5,36(s1)
    80005328:	fbed                	bnez	a5,8000531a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000532a:	509c                	lw	a5,32(s1)
    8000532c:	0017871b          	addiw	a4,a5,1
    80005330:	0007069b          	sext.w	a3,a4
    80005334:	0027179b          	slliw	a5,a4,0x2
    80005338:	9fb9                	addw	a5,a5,a4
    8000533a:	0017979b          	slliw	a5,a5,0x1
    8000533e:	54d8                	lw	a4,44(s1)
    80005340:	9fb9                	addw	a5,a5,a4
    80005342:	00f95963          	bge	s2,a5,80005354 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005346:	85a6                	mv	a1,s1
    80005348:	8526                	mv	a0,s1
    8000534a:	ffffd097          	auipc	ra,0xffffd
    8000534e:	318080e7          	jalr	792(ra) # 80002662 <sleep>
    80005352:	bfd1                	j	80005326 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005354:	0003a517          	auipc	a0,0x3a
    80005358:	b7450513          	addi	a0,a0,-1164 # 8003eec8 <log>
    8000535c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000535e:	ffffc097          	auipc	ra,0xffffc
    80005362:	95e080e7          	jalr	-1698(ra) # 80000cbc <release>
      break;
    }
  }
}
    80005366:	60e2                	ld	ra,24(sp)
    80005368:	6442                	ld	s0,16(sp)
    8000536a:	64a2                	ld	s1,8(sp)
    8000536c:	6902                	ld	s2,0(sp)
    8000536e:	6105                	addi	sp,sp,32
    80005370:	8082                	ret

0000000080005372 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005372:	7139                	addi	sp,sp,-64
    80005374:	fc06                	sd	ra,56(sp)
    80005376:	f822                	sd	s0,48(sp)
    80005378:	f426                	sd	s1,40(sp)
    8000537a:	f04a                	sd	s2,32(sp)
    8000537c:	ec4e                	sd	s3,24(sp)
    8000537e:	e852                	sd	s4,16(sp)
    80005380:	e456                	sd	s5,8(sp)
    80005382:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005384:	0003a497          	auipc	s1,0x3a
    80005388:	b4448493          	addi	s1,s1,-1212 # 8003eec8 <log>
    8000538c:	8526                	mv	a0,s1
    8000538e:	ffffc097          	auipc	ra,0xffffc
    80005392:	87a080e7          	jalr	-1926(ra) # 80000c08 <acquire>
  log.outstanding -= 1;
    80005396:	509c                	lw	a5,32(s1)
    80005398:	37fd                	addiw	a5,a5,-1
    8000539a:	0007891b          	sext.w	s2,a5
    8000539e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800053a0:	50dc                	lw	a5,36(s1)
    800053a2:	e7b9                	bnez	a5,800053f0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800053a4:	04091e63          	bnez	s2,80005400 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800053a8:	0003a497          	auipc	s1,0x3a
    800053ac:	b2048493          	addi	s1,s1,-1248 # 8003eec8 <log>
    800053b0:	4785                	li	a5,1
    800053b2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800053b4:	8526                	mv	a0,s1
    800053b6:	ffffc097          	auipc	ra,0xffffc
    800053ba:	906080e7          	jalr	-1786(ra) # 80000cbc <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800053be:	54dc                	lw	a5,44(s1)
    800053c0:	06f04763          	bgtz	a5,8000542e <end_op+0xbc>
    acquire(&log.lock);
    800053c4:	0003a497          	auipc	s1,0x3a
    800053c8:	b0448493          	addi	s1,s1,-1276 # 8003eec8 <log>
    800053cc:	8526                	mv	a0,s1
    800053ce:	ffffc097          	auipc	ra,0xffffc
    800053d2:	83a080e7          	jalr	-1990(ra) # 80000c08 <acquire>
    log.committing = 0;
    800053d6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800053da:	8526                	mv	a0,s1
    800053dc:	ffffd097          	auipc	ra,0xffffd
    800053e0:	410080e7          	jalr	1040(ra) # 800027ec <wakeup>
    release(&log.lock);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	8d6080e7          	jalr	-1834(ra) # 80000cbc <release>
}
    800053ee:	a03d                	j	8000541c <end_op+0xaa>
    panic("log.committing");
    800053f0:	00004517          	auipc	a0,0x4
    800053f4:	32850513          	addi	a0,a0,808 # 80009718 <syscalls+0x238>
    800053f8:	ffffb097          	auipc	ra,0xffffb
    800053fc:	136080e7          	jalr	310(ra) # 8000052e <panic>
    wakeup(&log);
    80005400:	0003a497          	auipc	s1,0x3a
    80005404:	ac848493          	addi	s1,s1,-1336 # 8003eec8 <log>
    80005408:	8526                	mv	a0,s1
    8000540a:	ffffd097          	auipc	ra,0xffffd
    8000540e:	3e2080e7          	jalr	994(ra) # 800027ec <wakeup>
  release(&log.lock);
    80005412:	8526                	mv	a0,s1
    80005414:	ffffc097          	auipc	ra,0xffffc
    80005418:	8a8080e7          	jalr	-1880(ra) # 80000cbc <release>
}
    8000541c:	70e2                	ld	ra,56(sp)
    8000541e:	7442                	ld	s0,48(sp)
    80005420:	74a2                	ld	s1,40(sp)
    80005422:	7902                	ld	s2,32(sp)
    80005424:	69e2                	ld	s3,24(sp)
    80005426:	6a42                	ld	s4,16(sp)
    80005428:	6aa2                	ld	s5,8(sp)
    8000542a:	6121                	addi	sp,sp,64
    8000542c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000542e:	0003aa97          	auipc	s5,0x3a
    80005432:	acaa8a93          	addi	s5,s5,-1334 # 8003eef8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005436:	0003aa17          	auipc	s4,0x3a
    8000543a:	a92a0a13          	addi	s4,s4,-1390 # 8003eec8 <log>
    8000543e:	018a2583          	lw	a1,24(s4)
    80005442:	012585bb          	addw	a1,a1,s2
    80005446:	2585                	addiw	a1,a1,1
    80005448:	028a2503          	lw	a0,40(s4)
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	cce080e7          	jalr	-818(ra) # 8000411a <bread>
    80005454:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005456:	000aa583          	lw	a1,0(s5)
    8000545a:	028a2503          	lw	a0,40(s4)
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	cbc080e7          	jalr	-836(ra) # 8000411a <bread>
    80005466:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005468:	40000613          	li	a2,1024
    8000546c:	05850593          	addi	a1,a0,88
    80005470:	05848513          	addi	a0,s1,88
    80005474:	ffffc097          	auipc	ra,0xffffc
    80005478:	b60080e7          	jalr	-1184(ra) # 80000fd4 <memmove>
    bwrite(to);  // write the log
    8000547c:	8526                	mv	a0,s1
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	d8e080e7          	jalr	-626(ra) # 8000420c <bwrite>
    brelse(from);
    80005486:	854e                	mv	a0,s3
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	dc2080e7          	jalr	-574(ra) # 8000424a <brelse>
    brelse(to);
    80005490:	8526                	mv	a0,s1
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	db8080e7          	jalr	-584(ra) # 8000424a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000549a:	2905                	addiw	s2,s2,1
    8000549c:	0a91                	addi	s5,s5,4
    8000549e:	02ca2783          	lw	a5,44(s4)
    800054a2:	f8f94ee3          	blt	s2,a5,8000543e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800054a6:	00000097          	auipc	ra,0x0
    800054aa:	c66080e7          	jalr	-922(ra) # 8000510c <write_head>
    install_trans(0); // Now install writes to home locations
    800054ae:	4501                	li	a0,0
    800054b0:	00000097          	auipc	ra,0x0
    800054b4:	cd8080e7          	jalr	-808(ra) # 80005188 <install_trans>
    log.lh.n = 0;
    800054b8:	0003a797          	auipc	a5,0x3a
    800054bc:	a207ae23          	sw	zero,-1476(a5) # 8003eef4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800054c0:	00000097          	auipc	ra,0x0
    800054c4:	c4c080e7          	jalr	-948(ra) # 8000510c <write_head>
    800054c8:	bdf5                	j	800053c4 <end_op+0x52>

00000000800054ca <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800054ca:	1101                	addi	sp,sp,-32
    800054cc:	ec06                	sd	ra,24(sp)
    800054ce:	e822                	sd	s0,16(sp)
    800054d0:	e426                	sd	s1,8(sp)
    800054d2:	e04a                	sd	s2,0(sp)
    800054d4:	1000                	addi	s0,sp,32
    800054d6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800054d8:	0003a917          	auipc	s2,0x3a
    800054dc:	9f090913          	addi	s2,s2,-1552 # 8003eec8 <log>
    800054e0:	854a                	mv	a0,s2
    800054e2:	ffffb097          	auipc	ra,0xffffb
    800054e6:	726080e7          	jalr	1830(ra) # 80000c08 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800054ea:	02c92603          	lw	a2,44(s2)
    800054ee:	47f5                	li	a5,29
    800054f0:	06c7c563          	blt	a5,a2,8000555a <log_write+0x90>
    800054f4:	0003a797          	auipc	a5,0x3a
    800054f8:	9f07a783          	lw	a5,-1552(a5) # 8003eee4 <log+0x1c>
    800054fc:	37fd                	addiw	a5,a5,-1
    800054fe:	04f65e63          	bge	a2,a5,8000555a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005502:	0003a797          	auipc	a5,0x3a
    80005506:	9e67a783          	lw	a5,-1562(a5) # 8003eee8 <log+0x20>
    8000550a:	06f05063          	blez	a5,8000556a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000550e:	4781                	li	a5,0
    80005510:	06c05563          	blez	a2,8000557a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005514:	44cc                	lw	a1,12(s1)
    80005516:	0003a717          	auipc	a4,0x3a
    8000551a:	9e270713          	addi	a4,a4,-1566 # 8003eef8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000551e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005520:	4314                	lw	a3,0(a4)
    80005522:	04b68c63          	beq	a3,a1,8000557a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005526:	2785                	addiw	a5,a5,1
    80005528:	0711                	addi	a4,a4,4
    8000552a:	fef61be3          	bne	a2,a5,80005520 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000552e:	0621                	addi	a2,a2,8
    80005530:	060a                	slli	a2,a2,0x2
    80005532:	0003a797          	auipc	a5,0x3a
    80005536:	99678793          	addi	a5,a5,-1642 # 8003eec8 <log>
    8000553a:	963e                	add	a2,a2,a5
    8000553c:	44dc                	lw	a5,12(s1)
    8000553e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005540:	8526                	mv	a0,s1
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	da6080e7          	jalr	-602(ra) # 800042e8 <bpin>
    log.lh.n++;
    8000554a:	0003a717          	auipc	a4,0x3a
    8000554e:	97e70713          	addi	a4,a4,-1666 # 8003eec8 <log>
    80005552:	575c                	lw	a5,44(a4)
    80005554:	2785                	addiw	a5,a5,1
    80005556:	d75c                	sw	a5,44(a4)
    80005558:	a835                	j	80005594 <log_write+0xca>
    panic("too big a transaction");
    8000555a:	00004517          	auipc	a0,0x4
    8000555e:	1ce50513          	addi	a0,a0,462 # 80009728 <syscalls+0x248>
    80005562:	ffffb097          	auipc	ra,0xffffb
    80005566:	fcc080e7          	jalr	-52(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    8000556a:	00004517          	auipc	a0,0x4
    8000556e:	1d650513          	addi	a0,a0,470 # 80009740 <syscalls+0x260>
    80005572:	ffffb097          	auipc	ra,0xffffb
    80005576:	fbc080e7          	jalr	-68(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    8000557a:	00878713          	addi	a4,a5,8
    8000557e:	00271693          	slli	a3,a4,0x2
    80005582:	0003a717          	auipc	a4,0x3a
    80005586:	94670713          	addi	a4,a4,-1722 # 8003eec8 <log>
    8000558a:	9736                	add	a4,a4,a3
    8000558c:	44d4                	lw	a3,12(s1)
    8000558e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005590:	faf608e3          	beq	a2,a5,80005540 <log_write+0x76>
  }
  release(&log.lock);
    80005594:	0003a517          	auipc	a0,0x3a
    80005598:	93450513          	addi	a0,a0,-1740 # 8003eec8 <log>
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	720080e7          	jalr	1824(ra) # 80000cbc <release>
}
    800055a4:	60e2                	ld	ra,24(sp)
    800055a6:	6442                	ld	s0,16(sp)
    800055a8:	64a2                	ld	s1,8(sp)
    800055aa:	6902                	ld	s2,0(sp)
    800055ac:	6105                	addi	sp,sp,32
    800055ae:	8082                	ret

00000000800055b0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800055b0:	1101                	addi	sp,sp,-32
    800055b2:	ec06                	sd	ra,24(sp)
    800055b4:	e822                	sd	s0,16(sp)
    800055b6:	e426                	sd	s1,8(sp)
    800055b8:	e04a                	sd	s2,0(sp)
    800055ba:	1000                	addi	s0,sp,32
    800055bc:	84aa                	mv	s1,a0
    800055be:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800055c0:	00004597          	auipc	a1,0x4
    800055c4:	1a058593          	addi	a1,a1,416 # 80009760 <syscalls+0x280>
    800055c8:	0521                	addi	a0,a0,8
    800055ca:	ffffb097          	auipc	ra,0xffffb
    800055ce:	56c080e7          	jalr	1388(ra) # 80000b36 <initlock>
  lk->name = name;
    800055d2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800055d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800055da:	0204a423          	sw	zero,40(s1)
}
    800055de:	60e2                	ld	ra,24(sp)
    800055e0:	6442                	ld	s0,16(sp)
    800055e2:	64a2                	ld	s1,8(sp)
    800055e4:	6902                	ld	s2,0(sp)
    800055e6:	6105                	addi	sp,sp,32
    800055e8:	8082                	ret

00000000800055ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800055ea:	1101                	addi	sp,sp,-32
    800055ec:	ec06                	sd	ra,24(sp)
    800055ee:	e822                	sd	s0,16(sp)
    800055f0:	e426                	sd	s1,8(sp)
    800055f2:	e04a                	sd	s2,0(sp)
    800055f4:	1000                	addi	s0,sp,32
    800055f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800055f8:	00850913          	addi	s2,a0,8
    800055fc:	854a                	mv	a0,s2
    800055fe:	ffffb097          	auipc	ra,0xffffb
    80005602:	60a080e7          	jalr	1546(ra) # 80000c08 <acquire>
  while (lk->locked) {
    80005606:	409c                	lw	a5,0(s1)
    80005608:	cb89                	beqz	a5,8000561a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000560a:	85ca                	mv	a1,s2
    8000560c:	8526                	mv	a0,s1
    8000560e:	ffffd097          	auipc	ra,0xffffd
    80005612:	054080e7          	jalr	84(ra) # 80002662 <sleep>
  while (lk->locked) {
    80005616:	409c                	lw	a5,0(s1)
    80005618:	fbed                	bnez	a5,8000560a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000561a:	4785                	li	a5,1
    8000561c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000561e:	ffffc097          	auipc	ra,0xffffc
    80005622:	6fa080e7          	jalr	1786(ra) # 80001d18 <myproc>
    80005626:	515c                	lw	a5,36(a0)
    80005628:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000562a:	854a                	mv	a0,s2
    8000562c:	ffffb097          	auipc	ra,0xffffb
    80005630:	690080e7          	jalr	1680(ra) # 80000cbc <release>
}
    80005634:	60e2                	ld	ra,24(sp)
    80005636:	6442                	ld	s0,16(sp)
    80005638:	64a2                	ld	s1,8(sp)
    8000563a:	6902                	ld	s2,0(sp)
    8000563c:	6105                	addi	sp,sp,32
    8000563e:	8082                	ret

0000000080005640 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005640:	1101                	addi	sp,sp,-32
    80005642:	ec06                	sd	ra,24(sp)
    80005644:	e822                	sd	s0,16(sp)
    80005646:	e426                	sd	s1,8(sp)
    80005648:	e04a                	sd	s2,0(sp)
    8000564a:	1000                	addi	s0,sp,32
    8000564c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000564e:	00850913          	addi	s2,a0,8
    80005652:	854a                	mv	a0,s2
    80005654:	ffffb097          	auipc	ra,0xffffb
    80005658:	5b4080e7          	jalr	1460(ra) # 80000c08 <acquire>
  lk->locked = 0;
    8000565c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005660:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005664:	8526                	mv	a0,s1
    80005666:	ffffd097          	auipc	ra,0xffffd
    8000566a:	186080e7          	jalr	390(ra) # 800027ec <wakeup>
  release(&lk->lk);
    8000566e:	854a                	mv	a0,s2
    80005670:	ffffb097          	auipc	ra,0xffffb
    80005674:	64c080e7          	jalr	1612(ra) # 80000cbc <release>
}
    80005678:	60e2                	ld	ra,24(sp)
    8000567a:	6442                	ld	s0,16(sp)
    8000567c:	64a2                	ld	s1,8(sp)
    8000567e:	6902                	ld	s2,0(sp)
    80005680:	6105                	addi	sp,sp,32
    80005682:	8082                	ret

0000000080005684 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005684:	7179                	addi	sp,sp,-48
    80005686:	f406                	sd	ra,40(sp)
    80005688:	f022                	sd	s0,32(sp)
    8000568a:	ec26                	sd	s1,24(sp)
    8000568c:	e84a                	sd	s2,16(sp)
    8000568e:	e44e                	sd	s3,8(sp)
    80005690:	1800                	addi	s0,sp,48
    80005692:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005694:	00850913          	addi	s2,a0,8
    80005698:	854a                	mv	a0,s2
    8000569a:	ffffb097          	auipc	ra,0xffffb
    8000569e:	56e080e7          	jalr	1390(ra) # 80000c08 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800056a2:	409c                	lw	a5,0(s1)
    800056a4:	ef99                	bnez	a5,800056c2 <holdingsleep+0x3e>
    800056a6:	4481                	li	s1,0
  release(&lk->lk);
    800056a8:	854a                	mv	a0,s2
    800056aa:	ffffb097          	auipc	ra,0xffffb
    800056ae:	612080e7          	jalr	1554(ra) # 80000cbc <release>
  return r;
}
    800056b2:	8526                	mv	a0,s1
    800056b4:	70a2                	ld	ra,40(sp)
    800056b6:	7402                	ld	s0,32(sp)
    800056b8:	64e2                	ld	s1,24(sp)
    800056ba:	6942                	ld	s2,16(sp)
    800056bc:	69a2                	ld	s3,8(sp)
    800056be:	6145                	addi	sp,sp,48
    800056c0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800056c2:	0284a983          	lw	s3,40(s1)
    800056c6:	ffffc097          	auipc	ra,0xffffc
    800056ca:	652080e7          	jalr	1618(ra) # 80001d18 <myproc>
    800056ce:	5144                	lw	s1,36(a0)
    800056d0:	413484b3          	sub	s1,s1,s3
    800056d4:	0014b493          	seqz	s1,s1
    800056d8:	bfc1                	j	800056a8 <holdingsleep+0x24>

00000000800056da <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800056da:	1141                	addi	sp,sp,-16
    800056dc:	e406                	sd	ra,8(sp)
    800056de:	e022                	sd	s0,0(sp)
    800056e0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800056e2:	00004597          	auipc	a1,0x4
    800056e6:	08e58593          	addi	a1,a1,142 # 80009770 <syscalls+0x290>
    800056ea:	0003a517          	auipc	a0,0x3a
    800056ee:	92650513          	addi	a0,a0,-1754 # 8003f010 <ftable>
    800056f2:	ffffb097          	auipc	ra,0xffffb
    800056f6:	444080e7          	jalr	1092(ra) # 80000b36 <initlock>
}
    800056fa:	60a2                	ld	ra,8(sp)
    800056fc:	6402                	ld	s0,0(sp)
    800056fe:	0141                	addi	sp,sp,16
    80005700:	8082                	ret

0000000080005702 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005702:	1101                	addi	sp,sp,-32
    80005704:	ec06                	sd	ra,24(sp)
    80005706:	e822                	sd	s0,16(sp)
    80005708:	e426                	sd	s1,8(sp)
    8000570a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000570c:	0003a517          	auipc	a0,0x3a
    80005710:	90450513          	addi	a0,a0,-1788 # 8003f010 <ftable>
    80005714:	ffffb097          	auipc	ra,0xffffb
    80005718:	4f4080e7          	jalr	1268(ra) # 80000c08 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000571c:	0003a497          	auipc	s1,0x3a
    80005720:	90c48493          	addi	s1,s1,-1780 # 8003f028 <ftable+0x18>
    80005724:	0003b717          	auipc	a4,0x3b
    80005728:	8a470713          	addi	a4,a4,-1884 # 8003ffc8 <ftable+0xfb8>
    if(f->ref == 0){
    8000572c:	40dc                	lw	a5,4(s1)
    8000572e:	cf99                	beqz	a5,8000574c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005730:	02848493          	addi	s1,s1,40
    80005734:	fee49ce3          	bne	s1,a4,8000572c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005738:	0003a517          	auipc	a0,0x3a
    8000573c:	8d850513          	addi	a0,a0,-1832 # 8003f010 <ftable>
    80005740:	ffffb097          	auipc	ra,0xffffb
    80005744:	57c080e7          	jalr	1404(ra) # 80000cbc <release>
  return 0;
    80005748:	4481                	li	s1,0
    8000574a:	a819                	j	80005760 <filealloc+0x5e>
      f->ref = 1;
    8000574c:	4785                	li	a5,1
    8000574e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005750:	0003a517          	auipc	a0,0x3a
    80005754:	8c050513          	addi	a0,a0,-1856 # 8003f010 <ftable>
    80005758:	ffffb097          	auipc	ra,0xffffb
    8000575c:	564080e7          	jalr	1380(ra) # 80000cbc <release>
}
    80005760:	8526                	mv	a0,s1
    80005762:	60e2                	ld	ra,24(sp)
    80005764:	6442                	ld	s0,16(sp)
    80005766:	64a2                	ld	s1,8(sp)
    80005768:	6105                	addi	sp,sp,32
    8000576a:	8082                	ret

000000008000576c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000576c:	1101                	addi	sp,sp,-32
    8000576e:	ec06                	sd	ra,24(sp)
    80005770:	e822                	sd	s0,16(sp)
    80005772:	e426                	sd	s1,8(sp)
    80005774:	1000                	addi	s0,sp,32
    80005776:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005778:	0003a517          	auipc	a0,0x3a
    8000577c:	89850513          	addi	a0,a0,-1896 # 8003f010 <ftable>
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	488080e7          	jalr	1160(ra) # 80000c08 <acquire>
  if(f->ref < 1)
    80005788:	40dc                	lw	a5,4(s1)
    8000578a:	02f05263          	blez	a5,800057ae <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000578e:	2785                	addiw	a5,a5,1
    80005790:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005792:	0003a517          	auipc	a0,0x3a
    80005796:	87e50513          	addi	a0,a0,-1922 # 8003f010 <ftable>
    8000579a:	ffffb097          	auipc	ra,0xffffb
    8000579e:	522080e7          	jalr	1314(ra) # 80000cbc <release>
  return f;
}
    800057a2:	8526                	mv	a0,s1
    800057a4:	60e2                	ld	ra,24(sp)
    800057a6:	6442                	ld	s0,16(sp)
    800057a8:	64a2                	ld	s1,8(sp)
    800057aa:	6105                	addi	sp,sp,32
    800057ac:	8082                	ret
    panic("filedup");
    800057ae:	00004517          	auipc	a0,0x4
    800057b2:	fca50513          	addi	a0,a0,-54 # 80009778 <syscalls+0x298>
    800057b6:	ffffb097          	auipc	ra,0xffffb
    800057ba:	d78080e7          	jalr	-648(ra) # 8000052e <panic>

00000000800057be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800057be:	7139                	addi	sp,sp,-64
    800057c0:	fc06                	sd	ra,56(sp)
    800057c2:	f822                	sd	s0,48(sp)
    800057c4:	f426                	sd	s1,40(sp)
    800057c6:	f04a                	sd	s2,32(sp)
    800057c8:	ec4e                	sd	s3,24(sp)
    800057ca:	e852                	sd	s4,16(sp)
    800057cc:	e456                	sd	s5,8(sp)
    800057ce:	0080                	addi	s0,sp,64
    800057d0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800057d2:	0003a517          	auipc	a0,0x3a
    800057d6:	83e50513          	addi	a0,a0,-1986 # 8003f010 <ftable>
    800057da:	ffffb097          	auipc	ra,0xffffb
    800057de:	42e080e7          	jalr	1070(ra) # 80000c08 <acquire>
  if(f->ref < 1)
    800057e2:	40dc                	lw	a5,4(s1)
    800057e4:	06f05163          	blez	a5,80005846 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800057e8:	37fd                	addiw	a5,a5,-1
    800057ea:	0007871b          	sext.w	a4,a5
    800057ee:	c0dc                	sw	a5,4(s1)
    800057f0:	06e04363          	bgtz	a4,80005856 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800057f4:	0004a903          	lw	s2,0(s1)
    800057f8:	0094ca83          	lbu	s5,9(s1)
    800057fc:	0104ba03          	ld	s4,16(s1)
    80005800:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005804:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005808:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000580c:	0003a517          	auipc	a0,0x3a
    80005810:	80450513          	addi	a0,a0,-2044 # 8003f010 <ftable>
    80005814:	ffffb097          	auipc	ra,0xffffb
    80005818:	4a8080e7          	jalr	1192(ra) # 80000cbc <release>

  if(ff.type == FD_PIPE){
    8000581c:	4785                	li	a5,1
    8000581e:	04f90d63          	beq	s2,a5,80005878 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005822:	3979                	addiw	s2,s2,-2
    80005824:	4785                	li	a5,1
    80005826:	0527e063          	bltu	a5,s2,80005866 <fileclose+0xa8>
    begin_op();
    8000582a:	00000097          	auipc	ra,0x0
    8000582e:	ac8080e7          	jalr	-1336(ra) # 800052f2 <begin_op>
    iput(ff.ip);
    80005832:	854e                	mv	a0,s3
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	2a4080e7          	jalr	676(ra) # 80004ad8 <iput>
    end_op();
    8000583c:	00000097          	auipc	ra,0x0
    80005840:	b36080e7          	jalr	-1226(ra) # 80005372 <end_op>
    80005844:	a00d                	j	80005866 <fileclose+0xa8>
    panic("fileclose");
    80005846:	00004517          	auipc	a0,0x4
    8000584a:	f3a50513          	addi	a0,a0,-198 # 80009780 <syscalls+0x2a0>
    8000584e:	ffffb097          	auipc	ra,0xffffb
    80005852:	ce0080e7          	jalr	-800(ra) # 8000052e <panic>
    release(&ftable.lock);
    80005856:	00039517          	auipc	a0,0x39
    8000585a:	7ba50513          	addi	a0,a0,1978 # 8003f010 <ftable>
    8000585e:	ffffb097          	auipc	ra,0xffffb
    80005862:	45e080e7          	jalr	1118(ra) # 80000cbc <release>
  }
}
    80005866:	70e2                	ld	ra,56(sp)
    80005868:	7442                	ld	s0,48(sp)
    8000586a:	74a2                	ld	s1,40(sp)
    8000586c:	7902                	ld	s2,32(sp)
    8000586e:	69e2                	ld	s3,24(sp)
    80005870:	6a42                	ld	s4,16(sp)
    80005872:	6aa2                	ld	s5,8(sp)
    80005874:	6121                	addi	sp,sp,64
    80005876:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005878:	85d6                	mv	a1,s5
    8000587a:	8552                	mv	a0,s4
    8000587c:	00000097          	auipc	ra,0x0
    80005880:	34c080e7          	jalr	844(ra) # 80005bc8 <pipeclose>
    80005884:	b7cd                	j	80005866 <fileclose+0xa8>

0000000080005886 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005886:	715d                	addi	sp,sp,-80
    80005888:	e486                	sd	ra,72(sp)
    8000588a:	e0a2                	sd	s0,64(sp)
    8000588c:	fc26                	sd	s1,56(sp)
    8000588e:	f84a                	sd	s2,48(sp)
    80005890:	f44e                	sd	s3,40(sp)
    80005892:	0880                	addi	s0,sp,80
    80005894:	84aa                	mv	s1,a0
    80005896:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005898:	ffffc097          	auipc	ra,0xffffc
    8000589c:	480080e7          	jalr	1152(ra) # 80001d18 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800058a0:	409c                	lw	a5,0(s1)
    800058a2:	37f9                	addiw	a5,a5,-2
    800058a4:	4705                	li	a4,1
    800058a6:	04f76763          	bltu	a4,a5,800058f4 <filestat+0x6e>
    800058aa:	892a                	mv	s2,a0
    ilock(f->ip);
    800058ac:	6c88                	ld	a0,24(s1)
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	070080e7          	jalr	112(ra) # 8000491e <ilock>
    stati(f->ip, &st);
    800058b6:	fb840593          	addi	a1,s0,-72
    800058ba:	6c88                	ld	a0,24(s1)
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	2ec080e7          	jalr	748(ra) # 80004ba8 <stati>
    iunlock(f->ip);
    800058c4:	6c88                	ld	a0,24(s1)
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	11a080e7          	jalr	282(ra) # 800049e0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800058ce:	46e1                	li	a3,24
    800058d0:	fb840613          	addi	a2,s0,-72
    800058d4:	85ce                	mv	a1,s3
    800058d6:	04093503          	ld	a0,64(s2)
    800058da:	ffffc097          	auipc	ra,0xffffc
    800058de:	026080e7          	jalr	38(ra) # 80001900 <copyout>
    800058e2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800058e6:	60a6                	ld	ra,72(sp)
    800058e8:	6406                	ld	s0,64(sp)
    800058ea:	74e2                	ld	s1,56(sp)
    800058ec:	7942                	ld	s2,48(sp)
    800058ee:	79a2                	ld	s3,40(sp)
    800058f0:	6161                	addi	sp,sp,80
    800058f2:	8082                	ret
  return -1;
    800058f4:	557d                	li	a0,-1
    800058f6:	bfc5                	j	800058e6 <filestat+0x60>

00000000800058f8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800058f8:	7179                	addi	sp,sp,-48
    800058fa:	f406                	sd	ra,40(sp)
    800058fc:	f022                	sd	s0,32(sp)
    800058fe:	ec26                	sd	s1,24(sp)
    80005900:	e84a                	sd	s2,16(sp)
    80005902:	e44e                	sd	s3,8(sp)
    80005904:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005906:	00854783          	lbu	a5,8(a0)
    8000590a:	c3d5                	beqz	a5,800059ae <fileread+0xb6>
    8000590c:	84aa                	mv	s1,a0
    8000590e:	89ae                	mv	s3,a1
    80005910:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005912:	411c                	lw	a5,0(a0)
    80005914:	4705                	li	a4,1
    80005916:	04e78963          	beq	a5,a4,80005968 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000591a:	470d                	li	a4,3
    8000591c:	04e78d63          	beq	a5,a4,80005976 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005920:	4709                	li	a4,2
    80005922:	06e79e63          	bne	a5,a4,8000599e <fileread+0xa6>
    ilock(f->ip);
    80005926:	6d08                	ld	a0,24(a0)
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	ff6080e7          	jalr	-10(ra) # 8000491e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005930:	874a                	mv	a4,s2
    80005932:	5094                	lw	a3,32(s1)
    80005934:	864e                	mv	a2,s3
    80005936:	4585                	li	a1,1
    80005938:	6c88                	ld	a0,24(s1)
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	298080e7          	jalr	664(ra) # 80004bd2 <readi>
    80005942:	892a                	mv	s2,a0
    80005944:	00a05563          	blez	a0,8000594e <fileread+0x56>
      f->off += r;
    80005948:	509c                	lw	a5,32(s1)
    8000594a:	9fa9                	addw	a5,a5,a0
    8000594c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000594e:	6c88                	ld	a0,24(s1)
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	090080e7          	jalr	144(ra) # 800049e0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005958:	854a                	mv	a0,s2
    8000595a:	70a2                	ld	ra,40(sp)
    8000595c:	7402                	ld	s0,32(sp)
    8000595e:	64e2                	ld	s1,24(sp)
    80005960:	6942                	ld	s2,16(sp)
    80005962:	69a2                	ld	s3,8(sp)
    80005964:	6145                	addi	sp,sp,48
    80005966:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005968:	6908                	ld	a0,16(a0)
    8000596a:	00000097          	auipc	ra,0x0
    8000596e:	3c8080e7          	jalr	968(ra) # 80005d32 <piperead>
    80005972:	892a                	mv	s2,a0
    80005974:	b7d5                	j	80005958 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005976:	02451783          	lh	a5,36(a0)
    8000597a:	03079693          	slli	a3,a5,0x30
    8000597e:	92c1                	srli	a3,a3,0x30
    80005980:	4725                	li	a4,9
    80005982:	02d76863          	bltu	a4,a3,800059b2 <fileread+0xba>
    80005986:	0792                	slli	a5,a5,0x4
    80005988:	00039717          	auipc	a4,0x39
    8000598c:	5e870713          	addi	a4,a4,1512 # 8003ef70 <devsw>
    80005990:	97ba                	add	a5,a5,a4
    80005992:	639c                	ld	a5,0(a5)
    80005994:	c38d                	beqz	a5,800059b6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005996:	4505                	li	a0,1
    80005998:	9782                	jalr	a5
    8000599a:	892a                	mv	s2,a0
    8000599c:	bf75                	j	80005958 <fileread+0x60>
    panic("fileread");
    8000599e:	00004517          	auipc	a0,0x4
    800059a2:	df250513          	addi	a0,a0,-526 # 80009790 <syscalls+0x2b0>
    800059a6:	ffffb097          	auipc	ra,0xffffb
    800059aa:	b88080e7          	jalr	-1144(ra) # 8000052e <panic>
    return -1;
    800059ae:	597d                	li	s2,-1
    800059b0:	b765                	j	80005958 <fileread+0x60>
      return -1;
    800059b2:	597d                	li	s2,-1
    800059b4:	b755                	j	80005958 <fileread+0x60>
    800059b6:	597d                	li	s2,-1
    800059b8:	b745                	j	80005958 <fileread+0x60>

00000000800059ba <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800059ba:	715d                	addi	sp,sp,-80
    800059bc:	e486                	sd	ra,72(sp)
    800059be:	e0a2                	sd	s0,64(sp)
    800059c0:	fc26                	sd	s1,56(sp)
    800059c2:	f84a                	sd	s2,48(sp)
    800059c4:	f44e                	sd	s3,40(sp)
    800059c6:	f052                	sd	s4,32(sp)
    800059c8:	ec56                	sd	s5,24(sp)
    800059ca:	e85a                	sd	s6,16(sp)
    800059cc:	e45e                	sd	s7,8(sp)
    800059ce:	e062                	sd	s8,0(sp)
    800059d0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800059d2:	00954783          	lbu	a5,9(a0)
    800059d6:	10078663          	beqz	a5,80005ae2 <filewrite+0x128>
    800059da:	892a                	mv	s2,a0
    800059dc:	8aae                	mv	s5,a1
    800059de:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800059e0:	411c                	lw	a5,0(a0)
    800059e2:	4705                	li	a4,1
    800059e4:	02e78263          	beq	a5,a4,80005a08 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800059e8:	470d                	li	a4,3
    800059ea:	02e78663          	beq	a5,a4,80005a16 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800059ee:	4709                	li	a4,2
    800059f0:	0ee79163          	bne	a5,a4,80005ad2 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800059f4:	0ac05d63          	blez	a2,80005aae <filewrite+0xf4>
    int i = 0;
    800059f8:	4981                	li	s3,0
    800059fa:	6b05                	lui	s6,0x1
    800059fc:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005a00:	6b85                	lui	s7,0x1
    80005a02:	c00b8b9b          	addiw	s7,s7,-1024
    80005a06:	a861                	j	80005a9e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005a08:	6908                	ld	a0,16(a0)
    80005a0a:	00000097          	auipc	ra,0x0
    80005a0e:	22e080e7          	jalr	558(ra) # 80005c38 <pipewrite>
    80005a12:	8a2a                	mv	s4,a0
    80005a14:	a045                	j	80005ab4 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005a16:	02451783          	lh	a5,36(a0)
    80005a1a:	03079693          	slli	a3,a5,0x30
    80005a1e:	92c1                	srli	a3,a3,0x30
    80005a20:	4725                	li	a4,9
    80005a22:	0cd76263          	bltu	a4,a3,80005ae6 <filewrite+0x12c>
    80005a26:	0792                	slli	a5,a5,0x4
    80005a28:	00039717          	auipc	a4,0x39
    80005a2c:	54870713          	addi	a4,a4,1352 # 8003ef70 <devsw>
    80005a30:	97ba                	add	a5,a5,a4
    80005a32:	679c                	ld	a5,8(a5)
    80005a34:	cbdd                	beqz	a5,80005aea <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005a36:	4505                	li	a0,1
    80005a38:	9782                	jalr	a5
    80005a3a:	8a2a                	mv	s4,a0
    80005a3c:	a8a5                	j	80005ab4 <filewrite+0xfa>
    80005a3e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005a42:	00000097          	auipc	ra,0x0
    80005a46:	8b0080e7          	jalr	-1872(ra) # 800052f2 <begin_op>
      ilock(f->ip);
    80005a4a:	01893503          	ld	a0,24(s2)
    80005a4e:	fffff097          	auipc	ra,0xfffff
    80005a52:	ed0080e7          	jalr	-304(ra) # 8000491e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005a56:	8762                	mv	a4,s8
    80005a58:	02092683          	lw	a3,32(s2)
    80005a5c:	01598633          	add	a2,s3,s5
    80005a60:	4585                	li	a1,1
    80005a62:	01893503          	ld	a0,24(s2)
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	264080e7          	jalr	612(ra) # 80004cca <writei>
    80005a6e:	84aa                	mv	s1,a0
    80005a70:	00a05763          	blez	a0,80005a7e <filewrite+0xc4>
        f->off += r;
    80005a74:	02092783          	lw	a5,32(s2)
    80005a78:	9fa9                	addw	a5,a5,a0
    80005a7a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005a7e:	01893503          	ld	a0,24(s2)
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	f5e080e7          	jalr	-162(ra) # 800049e0 <iunlock>
      end_op();
    80005a8a:	00000097          	auipc	ra,0x0
    80005a8e:	8e8080e7          	jalr	-1816(ra) # 80005372 <end_op>

      if(r != n1){
    80005a92:	009c1f63          	bne	s8,s1,80005ab0 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005a96:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005a9a:	0149db63          	bge	s3,s4,80005ab0 <filewrite+0xf6>
      int n1 = n - i;
    80005a9e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005aa2:	84be                	mv	s1,a5
    80005aa4:	2781                	sext.w	a5,a5
    80005aa6:	f8fb5ce3          	bge	s6,a5,80005a3e <filewrite+0x84>
    80005aaa:	84de                	mv	s1,s7
    80005aac:	bf49                	j	80005a3e <filewrite+0x84>
    int i = 0;
    80005aae:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005ab0:	013a1f63          	bne	s4,s3,80005ace <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005ab4:	8552                	mv	a0,s4
    80005ab6:	60a6                	ld	ra,72(sp)
    80005ab8:	6406                	ld	s0,64(sp)
    80005aba:	74e2                	ld	s1,56(sp)
    80005abc:	7942                	ld	s2,48(sp)
    80005abe:	79a2                	ld	s3,40(sp)
    80005ac0:	7a02                	ld	s4,32(sp)
    80005ac2:	6ae2                	ld	s5,24(sp)
    80005ac4:	6b42                	ld	s6,16(sp)
    80005ac6:	6ba2                	ld	s7,8(sp)
    80005ac8:	6c02                	ld	s8,0(sp)
    80005aca:	6161                	addi	sp,sp,80
    80005acc:	8082                	ret
    ret = (i == n ? n : -1);
    80005ace:	5a7d                	li	s4,-1
    80005ad0:	b7d5                	j	80005ab4 <filewrite+0xfa>
    panic("filewrite");
    80005ad2:	00004517          	auipc	a0,0x4
    80005ad6:	cce50513          	addi	a0,a0,-818 # 800097a0 <syscalls+0x2c0>
    80005ada:	ffffb097          	auipc	ra,0xffffb
    80005ade:	a54080e7          	jalr	-1452(ra) # 8000052e <panic>
    return -1;
    80005ae2:	5a7d                	li	s4,-1
    80005ae4:	bfc1                	j	80005ab4 <filewrite+0xfa>
      return -1;
    80005ae6:	5a7d                	li	s4,-1
    80005ae8:	b7f1                	j	80005ab4 <filewrite+0xfa>
    80005aea:	5a7d                	li	s4,-1
    80005aec:	b7e1                	j	80005ab4 <filewrite+0xfa>

0000000080005aee <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005aee:	7179                	addi	sp,sp,-48
    80005af0:	f406                	sd	ra,40(sp)
    80005af2:	f022                	sd	s0,32(sp)
    80005af4:	ec26                	sd	s1,24(sp)
    80005af6:	e84a                	sd	s2,16(sp)
    80005af8:	e44e                	sd	s3,8(sp)
    80005afa:	e052                	sd	s4,0(sp)
    80005afc:	1800                	addi	s0,sp,48
    80005afe:	84aa                	mv	s1,a0
    80005b00:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005b02:	0005b023          	sd	zero,0(a1)
    80005b06:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005b0a:	00000097          	auipc	ra,0x0
    80005b0e:	bf8080e7          	jalr	-1032(ra) # 80005702 <filealloc>
    80005b12:	e088                	sd	a0,0(s1)
    80005b14:	c551                	beqz	a0,80005ba0 <pipealloc+0xb2>
    80005b16:	00000097          	auipc	ra,0x0
    80005b1a:	bec080e7          	jalr	-1044(ra) # 80005702 <filealloc>
    80005b1e:	00aa3023          	sd	a0,0(s4)
    80005b22:	c92d                	beqz	a0,80005b94 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005b24:	ffffb097          	auipc	ra,0xffffb
    80005b28:	fb2080e7          	jalr	-78(ra) # 80000ad6 <kalloc>
    80005b2c:	892a                	mv	s2,a0
    80005b2e:	c125                	beqz	a0,80005b8e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005b30:	4985                	li	s3,1
    80005b32:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005b36:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005b3a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005b3e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005b42:	00004597          	auipc	a1,0x4
    80005b46:	c6e58593          	addi	a1,a1,-914 # 800097b0 <syscalls+0x2d0>
    80005b4a:	ffffb097          	auipc	ra,0xffffb
    80005b4e:	fec080e7          	jalr	-20(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005b52:	609c                	ld	a5,0(s1)
    80005b54:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005b58:	609c                	ld	a5,0(s1)
    80005b5a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005b5e:	609c                	ld	a5,0(s1)
    80005b60:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005b64:	609c                	ld	a5,0(s1)
    80005b66:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005b6a:	000a3783          	ld	a5,0(s4)
    80005b6e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005b72:	000a3783          	ld	a5,0(s4)
    80005b76:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005b7a:	000a3783          	ld	a5,0(s4)
    80005b7e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005b82:	000a3783          	ld	a5,0(s4)
    80005b86:	0127b823          	sd	s2,16(a5)
  return 0;
    80005b8a:	4501                	li	a0,0
    80005b8c:	a025                	j	80005bb4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005b8e:	6088                	ld	a0,0(s1)
    80005b90:	e501                	bnez	a0,80005b98 <pipealloc+0xaa>
    80005b92:	a039                	j	80005ba0 <pipealloc+0xb2>
    80005b94:	6088                	ld	a0,0(s1)
    80005b96:	c51d                	beqz	a0,80005bc4 <pipealloc+0xd6>
    fileclose(*f0);
    80005b98:	00000097          	auipc	ra,0x0
    80005b9c:	c26080e7          	jalr	-986(ra) # 800057be <fileclose>
  if(*f1)
    80005ba0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005ba4:	557d                	li	a0,-1
  if(*f1)
    80005ba6:	c799                	beqz	a5,80005bb4 <pipealloc+0xc6>
    fileclose(*f1);
    80005ba8:	853e                	mv	a0,a5
    80005baa:	00000097          	auipc	ra,0x0
    80005bae:	c14080e7          	jalr	-1004(ra) # 800057be <fileclose>
  return -1;
    80005bb2:	557d                	li	a0,-1
}
    80005bb4:	70a2                	ld	ra,40(sp)
    80005bb6:	7402                	ld	s0,32(sp)
    80005bb8:	64e2                	ld	s1,24(sp)
    80005bba:	6942                	ld	s2,16(sp)
    80005bbc:	69a2                	ld	s3,8(sp)
    80005bbe:	6a02                	ld	s4,0(sp)
    80005bc0:	6145                	addi	sp,sp,48
    80005bc2:	8082                	ret
  return -1;
    80005bc4:	557d                	li	a0,-1
    80005bc6:	b7fd                	j	80005bb4 <pipealloc+0xc6>

0000000080005bc8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005bc8:	1101                	addi	sp,sp,-32
    80005bca:	ec06                	sd	ra,24(sp)
    80005bcc:	e822                	sd	s0,16(sp)
    80005bce:	e426                	sd	s1,8(sp)
    80005bd0:	e04a                	sd	s2,0(sp)
    80005bd2:	1000                	addi	s0,sp,32
    80005bd4:	84aa                	mv	s1,a0
    80005bd6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005bd8:	ffffb097          	auipc	ra,0xffffb
    80005bdc:	030080e7          	jalr	48(ra) # 80000c08 <acquire>
  if(writable){
    80005be0:	02090d63          	beqz	s2,80005c1a <pipeclose+0x52>
    pi->writeopen = 0;
    80005be4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005be8:	21848513          	addi	a0,s1,536
    80005bec:	ffffd097          	auipc	ra,0xffffd
    80005bf0:	c00080e7          	jalr	-1024(ra) # 800027ec <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005bf4:	2204b783          	ld	a5,544(s1)
    80005bf8:	eb95                	bnez	a5,80005c2c <pipeclose+0x64>
    release(&pi->lock);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	ffffb097          	auipc	ra,0xffffb
    80005c00:	0c0080e7          	jalr	192(ra) # 80000cbc <release>
    kfree((char*)pi);
    80005c04:	8526                	mv	a0,s1
    80005c06:	ffffb097          	auipc	ra,0xffffb
    80005c0a:	dd4080e7          	jalr	-556(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005c0e:	60e2                	ld	ra,24(sp)
    80005c10:	6442                	ld	s0,16(sp)
    80005c12:	64a2                	ld	s1,8(sp)
    80005c14:	6902                	ld	s2,0(sp)
    80005c16:	6105                	addi	sp,sp,32
    80005c18:	8082                	ret
    pi->readopen = 0;
    80005c1a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005c1e:	21c48513          	addi	a0,s1,540
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	bca080e7          	jalr	-1078(ra) # 800027ec <wakeup>
    80005c2a:	b7e9                	j	80005bf4 <pipeclose+0x2c>
    release(&pi->lock);
    80005c2c:	8526                	mv	a0,s1
    80005c2e:	ffffb097          	auipc	ra,0xffffb
    80005c32:	08e080e7          	jalr	142(ra) # 80000cbc <release>
}
    80005c36:	bfe1                	j	80005c0e <pipeclose+0x46>

0000000080005c38 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005c38:	7159                	addi	sp,sp,-112
    80005c3a:	f486                	sd	ra,104(sp)
    80005c3c:	f0a2                	sd	s0,96(sp)
    80005c3e:	eca6                	sd	s1,88(sp)
    80005c40:	e8ca                	sd	s2,80(sp)
    80005c42:	e4ce                	sd	s3,72(sp)
    80005c44:	e0d2                	sd	s4,64(sp)
    80005c46:	fc56                	sd	s5,56(sp)
    80005c48:	f85a                	sd	s6,48(sp)
    80005c4a:	f45e                	sd	s7,40(sp)
    80005c4c:	f062                	sd	s8,32(sp)
    80005c4e:	ec66                	sd	s9,24(sp)
    80005c50:	1880                	addi	s0,sp,112
    80005c52:	84aa                	mv	s1,a0
    80005c54:	8b2e                	mv	s6,a1
    80005c56:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	0c0080e7          	jalr	192(ra) # 80001d18 <myproc>
    80005c60:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005c62:	8526                	mv	a0,s1
    80005c64:	ffffb097          	auipc	ra,0xffffb
    80005c68:	fa4080e7          	jalr	-92(ra) # 80000c08 <acquire>
  while(i < n){
    80005c6c:	0b505663          	blez	s5,80005d18 <pipewrite+0xe0>
  int i = 0;
    80005c70:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005c72:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005c74:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005c76:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005c7a:	21c48c13          	addi	s8,s1,540
    80005c7e:	a091                	j	80005cc2 <pipewrite+0x8a>
      release(&pi->lock);
    80005c80:	8526                	mv	a0,s1
    80005c82:	ffffb097          	auipc	ra,0xffffb
    80005c86:	03a080e7          	jalr	58(ra) # 80000cbc <release>
      return -1;
    80005c8a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005c8c:	854a                	mv	a0,s2
    80005c8e:	70a6                	ld	ra,104(sp)
    80005c90:	7406                	ld	s0,96(sp)
    80005c92:	64e6                	ld	s1,88(sp)
    80005c94:	6946                	ld	s2,80(sp)
    80005c96:	69a6                	ld	s3,72(sp)
    80005c98:	6a06                	ld	s4,64(sp)
    80005c9a:	7ae2                	ld	s5,56(sp)
    80005c9c:	7b42                	ld	s6,48(sp)
    80005c9e:	7ba2                	ld	s7,40(sp)
    80005ca0:	7c02                	ld	s8,32(sp)
    80005ca2:	6ce2                	ld	s9,24(sp)
    80005ca4:	6165                	addi	sp,sp,112
    80005ca6:	8082                	ret
      wakeup(&pi->nread);
    80005ca8:	8566                	mv	a0,s9
    80005caa:	ffffd097          	auipc	ra,0xffffd
    80005cae:	b42080e7          	jalr	-1214(ra) # 800027ec <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005cb2:	85a6                	mv	a1,s1
    80005cb4:	8562                	mv	a0,s8
    80005cb6:	ffffd097          	auipc	ra,0xffffd
    80005cba:	9ac080e7          	jalr	-1620(ra) # 80002662 <sleep>
  while(i < n){
    80005cbe:	05595e63          	bge	s2,s5,80005d1a <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005cc2:	2204a783          	lw	a5,544(s1)
    80005cc6:	dfcd                	beqz	a5,80005c80 <pipewrite+0x48>
    80005cc8:	01c9a783          	lw	a5,28(s3)
    80005ccc:	fb478ae3          	beq	a5,s4,80005c80 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005cd0:	2184a783          	lw	a5,536(s1)
    80005cd4:	21c4a703          	lw	a4,540(s1)
    80005cd8:	2007879b          	addiw	a5,a5,512
    80005cdc:	fcf706e3          	beq	a4,a5,80005ca8 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005ce0:	86d2                	mv	a3,s4
    80005ce2:	01690633          	add	a2,s2,s6
    80005ce6:	f9f40593          	addi	a1,s0,-97
    80005cea:	0409b503          	ld	a0,64(s3)
    80005cee:	ffffc097          	auipc	ra,0xffffc
    80005cf2:	c9e080e7          	jalr	-866(ra) # 8000198c <copyin>
    80005cf6:	03750263          	beq	a0,s7,80005d1a <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005cfa:	21c4a783          	lw	a5,540(s1)
    80005cfe:	0017871b          	addiw	a4,a5,1
    80005d02:	20e4ae23          	sw	a4,540(s1)
    80005d06:	1ff7f793          	andi	a5,a5,511
    80005d0a:	97a6                	add	a5,a5,s1
    80005d0c:	f9f44703          	lbu	a4,-97(s0)
    80005d10:	00e78c23          	sb	a4,24(a5)
      i++;
    80005d14:	2905                	addiw	s2,s2,1
    80005d16:	b765                	j	80005cbe <pipewrite+0x86>
  int i = 0;
    80005d18:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005d1a:	21848513          	addi	a0,s1,536
    80005d1e:	ffffd097          	auipc	ra,0xffffd
    80005d22:	ace080e7          	jalr	-1330(ra) # 800027ec <wakeup>
  release(&pi->lock);
    80005d26:	8526                	mv	a0,s1
    80005d28:	ffffb097          	auipc	ra,0xffffb
    80005d2c:	f94080e7          	jalr	-108(ra) # 80000cbc <release>
  return i;
    80005d30:	bfb1                	j	80005c8c <pipewrite+0x54>

0000000080005d32 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005d32:	715d                	addi	sp,sp,-80
    80005d34:	e486                	sd	ra,72(sp)
    80005d36:	e0a2                	sd	s0,64(sp)
    80005d38:	fc26                	sd	s1,56(sp)
    80005d3a:	f84a                	sd	s2,48(sp)
    80005d3c:	f44e                	sd	s3,40(sp)
    80005d3e:	f052                	sd	s4,32(sp)
    80005d40:	ec56                	sd	s5,24(sp)
    80005d42:	e85a                	sd	s6,16(sp)
    80005d44:	0880                	addi	s0,sp,80
    80005d46:	84aa                	mv	s1,a0
    80005d48:	892e                	mv	s2,a1
    80005d4a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005d4c:	ffffc097          	auipc	ra,0xffffc
    80005d50:	fcc080e7          	jalr	-52(ra) # 80001d18 <myproc>
    80005d54:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005d56:	8526                	mv	a0,s1
    80005d58:	ffffb097          	auipc	ra,0xffffb
    80005d5c:	eb0080e7          	jalr	-336(ra) # 80000c08 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005d60:	2184a703          	lw	a4,536(s1)
    80005d64:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005d68:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005d6a:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005d6e:	02f71563          	bne	a4,a5,80005d98 <piperead+0x66>
    80005d72:	2244a783          	lw	a5,548(s1)
    80005d76:	c38d                	beqz	a5,80005d98 <piperead+0x66>
    if(pr->killed==1){
    80005d78:	01ca2783          	lw	a5,28(s4)
    80005d7c:	09378963          	beq	a5,s3,80005e0e <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005d80:	85a6                	mv	a1,s1
    80005d82:	855a                	mv	a0,s6
    80005d84:	ffffd097          	auipc	ra,0xffffd
    80005d88:	8de080e7          	jalr	-1826(ra) # 80002662 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005d8c:	2184a703          	lw	a4,536(s1)
    80005d90:	21c4a783          	lw	a5,540(s1)
    80005d94:	fcf70fe3          	beq	a4,a5,80005d72 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005d98:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005d9a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005d9c:	05505363          	blez	s5,80005de2 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005da0:	2184a783          	lw	a5,536(s1)
    80005da4:	21c4a703          	lw	a4,540(s1)
    80005da8:	02f70d63          	beq	a4,a5,80005de2 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005dac:	0017871b          	addiw	a4,a5,1
    80005db0:	20e4ac23          	sw	a4,536(s1)
    80005db4:	1ff7f793          	andi	a5,a5,511
    80005db8:	97a6                	add	a5,a5,s1
    80005dba:	0187c783          	lbu	a5,24(a5)
    80005dbe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005dc2:	4685                	li	a3,1
    80005dc4:	fbf40613          	addi	a2,s0,-65
    80005dc8:	85ca                	mv	a1,s2
    80005dca:	040a3503          	ld	a0,64(s4)
    80005dce:	ffffc097          	auipc	ra,0xffffc
    80005dd2:	b32080e7          	jalr	-1230(ra) # 80001900 <copyout>
    80005dd6:	01650663          	beq	a0,s6,80005de2 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005dda:	2985                	addiw	s3,s3,1
    80005ddc:	0905                	addi	s2,s2,1
    80005dde:	fd3a91e3          	bne	s5,s3,80005da0 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005de2:	21c48513          	addi	a0,s1,540
    80005de6:	ffffd097          	auipc	ra,0xffffd
    80005dea:	a06080e7          	jalr	-1530(ra) # 800027ec <wakeup>
  release(&pi->lock);
    80005dee:	8526                	mv	a0,s1
    80005df0:	ffffb097          	auipc	ra,0xffffb
    80005df4:	ecc080e7          	jalr	-308(ra) # 80000cbc <release>
  return i;
}
    80005df8:	854e                	mv	a0,s3
    80005dfa:	60a6                	ld	ra,72(sp)
    80005dfc:	6406                	ld	s0,64(sp)
    80005dfe:	74e2                	ld	s1,56(sp)
    80005e00:	7942                	ld	s2,48(sp)
    80005e02:	79a2                	ld	s3,40(sp)
    80005e04:	7a02                	ld	s4,32(sp)
    80005e06:	6ae2                	ld	s5,24(sp)
    80005e08:	6b42                	ld	s6,16(sp)
    80005e0a:	6161                	addi	sp,sp,80
    80005e0c:	8082                	ret
      release(&pi->lock);
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	eac080e7          	jalr	-340(ra) # 80000cbc <release>
      return -1;
    80005e18:	59fd                	li	s3,-1
    80005e1a:	bff9                	j	80005df8 <piperead+0xc6>

0000000080005e1c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005e1c:	dd010113          	addi	sp,sp,-560
    80005e20:	22113423          	sd	ra,552(sp)
    80005e24:	22813023          	sd	s0,544(sp)
    80005e28:	20913c23          	sd	s1,536(sp)
    80005e2c:	21213823          	sd	s2,528(sp)
    80005e30:	21313423          	sd	s3,520(sp)
    80005e34:	21413023          	sd	s4,512(sp)
    80005e38:	ffd6                	sd	s5,504(sp)
    80005e3a:	fbda                	sd	s6,496(sp)
    80005e3c:	f7de                	sd	s7,488(sp)
    80005e3e:	f3e2                	sd	s8,480(sp)
    80005e40:	efe6                	sd	s9,472(sp)
    80005e42:	ebea                	sd	s10,464(sp)
    80005e44:	e7ee                	sd	s11,456(sp)
    80005e46:	1c00                	addi	s0,sp,560
    80005e48:	dea43823          	sd	a0,-528(s0)
    80005e4c:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005e50:	ffffc097          	auipc	ra,0xffffc
    80005e54:	ec8080e7          	jalr	-312(ra) # 80001d18 <myproc>
    80005e58:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005e5a:	ffffc097          	auipc	ra,0xffffc
    80005e5e:	efe080e7          	jalr	-258(ra) # 80001d58 <mykthread>
    80005e62:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005e64:	28898493          	addi	s1,s3,648
    80005e68:	6905                	lui	s2,0x1
    80005e6a:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005e6e:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005e70:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005e72:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005e74:	4b8d                	li	s7,3
    80005e76:	a811                	j	80005e8a <exec+0x6e>
      }
      release(&nt->lock);  
    80005e78:	8526                	mv	a0,s1
    80005e7a:	ffffb097          	auipc	ra,0xffffb
    80005e7e:	e42080e7          	jalr	-446(ra) # 80000cbc <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005e82:	0b848493          	addi	s1,s1,184
    80005e86:	03248363          	beq	s1,s2,80005eac <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005e8a:	fe9b0ce3          	beq	s6,s1,80005e82 <exec+0x66>
    80005e8e:	4c9c                	lw	a5,24(s1)
    80005e90:	dbed                	beqz	a5,80005e82 <exec+0x66>
      acquire(&nt->lock);
    80005e92:	8526                	mv	a0,s1
    80005e94:	ffffb097          	auipc	ra,0xffffb
    80005e98:	d74080e7          	jalr	-652(ra) # 80000c08 <acquire>
      nt->killed=1;
    80005e9c:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005ea0:	4c9c                	lw	a5,24(s1)
    80005ea2:	fd479be3          	bne	a5,s4,80005e78 <exec+0x5c>
        nt->state = TRUNNABLE;
    80005ea6:	0174ac23          	sw	s7,24(s1)
    80005eaa:	b7f9                	j	80005e78 <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005eac:	ffffd097          	auipc	ra,0xffffd
    80005eb0:	39e080e7          	jalr	926(ra) # 8000324a <kthread_join_all>
    
  begin_op();
    80005eb4:	fffff097          	auipc	ra,0xfffff
    80005eb8:	43e080e7          	jalr	1086(ra) # 800052f2 <begin_op>

  if((ip = namei(path)) == 0){
    80005ebc:	df043503          	ld	a0,-528(s0)
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	212080e7          	jalr	530(ra) # 800050d2 <namei>
    80005ec8:	8aaa                	mv	s5,a0
    80005eca:	cd25                	beqz	a0,80005f42 <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ecc:	fffff097          	auipc	ra,0xfffff
    80005ed0:	a52080e7          	jalr	-1454(ra) # 8000491e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005ed4:	04000713          	li	a4,64
    80005ed8:	4681                	li	a3,0
    80005eda:	e4840613          	addi	a2,s0,-440
    80005ede:	4581                	li	a1,0
    80005ee0:	8556                	mv	a0,s5
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	cf0080e7          	jalr	-784(ra) # 80004bd2 <readi>
    80005eea:	04000793          	li	a5,64
    80005eee:	00f51a63          	bne	a0,a5,80005f02 <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005ef2:	e4842703          	lw	a4,-440(s0)
    80005ef6:	464c47b7          	lui	a5,0x464c4
    80005efa:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005efe:	04f70863          	beq	a4,a5,80005f4e <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005f02:	8556                	mv	a0,s5
    80005f04:	fffff097          	auipc	ra,0xfffff
    80005f08:	c7c080e7          	jalr	-900(ra) # 80004b80 <iunlockput>
    end_op();
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	466080e7          	jalr	1126(ra) # 80005372 <end_op>
  }
  return -1;
    80005f14:	557d                	li	a0,-1
}
    80005f16:	22813083          	ld	ra,552(sp)
    80005f1a:	22013403          	ld	s0,544(sp)
    80005f1e:	21813483          	ld	s1,536(sp)
    80005f22:	21013903          	ld	s2,528(sp)
    80005f26:	20813983          	ld	s3,520(sp)
    80005f2a:	20013a03          	ld	s4,512(sp)
    80005f2e:	7afe                	ld	s5,504(sp)
    80005f30:	7b5e                	ld	s6,496(sp)
    80005f32:	7bbe                	ld	s7,488(sp)
    80005f34:	7c1e                	ld	s8,480(sp)
    80005f36:	6cfe                	ld	s9,472(sp)
    80005f38:	6d5e                	ld	s10,464(sp)
    80005f3a:	6dbe                	ld	s11,456(sp)
    80005f3c:	23010113          	addi	sp,sp,560
    80005f40:	8082                	ret
    end_op();
    80005f42:	fffff097          	auipc	ra,0xfffff
    80005f46:	430080e7          	jalr	1072(ra) # 80005372 <end_op>
    return -1;
    80005f4a:	557d                	li	a0,-1
    80005f4c:	b7e9                	j	80005f16 <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005f4e:	854e                	mv	a0,s3
    80005f50:	ffffc097          	auipc	ra,0xffffc
    80005f54:	f64080e7          	jalr	-156(ra) # 80001eb4 <proc_pagetable>
    80005f58:	e0a43423          	sd	a0,-504(s0)
    80005f5c:	d15d                	beqz	a0,80005f02 <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005f5e:	e6842783          	lw	a5,-408(s0)
    80005f62:	e8045703          	lhu	a4,-384(s0)
    80005f66:	c73d                	beqz	a4,80005fd4 <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005f68:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005f6a:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005f6e:	6a05                	lui	s4,0x1
    80005f70:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005f74:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005f78:	6d85                	lui	s11,0x1
    80005f7a:	7d7d                	lui	s10,0xfffff
    80005f7c:	a4b5                	j	800061e8 <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005f7e:	00004517          	auipc	a0,0x4
    80005f82:	83a50513          	addi	a0,a0,-1990 # 800097b8 <syscalls+0x2d8>
    80005f86:	ffffa097          	auipc	ra,0xffffa
    80005f8a:	5a8080e7          	jalr	1448(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005f8e:	874a                	mv	a4,s2
    80005f90:	009c86bb          	addw	a3,s9,s1
    80005f94:	4581                	li	a1,0
    80005f96:	8556                	mv	a0,s5
    80005f98:	fffff097          	auipc	ra,0xfffff
    80005f9c:	c3a080e7          	jalr	-966(ra) # 80004bd2 <readi>
    80005fa0:	2501                	sext.w	a0,a0
    80005fa2:	1ea91263          	bne	s2,a0,80006186 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005fa6:	009d84bb          	addw	s1,s11,s1
    80005faa:	013d09bb          	addw	s3,s10,s3
    80005fae:	2174fd63          	bgeu	s1,s7,800061c8 <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005fb2:	02049593          	slli	a1,s1,0x20
    80005fb6:	9181                	srli	a1,a1,0x20
    80005fb8:	95e2                	add	a1,a1,s8
    80005fba:	e0843503          	ld	a0,-504(s0)
    80005fbe:	ffffb097          	auipc	ra,0xffffb
    80005fc2:	350080e7          	jalr	848(ra) # 8000130e <walkaddr>
    80005fc6:	862a                	mv	a2,a0
    if(pa == 0)
    80005fc8:	d95d                	beqz	a0,80005f7e <exec+0x162>
      n = PGSIZE;
    80005fca:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005fcc:	fd49f1e3          	bgeu	s3,s4,80005f8e <exec+0x172>
      n = sz - i;
    80005fd0:	894e                	mv	s2,s3
    80005fd2:	bf75                	j	80005f8e <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005fd4:	4481                	li	s1,0
  iunlockput(ip);
    80005fd6:	8556                	mv	a0,s5
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	ba8080e7          	jalr	-1112(ra) # 80004b80 <iunlockput>
  end_op();
    80005fe0:	fffff097          	auipc	ra,0xfffff
    80005fe4:	392080e7          	jalr	914(ra) # 80005372 <end_op>
  p = myproc();
    80005fe8:	ffffc097          	auipc	ra,0xffffc
    80005fec:	d30080e7          	jalr	-720(ra) # 80001d18 <myproc>
    80005ff0:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005ff2:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005ff6:	6785                	lui	a5,0x1
    80005ff8:	17fd                	addi	a5,a5,-1
    80005ffa:	94be                	add	s1,s1,a5
    80005ffc:	77fd                	lui	a5,0xfffff
    80005ffe:	8fe5                	and	a5,a5,s1
    80006000:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006004:	6609                	lui	a2,0x2
    80006006:	963e                	add	a2,a2,a5
    80006008:	85be                	mv	a1,a5
    8000600a:	e0843483          	ld	s1,-504(s0)
    8000600e:	8526                	mv	a0,s1
    80006010:	ffffb097          	auipc	ra,0xffffb
    80006014:	6a0080e7          	jalr	1696(ra) # 800016b0 <uvmalloc>
    80006018:	8caa                	mv	s9,a0
  ip = 0;
    8000601a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000601c:	16050563          	beqz	a0,80006186 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80006020:	75f9                	lui	a1,0xffffe
    80006022:	95aa                	add	a1,a1,a0
    80006024:	8526                	mv	a0,s1
    80006026:	ffffc097          	auipc	ra,0xffffc
    8000602a:	8a8080e7          	jalr	-1880(ra) # 800018ce <uvmclear>
  stackbase = sp - PGSIZE;
    8000602e:	7bfd                	lui	s7,0xfffff
    80006030:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80006032:	de043783          	ld	a5,-544(s0)
    80006036:	6388                	ld	a0,0(a5)
    80006038:	c92d                	beqz	a0,800060aa <exec+0x28e>
    8000603a:	e8840993          	addi	s3,s0,-376
    8000603e:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80006042:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80006044:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80006046:	ffffb097          	auipc	ra,0xffffb
    8000604a:	0b6080e7          	jalr	182(ra) # 800010fc <strlen>
    8000604e:	0015079b          	addiw	a5,a0,1
    80006052:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80006056:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000605a:	15796b63          	bltu	s2,s7,800061b0 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000605e:	de043d83          	ld	s11,-544(s0)
    80006062:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80006066:	8556                	mv	a0,s5
    80006068:	ffffb097          	auipc	ra,0xffffb
    8000606c:	094080e7          	jalr	148(ra) # 800010fc <strlen>
    80006070:	0015069b          	addiw	a3,a0,1
    80006074:	8656                	mv	a2,s5
    80006076:	85ca                	mv	a1,s2
    80006078:	e0843503          	ld	a0,-504(s0)
    8000607c:	ffffc097          	auipc	ra,0xffffc
    80006080:	884080e7          	jalr	-1916(ra) # 80001900 <copyout>
    80006084:	12054a63          	bltz	a0,800061b8 <exec+0x39c>
    ustack[argc] = sp;
    80006088:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000608c:	0485                	addi	s1,s1,1
    8000608e:	008d8793          	addi	a5,s11,8
    80006092:	def43023          	sd	a5,-544(s0)
    80006096:	008db503          	ld	a0,8(s11)
    8000609a:	c911                	beqz	a0,800060ae <exec+0x292>
    if(argc >= MAXARG)
    8000609c:	09a1                	addi	s3,s3,8
    8000609e:	fb3c14e3          	bne	s8,s3,80006046 <exec+0x22a>
  sz = sz1;
    800060a2:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060a6:	4a81                	li	s5,0
    800060a8:	a8f9                	j	80006186 <exec+0x36a>
  sp = sz;
    800060aa:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    800060ac:	4481                	li	s1,0
  ustack[argc] = 0;
    800060ae:	00349793          	slli	a5,s1,0x3
    800060b2:	f9040713          	addi	a4,s0,-112
    800060b6:	97ba                	add	a5,a5,a4
    800060b8:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbbef8>
  sp -= (argc+1) * sizeof(uint64);
    800060bc:	00148693          	addi	a3,s1,1
    800060c0:	068e                	slli	a3,a3,0x3
    800060c2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800060c6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800060ca:	01797663          	bgeu	s2,s7,800060d6 <exec+0x2ba>
  sz = sz1;
    800060ce:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800060d2:	4a81                	li	s5,0
    800060d4:	a84d                	j	80006186 <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800060d6:	e8840613          	addi	a2,s0,-376
    800060da:	85ca                	mv	a1,s2
    800060dc:	e0843503          	ld	a0,-504(s0)
    800060e0:	ffffc097          	auipc	ra,0xffffc
    800060e4:	820080e7          	jalr	-2016(ra) # 80001900 <copyout>
    800060e8:	0c054c63          	bltz	a0,800061c0 <exec+0x3a4>
  t->trapframe->a1 = sp;
    800060ec:	040b3783          	ld	a5,64(s6)
    800060f0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800060f4:	df043783          	ld	a5,-528(s0)
    800060f8:	0007c703          	lbu	a4,0(a5)
    800060fc:	cf11                	beqz	a4,80006118 <exec+0x2fc>
    800060fe:	0785                	addi	a5,a5,1
    if(*s == '/')
    80006100:	02f00693          	li	a3,47
    80006104:	a039                	j	80006112 <exec+0x2f6>
      last = s+1;
    80006106:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    8000610a:	0785                	addi	a5,a5,1
    8000610c:	fff7c703          	lbu	a4,-1(a5)
    80006110:	c701                	beqz	a4,80006118 <exec+0x2fc>
    if(*s == '/')
    80006112:	fed71ce3          	bne	a4,a3,8000610a <exec+0x2ee>
    80006116:	bfc5                	j	80006106 <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    80006118:	4641                	li	a2,16
    8000611a:	df043583          	ld	a1,-528(s0)
    8000611e:	0d8a0513          	addi	a0,s4,216
    80006122:	ffffb097          	auipc	ra,0xffffb
    80006126:	fa8080e7          	jalr	-88(ra) # 800010ca <safestrcpy>
  for(int i=0; i<32; i++){
    8000612a:	0f8a0793          	addi	a5,s4,248
    8000612e:	1f8a0713          	addi	a4,s4,504
    80006132:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006134:	4605                	li	a2,1
    80006136:	a029                	j	80006140 <exec+0x324>
  for(int i=0; i<32; i++){
    80006138:	07a1                	addi	a5,a5,8
    8000613a:	0711                	addi	a4,a4,4
    8000613c:	00f58a63          	beq	a1,a5,80006150 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006140:	6394                	ld	a3,0(a5)
    80006142:	fec68be3          	beq	a3,a2,80006138 <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    80006146:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    8000614a:	00072023          	sw	zero,0(a4)
    8000614e:	b7ed                	j	80006138 <exec+0x31c>
  oldpagetable = p->pagetable;
    80006150:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    80006154:	e0843783          	ld	a5,-504(s0)
    80006158:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    8000615c:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80006160:	040b3783          	ld	a5,64(s6)
    80006164:	e6043703          	ld	a4,-416(s0)
    80006168:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    8000616a:	040b3783          	ld	a5,64(s6)
    8000616e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80006172:	85ea                	mv	a1,s10
    80006174:	ffffc097          	auipc	ra,0xffffc
    80006178:	ddc080e7          	jalr	-548(ra) # 80001f50 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000617c:	0004851b          	sext.w	a0,s1
    80006180:	bb59                	j	80005f16 <exec+0xfa>
    80006182:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    80006186:	de843583          	ld	a1,-536(s0)
    8000618a:	e0843503          	ld	a0,-504(s0)
    8000618e:	ffffc097          	auipc	ra,0xffffc
    80006192:	dc2080e7          	jalr	-574(ra) # 80001f50 <proc_freepagetable>
  if(ip){
    80006196:	d60a96e3          	bnez	s5,80005f02 <exec+0xe6>
  return -1;
    8000619a:	557d                	li	a0,-1
    8000619c:	bbad                	j	80005f16 <exec+0xfa>
    8000619e:	de943423          	sd	s1,-536(s0)
    800061a2:	b7d5                	j	80006186 <exec+0x36a>
    800061a4:	de943423          	sd	s1,-536(s0)
    800061a8:	bff9                	j	80006186 <exec+0x36a>
    800061aa:	de943423          	sd	s1,-536(s0)
    800061ae:	bfe1                	j	80006186 <exec+0x36a>
  sz = sz1;
    800061b0:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800061b4:	4a81                	li	s5,0
    800061b6:	bfc1                	j	80006186 <exec+0x36a>
  sz = sz1;
    800061b8:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800061bc:	4a81                	li	s5,0
    800061be:	b7e1                	j	80006186 <exec+0x36a>
  sz = sz1;
    800061c0:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800061c4:	4a81                	li	s5,0
    800061c6:	b7c1                	j	80006186 <exec+0x36a>
    sz = sz1;
    800061c8:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800061cc:	e0043783          	ld	a5,-512(s0)
    800061d0:	0017869b          	addiw	a3,a5,1
    800061d4:	e0d43023          	sd	a3,-512(s0)
    800061d8:	df843783          	ld	a5,-520(s0)
    800061dc:	0387879b          	addiw	a5,a5,56
    800061e0:	e8045703          	lhu	a4,-384(s0)
    800061e4:	dee6d9e3          	bge	a3,a4,80005fd6 <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800061e8:	2781                	sext.w	a5,a5
    800061ea:	def43c23          	sd	a5,-520(s0)
    800061ee:	03800713          	li	a4,56
    800061f2:	86be                	mv	a3,a5
    800061f4:	e1040613          	addi	a2,s0,-496
    800061f8:	4581                	li	a1,0
    800061fa:	8556                	mv	a0,s5
    800061fc:	fffff097          	auipc	ra,0xfffff
    80006200:	9d6080e7          	jalr	-1578(ra) # 80004bd2 <readi>
    80006204:	03800793          	li	a5,56
    80006208:	f6f51de3          	bne	a0,a5,80006182 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    8000620c:	e1042783          	lw	a5,-496(s0)
    80006210:	4705                	li	a4,1
    80006212:	fae79de3          	bne	a5,a4,800061cc <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    80006216:	e3843603          	ld	a2,-456(s0)
    8000621a:	e3043783          	ld	a5,-464(s0)
    8000621e:	f8f660e3          	bltu	a2,a5,8000619e <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006222:	e2043783          	ld	a5,-480(s0)
    80006226:	963e                	add	a2,a2,a5
    80006228:	f6f66ee3          	bltu	a2,a5,800061a4 <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000622c:	85a6                	mv	a1,s1
    8000622e:	e0843503          	ld	a0,-504(s0)
    80006232:	ffffb097          	auipc	ra,0xffffb
    80006236:	47e080e7          	jalr	1150(ra) # 800016b0 <uvmalloc>
    8000623a:	dea43423          	sd	a0,-536(s0)
    8000623e:	d535                	beqz	a0,800061aa <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80006240:	e2043c03          	ld	s8,-480(s0)
    80006244:	dd843783          	ld	a5,-552(s0)
    80006248:	00fc77b3          	and	a5,s8,a5
    8000624c:	ff8d                	bnez	a5,80006186 <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000624e:	e1842c83          	lw	s9,-488(s0)
    80006252:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006256:	f60b89e3          	beqz	s7,800061c8 <exec+0x3ac>
    8000625a:	89de                	mv	s3,s7
    8000625c:	4481                	li	s1,0
    8000625e:	bb91                	j	80005fb2 <exec+0x196>

0000000080006260 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80006260:	7179                	addi	sp,sp,-48
    80006262:	f406                	sd	ra,40(sp)
    80006264:	f022                	sd	s0,32(sp)
    80006266:	ec26                	sd	s1,24(sp)
    80006268:	e84a                	sd	s2,16(sp)
    8000626a:	1800                	addi	s0,sp,48
    8000626c:	892e                	mv	s2,a1
    8000626e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80006270:	fdc40593          	addi	a1,s0,-36
    80006274:	ffffe097          	auipc	ra,0xffffe
    80006278:	8ac080e7          	jalr	-1876(ra) # 80003b20 <argint>
    8000627c:	04054063          	bltz	a0,800062bc <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80006280:	fdc42703          	lw	a4,-36(s0)
    80006284:	47bd                	li	a5,15
    80006286:	02e7ed63          	bltu	a5,a4,800062c0 <argfd+0x60>
    8000628a:	ffffc097          	auipc	ra,0xffffc
    8000628e:	a8e080e7          	jalr	-1394(ra) # 80001d18 <myproc>
    80006292:	fdc42703          	lw	a4,-36(s0)
    80006296:	00a70793          	addi	a5,a4,10
    8000629a:	078e                	slli	a5,a5,0x3
    8000629c:	953e                	add	a0,a0,a5
    8000629e:	611c                	ld	a5,0(a0)
    800062a0:	c395                	beqz	a5,800062c4 <argfd+0x64>
    return -1;
  if(pfd)
    800062a2:	00090463          	beqz	s2,800062aa <argfd+0x4a>
    *pfd = fd;
    800062a6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800062aa:	4501                	li	a0,0
  if(pf)
    800062ac:	c091                	beqz	s1,800062b0 <argfd+0x50>
    *pf = f;
    800062ae:	e09c                	sd	a5,0(s1)
}
    800062b0:	70a2                	ld	ra,40(sp)
    800062b2:	7402                	ld	s0,32(sp)
    800062b4:	64e2                	ld	s1,24(sp)
    800062b6:	6942                	ld	s2,16(sp)
    800062b8:	6145                	addi	sp,sp,48
    800062ba:	8082                	ret
    return -1;
    800062bc:	557d                	li	a0,-1
    800062be:	bfcd                	j	800062b0 <argfd+0x50>
    return -1;
    800062c0:	557d                	li	a0,-1
    800062c2:	b7fd                	j	800062b0 <argfd+0x50>
    800062c4:	557d                	li	a0,-1
    800062c6:	b7ed                	j	800062b0 <argfd+0x50>

00000000800062c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800062c8:	1101                	addi	sp,sp,-32
    800062ca:	ec06                	sd	ra,24(sp)
    800062cc:	e822                	sd	s0,16(sp)
    800062ce:	e426                	sd	s1,8(sp)
    800062d0:	1000                	addi	s0,sp,32
    800062d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800062d4:	ffffc097          	auipc	ra,0xffffc
    800062d8:	a44080e7          	jalr	-1468(ra) # 80001d18 <myproc>
    800062dc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800062de:	05050793          	addi	a5,a0,80
    800062e2:	4501                	li	a0,0
    800062e4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800062e6:	6398                	ld	a4,0(a5)
    800062e8:	cb19                	beqz	a4,800062fe <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800062ea:	2505                	addiw	a0,a0,1
    800062ec:	07a1                	addi	a5,a5,8
    800062ee:	fed51ce3          	bne	a0,a3,800062e6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800062f2:	557d                	li	a0,-1
}
    800062f4:	60e2                	ld	ra,24(sp)
    800062f6:	6442                	ld	s0,16(sp)
    800062f8:	64a2                	ld	s1,8(sp)
    800062fa:	6105                	addi	sp,sp,32
    800062fc:	8082                	ret
      p->ofile[fd] = f;
    800062fe:	00a50793          	addi	a5,a0,10
    80006302:	078e                	slli	a5,a5,0x3
    80006304:	963e                	add	a2,a2,a5
    80006306:	e204                	sd	s1,0(a2)
      return fd;
    80006308:	b7f5                	j	800062f4 <fdalloc+0x2c>

000000008000630a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000630a:	715d                	addi	sp,sp,-80
    8000630c:	e486                	sd	ra,72(sp)
    8000630e:	e0a2                	sd	s0,64(sp)
    80006310:	fc26                	sd	s1,56(sp)
    80006312:	f84a                	sd	s2,48(sp)
    80006314:	f44e                	sd	s3,40(sp)
    80006316:	f052                	sd	s4,32(sp)
    80006318:	ec56                	sd	s5,24(sp)
    8000631a:	0880                	addi	s0,sp,80
    8000631c:	89ae                	mv	s3,a1
    8000631e:	8ab2                	mv	s5,a2
    80006320:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006322:	fb040593          	addi	a1,s0,-80
    80006326:	fffff097          	auipc	ra,0xfffff
    8000632a:	dca080e7          	jalr	-566(ra) # 800050f0 <nameiparent>
    8000632e:	892a                	mv	s2,a0
    80006330:	12050e63          	beqz	a0,8000646c <create+0x162>
    return 0;

  ilock(dp);
    80006334:	ffffe097          	auipc	ra,0xffffe
    80006338:	5ea080e7          	jalr	1514(ra) # 8000491e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000633c:	4601                	li	a2,0
    8000633e:	fb040593          	addi	a1,s0,-80
    80006342:	854a                	mv	a0,s2
    80006344:	fffff097          	auipc	ra,0xfffff
    80006348:	abe080e7          	jalr	-1346(ra) # 80004e02 <dirlookup>
    8000634c:	84aa                	mv	s1,a0
    8000634e:	c921                	beqz	a0,8000639e <create+0x94>
    iunlockput(dp);
    80006350:	854a                	mv	a0,s2
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	82e080e7          	jalr	-2002(ra) # 80004b80 <iunlockput>
    ilock(ip);
    8000635a:	8526                	mv	a0,s1
    8000635c:	ffffe097          	auipc	ra,0xffffe
    80006360:	5c2080e7          	jalr	1474(ra) # 8000491e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006364:	2981                	sext.w	s3,s3
    80006366:	4789                	li	a5,2
    80006368:	02f99463          	bne	s3,a5,80006390 <create+0x86>
    8000636c:	0444d783          	lhu	a5,68(s1)
    80006370:	37f9                	addiw	a5,a5,-2
    80006372:	17c2                	slli	a5,a5,0x30
    80006374:	93c1                	srli	a5,a5,0x30
    80006376:	4705                	li	a4,1
    80006378:	00f76c63          	bltu	a4,a5,80006390 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000637c:	8526                	mv	a0,s1
    8000637e:	60a6                	ld	ra,72(sp)
    80006380:	6406                	ld	s0,64(sp)
    80006382:	74e2                	ld	s1,56(sp)
    80006384:	7942                	ld	s2,48(sp)
    80006386:	79a2                	ld	s3,40(sp)
    80006388:	7a02                	ld	s4,32(sp)
    8000638a:	6ae2                	ld	s5,24(sp)
    8000638c:	6161                	addi	sp,sp,80
    8000638e:	8082                	ret
    iunlockput(ip);
    80006390:	8526                	mv	a0,s1
    80006392:	ffffe097          	auipc	ra,0xffffe
    80006396:	7ee080e7          	jalr	2030(ra) # 80004b80 <iunlockput>
    return 0;
    8000639a:	4481                	li	s1,0
    8000639c:	b7c5                	j	8000637c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000639e:	85ce                	mv	a1,s3
    800063a0:	00092503          	lw	a0,0(s2)
    800063a4:	ffffe097          	auipc	ra,0xffffe
    800063a8:	3e2080e7          	jalr	994(ra) # 80004786 <ialloc>
    800063ac:	84aa                	mv	s1,a0
    800063ae:	c521                	beqz	a0,800063f6 <create+0xec>
  ilock(ip);
    800063b0:	ffffe097          	auipc	ra,0xffffe
    800063b4:	56e080e7          	jalr	1390(ra) # 8000491e <ilock>
  ip->major = major;
    800063b8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800063bc:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800063c0:	4a05                	li	s4,1
    800063c2:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800063c6:	8526                	mv	a0,s1
    800063c8:	ffffe097          	auipc	ra,0xffffe
    800063cc:	48c080e7          	jalr	1164(ra) # 80004854 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800063d0:	2981                	sext.w	s3,s3
    800063d2:	03498a63          	beq	s3,s4,80006406 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800063d6:	40d0                	lw	a2,4(s1)
    800063d8:	fb040593          	addi	a1,s0,-80
    800063dc:	854a                	mv	a0,s2
    800063de:	fffff097          	auipc	ra,0xfffff
    800063e2:	c32080e7          	jalr	-974(ra) # 80005010 <dirlink>
    800063e6:	06054b63          	bltz	a0,8000645c <create+0x152>
  iunlockput(dp);
    800063ea:	854a                	mv	a0,s2
    800063ec:	ffffe097          	auipc	ra,0xffffe
    800063f0:	794080e7          	jalr	1940(ra) # 80004b80 <iunlockput>
  return ip;
    800063f4:	b761                	j	8000637c <create+0x72>
    panic("create: ialloc");
    800063f6:	00003517          	auipc	a0,0x3
    800063fa:	3e250513          	addi	a0,a0,994 # 800097d8 <syscalls+0x2f8>
    800063fe:	ffffa097          	auipc	ra,0xffffa
    80006402:	130080e7          	jalr	304(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80006406:	04a95783          	lhu	a5,74(s2)
    8000640a:	2785                	addiw	a5,a5,1
    8000640c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006410:	854a                	mv	a0,s2
    80006412:	ffffe097          	auipc	ra,0xffffe
    80006416:	442080e7          	jalr	1090(ra) # 80004854 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000641a:	40d0                	lw	a2,4(s1)
    8000641c:	00003597          	auipc	a1,0x3
    80006420:	3cc58593          	addi	a1,a1,972 # 800097e8 <syscalls+0x308>
    80006424:	8526                	mv	a0,s1
    80006426:	fffff097          	auipc	ra,0xfffff
    8000642a:	bea080e7          	jalr	-1046(ra) # 80005010 <dirlink>
    8000642e:	00054f63          	bltz	a0,8000644c <create+0x142>
    80006432:	00492603          	lw	a2,4(s2)
    80006436:	00003597          	auipc	a1,0x3
    8000643a:	3ba58593          	addi	a1,a1,954 # 800097f0 <syscalls+0x310>
    8000643e:	8526                	mv	a0,s1
    80006440:	fffff097          	auipc	ra,0xfffff
    80006444:	bd0080e7          	jalr	-1072(ra) # 80005010 <dirlink>
    80006448:	f80557e3          	bgez	a0,800063d6 <create+0xcc>
      panic("create dots");
    8000644c:	00003517          	auipc	a0,0x3
    80006450:	3ac50513          	addi	a0,a0,940 # 800097f8 <syscalls+0x318>
    80006454:	ffffa097          	auipc	ra,0xffffa
    80006458:	0da080e7          	jalr	218(ra) # 8000052e <panic>
    panic("create: dirlink");
    8000645c:	00003517          	auipc	a0,0x3
    80006460:	3ac50513          	addi	a0,a0,940 # 80009808 <syscalls+0x328>
    80006464:	ffffa097          	auipc	ra,0xffffa
    80006468:	0ca080e7          	jalr	202(ra) # 8000052e <panic>
    return 0;
    8000646c:	84aa                	mv	s1,a0
    8000646e:	b739                	j	8000637c <create+0x72>

0000000080006470 <sys_dup>:
{
    80006470:	7179                	addi	sp,sp,-48
    80006472:	f406                	sd	ra,40(sp)
    80006474:	f022                	sd	s0,32(sp)
    80006476:	ec26                	sd	s1,24(sp)
    80006478:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000647a:	fd840613          	addi	a2,s0,-40
    8000647e:	4581                	li	a1,0
    80006480:	4501                	li	a0,0
    80006482:	00000097          	auipc	ra,0x0
    80006486:	dde080e7          	jalr	-546(ra) # 80006260 <argfd>
    return -1;
    8000648a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000648c:	02054363          	bltz	a0,800064b2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006490:	fd843503          	ld	a0,-40(s0)
    80006494:	00000097          	auipc	ra,0x0
    80006498:	e34080e7          	jalr	-460(ra) # 800062c8 <fdalloc>
    8000649c:	84aa                	mv	s1,a0
    return -1;
    8000649e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800064a0:	00054963          	bltz	a0,800064b2 <sys_dup+0x42>
  filedup(f);
    800064a4:	fd843503          	ld	a0,-40(s0)
    800064a8:	fffff097          	auipc	ra,0xfffff
    800064ac:	2c4080e7          	jalr	708(ra) # 8000576c <filedup>
  return fd;
    800064b0:	87a6                	mv	a5,s1
}
    800064b2:	853e                	mv	a0,a5
    800064b4:	70a2                	ld	ra,40(sp)
    800064b6:	7402                	ld	s0,32(sp)
    800064b8:	64e2                	ld	s1,24(sp)
    800064ba:	6145                	addi	sp,sp,48
    800064bc:	8082                	ret

00000000800064be <sys_read>:
{
    800064be:	7179                	addi	sp,sp,-48
    800064c0:	f406                	sd	ra,40(sp)
    800064c2:	f022                	sd	s0,32(sp)
    800064c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800064c6:	fe840613          	addi	a2,s0,-24
    800064ca:	4581                	li	a1,0
    800064cc:	4501                	li	a0,0
    800064ce:	00000097          	auipc	ra,0x0
    800064d2:	d92080e7          	jalr	-622(ra) # 80006260 <argfd>
    return -1;
    800064d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800064d8:	04054163          	bltz	a0,8000651a <sys_read+0x5c>
    800064dc:	fe440593          	addi	a1,s0,-28
    800064e0:	4509                	li	a0,2
    800064e2:	ffffd097          	auipc	ra,0xffffd
    800064e6:	63e080e7          	jalr	1598(ra) # 80003b20 <argint>
    return -1;
    800064ea:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800064ec:	02054763          	bltz	a0,8000651a <sys_read+0x5c>
    800064f0:	fd840593          	addi	a1,s0,-40
    800064f4:	4505                	li	a0,1
    800064f6:	ffffd097          	auipc	ra,0xffffd
    800064fa:	64c080e7          	jalr	1612(ra) # 80003b42 <argaddr>
    return -1;
    800064fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006500:	00054d63          	bltz	a0,8000651a <sys_read+0x5c>
  return fileread(f, p, n);
    80006504:	fe442603          	lw	a2,-28(s0)
    80006508:	fd843583          	ld	a1,-40(s0)
    8000650c:	fe843503          	ld	a0,-24(s0)
    80006510:	fffff097          	auipc	ra,0xfffff
    80006514:	3e8080e7          	jalr	1000(ra) # 800058f8 <fileread>
    80006518:	87aa                	mv	a5,a0
}
    8000651a:	853e                	mv	a0,a5
    8000651c:	70a2                	ld	ra,40(sp)
    8000651e:	7402                	ld	s0,32(sp)
    80006520:	6145                	addi	sp,sp,48
    80006522:	8082                	ret

0000000080006524 <sys_write>:
{
    80006524:	7179                	addi	sp,sp,-48
    80006526:	f406                	sd	ra,40(sp)
    80006528:	f022                	sd	s0,32(sp)
    8000652a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000652c:	fe840613          	addi	a2,s0,-24
    80006530:	4581                	li	a1,0
    80006532:	4501                	li	a0,0
    80006534:	00000097          	auipc	ra,0x0
    80006538:	d2c080e7          	jalr	-724(ra) # 80006260 <argfd>
    return -1;
    8000653c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000653e:	04054163          	bltz	a0,80006580 <sys_write+0x5c>
    80006542:	fe440593          	addi	a1,s0,-28
    80006546:	4509                	li	a0,2
    80006548:	ffffd097          	auipc	ra,0xffffd
    8000654c:	5d8080e7          	jalr	1496(ra) # 80003b20 <argint>
    return -1;
    80006550:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006552:	02054763          	bltz	a0,80006580 <sys_write+0x5c>
    80006556:	fd840593          	addi	a1,s0,-40
    8000655a:	4505                	li	a0,1
    8000655c:	ffffd097          	auipc	ra,0xffffd
    80006560:	5e6080e7          	jalr	1510(ra) # 80003b42 <argaddr>
    return -1;
    80006564:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006566:	00054d63          	bltz	a0,80006580 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000656a:	fe442603          	lw	a2,-28(s0)
    8000656e:	fd843583          	ld	a1,-40(s0)
    80006572:	fe843503          	ld	a0,-24(s0)
    80006576:	fffff097          	auipc	ra,0xfffff
    8000657a:	444080e7          	jalr	1092(ra) # 800059ba <filewrite>
    8000657e:	87aa                	mv	a5,a0
}
    80006580:	853e                	mv	a0,a5
    80006582:	70a2                	ld	ra,40(sp)
    80006584:	7402                	ld	s0,32(sp)
    80006586:	6145                	addi	sp,sp,48
    80006588:	8082                	ret

000000008000658a <sys_close>:
{
    8000658a:	1101                	addi	sp,sp,-32
    8000658c:	ec06                	sd	ra,24(sp)
    8000658e:	e822                	sd	s0,16(sp)
    80006590:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80006592:	fe040613          	addi	a2,s0,-32
    80006596:	fec40593          	addi	a1,s0,-20
    8000659a:	4501                	li	a0,0
    8000659c:	00000097          	auipc	ra,0x0
    800065a0:	cc4080e7          	jalr	-828(ra) # 80006260 <argfd>
    return -1;
    800065a4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800065a6:	02054463          	bltz	a0,800065ce <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800065aa:	ffffb097          	auipc	ra,0xffffb
    800065ae:	76e080e7          	jalr	1902(ra) # 80001d18 <myproc>
    800065b2:	fec42783          	lw	a5,-20(s0)
    800065b6:	07a9                	addi	a5,a5,10
    800065b8:	078e                	slli	a5,a5,0x3
    800065ba:	97aa                	add	a5,a5,a0
    800065bc:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800065c0:	fe043503          	ld	a0,-32(s0)
    800065c4:	fffff097          	auipc	ra,0xfffff
    800065c8:	1fa080e7          	jalr	506(ra) # 800057be <fileclose>
  return 0;
    800065cc:	4781                	li	a5,0
}
    800065ce:	853e                	mv	a0,a5
    800065d0:	60e2                	ld	ra,24(sp)
    800065d2:	6442                	ld	s0,16(sp)
    800065d4:	6105                	addi	sp,sp,32
    800065d6:	8082                	ret

00000000800065d8 <sys_fstat>:
{
    800065d8:	1101                	addi	sp,sp,-32
    800065da:	ec06                	sd	ra,24(sp)
    800065dc:	e822                	sd	s0,16(sp)
    800065de:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800065e0:	fe840613          	addi	a2,s0,-24
    800065e4:	4581                	li	a1,0
    800065e6:	4501                	li	a0,0
    800065e8:	00000097          	auipc	ra,0x0
    800065ec:	c78080e7          	jalr	-904(ra) # 80006260 <argfd>
    return -1;
    800065f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800065f2:	02054563          	bltz	a0,8000661c <sys_fstat+0x44>
    800065f6:	fe040593          	addi	a1,s0,-32
    800065fa:	4505                	li	a0,1
    800065fc:	ffffd097          	auipc	ra,0xffffd
    80006600:	546080e7          	jalr	1350(ra) # 80003b42 <argaddr>
    return -1;
    80006604:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006606:	00054b63          	bltz	a0,8000661c <sys_fstat+0x44>
  return filestat(f, st);
    8000660a:	fe043583          	ld	a1,-32(s0)
    8000660e:	fe843503          	ld	a0,-24(s0)
    80006612:	fffff097          	auipc	ra,0xfffff
    80006616:	274080e7          	jalr	628(ra) # 80005886 <filestat>
    8000661a:	87aa                	mv	a5,a0
}
    8000661c:	853e                	mv	a0,a5
    8000661e:	60e2                	ld	ra,24(sp)
    80006620:	6442                	ld	s0,16(sp)
    80006622:	6105                	addi	sp,sp,32
    80006624:	8082                	ret

0000000080006626 <sys_link>:
{
    80006626:	7169                	addi	sp,sp,-304
    80006628:	f606                	sd	ra,296(sp)
    8000662a:	f222                	sd	s0,288(sp)
    8000662c:	ee26                	sd	s1,280(sp)
    8000662e:	ea4a                	sd	s2,272(sp)
    80006630:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006632:	08000613          	li	a2,128
    80006636:	ed040593          	addi	a1,s0,-304
    8000663a:	4501                	li	a0,0
    8000663c:	ffffd097          	auipc	ra,0xffffd
    80006640:	528080e7          	jalr	1320(ra) # 80003b64 <argstr>
    return -1;
    80006644:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006646:	10054e63          	bltz	a0,80006762 <sys_link+0x13c>
    8000664a:	08000613          	li	a2,128
    8000664e:	f5040593          	addi	a1,s0,-176
    80006652:	4505                	li	a0,1
    80006654:	ffffd097          	auipc	ra,0xffffd
    80006658:	510080e7          	jalr	1296(ra) # 80003b64 <argstr>
    return -1;
    8000665c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000665e:	10054263          	bltz	a0,80006762 <sys_link+0x13c>
  begin_op();
    80006662:	fffff097          	auipc	ra,0xfffff
    80006666:	c90080e7          	jalr	-880(ra) # 800052f2 <begin_op>
  if((ip = namei(old)) == 0){
    8000666a:	ed040513          	addi	a0,s0,-304
    8000666e:	fffff097          	auipc	ra,0xfffff
    80006672:	a64080e7          	jalr	-1436(ra) # 800050d2 <namei>
    80006676:	84aa                	mv	s1,a0
    80006678:	c551                	beqz	a0,80006704 <sys_link+0xde>
  ilock(ip);
    8000667a:	ffffe097          	auipc	ra,0xffffe
    8000667e:	2a4080e7          	jalr	676(ra) # 8000491e <ilock>
  if(ip->type == T_DIR){
    80006682:	04449703          	lh	a4,68(s1)
    80006686:	4785                	li	a5,1
    80006688:	08f70463          	beq	a4,a5,80006710 <sys_link+0xea>
  ip->nlink++;
    8000668c:	04a4d783          	lhu	a5,74(s1)
    80006690:	2785                	addiw	a5,a5,1
    80006692:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006696:	8526                	mv	a0,s1
    80006698:	ffffe097          	auipc	ra,0xffffe
    8000669c:	1bc080e7          	jalr	444(ra) # 80004854 <iupdate>
  iunlock(ip);
    800066a0:	8526                	mv	a0,s1
    800066a2:	ffffe097          	auipc	ra,0xffffe
    800066a6:	33e080e7          	jalr	830(ra) # 800049e0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800066aa:	fd040593          	addi	a1,s0,-48
    800066ae:	f5040513          	addi	a0,s0,-176
    800066b2:	fffff097          	auipc	ra,0xfffff
    800066b6:	a3e080e7          	jalr	-1474(ra) # 800050f0 <nameiparent>
    800066ba:	892a                	mv	s2,a0
    800066bc:	c935                	beqz	a0,80006730 <sys_link+0x10a>
  ilock(dp);
    800066be:	ffffe097          	auipc	ra,0xffffe
    800066c2:	260080e7          	jalr	608(ra) # 8000491e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800066c6:	00092703          	lw	a4,0(s2)
    800066ca:	409c                	lw	a5,0(s1)
    800066cc:	04f71d63          	bne	a4,a5,80006726 <sys_link+0x100>
    800066d0:	40d0                	lw	a2,4(s1)
    800066d2:	fd040593          	addi	a1,s0,-48
    800066d6:	854a                	mv	a0,s2
    800066d8:	fffff097          	auipc	ra,0xfffff
    800066dc:	938080e7          	jalr	-1736(ra) # 80005010 <dirlink>
    800066e0:	04054363          	bltz	a0,80006726 <sys_link+0x100>
  iunlockput(dp);
    800066e4:	854a                	mv	a0,s2
    800066e6:	ffffe097          	auipc	ra,0xffffe
    800066ea:	49a080e7          	jalr	1178(ra) # 80004b80 <iunlockput>
  iput(ip);
    800066ee:	8526                	mv	a0,s1
    800066f0:	ffffe097          	auipc	ra,0xffffe
    800066f4:	3e8080e7          	jalr	1000(ra) # 80004ad8 <iput>
  end_op();
    800066f8:	fffff097          	auipc	ra,0xfffff
    800066fc:	c7a080e7          	jalr	-902(ra) # 80005372 <end_op>
  return 0;
    80006700:	4781                	li	a5,0
    80006702:	a085                	j	80006762 <sys_link+0x13c>
    end_op();
    80006704:	fffff097          	auipc	ra,0xfffff
    80006708:	c6e080e7          	jalr	-914(ra) # 80005372 <end_op>
    return -1;
    8000670c:	57fd                	li	a5,-1
    8000670e:	a891                	j	80006762 <sys_link+0x13c>
    iunlockput(ip);
    80006710:	8526                	mv	a0,s1
    80006712:	ffffe097          	auipc	ra,0xffffe
    80006716:	46e080e7          	jalr	1134(ra) # 80004b80 <iunlockput>
    end_op();
    8000671a:	fffff097          	auipc	ra,0xfffff
    8000671e:	c58080e7          	jalr	-936(ra) # 80005372 <end_op>
    return -1;
    80006722:	57fd                	li	a5,-1
    80006724:	a83d                	j	80006762 <sys_link+0x13c>
    iunlockput(dp);
    80006726:	854a                	mv	a0,s2
    80006728:	ffffe097          	auipc	ra,0xffffe
    8000672c:	458080e7          	jalr	1112(ra) # 80004b80 <iunlockput>
  ilock(ip);
    80006730:	8526                	mv	a0,s1
    80006732:	ffffe097          	auipc	ra,0xffffe
    80006736:	1ec080e7          	jalr	492(ra) # 8000491e <ilock>
  ip->nlink--;
    8000673a:	04a4d783          	lhu	a5,74(s1)
    8000673e:	37fd                	addiw	a5,a5,-1
    80006740:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006744:	8526                	mv	a0,s1
    80006746:	ffffe097          	auipc	ra,0xffffe
    8000674a:	10e080e7          	jalr	270(ra) # 80004854 <iupdate>
  iunlockput(ip);
    8000674e:	8526                	mv	a0,s1
    80006750:	ffffe097          	auipc	ra,0xffffe
    80006754:	430080e7          	jalr	1072(ra) # 80004b80 <iunlockput>
  end_op();
    80006758:	fffff097          	auipc	ra,0xfffff
    8000675c:	c1a080e7          	jalr	-998(ra) # 80005372 <end_op>
  return -1;
    80006760:	57fd                	li	a5,-1
}
    80006762:	853e                	mv	a0,a5
    80006764:	70b2                	ld	ra,296(sp)
    80006766:	7412                	ld	s0,288(sp)
    80006768:	64f2                	ld	s1,280(sp)
    8000676a:	6952                	ld	s2,272(sp)
    8000676c:	6155                	addi	sp,sp,304
    8000676e:	8082                	ret

0000000080006770 <sys_unlink>:
{
    80006770:	7151                	addi	sp,sp,-240
    80006772:	f586                	sd	ra,232(sp)
    80006774:	f1a2                	sd	s0,224(sp)
    80006776:	eda6                	sd	s1,216(sp)
    80006778:	e9ca                	sd	s2,208(sp)
    8000677a:	e5ce                	sd	s3,200(sp)
    8000677c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000677e:	08000613          	li	a2,128
    80006782:	f3040593          	addi	a1,s0,-208
    80006786:	4501                	li	a0,0
    80006788:	ffffd097          	auipc	ra,0xffffd
    8000678c:	3dc080e7          	jalr	988(ra) # 80003b64 <argstr>
    80006790:	18054163          	bltz	a0,80006912 <sys_unlink+0x1a2>
  begin_op();
    80006794:	fffff097          	auipc	ra,0xfffff
    80006798:	b5e080e7          	jalr	-1186(ra) # 800052f2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000679c:	fb040593          	addi	a1,s0,-80
    800067a0:	f3040513          	addi	a0,s0,-208
    800067a4:	fffff097          	auipc	ra,0xfffff
    800067a8:	94c080e7          	jalr	-1716(ra) # 800050f0 <nameiparent>
    800067ac:	84aa                	mv	s1,a0
    800067ae:	c979                	beqz	a0,80006884 <sys_unlink+0x114>
  ilock(dp);
    800067b0:	ffffe097          	auipc	ra,0xffffe
    800067b4:	16e080e7          	jalr	366(ra) # 8000491e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800067b8:	00003597          	auipc	a1,0x3
    800067bc:	03058593          	addi	a1,a1,48 # 800097e8 <syscalls+0x308>
    800067c0:	fb040513          	addi	a0,s0,-80
    800067c4:	ffffe097          	auipc	ra,0xffffe
    800067c8:	624080e7          	jalr	1572(ra) # 80004de8 <namecmp>
    800067cc:	14050a63          	beqz	a0,80006920 <sys_unlink+0x1b0>
    800067d0:	00003597          	auipc	a1,0x3
    800067d4:	02058593          	addi	a1,a1,32 # 800097f0 <syscalls+0x310>
    800067d8:	fb040513          	addi	a0,s0,-80
    800067dc:	ffffe097          	auipc	ra,0xffffe
    800067e0:	60c080e7          	jalr	1548(ra) # 80004de8 <namecmp>
    800067e4:	12050e63          	beqz	a0,80006920 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800067e8:	f2c40613          	addi	a2,s0,-212
    800067ec:	fb040593          	addi	a1,s0,-80
    800067f0:	8526                	mv	a0,s1
    800067f2:	ffffe097          	auipc	ra,0xffffe
    800067f6:	610080e7          	jalr	1552(ra) # 80004e02 <dirlookup>
    800067fa:	892a                	mv	s2,a0
    800067fc:	12050263          	beqz	a0,80006920 <sys_unlink+0x1b0>
  ilock(ip);
    80006800:	ffffe097          	auipc	ra,0xffffe
    80006804:	11e080e7          	jalr	286(ra) # 8000491e <ilock>
  if(ip->nlink < 1)
    80006808:	04a91783          	lh	a5,74(s2)
    8000680c:	08f05263          	blez	a5,80006890 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006810:	04491703          	lh	a4,68(s2)
    80006814:	4785                	li	a5,1
    80006816:	08f70563          	beq	a4,a5,800068a0 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000681a:	4641                	li	a2,16
    8000681c:	4581                	li	a1,0
    8000681e:	fc040513          	addi	a0,s0,-64
    80006822:	ffffa097          	auipc	ra,0xffffa
    80006826:	756080e7          	jalr	1878(ra) # 80000f78 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000682a:	4741                	li	a4,16
    8000682c:	f2c42683          	lw	a3,-212(s0)
    80006830:	fc040613          	addi	a2,s0,-64
    80006834:	4581                	li	a1,0
    80006836:	8526                	mv	a0,s1
    80006838:	ffffe097          	auipc	ra,0xffffe
    8000683c:	492080e7          	jalr	1170(ra) # 80004cca <writei>
    80006840:	47c1                	li	a5,16
    80006842:	0af51563          	bne	a0,a5,800068ec <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006846:	04491703          	lh	a4,68(s2)
    8000684a:	4785                	li	a5,1
    8000684c:	0af70863          	beq	a4,a5,800068fc <sys_unlink+0x18c>
  iunlockput(dp);
    80006850:	8526                	mv	a0,s1
    80006852:	ffffe097          	auipc	ra,0xffffe
    80006856:	32e080e7          	jalr	814(ra) # 80004b80 <iunlockput>
  ip->nlink--;
    8000685a:	04a95783          	lhu	a5,74(s2)
    8000685e:	37fd                	addiw	a5,a5,-1
    80006860:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006864:	854a                	mv	a0,s2
    80006866:	ffffe097          	auipc	ra,0xffffe
    8000686a:	fee080e7          	jalr	-18(ra) # 80004854 <iupdate>
  iunlockput(ip);
    8000686e:	854a                	mv	a0,s2
    80006870:	ffffe097          	auipc	ra,0xffffe
    80006874:	310080e7          	jalr	784(ra) # 80004b80 <iunlockput>
  end_op();
    80006878:	fffff097          	auipc	ra,0xfffff
    8000687c:	afa080e7          	jalr	-1286(ra) # 80005372 <end_op>
  return 0;
    80006880:	4501                	li	a0,0
    80006882:	a84d                	j	80006934 <sys_unlink+0x1c4>
    end_op();
    80006884:	fffff097          	auipc	ra,0xfffff
    80006888:	aee080e7          	jalr	-1298(ra) # 80005372 <end_op>
    return -1;
    8000688c:	557d                	li	a0,-1
    8000688e:	a05d                	j	80006934 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006890:	00003517          	auipc	a0,0x3
    80006894:	f8850513          	addi	a0,a0,-120 # 80009818 <syscalls+0x338>
    80006898:	ffffa097          	auipc	ra,0xffffa
    8000689c:	c96080e7          	jalr	-874(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800068a0:	04c92703          	lw	a4,76(s2)
    800068a4:	02000793          	li	a5,32
    800068a8:	f6e7f9e3          	bgeu	a5,a4,8000681a <sys_unlink+0xaa>
    800068ac:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800068b0:	4741                	li	a4,16
    800068b2:	86ce                	mv	a3,s3
    800068b4:	f1840613          	addi	a2,s0,-232
    800068b8:	4581                	li	a1,0
    800068ba:	854a                	mv	a0,s2
    800068bc:	ffffe097          	auipc	ra,0xffffe
    800068c0:	316080e7          	jalr	790(ra) # 80004bd2 <readi>
    800068c4:	47c1                	li	a5,16
    800068c6:	00f51b63          	bne	a0,a5,800068dc <sys_unlink+0x16c>
    if(de.inum != 0)
    800068ca:	f1845783          	lhu	a5,-232(s0)
    800068ce:	e7a1                	bnez	a5,80006916 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800068d0:	29c1                	addiw	s3,s3,16
    800068d2:	04c92783          	lw	a5,76(s2)
    800068d6:	fcf9ede3          	bltu	s3,a5,800068b0 <sys_unlink+0x140>
    800068da:	b781                	j	8000681a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800068dc:	00003517          	auipc	a0,0x3
    800068e0:	f5450513          	addi	a0,a0,-172 # 80009830 <syscalls+0x350>
    800068e4:	ffffa097          	auipc	ra,0xffffa
    800068e8:	c4a080e7          	jalr	-950(ra) # 8000052e <panic>
    panic("unlink: writei");
    800068ec:	00003517          	auipc	a0,0x3
    800068f0:	f5c50513          	addi	a0,a0,-164 # 80009848 <syscalls+0x368>
    800068f4:	ffffa097          	auipc	ra,0xffffa
    800068f8:	c3a080e7          	jalr	-966(ra) # 8000052e <panic>
    dp->nlink--;
    800068fc:	04a4d783          	lhu	a5,74(s1)
    80006900:	37fd                	addiw	a5,a5,-1
    80006902:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006906:	8526                	mv	a0,s1
    80006908:	ffffe097          	auipc	ra,0xffffe
    8000690c:	f4c080e7          	jalr	-180(ra) # 80004854 <iupdate>
    80006910:	b781                	j	80006850 <sys_unlink+0xe0>
    return -1;
    80006912:	557d                	li	a0,-1
    80006914:	a005                	j	80006934 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006916:	854a                	mv	a0,s2
    80006918:	ffffe097          	auipc	ra,0xffffe
    8000691c:	268080e7          	jalr	616(ra) # 80004b80 <iunlockput>
  iunlockput(dp);
    80006920:	8526                	mv	a0,s1
    80006922:	ffffe097          	auipc	ra,0xffffe
    80006926:	25e080e7          	jalr	606(ra) # 80004b80 <iunlockput>
  end_op();
    8000692a:	fffff097          	auipc	ra,0xfffff
    8000692e:	a48080e7          	jalr	-1464(ra) # 80005372 <end_op>
  return -1;
    80006932:	557d                	li	a0,-1
}
    80006934:	70ae                	ld	ra,232(sp)
    80006936:	740e                	ld	s0,224(sp)
    80006938:	64ee                	ld	s1,216(sp)
    8000693a:	694e                	ld	s2,208(sp)
    8000693c:	69ae                	ld	s3,200(sp)
    8000693e:	616d                	addi	sp,sp,240
    80006940:	8082                	ret

0000000080006942 <sys_open>:

uint64
sys_open(void)
{
    80006942:	7131                	addi	sp,sp,-192
    80006944:	fd06                	sd	ra,184(sp)
    80006946:	f922                	sd	s0,176(sp)
    80006948:	f526                	sd	s1,168(sp)
    8000694a:	f14a                	sd	s2,160(sp)
    8000694c:	ed4e                	sd	s3,152(sp)
    8000694e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006950:	08000613          	li	a2,128
    80006954:	f5040593          	addi	a1,s0,-176
    80006958:	4501                	li	a0,0
    8000695a:	ffffd097          	auipc	ra,0xffffd
    8000695e:	20a080e7          	jalr	522(ra) # 80003b64 <argstr>
    return -1;
    80006962:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006964:	0c054163          	bltz	a0,80006a26 <sys_open+0xe4>
    80006968:	f4c40593          	addi	a1,s0,-180
    8000696c:	4505                	li	a0,1
    8000696e:	ffffd097          	auipc	ra,0xffffd
    80006972:	1b2080e7          	jalr	434(ra) # 80003b20 <argint>
    80006976:	0a054863          	bltz	a0,80006a26 <sys_open+0xe4>

  begin_op();
    8000697a:	fffff097          	auipc	ra,0xfffff
    8000697e:	978080e7          	jalr	-1672(ra) # 800052f2 <begin_op>

  if(omode & O_CREATE){
    80006982:	f4c42783          	lw	a5,-180(s0)
    80006986:	2007f793          	andi	a5,a5,512
    8000698a:	cbdd                	beqz	a5,80006a40 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000698c:	4681                	li	a3,0
    8000698e:	4601                	li	a2,0
    80006990:	4589                	li	a1,2
    80006992:	f5040513          	addi	a0,s0,-176
    80006996:	00000097          	auipc	ra,0x0
    8000699a:	974080e7          	jalr	-1676(ra) # 8000630a <create>
    8000699e:	892a                	mv	s2,a0
    if(ip == 0){
    800069a0:	c959                	beqz	a0,80006a36 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800069a2:	04491703          	lh	a4,68(s2)
    800069a6:	478d                	li	a5,3
    800069a8:	00f71763          	bne	a4,a5,800069b6 <sys_open+0x74>
    800069ac:	04695703          	lhu	a4,70(s2)
    800069b0:	47a5                	li	a5,9
    800069b2:	0ce7ec63          	bltu	a5,a4,80006a8a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800069b6:	fffff097          	auipc	ra,0xfffff
    800069ba:	d4c080e7          	jalr	-692(ra) # 80005702 <filealloc>
    800069be:	89aa                	mv	s3,a0
    800069c0:	10050263          	beqz	a0,80006ac4 <sys_open+0x182>
    800069c4:	00000097          	auipc	ra,0x0
    800069c8:	904080e7          	jalr	-1788(ra) # 800062c8 <fdalloc>
    800069cc:	84aa                	mv	s1,a0
    800069ce:	0e054663          	bltz	a0,80006aba <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800069d2:	04491703          	lh	a4,68(s2)
    800069d6:	478d                	li	a5,3
    800069d8:	0cf70463          	beq	a4,a5,80006aa0 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800069dc:	4789                	li	a5,2
    800069de:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800069e2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800069e6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800069ea:	f4c42783          	lw	a5,-180(s0)
    800069ee:	0017c713          	xori	a4,a5,1
    800069f2:	8b05                	andi	a4,a4,1
    800069f4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800069f8:	0037f713          	andi	a4,a5,3
    800069fc:	00e03733          	snez	a4,a4
    80006a00:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006a04:	4007f793          	andi	a5,a5,1024
    80006a08:	c791                	beqz	a5,80006a14 <sys_open+0xd2>
    80006a0a:	04491703          	lh	a4,68(s2)
    80006a0e:	4789                	li	a5,2
    80006a10:	08f70f63          	beq	a4,a5,80006aae <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006a14:	854a                	mv	a0,s2
    80006a16:	ffffe097          	auipc	ra,0xffffe
    80006a1a:	fca080e7          	jalr	-54(ra) # 800049e0 <iunlock>
  end_op();
    80006a1e:	fffff097          	auipc	ra,0xfffff
    80006a22:	954080e7          	jalr	-1708(ra) # 80005372 <end_op>

  return fd;
}
    80006a26:	8526                	mv	a0,s1
    80006a28:	70ea                	ld	ra,184(sp)
    80006a2a:	744a                	ld	s0,176(sp)
    80006a2c:	74aa                	ld	s1,168(sp)
    80006a2e:	790a                	ld	s2,160(sp)
    80006a30:	69ea                	ld	s3,152(sp)
    80006a32:	6129                	addi	sp,sp,192
    80006a34:	8082                	ret
      end_op();
    80006a36:	fffff097          	auipc	ra,0xfffff
    80006a3a:	93c080e7          	jalr	-1732(ra) # 80005372 <end_op>
      return -1;
    80006a3e:	b7e5                	j	80006a26 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006a40:	f5040513          	addi	a0,s0,-176
    80006a44:	ffffe097          	auipc	ra,0xffffe
    80006a48:	68e080e7          	jalr	1678(ra) # 800050d2 <namei>
    80006a4c:	892a                	mv	s2,a0
    80006a4e:	c905                	beqz	a0,80006a7e <sys_open+0x13c>
    ilock(ip);
    80006a50:	ffffe097          	auipc	ra,0xffffe
    80006a54:	ece080e7          	jalr	-306(ra) # 8000491e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006a58:	04491703          	lh	a4,68(s2)
    80006a5c:	4785                	li	a5,1
    80006a5e:	f4f712e3          	bne	a4,a5,800069a2 <sys_open+0x60>
    80006a62:	f4c42783          	lw	a5,-180(s0)
    80006a66:	dba1                	beqz	a5,800069b6 <sys_open+0x74>
      iunlockput(ip);
    80006a68:	854a                	mv	a0,s2
    80006a6a:	ffffe097          	auipc	ra,0xffffe
    80006a6e:	116080e7          	jalr	278(ra) # 80004b80 <iunlockput>
      end_op();
    80006a72:	fffff097          	auipc	ra,0xfffff
    80006a76:	900080e7          	jalr	-1792(ra) # 80005372 <end_op>
      return -1;
    80006a7a:	54fd                	li	s1,-1
    80006a7c:	b76d                	j	80006a26 <sys_open+0xe4>
      end_op();
    80006a7e:	fffff097          	auipc	ra,0xfffff
    80006a82:	8f4080e7          	jalr	-1804(ra) # 80005372 <end_op>
      return -1;
    80006a86:	54fd                	li	s1,-1
    80006a88:	bf79                	j	80006a26 <sys_open+0xe4>
    iunlockput(ip);
    80006a8a:	854a                	mv	a0,s2
    80006a8c:	ffffe097          	auipc	ra,0xffffe
    80006a90:	0f4080e7          	jalr	244(ra) # 80004b80 <iunlockput>
    end_op();
    80006a94:	fffff097          	auipc	ra,0xfffff
    80006a98:	8de080e7          	jalr	-1826(ra) # 80005372 <end_op>
    return -1;
    80006a9c:	54fd                	li	s1,-1
    80006a9e:	b761                	j	80006a26 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006aa0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006aa4:	04691783          	lh	a5,70(s2)
    80006aa8:	02f99223          	sh	a5,36(s3)
    80006aac:	bf2d                	j	800069e6 <sys_open+0xa4>
    itrunc(ip);
    80006aae:	854a                	mv	a0,s2
    80006ab0:	ffffe097          	auipc	ra,0xffffe
    80006ab4:	f7c080e7          	jalr	-132(ra) # 80004a2c <itrunc>
    80006ab8:	bfb1                	j	80006a14 <sys_open+0xd2>
      fileclose(f);
    80006aba:	854e                	mv	a0,s3
    80006abc:	fffff097          	auipc	ra,0xfffff
    80006ac0:	d02080e7          	jalr	-766(ra) # 800057be <fileclose>
    iunlockput(ip);
    80006ac4:	854a                	mv	a0,s2
    80006ac6:	ffffe097          	auipc	ra,0xffffe
    80006aca:	0ba080e7          	jalr	186(ra) # 80004b80 <iunlockput>
    end_op();
    80006ace:	fffff097          	auipc	ra,0xfffff
    80006ad2:	8a4080e7          	jalr	-1884(ra) # 80005372 <end_op>
    return -1;
    80006ad6:	54fd                	li	s1,-1
    80006ad8:	b7b9                	j	80006a26 <sys_open+0xe4>

0000000080006ada <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006ada:	7175                	addi	sp,sp,-144
    80006adc:	e506                	sd	ra,136(sp)
    80006ade:	e122                	sd	s0,128(sp)
    80006ae0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006ae2:	fffff097          	auipc	ra,0xfffff
    80006ae6:	810080e7          	jalr	-2032(ra) # 800052f2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006aea:	08000613          	li	a2,128
    80006aee:	f7040593          	addi	a1,s0,-144
    80006af2:	4501                	li	a0,0
    80006af4:	ffffd097          	auipc	ra,0xffffd
    80006af8:	070080e7          	jalr	112(ra) # 80003b64 <argstr>
    80006afc:	02054963          	bltz	a0,80006b2e <sys_mkdir+0x54>
    80006b00:	4681                	li	a3,0
    80006b02:	4601                	li	a2,0
    80006b04:	4585                	li	a1,1
    80006b06:	f7040513          	addi	a0,s0,-144
    80006b0a:	00000097          	auipc	ra,0x0
    80006b0e:	800080e7          	jalr	-2048(ra) # 8000630a <create>
    80006b12:	cd11                	beqz	a0,80006b2e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006b14:	ffffe097          	auipc	ra,0xffffe
    80006b18:	06c080e7          	jalr	108(ra) # 80004b80 <iunlockput>
  end_op();
    80006b1c:	fffff097          	auipc	ra,0xfffff
    80006b20:	856080e7          	jalr	-1962(ra) # 80005372 <end_op>
  return 0;
    80006b24:	4501                	li	a0,0
}
    80006b26:	60aa                	ld	ra,136(sp)
    80006b28:	640a                	ld	s0,128(sp)
    80006b2a:	6149                	addi	sp,sp,144
    80006b2c:	8082                	ret
    end_op();
    80006b2e:	fffff097          	auipc	ra,0xfffff
    80006b32:	844080e7          	jalr	-1980(ra) # 80005372 <end_op>
    return -1;
    80006b36:	557d                	li	a0,-1
    80006b38:	b7fd                	j	80006b26 <sys_mkdir+0x4c>

0000000080006b3a <sys_mknod>:

uint64
sys_mknod(void)
{
    80006b3a:	7135                	addi	sp,sp,-160
    80006b3c:	ed06                	sd	ra,152(sp)
    80006b3e:	e922                	sd	s0,144(sp)
    80006b40:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006b42:	ffffe097          	auipc	ra,0xffffe
    80006b46:	7b0080e7          	jalr	1968(ra) # 800052f2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006b4a:	08000613          	li	a2,128
    80006b4e:	f7040593          	addi	a1,s0,-144
    80006b52:	4501                	li	a0,0
    80006b54:	ffffd097          	auipc	ra,0xffffd
    80006b58:	010080e7          	jalr	16(ra) # 80003b64 <argstr>
    80006b5c:	04054a63          	bltz	a0,80006bb0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006b60:	f6c40593          	addi	a1,s0,-148
    80006b64:	4505                	li	a0,1
    80006b66:	ffffd097          	auipc	ra,0xffffd
    80006b6a:	fba080e7          	jalr	-70(ra) # 80003b20 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006b6e:	04054163          	bltz	a0,80006bb0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006b72:	f6840593          	addi	a1,s0,-152
    80006b76:	4509                	li	a0,2
    80006b78:	ffffd097          	auipc	ra,0xffffd
    80006b7c:	fa8080e7          	jalr	-88(ra) # 80003b20 <argint>
     argint(1, &major) < 0 ||
    80006b80:	02054863          	bltz	a0,80006bb0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006b84:	f6841683          	lh	a3,-152(s0)
    80006b88:	f6c41603          	lh	a2,-148(s0)
    80006b8c:	458d                	li	a1,3
    80006b8e:	f7040513          	addi	a0,s0,-144
    80006b92:	fffff097          	auipc	ra,0xfffff
    80006b96:	778080e7          	jalr	1912(ra) # 8000630a <create>
     argint(2, &minor) < 0 ||
    80006b9a:	c919                	beqz	a0,80006bb0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006b9c:	ffffe097          	auipc	ra,0xffffe
    80006ba0:	fe4080e7          	jalr	-28(ra) # 80004b80 <iunlockput>
  end_op();
    80006ba4:	ffffe097          	auipc	ra,0xffffe
    80006ba8:	7ce080e7          	jalr	1998(ra) # 80005372 <end_op>
  return 0;
    80006bac:	4501                	li	a0,0
    80006bae:	a031                	j	80006bba <sys_mknod+0x80>
    end_op();
    80006bb0:	ffffe097          	auipc	ra,0xffffe
    80006bb4:	7c2080e7          	jalr	1986(ra) # 80005372 <end_op>
    return -1;
    80006bb8:	557d                	li	a0,-1
}
    80006bba:	60ea                	ld	ra,152(sp)
    80006bbc:	644a                	ld	s0,144(sp)
    80006bbe:	610d                	addi	sp,sp,160
    80006bc0:	8082                	ret

0000000080006bc2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006bc2:	7135                	addi	sp,sp,-160
    80006bc4:	ed06                	sd	ra,152(sp)
    80006bc6:	e922                	sd	s0,144(sp)
    80006bc8:	e526                	sd	s1,136(sp)
    80006bca:	e14a                	sd	s2,128(sp)
    80006bcc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006bce:	ffffb097          	auipc	ra,0xffffb
    80006bd2:	14a080e7          	jalr	330(ra) # 80001d18 <myproc>
    80006bd6:	892a                	mv	s2,a0
  
  begin_op();
    80006bd8:	ffffe097          	auipc	ra,0xffffe
    80006bdc:	71a080e7          	jalr	1818(ra) # 800052f2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006be0:	08000613          	li	a2,128
    80006be4:	f6040593          	addi	a1,s0,-160
    80006be8:	4501                	li	a0,0
    80006bea:	ffffd097          	auipc	ra,0xffffd
    80006bee:	f7a080e7          	jalr	-134(ra) # 80003b64 <argstr>
    80006bf2:	04054b63          	bltz	a0,80006c48 <sys_chdir+0x86>
    80006bf6:	f6040513          	addi	a0,s0,-160
    80006bfa:	ffffe097          	auipc	ra,0xffffe
    80006bfe:	4d8080e7          	jalr	1240(ra) # 800050d2 <namei>
    80006c02:	84aa                	mv	s1,a0
    80006c04:	c131                	beqz	a0,80006c48 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006c06:	ffffe097          	auipc	ra,0xffffe
    80006c0a:	d18080e7          	jalr	-744(ra) # 8000491e <ilock>
  if(ip->type != T_DIR){
    80006c0e:	04449703          	lh	a4,68(s1)
    80006c12:	4785                	li	a5,1
    80006c14:	04f71063          	bne	a4,a5,80006c54 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006c18:	8526                	mv	a0,s1
    80006c1a:	ffffe097          	auipc	ra,0xffffe
    80006c1e:	dc6080e7          	jalr	-570(ra) # 800049e0 <iunlock>
  iput(p->cwd);
    80006c22:	0d093503          	ld	a0,208(s2)
    80006c26:	ffffe097          	auipc	ra,0xffffe
    80006c2a:	eb2080e7          	jalr	-334(ra) # 80004ad8 <iput>
  end_op();
    80006c2e:	ffffe097          	auipc	ra,0xffffe
    80006c32:	744080e7          	jalr	1860(ra) # 80005372 <end_op>
  p->cwd = ip;
    80006c36:	0c993823          	sd	s1,208(s2)
  return 0;
    80006c3a:	4501                	li	a0,0
}
    80006c3c:	60ea                	ld	ra,152(sp)
    80006c3e:	644a                	ld	s0,144(sp)
    80006c40:	64aa                	ld	s1,136(sp)
    80006c42:	690a                	ld	s2,128(sp)
    80006c44:	610d                	addi	sp,sp,160
    80006c46:	8082                	ret
    end_op();
    80006c48:	ffffe097          	auipc	ra,0xffffe
    80006c4c:	72a080e7          	jalr	1834(ra) # 80005372 <end_op>
    return -1;
    80006c50:	557d                	li	a0,-1
    80006c52:	b7ed                	j	80006c3c <sys_chdir+0x7a>
    iunlockput(ip);
    80006c54:	8526                	mv	a0,s1
    80006c56:	ffffe097          	auipc	ra,0xffffe
    80006c5a:	f2a080e7          	jalr	-214(ra) # 80004b80 <iunlockput>
    end_op();
    80006c5e:	ffffe097          	auipc	ra,0xffffe
    80006c62:	714080e7          	jalr	1812(ra) # 80005372 <end_op>
    return -1;
    80006c66:	557d                	li	a0,-1
    80006c68:	bfd1                	j	80006c3c <sys_chdir+0x7a>

0000000080006c6a <sys_exec>:

uint64
sys_exec(void)
{
    80006c6a:	7145                	addi	sp,sp,-464
    80006c6c:	e786                	sd	ra,456(sp)
    80006c6e:	e3a2                	sd	s0,448(sp)
    80006c70:	ff26                	sd	s1,440(sp)
    80006c72:	fb4a                	sd	s2,432(sp)
    80006c74:	f74e                	sd	s3,424(sp)
    80006c76:	f352                	sd	s4,416(sp)
    80006c78:	ef56                	sd	s5,408(sp)
    80006c7a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006c7c:	08000613          	li	a2,128
    80006c80:	f4040593          	addi	a1,s0,-192
    80006c84:	4501                	li	a0,0
    80006c86:	ffffd097          	auipc	ra,0xffffd
    80006c8a:	ede080e7          	jalr	-290(ra) # 80003b64 <argstr>
    return -1;
    80006c8e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006c90:	0c054a63          	bltz	a0,80006d64 <sys_exec+0xfa>
    80006c94:	e3840593          	addi	a1,s0,-456
    80006c98:	4505                	li	a0,1
    80006c9a:	ffffd097          	auipc	ra,0xffffd
    80006c9e:	ea8080e7          	jalr	-344(ra) # 80003b42 <argaddr>
    80006ca2:	0c054163          	bltz	a0,80006d64 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006ca6:	10000613          	li	a2,256
    80006caa:	4581                	li	a1,0
    80006cac:	e4040513          	addi	a0,s0,-448
    80006cb0:	ffffa097          	auipc	ra,0xffffa
    80006cb4:	2c8080e7          	jalr	712(ra) # 80000f78 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006cb8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006cbc:	89a6                	mv	s3,s1
    80006cbe:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006cc0:	02000a13          	li	s4,32
    80006cc4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006cc8:	00391793          	slli	a5,s2,0x3
    80006ccc:	e3040593          	addi	a1,s0,-464
    80006cd0:	e3843503          	ld	a0,-456(s0)
    80006cd4:	953e                	add	a0,a0,a5
    80006cd6:	ffffd097          	auipc	ra,0xffffd
    80006cda:	db0080e7          	jalr	-592(ra) # 80003a86 <fetchaddr>
    80006cde:	02054a63          	bltz	a0,80006d12 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006ce2:	e3043783          	ld	a5,-464(s0)
    80006ce6:	c3b9                	beqz	a5,80006d2c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006ce8:	ffffa097          	auipc	ra,0xffffa
    80006cec:	dee080e7          	jalr	-530(ra) # 80000ad6 <kalloc>
    80006cf0:	85aa                	mv	a1,a0
    80006cf2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006cf6:	cd11                	beqz	a0,80006d12 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006cf8:	6605                	lui	a2,0x1
    80006cfa:	e3043503          	ld	a0,-464(s0)
    80006cfe:	ffffd097          	auipc	ra,0xffffd
    80006d02:	dda080e7          	jalr	-550(ra) # 80003ad8 <fetchstr>
    80006d06:	00054663          	bltz	a0,80006d12 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006d0a:	0905                	addi	s2,s2,1
    80006d0c:	09a1                	addi	s3,s3,8
    80006d0e:	fb491be3          	bne	s2,s4,80006cc4 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006d12:	10048913          	addi	s2,s1,256
    80006d16:	6088                	ld	a0,0(s1)
    80006d18:	c529                	beqz	a0,80006d62 <sys_exec+0xf8>
    kfree(argv[i]);
    80006d1a:	ffffa097          	auipc	ra,0xffffa
    80006d1e:	cc0080e7          	jalr	-832(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006d22:	04a1                	addi	s1,s1,8
    80006d24:	ff2499e3          	bne	s1,s2,80006d16 <sys_exec+0xac>
  return -1;
    80006d28:	597d                	li	s2,-1
    80006d2a:	a82d                	j	80006d64 <sys_exec+0xfa>
      argv[i] = 0;
    80006d2c:	0a8e                	slli	s5,s5,0x3
    80006d2e:	fc040793          	addi	a5,s0,-64
    80006d32:	9abe                	add	s5,s5,a5
    80006d34:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006d38:	e4040593          	addi	a1,s0,-448
    80006d3c:	f4040513          	addi	a0,s0,-192
    80006d40:	fffff097          	auipc	ra,0xfffff
    80006d44:	0dc080e7          	jalr	220(ra) # 80005e1c <exec>
    80006d48:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006d4a:	10048993          	addi	s3,s1,256
    80006d4e:	6088                	ld	a0,0(s1)
    80006d50:	c911                	beqz	a0,80006d64 <sys_exec+0xfa>
    kfree(argv[i]);
    80006d52:	ffffa097          	auipc	ra,0xffffa
    80006d56:	c88080e7          	jalr	-888(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006d5a:	04a1                	addi	s1,s1,8
    80006d5c:	ff3499e3          	bne	s1,s3,80006d4e <sys_exec+0xe4>
    80006d60:	a011                	j	80006d64 <sys_exec+0xfa>
  return -1;
    80006d62:	597d                	li	s2,-1
}
    80006d64:	854a                	mv	a0,s2
    80006d66:	60be                	ld	ra,456(sp)
    80006d68:	641e                	ld	s0,448(sp)
    80006d6a:	74fa                	ld	s1,440(sp)
    80006d6c:	795a                	ld	s2,432(sp)
    80006d6e:	79ba                	ld	s3,424(sp)
    80006d70:	7a1a                	ld	s4,416(sp)
    80006d72:	6afa                	ld	s5,408(sp)
    80006d74:	6179                	addi	sp,sp,464
    80006d76:	8082                	ret

0000000080006d78 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006d78:	7139                	addi	sp,sp,-64
    80006d7a:	fc06                	sd	ra,56(sp)
    80006d7c:	f822                	sd	s0,48(sp)
    80006d7e:	f426                	sd	s1,40(sp)
    80006d80:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006d82:	ffffb097          	auipc	ra,0xffffb
    80006d86:	f96080e7          	jalr	-106(ra) # 80001d18 <myproc>
    80006d8a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006d8c:	fd840593          	addi	a1,s0,-40
    80006d90:	4501                	li	a0,0
    80006d92:	ffffd097          	auipc	ra,0xffffd
    80006d96:	db0080e7          	jalr	-592(ra) # 80003b42 <argaddr>
    return -1;
    80006d9a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006d9c:	0e054063          	bltz	a0,80006e7c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006da0:	fc840593          	addi	a1,s0,-56
    80006da4:	fd040513          	addi	a0,s0,-48
    80006da8:	fffff097          	auipc	ra,0xfffff
    80006dac:	d46080e7          	jalr	-698(ra) # 80005aee <pipealloc>
    return -1;
    80006db0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006db2:	0c054563          	bltz	a0,80006e7c <sys_pipe+0x104>
  fd0 = -1;
    80006db6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006dba:	fd043503          	ld	a0,-48(s0)
    80006dbe:	fffff097          	auipc	ra,0xfffff
    80006dc2:	50a080e7          	jalr	1290(ra) # 800062c8 <fdalloc>
    80006dc6:	fca42223          	sw	a0,-60(s0)
    80006dca:	08054c63          	bltz	a0,80006e62 <sys_pipe+0xea>
    80006dce:	fc843503          	ld	a0,-56(s0)
    80006dd2:	fffff097          	auipc	ra,0xfffff
    80006dd6:	4f6080e7          	jalr	1270(ra) # 800062c8 <fdalloc>
    80006dda:	fca42023          	sw	a0,-64(s0)
    80006dde:	06054863          	bltz	a0,80006e4e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006de2:	4691                	li	a3,4
    80006de4:	fc440613          	addi	a2,s0,-60
    80006de8:	fd843583          	ld	a1,-40(s0)
    80006dec:	60a8                	ld	a0,64(s1)
    80006dee:	ffffb097          	auipc	ra,0xffffb
    80006df2:	b12080e7          	jalr	-1262(ra) # 80001900 <copyout>
    80006df6:	02054063          	bltz	a0,80006e16 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006dfa:	4691                	li	a3,4
    80006dfc:	fc040613          	addi	a2,s0,-64
    80006e00:	fd843583          	ld	a1,-40(s0)
    80006e04:	0591                	addi	a1,a1,4
    80006e06:	60a8                	ld	a0,64(s1)
    80006e08:	ffffb097          	auipc	ra,0xffffb
    80006e0c:	af8080e7          	jalr	-1288(ra) # 80001900 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006e10:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006e12:	06055563          	bgez	a0,80006e7c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006e16:	fc442783          	lw	a5,-60(s0)
    80006e1a:	07a9                	addi	a5,a5,10
    80006e1c:	078e                	slli	a5,a5,0x3
    80006e1e:	97a6                	add	a5,a5,s1
    80006e20:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006e24:	fc042503          	lw	a0,-64(s0)
    80006e28:	0529                	addi	a0,a0,10
    80006e2a:	050e                	slli	a0,a0,0x3
    80006e2c:	9526                	add	a0,a0,s1
    80006e2e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006e32:	fd043503          	ld	a0,-48(s0)
    80006e36:	fffff097          	auipc	ra,0xfffff
    80006e3a:	988080e7          	jalr	-1656(ra) # 800057be <fileclose>
    fileclose(wf);
    80006e3e:	fc843503          	ld	a0,-56(s0)
    80006e42:	fffff097          	auipc	ra,0xfffff
    80006e46:	97c080e7          	jalr	-1668(ra) # 800057be <fileclose>
    return -1;
    80006e4a:	57fd                	li	a5,-1
    80006e4c:	a805                	j	80006e7c <sys_pipe+0x104>
    if(fd0 >= 0)
    80006e4e:	fc442783          	lw	a5,-60(s0)
    80006e52:	0007c863          	bltz	a5,80006e62 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006e56:	00a78513          	addi	a0,a5,10
    80006e5a:	050e                	slli	a0,a0,0x3
    80006e5c:	9526                	add	a0,a0,s1
    80006e5e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006e62:	fd043503          	ld	a0,-48(s0)
    80006e66:	fffff097          	auipc	ra,0xfffff
    80006e6a:	958080e7          	jalr	-1704(ra) # 800057be <fileclose>
    fileclose(wf);
    80006e6e:	fc843503          	ld	a0,-56(s0)
    80006e72:	fffff097          	auipc	ra,0xfffff
    80006e76:	94c080e7          	jalr	-1716(ra) # 800057be <fileclose>
    return -1;
    80006e7a:	57fd                	li	a5,-1
}
    80006e7c:	853e                	mv	a0,a5
    80006e7e:	70e2                	ld	ra,56(sp)
    80006e80:	7442                	ld	s0,48(sp)
    80006e82:	74a2                	ld	s1,40(sp)
    80006e84:	6121                	addi	sp,sp,64
    80006e86:	8082                	ret
	...

0000000080006e90 <kernelvec>:
    80006e90:	7111                	addi	sp,sp,-256
    80006e92:	e006                	sd	ra,0(sp)
    80006e94:	e40a                	sd	sp,8(sp)
    80006e96:	e80e                	sd	gp,16(sp)
    80006e98:	ec12                	sd	tp,24(sp)
    80006e9a:	f016                	sd	t0,32(sp)
    80006e9c:	f41a                	sd	t1,40(sp)
    80006e9e:	f81e                	sd	t2,48(sp)
    80006ea0:	fc22                	sd	s0,56(sp)
    80006ea2:	e0a6                	sd	s1,64(sp)
    80006ea4:	e4aa                	sd	a0,72(sp)
    80006ea6:	e8ae                	sd	a1,80(sp)
    80006ea8:	ecb2                	sd	a2,88(sp)
    80006eaa:	f0b6                	sd	a3,96(sp)
    80006eac:	f4ba                	sd	a4,104(sp)
    80006eae:	f8be                	sd	a5,112(sp)
    80006eb0:	fcc2                	sd	a6,120(sp)
    80006eb2:	e146                	sd	a7,128(sp)
    80006eb4:	e54a                	sd	s2,136(sp)
    80006eb6:	e94e                	sd	s3,144(sp)
    80006eb8:	ed52                	sd	s4,152(sp)
    80006eba:	f156                	sd	s5,160(sp)
    80006ebc:	f55a                	sd	s6,168(sp)
    80006ebe:	f95e                	sd	s7,176(sp)
    80006ec0:	fd62                	sd	s8,184(sp)
    80006ec2:	e1e6                	sd	s9,192(sp)
    80006ec4:	e5ea                	sd	s10,200(sp)
    80006ec6:	e9ee                	sd	s11,208(sp)
    80006ec8:	edf2                	sd	t3,216(sp)
    80006eca:	f1f6                	sd	t4,224(sp)
    80006ecc:	f5fa                	sd	t5,232(sp)
    80006ece:	f9fe                	sd	t6,240(sp)
    80006ed0:	a5ffc0ef          	jal	ra,8000392e <kerneltrap>
    80006ed4:	6082                	ld	ra,0(sp)
    80006ed6:	6122                	ld	sp,8(sp)
    80006ed8:	61c2                	ld	gp,16(sp)
    80006eda:	7282                	ld	t0,32(sp)
    80006edc:	7322                	ld	t1,40(sp)
    80006ede:	73c2                	ld	t2,48(sp)
    80006ee0:	7462                	ld	s0,56(sp)
    80006ee2:	6486                	ld	s1,64(sp)
    80006ee4:	6526                	ld	a0,72(sp)
    80006ee6:	65c6                	ld	a1,80(sp)
    80006ee8:	6666                	ld	a2,88(sp)
    80006eea:	7686                	ld	a3,96(sp)
    80006eec:	7726                	ld	a4,104(sp)
    80006eee:	77c6                	ld	a5,112(sp)
    80006ef0:	7866                	ld	a6,120(sp)
    80006ef2:	688a                	ld	a7,128(sp)
    80006ef4:	692a                	ld	s2,136(sp)
    80006ef6:	69ca                	ld	s3,144(sp)
    80006ef8:	6a6a                	ld	s4,152(sp)
    80006efa:	7a8a                	ld	s5,160(sp)
    80006efc:	7b2a                	ld	s6,168(sp)
    80006efe:	7bca                	ld	s7,176(sp)
    80006f00:	7c6a                	ld	s8,184(sp)
    80006f02:	6c8e                	ld	s9,192(sp)
    80006f04:	6d2e                	ld	s10,200(sp)
    80006f06:	6dce                	ld	s11,208(sp)
    80006f08:	6e6e                	ld	t3,216(sp)
    80006f0a:	7e8e                	ld	t4,224(sp)
    80006f0c:	7f2e                	ld	t5,232(sp)
    80006f0e:	7fce                	ld	t6,240(sp)
    80006f10:	6111                	addi	sp,sp,256
    80006f12:	10200073          	sret
    80006f16:	00000013          	nop
    80006f1a:	00000013          	nop
    80006f1e:	0001                	nop

0000000080006f20 <timervec>:
    80006f20:	34051573          	csrrw	a0,mscratch,a0
    80006f24:	e10c                	sd	a1,0(a0)
    80006f26:	e510                	sd	a2,8(a0)
    80006f28:	e914                	sd	a3,16(a0)
    80006f2a:	6d0c                	ld	a1,24(a0)
    80006f2c:	7110                	ld	a2,32(a0)
    80006f2e:	6194                	ld	a3,0(a1)
    80006f30:	96b2                	add	a3,a3,a2
    80006f32:	e194                	sd	a3,0(a1)
    80006f34:	4589                	li	a1,2
    80006f36:	14459073          	csrw	sip,a1
    80006f3a:	6914                	ld	a3,16(a0)
    80006f3c:	6510                	ld	a2,8(a0)
    80006f3e:	610c                	ld	a1,0(a0)
    80006f40:	34051573          	csrrw	a0,mscratch,a0
    80006f44:	30200073          	mret
	...

0000000080006f4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006f4a:	1141                	addi	sp,sp,-16
    80006f4c:	e422                	sd	s0,8(sp)
    80006f4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006f50:	0c0007b7          	lui	a5,0xc000
    80006f54:	4705                	li	a4,1
    80006f56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006f58:	c3d8                	sw	a4,4(a5)
}
    80006f5a:	6422                	ld	s0,8(sp)
    80006f5c:	0141                	addi	sp,sp,16
    80006f5e:	8082                	ret

0000000080006f60 <plicinithart>:

void
plicinithart(void)
{
    80006f60:	1141                	addi	sp,sp,-16
    80006f62:	e406                	sd	ra,8(sp)
    80006f64:	e022                	sd	s0,0(sp)
    80006f66:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006f68:	ffffb097          	auipc	ra,0xffffb
    80006f6c:	d7c080e7          	jalr	-644(ra) # 80001ce4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006f70:	0085171b          	slliw	a4,a0,0x8
    80006f74:	0c0027b7          	lui	a5,0xc002
    80006f78:	97ba                	add	a5,a5,a4
    80006f7a:	40200713          	li	a4,1026
    80006f7e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006f82:	00d5151b          	slliw	a0,a0,0xd
    80006f86:	0c2017b7          	lui	a5,0xc201
    80006f8a:	953e                	add	a0,a0,a5
    80006f8c:	00052023          	sw	zero,0(a0)
}
    80006f90:	60a2                	ld	ra,8(sp)
    80006f92:	6402                	ld	s0,0(sp)
    80006f94:	0141                	addi	sp,sp,16
    80006f96:	8082                	ret

0000000080006f98 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006f98:	1141                	addi	sp,sp,-16
    80006f9a:	e406                	sd	ra,8(sp)
    80006f9c:	e022                	sd	s0,0(sp)
    80006f9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006fa0:	ffffb097          	auipc	ra,0xffffb
    80006fa4:	d44080e7          	jalr	-700(ra) # 80001ce4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006fa8:	00d5179b          	slliw	a5,a0,0xd
    80006fac:	0c201537          	lui	a0,0xc201
    80006fb0:	953e                	add	a0,a0,a5
  return irq;
}
    80006fb2:	4148                	lw	a0,4(a0)
    80006fb4:	60a2                	ld	ra,8(sp)
    80006fb6:	6402                	ld	s0,0(sp)
    80006fb8:	0141                	addi	sp,sp,16
    80006fba:	8082                	ret

0000000080006fbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006fbc:	1101                	addi	sp,sp,-32
    80006fbe:	ec06                	sd	ra,24(sp)
    80006fc0:	e822                	sd	s0,16(sp)
    80006fc2:	e426                	sd	s1,8(sp)
    80006fc4:	1000                	addi	s0,sp,32
    80006fc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006fc8:	ffffb097          	auipc	ra,0xffffb
    80006fcc:	d1c080e7          	jalr	-740(ra) # 80001ce4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006fd0:	00d5151b          	slliw	a0,a0,0xd
    80006fd4:	0c2017b7          	lui	a5,0xc201
    80006fd8:	97aa                	add	a5,a5,a0
    80006fda:	c3c4                	sw	s1,4(a5)
}
    80006fdc:	60e2                	ld	ra,24(sp)
    80006fde:	6442                	ld	s0,16(sp)
    80006fe0:	64a2                	ld	s1,8(sp)
    80006fe2:	6105                	addi	sp,sp,32
    80006fe4:	8082                	ret

0000000080006fe6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006fe6:	1141                	addi	sp,sp,-16
    80006fe8:	e406                	sd	ra,8(sp)
    80006fea:	e022                	sd	s0,0(sp)
    80006fec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006fee:	479d                	li	a5,7
    80006ff0:	06a7c963          	blt	a5,a0,80007062 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006ff4:	00039797          	auipc	a5,0x39
    80006ff8:	00c78793          	addi	a5,a5,12 # 80040000 <disk>
    80006ffc:	00a78733          	add	a4,a5,a0
    80007000:	6789                	lui	a5,0x2
    80007002:	97ba                	add	a5,a5,a4
    80007004:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80007008:	e7ad                	bnez	a5,80007072 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000700a:	00451793          	slli	a5,a0,0x4
    8000700e:	0003b717          	auipc	a4,0x3b
    80007012:	ff270713          	addi	a4,a4,-14 # 80042000 <disk+0x2000>
    80007016:	6314                	ld	a3,0(a4)
    80007018:	96be                	add	a3,a3,a5
    8000701a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000701e:	6314                	ld	a3,0(a4)
    80007020:	96be                	add	a3,a3,a5
    80007022:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80007026:	6314                	ld	a3,0(a4)
    80007028:	96be                	add	a3,a3,a5
    8000702a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000702e:	6318                	ld	a4,0(a4)
    80007030:	97ba                	add	a5,a5,a4
    80007032:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007036:	00039797          	auipc	a5,0x39
    8000703a:	fca78793          	addi	a5,a5,-54 # 80040000 <disk>
    8000703e:	97aa                	add	a5,a5,a0
    80007040:	6509                	lui	a0,0x2
    80007042:	953e                	add	a0,a0,a5
    80007044:	4785                	li	a5,1
    80007046:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000704a:	0003b517          	auipc	a0,0x3b
    8000704e:	fce50513          	addi	a0,a0,-50 # 80042018 <disk+0x2018>
    80007052:	ffffb097          	auipc	ra,0xffffb
    80007056:	79a080e7          	jalr	1946(ra) # 800027ec <wakeup>
}
    8000705a:	60a2                	ld	ra,8(sp)
    8000705c:	6402                	ld	s0,0(sp)
    8000705e:	0141                	addi	sp,sp,16
    80007060:	8082                	ret
    panic("free_desc 1");
    80007062:	00002517          	auipc	a0,0x2
    80007066:	7f650513          	addi	a0,a0,2038 # 80009858 <syscalls+0x378>
    8000706a:	ffff9097          	auipc	ra,0xffff9
    8000706e:	4c4080e7          	jalr	1220(ra) # 8000052e <panic>
    panic("free_desc 2");
    80007072:	00002517          	auipc	a0,0x2
    80007076:	7f650513          	addi	a0,a0,2038 # 80009868 <syscalls+0x388>
    8000707a:	ffff9097          	auipc	ra,0xffff9
    8000707e:	4b4080e7          	jalr	1204(ra) # 8000052e <panic>

0000000080007082 <virtio_disk_init>:
{
    80007082:	1101                	addi	sp,sp,-32
    80007084:	ec06                	sd	ra,24(sp)
    80007086:	e822                	sd	s0,16(sp)
    80007088:	e426                	sd	s1,8(sp)
    8000708a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000708c:	00002597          	auipc	a1,0x2
    80007090:	7ec58593          	addi	a1,a1,2028 # 80009878 <syscalls+0x398>
    80007094:	0003b517          	auipc	a0,0x3b
    80007098:	09450513          	addi	a0,a0,148 # 80042128 <disk+0x2128>
    8000709c:	ffffa097          	auipc	ra,0xffffa
    800070a0:	a9a080e7          	jalr	-1382(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800070a4:	100017b7          	lui	a5,0x10001
    800070a8:	4398                	lw	a4,0(a5)
    800070aa:	2701                	sext.w	a4,a4
    800070ac:	747277b7          	lui	a5,0x74727
    800070b0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800070b4:	0ef71163          	bne	a4,a5,80007196 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800070b8:	100017b7          	lui	a5,0x10001
    800070bc:	43dc                	lw	a5,4(a5)
    800070be:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800070c0:	4705                	li	a4,1
    800070c2:	0ce79a63          	bne	a5,a4,80007196 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800070c6:	100017b7          	lui	a5,0x10001
    800070ca:	479c                	lw	a5,8(a5)
    800070cc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800070ce:	4709                	li	a4,2
    800070d0:	0ce79363          	bne	a5,a4,80007196 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800070d4:	100017b7          	lui	a5,0x10001
    800070d8:	47d8                	lw	a4,12(a5)
    800070da:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800070dc:	554d47b7          	lui	a5,0x554d4
    800070e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800070e4:	0af71963          	bne	a4,a5,80007196 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800070e8:	100017b7          	lui	a5,0x10001
    800070ec:	4705                	li	a4,1
    800070ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800070f0:	470d                	li	a4,3
    800070f2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800070f4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800070f6:	c7ffe737          	lui	a4,0xc7ffe
    800070fa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb75f>
    800070fe:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007100:	2701                	sext.w	a4,a4
    80007102:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007104:	472d                	li	a4,11
    80007106:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007108:	473d                	li	a4,15
    8000710a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000710c:	6705                	lui	a4,0x1
    8000710e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007110:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007114:	5bdc                	lw	a5,52(a5)
    80007116:	2781                	sext.w	a5,a5
  if(max == 0)
    80007118:	c7d9                	beqz	a5,800071a6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000711a:	471d                	li	a4,7
    8000711c:	08f77d63          	bgeu	a4,a5,800071b6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007120:	100014b7          	lui	s1,0x10001
    80007124:	47a1                	li	a5,8
    80007126:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007128:	6609                	lui	a2,0x2
    8000712a:	4581                	li	a1,0
    8000712c:	00039517          	auipc	a0,0x39
    80007130:	ed450513          	addi	a0,a0,-300 # 80040000 <disk>
    80007134:	ffffa097          	auipc	ra,0xffffa
    80007138:	e44080e7          	jalr	-444(ra) # 80000f78 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000713c:	00039717          	auipc	a4,0x39
    80007140:	ec470713          	addi	a4,a4,-316 # 80040000 <disk>
    80007144:	00c75793          	srli	a5,a4,0xc
    80007148:	2781                	sext.w	a5,a5
    8000714a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000714c:	0003b797          	auipc	a5,0x3b
    80007150:	eb478793          	addi	a5,a5,-332 # 80042000 <disk+0x2000>
    80007154:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007156:	00039717          	auipc	a4,0x39
    8000715a:	f2a70713          	addi	a4,a4,-214 # 80040080 <disk+0x80>
    8000715e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80007160:	0003a717          	auipc	a4,0x3a
    80007164:	ea070713          	addi	a4,a4,-352 # 80041000 <disk+0x1000>
    80007168:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000716a:	4705                	li	a4,1
    8000716c:	00e78c23          	sb	a4,24(a5)
    80007170:	00e78ca3          	sb	a4,25(a5)
    80007174:	00e78d23          	sb	a4,26(a5)
    80007178:	00e78da3          	sb	a4,27(a5)
    8000717c:	00e78e23          	sb	a4,28(a5)
    80007180:	00e78ea3          	sb	a4,29(a5)
    80007184:	00e78f23          	sb	a4,30(a5)
    80007188:	00e78fa3          	sb	a4,31(a5)
}
    8000718c:	60e2                	ld	ra,24(sp)
    8000718e:	6442                	ld	s0,16(sp)
    80007190:	64a2                	ld	s1,8(sp)
    80007192:	6105                	addi	sp,sp,32
    80007194:	8082                	ret
    panic("could not find virtio disk");
    80007196:	00002517          	auipc	a0,0x2
    8000719a:	6f250513          	addi	a0,a0,1778 # 80009888 <syscalls+0x3a8>
    8000719e:	ffff9097          	auipc	ra,0xffff9
    800071a2:	390080e7          	jalr	912(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800071a6:	00002517          	auipc	a0,0x2
    800071aa:	70250513          	addi	a0,a0,1794 # 800098a8 <syscalls+0x3c8>
    800071ae:	ffff9097          	auipc	ra,0xffff9
    800071b2:	380080e7          	jalr	896(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800071b6:	00002517          	auipc	a0,0x2
    800071ba:	71250513          	addi	a0,a0,1810 # 800098c8 <syscalls+0x3e8>
    800071be:	ffff9097          	auipc	ra,0xffff9
    800071c2:	370080e7          	jalr	880(ra) # 8000052e <panic>

00000000800071c6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800071c6:	7119                	addi	sp,sp,-128
    800071c8:	fc86                	sd	ra,120(sp)
    800071ca:	f8a2                	sd	s0,112(sp)
    800071cc:	f4a6                	sd	s1,104(sp)
    800071ce:	f0ca                	sd	s2,96(sp)
    800071d0:	ecce                	sd	s3,88(sp)
    800071d2:	e8d2                	sd	s4,80(sp)
    800071d4:	e4d6                	sd	s5,72(sp)
    800071d6:	e0da                	sd	s6,64(sp)
    800071d8:	fc5e                	sd	s7,56(sp)
    800071da:	f862                	sd	s8,48(sp)
    800071dc:	f466                	sd	s9,40(sp)
    800071de:	f06a                	sd	s10,32(sp)
    800071e0:	ec6e                	sd	s11,24(sp)
    800071e2:	0100                	addi	s0,sp,128
    800071e4:	8aaa                	mv	s5,a0
    800071e6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800071e8:	00c52c83          	lw	s9,12(a0)
    800071ec:	001c9c9b          	slliw	s9,s9,0x1
    800071f0:	1c82                	slli	s9,s9,0x20
    800071f2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800071f6:	0003b517          	auipc	a0,0x3b
    800071fa:	f3250513          	addi	a0,a0,-206 # 80042128 <disk+0x2128>
    800071fe:	ffffa097          	auipc	ra,0xffffa
    80007202:	a0a080e7          	jalr	-1526(ra) # 80000c08 <acquire>
  for(int i = 0; i < 3; i++){
    80007206:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007208:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000720a:	00039c17          	auipc	s8,0x39
    8000720e:	df6c0c13          	addi	s8,s8,-522 # 80040000 <disk>
    80007212:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007214:	4b0d                	li	s6,3
    80007216:	a0ad                	j	80007280 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007218:	00fc0733          	add	a4,s8,a5
    8000721c:	975e                	add	a4,a4,s7
    8000721e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007222:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007224:	0207c563          	bltz	a5,8000724e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007228:	2905                	addiw	s2,s2,1
    8000722a:	0611                	addi	a2,a2,4
    8000722c:	19690d63          	beq	s2,s6,800073c6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007230:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007232:	0003b717          	auipc	a4,0x3b
    80007236:	de670713          	addi	a4,a4,-538 # 80042018 <disk+0x2018>
    8000723a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000723c:	00074683          	lbu	a3,0(a4)
    80007240:	fee1                	bnez	a3,80007218 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007242:	2785                	addiw	a5,a5,1
    80007244:	0705                	addi	a4,a4,1
    80007246:	fe979be3          	bne	a5,s1,8000723c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000724a:	57fd                	li	a5,-1
    8000724c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000724e:	01205d63          	blez	s2,80007268 <virtio_disk_rw+0xa2>
    80007252:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007254:	000a2503          	lw	a0,0(s4)
    80007258:	00000097          	auipc	ra,0x0
    8000725c:	d8e080e7          	jalr	-626(ra) # 80006fe6 <free_desc>
      for(int j = 0; j < i; j++)
    80007260:	2d85                	addiw	s11,s11,1
    80007262:	0a11                	addi	s4,s4,4
    80007264:	ffb918e3          	bne	s2,s11,80007254 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007268:	0003b597          	auipc	a1,0x3b
    8000726c:	ec058593          	addi	a1,a1,-320 # 80042128 <disk+0x2128>
    80007270:	0003b517          	auipc	a0,0x3b
    80007274:	da850513          	addi	a0,a0,-600 # 80042018 <disk+0x2018>
    80007278:	ffffb097          	auipc	ra,0xffffb
    8000727c:	3ea080e7          	jalr	1002(ra) # 80002662 <sleep>
  for(int i = 0; i < 3; i++){
    80007280:	f8040a13          	addi	s4,s0,-128
{
    80007284:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007286:	894e                	mv	s2,s3
    80007288:	b765                	j	80007230 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000728a:	0003b697          	auipc	a3,0x3b
    8000728e:	d766b683          	ld	a3,-650(a3) # 80042000 <disk+0x2000>
    80007292:	96ba                	add	a3,a3,a4
    80007294:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80007298:	00039817          	auipc	a6,0x39
    8000729c:	d6880813          	addi	a6,a6,-664 # 80040000 <disk>
    800072a0:	0003b697          	auipc	a3,0x3b
    800072a4:	d6068693          	addi	a3,a3,-672 # 80042000 <disk+0x2000>
    800072a8:	6290                	ld	a2,0(a3)
    800072aa:	963a                	add	a2,a2,a4
    800072ac:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800072b0:	0015e593          	ori	a1,a1,1
    800072b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800072b8:	f8842603          	lw	a2,-120(s0)
    800072bc:	628c                	ld	a1,0(a3)
    800072be:	972e                	add	a4,a4,a1
    800072c0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800072c4:	20050593          	addi	a1,a0,512
    800072c8:	0592                	slli	a1,a1,0x4
    800072ca:	95c2                	add	a1,a1,a6
    800072cc:	577d                	li	a4,-1
    800072ce:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800072d2:	00461713          	slli	a4,a2,0x4
    800072d6:	6290                	ld	a2,0(a3)
    800072d8:	963a                	add	a2,a2,a4
    800072da:	03078793          	addi	a5,a5,48
    800072de:	97c2                	add	a5,a5,a6
    800072e0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800072e2:	629c                	ld	a5,0(a3)
    800072e4:	97ba                	add	a5,a5,a4
    800072e6:	4605                	li	a2,1
    800072e8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800072ea:	629c                	ld	a5,0(a3)
    800072ec:	97ba                	add	a5,a5,a4
    800072ee:	4809                	li	a6,2
    800072f0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800072f4:	629c                	ld	a5,0(a3)
    800072f6:	973e                	add	a4,a4,a5
    800072f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800072fc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007300:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007304:	6698                	ld	a4,8(a3)
    80007306:	00275783          	lhu	a5,2(a4)
    8000730a:	8b9d                	andi	a5,a5,7
    8000730c:	0786                	slli	a5,a5,0x1
    8000730e:	97ba                	add	a5,a5,a4
    80007310:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007314:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007318:	6698                	ld	a4,8(a3)
    8000731a:	00275783          	lhu	a5,2(a4)
    8000731e:	2785                	addiw	a5,a5,1
    80007320:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007324:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007328:	100017b7          	lui	a5,0x10001
    8000732c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007330:	004aa783          	lw	a5,4(s5)
    80007334:	02c79163          	bne	a5,a2,80007356 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007338:	0003b917          	auipc	s2,0x3b
    8000733c:	df090913          	addi	s2,s2,-528 # 80042128 <disk+0x2128>
  while(b->disk == 1) {
    80007340:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007342:	85ca                	mv	a1,s2
    80007344:	8556                	mv	a0,s5
    80007346:	ffffb097          	auipc	ra,0xffffb
    8000734a:	31c080e7          	jalr	796(ra) # 80002662 <sleep>
  while(b->disk == 1) {
    8000734e:	004aa783          	lw	a5,4(s5)
    80007352:	fe9788e3          	beq	a5,s1,80007342 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007356:	f8042903          	lw	s2,-128(s0)
    8000735a:	20090793          	addi	a5,s2,512
    8000735e:	00479713          	slli	a4,a5,0x4
    80007362:	00039797          	auipc	a5,0x39
    80007366:	c9e78793          	addi	a5,a5,-866 # 80040000 <disk>
    8000736a:	97ba                	add	a5,a5,a4
    8000736c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007370:	0003b997          	auipc	s3,0x3b
    80007374:	c9098993          	addi	s3,s3,-880 # 80042000 <disk+0x2000>
    80007378:	00491713          	slli	a4,s2,0x4
    8000737c:	0009b783          	ld	a5,0(s3)
    80007380:	97ba                	add	a5,a5,a4
    80007382:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007386:	854a                	mv	a0,s2
    80007388:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000738c:	00000097          	auipc	ra,0x0
    80007390:	c5a080e7          	jalr	-934(ra) # 80006fe6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80007394:	8885                	andi	s1,s1,1
    80007396:	f0ed                	bnez	s1,80007378 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80007398:	0003b517          	auipc	a0,0x3b
    8000739c:	d9050513          	addi	a0,a0,-624 # 80042128 <disk+0x2128>
    800073a0:	ffffa097          	auipc	ra,0xffffa
    800073a4:	91c080e7          	jalr	-1764(ra) # 80000cbc <release>
}
    800073a8:	70e6                	ld	ra,120(sp)
    800073aa:	7446                	ld	s0,112(sp)
    800073ac:	74a6                	ld	s1,104(sp)
    800073ae:	7906                	ld	s2,96(sp)
    800073b0:	69e6                	ld	s3,88(sp)
    800073b2:	6a46                	ld	s4,80(sp)
    800073b4:	6aa6                	ld	s5,72(sp)
    800073b6:	6b06                	ld	s6,64(sp)
    800073b8:	7be2                	ld	s7,56(sp)
    800073ba:	7c42                	ld	s8,48(sp)
    800073bc:	7ca2                	ld	s9,40(sp)
    800073be:	7d02                	ld	s10,32(sp)
    800073c0:	6de2                	ld	s11,24(sp)
    800073c2:	6109                	addi	sp,sp,128
    800073c4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800073c6:	f8042503          	lw	a0,-128(s0)
    800073ca:	20050793          	addi	a5,a0,512
    800073ce:	0792                	slli	a5,a5,0x4
  if(write)
    800073d0:	00039817          	auipc	a6,0x39
    800073d4:	c3080813          	addi	a6,a6,-976 # 80040000 <disk>
    800073d8:	00f80733          	add	a4,a6,a5
    800073dc:	01a036b3          	snez	a3,s10
    800073e0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800073e4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800073e8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800073ec:	7679                	lui	a2,0xffffe
    800073ee:	963e                	add	a2,a2,a5
    800073f0:	0003b697          	auipc	a3,0x3b
    800073f4:	c1068693          	addi	a3,a3,-1008 # 80042000 <disk+0x2000>
    800073f8:	6298                	ld	a4,0(a3)
    800073fa:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800073fc:	0a878593          	addi	a1,a5,168
    80007400:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007402:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007404:	6298                	ld	a4,0(a3)
    80007406:	9732                	add	a4,a4,a2
    80007408:	45c1                	li	a1,16
    8000740a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000740c:	6298                	ld	a4,0(a3)
    8000740e:	9732                	add	a4,a4,a2
    80007410:	4585                	li	a1,1
    80007412:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007416:	f8442703          	lw	a4,-124(s0)
    8000741a:	628c                	ld	a1,0(a3)
    8000741c:	962e                	add	a2,a2,a1
    8000741e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbb00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007422:	0712                	slli	a4,a4,0x4
    80007424:	6290                	ld	a2,0(a3)
    80007426:	963a                	add	a2,a2,a4
    80007428:	058a8593          	addi	a1,s5,88
    8000742c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000742e:	6294                	ld	a3,0(a3)
    80007430:	96ba                	add	a3,a3,a4
    80007432:	40000613          	li	a2,1024
    80007436:	c690                	sw	a2,8(a3)
  if(write)
    80007438:	e40d19e3          	bnez	s10,8000728a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000743c:	0003b697          	auipc	a3,0x3b
    80007440:	bc46b683          	ld	a3,-1084(a3) # 80042000 <disk+0x2000>
    80007444:	96ba                	add	a3,a3,a4
    80007446:	4609                	li	a2,2
    80007448:	00c69623          	sh	a2,12(a3)
    8000744c:	b5b1                	j	80007298 <virtio_disk_rw+0xd2>

000000008000744e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000744e:	1101                	addi	sp,sp,-32
    80007450:	ec06                	sd	ra,24(sp)
    80007452:	e822                	sd	s0,16(sp)
    80007454:	e426                	sd	s1,8(sp)
    80007456:	e04a                	sd	s2,0(sp)
    80007458:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000745a:	0003b517          	auipc	a0,0x3b
    8000745e:	cce50513          	addi	a0,a0,-818 # 80042128 <disk+0x2128>
    80007462:	ffff9097          	auipc	ra,0xffff9
    80007466:	7a6080e7          	jalr	1958(ra) # 80000c08 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000746a:	10001737          	lui	a4,0x10001
    8000746e:	533c                	lw	a5,96(a4)
    80007470:	8b8d                	andi	a5,a5,3
    80007472:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007474:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007478:	0003b797          	auipc	a5,0x3b
    8000747c:	b8878793          	addi	a5,a5,-1144 # 80042000 <disk+0x2000>
    80007480:	6b94                	ld	a3,16(a5)
    80007482:	0207d703          	lhu	a4,32(a5)
    80007486:	0026d783          	lhu	a5,2(a3)
    8000748a:	06f70163          	beq	a4,a5,800074ec <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000748e:	00039917          	auipc	s2,0x39
    80007492:	b7290913          	addi	s2,s2,-1166 # 80040000 <disk>
    80007496:	0003b497          	auipc	s1,0x3b
    8000749a:	b6a48493          	addi	s1,s1,-1174 # 80042000 <disk+0x2000>
    __sync_synchronize();
    8000749e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800074a2:	6898                	ld	a4,16(s1)
    800074a4:	0204d783          	lhu	a5,32(s1)
    800074a8:	8b9d                	andi	a5,a5,7
    800074aa:	078e                	slli	a5,a5,0x3
    800074ac:	97ba                	add	a5,a5,a4
    800074ae:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800074b0:	20078713          	addi	a4,a5,512
    800074b4:	0712                	slli	a4,a4,0x4
    800074b6:	974a                	add	a4,a4,s2
    800074b8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800074bc:	e731                	bnez	a4,80007508 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800074be:	20078793          	addi	a5,a5,512
    800074c2:	0792                	slli	a5,a5,0x4
    800074c4:	97ca                	add	a5,a5,s2
    800074c6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800074c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800074cc:	ffffb097          	auipc	ra,0xffffb
    800074d0:	320080e7          	jalr	800(ra) # 800027ec <wakeup>

    disk.used_idx += 1;
    800074d4:	0204d783          	lhu	a5,32(s1)
    800074d8:	2785                	addiw	a5,a5,1
    800074da:	17c2                	slli	a5,a5,0x30
    800074dc:	93c1                	srli	a5,a5,0x30
    800074de:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800074e2:	6898                	ld	a4,16(s1)
    800074e4:	00275703          	lhu	a4,2(a4)
    800074e8:	faf71be3          	bne	a4,a5,8000749e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800074ec:	0003b517          	auipc	a0,0x3b
    800074f0:	c3c50513          	addi	a0,a0,-964 # 80042128 <disk+0x2128>
    800074f4:	ffff9097          	auipc	ra,0xffff9
    800074f8:	7c8080e7          	jalr	1992(ra) # 80000cbc <release>
}
    800074fc:	60e2                	ld	ra,24(sp)
    800074fe:	6442                	ld	s0,16(sp)
    80007500:	64a2                	ld	s1,8(sp)
    80007502:	6902                	ld	s2,0(sp)
    80007504:	6105                	addi	sp,sp,32
    80007506:	8082                	ret
      panic("virtio_disk_intr status");
    80007508:	00002517          	auipc	a0,0x2
    8000750c:	3e050513          	addi	a0,a0,992 # 800098e8 <syscalls+0x408>
    80007510:	ffff9097          	auipc	ra,0xffff9
    80007514:	01e080e7          	jalr	30(ra) # 8000052e <panic>

0000000080007518 <call_sigret>:
    80007518:	48e1                	li	a7,24
    8000751a:	00000073          	ecall
    8000751e:	8082                	ret

0000000080007520 <end_sigret>:
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
