
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
    80000068:	c1c78793          	addi	a5,a5,-996 # 80006c80 <timervec>
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
    80000122:	50e080e7          	jalr	1294(ra) # 8000262c <either_copyin>
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
    800001b6:	b7e080e7          	jalr	-1154(ra) # 80001d30 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	066080e7          	jalr	102(ra) # 80002228 <sleep>
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
    80000202:	3d8080e7          	jalr	984(ra) # 800025d6 <either_copyout>
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
    800002e2:	3a4080e7          	jalr	932(ra) # 80002682 <procdump>
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
    80000436:	f82080e7          	jalr	-126(ra) # 800023b4 <wakeup>
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
    80000464:	0002b797          	auipc	a5,0x2b
    80000468:	8b478793          	addi	a5,a5,-1868 # 8002ad18 <devsw>
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
    8000055c:	01050513          	addi	a0,a0,16 # 80009568 <digits+0x528>
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
    80000882:	b36080e7          	jalr	-1226(ra) # 800023b4 <wakeup>
    
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
    8000090e:	91e080e7          	jalr	-1762(ra) # 80002228 <sleep>
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
    80000b60:	1b8080e7          	jalr	440(ra) # 80001d14 <mycpu>
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
    80000b92:	186080e7          	jalr	390(ra) # 80001d14 <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	17a080e7          	jalr	378(ra) # 80001d14 <mycpu>
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
    80000bb6:	162080e7          	jalr	354(ra) # 80001d14 <mycpu>
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
    80000bf6:	122080e7          	jalr	290(ra) # 80001d14 <mycpu>
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
    80000c22:	0f6080e7          	jalr	246(ra) # 80001d14 <mycpu>
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
    80000e78:	e90080e7          	jalr	-368(ra) # 80001d04 <cpuid>
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
    80000e94:	e74080e7          	jalr	-396(ra) # 80001d04 <cpuid>
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
    80000eb6:	180080e7          	jalr	384(ra) # 80003032 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00006097          	auipc	ra,0x6
    80000ebe:	e06080e7          	jalr	-506(ra) # 80006cc0 <plicinithart>
  }

  scheduler();        
    80000ec2:	00002097          	auipc	ra,0x2
    80000ec6:	e84080e7          	jalr	-380(ra) # 80002d46 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00008517          	auipc	a0,0x8
    80000ede:	68e50513          	addi	a0,a0,1678 # 80009568 <digits+0x528>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00008517          	auipc	a0,0x8
    80000eee:	1b650513          	addi	a0,a0,438 # 800090a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00008517          	auipc	a0,0x8
    80000efe:	66e50513          	addi	a0,a0,1646 # 80009568 <digits+0x528>
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
    80000f26:	d32080e7          	jalr	-718(ra) # 80001c54 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	0e0080e7          	jalr	224(ra) # 8000300a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	100080e7          	jalr	256(ra) # 80003032 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00006097          	auipc	ra,0x6
    80000f3e:	d70080e7          	jalr	-656(ra) # 80006caa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00006097          	auipc	ra,0x6
    80000f46:	d7e080e7          	jalr	-642(ra) # 80006cc0 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00003097          	auipc	ra,0x3
    80000f4e:	9a6080e7          	jalr	-1626(ra) # 800038f0 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	038080e7          	jalr	56(ra) # 80003f8a <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	308080e7          	jalr	776(ra) # 80005262 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00006097          	auipc	ra,0x6
    80000f66:	e80080e7          	jalr	-384(ra) # 80006de2 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	0b6080e7          	jalr	182(ra) # 80002020 <userinit>
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
    80001224:	99e080e7          	jalr	-1634(ra) # 80001bbe <proc_mapstacks>
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
// Return 0 on success, -1 on error.
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
    8000153a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd0000>
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
    80001578:	7bc080e7          	jalr	1980(ra) # 80001d30 <myproc>
    8000157c:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_swap_info.free_spaces);
    8000157e:	17855503          	lhu	a0,376(a0)
    80001582:	00001097          	auipc	ra,0x1
    80001586:	1b0080e7          	jalr	432(ra) # 80002732 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000158a:	0005071b          	sext.w	a4,a0
    8000158e:	47bd                	li	a5,15
    80001590:	02e7ea63          	bltu	a5,a4,800015c4 <insert_page_to_swap_file+0x5e>
    panic("insert_swap: no free index in swap arr");
  p->pages_swap_info.pages[free_index].va = a;                // Set va of page
    80001594:	01750793          	addi	a5,a0,23
    80001598:	0792                	slli	a5,a5,0x4
    8000159a:	97a6                	add	a5,a5,s1
    8000159c:	0127b823          	sd	s2,16(a5)

  if (p->pages_swap_info.free_spaces & (1 << free_index))
    800015a0:	1784d783          	lhu	a5,376(s1)
    800015a4:	40a7d73b          	sraw	a4,a5,a0
    800015a8:	8b05                	andi	a4,a4,1
    800015aa:	e70d                	bnez	a4,800015d4 <insert_page_to_swap_file+0x6e>
    panic("insert_swap: tried to set free space flag when it is already set");
  p->pages_swap_info.free_spaces |= (1 << free_index); // Mark space as occupied
    800015ac:	4705                	li	a4,1
    800015ae:	00a7173b          	sllw	a4,a4,a0
    800015b2:	8fd9                	or	a5,a5,a4
    800015b4:	16f49c23          	sh	a5,376(s1)

  return free_index;
}
    800015b8:	60e2                	ld	ra,24(sp)
    800015ba:	6442                	ld	s0,16(sp)
    800015bc:	64a2                	ld	s1,8(sp)
    800015be:	6902                	ld	s2,0(sp)
    800015c0:	6105                	addi	sp,sp,32
    800015c2:	8082                	ret
    panic("insert_swap: no free index in swap arr");
    800015c4:	00008517          	auipc	a0,0x8
    800015c8:	b6450513          	addi	a0,a0,-1180 # 80009128 <digits+0xe8>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
    panic("insert_swap: tried to set free space flag when it is already set");
    800015d4:	00008517          	auipc	a0,0x8
    800015d8:	b7c50513          	addi	a0,a0,-1156 # 80009150 <digits+0x110>
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	f4e080e7          	jalr	-178(ra) # 8000052a <panic>

00000000800015e4 <insert_page_to_physical_memory>:
// Update data structure
int insert_page_to_physical_memory(uint64 a)
{
    800015e4:	7179                	addi	sp,sp,-48
    800015e6:	f406                	sd	ra,40(sp)
    800015e8:	f022                	sd	s0,32(sp)
    800015ea:	ec26                	sd	s1,24(sp)
    800015ec:	e84a                	sd	s2,16(sp)
    800015ee:	e44e                	sd	s3,8(sp)
    800015f0:	1800                	addi	s0,sp,48
    800015f2:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    800015f4:	00000097          	auipc	ra,0x0
    800015f8:	73c080e7          	jalr	1852(ra) # 80001d30 <myproc>
    800015fc:	84aa                	mv	s1,a0
  int free_index = get_next_free_space(p->pages_physc_info.free_spaces);
    800015fe:	28055503          	lhu	a0,640(a0)
    80001602:	00001097          	auipc	ra,0x1
    80001606:	130080e7          	jalr	304(ra) # 80002732 <get_next_free_space>
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000160a:	0005071b          	sext.w	a4,a0
    8000160e:	47bd                	li	a5,15
    80001610:	04e7eb63          	bltu	a5,a4,80001666 <insert_page_to_physical_memory+0x82>
    80001614:	892a                	mv	s2,a0
    panic("insert_phys: no free index in physc arr");
  p->pages_physc_info.pages[free_index].va = a;                // Set va of page
    80001616:	00451713          	slli	a4,a0,0x4
    8000161a:	9726                	add	a4,a4,s1
    8000161c:	29373423          	sd	s3,648(a4)
  p->pages_physc_info.pages[free_index].time_inserted = p->paging_time; //  Update insertion time
    80001620:	3884b783          	ld	a5,904(s1)
    80001624:	28f72a23          	sw	a5,660(a4)
  p->paging_time++;
    80001628:	0785                	addi	a5,a5,1
    8000162a:	38f4b423          	sd	a5,904(s1)
  reset_aging_counter(&p->pages_physc_info.pages[free_index]);
    8000162e:	0512                	slli	a0,a0,0x4
    80001630:	28850513          	addi	a0,a0,648
    80001634:	9526                	add	a0,a0,s1
    80001636:	00001097          	auipc	ra,0x1
    8000163a:	7c2080e7          	jalr	1986(ra) # 80002df8 <reset_aging_counter>
  if (p->pages_physc_info.free_spaces & (1 << free_index))
    8000163e:	2804d783          	lhu	a5,640(s1)
    80001642:	4127d73b          	sraw	a4,a5,s2
    80001646:	8b05                	andi	a4,a4,1
    80001648:	e71d                	bnez	a4,80001676 <insert_page_to_physical_memory+0x92>
    panic("insert_phys: tried to set free space flag when it is already set");
  p->pages_physc_info.free_spaces |= (1 << free_index); // Mark space as occupied
    8000164a:	4705                	li	a4,1
    8000164c:	0127173b          	sllw	a4,a4,s2
    80001650:	8fd9                	or	a5,a5,a4
    80001652:	28f49023          	sh	a5,640(s1)

  return free_index;
}
    80001656:	854a                	mv	a0,s2
    80001658:	70a2                	ld	ra,40(sp)
    8000165a:	7402                	ld	s0,32(sp)
    8000165c:	64e2                	ld	s1,24(sp)
    8000165e:	6942                	ld	s2,16(sp)
    80001660:	69a2                	ld	s3,8(sp)
    80001662:	6145                	addi	sp,sp,48
    80001664:	8082                	ret
    panic("insert_phys: no free index in physc arr");
    80001666:	00008517          	auipc	a0,0x8
    8000166a:	b3250513          	addi	a0,a0,-1230 # 80009198 <digits+0x158>
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	ebc080e7          	jalr	-324(ra) # 8000052a <panic>
    panic("insert_phys: tried to set free space flag when it is already set");
    80001676:	00008517          	auipc	a0,0x8
    8000167a:	b4a50513          	addi	a0,a0,-1206 # 800091c0 <digits+0x180>
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	eac080e7          	jalr	-340(ra) # 8000052a <panic>

0000000080001686 <remove_page_from_physical_memory>:

// Update data structure
int remove_page_from_physical_memory(uint64 a)
{
    80001686:	1101                	addi	sp,sp,-32
    80001688:	ec06                	sd	ra,24(sp)
    8000168a:	e822                	sd	s0,16(sp)
    8000168c:	e426                	sd	s1,8(sp)
    8000168e:	e04a                	sd	s2,0(sp)
    80001690:	1000                	addi	s0,sp,32
    80001692:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001694:	00000097          	auipc	ra,0x0
    80001698:	69c080e7          	jalr	1692(ra) # 80001d30 <myproc>
    8000169c:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_physc_info.pages);
    8000169e:	28850593          	addi	a1,a0,648
    800016a2:	854a                	mv	a0,s2
    800016a4:	00001097          	auipc	ra,0x1
    800016a8:	0ba080e7          	jalr	186(ra) # 8000275e <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    800016ac:	0005071b          	sext.w	a4,a0
    800016b0:	47bd                	li	a5,15
    800016b2:	02e7ec63          	bltu	a5,a4,800016ea <remove_page_from_physical_memory+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_physc_info.free_spaces & (1 << index)))
    800016b6:	2804d783          	lhu	a5,640(s1)
    800016ba:	40a7d73b          	sraw	a4,a5,a0
    800016be:	8b05                	andi	a4,a4,1
    800016c0:	cf09                	beqz	a4,800016da <remove_page_from_physical_memory+0x54>
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
  p->pages_physc_info.free_spaces ^= (1 << index);
    800016c2:	4705                	li	a4,1
    800016c4:	00a7173b          	sllw	a4,a4,a0
    800016c8:	8fb9                	xor	a5,a5,a4
    800016ca:	28f49023          	sh	a5,640(s1)

  return index;
}
    800016ce:	60e2                	ld	ra,24(sp)
    800016d0:	6442                	ld	s0,16(sp)
    800016d2:	64a2                	ld	s1,8(sp)
    800016d4:	6902                	ld	s2,0(sp)
    800016d6:	6105                	addi	sp,sp,32
    800016d8:	8082                	ret
    panic("remove_page_from_physical_memory: free space flag should be set but is unset");
    800016da:	00008517          	auipc	a0,0x8
    800016de:	b2e50513          	addi	a0,a0,-1234 # 80009208 <digits+0x1c8>
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	e48080e7          	jalr	-440(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    800016ea:	557d                	li	a0,-1
    800016ec:	b7cd                	j	800016ce <remove_page_from_physical_memory+0x48>

00000000800016ee <remove_page_from_swap_file>:

// Update data structure
int remove_page_from_swap_file(uint64 a)
{
    800016ee:	1101                	addi	sp,sp,-32
    800016f0:	ec06                	sd	ra,24(sp)
    800016f2:	e822                	sd	s0,16(sp)
    800016f4:	e426                	sd	s1,8(sp)
    800016f6:	e04a                	sd	s2,0(sp)
    800016f8:	1000                	addi	s0,sp,32
    800016fa:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	634080e7          	jalr	1588(ra) # 80001d30 <myproc>
    80001704:	84aa                	mv	s1,a0
  int index = get_index_in_page_info_array(a, p->pages_swap_info.pages);
    80001706:	18050593          	addi	a1,a0,384
    8000170a:	854a                	mv	a0,s2
    8000170c:	00001097          	auipc	ra,0x1
    80001710:	052080e7          	jalr	82(ra) # 8000275e <get_index_in_page_info_array>
  if (index < 0 || index >= MAX_PSYC_PAGES)
    80001714:	0005071b          	sext.w	a4,a0
    80001718:	47bd                	li	a5,15
    8000171a:	02e7ec63          	bltu	a5,a4,80001752 <remove_page_from_swap_file+0x64>
    return -1; // page is not in phisical mem
  // panic("remove_page_from_physical_memory: not found page to free ");
  if (!(p->pages_swap_info.free_spaces & (1 << index)))
    8000171e:	1784d783          	lhu	a5,376(s1)
    80001722:	40a7d73b          	sraw	a4,a5,a0
    80001726:	8b05                	andi	a4,a4,1
    80001728:	cf09                	beqz	a4,80001742 <remove_page_from_swap_file+0x54>
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
  p->pages_swap_info.free_spaces ^= (1 << index);
    8000172a:	4705                	li	a4,1
    8000172c:	00a7173b          	sllw	a4,a4,a0
    80001730:	8fb9                	xor	a5,a5,a4
    80001732:	16f49c23          	sh	a5,376(s1)

  return index;
    80001736:	60e2                	ld	ra,24(sp)
    80001738:	6442                	ld	s0,16(sp)
    8000173a:	64a2                	ld	s1,8(sp)
    8000173c:	6902                	ld	s2,0(sp)
    8000173e:	6105                	addi	sp,sp,32
    80001740:	8082                	ret
    panic("remove_page_from_swap_file: free space flag should be set but is unset");
    80001742:	00008517          	auipc	a0,0x8
    80001746:	b1650513          	addi	a0,a0,-1258 # 80009258 <digits+0x218>
    8000174a:	fffff097          	auipc	ra,0xfffff
    8000174e:	de0080e7          	jalr	-544(ra) # 8000052a <panic>
    return -1; // page is not in phisical mem
    80001752:	557d                	li	a0,-1
    80001754:	b7cd                	j	80001736 <remove_page_from_swap_file+0x48>

0000000080001756 <uvmunmap>:
{
    80001756:	711d                	addi	sp,sp,-96
    80001758:	ec86                	sd	ra,88(sp)
    8000175a:	e8a2                	sd	s0,80(sp)
    8000175c:	e4a6                	sd	s1,72(sp)
    8000175e:	e0ca                	sd	s2,64(sp)
    80001760:	fc4e                	sd	s3,56(sp)
    80001762:	f852                	sd	s4,48(sp)
    80001764:	f456                	sd	s5,40(sp)
    80001766:	f05a                	sd	s6,32(sp)
    80001768:	ec5e                	sd	s7,24(sp)
    8000176a:	e862                	sd	s8,16(sp)
    8000176c:	e466                	sd	s9,8(sp)
    8000176e:	1080                	addi	s0,sp,96
    80001770:	89aa                	mv	s3,a0
    80001772:	892e                	mv	s2,a1
    80001774:	8a32                	mv	s4,a2
    80001776:	8b36                	mv	s6,a3
  struct proc *p = myproc();
    80001778:	00000097          	auipc	ra,0x0
    8000177c:	5b8080e7          	jalr	1464(ra) # 80001d30 <myproc>
  if ((va % PGSIZE) != 0)
    80001780:	03491793          	slli	a5,s2,0x34
    80001784:	e795                	bnez	a5,800017b0 <uvmunmap+0x5a>
    80001786:	8c2a                	mv	s8,a0
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001788:	0a32                	slli	s4,s4,0xc
    8000178a:	9a4a                	add	s4,s4,s2
    if (PTE_FLAGS(*pte) == PTE_V)
    8000178c:	4b85                	li	s7,1
      if (myproc()->pid > 2 && pagetable == p->pagetable)
    8000178e:	4c89                	li	s9,2
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001790:	6a85                	lui	s5,0x1
    80001792:	07496e63          	bltu	s2,s4,8000180e <uvmunmap+0xb8>
}
    80001796:	60e6                	ld	ra,88(sp)
    80001798:	6446                	ld	s0,80(sp)
    8000179a:	64a6                	ld	s1,72(sp)
    8000179c:	6906                	ld	s2,64(sp)
    8000179e:	79e2                	ld	s3,56(sp)
    800017a0:	7a42                	ld	s4,48(sp)
    800017a2:	7aa2                	ld	s5,40(sp)
    800017a4:	7b02                	ld	s6,32(sp)
    800017a6:	6be2                	ld	s7,24(sp)
    800017a8:	6c42                	ld	s8,16(sp)
    800017aa:	6ca2                	ld	s9,8(sp)
    800017ac:	6125                	addi	sp,sp,96
    800017ae:	8082                	ret
    panic("uvmunmap: not aligned");
    800017b0:	00008517          	auipc	a0,0x8
    800017b4:	af050513          	addi	a0,a0,-1296 # 800092a0 <digits+0x260>
    800017b8:	fffff097          	auipc	ra,0xfffff
    800017bc:	d72080e7          	jalr	-654(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800017c0:	00008517          	auipc	a0,0x8
    800017c4:	af850513          	addi	a0,a0,-1288 # 800092b8 <digits+0x278>
    800017c8:	fffff097          	auipc	ra,0xfffff
    800017cc:	d62080e7          	jalr	-670(ra) # 8000052a <panic>
          panic("uvmunmap: cant find file bos");
    800017d0:	00008517          	auipc	a0,0x8
    800017d4:	af850513          	addi	a0,a0,-1288 # 800092c8 <digits+0x288>
    800017d8:	fffff097          	auipc	ra,0xfffff
    800017dc:	d52080e7          	jalr	-686(ra) # 8000052a <panic>
        print_pages_from_info_arrs();
    800017e0:	00001097          	auipc	ra,0x1
    800017e4:	628080e7          	jalr	1576(ra) # 80002e08 <print_pages_from_info_arrs>
        panic("uvmunmap: not mapped");
    800017e8:	00008517          	auipc	a0,0x8
    800017ec:	b0050513          	addi	a0,a0,-1280 # 800092e8 <digits+0x2a8>
    800017f0:	fffff097          	auipc	ra,0xfffff
    800017f4:	d3a080e7          	jalr	-710(ra) # 8000052a <panic>
    if (PTE_FLAGS(*pte) == PTE_V)
    800017f8:	3ff7f713          	andi	a4,a5,1023
    800017fc:	05770a63          	beq	a4,s7,80001850 <uvmunmap+0xfa>
    if (do_free)
    80001800:	060b1063          	bnez	s6,80001860 <uvmunmap+0x10a>
    *pte = 0;
    80001804:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001808:	9956                	add	s2,s2,s5
    8000180a:	f94976e3          	bgeu	s2,s4,80001796 <uvmunmap+0x40>
    if ((pte = walk(pagetable, a, 0)) == 0)
    8000180e:	4601                	li	a2,0
    80001810:	85ca                	mv	a1,s2
    80001812:	854e                	mv	a0,s3
    80001814:	fffff097          	auipc	ra,0xfffff
    80001818:	792080e7          	jalr	1938(ra) # 80000fa6 <walk>
    8000181c:	84aa                	mv	s1,a0
    8000181e:	d14d                	beqz	a0,800017c0 <uvmunmap+0x6a>
    if ((*pte & PTE_V) == 0){
    80001820:	611c                	ld	a5,0(a0)
    80001822:	0017f713          	andi	a4,a5,1
    80001826:	fb69                	bnez	a4,800017f8 <uvmunmap+0xa2>
      if((*pte & PTE_PG)  && pagetable == p->pagetable){  // page is swapped out
    80001828:	2007f793          	andi	a5,a5,512
    8000182c:	dbd5                	beqz	a5,800017e0 <uvmunmap+0x8a>
    8000182e:	050c3783          	ld	a5,80(s8)
    80001832:	fd379be3          	bne	a5,s3,80001808 <uvmunmap+0xb2>
        if(remove_page_from_swap_file(a)<0)
    80001836:	854a                	mv	a0,s2
    80001838:	00000097          	auipc	ra,0x0
    8000183c:	eb6080e7          	jalr	-330(ra) # 800016ee <remove_page_from_swap_file>
    80001840:	f80548e3          	bltz	a0,800017d0 <uvmunmap+0x7a>
        p->total_pages_num--;
    80001844:	174c2783          	lw	a5,372(s8)
    80001848:	37fd                	addiw	a5,a5,-1
    8000184a:	16fc2a23          	sw	a5,372(s8)
        continue;
    8000184e:	bf6d                	j	80001808 <uvmunmap+0xb2>
      panic("uvmunmap: not a leaf");
    80001850:	00008517          	auipc	a0,0x8
    80001854:	ab050513          	addi	a0,a0,-1360 # 80009300 <digits+0x2c0>
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	cd2080e7          	jalr	-814(ra) # 8000052a <panic>
      uint64 pa = PTE2PA(*pte);
    80001860:	00a7d513          	srli	a0,a5,0xa
      kfree((void *)pa);
    80001864:	0532                	slli	a0,a0,0xc
    80001866:	fffff097          	auipc	ra,0xfffff
    8000186a:	170080e7          	jalr	368(ra) # 800009d6 <kfree>
      if (myproc()->pid > 2 && pagetable == p->pagetable)
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	4c2080e7          	jalr	1218(ra) # 80001d30 <myproc>
    80001876:	591c                	lw	a5,48(a0)
    80001878:	f8fcd6e3          	bge	s9,a5,80001804 <uvmunmap+0xae>
    8000187c:	050c3783          	ld	a5,80(s8)
    80001880:	f93792e3          	bne	a5,s3,80001804 <uvmunmap+0xae>
        if (remove_page_from_physical_memory(a) >= 0)
    80001884:	854a                	mv	a0,s2
    80001886:	00000097          	auipc	ra,0x0
    8000188a:	e00080e7          	jalr	-512(ra) # 80001686 <remove_page_from_physical_memory>
    8000188e:	02054563          	bltz	a0,800018b8 <uvmunmap+0x162>
          myproc()->physical_pages_num--;
    80001892:	00000097          	auipc	ra,0x0
    80001896:	49e080e7          	jalr	1182(ra) # 80001d30 <myproc>
    8000189a:	17052783          	lw	a5,368(a0)
    8000189e:	37fd                	addiw	a5,a5,-1
    800018a0:	16f52823          	sw	a5,368(a0)
          myproc()->total_pages_num--;
    800018a4:	00000097          	auipc	ra,0x0
    800018a8:	48c080e7          	jalr	1164(ra) # 80001d30 <myproc>
    800018ac:	17452783          	lw	a5,372(a0)
    800018b0:	37fd                	addiw	a5,a5,-1
    800018b2:	16f52a23          	sw	a5,372(a0)
    800018b6:	b7b9                	j	80001804 <uvmunmap+0xae>
          print_pages_from_info_arrs();
    800018b8:	00001097          	auipc	ra,0x1
    800018bc:	550080e7          	jalr	1360(ra) # 80002e08 <print_pages_from_info_arrs>
    800018c0:	b791                	j	80001804 <uvmunmap+0xae>

00000000800018c2 <uvmdealloc>:
{
    800018c2:	1101                	addi	sp,sp,-32
    800018c4:	ec06                	sd	ra,24(sp)
    800018c6:	e822                	sd	s0,16(sp)
    800018c8:	e426                	sd	s1,8(sp)
    800018ca:	1000                	addi	s0,sp,32
    return oldsz;
    800018cc:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800018ce:	00b67d63          	bgeu	a2,a1,800018e8 <uvmdealloc+0x26>
    800018d2:	84b2                	mv	s1,a2
  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800018d4:	6785                	lui	a5,0x1
    800018d6:	17fd                	addi	a5,a5,-1
    800018d8:	00f60733          	add	a4,a2,a5
    800018dc:	767d                	lui	a2,0xfffff
    800018de:	8f71                	and	a4,a4,a2
    800018e0:	97ae                	add	a5,a5,a1
    800018e2:	8ff1                	and	a5,a5,a2
    800018e4:	00f76863          	bltu	a4,a5,800018f4 <uvmdealloc+0x32>
}
    800018e8:	8526                	mv	a0,s1
    800018ea:	60e2                	ld	ra,24(sp)
    800018ec:	6442                	ld	s0,16(sp)
    800018ee:	64a2                	ld	s1,8(sp)
    800018f0:	6105                	addi	sp,sp,32
    800018f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800018f4:	8f99                	sub	a5,a5,a4
    800018f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800018f8:	4685                	li	a3,1
    800018fa:	0007861b          	sext.w	a2,a5
    800018fe:	85ba                	mv	a1,a4
    80001900:	00000097          	auipc	ra,0x0
    80001904:	e56080e7          	jalr	-426(ra) # 80001756 <uvmunmap>
    80001908:	b7c5                	j	800018e8 <uvmdealloc+0x26>

000000008000190a <uvmalloc>:
{
    8000190a:	711d                	addi	sp,sp,-96
    8000190c:	ec86                	sd	ra,88(sp)
    8000190e:	e8a2                	sd	s0,80(sp)
    80001910:	e4a6                	sd	s1,72(sp)
    80001912:	e0ca                	sd	s2,64(sp)
    80001914:	fc4e                	sd	s3,56(sp)
    80001916:	f852                	sd	s4,48(sp)
    80001918:	f456                	sd	s5,40(sp)
    8000191a:	f05a                	sd	s6,32(sp)
    8000191c:	ec5e                	sd	s7,24(sp)
    8000191e:	e862                	sd	s8,16(sp)
    80001920:	e466                	sd	s9,8(sp)
    80001922:	e06a                	sd	s10,0(sp)
    80001924:	1080                	addi	s0,sp,96
    80001926:	8baa                	mv	s7,a0
    80001928:	892e                	mv	s2,a1
    8000192a:	8b32                	mv	s6,a2
  struct proc *p = myproc();
    8000192c:	00000097          	auipc	ra,0x0
    80001930:	404080e7          	jalr	1028(ra) # 80001d30 <myproc>
  if (newsz < oldsz)
    80001934:	132b6c63          	bltu	s6,s2,80001a6c <uvmalloc+0x162>
    80001938:	84aa                	mv	s1,a0
  oldsz = PGROUNDUP(oldsz);
    8000193a:	6c05                	lui	s8,0x1
    8000193c:	1c7d                	addi	s8,s8,-1
    8000193e:	9962                	add	s2,s2,s8
    80001940:	7c7d                	lui	s8,0xfffff
    80001942:	01897c33          	and	s8,s2,s8
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001946:	156c7263          	bgeu	s8,s6,80001a8a <uvmalloc+0x180>
    8000194a:	8a62                	mv	s4,s8
    if (p->pid > 2)
    8000194c:	4a89                	li	s5,2
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    8000194e:	4cfd                	li	s9,31
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001950:	493d                	li	s2,15
        printf("calling page out from uvmalloc for pageing out va=%d\n ",i);
    80001952:	00008997          	auipc	s3,0x8
    80001956:	a3698993          	addi	s3,s3,-1482 # 80009388 <digits+0x348>
    8000195a:	a0bd                	j	800019c8 <uvmalloc+0xbe>
        panic("uvmalloc: proc out of space!");
    8000195c:	00008517          	auipc	a0,0x8
    80001960:	9bc50513          	addi	a0,a0,-1604 # 80009318 <digits+0x2d8>
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	bc6080e7          	jalr	-1082(ra) # 8000052a <panic>
          printf("panic recieved for pid=%d\n",p->pid);
    8000196c:	588c                	lw	a1,48(s1)
    8000196e:	00008517          	auipc	a0,0x8
    80001972:	9ca50513          	addi	a0,a0,-1590 # 80009338 <digits+0x2f8>
    80001976:	fffff097          	auipc	ra,0xfffff
    8000197a:	bfe080e7          	jalr	-1026(ra) # 80000574 <printf>
          panic("uvmalloc: did not find the page to swap out!");
    8000197e:	00008517          	auipc	a0,0x8
    80001982:	9da50513          	addi	a0,a0,-1574 # 80009358 <digits+0x318>
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	ba4080e7          	jalr	-1116(ra) # 8000052a <panic>
    mem = kalloc();
    8000198e:	fffff097          	auipc	ra,0xfffff
    80001992:	144080e7          	jalr	324(ra) # 80000ad2 <kalloc>
    80001996:	8d2a                	mv	s10,a0
    if (mem == 0)
    80001998:	c149                	beqz	a0,80001a1a <uvmalloc+0x110>
    memset(mem, 0, PGSIZE);
    8000199a:	6605                	lui	a2,0x1
    8000199c:	4581                	li	a1,0
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	320080e7          	jalr	800(ra) # 80000cbe <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
    800019a6:	4779                	li	a4,30
    800019a8:	86ea                	mv	a3,s10
    800019aa:	6605                	lui	a2,0x1
    800019ac:	85d2                	mv	a1,s4
    800019ae:	855e                	mv	a0,s7
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	6f2080e7          	jalr	1778(ra) # 800010a2 <mappages>
    800019b8:	e935                	bnez	a0,80001a2c <uvmalloc+0x122>
    if (p->pid > 2)
    800019ba:	589c                	lw	a5,48(s1)
    800019bc:	08fac663          	blt	s5,a5,80001a48 <uvmalloc+0x13e>
  for (a = oldsz; a < newsz; a += PGSIZE)
    800019c0:	6785                	lui	a5,0x1
    800019c2:	9a3e                	add	s4,s4,a5
    800019c4:	0b6a7263          	bgeu	s4,s6,80001a68 <uvmalloc+0x15e>
    if (p->pid > 2)
    800019c8:	589c                	lw	a5,48(s1)
    800019ca:	fcfad2e3          	bge	s5,a5,8000198e <uvmalloc+0x84>
      if (p->total_pages_num >= MAX_TOTAL_PAGES)
    800019ce:	1744a783          	lw	a5,372(s1)
    800019d2:	f8fcc5e3          	blt	s9,a5,8000195c <uvmalloc+0x52>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    800019d6:	1704a783          	lw	a5,368(s1)
    800019da:	faf95ae3          	bge	s2,a5,8000198e <uvmalloc+0x84>
        int i = get_next_page_to_swap_out();
    800019de:	00001097          	auipc	ra,0x1
    800019e2:	580080e7          	jalr	1408(ra) # 80002f5e <get_next_page_to_swap_out>
    800019e6:	85aa                	mv	a1,a0
        if (i < 0 || i >= MAX_PSYC_PAGES){
    800019e8:	0005079b          	sext.w	a5,a0
    800019ec:	f8f960e3          	bltu	s2,a5,8000196c <uvmalloc+0x62>
        uint64 rva = p->pages_physc_info.pages[i].va;
    800019f0:	02850793          	addi	a5,a0,40
    800019f4:	0792                	slli	a5,a5,0x4
    800019f6:	97a6                	add	a5,a5,s1
    800019f8:	0087bd03          	ld	s10,8(a5) # 1008 <_entry-0x7fffeff8>
        printf("calling page out from uvmalloc for pageing out va=%d\n ",i);
    800019fc:	854e                	mv	a0,s3
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	b76080e7          	jalr	-1162(ra) # 80000574 <printf>
        page_out(rva);
    80001a06:	856a                	mv	a0,s10
    80001a08:	00001097          	auipc	ra,0x1
    80001a0c:	d7a080e7          	jalr	-646(ra) # 80002782 <page_out>
      while (p->physical_pages_num >= MAX_PSYC_PAGES)
    80001a10:	1704a783          	lw	a5,368(s1)
    80001a14:	fcf945e3          	blt	s2,a5,800019de <uvmalloc+0xd4>
    80001a18:	bf9d                	j	8000198e <uvmalloc+0x84>
      uvmdealloc(pagetable, a, oldsz);
    80001a1a:	8662                	mv	a2,s8
    80001a1c:	85d2                	mv	a1,s4
    80001a1e:	855e                	mv	a0,s7
    80001a20:	00000097          	auipc	ra,0x0
    80001a24:	ea2080e7          	jalr	-350(ra) # 800018c2 <uvmdealloc>
      return 0;
    80001a28:	4501                	li	a0,0
    80001a2a:	a091                	j	80001a6e <uvmalloc+0x164>
      kfree(mem);
    80001a2c:	856a                	mv	a0,s10
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	fa8080e7          	jalr	-88(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001a36:	8662                	mv	a2,s8
    80001a38:	85d2                	mv	a1,s4
    80001a3a:	855e                	mv	a0,s7
    80001a3c:	00000097          	auipc	ra,0x0
    80001a40:	e86080e7          	jalr	-378(ra) # 800018c2 <uvmdealloc>
      return 0;
    80001a44:	4501                	li	a0,0
    80001a46:	a025                	j	80001a6e <uvmalloc+0x164>
      insert_page_to_physical_memory(a);
    80001a48:	8552                	mv	a0,s4
    80001a4a:	00000097          	auipc	ra,0x0
    80001a4e:	b9a080e7          	jalr	-1126(ra) # 800015e4 <insert_page_to_physical_memory>
      p->total_pages_num++;
    80001a52:	1744a783          	lw	a5,372(s1)
    80001a56:	2785                	addiw	a5,a5,1
    80001a58:	16f4aa23          	sw	a5,372(s1)
      p->physical_pages_num++;
    80001a5c:	1704a783          	lw	a5,368(s1)
    80001a60:	2785                	addiw	a5,a5,1
    80001a62:	16f4a823          	sw	a5,368(s1)
    80001a66:	bfa9                	j	800019c0 <uvmalloc+0xb6>
  return newsz;
    80001a68:	855a                	mv	a0,s6
    80001a6a:	a011                	j	80001a6e <uvmalloc+0x164>
    return oldsz;
    80001a6c:	854a                	mv	a0,s2
}
    80001a6e:	60e6                	ld	ra,88(sp)
    80001a70:	6446                	ld	s0,80(sp)
    80001a72:	64a6                	ld	s1,72(sp)
    80001a74:	6906                	ld	s2,64(sp)
    80001a76:	79e2                	ld	s3,56(sp)
    80001a78:	7a42                	ld	s4,48(sp)
    80001a7a:	7aa2                	ld	s5,40(sp)
    80001a7c:	7b02                	ld	s6,32(sp)
    80001a7e:	6be2                	ld	s7,24(sp)
    80001a80:	6c42                	ld	s8,16(sp)
    80001a82:	6ca2                	ld	s9,8(sp)
    80001a84:	6d02                	ld	s10,0(sp)
    80001a86:	6125                	addi	sp,sp,96
    80001a88:	8082                	ret
  return newsz;
    80001a8a:	855a                	mv	a0,s6
    80001a8c:	b7cd                	j	80001a6e <uvmalloc+0x164>

0000000080001a8e <uvmfree>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	1000                	addi	s0,sp,32
    80001a98:	84aa                	mv	s1,a0
  if (sz > 0)
    80001a9a:	e999                	bnez	a1,80001ab0 <uvmfree+0x22>
  freewalk(pagetable);
    80001a9c:	8526                	mv	a0,s1
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	858080e7          	jalr	-1960(ra) # 800012f6 <freewalk>
}
    80001aa6:	60e2                	ld	ra,24(sp)
    80001aa8:	6442                	ld	s0,16(sp)
    80001aaa:	64a2                	ld	s1,8(sp)
    80001aac:	6105                	addi	sp,sp,32
    80001aae:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	167d                	addi	a2,a2,-1
    80001ab4:	962e                	add	a2,a2,a1
    80001ab6:	4685                	li	a3,1
    80001ab8:	8231                	srli	a2,a2,0xc
    80001aba:	4581                	li	a1,0
    80001abc:	00000097          	auipc	ra,0x0
    80001ac0:	c9a080e7          	jalr	-870(ra) # 80001756 <uvmunmap>
    80001ac4:	bfe1                	j	80001a9c <uvmfree+0xe>

0000000080001ac6 <uvmcopy>:
  for (i = 0; i < sz; i += PGSIZE)
    80001ac6:	ca65                	beqz	a2,80001bb6 <uvmcopy+0xf0>
{
    80001ac8:	715d                	addi	sp,sp,-80
    80001aca:	e486                	sd	ra,72(sp)
    80001acc:	e0a2                	sd	s0,64(sp)
    80001ace:	fc26                	sd	s1,56(sp)
    80001ad0:	f84a                	sd	s2,48(sp)
    80001ad2:	f44e                	sd	s3,40(sp)
    80001ad4:	f052                	sd	s4,32(sp)
    80001ad6:	ec56                	sd	s5,24(sp)
    80001ad8:	e85a                	sd	s6,16(sp)
    80001ada:	e45e                	sd	s7,8(sp)
    80001adc:	0880                	addi	s0,sp,80
    80001ade:	8aaa                	mv	s5,a0
    80001ae0:	8a2e                	mv	s4,a1
    80001ae2:	89b2                	mv	s3,a2
  for (i = 0; i < sz; i += PGSIZE)
    80001ae4:	4901                	li	s2,0
    80001ae6:	a08d                	j	80001b48 <uvmcopy+0x82>
      panic("uvmcopy: pte should exist");
    80001ae8:	00008517          	auipc	a0,0x8
    80001aec:	8d850513          	addi	a0,a0,-1832 # 800093c0 <digits+0x380>
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	a3a080e7          	jalr	-1478(ra) # 8000052a <panic>
        panic("uvmcopy: page not present");
    80001af8:	00008517          	auipc	a0,0x8
    80001afc:	8e850513          	addi	a0,a0,-1816 # 800093e0 <digits+0x3a0>
    80001b00:	fffff097          	auipc	ra,0xfffff
    80001b04:	a2a080e7          	jalr	-1494(ra) # 8000052a <panic>
    pa = PTE2PA(*pte);
    80001b08:	00a75593          	srli	a1,a4,0xa
    80001b0c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001b10:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	fbe080e7          	jalr	-66(ra) # 80000ad2 <kalloc>
    80001b1c:	8b2a                	mv	s6,a0
    80001b1e:	c52d                	beqz	a0,80001b88 <uvmcopy+0xc2>
    memmove(mem, (char *)pa, PGSIZE);
    80001b20:	6605                	lui	a2,0x1
    80001b22:	85de                	mv	a1,s7
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	1f6080e7          	jalr	502(ra) # 80000d1a <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    80001b2c:	8726                	mv	a4,s1
    80001b2e:	86da                	mv	a3,s6
    80001b30:	6605                	lui	a2,0x1
    80001b32:	85ca                	mv	a1,s2
    80001b34:	8552                	mv	a0,s4
    80001b36:	fffff097          	auipc	ra,0xfffff
    80001b3a:	56c080e7          	jalr	1388(ra) # 800010a2 <mappages>
    80001b3e:	e121                	bnez	a0,80001b7e <uvmcopy+0xb8>
  for (i = 0; i < sz; i += PGSIZE)
    80001b40:	6785                	lui	a5,0x1
    80001b42:	993e                	add	s2,s2,a5
    80001b44:	05397d63          	bgeu	s2,s3,80001b9e <uvmcopy+0xd8>
    if ((pte = walk(old, i, 0)) == 0)
    80001b48:	4601                	li	a2,0
    80001b4a:	85ca                	mv	a1,s2
    80001b4c:	8556                	mv	a0,s5
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	458080e7          	jalr	1112(ra) # 80000fa6 <walk>
    80001b56:	84aa                	mv	s1,a0
    80001b58:	d941                	beqz	a0,80001ae8 <uvmcopy+0x22>
    if ((*pte & PTE_V) == 0){
    80001b5a:	6118                	ld	a4,0(a0)
    80001b5c:	00177793          	andi	a5,a4,1
    80001b60:	f7c5                	bnez	a5,80001b08 <uvmcopy+0x42>
      if(!(*pte & PTE_PG))
    80001b62:	20077713          	andi	a4,a4,512
    80001b66:	db49                	beqz	a4,80001af8 <uvmcopy+0x32>
      if((np_pte = walk(new, i, 1)) == 0)
    80001b68:	4605                	li	a2,1
    80001b6a:	85ca                	mv	a1,s2
    80001b6c:	8552                	mv	a0,s4
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	438080e7          	jalr	1080(ra) # 80000fa6 <walk>
    80001b76:	c131                	beqz	a0,80001bba <uvmcopy+0xf4>
      *np_pte = *pte; 
    80001b78:	609c                	ld	a5,0(s1)
    80001b7a:	e11c                	sd	a5,0(a0)
      continue;
    80001b7c:	b7d1                	j	80001b40 <uvmcopy+0x7a>
      kfree(mem);
    80001b7e:	855a                	mv	a0,s6
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	e56080e7          	jalr	-426(ra) # 800009d6 <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001b88:	4685                	li	a3,1
    80001b8a:	00c95613          	srli	a2,s2,0xc
    80001b8e:	4581                	li	a1,0
    80001b90:	8552                	mv	a0,s4
    80001b92:	00000097          	auipc	ra,0x0
    80001b96:	bc4080e7          	jalr	-1084(ra) # 80001756 <uvmunmap>
  return -1;
    80001b9a:	557d                	li	a0,-1
    80001b9c:	a011                	j	80001ba0 <uvmcopy+0xda>
  return 0;
    80001b9e:	4501                	li	a0,0
}
    80001ba0:	60a6                	ld	ra,72(sp)
    80001ba2:	6406                	ld	s0,64(sp)
    80001ba4:	74e2                	ld	s1,56(sp)
    80001ba6:	7942                	ld	s2,48(sp)
    80001ba8:	79a2                	ld	s3,40(sp)
    80001baa:	7a02                	ld	s4,32(sp)
    80001bac:	6ae2                	ld	s5,24(sp)
    80001bae:	6b42                	ld	s6,16(sp)
    80001bb0:	6ba2                	ld	s7,8(sp)
    80001bb2:	6161                	addi	sp,sp,80
    80001bb4:	8082                	ret
  return 0;
    80001bb6:	4501                	li	a0,0
}
    80001bb8:	8082                	ret
        return -1;
    80001bba:	557d                	li	a0,-1
    80001bbc:	b7d5                	j	80001ba0 <uvmcopy+0xda>

0000000080001bbe <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001bbe:	7139                	addi	sp,sp,-64
    80001bc0:	fc06                	sd	ra,56(sp)
    80001bc2:	f822                	sd	s0,48(sp)
    80001bc4:	f426                	sd	s1,40(sp)
    80001bc6:	f04a                	sd	s2,32(sp)
    80001bc8:	ec4e                	sd	s3,24(sp)
    80001bca:	e852                	sd	s4,16(sp)
    80001bcc:	e456                	sd	s5,8(sp)
    80001bce:	e05a                	sd	s6,0(sp)
    80001bd0:	0080                	addi	s0,sp,64
    80001bd2:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001bd4:	00011497          	auipc	s1,0x11
    80001bd8:	afc48493          	addi	s1,s1,-1284 # 800126d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001bdc:	8b26                	mv	s6,s1
    80001bde:	00007a97          	auipc	s5,0x7
    80001be2:	422a8a93          	addi	s5,s5,1058 # 80009000 <etext>
    80001be6:	04000937          	lui	s2,0x4000
    80001bea:	197d                	addi	s2,s2,-1
    80001bec:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001bee:	0001fa17          	auipc	s4,0x1f
    80001bf2:	ee2a0a13          	addi	s4,s4,-286 # 80020ad0 <tickslock>
    char *pa = kalloc();
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	edc080e7          	jalr	-292(ra) # 80000ad2 <kalloc>
    80001bfe:	862a                	mv	a2,a0
    if (pa == 0)
    80001c00:	c131                	beqz	a0,80001c44 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001c02:	416485b3          	sub	a1,s1,s6
    80001c06:	8591                	srai	a1,a1,0x4
    80001c08:	000ab783          	ld	a5,0(s5)
    80001c0c:	02f585b3          	mul	a1,a1,a5
    80001c10:	2585                	addiw	a1,a1,1
    80001c12:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c16:	4719                	li	a4,6
    80001c18:	6685                	lui	a3,0x1
    80001c1a:	40b905b3          	sub	a1,s2,a1
    80001c1e:	854e                	mv	a0,s3
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	510080e7          	jalr	1296(ra) # 80001130 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c28:	39048493          	addi	s1,s1,912
    80001c2c:	fd4495e3          	bne	s1,s4,80001bf6 <proc_mapstacks+0x38>
  }
}
    80001c30:	70e2                	ld	ra,56(sp)
    80001c32:	7442                	ld	s0,48(sp)
    80001c34:	74a2                	ld	s1,40(sp)
    80001c36:	7902                	ld	s2,32(sp)
    80001c38:	69e2                	ld	s3,24(sp)
    80001c3a:	6a42                	ld	s4,16(sp)
    80001c3c:	6aa2                	ld	s5,8(sp)
    80001c3e:	6b02                	ld	s6,0(sp)
    80001c40:	6121                	addi	sp,sp,64
    80001c42:	8082                	ret
      panic("kalloc");
    80001c44:	00007517          	auipc	a0,0x7
    80001c48:	7bc50513          	addi	a0,a0,1980 # 80009400 <digits+0x3c0>
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	8de080e7          	jalr	-1826(ra) # 8000052a <panic>

0000000080001c54 <procinit>:

// initialize the proc table at boot time.
void procinit(void)
{
    80001c54:	7139                	addi	sp,sp,-64
    80001c56:	fc06                	sd	ra,56(sp)
    80001c58:	f822                	sd	s0,48(sp)
    80001c5a:	f426                	sd	s1,40(sp)
    80001c5c:	f04a                	sd	s2,32(sp)
    80001c5e:	ec4e                	sd	s3,24(sp)
    80001c60:	e852                	sd	s4,16(sp)
    80001c62:	e456                	sd	s5,8(sp)
    80001c64:	e05a                	sd	s6,0(sp)
    80001c66:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001c68:	00007597          	auipc	a1,0x7
    80001c6c:	7a058593          	addi	a1,a1,1952 # 80009408 <digits+0x3c8>
    80001c70:	00010517          	auipc	a0,0x10
    80001c74:	63050513          	addi	a0,a0,1584 # 800122a0 <pid_lock>
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	eba080e7          	jalr	-326(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c80:	00007597          	auipc	a1,0x7
    80001c84:	79058593          	addi	a1,a1,1936 # 80009410 <digits+0x3d0>
    80001c88:	00010517          	auipc	a0,0x10
    80001c8c:	63050513          	addi	a0,a0,1584 # 800122b8 <wait_lock>
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	ea2080e7          	jalr	-350(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c98:	00011497          	auipc	s1,0x11
    80001c9c:	a3848493          	addi	s1,s1,-1480 # 800126d0 <proc>
  {
    initlock(&p->lock, "proc");
    80001ca0:	00007b17          	auipc	s6,0x7
    80001ca4:	780b0b13          	addi	s6,s6,1920 # 80009420 <digits+0x3e0>
    p->kstack = KSTACK((int)(p - proc));
    80001ca8:	8aa6                	mv	s5,s1
    80001caa:	00007a17          	auipc	s4,0x7
    80001cae:	356a0a13          	addi	s4,s4,854 # 80009000 <etext>
    80001cb2:	04000937          	lui	s2,0x4000
    80001cb6:	197d                	addi	s2,s2,-1
    80001cb8:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001cba:	0001f997          	auipc	s3,0x1f
    80001cbe:	e1698993          	addi	s3,s3,-490 # 80020ad0 <tickslock>
    initlock(&p->lock, "proc");
    80001cc2:	85da                	mv	a1,s6
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	e6c080e7          	jalr	-404(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001cce:	415487b3          	sub	a5,s1,s5
    80001cd2:	8791                	srai	a5,a5,0x4
    80001cd4:	000a3703          	ld	a4,0(s4)
    80001cd8:	02e787b3          	mul	a5,a5,a4
    80001cdc:	2785                	addiw	a5,a5,1
    80001cde:	00d7979b          	slliw	a5,a5,0xd
    80001ce2:	40f907b3          	sub	a5,s2,a5
    80001ce6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001ce8:	39048493          	addi	s1,s1,912
    80001cec:	fd349be3          	bne	s1,s3,80001cc2 <procinit+0x6e>
  }
}
    80001cf0:	70e2                	ld	ra,56(sp)
    80001cf2:	7442                	ld	s0,48(sp)
    80001cf4:	74a2                	ld	s1,40(sp)
    80001cf6:	7902                	ld	s2,32(sp)
    80001cf8:	69e2                	ld	s3,24(sp)
    80001cfa:	6a42                	ld	s4,16(sp)
    80001cfc:	6aa2                	ld	s5,8(sp)
    80001cfe:	6b02                	ld	s6,0(sp)
    80001d00:	6121                	addi	sp,sp,64
    80001d02:	8082                	ret

0000000080001d04 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001d04:	1141                	addi	sp,sp,-16
    80001d06:	e422                	sd	s0,8(sp)
    80001d08:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d0a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d0c:	2501                	sext.w	a0,a0
    80001d0e:	6422                	ld	s0,8(sp)
    80001d10:	0141                	addi	sp,sp,16
    80001d12:	8082                	ret

0000000080001d14 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001d14:	1141                	addi	sp,sp,-16
    80001d16:	e422                	sd	s0,8(sp)
    80001d18:	0800                	addi	s0,sp,16
    80001d1a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d1c:	2781                	sext.w	a5,a5
    80001d1e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001d20:	00010517          	auipc	a0,0x10
    80001d24:	5b050513          	addi	a0,a0,1456 # 800122d0 <cpus>
    80001d28:	953e                	add	a0,a0,a5
    80001d2a:	6422                	ld	s0,8(sp)
    80001d2c:	0141                	addi	sp,sp,16
    80001d2e:	8082                	ret

0000000080001d30 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001d30:	1101                	addi	sp,sp,-32
    80001d32:	ec06                	sd	ra,24(sp)
    80001d34:	e822                	sd	s0,16(sp)
    80001d36:	e426                	sd	s1,8(sp)
    80001d38:	1000                	addi	s0,sp,32
  push_off();
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	e3c080e7          	jalr	-452(ra) # 80000b76 <push_off>
    80001d42:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d44:	2781                	sext.w	a5,a5
    80001d46:	079e                	slli	a5,a5,0x7
    80001d48:	00010717          	auipc	a4,0x10
    80001d4c:	55870713          	addi	a4,a4,1368 # 800122a0 <pid_lock>
    80001d50:	97ba                	add	a5,a5,a4
    80001d52:	7b84                	ld	s1,48(a5)
  pop_off();
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	ec2080e7          	jalr	-318(ra) # 80000c16 <pop_off>
  return p;
}
    80001d5c:	8526                	mv	a0,s1
    80001d5e:	60e2                	ld	ra,24(sp)
    80001d60:	6442                	ld	s0,16(sp)
    80001d62:	64a2                	ld	s1,8(sp)
    80001d64:	6105                	addi	sp,sp,32
    80001d66:	8082                	ret

0000000080001d68 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001d68:	1141                	addi	sp,sp,-16
    80001d6a:	e406                	sd	ra,8(sp)
    80001d6c:	e022                	sd	s0,0(sp)
    80001d6e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	fc0080e7          	jalr	-64(ra) # 80001d30 <myproc>
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	efe080e7          	jalr	-258(ra) # 80000c76 <release>

  if (first)
    80001d80:	00008797          	auipc	a5,0x8
    80001d84:	1a07a783          	lw	a5,416(a5) # 80009f20 <first.1>
    80001d88:	eb89                	bnez	a5,80001d9a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001d8a:	00001097          	auipc	ra,0x1
    80001d8e:	2c0080e7          	jalr	704(ra) # 8000304a <usertrapret>
}
    80001d92:	60a2                	ld	ra,8(sp)
    80001d94:	6402                	ld	s0,0(sp)
    80001d96:	0141                	addi	sp,sp,16
    80001d98:	8082                	ret
    first = 0;
    80001d9a:	00008797          	auipc	a5,0x8
    80001d9e:	1807a323          	sw	zero,390(a5) # 80009f20 <first.1>
    fsinit(ROOTDEV);
    80001da2:	4505                	li	a0,1
    80001da4:	00002097          	auipc	ra,0x2
    80001da8:	166080e7          	jalr	358(ra) # 80003f0a <fsinit>
    80001dac:	bff9                	j	80001d8a <forkret+0x22>

0000000080001dae <allocpid>:
{
    80001dae:	1101                	addi	sp,sp,-32
    80001db0:	ec06                	sd	ra,24(sp)
    80001db2:	e822                	sd	s0,16(sp)
    80001db4:	e426                	sd	s1,8(sp)
    80001db6:	e04a                	sd	s2,0(sp)
    80001db8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001dba:	00010917          	auipc	s2,0x10
    80001dbe:	4e690913          	addi	s2,s2,1254 # 800122a0 <pid_lock>
    80001dc2:	854a                	mv	a0,s2
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	dfe080e7          	jalr	-514(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001dcc:	00008797          	auipc	a5,0x8
    80001dd0:	15878793          	addi	a5,a5,344 # 80009f24 <nextpid>
    80001dd4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001dd6:	0014871b          	addiw	a4,s1,1
    80001dda:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ddc:	854a                	mv	a0,s2
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	e98080e7          	jalr	-360(ra) # 80000c76 <release>
}
    80001de6:	8526                	mv	a0,s1
    80001de8:	60e2                	ld	ra,24(sp)
    80001dea:	6442                	ld	s0,16(sp)
    80001dec:	64a2                	ld	s1,8(sp)
    80001dee:	6902                	ld	s2,0(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret

0000000080001df4 <proc_pagetable>:
{
    80001df4:	1101                	addi	sp,sp,-32
    80001df6:	ec06                	sd	ra,24(sp)
    80001df8:	e822                	sd	s0,16(sp)
    80001dfa:	e426                	sd	s1,8(sp)
    80001dfc:	e04a                	sd	s2,0(sp)
    80001dfe:	1000                	addi	s0,sp,32
    80001e00:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	454080e7          	jalr	1108(ra) # 80001256 <uvmcreate>
    80001e0a:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001e0c:	c121                	beqz	a0,80001e4c <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e0e:	4729                	li	a4,10
    80001e10:	00006697          	auipc	a3,0x6
    80001e14:	1f068693          	addi	a3,a3,496 # 80008000 <_trampoline>
    80001e18:	6605                	lui	a2,0x1
    80001e1a:	040005b7          	lui	a1,0x4000
    80001e1e:	15fd                	addi	a1,a1,-1
    80001e20:	05b2                	slli	a1,a1,0xc
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	280080e7          	jalr	640(ra) # 800010a2 <mappages>
    80001e2a:	02054863          	bltz	a0,80001e5a <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e2e:	4719                	li	a4,6
    80001e30:	05893683          	ld	a3,88(s2)
    80001e34:	6605                	lui	a2,0x1
    80001e36:	020005b7          	lui	a1,0x2000
    80001e3a:	15fd                	addi	a1,a1,-1
    80001e3c:	05b6                	slli	a1,a1,0xd
    80001e3e:	8526                	mv	a0,s1
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	262080e7          	jalr	610(ra) # 800010a2 <mappages>
    80001e48:	02054163          	bltz	a0,80001e6a <proc_pagetable+0x76>
}
    80001e4c:	8526                	mv	a0,s1
    80001e4e:	60e2                	ld	ra,24(sp)
    80001e50:	6442                	ld	s0,16(sp)
    80001e52:	64a2                	ld	s1,8(sp)
    80001e54:	6902                	ld	s2,0(sp)
    80001e56:	6105                	addi	sp,sp,32
    80001e58:	8082                	ret
    uvmfree(pagetable, 0);
    80001e5a:	4581                	li	a1,0
    80001e5c:	8526                	mv	a0,s1
    80001e5e:	00000097          	auipc	ra,0x0
    80001e62:	c30080e7          	jalr	-976(ra) # 80001a8e <uvmfree>
    return 0;
    80001e66:	4481                	li	s1,0
    80001e68:	b7d5                	j	80001e4c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e6a:	4681                	li	a3,0
    80001e6c:	4605                	li	a2,1
    80001e6e:	040005b7          	lui	a1,0x4000
    80001e72:	15fd                	addi	a1,a1,-1
    80001e74:	05b2                	slli	a1,a1,0xc
    80001e76:	8526                	mv	a0,s1
    80001e78:	00000097          	auipc	ra,0x0
    80001e7c:	8de080e7          	jalr	-1826(ra) # 80001756 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e80:	4581                	li	a1,0
    80001e82:	8526                	mv	a0,s1
    80001e84:	00000097          	auipc	ra,0x0
    80001e88:	c0a080e7          	jalr	-1014(ra) # 80001a8e <uvmfree>
    return 0;
    80001e8c:	4481                	li	s1,0
    80001e8e:	bf7d                	j	80001e4c <proc_pagetable+0x58>

0000000080001e90 <proc_freepagetable>:
{
    80001e90:	1101                	addi	sp,sp,-32
    80001e92:	ec06                	sd	ra,24(sp)
    80001e94:	e822                	sd	s0,16(sp)
    80001e96:	e426                	sd	s1,8(sp)
    80001e98:	e04a                	sd	s2,0(sp)
    80001e9a:	1000                	addi	s0,sp,32
    80001e9c:	84aa                	mv	s1,a0
    80001e9e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea0:	4681                	li	a3,0
    80001ea2:	4605                	li	a2,1
    80001ea4:	040005b7          	lui	a1,0x4000
    80001ea8:	15fd                	addi	a1,a1,-1
    80001eaa:	05b2                	slli	a1,a1,0xc
    80001eac:	00000097          	auipc	ra,0x0
    80001eb0:	8aa080e7          	jalr	-1878(ra) # 80001756 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001eb4:	4681                	li	a3,0
    80001eb6:	4605                	li	a2,1
    80001eb8:	020005b7          	lui	a1,0x2000
    80001ebc:	15fd                	addi	a1,a1,-1
    80001ebe:	05b6                	slli	a1,a1,0xd
    80001ec0:	8526                	mv	a0,s1
    80001ec2:	00000097          	auipc	ra,0x0
    80001ec6:	894080e7          	jalr	-1900(ra) # 80001756 <uvmunmap>
  uvmfree(pagetable, sz);
    80001eca:	85ca                	mv	a1,s2
    80001ecc:	8526                	mv	a0,s1
    80001ece:	00000097          	auipc	ra,0x0
    80001ed2:	bc0080e7          	jalr	-1088(ra) # 80001a8e <uvmfree>
}
    80001ed6:	60e2                	ld	ra,24(sp)
    80001ed8:	6442                	ld	s0,16(sp)
    80001eda:	64a2                	ld	s1,8(sp)
    80001edc:	6902                	ld	s2,0(sp)
    80001ede:	6105                	addi	sp,sp,32
    80001ee0:	8082                	ret

0000000080001ee2 <freeproc>:
{
    80001ee2:	1101                	addi	sp,sp,-32
    80001ee4:	ec06                	sd	ra,24(sp)
    80001ee6:	e822                	sd	s0,16(sp)
    80001ee8:	e426                	sd	s1,8(sp)
    80001eea:	1000                	addi	s0,sp,32
    80001eec:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001eee:	6d28                	ld	a0,88(a0)
    80001ef0:	c509                	beqz	a0,80001efa <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001ef2:	fffff097          	auipc	ra,0xfffff
    80001ef6:	ae4080e7          	jalr	-1308(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001efa:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001efe:	68a8                	ld	a0,80(s1)
    80001f00:	c511                	beqz	a0,80001f0c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001f02:	64ac                	ld	a1,72(s1)
    80001f04:	00000097          	auipc	ra,0x0
    80001f08:	f8c080e7          	jalr	-116(ra) # 80001e90 <proc_freepagetable>
  p->pagetable = 0;
    80001f0c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001f10:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001f14:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001f18:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001f1c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001f20:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001f24:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001f28:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001f2c:	0004ac23          	sw	zero,24(s1)
  p->paging_time = 0;
    80001f30:	3804b423          	sd	zero,904(s1)
}
    80001f34:	60e2                	ld	ra,24(sp)
    80001f36:	6442                	ld	s0,16(sp)
    80001f38:	64a2                	ld	s1,8(sp)
    80001f3a:	6105                	addi	sp,sp,32
    80001f3c:	8082                	ret

0000000080001f3e <allocproc>:
{
    80001f3e:	1101                	addi	sp,sp,-32
    80001f40:	ec06                	sd	ra,24(sp)
    80001f42:	e822                	sd	s0,16(sp)
    80001f44:	e426                	sd	s1,8(sp)
    80001f46:	e04a                	sd	s2,0(sp)
    80001f48:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001f4a:	00010497          	auipc	s1,0x10
    80001f4e:	78648493          	addi	s1,s1,1926 # 800126d0 <proc>
    80001f52:	0001f917          	auipc	s2,0x1f
    80001f56:	b7e90913          	addi	s2,s2,-1154 # 80020ad0 <tickslock>
    acquire(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	fffff097          	auipc	ra,0xfffff
    80001f60:	c66080e7          	jalr	-922(ra) # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001f64:	4c9c                	lw	a5,24(s1)
    80001f66:	cf81                	beqz	a5,80001f7e <allocproc+0x40>
      release(&p->lock);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	d0c080e7          	jalr	-756(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001f72:	39048493          	addi	s1,s1,912
    80001f76:	ff2492e3          	bne	s1,s2,80001f5a <allocproc+0x1c>
  return 0;
    80001f7a:	4481                	li	s1,0
    80001f7c:	a09d                	j	80001fe2 <allocproc+0xa4>
  p->pid = allocpid();
    80001f7e:	00000097          	auipc	ra,0x0
    80001f82:	e30080e7          	jalr	-464(ra) # 80001dae <allocpid>
    80001f86:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001f88:	4785                	li	a5,1
    80001f8a:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	b46080e7          	jalr	-1210(ra) # 80000ad2 <kalloc>
    80001f94:	892a                	mv	s2,a0
    80001f96:	eca8                	sd	a0,88(s1)
    80001f98:	cd21                	beqz	a0,80001ff0 <allocproc+0xb2>
  p->pagetable = proc_pagetable(p);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	e58080e7          	jalr	-424(ra) # 80001df4 <proc_pagetable>
    80001fa4:	892a                	mv	s2,a0
    80001fa6:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001fa8:	c125                	beqz	a0,80002008 <allocproc+0xca>
  memset(&p->context, 0, sizeof(p->context));
    80001faa:	07000613          	li	a2,112
    80001fae:	4581                	li	a1,0
    80001fb0:	06048513          	addi	a0,s1,96
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	d0a080e7          	jalr	-758(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001fbc:	00000797          	auipc	a5,0x0
    80001fc0:	dac78793          	addi	a5,a5,-596 # 80001d68 <forkret>
    80001fc4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001fc6:	60bc                	ld	a5,64(s1)
    80001fc8:	6705                	lui	a4,0x1
    80001fca:	97ba                	add	a5,a5,a4
    80001fcc:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001fce:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001fd2:	1604aa23          	sw	zero,372(s1)
  p->pages_physc_info.free_spaces = 0;
    80001fd6:	28049023          	sh	zero,640(s1)
  p->pages_swap_info.free_spaces = 0;
    80001fda:	16049c23          	sh	zero,376(s1)
  p->paging_time = 0;
    80001fde:	3804b423          	sd	zero,904(s1)
}
    80001fe2:	8526                	mv	a0,s1
    80001fe4:	60e2                	ld	ra,24(sp)
    80001fe6:	6442                	ld	s0,16(sp)
    80001fe8:	64a2                	ld	s1,8(sp)
    80001fea:	6902                	ld	s2,0(sp)
    80001fec:	6105                	addi	sp,sp,32
    80001fee:	8082                	ret
    freeproc(p);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	00000097          	auipc	ra,0x0
    80001ff6:	ef0080e7          	jalr	-272(ra) # 80001ee2 <freeproc>
    release(&p->lock);
    80001ffa:	8526                	mv	a0,s1
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	c7a080e7          	jalr	-902(ra) # 80000c76 <release>
    return 0;
    80002004:	84ca                	mv	s1,s2
    80002006:	bff1                	j	80001fe2 <allocproc+0xa4>
    freeproc(p);
    80002008:	8526                	mv	a0,s1
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	ed8080e7          	jalr	-296(ra) # 80001ee2 <freeproc>
    release(&p->lock);
    80002012:	8526                	mv	a0,s1
    80002014:	fffff097          	auipc	ra,0xfffff
    80002018:	c62080e7          	jalr	-926(ra) # 80000c76 <release>
    return 0;
    8000201c:	84ca                	mv	s1,s2
    8000201e:	b7d1                	j	80001fe2 <allocproc+0xa4>

0000000080002020 <userinit>:
{
    80002020:	1101                	addi	sp,sp,-32
    80002022:	ec06                	sd	ra,24(sp)
    80002024:	e822                	sd	s0,16(sp)
    80002026:	e426                	sd	s1,8(sp)
    80002028:	1000                	addi	s0,sp,32
  p = allocproc();
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	f14080e7          	jalr	-236(ra) # 80001f3e <allocproc>
    80002032:	84aa                	mv	s1,a0
  initproc = p;
    80002034:	00008797          	auipc	a5,0x8
    80002038:	fea7ba23          	sd	a0,-12(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000203c:	03400613          	li	a2,52
    80002040:	00008597          	auipc	a1,0x8
    80002044:	ef058593          	addi	a1,a1,-272 # 80009f30 <initcode>
    80002048:	6928                	ld	a0,80(a0)
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	23a080e7          	jalr	570(ra) # 80001284 <uvminit>
  p->sz = PGSIZE;
    80002052:	6785                	lui	a5,0x1
    80002054:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80002056:	6cb8                	ld	a4,88(s1)
    80002058:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    8000205c:	6cb8                	ld	a4,88(s1)
    8000205e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002060:	4641                	li	a2,16
    80002062:	00007597          	auipc	a1,0x7
    80002066:	3c658593          	addi	a1,a1,966 # 80009428 <digits+0x3e8>
    8000206a:	15848513          	addi	a0,s1,344
    8000206e:	fffff097          	auipc	ra,0xfffff
    80002072:	da2080e7          	jalr	-606(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80002076:	00007517          	auipc	a0,0x7
    8000207a:	3c250513          	addi	a0,a0,962 # 80009438 <digits+0x3f8>
    8000207e:	00003097          	auipc	ra,0x3
    80002082:	8ba080e7          	jalr	-1862(ra) # 80004938 <namei>
    80002086:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000208a:	478d                	li	a5,3
    8000208c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	be6080e7          	jalr	-1050(ra) # 80000c76 <release>
}
    80002098:	60e2                	ld	ra,24(sp)
    8000209a:	6442                	ld	s0,16(sp)
    8000209c:	64a2                	ld	s1,8(sp)
    8000209e:	6105                	addi	sp,sp,32
    800020a0:	8082                	ret

00000000800020a2 <growproc>:
{
    800020a2:	1101                	addi	sp,sp,-32
    800020a4:	ec06                	sd	ra,24(sp)
    800020a6:	e822                	sd	s0,16(sp)
    800020a8:	e426                	sd	s1,8(sp)
    800020aa:	e04a                	sd	s2,0(sp)
    800020ac:	1000                	addi	s0,sp,32
    800020ae:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	c80080e7          	jalr	-896(ra) # 80001d30 <myproc>
    800020b8:	892a                	mv	s2,a0
  sz = p->sz;
    800020ba:	652c                	ld	a1,72(a0)
    800020bc:	0005861b          	sext.w	a2,a1
  if (n > 0)
    800020c0:	00904f63          	bgtz	s1,800020de <growproc+0x3c>
  else if (n < 0)
    800020c4:	0204cc63          	bltz	s1,800020fc <growproc+0x5a>
  p->sz = sz;
    800020c8:	1602                	slli	a2,a2,0x20
    800020ca:	9201                	srli	a2,a2,0x20
    800020cc:	04c93423          	sd	a2,72(s2)
  return 0;
    800020d0:	4501                	li	a0,0
}
    800020d2:	60e2                	ld	ra,24(sp)
    800020d4:	6442                	ld	s0,16(sp)
    800020d6:	64a2                	ld	s1,8(sp)
    800020d8:	6902                	ld	s2,0(sp)
    800020da:	6105                	addi	sp,sp,32
    800020dc:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    800020de:	9e25                	addw	a2,a2,s1
    800020e0:	1602                	slli	a2,a2,0x20
    800020e2:	9201                	srli	a2,a2,0x20
    800020e4:	1582                	slli	a1,a1,0x20
    800020e6:	9181                	srli	a1,a1,0x20
    800020e8:	6928                	ld	a0,80(a0)
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	820080e7          	jalr	-2016(ra) # 8000190a <uvmalloc>
    800020f2:	0005061b          	sext.w	a2,a0
    800020f6:	fa69                	bnez	a2,800020c8 <growproc+0x26>
      return -1;
    800020f8:	557d                	li	a0,-1
    800020fa:	bfe1                	j	800020d2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800020fc:	9e25                	addw	a2,a2,s1
    800020fe:	1602                	slli	a2,a2,0x20
    80002100:	9201                	srli	a2,a2,0x20
    80002102:	1582                	slli	a1,a1,0x20
    80002104:	9181                	srli	a1,a1,0x20
    80002106:	6928                	ld	a0,80(a0)
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	7ba080e7          	jalr	1978(ra) # 800018c2 <uvmdealloc>
    80002110:	0005061b          	sext.w	a2,a0
    80002114:	bf55                	j	800020c8 <growproc+0x26>

0000000080002116 <sched>:
{
    80002116:	7179                	addi	sp,sp,-48
    80002118:	f406                	sd	ra,40(sp)
    8000211a:	f022                	sd	s0,32(sp)
    8000211c:	ec26                	sd	s1,24(sp)
    8000211e:	e84a                	sd	s2,16(sp)
    80002120:	e44e                	sd	s3,8(sp)
    80002122:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002124:	00000097          	auipc	ra,0x0
    80002128:	c0c080e7          	jalr	-1012(ra) # 80001d30 <myproc>
    8000212c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	a1a080e7          	jalr	-1510(ra) # 80000b48 <holding>
    80002136:	c93d                	beqz	a0,800021ac <sched+0x96>
    80002138:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000213a:	2781                	sext.w	a5,a5
    8000213c:	079e                	slli	a5,a5,0x7
    8000213e:	00010717          	auipc	a4,0x10
    80002142:	16270713          	addi	a4,a4,354 # 800122a0 <pid_lock>
    80002146:	97ba                	add	a5,a5,a4
    80002148:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    8000214c:	4785                	li	a5,1
    8000214e:	06f71763          	bne	a4,a5,800021bc <sched+0xa6>
  if (p->state == RUNNING)
    80002152:	4c98                	lw	a4,24(s1)
    80002154:	4791                	li	a5,4
    80002156:	06f70b63          	beq	a4,a5,800021cc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000215a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000215e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002160:	efb5                	bnez	a5,800021dc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002162:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002164:	00010917          	auipc	s2,0x10
    80002168:	13c90913          	addi	s2,s2,316 # 800122a0 <pid_lock>
    8000216c:	2781                	sext.w	a5,a5
    8000216e:	079e                	slli	a5,a5,0x7
    80002170:	97ca                	add	a5,a5,s2
    80002172:	0ac7a983          	lw	s3,172(a5)
    80002176:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002178:	2781                	sext.w	a5,a5
    8000217a:	079e                	slli	a5,a5,0x7
    8000217c:	00010597          	auipc	a1,0x10
    80002180:	15c58593          	addi	a1,a1,348 # 800122d8 <cpus+0x8>
    80002184:	95be                	add	a1,a1,a5
    80002186:	06048513          	addi	a0,s1,96
    8000218a:	00001097          	auipc	ra,0x1
    8000218e:	e16080e7          	jalr	-490(ra) # 80002fa0 <swtch>
    80002192:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002194:	2781                	sext.w	a5,a5
    80002196:	079e                	slli	a5,a5,0x7
    80002198:	97ca                	add	a5,a5,s2
    8000219a:	0b37a623          	sw	s3,172(a5)
}
    8000219e:	70a2                	ld	ra,40(sp)
    800021a0:	7402                	ld	s0,32(sp)
    800021a2:	64e2                	ld	s1,24(sp)
    800021a4:	6942                	ld	s2,16(sp)
    800021a6:	69a2                	ld	s3,8(sp)
    800021a8:	6145                	addi	sp,sp,48
    800021aa:	8082                	ret
    panic("sched p->lock");
    800021ac:	00007517          	auipc	a0,0x7
    800021b0:	29450513          	addi	a0,a0,660 # 80009440 <digits+0x400>
    800021b4:	ffffe097          	auipc	ra,0xffffe
    800021b8:	376080e7          	jalr	886(ra) # 8000052a <panic>
    panic("sched locks");
    800021bc:	00007517          	auipc	a0,0x7
    800021c0:	29450513          	addi	a0,a0,660 # 80009450 <digits+0x410>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	366080e7          	jalr	870(ra) # 8000052a <panic>
    panic("sched running");
    800021cc:	00007517          	auipc	a0,0x7
    800021d0:	29450513          	addi	a0,a0,660 # 80009460 <digits+0x420>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	356080e7          	jalr	854(ra) # 8000052a <panic>
    panic("sched interruptible");
    800021dc:	00007517          	auipc	a0,0x7
    800021e0:	29450513          	addi	a0,a0,660 # 80009470 <digits+0x430>
    800021e4:	ffffe097          	auipc	ra,0xffffe
    800021e8:	346080e7          	jalr	838(ra) # 8000052a <panic>

00000000800021ec <yield>:
{
    800021ec:	1101                	addi	sp,sp,-32
    800021ee:	ec06                	sd	ra,24(sp)
    800021f0:	e822                	sd	s0,16(sp)
    800021f2:	e426                	sd	s1,8(sp)
    800021f4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021f6:	00000097          	auipc	ra,0x0
    800021fa:	b3a080e7          	jalr	-1222(ra) # 80001d30 <myproc>
    800021fe:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	9c2080e7          	jalr	-1598(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80002208:	478d                	li	a5,3
    8000220a:	cc9c                	sw	a5,24(s1)
  sched();
    8000220c:	00000097          	auipc	ra,0x0
    80002210:	f0a080e7          	jalr	-246(ra) # 80002116 <sched>
  release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	a60080e7          	jalr	-1440(ra) # 80000c76 <release>
}
    8000221e:	60e2                	ld	ra,24(sp)
    80002220:	6442                	ld	s0,16(sp)
    80002222:	64a2                	ld	s1,8(sp)
    80002224:	6105                	addi	sp,sp,32
    80002226:	8082                	ret

0000000080002228 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002228:	7179                	addi	sp,sp,-48
    8000222a:	f406                	sd	ra,40(sp)
    8000222c:	f022                	sd	s0,32(sp)
    8000222e:	ec26                	sd	s1,24(sp)
    80002230:	e84a                	sd	s2,16(sp)
    80002232:	e44e                	sd	s3,8(sp)
    80002234:	1800                	addi	s0,sp,48
    80002236:	89aa                	mv	s3,a0
    80002238:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	af6080e7          	jalr	-1290(ra) # 80001d30 <myproc>
    80002242:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	97e080e7          	jalr	-1666(ra) # 80000bc2 <acquire>
  release(lk);
    8000224c:	854a                	mv	a0,s2
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	a28080e7          	jalr	-1496(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80002256:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000225a:	4789                	li	a5,2
    8000225c:	cc9c                	sw	a5,24(s1)

  sched();
    8000225e:	00000097          	auipc	ra,0x0
    80002262:	eb8080e7          	jalr	-328(ra) # 80002116 <sched>

  // Tidy up.
  p->chan = 0;
    80002266:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000226a:	8526                	mv	a0,s1
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	a0a080e7          	jalr	-1526(ra) # 80000c76 <release>
  acquire(lk);
    80002274:	854a                	mv	a0,s2
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	94c080e7          	jalr	-1716(ra) # 80000bc2 <acquire>
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6145                	addi	sp,sp,48
    8000228a:	8082                	ret

000000008000228c <wait>:
{
    8000228c:	715d                	addi	sp,sp,-80
    8000228e:	e486                	sd	ra,72(sp)
    80002290:	e0a2                	sd	s0,64(sp)
    80002292:	fc26                	sd	s1,56(sp)
    80002294:	f84a                	sd	s2,48(sp)
    80002296:	f44e                	sd	s3,40(sp)
    80002298:	f052                	sd	s4,32(sp)
    8000229a:	ec56                	sd	s5,24(sp)
    8000229c:	e85a                	sd	s6,16(sp)
    8000229e:	e45e                	sd	s7,8(sp)
    800022a0:	e062                	sd	s8,0(sp)
    800022a2:	0880                	addi	s0,sp,80
    800022a4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022a6:	00000097          	auipc	ra,0x0
    800022aa:	a8a080e7          	jalr	-1398(ra) # 80001d30 <myproc>
    800022ae:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022b0:	00010517          	auipc	a0,0x10
    800022b4:	00850513          	addi	a0,a0,8 # 800122b8 <wait_lock>
    800022b8:	fffff097          	auipc	ra,0xfffff
    800022bc:	90a080e7          	jalr	-1782(ra) # 80000bc2 <acquire>
    havekids = 0;
    800022c0:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    800022c2:	4a15                	li	s4,5
        havekids = 1;
    800022c4:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800022c6:	0001f997          	auipc	s3,0x1f
    800022ca:	80a98993          	addi	s3,s3,-2038 # 80020ad0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    800022ce:	00010c17          	auipc	s8,0x10
    800022d2:	feac0c13          	addi	s8,s8,-22 # 800122b8 <wait_lock>
    havekids = 0;
    800022d6:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    800022d8:	00010497          	auipc	s1,0x10
    800022dc:	3f848493          	addi	s1,s1,1016 # 800126d0 <proc>
    800022e0:	a0bd                	j	8000234e <wait+0xc2>
          pid = np->pid;
    800022e2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022e6:	000b0e63          	beqz	s6,80002302 <wait+0x76>
    800022ea:	4691                	li	a3,4
    800022ec:	02c48613          	addi	a2,s1,44
    800022f0:	85da                	mv	a1,s6
    800022f2:	05093503          	ld	a0,80(s2)
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	09c080e7          	jalr	156(ra) # 80001392 <copyout>
    800022fe:	02054563          	bltz	a0,80002328 <wait+0x9c>
          freeproc(np);
    80002302:	8526                	mv	a0,s1
    80002304:	00000097          	auipc	ra,0x0
    80002308:	bde080e7          	jalr	-1058(ra) # 80001ee2 <freeproc>
          release(&np->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	968080e7          	jalr	-1688(ra) # 80000c76 <release>
          release(&wait_lock);
    80002316:	00010517          	auipc	a0,0x10
    8000231a:	fa250513          	addi	a0,a0,-94 # 800122b8 <wait_lock>
    8000231e:	fffff097          	auipc	ra,0xfffff
    80002322:	958080e7          	jalr	-1704(ra) # 80000c76 <release>
          return pid;
    80002326:	a09d                	j	8000238c <wait+0x100>
            release(&np->lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	94c080e7          	jalr	-1716(ra) # 80000c76 <release>
            release(&wait_lock);
    80002332:	00010517          	auipc	a0,0x10
    80002336:	f8650513          	addi	a0,a0,-122 # 800122b8 <wait_lock>
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	93c080e7          	jalr	-1732(ra) # 80000c76 <release>
            return -1;
    80002342:	59fd                	li	s3,-1
    80002344:	a0a1                	j	8000238c <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    80002346:	39048493          	addi	s1,s1,912
    8000234a:	03348463          	beq	s1,s3,80002372 <wait+0xe6>
      if (np->parent == p)
    8000234e:	7c9c                	ld	a5,56(s1)
    80002350:	ff279be3          	bne	a5,s2,80002346 <wait+0xba>
        acquire(&np->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	86c080e7          	jalr	-1940(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    8000235e:	4c9c                	lw	a5,24(s1)
    80002360:	f94781e3          	beq	a5,s4,800022e2 <wait+0x56>
        release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	910080e7          	jalr	-1776(ra) # 80000c76 <release>
        havekids = 1;
    8000236e:	8756                	mv	a4,s5
    80002370:	bfd9                	j	80002346 <wait+0xba>
    if (!havekids || p->killed)
    80002372:	c701                	beqz	a4,8000237a <wait+0xee>
    80002374:	02892783          	lw	a5,40(s2)
    80002378:	c79d                	beqz	a5,800023a6 <wait+0x11a>
      release(&wait_lock);
    8000237a:	00010517          	auipc	a0,0x10
    8000237e:	f3e50513          	addi	a0,a0,-194 # 800122b8 <wait_lock>
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	8f4080e7          	jalr	-1804(ra) # 80000c76 <release>
      return -1;
    8000238a:	59fd                	li	s3,-1
}
    8000238c:	854e                	mv	a0,s3
    8000238e:	60a6                	ld	ra,72(sp)
    80002390:	6406                	ld	s0,64(sp)
    80002392:	74e2                	ld	s1,56(sp)
    80002394:	7942                	ld	s2,48(sp)
    80002396:	79a2                	ld	s3,40(sp)
    80002398:	7a02                	ld	s4,32(sp)
    8000239a:	6ae2                	ld	s5,24(sp)
    8000239c:	6b42                	ld	s6,16(sp)
    8000239e:	6ba2                	ld	s7,8(sp)
    800023a0:	6c02                	ld	s8,0(sp)
    800023a2:	6161                	addi	sp,sp,80
    800023a4:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    800023a6:	85e2                	mv	a1,s8
    800023a8:	854a                	mv	a0,s2
    800023aa:	00000097          	auipc	ra,0x0
    800023ae:	e7e080e7          	jalr	-386(ra) # 80002228 <sleep>
    havekids = 0;
    800023b2:	b715                	j	800022d6 <wait+0x4a>

00000000800023b4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800023b4:	7139                	addi	sp,sp,-64
    800023b6:	fc06                	sd	ra,56(sp)
    800023b8:	f822                	sd	s0,48(sp)
    800023ba:	f426                	sd	s1,40(sp)
    800023bc:	f04a                	sd	s2,32(sp)
    800023be:	ec4e                	sd	s3,24(sp)
    800023c0:	e852                	sd	s4,16(sp)
    800023c2:	e456                	sd	s5,8(sp)
    800023c4:	0080                	addi	s0,sp,64
    800023c6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800023c8:	00010497          	auipc	s1,0x10
    800023cc:	30848493          	addi	s1,s1,776 # 800126d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800023d0:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800023d2:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800023d4:	0001e917          	auipc	s2,0x1e
    800023d8:	6fc90913          	addi	s2,s2,1788 # 80020ad0 <tickslock>
    800023dc:	a811                	j	800023f0 <wakeup+0x3c>
      }
      release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	896080e7          	jalr	-1898(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023e8:	39048493          	addi	s1,s1,912
    800023ec:	03248663          	beq	s1,s2,80002418 <wakeup+0x64>
    if (p != myproc())
    800023f0:	00000097          	auipc	ra,0x0
    800023f4:	940080e7          	jalr	-1728(ra) # 80001d30 <myproc>
    800023f8:	fea488e3          	beq	s1,a0,800023e8 <wakeup+0x34>
      acquire(&p->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	7c4080e7          	jalr	1988(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002406:	4c9c                	lw	a5,24(s1)
    80002408:	fd379be3          	bne	a5,s3,800023de <wakeup+0x2a>
    8000240c:	709c                	ld	a5,32(s1)
    8000240e:	fd4798e3          	bne	a5,s4,800023de <wakeup+0x2a>
        p->state = RUNNABLE;
    80002412:	0154ac23          	sw	s5,24(s1)
    80002416:	b7e1                	j	800023de <wakeup+0x2a>
    }
  }
}
    80002418:	70e2                	ld	ra,56(sp)
    8000241a:	7442                	ld	s0,48(sp)
    8000241c:	74a2                	ld	s1,40(sp)
    8000241e:	7902                	ld	s2,32(sp)
    80002420:	69e2                	ld	s3,24(sp)
    80002422:	6a42                	ld	s4,16(sp)
    80002424:	6aa2                	ld	s5,8(sp)
    80002426:	6121                	addi	sp,sp,64
    80002428:	8082                	ret

000000008000242a <reparent>:
{
    8000242a:	7179                	addi	sp,sp,-48
    8000242c:	f406                	sd	ra,40(sp)
    8000242e:	f022                	sd	s0,32(sp)
    80002430:	ec26                	sd	s1,24(sp)
    80002432:	e84a                	sd	s2,16(sp)
    80002434:	e44e                	sd	s3,8(sp)
    80002436:	e052                	sd	s4,0(sp)
    80002438:	1800                	addi	s0,sp,48
    8000243a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000243c:	00010497          	auipc	s1,0x10
    80002440:	29448493          	addi	s1,s1,660 # 800126d0 <proc>
      pp->parent = initproc;
    80002444:	00008a17          	auipc	s4,0x8
    80002448:	be4a0a13          	addi	s4,s4,-1052 # 8000a028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244c:	0001e997          	auipc	s3,0x1e
    80002450:	68498993          	addi	s3,s3,1668 # 80020ad0 <tickslock>
    80002454:	a029                	j	8000245e <reparent+0x34>
    80002456:	39048493          	addi	s1,s1,912
    8000245a:	01348d63          	beq	s1,s3,80002474 <reparent+0x4a>
    if (pp->parent == p)
    8000245e:	7c9c                	ld	a5,56(s1)
    80002460:	ff279be3          	bne	a5,s2,80002456 <reparent+0x2c>
      pp->parent = initproc;
    80002464:	000a3503          	ld	a0,0(s4)
    80002468:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000246a:	00000097          	auipc	ra,0x0
    8000246e:	f4a080e7          	jalr	-182(ra) # 800023b4 <wakeup>
    80002472:	b7d5                	j	80002456 <reparent+0x2c>
}
    80002474:	70a2                	ld	ra,40(sp)
    80002476:	7402                	ld	s0,32(sp)
    80002478:	64e2                	ld	s1,24(sp)
    8000247a:	6942                	ld	s2,16(sp)
    8000247c:	69a2                	ld	s3,8(sp)
    8000247e:	6a02                	ld	s4,0(sp)
    80002480:	6145                	addi	sp,sp,48
    80002482:	8082                	ret

0000000080002484 <exit>:
{
    80002484:	7179                	addi	sp,sp,-48
    80002486:	f406                	sd	ra,40(sp)
    80002488:	f022                	sd	s0,32(sp)
    8000248a:	ec26                	sd	s1,24(sp)
    8000248c:	e84a                	sd	s2,16(sp)
    8000248e:	e44e                	sd	s3,8(sp)
    80002490:	e052                	sd	s4,0(sp)
    80002492:	1800                	addi	s0,sp,48
    80002494:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002496:	00000097          	auipc	ra,0x0
    8000249a:	89a080e7          	jalr	-1894(ra) # 80001d30 <myproc>
    8000249e:	89aa                	mv	s3,a0
  if (p == initproc)
    800024a0:	00008797          	auipc	a5,0x8
    800024a4:	b887b783          	ld	a5,-1144(a5) # 8000a028 <initproc>
    800024a8:	0d050493          	addi	s1,a0,208
    800024ac:	15050913          	addi	s2,a0,336
    800024b0:	02a79363          	bne	a5,a0,800024d6 <exit+0x52>
    panic("init exiting");
    800024b4:	00007517          	auipc	a0,0x7
    800024b8:	fd450513          	addi	a0,a0,-44 # 80009488 <digits+0x448>
    800024bc:	ffffe097          	auipc	ra,0xffffe
    800024c0:	06e080e7          	jalr	110(ra) # 8000052a <panic>
      fileclose(f);
    800024c4:	00003097          	auipc	ra,0x3
    800024c8:	e82080e7          	jalr	-382(ra) # 80005346 <fileclose>
      p->ofile[fd] = 0;
    800024cc:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800024d0:	04a1                	addi	s1,s1,8
    800024d2:	01248563          	beq	s1,s2,800024dc <exit+0x58>
    if (p->ofile[fd])
    800024d6:	6088                	ld	a0,0(s1)
    800024d8:	f575                	bnez	a0,800024c4 <exit+0x40>
    800024da:	bfdd                	j	800024d0 <exit+0x4c>
  removeSwapFile(p);  // Remove swap file of p
    800024dc:	854e                	mv	a0,s3
    800024de:	00002097          	auipc	ra,0x2
    800024e2:	506080e7          	jalr	1286(ra) # 800049e4 <removeSwapFile>
  begin_op();
    800024e6:	00003097          	auipc	ra,0x3
    800024ea:	994080e7          	jalr	-1644(ra) # 80004e7a <begin_op>
  iput(p->cwd);
    800024ee:	1509b503          	ld	a0,336(s3)
    800024f2:	00002097          	auipc	ra,0x2
    800024f6:	e4a080e7          	jalr	-438(ra) # 8000433c <iput>
  end_op();
    800024fa:	00003097          	auipc	ra,0x3
    800024fe:	a00080e7          	jalr	-1536(ra) # 80004efa <end_op>
  p->cwd = 0;
    80002502:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002506:	00010497          	auipc	s1,0x10
    8000250a:	db248493          	addi	s1,s1,-590 # 800122b8 <wait_lock>
    8000250e:	8526                	mv	a0,s1
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	6b2080e7          	jalr	1714(ra) # 80000bc2 <acquire>
  reparent(p);
    80002518:	854e                	mv	a0,s3
    8000251a:	00000097          	auipc	ra,0x0
    8000251e:	f10080e7          	jalr	-240(ra) # 8000242a <reparent>
  wakeup(p->parent);
    80002522:	0389b503          	ld	a0,56(s3)
    80002526:	00000097          	auipc	ra,0x0
    8000252a:	e8e080e7          	jalr	-370(ra) # 800023b4 <wakeup>
  acquire(&p->lock);
    8000252e:	854e                	mv	a0,s3
    80002530:	ffffe097          	auipc	ra,0xffffe
    80002534:	692080e7          	jalr	1682(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002538:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000253c:	4795                	li	a5,5
    8000253e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	732080e7          	jalr	1842(ra) # 80000c76 <release>
  sched();
    8000254c:	00000097          	auipc	ra,0x0
    80002550:	bca080e7          	jalr	-1078(ra) # 80002116 <sched>
  panic("zombie exit");
    80002554:	00007517          	auipc	a0,0x7
    80002558:	f4450513          	addi	a0,a0,-188 # 80009498 <digits+0x458>
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	fce080e7          	jalr	-50(ra) # 8000052a <panic>

0000000080002564 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002564:	7179                	addi	sp,sp,-48
    80002566:	f406                	sd	ra,40(sp)
    80002568:	f022                	sd	s0,32(sp)
    8000256a:	ec26                	sd	s1,24(sp)
    8000256c:	e84a                	sd	s2,16(sp)
    8000256e:	e44e                	sd	s3,8(sp)
    80002570:	1800                	addi	s0,sp,48
    80002572:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002574:	00010497          	auipc	s1,0x10
    80002578:	15c48493          	addi	s1,s1,348 # 800126d0 <proc>
    8000257c:	0001e997          	auipc	s3,0x1e
    80002580:	55498993          	addi	s3,s3,1364 # 80020ad0 <tickslock>
  {
    acquire(&p->lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	63c080e7          	jalr	1596(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    8000258e:	589c                	lw	a5,48(s1)
    80002590:	01278d63          	beq	a5,s2,800025aa <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	6e0080e7          	jalr	1760(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000259e:	39048493          	addi	s1,s1,912
    800025a2:	ff3491e3          	bne	s1,s3,80002584 <kill+0x20>
  }
  return -1;
    800025a6:	557d                	li	a0,-1
    800025a8:	a829                	j	800025c2 <kill+0x5e>
      p->killed = 1;
    800025aa:	4785                	li	a5,1
    800025ac:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800025ae:	4c98                	lw	a4,24(s1)
    800025b0:	4789                	li	a5,2
    800025b2:	00f70f63          	beq	a4,a5,800025d0 <kill+0x6c>
      release(&p->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	6be080e7          	jalr	1726(ra) # 80000c76 <release>
      return 0;
    800025c0:	4501                	li	a0,0
}
    800025c2:	70a2                	ld	ra,40(sp)
    800025c4:	7402                	ld	s0,32(sp)
    800025c6:	64e2                	ld	s1,24(sp)
    800025c8:	6942                	ld	s2,16(sp)
    800025ca:	69a2                	ld	s3,8(sp)
    800025cc:	6145                	addi	sp,sp,48
    800025ce:	8082                	ret
        p->state = RUNNABLE;
    800025d0:	478d                	li	a5,3
    800025d2:	cc9c                	sw	a5,24(s1)
    800025d4:	b7cd                	j	800025b6 <kill+0x52>

00000000800025d6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025d6:	7179                	addi	sp,sp,-48
    800025d8:	f406                	sd	ra,40(sp)
    800025da:	f022                	sd	s0,32(sp)
    800025dc:	ec26                	sd	s1,24(sp)
    800025de:	e84a                	sd	s2,16(sp)
    800025e0:	e44e                	sd	s3,8(sp)
    800025e2:	e052                	sd	s4,0(sp)
    800025e4:	1800                	addi	s0,sp,48
    800025e6:	84aa                	mv	s1,a0
    800025e8:	892e                	mv	s2,a1
    800025ea:	89b2                	mv	s3,a2
    800025ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	742080e7          	jalr	1858(ra) # 80001d30 <myproc>
  if (user_dst)
    800025f6:	c08d                	beqz	s1,80002618 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800025f8:	86d2                	mv	a3,s4
    800025fa:	864e                	mv	a2,s3
    800025fc:	85ca                	mv	a1,s2
    800025fe:	6928                	ld	a0,80(a0)
    80002600:	fffff097          	auipc	ra,0xfffff
    80002604:	d92080e7          	jalr	-622(ra) # 80001392 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002608:	70a2                	ld	ra,40(sp)
    8000260a:	7402                	ld	s0,32(sp)
    8000260c:	64e2                	ld	s1,24(sp)
    8000260e:	6942                	ld	s2,16(sp)
    80002610:	69a2                	ld	s3,8(sp)
    80002612:	6a02                	ld	s4,0(sp)
    80002614:	6145                	addi	sp,sp,48
    80002616:	8082                	ret
    memmove((char *)dst, src, len);
    80002618:	000a061b          	sext.w	a2,s4
    8000261c:	85ce                	mv	a1,s3
    8000261e:	854a                	mv	a0,s2
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	6fa080e7          	jalr	1786(ra) # 80000d1a <memmove>
    return 0;
    80002628:	8526                	mv	a0,s1
    8000262a:	bff9                	j	80002608 <either_copyout+0x32>

000000008000262c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000262c:	7179                	addi	sp,sp,-48
    8000262e:	f406                	sd	ra,40(sp)
    80002630:	f022                	sd	s0,32(sp)
    80002632:	ec26                	sd	s1,24(sp)
    80002634:	e84a                	sd	s2,16(sp)
    80002636:	e44e                	sd	s3,8(sp)
    80002638:	e052                	sd	s4,0(sp)
    8000263a:	1800                	addi	s0,sp,48
    8000263c:	892a                	mv	s2,a0
    8000263e:	84ae                	mv	s1,a1
    80002640:	89b2                	mv	s3,a2
    80002642:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002644:	fffff097          	auipc	ra,0xfffff
    80002648:	6ec080e7          	jalr	1772(ra) # 80001d30 <myproc>
  if (user_src)
    8000264c:	c08d                	beqz	s1,8000266e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000264e:	86d2                	mv	a3,s4
    80002650:	864e                	mv	a2,s3
    80002652:	85ca                	mv	a1,s2
    80002654:	6928                	ld	a0,80(a0)
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	dca080e7          	jalr	-566(ra) # 80001420 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000265e:	70a2                	ld	ra,40(sp)
    80002660:	7402                	ld	s0,32(sp)
    80002662:	64e2                	ld	s1,24(sp)
    80002664:	6942                	ld	s2,16(sp)
    80002666:	69a2                	ld	s3,8(sp)
    80002668:	6a02                	ld	s4,0(sp)
    8000266a:	6145                	addi	sp,sp,48
    8000266c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000266e:	000a061b          	sext.w	a2,s4
    80002672:	85ce                	mv	a1,s3
    80002674:	854a                	mv	a0,s2
    80002676:	ffffe097          	auipc	ra,0xffffe
    8000267a:	6a4080e7          	jalr	1700(ra) # 80000d1a <memmove>
    return 0;
    8000267e:	8526                	mv	a0,s1
    80002680:	bff9                	j	8000265e <either_copyin+0x32>

0000000080002682 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002682:	715d                	addi	sp,sp,-80
    80002684:	e486                	sd	ra,72(sp)
    80002686:	e0a2                	sd	s0,64(sp)
    80002688:	fc26                	sd	s1,56(sp)
    8000268a:	f84a                	sd	s2,48(sp)
    8000268c:	f44e                	sd	s3,40(sp)
    8000268e:	f052                	sd	s4,32(sp)
    80002690:	ec56                	sd	s5,24(sp)
    80002692:	e85a                	sd	s6,16(sp)
    80002694:	e45e                	sd	s7,8(sp)
    80002696:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002698:	00007517          	auipc	a0,0x7
    8000269c:	ed050513          	addi	a0,a0,-304 # 80009568 <digits+0x528>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	ed4080e7          	jalr	-300(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026a8:	00010497          	auipc	s1,0x10
    800026ac:	18048493          	addi	s1,s1,384 # 80012828 <proc+0x158>
    800026b0:	0001e917          	auipc	s2,0x1e
    800026b4:	57890913          	addi	s2,s2,1400 # 80020c28 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026ba:	00007997          	auipc	s3,0x7
    800026be:	dee98993          	addi	s3,s3,-530 # 800094a8 <digits+0x468>
    printf("%d %s %s", p->pid, state, p->name);
    800026c2:	00007a97          	auipc	s5,0x7
    800026c6:	deea8a93          	addi	s5,s5,-530 # 800094b0 <digits+0x470>
    printf("\n");
    800026ca:	00007a17          	auipc	s4,0x7
    800026ce:	e9ea0a13          	addi	s4,s4,-354 # 80009568 <digits+0x528>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026d2:	00007b97          	auipc	s7,0x7
    800026d6:	0ceb8b93          	addi	s7,s7,206 # 800097a0 <states.0>
    800026da:	a00d                	j	800026fc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026dc:	ed86a583          	lw	a1,-296(a3)
    800026e0:	8556                	mv	a0,s5
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	e92080e7          	jalr	-366(ra) # 80000574 <printf>
    printf("\n");
    800026ea:	8552                	mv	a0,s4
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	e88080e7          	jalr	-376(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026f4:	39048493          	addi	s1,s1,912
    800026f8:	03248263          	beq	s1,s2,8000271c <procdump+0x9a>
    if (p->state == UNUSED)
    800026fc:	86a6                	mv	a3,s1
    800026fe:	ec04a783          	lw	a5,-320(s1)
    80002702:	dbed                	beqz	a5,800026f4 <procdump+0x72>
      state = "???";
    80002704:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002706:	fcfb6be3          	bltu	s6,a5,800026dc <procdump+0x5a>
    8000270a:	02079713          	slli	a4,a5,0x20
    8000270e:	01d75793          	srli	a5,a4,0x1d
    80002712:	97de                	add	a5,a5,s7
    80002714:	6390                	ld	a2,0(a5)
    80002716:	f279                	bnez	a2,800026dc <procdump+0x5a>
      state = "???";
    80002718:	864e                	mv	a2,s3
    8000271a:	b7c9                	j	800026dc <procdump+0x5a>
  }
}
    8000271c:	60a6                	ld	ra,72(sp)
    8000271e:	6406                	ld	s0,64(sp)
    80002720:	74e2                	ld	s1,56(sp)
    80002722:	7942                	ld	s2,48(sp)
    80002724:	79a2                	ld	s3,40(sp)
    80002726:	7a02                	ld	s4,32(sp)
    80002728:	6ae2                	ld	s5,24(sp)
    8000272a:	6b42                	ld	s6,16(sp)
    8000272c:	6ba2                	ld	s7,8(sp)
    8000272e:	6161                	addi	sp,sp,80
    80002730:	8082                	ret

0000000080002732 <get_next_free_space>:

// Next free space in swap file
int get_next_free_space(uint16 free_spaces)
{
    80002732:	1141                	addi	sp,sp,-16
    80002734:	e422                	sd	s0,8(sp)
    80002736:	0800                	addi	s0,sp,16
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (!(free_spaces & (1 << i)))
    80002738:	0005071b          	sext.w	a4,a0
    8000273c:	8905                	andi	a0,a0,1
    8000273e:	cd11                	beqz	a0,8000275a <get_next_free_space+0x28>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002740:	4505                	li	a0,1
    80002742:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002744:	40a757bb          	sraw	a5,a4,a0
    80002748:	8b85                	andi	a5,a5,1
    8000274a:	c789                	beqz	a5,80002754 <get_next_free_space+0x22>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000274c:	2505                	addiw	a0,a0,1
    8000274e:	fed51be3          	bne	a0,a3,80002744 <get_next_free_space+0x12>
      return i;
  }
  return -1;
    80002752:	557d                	li	a0,-1
}
    80002754:	6422                	ld	s0,8(sp)
    80002756:	0141                	addi	sp,sp,16
    80002758:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000275a:	4501                	li	a0,0
    8000275c:	bfe5                	j	80002754 <get_next_free_space+0x22>

000000008000275e <get_index_in_page_info_array>:

// Get file vm and return file entery inside swap file if exist
int get_index_in_page_info_array(uint64 va, struct page_info *arr)
{
    8000275e:	1141                	addi	sp,sp,-16
    80002760:	e422                	sd	s0,8(sp)
    80002762:	0800                	addi	s0,sp,16
  uint64 rva = PGROUNDDOWN(va);
    80002764:	777d                	lui	a4,0xfffff
    80002766:	8f69                	and	a4,a4,a0
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002768:	4501                	li	a0,0
    8000276a:	46c1                	li	a3,16
  {
    struct page_info *po = &arr[i];
    // printf("getPageIndex: in for loop: po->va = %p\n",po->va);
    if (po->va == rva)
    8000276c:	619c                	ld	a5,0(a1)
    8000276e:	00e78763          	beq	a5,a4,8000277c <get_index_in_page_info_array+0x1e>
  for (int i = 0; i < MAX_PSYC_PAGES;i++)
    80002772:	2505                	addiw	a0,a0,1
    80002774:	05c1                	addi	a1,a1,16
    80002776:	fed51be3          	bne	a0,a3,8000276c <get_index_in_page_info_array+0xe>
    {
      return i;
    }
  }
  return -1; // if not found return null
    8000277a:	557d                	li	a0,-1
}
    8000277c:	6422                	ld	s0,8(sp)
    8000277e:	0141                	addi	sp,sp,16
    80002780:	8082                	ret

0000000080002782 <page_out>:
//  free physical memory of page which virtual address va
//  write this page to procs swap file
//  return the new free physical address
uint64
page_out(uint64 va)
{
    80002782:	7179                	addi	sp,sp,-48
    80002784:	f406                	sd	ra,40(sp)
    80002786:	f022                	sd	s0,32(sp)
    80002788:	ec26                	sd	s1,24(sp)
    8000278a:	e84a                	sd	s2,16(sp)
    8000278c:	e44e                	sd	s3,8(sp)
    8000278e:	1800                	addi	s0,sp,48
    80002790:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002792:	fffff097          	auipc	ra,0xfffff
    80002796:	59e080e7          	jalr	1438(ra) # 80001d30 <myproc>
    8000279a:	84aa                	mv	s1,a0
  printf("1 %d\n",p->pid);
    8000279c:	590c                	lw	a1,48(a0)
    8000279e:	00007517          	auipc	a0,0x7
    800027a2:	d2250513          	addi	a0,a0,-734 # 800094c0 <digits+0x480>
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	dce080e7          	jalr	-562(ra) # 80000574 <printf>

  uint64 rva = PGROUNDDOWN(va);
    800027ae:	757d                	lui	a0,0xfffff
    800027b0:	00a97933          	and	s2,s2,a0

  // find the addres of the page which sent out
  uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0
    800027b4:	4605                	li	a2,1
    800027b6:	85ca                	mv	a1,s2
    800027b8:	68a8                	ld	a0,80(s1)
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	892080e7          	jalr	-1902(ra) # 8000104c <walkaddr>
    800027c2:	89aa                	mv	s3,a0

  // insert the page to the swap file
  
  int page_index = insert_page_to_swap_file(rva);
    800027c4:	854a                	mv	a0,s2
    800027c6:	fffff097          	auipc	ra,0xfffff
    800027ca:	da0080e7          	jalr	-608(ra) # 80001566 <insert_page_to_swap_file>
  int start_offset = page_index * PGSIZE;
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800027ce:	0005079b          	sext.w	a5,a0
    800027d2:	473d                	li	a4,15
    800027d4:	04f76c63          	bltu	a4,a5,8000282c <page_out+0xaa>
    800027d8:	00c5161b          	slliw	a2,a0,0xc
    panic("fadge no free index in page_out");
  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file
    800027dc:	6685                	lui	a3,0x1
    800027de:	2601                	sext.w	a2,a2
    800027e0:	85ce                	mv	a1,s3
    800027e2:	8526                	mv	a0,s1
    800027e4:	00002097          	auipc	ra,0x2
    800027e8:	468080e7          	jalr	1128(ra) # 80004c4c <writeToSwapFile>

  // Update the ram info struct
  remove_page_from_physical_memory(rva);
    800027ec:	854a                	mv	a0,s2
    800027ee:	fffff097          	auipc	ra,0xfffff
    800027f2:	e98080e7          	jalr	-360(ra) # 80001686 <remove_page_from_physical_memory>
  p->physical_pages_num--;
    800027f6:	1704a783          	lw	a5,368(s1)
    800027fa:	37fd                	addiw	a5,a5,-1
    800027fc:	16f4a823          	sw	a5,368(s1)
  
  // free space in physical memory
  kfree((void *)pa);
    80002800:	854e                	mv	a0,s3
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	1d4080e7          	jalr	468(ra) # 800009d6 <kfree>
  printf("end of pae out pid = %d\n",p->pid);
    8000280a:	588c                	lw	a1,48(s1)
    8000280c:	00007517          	auipc	a0,0x7
    80002810:	cdc50513          	addi	a0,a0,-804 # 800094e8 <digits+0x4a8>
    80002814:	ffffe097          	auipc	ra,0xffffe
    80002818:	d60080e7          	jalr	-672(ra) # 80000574 <printf>
  return pa;
}
    8000281c:	854e                	mv	a0,s3
    8000281e:	70a2                	ld	ra,40(sp)
    80002820:	7402                	ld	s0,32(sp)
    80002822:	64e2                	ld	s1,24(sp)
    80002824:	6942                	ld	s2,16(sp)
    80002826:	69a2                	ld	s3,8(sp)
    80002828:	6145                	addi	sp,sp,48
    8000282a:	8082                	ret
    panic("fadge no free index in page_out");
    8000282c:	00007517          	auipc	a0,0x7
    80002830:	c9c50513          	addi	a0,a0,-868 # 800094c8 <digits+0x488>
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	cf6080e7          	jalr	-778(ra) # 8000052a <panic>

000000008000283c <page_in>:

// move page from swap file to physical memory
pte_t *
page_in(uint64 va, pte_t *pte)
{
    8000283c:	7139                	addi	sp,sp,-64
    8000283e:	fc06                	sd	ra,56(sp)
    80002840:	f822                	sd	s0,48(sp)
    80002842:	f426                	sd	s1,40(sp)
    80002844:	f04a                	sd	s2,32(sp)
    80002846:	ec4e                	sd	s3,24(sp)
    80002848:	e852                	sd	s4,16(sp)
    8000284a:	e456                	sd	s5,8(sp)
    8000284c:	0080                	addi	s0,sp,64
    8000284e:	8aaa                	mv	s5,a0
    80002850:	84ae                	mv	s1,a1
  uint64 pa;
  struct proc *p = myproc();
    80002852:	fffff097          	auipc	ra,0xfffff
    80002856:	4de080e7          	jalr	1246(ra) # 80001d30 <myproc>
    8000285a:	892a                	mv	s2,a0
  uint64 rva = PGROUNDDOWN(va);
    8000285c:	79fd                	lui	s3,0xfffff
    8000285e:	013af9b3          	and	s3,s5,s3
  // update swap info
  int swap_old_index = remove_page_from_swap_file(rva);
    80002862:	854e                	mv	a0,s3
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	e8a080e7          	jalr	-374(ra) # 800016ee <remove_page_from_swap_file>
  if(swap_old_index <0)
    8000286c:	0c054c63          	bltz	a0,80002944 <page_in+0x108>
    80002870:	8a2a                	mv	s4,a0
    panic("page_in: index in swap file not found");

  // update physc info
  int physc_new_index = insert_page_to_physical_memory(rva);
    80002872:	854e                	mv	a0,s3
    80002874:	fffff097          	auipc	ra,0xfffff
    80002878:	d70080e7          	jalr	-656(ra) # 800015e4 <insert_page_to_physical_memory>
  p->physical_pages_num++;
    8000287c:	17092783          	lw	a5,368(s2)
    80002880:	2785                	addiw	a5,a5,1
    80002882:	16f92823          	sw	a5,368(s2)

  // alloc page in physical memory
  if ((pa = (uint64)kalloc()) == 0){
    80002886:	ffffe097          	auipc	ra,0xffffe
    8000288a:	24c080e7          	jalr	588(ra) # 80000ad2 <kalloc>
    8000288e:	89aa                	mv	s3,a0
    80002890:	c171                	beqz	a0,80002954 <page_in+0x118>
    printf("retrievingpage: kalloc failed\n");
    return -1;
  }
    printf("1.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    80002892:	608c                	ld	a1,0(s1)
    80002894:	0095d613          	srli	a2,a1,0x9
    80002898:	8a05                	andi	a2,a2,1
    8000289a:	8985                	andi	a1,a1,1
    8000289c:	00007517          	auipc	a0,0x7
    800028a0:	cb450513          	addi	a0,a0,-844 # 80009550 <digits+0x510>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	cd0080e7          	jalr	-816(ra) # 80000574 <printf>
  mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_FLAGS(*pte));
    800028ac:	6098                	ld	a4,0(s1)
    800028ae:	3ff77713          	andi	a4,a4,1023
    800028b2:	86ce                	mv	a3,s3
    800028b4:	6605                	lui	a2,0x1
    800028b6:	85d6                	mv	a1,s5
    800028b8:	05093503          	ld	a0,80(s2)
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	7e6080e7          	jalr	2022(ra) # 800010a2 <mappages>
    printf("2.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    800028c4:	608c                	ld	a1,0(s1)
    800028c6:	0095d613          	srli	a2,a1,0x9
    800028ca:	8a05                	andi	a2,a2,1
    800028cc:	8985                	andi	a1,a1,1
    800028ce:	00007517          	auipc	a0,0x7
    800028d2:	ca250513          	addi	a0,a0,-862 # 80009570 <digits+0x530>
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	c9e080e7          	jalr	-866(ra) # 80000574 <printf>

  // Write to swap file
  int start_offset = swap_old_index * PGSIZE;
  readFromSwapFile(p, (char*)pa, start_offset, PGSIZE);
    800028de:	6685                	lui	a3,0x1
    800028e0:	00ca161b          	slliw	a2,s4,0xc
    800028e4:	85ce                	mv	a1,s3
    800028e6:	854a                	mv	a0,s2
    800028e8:	00002097          	auipc	ra,0x2
    800028ec:	388080e7          	jalr	904(ra) # 80004c70 <readFromSwapFile>
    printf("3.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    800028f0:	608c                	ld	a1,0(s1)
    800028f2:	0095d613          	srli	a2,a1,0x9
    800028f6:	8a05                	andi	a2,a2,1
    800028f8:	8985                	andi	a1,a1,1
    800028fa:	00007517          	auipc	a0,0x7
    800028fe:	c9650513          	addi	a0,a0,-874 # 80009590 <digits+0x550>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c72080e7          	jalr	-910(ra) # 80000574 <printf>

  // update pte
  if (!(*pte & PTE_PG))
    8000290a:	609c                	ld	a5,0(s1)
    8000290c:	2007f713          	andi	a4,a5,512
    80002910:	cf21                	beqz	a4,80002968 <page_in+0x12c>
    panic("page in: page out flag was off");
  *pte = (*pte | PTE_V) &(~PTE_PG);
    80002912:	dfe7f793          	andi	a5,a5,-514
    80002916:	0017e793          	ori	a5,a5,1
    8000291a:	e09c                	sd	a5,0(s1)
  printf("3.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    8000291c:	4601                	li	a2,0
    8000291e:	4585                	li	a1,1
    80002920:	00007517          	auipc	a0,0x7
    80002924:	c7050513          	addi	a0,a0,-912 # 80009590 <digits+0x550>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	c4c080e7          	jalr	-948(ra) # 80000574 <printf>


  return pte;
    80002930:	8526                	mv	a0,s1
}
    80002932:	70e2                	ld	ra,56(sp)
    80002934:	7442                	ld	s0,48(sp)
    80002936:	74a2                	ld	s1,40(sp)
    80002938:	7902                	ld	s2,32(sp)
    8000293a:	69e2                	ld	s3,24(sp)
    8000293c:	6a42                	ld	s4,16(sp)
    8000293e:	6aa2                	ld	s5,8(sp)
    80002940:	6121                	addi	sp,sp,64
    80002942:	8082                	ret
    panic("page_in: index in swap file not found");
    80002944:	00007517          	auipc	a0,0x7
    80002948:	bc450513          	addi	a0,a0,-1084 # 80009508 <digits+0x4c8>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	bde080e7          	jalr	-1058(ra) # 8000052a <panic>
    printf("retrievingpage: kalloc failed\n");
    80002954:	00007517          	auipc	a0,0x7
    80002958:	bdc50513          	addi	a0,a0,-1060 # 80009530 <digits+0x4f0>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	c18080e7          	jalr	-1000(ra) # 80000574 <printf>
    return -1;
    80002964:	557d                	li	a0,-1
    80002966:	b7f1                	j	80002932 <page_in+0xf6>
    panic("page in: page out flag was off");
    80002968:	00007517          	auipc	a0,0x7
    8000296c:	c4850513          	addi	a0,a0,-952 # 800095b0 <digits+0x570>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	bba080e7          	jalr	-1094(ra) # 8000052a <panic>

0000000080002978 <copyFilesInfo>:

void copyFilesInfo(struct proc *p, struct proc *np)
{
    80002978:	7139                	addi	sp,sp,-64
    8000297a:	fc06                	sd	ra,56(sp)
    8000297c:	f822                	sd	s0,48(sp)
    8000297e:	f426                	sd	s1,40(sp)
    80002980:	f04a                	sd	s2,32(sp)
    80002982:	ec4e                	sd	s3,24(sp)
    80002984:	e852                	sd	s4,16(sp)
    80002986:	e456                	sd	s5,8(sp)
    80002988:	e05a                	sd	s6,0(sp)
    8000298a:	0080                	addi	s0,sp,64
    8000298c:	89aa                	mv	s3,a0
    8000298e:	84ae                	mv	s1,a1
  // Copy swapfile
  void *temp_page;

  if (!(temp_page = kalloc()))
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	142080e7          	jalr	322(ra) # 80000ad2 <kalloc>
    80002998:	8b2a                	mv	s6,a0
    panic("copyFilesInfo: kalloc failed");

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000299a:	4901                	li	s2,0
    8000299c:	4a41                	li	s4,16
  if (!(temp_page = kalloc()))
    8000299e:	e505                	bnez	a0,800029c6 <copyFilesInfo+0x4e>
    panic("copyFilesInfo: kalloc failed");
    800029a0:	00007517          	auipc	a0,0x7
    800029a4:	c3050513          	addi	a0,a0,-976 # 800095d0 <digits+0x590>
    800029a8:	ffffe097          	auipc	ra,0xffffe
    800029ac:	b82080e7          	jalr	-1150(ra) # 8000052a <panic>
    if (p->pages_swap_info.free_spaces & (1 << i))
    {
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);

      if (res < 0)
        panic("copyFilesInfo: failed read");
    800029b0:	00007517          	auipc	a0,0x7
    800029b4:	c4050513          	addi	a0,a0,-960 # 800095f0 <digits+0x5b0>
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	b72080e7          	jalr	-1166(ra) # 8000052a <panic>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800029c0:	2905                	addiw	s2,s2,1
    800029c2:	05490663          	beq	s2,s4,80002a0e <copyFilesInfo+0x96>
    if (p->pages_swap_info.free_spaces & (1 << i))
    800029c6:	1789d783          	lhu	a5,376(s3) # fffffffffffff178 <end+0xffffffff7ffd0178>
    800029ca:	4127d7bb          	sraw	a5,a5,s2
    800029ce:	8b85                	andi	a5,a5,1
    800029d0:	dbe5                	beqz	a5,800029c0 <copyFilesInfo+0x48>
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    800029d2:	00c91a9b          	slliw	s5,s2,0xc
    800029d6:	6685                	lui	a3,0x1
    800029d8:	8656                	mv	a2,s5
    800029da:	85da                	mv	a1,s6
    800029dc:	854e                	mv	a0,s3
    800029de:	00002097          	auipc	ra,0x2
    800029e2:	292080e7          	jalr	658(ra) # 80004c70 <readFromSwapFile>
      if (res < 0)
    800029e6:	fc0545e3          	bltz	a0,800029b0 <copyFilesInfo+0x38>

      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    800029ea:	6685                	lui	a3,0x1
    800029ec:	8656                	mv	a2,s5
    800029ee:	85da                	mv	a1,s6
    800029f0:	8526                	mv	a0,s1
    800029f2:	00002097          	auipc	ra,0x2
    800029f6:	25a080e7          	jalr	602(ra) # 80004c4c <writeToSwapFile>

      if (res < 0)
    800029fa:	fc0553e3          	bgez	a0,800029c0 <copyFilesInfo+0x48>
        panic("copyFilesInfo: faild write ");
    800029fe:	00007517          	auipc	a0,0x7
    80002a02:	c1250513          	addi	a0,a0,-1006 # 80009610 <digits+0x5d0>
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	b24080e7          	jalr	-1244(ra) # 8000052a <panic>
    }
  }

  kfree(temp_page);
    80002a0e:	855a                	mv	a0,s6
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	fc6080e7          	jalr	-58(ra) # 800009d6 <kfree>

  // Copy swap and ram structs
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
    80002a18:	1789d783          	lhu	a5,376(s3)
    80002a1c:	16f49c23          	sh	a5,376(s1)
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;
    80002a20:	2809d783          	lhu	a5,640(s3)
    80002a24:	28f49023          	sh	a5,640(s1)

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002a28:	18098793          	addi	a5,s3,384
    80002a2c:	18048593          	addi	a1,s1,384
    80002a30:	28098993          	addi	s3,s3,640
  {
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    80002a34:	6398                	ld	a4,0(a5)
    80002a36:	e198                	sd	a4,0(a1)
    80002a38:	6798                	ld	a4,8(a5)
    80002a3a:	e598                	sd	a4,8(a1)
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
    80002a3c:	1087b703          	ld	a4,264(a5)
    80002a40:	10e5b423          	sd	a4,264(a1)
    80002a44:	1107b703          	ld	a4,272(a5)
    80002a48:	10e5b823          	sd	a4,272(a1)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002a4c:	07c1                	addi	a5,a5,16
    80002a4e:	05c1                	addi	a1,a1,16
    80002a50:	ff3792e3          	bne	a5,s3,80002a34 <copyFilesInfo+0xbc>
  }

}
    80002a54:	70e2                	ld	ra,56(sp)
    80002a56:	7442                	ld	s0,48(sp)
    80002a58:	74a2                	ld	s1,40(sp)
    80002a5a:	7902                	ld	s2,32(sp)
    80002a5c:	69e2                	ld	s3,24(sp)
    80002a5e:	6a42                	ld	s4,16(sp)
    80002a60:	6aa2                	ld	s5,8(sp)
    80002a62:	6b02                	ld	s6,0(sp)
    80002a64:	6121                	addi	sp,sp,64
    80002a66:	8082                	ret

0000000080002a68 <fork>:
{
    80002a68:	7139                	addi	sp,sp,-64
    80002a6a:	fc06                	sd	ra,56(sp)
    80002a6c:	f822                	sd	s0,48(sp)
    80002a6e:	f426                	sd	s1,40(sp)
    80002a70:	f04a                	sd	s2,32(sp)
    80002a72:	ec4e                	sd	s3,24(sp)
    80002a74:	e852                	sd	s4,16(sp)
    80002a76:	e456                	sd	s5,8(sp)
    80002a78:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002a7a:	fffff097          	auipc	ra,0xfffff
    80002a7e:	2b6080e7          	jalr	694(ra) # 80001d30 <myproc>
    80002a82:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80002a84:	fffff097          	auipc	ra,0xfffff
    80002a88:	4ba080e7          	jalr	1210(ra) # 80001f3e <allocproc>
    80002a8c:	12050f63          	beqz	a0,80002bca <fork+0x162>
    80002a90:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002a92:	048ab603          	ld	a2,72(s5)
    80002a96:	692c                	ld	a1,80(a0)
    80002a98:	050ab503          	ld	a0,80(s5)
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	02a080e7          	jalr	42(ra) # 80001ac6 <uvmcopy>
    80002aa4:	04054863          	bltz	a0,80002af4 <fork+0x8c>
  np->sz = p->sz;
    80002aa8:	048ab783          	ld	a5,72(s5)
    80002aac:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002ab0:	058ab683          	ld	a3,88(s5)
    80002ab4:	87b6                	mv	a5,a3
    80002ab6:	0589b703          	ld	a4,88(s3)
    80002aba:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002abe:	0007b803          	ld	a6,0(a5)
    80002ac2:	6788                	ld	a0,8(a5)
    80002ac4:	6b8c                	ld	a1,16(a5)
    80002ac6:	6f90                	ld	a2,24(a5)
    80002ac8:	01073023          	sd	a6,0(a4) # fffffffffffff000 <end+0xffffffff7ffd0000>
    80002acc:	e708                	sd	a0,8(a4)
    80002ace:	eb0c                	sd	a1,16(a4)
    80002ad0:	ef10                	sd	a2,24(a4)
    80002ad2:	02078793          	addi	a5,a5,32
    80002ad6:	02070713          	addi	a4,a4,32
    80002ada:	fed792e3          	bne	a5,a3,80002abe <fork+0x56>
  np->trapframe->a0 = 0;
    80002ade:	0589b783          	ld	a5,88(s3)
    80002ae2:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002ae6:	0d0a8493          	addi	s1,s5,208
    80002aea:	0d098913          	addi	s2,s3,208
    80002aee:	150a8a13          	addi	s4,s5,336
    80002af2:	a00d                	j	80002b14 <fork+0xac>
    freeproc(np);
    80002af4:	854e                	mv	a0,s3
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	3ec080e7          	jalr	1004(ra) # 80001ee2 <freeproc>
    release(&np->lock);
    80002afe:	854e                	mv	a0,s3
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	176080e7          	jalr	374(ra) # 80000c76 <release>
    return -1;
    80002b08:	597d                	li	s2,-1
    80002b0a:	a075                	j	80002bb6 <fork+0x14e>
  for (i = 0; i < NOFILE; i++)
    80002b0c:	04a1                	addi	s1,s1,8
    80002b0e:	0921                	addi	s2,s2,8
    80002b10:	01448b63          	beq	s1,s4,80002b26 <fork+0xbe>
    if (p->ofile[i])
    80002b14:	6088                	ld	a0,0(s1)
    80002b16:	d97d                	beqz	a0,80002b0c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80002b18:	00002097          	auipc	ra,0x2
    80002b1c:	7dc080e7          	jalr	2012(ra) # 800052f4 <filedup>
    80002b20:	00a93023          	sd	a0,0(s2)
    80002b24:	b7e5                	j	80002b0c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80002b26:	150ab503          	ld	a0,336(s5)
    80002b2a:	00001097          	auipc	ra,0x1
    80002b2e:	61a080e7          	jalr	1562(ra) # 80004144 <idup>
    80002b32:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002b36:	4641                	li	a2,16
    80002b38:	158a8593          	addi	a1,s5,344
    80002b3c:	15898513          	addi	a0,s3,344
    80002b40:	ffffe097          	auipc	ra,0xffffe
    80002b44:	2d0080e7          	jalr	720(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80002b48:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002b4c:	854e                	mv	a0,s3
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	128080e7          	jalr	296(ra) # 80000c76 <release>
  createSwapFile(np);
    80002b56:	854e                	mv	a0,s3
    80002b58:	00002097          	auipc	ra,0x2
    80002b5c:	044080e7          	jalr	68(ra) # 80004b9c <createSwapFile>
  copyFilesInfo(p, np); // TODO: check we need to this for father 1,2 
    80002b60:	85ce                	mv	a1,s3
    80002b62:	8556                	mv	a0,s5
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	e14080e7          	jalr	-492(ra) # 80002978 <copyFilesInfo>
  np->physical_pages_num = p->physical_pages_num;
    80002b6c:	170aa783          	lw	a5,368(s5)
    80002b70:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    80002b74:	174aa783          	lw	a5,372(s5)
    80002b78:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002b7c:	0000f497          	auipc	s1,0xf
    80002b80:	73c48493          	addi	s1,s1,1852 # 800122b8 <wait_lock>
    80002b84:	8526                	mv	a0,s1
    80002b86:	ffffe097          	auipc	ra,0xffffe
    80002b8a:	03c080e7          	jalr	60(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002b8e:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002b92:	8526                	mv	a0,s1
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	0e2080e7          	jalr	226(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002b9c:	854e                	mv	a0,s3
    80002b9e:	ffffe097          	auipc	ra,0xffffe
    80002ba2:	024080e7          	jalr	36(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80002ba6:	478d                	li	a5,3
    80002ba8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002bac:	854e                	mv	a0,s3
    80002bae:	ffffe097          	auipc	ra,0xffffe
    80002bb2:	0c8080e7          	jalr	200(ra) # 80000c76 <release>
}
    80002bb6:	854a                	mv	a0,s2
    80002bb8:	70e2                	ld	ra,56(sp)
    80002bba:	7442                	ld	s0,48(sp)
    80002bbc:	74a2                	ld	s1,40(sp)
    80002bbe:	7902                	ld	s2,32(sp)
    80002bc0:	69e2                	ld	s3,24(sp)
    80002bc2:	6a42                	ld	s4,16(sp)
    80002bc4:	6aa2                	ld	s5,8(sp)
    80002bc6:	6121                	addi	sp,sp,64
    80002bc8:	8082                	ret
    return -1;
    80002bca:	597d                	li	s2,-1
    80002bcc:	b7ed                	j	80002bb6 <fork+0x14e>

0000000080002bce <NFUA_compare>:
  return selected_pg_index;
}

int NFUA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002bce:	c511                	beqz	a0,80002bda <NFUA_compare+0xc>
    80002bd0:	c589                	beqz	a1,80002bda <NFUA_compare+0xc>
    panic("NFUA_compare : null input");

  return pg1->aging_counter - pg2->aging_counter;
    80002bd2:	4508                	lw	a0,8(a0)
    80002bd4:	459c                	lw	a5,8(a1)
}
    80002bd6:	9d1d                	subw	a0,a0,a5
    80002bd8:	8082                	ret
{
    80002bda:	1141                	addi	sp,sp,-16
    80002bdc:	e406                	sd	ra,8(sp)
    80002bde:	e022                	sd	s0,0(sp)
    80002be0:	0800                	addi	s0,sp,16
    panic("NFUA_compare : null input");
    80002be2:	00007517          	auipc	a0,0x7
    80002be6:	a4e50513          	addi	a0,a0,-1458 # 80009630 <digits+0x5f0>
    80002bea:	ffffe097          	auipc	ra,0xffffe
    80002bee:	940080e7          	jalr	-1728(ra) # 8000052a <panic>

0000000080002bf2 <SCFIFO_compare>:
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    80002bf2:	c511                	beqz	a0,80002bfe <SCFIFO_compare+0xc>
    80002bf4:	c589                	beqz	a1,80002bfe <SCFIFO_compare+0xc>
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
    80002bf6:	4548                	lw	a0,12(a0)
    80002bf8:	45dc                	lw	a5,12(a1)
}
    80002bfa:	9d1d                	subw	a0,a0,a5
    80002bfc:	8082                	ret
{
    80002bfe:	1141                	addi	sp,sp,-16
    80002c00:	e406                	sd	ra,8(sp)
    80002c02:	e022                	sd	s0,0(sp)
    80002c04:	0800                	addi	s0,sp,16
    panic("SCFIFO_compare : null input");
    80002c06:	00007517          	auipc	a0,0x7
    80002c0a:	a4a50513          	addi	a0,a0,-1462 # 80009650 <digits+0x610>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080002c16 <countOnes>:

int countOnes(uint n)
{
    80002c16:	1141                	addi	sp,sp,-16
    80002c18:	e422                	sd	s0,8(sp)
    80002c1a:	0800                	addi	s0,sp,16
  int count = 0;
  while (n)
    80002c1c:	cd01                	beqz	a0,80002c34 <countOnes+0x1e>
    80002c1e:	87aa                	mv	a5,a0
  int count = 0;
    80002c20:	4501                	li	a0,0
  {
    count += n & 1;
    80002c22:	0017f713          	andi	a4,a5,1
    80002c26:	9d39                	addw	a0,a0,a4
    n >>= 1;
    80002c28:	0017d79b          	srliw	a5,a5,0x1
  while (n)
    80002c2c:	fbfd                	bnez	a5,80002c22 <countOnes+0xc>
  }
  return count;
}
    80002c2e:	6422                	ld	s0,8(sp)
    80002c30:	0141                	addi	sp,sp,16
    80002c32:	8082                	ret
  int count = 0;
    80002c34:	4501                	li	a0,0
    80002c36:	bfe5                	j	80002c2e <countOnes+0x18>

0000000080002c38 <LAPA_compare>:
{
    80002c38:	7179                	addi	sp,sp,-48
    80002c3a:	f406                	sd	ra,40(sp)
    80002c3c:	f022                	sd	s0,32(sp)
    80002c3e:	ec26                	sd	s1,24(sp)
    80002c40:	e84a                	sd	s2,16(sp)
    80002c42:	e44e                	sd	s3,8(sp)
    80002c44:	1800                	addi	s0,sp,48
  if (!pg1 || !pg2)
    80002c46:	cd05                	beqz	a0,80002c7e <LAPA_compare+0x46>
    80002c48:	892e                	mv	s2,a1
    80002c4a:	c995                	beqz	a1,80002c7e <LAPA_compare+0x46>
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);
    80002c4c:	00852983          	lw	s3,8(a0)
    80002c50:	854e                	mv	a0,s3
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	fc4080e7          	jalr	-60(ra) # 80002c16 <countOnes>
    80002c5a:	84aa                	mv	s1,a0
    80002c5c:	00892903          	lw	s2,8(s2)
    80002c60:	854a                	mv	a0,s2
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	fb4080e7          	jalr	-76(ra) # 80002c16 <countOnes>
    80002c6a:	40a4853b          	subw	a0,s1,a0
  if (res == 0)
    80002c6e:	c105                	beqz	a0,80002c8e <LAPA_compare+0x56>
}
    80002c70:	70a2                	ld	ra,40(sp)
    80002c72:	7402                	ld	s0,32(sp)
    80002c74:	64e2                	ld	s1,24(sp)
    80002c76:	6942                	ld	s2,16(sp)
    80002c78:	69a2                	ld	s3,8(sp)
    80002c7a:	6145                	addi	sp,sp,48
    80002c7c:	8082                	ret
    panic("LAPA_compare : null input");
    80002c7e:	00007517          	auipc	a0,0x7
    80002c82:	9f250513          	addi	a0,a0,-1550 # 80009670 <digits+0x630>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	8a4080e7          	jalr	-1884(ra) # 8000052a <panic>
    return pg1->aging_counter - pg2->aging_counter;
    80002c8e:	4129853b          	subw	a0,s3,s2
    80002c92:	bff9                	j	80002c70 <LAPA_compare+0x38>

0000000080002c94 <is_accessed>:
{
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
}

int is_accessed(struct page_info *pg, int to_reset)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	e04a                	sd	s2,0(sp)
    80002c9e:	1000                	addi	s0,sp,32
    80002ca0:	84aa                	mv	s1,a0
    80002ca2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	08c080e7          	jalr	140(ra) # 80001d30 <myproc>
  pte_t *pte = walk(p->pagetable, pg->va, 0);
    80002cac:	4601                	li	a2,0
    80002cae:	608c                	ld	a1,0(s1)
    80002cb0:	6928                	ld	a0,80(a0)
    80002cb2:	ffffe097          	auipc	ra,0xffffe
    80002cb6:	2f4080e7          	jalr	756(ra) # 80000fa6 <walk>
    80002cba:	87aa                	mv	a5,a0
  int accessed = (*pte & PTE_A);
    80002cbc:	6118                	ld	a4,0(a0)
    80002cbe:	04077513          	andi	a0,a4,64
  if (accessed && to_reset)
    80002cc2:	c511                	beqz	a0,80002cce <is_accessed+0x3a>
    80002cc4:	00090563          	beqz	s2,80002cce <is_accessed+0x3a>
    *pte ^= PTE_A; // reset accessed flag
    80002cc8:	04074713          	xori	a4,a4,64
    80002ccc:	e398                	sd	a4,0(a5)

  return accessed;
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6902                	ld	s2,0(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret

0000000080002cda <update_NFUA_LAPA_counter>:
{
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	e426                	sd	s1,8(sp)
    80002ce2:	e04a                	sd	s2,0(sp)
    80002ce4:	1000                	addi	s0,sp,32
    80002ce6:	84aa                	mv	s1,a0
  pg->aging_counter = (pg->aging_counter >> 1) | (is_accessed(pg, 1) << 31);
    80002ce8:	451c                	lw	a5,8(a0)
    80002cea:	0017d91b          	srliw	s2,a5,0x1
    80002cee:	4585                	li	a1,1
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	fa4080e7          	jalr	-92(ra) # 80002c94 <is_accessed>
    80002cf8:	01f5179b          	slliw	a5,a0,0x1f
    80002cfc:	0127e7b3          	or	a5,a5,s2
    80002d00:	c49c                	sw	a5,8(s1)
}
    80002d02:	60e2                	ld	ra,24(sp)
    80002d04:	6442                	ld	s0,16(sp)
    80002d06:	64a2                	ld	s1,8(sp)
    80002d08:	6902                	ld	s2,0(sp)
    80002d0a:	6105                	addi	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <update_pages_info>:
{
    80002d0e:	1101                	addi	sp,sp,-32
    80002d10:	ec06                	sd	ra,24(sp)
    80002d12:	e822                	sd	s0,16(sp)
    80002d14:	e426                	sd	s1,8(sp)
    80002d16:	e04a                	sd	s2,0(sp)
    80002d18:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002d1a:	fffff097          	auipc	ra,0xfffff
    80002d1e:	016080e7          	jalr	22(ra) # 80001d30 <myproc>
  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002d22:	28850493          	addi	s1,a0,648
    80002d26:	39850913          	addi	s2,a0,920
    update_NFUA_LAPA_counter(pg);
    80002d2a:	8526                	mv	a0,s1
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	fae080e7          	jalr	-82(ra) # 80002cda <update_NFUA_LAPA_counter>
  for (pg = p->pages_physc_info.pages; pg <= &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
    80002d34:	04c1                	addi	s1,s1,16
    80002d36:	fe991ae3          	bne	s2,s1,80002d2a <update_pages_info+0x1c>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6902                	ld	s2,0(sp)
    80002d42:	6105                	addi	sp,sp,32
    80002d44:	8082                	ret

0000000080002d46 <scheduler>:
{
    80002d46:	715d                	addi	sp,sp,-80
    80002d48:	e486                	sd	ra,72(sp)
    80002d4a:	e0a2                	sd	s0,64(sp)
    80002d4c:	fc26                	sd	s1,56(sp)
    80002d4e:	f84a                	sd	s2,48(sp)
    80002d50:	f44e                	sd	s3,40(sp)
    80002d52:	f052                	sd	s4,32(sp)
    80002d54:	ec56                	sd	s5,24(sp)
    80002d56:	e85a                	sd	s6,16(sp)
    80002d58:	e45e                	sd	s7,8(sp)
    80002d5a:	0880                	addi	s0,sp,80
    80002d5c:	8792                	mv	a5,tp
  int id = r_tp();
    80002d5e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002d60:	00779b13          	slli	s6,a5,0x7
    80002d64:	0000f717          	auipc	a4,0xf
    80002d68:	53c70713          	addi	a4,a4,1340 # 800122a0 <pid_lock>
    80002d6c:	975a                	add	a4,a4,s6
    80002d6e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002d72:	0000f717          	auipc	a4,0xf
    80002d76:	56670713          	addi	a4,a4,1382 # 800122d8 <cpus+0x8>
    80002d7a:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80002d7c:	498d                	li	s3,3
        p->state = RUNNING;
    80002d7e:	4b91                	li	s7,4
        c->proc = p;
    80002d80:	079e                	slli	a5,a5,0x7
    80002d82:	0000fa17          	auipc	s4,0xf
    80002d86:	51ea0a13          	addi	s4,s4,1310 # 800122a0 <pid_lock>
    80002d8a:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80002d8c:	0001e917          	auipc	s2,0x1e
    80002d90:	d4490913          	addi	s2,s2,-700 # 80020ad0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d98:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d9c:	10079073          	csrw	sstatus,a5
    80002da0:	00010497          	auipc	s1,0x10
    80002da4:	93048493          	addi	s1,s1,-1744 # 800126d0 <proc>
        if(p->pid>2){
    80002da8:	4a89                	li	s5,2
    80002daa:	a821                	j	80002dc2 <scheduler+0x7c>
        c->proc = 0;
    80002dac:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80002db0:	8526                	mv	a0,s1
    80002db2:	ffffe097          	auipc	ra,0xffffe
    80002db6:	ec4080e7          	jalr	-316(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002dba:	39048493          	addi	s1,s1,912
    80002dbe:	fd248be3          	beq	s1,s2,80002d94 <scheduler+0x4e>
      acquire(&p->lock);
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	ffffe097          	auipc	ra,0xffffe
    80002dc8:	dfe080e7          	jalr	-514(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80002dcc:	4c9c                	lw	a5,24(s1)
    80002dce:	ff3791e3          	bne	a5,s3,80002db0 <scheduler+0x6a>
        p->state = RUNNING;
    80002dd2:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002dd6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002dda:	06048593          	addi	a1,s1,96
    80002dde:	855a                	mv	a0,s6
    80002de0:	00000097          	auipc	ra,0x0
    80002de4:	1c0080e7          	jalr	448(ra) # 80002fa0 <swtch>
        if(p->pid>2){
    80002de8:	589c                	lw	a5,48(s1)
    80002dea:	fcfad1e3          	bge	s5,a5,80002dac <scheduler+0x66>
          update_pages_info();
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	f20080e7          	jalr	-224(ra) # 80002d0e <update_pages_info>
    80002df6:	bf5d                	j	80002dac <scheduler+0x66>

0000000080002df8 <reset_aging_counter>:
void reset_aging_counter(struct page_info *pg)
{
    80002df8:	1141                	addi	sp,sp,-16
    80002dfa:	e422                	sd	s0,8(sp)
    80002dfc:	0800                	addi	s0,sp,16
  #ifdef NFUA
    pg->aging_counter = 0;
  #elif LAPA
    pg->aging_counter = ~0;
    80002dfe:	57fd                	li	a5,-1
    80002e00:	c51c                	sw	a5,8(a0)
  #endif
}
    80002e02:	6422                	ld	s0,8(sp)
    80002e04:	0141                	addi	sp,sp,16
    80002e06:	8082                	ret

0000000080002e08 <print_pages_from_info_arrs>:

void print_pages_from_info_arrs(){
    80002e08:	7139                	addi	sp,sp,-64
    80002e0a:	fc06                	sd	ra,56(sp)
    80002e0c:	f822                	sd	s0,48(sp)
    80002e0e:	f426                	sd	s1,40(sp)
    80002e10:	f04a                	sd	s2,32(sp)
    80002e12:	ec4e                	sd	s3,24(sp)
    80002e14:	e852                	sd	s4,16(sp)
    80002e16:	e456                	sd	s5,8(sp)
    80002e18:	e05a                	sd	s6,0(sp)
    80002e1a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	f14080e7          	jalr	-236(ra) # 80001d30 <myproc>
    80002e24:	89aa                	mv	s3,a0
  printf("\n physic pages \t\t\tswap file::\n");
    80002e26:	00007517          	auipc	a0,0x7
    80002e2a:	86a50513          	addi	a0,a0,-1942 # 80009690 <digits+0x650>
    80002e2e:	ffffd097          	auipc	ra,0xffffd
    80002e32:	746080e7          	jalr	1862(ra) # 80000574 <printf>

  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e36:	18098493          	addi	s1,s3,384
    80002e3a:	4901                	li	s2,0
    printf("(%p , %d ,\t %p)\t\t(%p , %d)  \n ", p->pages_physc_info.pages[i].va, (p->pages_physc_info.free_spaces & (1 << i))>0,p->pages_physc_info.pages[i].aging_counter,
    80002e3c:	4b05                	li	s6,1
    80002e3e:	00007a97          	auipc	s5,0x7
    80002e42:	872a8a93          	addi	s5,s5,-1934 # 800096b0 <digits+0x670>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e46:	4a41                	li	s4,16
    printf("(%p , %d ,\t %p)\t\t(%p , %d)  \n ", p->pages_physc_info.pages[i].va, (p->pages_physc_info.free_spaces & (1 << i))>0,p->pages_physc_info.pages[i].aging_counter,
    80002e48:	012b17bb          	sllw	a5,s6,s2
    80002e4c:	1789d703          	lhu	a4,376(s3)
    80002e50:	2809d603          	lhu	a2,640(s3)
    80002e54:	8e7d                	and	a2,a2,a5
    80002e56:	8ff9                	and	a5,a5,a4
    80002e58:	6098                	ld	a4,0(s1)
    80002e5a:	1104a683          	lw	a3,272(s1)
    80002e5e:	00c03633          	snez	a2,a2
    80002e62:	1084b583          	ld	a1,264(s1)
    80002e66:	8556                	mv	a0,s5
    80002e68:	ffffd097          	auipc	ra,0xffffd
    80002e6c:	70c080e7          	jalr	1804(ra) # 80000574 <printf>
  for (int i = 0; i < MAX_PSYC_PAGES; i++){
    80002e70:	2905                	addiw	s2,s2,1
    80002e72:	04c1                	addi	s1,s1,16
    80002e74:	fd491ae3          	bne	s2,s4,80002e48 <print_pages_from_info_arrs+0x40>
  }

  // printf("\n swap file:\n");
  // for(int i=0;i<MAX_PSYC_PAGES;i++)
  //   printf("(%p , %d)\n ",p->pages_swap_info.pages[i].va,p->pages_swap_info.free_spaces&(1<<i));
    80002e78:	70e2                	ld	ra,56(sp)
    80002e7a:	7442                	ld	s0,48(sp)
    80002e7c:	74a2                	ld	s1,40(sp)
    80002e7e:	7902                	ld	s2,32(sp)
    80002e80:	69e2                	ld	s3,24(sp)
    80002e82:	6a42                	ld	s4,16(sp)
    80002e84:	6aa2                	ld	s5,8(sp)
    80002e86:	6b02                	ld	s6,0(sp)
    80002e88:	6121                	addi	sp,sp,64
    80002e8a:	8082                	ret

0000000080002e8c <compare_all_pages>:
{
    80002e8c:	711d                	addi	sp,sp,-96
    80002e8e:	ec86                	sd	ra,88(sp)
    80002e90:	e8a2                	sd	s0,80(sp)
    80002e92:	e4a6                	sd	s1,72(sp)
    80002e94:	e0ca                	sd	s2,64(sp)
    80002e96:	fc4e                	sd	s3,56(sp)
    80002e98:	f852                	sd	s4,48(sp)
    80002e9a:	f456                	sd	s5,40(sp)
    80002e9c:	f05a                	sd	s6,32(sp)
    80002e9e:	ec5e                	sd	s7,24(sp)
    80002ea0:	e862                	sd	s8,16(sp)
    80002ea2:	e466                	sd	s9,8(sp)
    80002ea4:	1080                	addi	s0,sp,96
    80002ea6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	e88080e7          	jalr	-376(ra) # 80001d30 <myproc>
    80002eb0:	89aa                	mv	s3,a0
  printf("compare all pages:\n");
    80002eb2:	00007517          	auipc	a0,0x7
    80002eb6:	81e50513          	addi	a0,a0,-2018 # 800096d0 <digits+0x690>
    80002eba:	ffffd097          	auipc	ra,0xffffd
    80002ebe:	6ba080e7          	jalr	1722(ra) # 80000574 <printf>
  printf("1.page 0 has aging counter = %p\n",&p->pages_physc_info.pages[0].aging_counter);
    80002ec2:	29098493          	addi	s1,s3,656
    80002ec6:	85a6                	mv	a1,s1
    80002ec8:	00007517          	auipc	a0,0x7
    80002ecc:	82050513          	addi	a0,a0,-2016 # 800096e8 <digits+0x6a8>
    80002ed0:	ffffd097          	auipc	ra,0xffffd
    80002ed4:	6a4080e7          	jalr	1700(ra) # 80000574 <printf>
  print_pages_from_info_arrs();
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	f30080e7          	jalr	-208(ra) # 80002e08 <print_pages_from_info_arrs>
  printf("2.page 0 has aging counter = %p\n",&p->pages_physc_info.pages[0].aging_counter);
    80002ee0:	85a6                	mv	a1,s1
    80002ee2:	00007517          	auipc	a0,0x7
    80002ee6:	82e50513          	addi	a0,a0,-2002 # 80009710 <digits+0x6d0>
    80002eea:	ffffd097          	auipc	ra,0xffffd
    80002eee:	68a080e7          	jalr	1674(ra) # 80000574 <printf>
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002ef2:	28898913          	addi	s2,s3,648
    80002ef6:	4481                	li	s1,0
  int min_index = -1;
    80002ef8:	5bfd                	li	s7,-1
  struct page_info *pg_to_swap = 0;
    80002efa:	4a01                	li	s4,0
      printf("page %d has aging counter = %p\n",i,pg->aging_counter);
    80002efc:	00007c17          	auipc	s8,0x7
    80002f00:	83cc0c13          	addi	s8,s8,-1988 # 80009738 <digits+0x6f8>
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002f04:	4ac1                	li	s5,16
    80002f06:	a839                	j	80002f24 <compare_all_pages+0x98>
      printf("page %d has aging counter = %p\n",i,pg->aging_counter);
    80002f08:	008ca603          	lw	a2,8(s9)
    80002f0c:	85a6                	mv	a1,s1
    80002f0e:	8562                	mv	a0,s8
    80002f10:	ffffd097          	auipc	ra,0xffffd
    80002f14:	664080e7          	jalr	1636(ra) # 80000574 <printf>
    80002f18:	8ba6                	mv	s7,s1
      pg_to_swap = pg;
    80002f1a:	8a66                	mv	s4,s9
  for (int i=0;i<MAX_PSYC_PAGES;i++)
    80002f1c:	2485                	addiw	s1,s1,1
    80002f1e:	0941                	addi	s2,s2,16
    80002f20:	03548163          	beq	s1,s5,80002f42 <compare_all_pages+0xb6>
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002f24:	2809d783          	lhu	a5,640(s3)
    80002f28:	4097d7bb          	sraw	a5,a5,s1
    80002f2c:	8b85                	andi	a5,a5,1
    80002f2e:	d7fd                	beqz	a5,80002f1c <compare_all_pages+0x90>
    struct page_info *pg = &p->pages_physc_info.pages[i];
    80002f30:	8cca                	mv	s9,s2
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    80002f32:	fc0a0be3          	beqz	s4,80002f08 <compare_all_pages+0x7c>
    80002f36:	85d2                	mv	a1,s4
    80002f38:	854a                	mv	a0,s2
    80002f3a:	9b02                	jalr	s6
    80002f3c:	fe0550e3          	bgez	a0,80002f1c <compare_all_pages+0x90>
    80002f40:	b7e1                	j	80002f08 <compare_all_pages+0x7c>
}
    80002f42:	855e                	mv	a0,s7
    80002f44:	60e6                	ld	ra,88(sp)
    80002f46:	6446                	ld	s0,80(sp)
    80002f48:	64a6                	ld	s1,72(sp)
    80002f4a:	6906                	ld	s2,64(sp)
    80002f4c:	79e2                	ld	s3,56(sp)
    80002f4e:	7a42                	ld	s4,48(sp)
    80002f50:	7aa2                	ld	s5,40(sp)
    80002f52:	7b02                	ld	s6,32(sp)
    80002f54:	6be2                	ld	s7,24(sp)
    80002f56:	6c42                	ld	s8,16(sp)
    80002f58:	6ca2                	ld	s9,8(sp)
    80002f5a:	6125                	addi	sp,sp,96
    80002f5c:	8082                	ret

0000000080002f5e <get_next_page_to_swap_out>:
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	e426                	sd	s1,8(sp)
    80002f66:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	dc8080e7          	jalr	-568(ra) # 80001d30 <myproc>
  selected_pg_index = compare_all_pages(LAPA_compare);
    80002f70:	00000517          	auipc	a0,0x0
    80002f74:	cc850513          	addi	a0,a0,-824 # 80002c38 <LAPA_compare>
    80002f78:	00000097          	auipc	ra,0x0
    80002f7c:	f14080e7          	jalr	-236(ra) # 80002e8c <compare_all_pages>
    80002f80:	84aa                	mv	s1,a0
  printf("next page to swapout = %d\n",selected_pg_index);
    80002f82:	85aa                	mv	a1,a0
    80002f84:	00006517          	auipc	a0,0x6
    80002f88:	7d450513          	addi	a0,a0,2004 # 80009758 <digits+0x718>
    80002f8c:	ffffd097          	auipc	ra,0xffffd
    80002f90:	5e8080e7          	jalr	1512(ra) # 80000574 <printf>
}
    80002f94:	8526                	mv	a0,s1
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	64a2                	ld	s1,8(sp)
    80002f9c:	6105                	addi	sp,sp,32
    80002f9e:	8082                	ret

0000000080002fa0 <swtch>:
    80002fa0:	00153023          	sd	ra,0(a0)
    80002fa4:	00253423          	sd	sp,8(a0)
    80002fa8:	e900                	sd	s0,16(a0)
    80002faa:	ed04                	sd	s1,24(a0)
    80002fac:	03253023          	sd	s2,32(a0)
    80002fb0:	03353423          	sd	s3,40(a0)
    80002fb4:	03453823          	sd	s4,48(a0)
    80002fb8:	03553c23          	sd	s5,56(a0)
    80002fbc:	05653023          	sd	s6,64(a0)
    80002fc0:	05753423          	sd	s7,72(a0)
    80002fc4:	05853823          	sd	s8,80(a0)
    80002fc8:	05953c23          	sd	s9,88(a0)
    80002fcc:	07a53023          	sd	s10,96(a0)
    80002fd0:	07b53423          	sd	s11,104(a0)
    80002fd4:	0005b083          	ld	ra,0(a1)
    80002fd8:	0085b103          	ld	sp,8(a1)
    80002fdc:	6980                	ld	s0,16(a1)
    80002fde:	6d84                	ld	s1,24(a1)
    80002fe0:	0205b903          	ld	s2,32(a1)
    80002fe4:	0285b983          	ld	s3,40(a1)
    80002fe8:	0305ba03          	ld	s4,48(a1)
    80002fec:	0385ba83          	ld	s5,56(a1)
    80002ff0:	0405bb03          	ld	s6,64(a1)
    80002ff4:	0485bb83          	ld	s7,72(a1)
    80002ff8:	0505bc03          	ld	s8,80(a1)
    80002ffc:	0585bc83          	ld	s9,88(a1)
    80003000:	0605bd03          	ld	s10,96(a1)
    80003004:	0685bd83          	ld	s11,104(a1)
    80003008:	8082                	ret

000000008000300a <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000300a:	1141                	addi	sp,sp,-16
    8000300c:	e406                	sd	ra,8(sp)
    8000300e:	e022                	sd	s0,0(sp)
    80003010:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003012:	00006597          	auipc	a1,0x6
    80003016:	7be58593          	addi	a1,a1,1982 # 800097d0 <states.0+0x30>
    8000301a:	0001e517          	auipc	a0,0x1e
    8000301e:	ab650513          	addi	a0,a0,-1354 # 80020ad0 <tickslock>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	b10080e7          	jalr	-1264(ra) # 80000b32 <initlock>
}
    8000302a:	60a2                	ld	ra,8(sp)
    8000302c:	6402                	ld	s0,0(sp)
    8000302e:	0141                	addi	sp,sp,16
    80003030:	8082                	ret

0000000080003032 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80003032:	1141                	addi	sp,sp,-16
    80003034:	e422                	sd	s0,8(sp)
    80003036:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003038:	00004797          	auipc	a5,0x4
    8000303c:	bb878793          	addi	a5,a5,-1096 # 80006bf0 <kernelvec>
    80003040:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003044:	6422                	ld	s0,8(sp)
    80003046:	0141                	addi	sp,sp,16
    80003048:	8082                	ret

000000008000304a <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000304a:	1141                	addi	sp,sp,-16
    8000304c:	e406                	sd	ra,8(sp)
    8000304e:	e022                	sd	s0,0(sp)
    80003050:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80003052:	fffff097          	auipc	ra,0xfffff
    80003056:	cde080e7          	jalr	-802(ra) # 80001d30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000305a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000305e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003060:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003064:	00005617          	auipc	a2,0x5
    80003068:	f9c60613          	addi	a2,a2,-100 # 80008000 <_trampoline>
    8000306c:	00005697          	auipc	a3,0x5
    80003070:	f9468693          	addi	a3,a3,-108 # 80008000 <_trampoline>
    80003074:	8e91                	sub	a3,a3,a2
    80003076:	040007b7          	lui	a5,0x4000
    8000307a:	17fd                	addi	a5,a5,-1
    8000307c:	07b2                	slli	a5,a5,0xc
    8000307e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003080:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003084:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003086:	180026f3          	csrr	a3,satp
    8000308a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000308c:	6d38                	ld	a4,88(a0)
    8000308e:	6134                	ld	a3,64(a0)
    80003090:	6585                	lui	a1,0x1
    80003092:	96ae                	add	a3,a3,a1
    80003094:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003096:	6d38                	ld	a4,88(a0)
    80003098:	00000697          	auipc	a3,0x0
    8000309c:	13868693          	addi	a3,a3,312 # 800031d0 <usertrap>
    800030a0:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800030a2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800030a4:	8692                	mv	a3,tp
    800030a6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030a8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800030ac:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800030b0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030b4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800030b8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030ba:	6f18                	ld	a4,24(a4)
    800030bc:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800030c0:	692c                	ld	a1,80(a0)
    800030c2:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800030c4:	00005717          	auipc	a4,0x5
    800030c8:	fcc70713          	addi	a4,a4,-52 # 80008090 <userret>
    800030cc:	8f11                	sub	a4,a4,a2
    800030ce:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    800030d0:	577d                	li	a4,-1
    800030d2:	177e                	slli	a4,a4,0x3f
    800030d4:	8dd9                	or	a1,a1,a4
    800030d6:	02000537          	lui	a0,0x2000
    800030da:	157d                	addi	a0,a0,-1
    800030dc:	0536                	slli	a0,a0,0xd
    800030de:	9782                	jalr	a5
}
    800030e0:	60a2                	ld	ra,8(sp)
    800030e2:	6402                	ld	s0,0(sp)
    800030e4:	0141                	addi	sp,sp,16
    800030e6:	8082                	ret

00000000800030e8 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800030f2:	0001e497          	auipc	s1,0x1e
    800030f6:	9de48493          	addi	s1,s1,-1570 # 80020ad0 <tickslock>
    800030fa:	8526                	mv	a0,s1
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	ac6080e7          	jalr	-1338(ra) # 80000bc2 <acquire>
  ticks++;
    80003104:	00007517          	auipc	a0,0x7
    80003108:	f2c50513          	addi	a0,a0,-212 # 8000a030 <ticks>
    8000310c:	411c                	lw	a5,0(a0)
    8000310e:	2785                	addiw	a5,a5,1
    80003110:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	2a2080e7          	jalr	674(ra) # 800023b4 <wakeup>
  release(&tickslock);
    8000311a:	8526                	mv	a0,s1
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	b5a080e7          	jalr	-1190(ra) # 80000c76 <release>
}
    80003124:	60e2                	ld	ra,24(sp)
    80003126:	6442                	ld	s0,16(sp)
    80003128:	64a2                	ld	s1,8(sp)
    8000312a:	6105                	addi	sp,sp,32
    8000312c:	8082                	ret

000000008000312e <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    8000312e:	1101                	addi	sp,sp,-32
    80003130:	ec06                	sd	ra,24(sp)
    80003132:	e822                	sd	s0,16(sp)
    80003134:	e426                	sd	s1,8(sp)
    80003136:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003138:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    8000313c:	00074d63          	bltz	a4,80003156 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80003140:	57fd                	li	a5,-1
    80003142:	17fe                	slli	a5,a5,0x3f
    80003144:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80003146:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80003148:	06f70363          	beq	a4,a5,800031ae <devintr+0x80>
  }
}
    8000314c:	60e2                	ld	ra,24(sp)
    8000314e:	6442                	ld	s0,16(sp)
    80003150:	64a2                	ld	s1,8(sp)
    80003152:	6105                	addi	sp,sp,32
    80003154:	8082                	ret
      (scause & 0xff) == 9)
    80003156:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    8000315a:	46a5                	li	a3,9
    8000315c:	fed792e3          	bne	a5,a3,80003140 <devintr+0x12>
    int irq = plic_claim();
    80003160:	00004097          	auipc	ra,0x4
    80003164:	b98080e7          	jalr	-1128(ra) # 80006cf8 <plic_claim>
    80003168:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    8000316a:	47a9                	li	a5,10
    8000316c:	02f50763          	beq	a0,a5,8000319a <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80003170:	4785                	li	a5,1
    80003172:	02f50963          	beq	a0,a5,800031a4 <devintr+0x76>
    return 1;
    80003176:	4505                	li	a0,1
    else if (irq)
    80003178:	d8f1                	beqz	s1,8000314c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000317a:	85a6                	mv	a1,s1
    8000317c:	00006517          	auipc	a0,0x6
    80003180:	65c50513          	addi	a0,a0,1628 # 800097d8 <states.0+0x38>
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	3f0080e7          	jalr	1008(ra) # 80000574 <printf>
      plic_complete(irq);
    8000318c:	8526                	mv	a0,s1
    8000318e:	00004097          	auipc	ra,0x4
    80003192:	b8e080e7          	jalr	-1138(ra) # 80006d1c <plic_complete>
    return 1;
    80003196:	4505                	li	a0,1
    80003198:	bf55                	j	8000314c <devintr+0x1e>
      uartintr();
    8000319a:	ffffd097          	auipc	ra,0xffffd
    8000319e:	7ec080e7          	jalr	2028(ra) # 80000986 <uartintr>
    800031a2:	b7ed                	j	8000318c <devintr+0x5e>
      virtio_disk_intr();
    800031a4:	00004097          	auipc	ra,0x4
    800031a8:	00a080e7          	jalr	10(ra) # 800071ae <virtio_disk_intr>
    800031ac:	b7c5                	j	8000318c <devintr+0x5e>
    if (cpuid() == 0)
    800031ae:	fffff097          	auipc	ra,0xfffff
    800031b2:	b56080e7          	jalr	-1194(ra) # 80001d04 <cpuid>
    800031b6:	c901                	beqz	a0,800031c6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800031b8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800031bc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800031be:	14479073          	csrw	sip,a5
    return 2;
    800031c2:	4509                	li	a0,2
    800031c4:	b761                	j	8000314c <devintr+0x1e>
      clockintr();
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	f22080e7          	jalr	-222(ra) # 800030e8 <clockintr>
    800031ce:	b7ed                	j	800031b8 <devintr+0x8a>

00000000800031d0 <usertrap>:
{
    800031d0:	7139                	addi	sp,sp,-64
    800031d2:	fc06                	sd	ra,56(sp)
    800031d4:	f822                	sd	s0,48(sp)
    800031d6:	f426                	sd	s1,40(sp)
    800031d8:	f04a                	sd	s2,32(sp)
    800031da:	ec4e                	sd	s3,24(sp)
    800031dc:	e852                	sd	s4,16(sp)
    800031de:	e456                	sd	s5,8(sp)
    800031e0:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800031e2:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800031e6:	1007f793          	andi	a5,a5,256
    800031ea:	e7a1                	bnez	a5,80003232 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800031ec:	00004797          	auipc	a5,0x4
    800031f0:	a0478793          	addi	a5,a5,-1532 # 80006bf0 <kernelvec>
    800031f4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800031f8:	fffff097          	auipc	ra,0xfffff
    800031fc:	b38080e7          	jalr	-1224(ra) # 80001d30 <myproc>
    80003200:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80003202:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003204:	14102773          	csrr	a4,sepc
    80003208:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000320a:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    8000320e:	4721                	li	a4,8
    80003210:	02e78963          	beq	a5,a4,80003242 <usertrap+0x72>
  else if (trap_cause == 13 || trap_cause == 15)
    80003214:	9bf5                	andi	a5,a5,-3
    80003216:	4735                	li	a4,13
    80003218:	06e78b63          	beq	a5,a4,8000328e <usertrap+0xbe>
  else if ((which_dev = devintr()) != 0)
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	f12080e7          	jalr	-238(ra) # 8000312e <devintr>
    80003224:	892a                	mv	s2,a0
    80003226:	1c050663          	beqz	a0,800033f2 <usertrap+0x222>
  if (p->killed)
    8000322a:	549c                	lw	a5,40(s1)
    8000322c:	20078363          	beqz	a5,80003432 <usertrap+0x262>
    80003230:	aae5                	j	80003428 <usertrap+0x258>
    panic("usertrap: not from user mode");
    80003232:	00006517          	auipc	a0,0x6
    80003236:	5c650513          	addi	a0,a0,1478 # 800097f8 <states.0+0x58>
    8000323a:	ffffd097          	auipc	ra,0xffffd
    8000323e:	2f0080e7          	jalr	752(ra) # 8000052a <panic>
    if (p->killed)
    80003242:	551c                	lw	a5,40(a0)
    80003244:	ef9d                	bnez	a5,80003282 <usertrap+0xb2>
    p->trapframe->epc += 4;
    80003246:	6cb8                	ld	a4,88(s1)
    80003248:	6f1c                	ld	a5,24(a4)
    8000324a:	0791                	addi	a5,a5,4
    8000324c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000324e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003252:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003256:	10079073          	csrw	sstatus,a5
    syscall();
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	42a080e7          	jalr	1066(ra) # 80003684 <syscall>
  if (p->killed)
    80003262:	549c                	lw	a5,40(s1)
    80003264:	1c079163          	bnez	a5,80003426 <usertrap+0x256>
  usertrapret();
    80003268:	00000097          	auipc	ra,0x0
    8000326c:	de2080e7          	jalr	-542(ra) # 8000304a <usertrapret>
}
    80003270:	70e2                	ld	ra,56(sp)
    80003272:	7442                	ld	s0,48(sp)
    80003274:	74a2                	ld	s1,40(sp)
    80003276:	7902                	ld	s2,32(sp)
    80003278:	69e2                	ld	s3,24(sp)
    8000327a:	6a42                	ld	s4,16(sp)
    8000327c:	6aa2                	ld	s5,8(sp)
    8000327e:	6121                	addi	sp,sp,64
    80003280:	8082                	ret
      exit(-1);
    80003282:	557d                	li	a0,-1
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	200080e7          	jalr	512(ra) # 80002484 <exit>
    8000328c:	bf6d                	j	80003246 <usertrap+0x76>
    struct proc *p = myproc();
    8000328e:	fffff097          	auipc	ra,0xfffff
    80003292:	aa2080e7          	jalr	-1374(ra) # 80001d30 <myproc>
    80003296:	89aa                	mv	s3,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003298:	14302a73          	csrr	s4,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    8000329c:	77fd                	lui	a5,0xfffff
    8000329e:	00fa7a33          	and	s4,s4,a5
    pte_t *pte = walk(p->pagetable, fault_rva, 0);
    800032a2:	4601                	li	a2,0
    800032a4:	85d2                	mv	a1,s4
    800032a6:	6928                	ld	a0,80(a0)
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	cfe080e7          	jalr	-770(ra) # 80000fa6 <walk>
    800032b0:	892a                	mv	s2,a0
    if (!pte || p->pid <= 2)
    800032b2:	cd31                	beqz	a0,8000330e <usertrap+0x13e>
    800032b4:	0309a703          	lw	a4,48(s3)
    800032b8:	4789                	li	a5,2
    800032ba:	04e7da63          	bge	a5,a4,8000330e <usertrap+0x13e>
    printf("8====D\n");
    800032be:	00006517          	auipc	a0,0x6
    800032c2:	59a50513          	addi	a0,a0,1434 # 80009858 <states.0+0xb8>
    800032c6:	ffffd097          	auipc	ra,0xffffd
    800032ca:	2ae080e7          	jalr	686(ra) # 80000574 <printf>
    printf("10.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    800032ce:	00093583          	ld	a1,0(s2)
    800032d2:	0095d613          	srli	a2,a1,0x9
    800032d6:	8a05                	andi	a2,a2,1
    800032d8:	8985                	andi	a1,a1,1
    800032da:	00006517          	auipc	a0,0x6
    800032de:	58650513          	addi	a0,a0,1414 # 80009860 <states.0+0xc0>
    800032e2:	ffffd097          	auipc	ra,0xffffd
    800032e6:	292080e7          	jalr	658(ra) # 80000574 <printf>
    if ((*pte & PTE_PG) && !(*pte & PTE_V))
    800032ea:	00093783          	ld	a5,0(s2)
    800032ee:	2017f693          	andi	a3,a5,513
    800032f2:	20000713          	li	a4,512
    800032f6:	02e68e63          	beq	a3,a4,80003332 <usertrap+0x162>
    else if (*pte & PTE_V)
    800032fa:	8b85                	andi	a5,a5,1
    800032fc:	d3bd                	beqz	a5,80003262 <usertrap+0x92>
      panic("usertrap: PTE_V should not be valid during page_fault"); //TODO: check if needed/true
    800032fe:	00006517          	auipc	a0,0x6
    80003302:	66250513          	addi	a0,a0,1634 # 80009960 <states.0+0x1c0>
    80003306:	ffffd097          	auipc	ra,0xffffd
    8000330a:	224080e7          	jalr	548(ra) # 8000052a <panic>
      printf("seg fault with pid=%d", p->pid);
    8000330e:	0309a583          	lw	a1,48(s3)
    80003312:	00006517          	auipc	a0,0x6
    80003316:	50650513          	addi	a0,a0,1286 # 80009818 <states.0+0x78>
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	25a080e7          	jalr	602(ra) # 80000574 <printf>
      panic("usertrap: segmentation fault oh nooooo"); // TODO check if need to kill just the current procces
    80003322:	00006517          	auipc	a0,0x6
    80003326:	50e50513          	addi	a0,a0,1294 # 80009830 <states.0+0x90>
    8000332a:	ffffd097          	auipc	ra,0xffffd
    8000332e:	200080e7          	jalr	512(ra) # 8000052a <panic>
      printf("debug: segfault bringing page from swapfile\n");
    80003332:	00006517          	auipc	a0,0x6
    80003336:	54e50513          	addi	a0,a0,1358 # 80009880 <states.0+0xe0>
    8000333a:	ffffd097          	auipc	ra,0xffffd
    8000333e:	23a080e7          	jalr	570(ra) # 80000574 <printf>
      if (p->physical_pages_num >= MAX_PSYC_PAGES)
    80003342:	1709a703          	lw	a4,368(s3)
    80003346:	47bd                	li	a5,15
    80003348:	06e7dd63          	bge	a5,a4,800033c2 <usertrap+0x1f2>
        int page_to_swap_out_index = get_next_page_to_swap_out();
    8000334c:	00000097          	auipc	ra,0x0
    80003350:	c12080e7          	jalr	-1006(ra) # 80002f5e <get_next_page_to_swap_out>
        if (page_to_swap_out_index < 0 || page_to_swap_out_index > MAX_PSYC_PAGES)
    80003354:	0005071b          	sext.w	a4,a0
    80003358:	47c1                	li	a5,16
    8000335a:	08e7e463          	bltu	a5,a4,800033e2 <usertrap+0x212>
        uint64 va = p->pages_physc_info.pages[page_to_swap_out_index].va;
    8000335e:	02850513          	addi	a0,a0,40
    80003362:	0512                	slli	a0,a0,0x4
    80003364:	99aa                	add	s3,s3,a0
    80003366:	0089ba83          	ld	s5,8(s3)
        printf("11.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    8000336a:	00093583          	ld	a1,0(s2)
    8000336e:	0095d613          	srli	a2,a1,0x9
    80003372:	8a05                	andi	a2,a2,1
    80003374:	8985                	andi	a1,a1,1
    80003376:	00006517          	auipc	a0,0x6
    8000337a:	56250513          	addi	a0,a0,1378 # 800098d8 <states.0+0x138>
    8000337e:	ffffd097          	auipc	ra,0xffffd
    80003382:	1f6080e7          	jalr	502(ra) # 80000574 <printf>
        uint64 pa = page_out(va);
    80003386:	8556                	mv	a0,s5
    80003388:	fffff097          	auipc	ra,0xfffff
    8000338c:	3fa080e7          	jalr	1018(ra) # 80002782 <page_out>
    80003390:	89aa                	mv	s3,a0
         printf("12.pte_v = %d, pte_pg= %d\n", (*pte & PTE_V) > 0, (*pte & PTE_PG)>0);
    80003392:	00093583          	ld	a1,0(s2)
    80003396:	0095d613          	srli	a2,a1,0x9
    8000339a:	8a05                	andi	a2,a2,1
    8000339c:	8985                	andi	a1,a1,1
    8000339e:	00006517          	auipc	a0,0x6
    800033a2:	55a50513          	addi	a0,a0,1370 # 800098f8 <states.0+0x158>
    800033a6:	ffffd097          	auipc	ra,0xffffd
    800033aa:	1ce080e7          	jalr	462(ra) # 80000574 <printf>
        printf("usertrap: paged out page with va = %p pa = %p\n", va, pa); //TODO delete
    800033ae:	864e                	mv	a2,s3
    800033b0:	85d6                	mv	a1,s5
    800033b2:	00006517          	auipc	a0,0x6
    800033b6:	56650513          	addi	a0,a0,1382 # 80009918 <states.0+0x178>
    800033ba:	ffffd097          	auipc	ra,0xffffd
    800033be:	1ba080e7          	jalr	442(ra) # 80000574 <printf>
      pte_t *pte_new = page_in(fault_rva, pte);
    800033c2:	85ca                	mv	a1,s2
    800033c4:	8552                	mv	a0,s4
    800033c6:	fffff097          	auipc	ra,0xfffff
    800033ca:	476080e7          	jalr	1142(ra) # 8000283c <page_in>
    800033ce:	85aa                	mv	a1,a0
      printf("usertrap: pte_new = %p\n", pte_new); // TODO delete
    800033d0:	00006517          	auipc	a0,0x6
    800033d4:	57850513          	addi	a0,a0,1400 # 80009948 <states.0+0x1a8>
    800033d8:	ffffd097          	auipc	ra,0xffffd
    800033dc:	19c080e7          	jalr	412(ra) # 80000574 <printf>
    800033e0:	b549                	j	80003262 <usertrap+0x92>
          panic("usertrap: did not find page to swap out");
    800033e2:	00006517          	auipc	a0,0x6
    800033e6:	4ce50513          	addi	a0,a0,1230 # 800098b0 <states.0+0x110>
    800033ea:	ffffd097          	auipc	ra,0xffffd
    800033ee:	140080e7          	jalr	320(ra) # 8000052a <panic>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800033f2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800033f6:	5890                	lw	a2,48(s1)
    800033f8:	00006517          	auipc	a0,0x6
    800033fc:	5a050513          	addi	a0,a0,1440 # 80009998 <states.0+0x1f8>
    80003400:	ffffd097          	auipc	ra,0xffffd
    80003404:	174080e7          	jalr	372(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003408:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000340c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003410:	00006517          	auipc	a0,0x6
    80003414:	5b850513          	addi	a0,a0,1464 # 800099c8 <states.0+0x228>
    80003418:	ffffd097          	auipc	ra,0xffffd
    8000341c:	15c080e7          	jalr	348(ra) # 80000574 <printf>
    p->killed = 1;
    80003420:	4785                	li	a5,1
    80003422:	d49c                	sw	a5,40(s1)
  if (p->killed)
    80003424:	a011                	j	80003428 <usertrap+0x258>
    80003426:	4901                	li	s2,0
    exit(-1);
    80003428:	557d                	li	a0,-1
    8000342a:	fffff097          	auipc	ra,0xfffff
    8000342e:	05a080e7          	jalr	90(ra) # 80002484 <exit>
  if (which_dev == 2)
    80003432:	4789                	li	a5,2
    80003434:	e2f91ae3          	bne	s2,a5,80003268 <usertrap+0x98>
    yield();
    80003438:	fffff097          	auipc	ra,0xfffff
    8000343c:	db4080e7          	jalr	-588(ra) # 800021ec <yield>
    80003440:	b525                	j	80003268 <usertrap+0x98>

0000000080003442 <kerneltrap>:
{
    80003442:	7179                	addi	sp,sp,-48
    80003444:	f406                	sd	ra,40(sp)
    80003446:	f022                	sd	s0,32(sp)
    80003448:	ec26                	sd	s1,24(sp)
    8000344a:	e84a                	sd	s2,16(sp)
    8000344c:	e44e                	sd	s3,8(sp)
    8000344e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003450:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003454:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003458:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    8000345c:	1004f793          	andi	a5,s1,256
    80003460:	cb85                	beqz	a5,80003490 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003462:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003466:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003468:	ef85                	bnez	a5,800034a0 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	cc4080e7          	jalr	-828(ra) # 8000312e <devintr>
    80003472:	cd1d                	beqz	a0,800034b0 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003474:	4789                	li	a5,2
    80003476:	06f50a63          	beq	a0,a5,800034ea <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000347a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000347e:	10049073          	csrw	sstatus,s1
}
    80003482:	70a2                	ld	ra,40(sp)
    80003484:	7402                	ld	s0,32(sp)
    80003486:	64e2                	ld	s1,24(sp)
    80003488:	6942                	ld	s2,16(sp)
    8000348a:	69a2                	ld	s3,8(sp)
    8000348c:	6145                	addi	sp,sp,48
    8000348e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003490:	00006517          	auipc	a0,0x6
    80003494:	55850513          	addi	a0,a0,1368 # 800099e8 <states.0+0x248>
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	092080e7          	jalr	146(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    800034a0:	00006517          	auipc	a0,0x6
    800034a4:	57050513          	addi	a0,a0,1392 # 80009a10 <states.0+0x270>
    800034a8:	ffffd097          	auipc	ra,0xffffd
    800034ac:	082080e7          	jalr	130(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    800034b0:	85ce                	mv	a1,s3
    800034b2:	00006517          	auipc	a0,0x6
    800034b6:	57e50513          	addi	a0,a0,1406 # 80009a30 <states.0+0x290>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	0ba080e7          	jalr	186(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800034c2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800034c6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800034ca:	00006517          	auipc	a0,0x6
    800034ce:	57650513          	addi	a0,a0,1398 # 80009a40 <states.0+0x2a0>
    800034d2:	ffffd097          	auipc	ra,0xffffd
    800034d6:	0a2080e7          	jalr	162(ra) # 80000574 <printf>
    panic("kerneltrap");
    800034da:	00006517          	auipc	a0,0x6
    800034de:	57e50513          	addi	a0,a0,1406 # 80009a58 <states.0+0x2b8>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	048080e7          	jalr	72(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800034ea:	fffff097          	auipc	ra,0xfffff
    800034ee:	846080e7          	jalr	-1978(ra) # 80001d30 <myproc>
    800034f2:	d541                	beqz	a0,8000347a <kerneltrap+0x38>
    800034f4:	fffff097          	auipc	ra,0xfffff
    800034f8:	83c080e7          	jalr	-1988(ra) # 80001d30 <myproc>
    800034fc:	4d18                	lw	a4,24(a0)
    800034fe:	4791                	li	a5,4
    80003500:	f6f71de3          	bne	a4,a5,8000347a <kerneltrap+0x38>
    yield();
    80003504:	fffff097          	auipc	ra,0xfffff
    80003508:	ce8080e7          	jalr	-792(ra) # 800021ec <yield>
    8000350c:	b7bd                	j	8000347a <kerneltrap+0x38>

000000008000350e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000350e:	1101                	addi	sp,sp,-32
    80003510:	ec06                	sd	ra,24(sp)
    80003512:	e822                	sd	s0,16(sp)
    80003514:	e426                	sd	s1,8(sp)
    80003516:	1000                	addi	s0,sp,32
    80003518:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000351a:	fffff097          	auipc	ra,0xfffff
    8000351e:	816080e7          	jalr	-2026(ra) # 80001d30 <myproc>
  switch (n) {
    80003522:	4795                	li	a5,5
    80003524:	0497e163          	bltu	a5,s1,80003566 <argraw+0x58>
    80003528:	048a                	slli	s1,s1,0x2
    8000352a:	00006717          	auipc	a4,0x6
    8000352e:	56670713          	addi	a4,a4,1382 # 80009a90 <states.0+0x2f0>
    80003532:	94ba                	add	s1,s1,a4
    80003534:	409c                	lw	a5,0(s1)
    80003536:	97ba                	add	a5,a5,a4
    80003538:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000353a:	6d3c                	ld	a5,88(a0)
    8000353c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000353e:	60e2                	ld	ra,24(sp)
    80003540:	6442                	ld	s0,16(sp)
    80003542:	64a2                	ld	s1,8(sp)
    80003544:	6105                	addi	sp,sp,32
    80003546:	8082                	ret
    return p->trapframe->a1;
    80003548:	6d3c                	ld	a5,88(a0)
    8000354a:	7fa8                	ld	a0,120(a5)
    8000354c:	bfcd                	j	8000353e <argraw+0x30>
    return p->trapframe->a2;
    8000354e:	6d3c                	ld	a5,88(a0)
    80003550:	63c8                	ld	a0,128(a5)
    80003552:	b7f5                	j	8000353e <argraw+0x30>
    return p->trapframe->a3;
    80003554:	6d3c                	ld	a5,88(a0)
    80003556:	67c8                	ld	a0,136(a5)
    80003558:	b7dd                	j	8000353e <argraw+0x30>
    return p->trapframe->a4;
    8000355a:	6d3c                	ld	a5,88(a0)
    8000355c:	6bc8                	ld	a0,144(a5)
    8000355e:	b7c5                	j	8000353e <argraw+0x30>
    return p->trapframe->a5;
    80003560:	6d3c                	ld	a5,88(a0)
    80003562:	6fc8                	ld	a0,152(a5)
    80003564:	bfe9                	j	8000353e <argraw+0x30>
  panic("argraw");
    80003566:	00006517          	auipc	a0,0x6
    8000356a:	50250513          	addi	a0,a0,1282 # 80009a68 <states.0+0x2c8>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	fbc080e7          	jalr	-68(ra) # 8000052a <panic>

0000000080003576 <fetchaddr>:
{
    80003576:	1101                	addi	sp,sp,-32
    80003578:	ec06                	sd	ra,24(sp)
    8000357a:	e822                	sd	s0,16(sp)
    8000357c:	e426                	sd	s1,8(sp)
    8000357e:	e04a                	sd	s2,0(sp)
    80003580:	1000                	addi	s0,sp,32
    80003582:	84aa                	mv	s1,a0
    80003584:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003586:	ffffe097          	auipc	ra,0xffffe
    8000358a:	7aa080e7          	jalr	1962(ra) # 80001d30 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000358e:	653c                	ld	a5,72(a0)
    80003590:	02f4f863          	bgeu	s1,a5,800035c0 <fetchaddr+0x4a>
    80003594:	00848713          	addi	a4,s1,8
    80003598:	02e7e663          	bltu	a5,a4,800035c4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000359c:	46a1                	li	a3,8
    8000359e:	8626                	mv	a2,s1
    800035a0:	85ca                	mv	a1,s2
    800035a2:	6928                	ld	a0,80(a0)
    800035a4:	ffffe097          	auipc	ra,0xffffe
    800035a8:	e7c080e7          	jalr	-388(ra) # 80001420 <copyin>
    800035ac:	00a03533          	snez	a0,a0
    800035b0:	40a00533          	neg	a0,a0
}
    800035b4:	60e2                	ld	ra,24(sp)
    800035b6:	6442                	ld	s0,16(sp)
    800035b8:	64a2                	ld	s1,8(sp)
    800035ba:	6902                	ld	s2,0(sp)
    800035bc:	6105                	addi	sp,sp,32
    800035be:	8082                	ret
    return -1;
    800035c0:	557d                	li	a0,-1
    800035c2:	bfcd                	j	800035b4 <fetchaddr+0x3e>
    800035c4:	557d                	li	a0,-1
    800035c6:	b7fd                	j	800035b4 <fetchaddr+0x3e>

00000000800035c8 <fetchstr>:
{
    800035c8:	7179                	addi	sp,sp,-48
    800035ca:	f406                	sd	ra,40(sp)
    800035cc:	f022                	sd	s0,32(sp)
    800035ce:	ec26                	sd	s1,24(sp)
    800035d0:	e84a                	sd	s2,16(sp)
    800035d2:	e44e                	sd	s3,8(sp)
    800035d4:	1800                	addi	s0,sp,48
    800035d6:	892a                	mv	s2,a0
    800035d8:	84ae                	mv	s1,a1
    800035da:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800035dc:	ffffe097          	auipc	ra,0xffffe
    800035e0:	754080e7          	jalr	1876(ra) # 80001d30 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800035e4:	86ce                	mv	a3,s3
    800035e6:	864a                	mv	a2,s2
    800035e8:	85a6                	mv	a1,s1
    800035ea:	6928                	ld	a0,80(a0)
    800035ec:	ffffe097          	auipc	ra,0xffffe
    800035f0:	ec4080e7          	jalr	-316(ra) # 800014b0 <copyinstr>
  if(err < 0)
    800035f4:	00054763          	bltz	a0,80003602 <fetchstr+0x3a>
  return strlen(buf);
    800035f8:	8526                	mv	a0,s1
    800035fa:	ffffe097          	auipc	ra,0xffffe
    800035fe:	848080e7          	jalr	-1976(ra) # 80000e42 <strlen>
}
    80003602:	70a2                	ld	ra,40(sp)
    80003604:	7402                	ld	s0,32(sp)
    80003606:	64e2                	ld	s1,24(sp)
    80003608:	6942                	ld	s2,16(sp)
    8000360a:	69a2                	ld	s3,8(sp)
    8000360c:	6145                	addi	sp,sp,48
    8000360e:	8082                	ret

0000000080003610 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003610:	1101                	addi	sp,sp,-32
    80003612:	ec06                	sd	ra,24(sp)
    80003614:	e822                	sd	s0,16(sp)
    80003616:	e426                	sd	s1,8(sp)
    80003618:	1000                	addi	s0,sp,32
    8000361a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000361c:	00000097          	auipc	ra,0x0
    80003620:	ef2080e7          	jalr	-270(ra) # 8000350e <argraw>
    80003624:	c088                	sw	a0,0(s1)
  return 0;
}
    80003626:	4501                	li	a0,0
    80003628:	60e2                	ld	ra,24(sp)
    8000362a:	6442                	ld	s0,16(sp)
    8000362c:	64a2                	ld	s1,8(sp)
    8000362e:	6105                	addi	sp,sp,32
    80003630:	8082                	ret

0000000080003632 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003632:	1101                	addi	sp,sp,-32
    80003634:	ec06                	sd	ra,24(sp)
    80003636:	e822                	sd	s0,16(sp)
    80003638:	e426                	sd	s1,8(sp)
    8000363a:	1000                	addi	s0,sp,32
    8000363c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	ed0080e7          	jalr	-304(ra) # 8000350e <argraw>
    80003646:	e088                	sd	a0,0(s1)
  return 0;
}
    80003648:	4501                	li	a0,0
    8000364a:	60e2                	ld	ra,24(sp)
    8000364c:	6442                	ld	s0,16(sp)
    8000364e:	64a2                	ld	s1,8(sp)
    80003650:	6105                	addi	sp,sp,32
    80003652:	8082                	ret

0000000080003654 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003654:	1101                	addi	sp,sp,-32
    80003656:	ec06                	sd	ra,24(sp)
    80003658:	e822                	sd	s0,16(sp)
    8000365a:	e426                	sd	s1,8(sp)
    8000365c:	e04a                	sd	s2,0(sp)
    8000365e:	1000                	addi	s0,sp,32
    80003660:	84ae                	mv	s1,a1
    80003662:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003664:	00000097          	auipc	ra,0x0
    80003668:	eaa080e7          	jalr	-342(ra) # 8000350e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000366c:	864a                	mv	a2,s2
    8000366e:	85a6                	mv	a1,s1
    80003670:	00000097          	auipc	ra,0x0
    80003674:	f58080e7          	jalr	-168(ra) # 800035c8 <fetchstr>
}
    80003678:	60e2                	ld	ra,24(sp)
    8000367a:	6442                	ld	s0,16(sp)
    8000367c:	64a2                	ld	s1,8(sp)
    8000367e:	6902                	ld	s2,0(sp)
    80003680:	6105                	addi	sp,sp,32
    80003682:	8082                	ret

0000000080003684 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80003684:	1101                	addi	sp,sp,-32
    80003686:	ec06                	sd	ra,24(sp)
    80003688:	e822                	sd	s0,16(sp)
    8000368a:	e426                	sd	s1,8(sp)
    8000368c:	e04a                	sd	s2,0(sp)
    8000368e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003690:	ffffe097          	auipc	ra,0xffffe
    80003694:	6a0080e7          	jalr	1696(ra) # 80001d30 <myproc>
    80003698:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000369a:	05853903          	ld	s2,88(a0)
    8000369e:	0a893783          	ld	a5,168(s2)
    800036a2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800036a6:	37fd                	addiw	a5,a5,-1
    800036a8:	4751                	li	a4,20
    800036aa:	00f76f63          	bltu	a4,a5,800036c8 <syscall+0x44>
    800036ae:	00369713          	slli	a4,a3,0x3
    800036b2:	00006797          	auipc	a5,0x6
    800036b6:	3f678793          	addi	a5,a5,1014 # 80009aa8 <syscalls>
    800036ba:	97ba                	add	a5,a5,a4
    800036bc:	639c                	ld	a5,0(a5)
    800036be:	c789                	beqz	a5,800036c8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800036c0:	9782                	jalr	a5
    800036c2:	06a93823          	sd	a0,112(s2)
    800036c6:	a839                	j	800036e4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800036c8:	15848613          	addi	a2,s1,344
    800036cc:	588c                	lw	a1,48(s1)
    800036ce:	00006517          	auipc	a0,0x6
    800036d2:	3a250513          	addi	a0,a0,930 # 80009a70 <states.0+0x2d0>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	e9e080e7          	jalr	-354(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800036de:	6cbc                	ld	a5,88(s1)
    800036e0:	577d                	li	a4,-1
    800036e2:	fbb8                	sd	a4,112(a5)
  }
}
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6902                	ld	s2,0(sp)
    800036ec:	6105                	addi	sp,sp,32
    800036ee:	8082                	ret

00000000800036f0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800036f0:	1101                	addi	sp,sp,-32
    800036f2:	ec06                	sd	ra,24(sp)
    800036f4:	e822                	sd	s0,16(sp)
    800036f6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800036f8:	fec40593          	addi	a1,s0,-20
    800036fc:	4501                	li	a0,0
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	f12080e7          	jalr	-238(ra) # 80003610 <argint>
    return -1;
    80003706:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003708:	00054963          	bltz	a0,8000371a <sys_exit+0x2a>
  exit(n);
    8000370c:	fec42503          	lw	a0,-20(s0)
    80003710:	fffff097          	auipc	ra,0xfffff
    80003714:	d74080e7          	jalr	-652(ra) # 80002484 <exit>
  return 0;  // not reached
    80003718:	4781                	li	a5,0
}
    8000371a:	853e                	mv	a0,a5
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret

0000000080003724 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003724:	1141                	addi	sp,sp,-16
    80003726:	e406                	sd	ra,8(sp)
    80003728:	e022                	sd	s0,0(sp)
    8000372a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000372c:	ffffe097          	auipc	ra,0xffffe
    80003730:	604080e7          	jalr	1540(ra) # 80001d30 <myproc>
}
    80003734:	5908                	lw	a0,48(a0)
    80003736:	60a2                	ld	ra,8(sp)
    80003738:	6402                	ld	s0,0(sp)
    8000373a:	0141                	addi	sp,sp,16
    8000373c:	8082                	ret

000000008000373e <sys_fork>:

uint64
sys_fork(void)
{
    8000373e:	1141                	addi	sp,sp,-16
    80003740:	e406                	sd	ra,8(sp)
    80003742:	e022                	sd	s0,0(sp)
    80003744:	0800                	addi	s0,sp,16
  return fork();
    80003746:	fffff097          	auipc	ra,0xfffff
    8000374a:	322080e7          	jalr	802(ra) # 80002a68 <fork>
}
    8000374e:	60a2                	ld	ra,8(sp)
    80003750:	6402                	ld	s0,0(sp)
    80003752:	0141                	addi	sp,sp,16
    80003754:	8082                	ret

0000000080003756 <sys_wait>:

uint64
sys_wait(void)
{
    80003756:	1101                	addi	sp,sp,-32
    80003758:	ec06                	sd	ra,24(sp)
    8000375a:	e822                	sd	s0,16(sp)
    8000375c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000375e:	fe840593          	addi	a1,s0,-24
    80003762:	4501                	li	a0,0
    80003764:	00000097          	auipc	ra,0x0
    80003768:	ece080e7          	jalr	-306(ra) # 80003632 <argaddr>
    8000376c:	87aa                	mv	a5,a0
    return -1;
    8000376e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003770:	0007c863          	bltz	a5,80003780 <sys_wait+0x2a>
  return wait(p);
    80003774:	fe843503          	ld	a0,-24(s0)
    80003778:	fffff097          	auipc	ra,0xfffff
    8000377c:	b14080e7          	jalr	-1260(ra) # 8000228c <wait>
}
    80003780:	60e2                	ld	ra,24(sp)
    80003782:	6442                	ld	s0,16(sp)
    80003784:	6105                	addi	sp,sp,32
    80003786:	8082                	ret

0000000080003788 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003788:	7179                	addi	sp,sp,-48
    8000378a:	f406                	sd	ra,40(sp)
    8000378c:	f022                	sd	s0,32(sp)
    8000378e:	ec26                	sd	s1,24(sp)
    80003790:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003792:	fdc40593          	addi	a1,s0,-36
    80003796:	4501                	li	a0,0
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	e78080e7          	jalr	-392(ra) # 80003610 <argint>
    return -1;
    800037a0:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800037a2:	00054f63          	bltz	a0,800037c0 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800037a6:	ffffe097          	auipc	ra,0xffffe
    800037aa:	58a080e7          	jalr	1418(ra) # 80001d30 <myproc>
    800037ae:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800037b0:	fdc42503          	lw	a0,-36(s0)
    800037b4:	fffff097          	auipc	ra,0xfffff
    800037b8:	8ee080e7          	jalr	-1810(ra) # 800020a2 <growproc>
    800037bc:	00054863          	bltz	a0,800037cc <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800037c0:	8526                	mv	a0,s1
    800037c2:	70a2                	ld	ra,40(sp)
    800037c4:	7402                	ld	s0,32(sp)
    800037c6:	64e2                	ld	s1,24(sp)
    800037c8:	6145                	addi	sp,sp,48
    800037ca:	8082                	ret
    return -1;
    800037cc:	54fd                	li	s1,-1
    800037ce:	bfcd                	j	800037c0 <sys_sbrk+0x38>

00000000800037d0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800037d0:	7139                	addi	sp,sp,-64
    800037d2:	fc06                	sd	ra,56(sp)
    800037d4:	f822                	sd	s0,48(sp)
    800037d6:	f426                	sd	s1,40(sp)
    800037d8:	f04a                	sd	s2,32(sp)
    800037da:	ec4e                	sd	s3,24(sp)
    800037dc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800037de:	fcc40593          	addi	a1,s0,-52
    800037e2:	4501                	li	a0,0
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	e2c080e7          	jalr	-468(ra) # 80003610 <argint>
    return -1;
    800037ec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800037ee:	06054563          	bltz	a0,80003858 <sys_sleep+0x88>
  acquire(&tickslock);
    800037f2:	0001d517          	auipc	a0,0x1d
    800037f6:	2de50513          	addi	a0,a0,734 # 80020ad0 <tickslock>
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	3c8080e7          	jalr	968(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003802:	00007917          	auipc	s2,0x7
    80003806:	82e92903          	lw	s2,-2002(s2) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    8000380a:	fcc42783          	lw	a5,-52(s0)
    8000380e:	cf85                	beqz	a5,80003846 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003810:	0001d997          	auipc	s3,0x1d
    80003814:	2c098993          	addi	s3,s3,704 # 80020ad0 <tickslock>
    80003818:	00007497          	auipc	s1,0x7
    8000381c:	81848493          	addi	s1,s1,-2024 # 8000a030 <ticks>
    if(myproc()->killed){
    80003820:	ffffe097          	auipc	ra,0xffffe
    80003824:	510080e7          	jalr	1296(ra) # 80001d30 <myproc>
    80003828:	551c                	lw	a5,40(a0)
    8000382a:	ef9d                	bnez	a5,80003868 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000382c:	85ce                	mv	a1,s3
    8000382e:	8526                	mv	a0,s1
    80003830:	fffff097          	auipc	ra,0xfffff
    80003834:	9f8080e7          	jalr	-1544(ra) # 80002228 <sleep>
  while(ticks - ticks0 < n){
    80003838:	409c                	lw	a5,0(s1)
    8000383a:	412787bb          	subw	a5,a5,s2
    8000383e:	fcc42703          	lw	a4,-52(s0)
    80003842:	fce7efe3          	bltu	a5,a4,80003820 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003846:	0001d517          	auipc	a0,0x1d
    8000384a:	28a50513          	addi	a0,a0,650 # 80020ad0 <tickslock>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	428080e7          	jalr	1064(ra) # 80000c76 <release>
  return 0;
    80003856:	4781                	li	a5,0
}
    80003858:	853e                	mv	a0,a5
    8000385a:	70e2                	ld	ra,56(sp)
    8000385c:	7442                	ld	s0,48(sp)
    8000385e:	74a2                	ld	s1,40(sp)
    80003860:	7902                	ld	s2,32(sp)
    80003862:	69e2                	ld	s3,24(sp)
    80003864:	6121                	addi	sp,sp,64
    80003866:	8082                	ret
      release(&tickslock);
    80003868:	0001d517          	auipc	a0,0x1d
    8000386c:	26850513          	addi	a0,a0,616 # 80020ad0 <tickslock>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	406080e7          	jalr	1030(ra) # 80000c76 <release>
      return -1;
    80003878:	57fd                	li	a5,-1
    8000387a:	bff9                	j	80003858 <sys_sleep+0x88>

000000008000387c <sys_kill>:

uint64
sys_kill(void)
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003884:	fec40593          	addi	a1,s0,-20
    80003888:	4501                	li	a0,0
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	d86080e7          	jalr	-634(ra) # 80003610 <argint>
    80003892:	87aa                	mv	a5,a0
    return -1;
    80003894:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003896:	0007c863          	bltz	a5,800038a6 <sys_kill+0x2a>
  return kill(pid);
    8000389a:	fec42503          	lw	a0,-20(s0)
    8000389e:	fffff097          	auipc	ra,0xfffff
    800038a2:	cc6080e7          	jalr	-826(ra) # 80002564 <kill>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	6105                	addi	sp,sp,32
    800038ac:	8082                	ret

00000000800038ae <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800038ae:	1101                	addi	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800038b8:	0001d517          	auipc	a0,0x1d
    800038bc:	21850513          	addi	a0,a0,536 # 80020ad0 <tickslock>
    800038c0:	ffffd097          	auipc	ra,0xffffd
    800038c4:	302080e7          	jalr	770(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800038c8:	00006497          	auipc	s1,0x6
    800038cc:	7684a483          	lw	s1,1896(s1) # 8000a030 <ticks>
  release(&tickslock);
    800038d0:	0001d517          	auipc	a0,0x1d
    800038d4:	20050513          	addi	a0,a0,512 # 80020ad0 <tickslock>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	39e080e7          	jalr	926(ra) # 80000c76 <release>
  return xticks;
}
    800038e0:	02049513          	slli	a0,s1,0x20
    800038e4:	9101                	srli	a0,a0,0x20
    800038e6:	60e2                	ld	ra,24(sp)
    800038e8:	6442                	ld	s0,16(sp)
    800038ea:	64a2                	ld	s1,8(sp)
    800038ec:	6105                	addi	sp,sp,32
    800038ee:	8082                	ret

00000000800038f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800038f0:	7179                	addi	sp,sp,-48
    800038f2:	f406                	sd	ra,40(sp)
    800038f4:	f022                	sd	s0,32(sp)
    800038f6:	ec26                	sd	s1,24(sp)
    800038f8:	e84a                	sd	s2,16(sp)
    800038fa:	e44e                	sd	s3,8(sp)
    800038fc:	e052                	sd	s4,0(sp)
    800038fe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003900:	00006597          	auipc	a1,0x6
    80003904:	25858593          	addi	a1,a1,600 # 80009b58 <syscalls+0xb0>
    80003908:	0001d517          	auipc	a0,0x1d
    8000390c:	1e050513          	addi	a0,a0,480 # 80020ae8 <bcache>
    80003910:	ffffd097          	auipc	ra,0xffffd
    80003914:	222080e7          	jalr	546(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003918:	00025797          	auipc	a5,0x25
    8000391c:	1d078793          	addi	a5,a5,464 # 80028ae8 <bcache+0x8000>
    80003920:	00025717          	auipc	a4,0x25
    80003924:	43070713          	addi	a4,a4,1072 # 80028d50 <bcache+0x8268>
    80003928:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000392c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003930:	0001d497          	auipc	s1,0x1d
    80003934:	1d048493          	addi	s1,s1,464 # 80020b00 <bcache+0x18>
    b->next = bcache.head.next;
    80003938:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000393a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000393c:	00006a17          	auipc	s4,0x6
    80003940:	224a0a13          	addi	s4,s4,548 # 80009b60 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003944:	2b893783          	ld	a5,696(s2)
    80003948:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000394a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000394e:	85d2                	mv	a1,s4
    80003950:	01048513          	addi	a0,s1,16
    80003954:	00001097          	auipc	ra,0x1
    80003958:	7e4080e7          	jalr	2020(ra) # 80005138 <initsleeplock>
    bcache.head.next->prev = b;
    8000395c:	2b893783          	ld	a5,696(s2)
    80003960:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003962:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003966:	45848493          	addi	s1,s1,1112
    8000396a:	fd349de3          	bne	s1,s3,80003944 <binit+0x54>
  }
}
    8000396e:	70a2                	ld	ra,40(sp)
    80003970:	7402                	ld	s0,32(sp)
    80003972:	64e2                	ld	s1,24(sp)
    80003974:	6942                	ld	s2,16(sp)
    80003976:	69a2                	ld	s3,8(sp)
    80003978:	6a02                	ld	s4,0(sp)
    8000397a:	6145                	addi	sp,sp,48
    8000397c:	8082                	ret

000000008000397e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000397e:	7179                	addi	sp,sp,-48
    80003980:	f406                	sd	ra,40(sp)
    80003982:	f022                	sd	s0,32(sp)
    80003984:	ec26                	sd	s1,24(sp)
    80003986:	e84a                	sd	s2,16(sp)
    80003988:	e44e                	sd	s3,8(sp)
    8000398a:	1800                	addi	s0,sp,48
    8000398c:	892a                	mv	s2,a0
    8000398e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003990:	0001d517          	auipc	a0,0x1d
    80003994:	15850513          	addi	a0,a0,344 # 80020ae8 <bcache>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	22a080e7          	jalr	554(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800039a0:	00025497          	auipc	s1,0x25
    800039a4:	4004b483          	ld	s1,1024(s1) # 80028da0 <bcache+0x82b8>
    800039a8:	00025797          	auipc	a5,0x25
    800039ac:	3a878793          	addi	a5,a5,936 # 80028d50 <bcache+0x8268>
    800039b0:	02f48f63          	beq	s1,a5,800039ee <bread+0x70>
    800039b4:	873e                	mv	a4,a5
    800039b6:	a021                	j	800039be <bread+0x40>
    800039b8:	68a4                	ld	s1,80(s1)
    800039ba:	02e48a63          	beq	s1,a4,800039ee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800039be:	449c                	lw	a5,8(s1)
    800039c0:	ff279ce3          	bne	a5,s2,800039b8 <bread+0x3a>
    800039c4:	44dc                	lw	a5,12(s1)
    800039c6:	ff3799e3          	bne	a5,s3,800039b8 <bread+0x3a>
      b->refcnt++;
    800039ca:	40bc                	lw	a5,64(s1)
    800039cc:	2785                	addiw	a5,a5,1
    800039ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800039d0:	0001d517          	auipc	a0,0x1d
    800039d4:	11850513          	addi	a0,a0,280 # 80020ae8 <bcache>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	29e080e7          	jalr	670(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800039e0:	01048513          	addi	a0,s1,16
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	78e080e7          	jalr	1934(ra) # 80005172 <acquiresleep>
      return b;
    800039ec:	a8b9                	j	80003a4a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800039ee:	00025497          	auipc	s1,0x25
    800039f2:	3aa4b483          	ld	s1,938(s1) # 80028d98 <bcache+0x82b0>
    800039f6:	00025797          	auipc	a5,0x25
    800039fa:	35a78793          	addi	a5,a5,858 # 80028d50 <bcache+0x8268>
    800039fe:	00f48863          	beq	s1,a5,80003a0e <bread+0x90>
    80003a02:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003a04:	40bc                	lw	a5,64(s1)
    80003a06:	cf81                	beqz	a5,80003a1e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003a08:	64a4                	ld	s1,72(s1)
    80003a0a:	fee49de3          	bne	s1,a4,80003a04 <bread+0x86>
  panic("bget: no buffers");
    80003a0e:	00006517          	auipc	a0,0x6
    80003a12:	15a50513          	addi	a0,a0,346 # 80009b68 <syscalls+0xc0>
    80003a16:	ffffd097          	auipc	ra,0xffffd
    80003a1a:	b14080e7          	jalr	-1260(ra) # 8000052a <panic>
      b->dev = dev;
    80003a1e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003a22:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003a26:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003a2a:	4785                	li	a5,1
    80003a2c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003a2e:	0001d517          	auipc	a0,0x1d
    80003a32:	0ba50513          	addi	a0,a0,186 # 80020ae8 <bcache>
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	240080e7          	jalr	576(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003a3e:	01048513          	addi	a0,s1,16
    80003a42:	00001097          	auipc	ra,0x1
    80003a46:	730080e7          	jalr	1840(ra) # 80005172 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003a4a:	409c                	lw	a5,0(s1)
    80003a4c:	cb89                	beqz	a5,80003a5e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003a4e:	8526                	mv	a0,s1
    80003a50:	70a2                	ld	ra,40(sp)
    80003a52:	7402                	ld	s0,32(sp)
    80003a54:	64e2                	ld	s1,24(sp)
    80003a56:	6942                	ld	s2,16(sp)
    80003a58:	69a2                	ld	s3,8(sp)
    80003a5a:	6145                	addi	sp,sp,48
    80003a5c:	8082                	ret
    virtio_disk_rw(b, 0);
    80003a5e:	4581                	li	a1,0
    80003a60:	8526                	mv	a0,s1
    80003a62:	00003097          	auipc	ra,0x3
    80003a66:	4c4080e7          	jalr	1220(ra) # 80006f26 <virtio_disk_rw>
    b->valid = 1;
    80003a6a:	4785                	li	a5,1
    80003a6c:	c09c                	sw	a5,0(s1)
  return b;
    80003a6e:	b7c5                	j	80003a4e <bread+0xd0>

0000000080003a70 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	e426                	sd	s1,8(sp)
    80003a78:	1000                	addi	s0,sp,32
    80003a7a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003a7c:	0541                	addi	a0,a0,16
    80003a7e:	00001097          	auipc	ra,0x1
    80003a82:	78e080e7          	jalr	1934(ra) # 8000520c <holdingsleep>
    80003a86:	cd01                	beqz	a0,80003a9e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003a88:	4585                	li	a1,1
    80003a8a:	8526                	mv	a0,s1
    80003a8c:	00003097          	auipc	ra,0x3
    80003a90:	49a080e7          	jalr	1178(ra) # 80006f26 <virtio_disk_rw>
}
    80003a94:	60e2                	ld	ra,24(sp)
    80003a96:	6442                	ld	s0,16(sp)
    80003a98:	64a2                	ld	s1,8(sp)
    80003a9a:	6105                	addi	sp,sp,32
    80003a9c:	8082                	ret
    panic("bwrite");
    80003a9e:	00006517          	auipc	a0,0x6
    80003aa2:	0e250513          	addi	a0,a0,226 # 80009b80 <syscalls+0xd8>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	a84080e7          	jalr	-1404(ra) # 8000052a <panic>

0000000080003aae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003aae:	1101                	addi	sp,sp,-32
    80003ab0:	ec06                	sd	ra,24(sp)
    80003ab2:	e822                	sd	s0,16(sp)
    80003ab4:	e426                	sd	s1,8(sp)
    80003ab6:	e04a                	sd	s2,0(sp)
    80003ab8:	1000                	addi	s0,sp,32
    80003aba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003abc:	01050913          	addi	s2,a0,16
    80003ac0:	854a                	mv	a0,s2
    80003ac2:	00001097          	auipc	ra,0x1
    80003ac6:	74a080e7          	jalr	1866(ra) # 8000520c <holdingsleep>
    80003aca:	c92d                	beqz	a0,80003b3c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003acc:	854a                	mv	a0,s2
    80003ace:	00001097          	auipc	ra,0x1
    80003ad2:	6fa080e7          	jalr	1786(ra) # 800051c8 <releasesleep>

  acquire(&bcache.lock);
    80003ad6:	0001d517          	auipc	a0,0x1d
    80003ada:	01250513          	addi	a0,a0,18 # 80020ae8 <bcache>
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	0e4080e7          	jalr	228(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003ae6:	40bc                	lw	a5,64(s1)
    80003ae8:	37fd                	addiw	a5,a5,-1
    80003aea:	0007871b          	sext.w	a4,a5
    80003aee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003af0:	eb05                	bnez	a4,80003b20 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003af2:	68bc                	ld	a5,80(s1)
    80003af4:	64b8                	ld	a4,72(s1)
    80003af6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003af8:	64bc                	ld	a5,72(s1)
    80003afa:	68b8                	ld	a4,80(s1)
    80003afc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003afe:	00025797          	auipc	a5,0x25
    80003b02:	fea78793          	addi	a5,a5,-22 # 80028ae8 <bcache+0x8000>
    80003b06:	2b87b703          	ld	a4,696(a5)
    80003b0a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003b0c:	00025717          	auipc	a4,0x25
    80003b10:	24470713          	addi	a4,a4,580 # 80028d50 <bcache+0x8268>
    80003b14:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003b16:	2b87b703          	ld	a4,696(a5)
    80003b1a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003b1c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003b20:	0001d517          	auipc	a0,0x1d
    80003b24:	fc850513          	addi	a0,a0,-56 # 80020ae8 <bcache>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
}
    80003b30:	60e2                	ld	ra,24(sp)
    80003b32:	6442                	ld	s0,16(sp)
    80003b34:	64a2                	ld	s1,8(sp)
    80003b36:	6902                	ld	s2,0(sp)
    80003b38:	6105                	addi	sp,sp,32
    80003b3a:	8082                	ret
    panic("brelse");
    80003b3c:	00006517          	auipc	a0,0x6
    80003b40:	04c50513          	addi	a0,a0,76 # 80009b88 <syscalls+0xe0>
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	9e6080e7          	jalr	-1562(ra) # 8000052a <panic>

0000000080003b4c <bpin>:

void
bpin(struct buf *b) {
    80003b4c:	1101                	addi	sp,sp,-32
    80003b4e:	ec06                	sd	ra,24(sp)
    80003b50:	e822                	sd	s0,16(sp)
    80003b52:	e426                	sd	s1,8(sp)
    80003b54:	1000                	addi	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b58:	0001d517          	auipc	a0,0x1d
    80003b5c:	f9050513          	addi	a0,a0,-112 # 80020ae8 <bcache>
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	062080e7          	jalr	98(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003b68:	40bc                	lw	a5,64(s1)
    80003b6a:	2785                	addiw	a5,a5,1
    80003b6c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003b6e:	0001d517          	auipc	a0,0x1d
    80003b72:	f7a50513          	addi	a0,a0,-134 # 80020ae8 <bcache>
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	100080e7          	jalr	256(ra) # 80000c76 <release>
}
    80003b7e:	60e2                	ld	ra,24(sp)
    80003b80:	6442                	ld	s0,16(sp)
    80003b82:	64a2                	ld	s1,8(sp)
    80003b84:	6105                	addi	sp,sp,32
    80003b86:	8082                	ret

0000000080003b88 <bunpin>:

void
bunpin(struct buf *b) {
    80003b88:	1101                	addi	sp,sp,-32
    80003b8a:	ec06                	sd	ra,24(sp)
    80003b8c:	e822                	sd	s0,16(sp)
    80003b8e:	e426                	sd	s1,8(sp)
    80003b90:	1000                	addi	s0,sp,32
    80003b92:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003b94:	0001d517          	auipc	a0,0x1d
    80003b98:	f5450513          	addi	a0,a0,-172 # 80020ae8 <bcache>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	026080e7          	jalr	38(ra) # 80000bc2 <acquire>
  b->refcnt--;
    80003ba4:	40bc                	lw	a5,64(s1)
    80003ba6:	37fd                	addiw	a5,a5,-1
    80003ba8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003baa:	0001d517          	auipc	a0,0x1d
    80003bae:	f3e50513          	addi	a0,a0,-194 # 80020ae8 <bcache>
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	0c4080e7          	jalr	196(ra) # 80000c76 <release>
}
    80003bba:	60e2                	ld	ra,24(sp)
    80003bbc:	6442                	ld	s0,16(sp)
    80003bbe:	64a2                	ld	s1,8(sp)
    80003bc0:	6105                	addi	sp,sp,32
    80003bc2:	8082                	ret

0000000080003bc4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003bc4:	1101                	addi	sp,sp,-32
    80003bc6:	ec06                	sd	ra,24(sp)
    80003bc8:	e822                	sd	s0,16(sp)
    80003bca:	e426                	sd	s1,8(sp)
    80003bcc:	e04a                	sd	s2,0(sp)
    80003bce:	1000                	addi	s0,sp,32
    80003bd0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003bd2:	00d5d59b          	srliw	a1,a1,0xd
    80003bd6:	00025797          	auipc	a5,0x25
    80003bda:	5ee7a783          	lw	a5,1518(a5) # 800291c4 <sb+0x1c>
    80003bde:	9dbd                	addw	a1,a1,a5
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	d9e080e7          	jalr	-610(ra) # 8000397e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003be8:	0074f713          	andi	a4,s1,7
    80003bec:	4785                	li	a5,1
    80003bee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003bf2:	14ce                	slli	s1,s1,0x33
    80003bf4:	90d9                	srli	s1,s1,0x36
    80003bf6:	00950733          	add	a4,a0,s1
    80003bfa:	05874703          	lbu	a4,88(a4)
    80003bfe:	00e7f6b3          	and	a3,a5,a4
    80003c02:	c69d                	beqz	a3,80003c30 <bfree+0x6c>
    80003c04:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003c06:	94aa                	add	s1,s1,a0
    80003c08:	fff7c793          	not	a5,a5
    80003c0c:	8ff9                	and	a5,a5,a4
    80003c0e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003c12:	00001097          	auipc	ra,0x1
    80003c16:	440080e7          	jalr	1088(ra) # 80005052 <log_write>
  brelse(bp);
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	e92080e7          	jalr	-366(ra) # 80003aae <brelse>
}
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	64a2                	ld	s1,8(sp)
    80003c2a:	6902                	ld	s2,0(sp)
    80003c2c:	6105                	addi	sp,sp,32
    80003c2e:	8082                	ret
    panic("freeing free block");
    80003c30:	00006517          	auipc	a0,0x6
    80003c34:	f6050513          	addi	a0,a0,-160 # 80009b90 <syscalls+0xe8>
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	8f2080e7          	jalr	-1806(ra) # 8000052a <panic>

0000000080003c40 <balloc>:
{
    80003c40:	711d                	addi	sp,sp,-96
    80003c42:	ec86                	sd	ra,88(sp)
    80003c44:	e8a2                	sd	s0,80(sp)
    80003c46:	e4a6                	sd	s1,72(sp)
    80003c48:	e0ca                	sd	s2,64(sp)
    80003c4a:	fc4e                	sd	s3,56(sp)
    80003c4c:	f852                	sd	s4,48(sp)
    80003c4e:	f456                	sd	s5,40(sp)
    80003c50:	f05a                	sd	s6,32(sp)
    80003c52:	ec5e                	sd	s7,24(sp)
    80003c54:	e862                	sd	s8,16(sp)
    80003c56:	e466                	sd	s9,8(sp)
    80003c58:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003c5a:	00025797          	auipc	a5,0x25
    80003c5e:	5527a783          	lw	a5,1362(a5) # 800291ac <sb+0x4>
    80003c62:	cbd1                	beqz	a5,80003cf6 <balloc+0xb6>
    80003c64:	8baa                	mv	s7,a0
    80003c66:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003c68:	00025b17          	auipc	s6,0x25
    80003c6c:	540b0b13          	addi	s6,s6,1344 # 800291a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c70:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003c72:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c74:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003c76:	6c89                	lui	s9,0x2
    80003c78:	a831                	j	80003c94 <balloc+0x54>
    brelse(bp);
    80003c7a:	854a                	mv	a0,s2
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	e32080e7          	jalr	-462(ra) # 80003aae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003c84:	015c87bb          	addw	a5,s9,s5
    80003c88:	00078a9b          	sext.w	s5,a5
    80003c8c:	004b2703          	lw	a4,4(s6)
    80003c90:	06eaf363          	bgeu	s5,a4,80003cf6 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003c94:	41fad79b          	sraiw	a5,s5,0x1f
    80003c98:	0137d79b          	srliw	a5,a5,0x13
    80003c9c:	015787bb          	addw	a5,a5,s5
    80003ca0:	40d7d79b          	sraiw	a5,a5,0xd
    80003ca4:	01cb2583          	lw	a1,28(s6)
    80003ca8:	9dbd                	addw	a1,a1,a5
    80003caa:	855e                	mv	a0,s7
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	cd2080e7          	jalr	-814(ra) # 8000397e <bread>
    80003cb4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cb6:	004b2503          	lw	a0,4(s6)
    80003cba:	000a849b          	sext.w	s1,s5
    80003cbe:	8662                	mv	a2,s8
    80003cc0:	faa4fde3          	bgeu	s1,a0,80003c7a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003cc4:	41f6579b          	sraiw	a5,a2,0x1f
    80003cc8:	01d7d69b          	srliw	a3,a5,0x1d
    80003ccc:	00c6873b          	addw	a4,a3,a2
    80003cd0:	00777793          	andi	a5,a4,7
    80003cd4:	9f95                	subw	a5,a5,a3
    80003cd6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003cda:	4037571b          	sraiw	a4,a4,0x3
    80003cde:	00e906b3          	add	a3,s2,a4
    80003ce2:	0586c683          	lbu	a3,88(a3)
    80003ce6:	00d7f5b3          	and	a1,a5,a3
    80003cea:	cd91                	beqz	a1,80003d06 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003cec:	2605                	addiw	a2,a2,1
    80003cee:	2485                	addiw	s1,s1,1
    80003cf0:	fd4618e3          	bne	a2,s4,80003cc0 <balloc+0x80>
    80003cf4:	b759                	j	80003c7a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003cf6:	00006517          	auipc	a0,0x6
    80003cfa:	eb250513          	addi	a0,a0,-334 # 80009ba8 <syscalls+0x100>
    80003cfe:	ffffd097          	auipc	ra,0xffffd
    80003d02:	82c080e7          	jalr	-2004(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003d06:	974a                	add	a4,a4,s2
    80003d08:	8fd5                	or	a5,a5,a3
    80003d0a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003d0e:	854a                	mv	a0,s2
    80003d10:	00001097          	auipc	ra,0x1
    80003d14:	342080e7          	jalr	834(ra) # 80005052 <log_write>
        brelse(bp);
    80003d18:	854a                	mv	a0,s2
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	d94080e7          	jalr	-620(ra) # 80003aae <brelse>
  bp = bread(dev, bno);
    80003d22:	85a6                	mv	a1,s1
    80003d24:	855e                	mv	a0,s7
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	c58080e7          	jalr	-936(ra) # 8000397e <bread>
    80003d2e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003d30:	40000613          	li	a2,1024
    80003d34:	4581                	li	a1,0
    80003d36:	05850513          	addi	a0,a0,88
    80003d3a:	ffffd097          	auipc	ra,0xffffd
    80003d3e:	f84080e7          	jalr	-124(ra) # 80000cbe <memset>
  log_write(bp);
    80003d42:	854a                	mv	a0,s2
    80003d44:	00001097          	auipc	ra,0x1
    80003d48:	30e080e7          	jalr	782(ra) # 80005052 <log_write>
  brelse(bp);
    80003d4c:	854a                	mv	a0,s2
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	d60080e7          	jalr	-672(ra) # 80003aae <brelse>
}
    80003d56:	8526                	mv	a0,s1
    80003d58:	60e6                	ld	ra,88(sp)
    80003d5a:	6446                	ld	s0,80(sp)
    80003d5c:	64a6                	ld	s1,72(sp)
    80003d5e:	6906                	ld	s2,64(sp)
    80003d60:	79e2                	ld	s3,56(sp)
    80003d62:	7a42                	ld	s4,48(sp)
    80003d64:	7aa2                	ld	s5,40(sp)
    80003d66:	7b02                	ld	s6,32(sp)
    80003d68:	6be2                	ld	s7,24(sp)
    80003d6a:	6c42                	ld	s8,16(sp)
    80003d6c:	6ca2                	ld	s9,8(sp)
    80003d6e:	6125                	addi	sp,sp,96
    80003d70:	8082                	ret

0000000080003d72 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003d72:	7179                	addi	sp,sp,-48
    80003d74:	f406                	sd	ra,40(sp)
    80003d76:	f022                	sd	s0,32(sp)
    80003d78:	ec26                	sd	s1,24(sp)
    80003d7a:	e84a                	sd	s2,16(sp)
    80003d7c:	e44e                	sd	s3,8(sp)
    80003d7e:	e052                	sd	s4,0(sp)
    80003d80:	1800                	addi	s0,sp,48
    80003d82:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003d84:	47ad                	li	a5,11
    80003d86:	04b7fe63          	bgeu	a5,a1,80003de2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003d8a:	ff45849b          	addiw	s1,a1,-12
    80003d8e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003d92:	0ff00793          	li	a5,255
    80003d96:	0ae7e463          	bltu	a5,a4,80003e3e <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003d9a:	08052583          	lw	a1,128(a0)
    80003d9e:	c5b5                	beqz	a1,80003e0a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003da0:	00092503          	lw	a0,0(s2)
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	bda080e7          	jalr	-1062(ra) # 8000397e <bread>
    80003dac:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003dae:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003db2:	02049713          	slli	a4,s1,0x20
    80003db6:	01e75593          	srli	a1,a4,0x1e
    80003dba:	00b784b3          	add	s1,a5,a1
    80003dbe:	0004a983          	lw	s3,0(s1)
    80003dc2:	04098e63          	beqz	s3,80003e1e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	ce6080e7          	jalr	-794(ra) # 80003aae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003dd0:	854e                	mv	a0,s3
    80003dd2:	70a2                	ld	ra,40(sp)
    80003dd4:	7402                	ld	s0,32(sp)
    80003dd6:	64e2                	ld	s1,24(sp)
    80003dd8:	6942                	ld	s2,16(sp)
    80003dda:	69a2                	ld	s3,8(sp)
    80003ddc:	6a02                	ld	s4,0(sp)
    80003dde:	6145                	addi	sp,sp,48
    80003de0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003de2:	02059793          	slli	a5,a1,0x20
    80003de6:	01e7d593          	srli	a1,a5,0x1e
    80003dea:	00b504b3          	add	s1,a0,a1
    80003dee:	0504a983          	lw	s3,80(s1)
    80003df2:	fc099fe3          	bnez	s3,80003dd0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003df6:	4108                	lw	a0,0(a0)
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	e48080e7          	jalr	-440(ra) # 80003c40 <balloc>
    80003e00:	0005099b          	sext.w	s3,a0
    80003e04:	0534a823          	sw	s3,80(s1)
    80003e08:	b7e1                	j	80003dd0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003e0a:	4108                	lw	a0,0(a0)
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	e34080e7          	jalr	-460(ra) # 80003c40 <balloc>
    80003e14:	0005059b          	sext.w	a1,a0
    80003e18:	08b92023          	sw	a1,128(s2)
    80003e1c:	b751                	j	80003da0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003e1e:	00092503          	lw	a0,0(s2)
    80003e22:	00000097          	auipc	ra,0x0
    80003e26:	e1e080e7          	jalr	-482(ra) # 80003c40 <balloc>
    80003e2a:	0005099b          	sext.w	s3,a0
    80003e2e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003e32:	8552                	mv	a0,s4
    80003e34:	00001097          	auipc	ra,0x1
    80003e38:	21e080e7          	jalr	542(ra) # 80005052 <log_write>
    80003e3c:	b769                	j	80003dc6 <bmap+0x54>
  panic("bmap: out of range");
    80003e3e:	00006517          	auipc	a0,0x6
    80003e42:	d8250513          	addi	a0,a0,-638 # 80009bc0 <syscalls+0x118>
    80003e46:	ffffc097          	auipc	ra,0xffffc
    80003e4a:	6e4080e7          	jalr	1764(ra) # 8000052a <panic>

0000000080003e4e <iget>:
{
    80003e4e:	7179                	addi	sp,sp,-48
    80003e50:	f406                	sd	ra,40(sp)
    80003e52:	f022                	sd	s0,32(sp)
    80003e54:	ec26                	sd	s1,24(sp)
    80003e56:	e84a                	sd	s2,16(sp)
    80003e58:	e44e                	sd	s3,8(sp)
    80003e5a:	e052                	sd	s4,0(sp)
    80003e5c:	1800                	addi	s0,sp,48
    80003e5e:	89aa                	mv	s3,a0
    80003e60:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003e62:	00025517          	auipc	a0,0x25
    80003e66:	36650513          	addi	a0,a0,870 # 800291c8 <itable>
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	d58080e7          	jalr	-680(ra) # 80000bc2 <acquire>
  empty = 0;
    80003e72:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e74:	00025497          	auipc	s1,0x25
    80003e78:	36c48493          	addi	s1,s1,876 # 800291e0 <itable+0x18>
    80003e7c:	00027697          	auipc	a3,0x27
    80003e80:	df468693          	addi	a3,a3,-524 # 8002ac70 <log>
    80003e84:	a039                	j	80003e92 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003e86:	02090b63          	beqz	s2,80003ebc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003e8a:	08848493          	addi	s1,s1,136
    80003e8e:	02d48a63          	beq	s1,a3,80003ec2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003e92:	449c                	lw	a5,8(s1)
    80003e94:	fef059e3          	blez	a5,80003e86 <iget+0x38>
    80003e98:	4098                	lw	a4,0(s1)
    80003e9a:	ff3716e3          	bne	a4,s3,80003e86 <iget+0x38>
    80003e9e:	40d8                	lw	a4,4(s1)
    80003ea0:	ff4713e3          	bne	a4,s4,80003e86 <iget+0x38>
      ip->ref++;
    80003ea4:	2785                	addiw	a5,a5,1
    80003ea6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ea8:	00025517          	auipc	a0,0x25
    80003eac:	32050513          	addi	a0,a0,800 # 800291c8 <itable>
    80003eb0:	ffffd097          	auipc	ra,0xffffd
    80003eb4:	dc6080e7          	jalr	-570(ra) # 80000c76 <release>
      return ip;
    80003eb8:	8926                	mv	s2,s1
    80003eba:	a03d                	j	80003ee8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ebc:	f7f9                	bnez	a5,80003e8a <iget+0x3c>
    80003ebe:	8926                	mv	s2,s1
    80003ec0:	b7e9                	j	80003e8a <iget+0x3c>
  if(empty == 0)
    80003ec2:	02090c63          	beqz	s2,80003efa <iget+0xac>
  ip->dev = dev;
    80003ec6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003eca:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003ece:	4785                	li	a5,1
    80003ed0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ed4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ed8:	00025517          	auipc	a0,0x25
    80003edc:	2f050513          	addi	a0,a0,752 # 800291c8 <itable>
    80003ee0:	ffffd097          	auipc	ra,0xffffd
    80003ee4:	d96080e7          	jalr	-618(ra) # 80000c76 <release>
}
    80003ee8:	854a                	mv	a0,s2
    80003eea:	70a2                	ld	ra,40(sp)
    80003eec:	7402                	ld	s0,32(sp)
    80003eee:	64e2                	ld	s1,24(sp)
    80003ef0:	6942                	ld	s2,16(sp)
    80003ef2:	69a2                	ld	s3,8(sp)
    80003ef4:	6a02                	ld	s4,0(sp)
    80003ef6:	6145                	addi	sp,sp,48
    80003ef8:	8082                	ret
    panic("iget: no inodes");
    80003efa:	00006517          	auipc	a0,0x6
    80003efe:	cde50513          	addi	a0,a0,-802 # 80009bd8 <syscalls+0x130>
    80003f02:	ffffc097          	auipc	ra,0xffffc
    80003f06:	628080e7          	jalr	1576(ra) # 8000052a <panic>

0000000080003f0a <fsinit>:
fsinit(int dev) {
    80003f0a:	7179                	addi	sp,sp,-48
    80003f0c:	f406                	sd	ra,40(sp)
    80003f0e:	f022                	sd	s0,32(sp)
    80003f10:	ec26                	sd	s1,24(sp)
    80003f12:	e84a                	sd	s2,16(sp)
    80003f14:	e44e                	sd	s3,8(sp)
    80003f16:	1800                	addi	s0,sp,48
    80003f18:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003f1a:	4585                	li	a1,1
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	a62080e7          	jalr	-1438(ra) # 8000397e <bread>
    80003f24:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003f26:	00025997          	auipc	s3,0x25
    80003f2a:	28298993          	addi	s3,s3,642 # 800291a8 <sb>
    80003f2e:	02000613          	li	a2,32
    80003f32:	05850593          	addi	a1,a0,88
    80003f36:	854e                	mv	a0,s3
    80003f38:	ffffd097          	auipc	ra,0xffffd
    80003f3c:	de2080e7          	jalr	-542(ra) # 80000d1a <memmove>
  brelse(bp);
    80003f40:	8526                	mv	a0,s1
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	b6c080e7          	jalr	-1172(ra) # 80003aae <brelse>
  if(sb.magic != FSMAGIC)
    80003f4a:	0009a703          	lw	a4,0(s3)
    80003f4e:	102037b7          	lui	a5,0x10203
    80003f52:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003f56:	02f71263          	bne	a4,a5,80003f7a <fsinit+0x70>
  initlog(dev, &sb);
    80003f5a:	00025597          	auipc	a1,0x25
    80003f5e:	24e58593          	addi	a1,a1,590 # 800291a8 <sb>
    80003f62:	854a                	mv	a0,s2
    80003f64:	00001097          	auipc	ra,0x1
    80003f68:	e70080e7          	jalr	-400(ra) # 80004dd4 <initlog>
}
    80003f6c:	70a2                	ld	ra,40(sp)
    80003f6e:	7402                	ld	s0,32(sp)
    80003f70:	64e2                	ld	s1,24(sp)
    80003f72:	6942                	ld	s2,16(sp)
    80003f74:	69a2                	ld	s3,8(sp)
    80003f76:	6145                	addi	sp,sp,48
    80003f78:	8082                	ret
    panic("invalid file system");
    80003f7a:	00006517          	auipc	a0,0x6
    80003f7e:	c6e50513          	addi	a0,a0,-914 # 80009be8 <syscalls+0x140>
    80003f82:	ffffc097          	auipc	ra,0xffffc
    80003f86:	5a8080e7          	jalr	1448(ra) # 8000052a <panic>

0000000080003f8a <iinit>:
{
    80003f8a:	7179                	addi	sp,sp,-48
    80003f8c:	f406                	sd	ra,40(sp)
    80003f8e:	f022                	sd	s0,32(sp)
    80003f90:	ec26                	sd	s1,24(sp)
    80003f92:	e84a                	sd	s2,16(sp)
    80003f94:	e44e                	sd	s3,8(sp)
    80003f96:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003f98:	00006597          	auipc	a1,0x6
    80003f9c:	c6858593          	addi	a1,a1,-920 # 80009c00 <syscalls+0x158>
    80003fa0:	00025517          	auipc	a0,0x25
    80003fa4:	22850513          	addi	a0,a0,552 # 800291c8 <itable>
    80003fa8:	ffffd097          	auipc	ra,0xffffd
    80003fac:	b8a080e7          	jalr	-1142(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003fb0:	00025497          	auipc	s1,0x25
    80003fb4:	24048493          	addi	s1,s1,576 # 800291f0 <itable+0x28>
    80003fb8:	00027997          	auipc	s3,0x27
    80003fbc:	cc898993          	addi	s3,s3,-824 # 8002ac80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003fc0:	00006917          	auipc	s2,0x6
    80003fc4:	c4890913          	addi	s2,s2,-952 # 80009c08 <syscalls+0x160>
    80003fc8:	85ca                	mv	a1,s2
    80003fca:	8526                	mv	a0,s1
    80003fcc:	00001097          	auipc	ra,0x1
    80003fd0:	16c080e7          	jalr	364(ra) # 80005138 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003fd4:	08848493          	addi	s1,s1,136
    80003fd8:	ff3498e3          	bne	s1,s3,80003fc8 <iinit+0x3e>
}
    80003fdc:	70a2                	ld	ra,40(sp)
    80003fde:	7402                	ld	s0,32(sp)
    80003fe0:	64e2                	ld	s1,24(sp)
    80003fe2:	6942                	ld	s2,16(sp)
    80003fe4:	69a2                	ld	s3,8(sp)
    80003fe6:	6145                	addi	sp,sp,48
    80003fe8:	8082                	ret

0000000080003fea <ialloc>:
{
    80003fea:	715d                	addi	sp,sp,-80
    80003fec:	e486                	sd	ra,72(sp)
    80003fee:	e0a2                	sd	s0,64(sp)
    80003ff0:	fc26                	sd	s1,56(sp)
    80003ff2:	f84a                	sd	s2,48(sp)
    80003ff4:	f44e                	sd	s3,40(sp)
    80003ff6:	f052                	sd	s4,32(sp)
    80003ff8:	ec56                	sd	s5,24(sp)
    80003ffa:	e85a                	sd	s6,16(sp)
    80003ffc:	e45e                	sd	s7,8(sp)
    80003ffe:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80004000:	00025717          	auipc	a4,0x25
    80004004:	1b472703          	lw	a4,436(a4) # 800291b4 <sb+0xc>
    80004008:	4785                	li	a5,1
    8000400a:	04e7fa63          	bgeu	a5,a4,8000405e <ialloc+0x74>
    8000400e:	8aaa                	mv	s5,a0
    80004010:	8bae                	mv	s7,a1
    80004012:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004014:	00025a17          	auipc	s4,0x25
    80004018:	194a0a13          	addi	s4,s4,404 # 800291a8 <sb>
    8000401c:	00048b1b          	sext.w	s6,s1
    80004020:	0044d793          	srli	a5,s1,0x4
    80004024:	018a2583          	lw	a1,24(s4)
    80004028:	9dbd                	addw	a1,a1,a5
    8000402a:	8556                	mv	a0,s5
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	952080e7          	jalr	-1710(ra) # 8000397e <bread>
    80004034:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80004036:	05850993          	addi	s3,a0,88
    8000403a:	00f4f793          	andi	a5,s1,15
    8000403e:	079a                	slli	a5,a5,0x6
    80004040:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004042:	00099783          	lh	a5,0(s3)
    80004046:	c785                	beqz	a5,8000406e <ialloc+0x84>
    brelse(bp);
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	a66080e7          	jalr	-1434(ra) # 80003aae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004050:	0485                	addi	s1,s1,1
    80004052:	00ca2703          	lw	a4,12(s4)
    80004056:	0004879b          	sext.w	a5,s1
    8000405a:	fce7e1e3          	bltu	a5,a4,8000401c <ialloc+0x32>
  panic("ialloc: no inodes");
    8000405e:	00006517          	auipc	a0,0x6
    80004062:	bb250513          	addi	a0,a0,-1102 # 80009c10 <syscalls+0x168>
    80004066:	ffffc097          	auipc	ra,0xffffc
    8000406a:	4c4080e7          	jalr	1220(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    8000406e:	04000613          	li	a2,64
    80004072:	4581                	li	a1,0
    80004074:	854e                	mv	a0,s3
    80004076:	ffffd097          	auipc	ra,0xffffd
    8000407a:	c48080e7          	jalr	-952(ra) # 80000cbe <memset>
      dip->type = type;
    8000407e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004082:	854a                	mv	a0,s2
    80004084:	00001097          	auipc	ra,0x1
    80004088:	fce080e7          	jalr	-50(ra) # 80005052 <log_write>
      brelse(bp);
    8000408c:	854a                	mv	a0,s2
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	a20080e7          	jalr	-1504(ra) # 80003aae <brelse>
      return iget(dev, inum);
    80004096:	85da                	mv	a1,s6
    80004098:	8556                	mv	a0,s5
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	db4080e7          	jalr	-588(ra) # 80003e4e <iget>
}
    800040a2:	60a6                	ld	ra,72(sp)
    800040a4:	6406                	ld	s0,64(sp)
    800040a6:	74e2                	ld	s1,56(sp)
    800040a8:	7942                	ld	s2,48(sp)
    800040aa:	79a2                	ld	s3,40(sp)
    800040ac:	7a02                	ld	s4,32(sp)
    800040ae:	6ae2                	ld	s5,24(sp)
    800040b0:	6b42                	ld	s6,16(sp)
    800040b2:	6ba2                	ld	s7,8(sp)
    800040b4:	6161                	addi	sp,sp,80
    800040b6:	8082                	ret

00000000800040b8 <iupdate>:
{
    800040b8:	1101                	addi	sp,sp,-32
    800040ba:	ec06                	sd	ra,24(sp)
    800040bc:	e822                	sd	s0,16(sp)
    800040be:	e426                	sd	s1,8(sp)
    800040c0:	e04a                	sd	s2,0(sp)
    800040c2:	1000                	addi	s0,sp,32
    800040c4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040c6:	415c                	lw	a5,4(a0)
    800040c8:	0047d79b          	srliw	a5,a5,0x4
    800040cc:	00025597          	auipc	a1,0x25
    800040d0:	0f45a583          	lw	a1,244(a1) # 800291c0 <sb+0x18>
    800040d4:	9dbd                	addw	a1,a1,a5
    800040d6:	4108                	lw	a0,0(a0)
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	8a6080e7          	jalr	-1882(ra) # 8000397e <bread>
    800040e0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800040e2:	05850793          	addi	a5,a0,88
    800040e6:	40c8                	lw	a0,4(s1)
    800040e8:	893d                	andi	a0,a0,15
    800040ea:	051a                	slli	a0,a0,0x6
    800040ec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800040ee:	04449703          	lh	a4,68(s1)
    800040f2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800040f6:	04649703          	lh	a4,70(s1)
    800040fa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800040fe:	04849703          	lh	a4,72(s1)
    80004102:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004106:	04a49703          	lh	a4,74(s1)
    8000410a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000410e:	44f8                	lw	a4,76(s1)
    80004110:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004112:	03400613          	li	a2,52
    80004116:	05048593          	addi	a1,s1,80
    8000411a:	0531                	addi	a0,a0,12
    8000411c:	ffffd097          	auipc	ra,0xffffd
    80004120:	bfe080e7          	jalr	-1026(ra) # 80000d1a <memmove>
  log_write(bp);
    80004124:	854a                	mv	a0,s2
    80004126:	00001097          	auipc	ra,0x1
    8000412a:	f2c080e7          	jalr	-212(ra) # 80005052 <log_write>
  brelse(bp);
    8000412e:	854a                	mv	a0,s2
    80004130:	00000097          	auipc	ra,0x0
    80004134:	97e080e7          	jalr	-1666(ra) # 80003aae <brelse>
}
    80004138:	60e2                	ld	ra,24(sp)
    8000413a:	6442                	ld	s0,16(sp)
    8000413c:	64a2                	ld	s1,8(sp)
    8000413e:	6902                	ld	s2,0(sp)
    80004140:	6105                	addi	sp,sp,32
    80004142:	8082                	ret

0000000080004144 <idup>:
{
    80004144:	1101                	addi	sp,sp,-32
    80004146:	ec06                	sd	ra,24(sp)
    80004148:	e822                	sd	s0,16(sp)
    8000414a:	e426                	sd	s1,8(sp)
    8000414c:	1000                	addi	s0,sp,32
    8000414e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004150:	00025517          	auipc	a0,0x25
    80004154:	07850513          	addi	a0,a0,120 # 800291c8 <itable>
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	a6a080e7          	jalr	-1430(ra) # 80000bc2 <acquire>
  ip->ref++;
    80004160:	449c                	lw	a5,8(s1)
    80004162:	2785                	addiw	a5,a5,1
    80004164:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004166:	00025517          	auipc	a0,0x25
    8000416a:	06250513          	addi	a0,a0,98 # 800291c8 <itable>
    8000416e:	ffffd097          	auipc	ra,0xffffd
    80004172:	b08080e7          	jalr	-1272(ra) # 80000c76 <release>
}
    80004176:	8526                	mv	a0,s1
    80004178:	60e2                	ld	ra,24(sp)
    8000417a:	6442                	ld	s0,16(sp)
    8000417c:	64a2                	ld	s1,8(sp)
    8000417e:	6105                	addi	sp,sp,32
    80004180:	8082                	ret

0000000080004182 <ilock>:
{
    80004182:	1101                	addi	sp,sp,-32
    80004184:	ec06                	sd	ra,24(sp)
    80004186:	e822                	sd	s0,16(sp)
    80004188:	e426                	sd	s1,8(sp)
    8000418a:	e04a                	sd	s2,0(sp)
    8000418c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000418e:	c115                	beqz	a0,800041b2 <ilock+0x30>
    80004190:	84aa                	mv	s1,a0
    80004192:	451c                	lw	a5,8(a0)
    80004194:	00f05f63          	blez	a5,800041b2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80004198:	0541                	addi	a0,a0,16
    8000419a:	00001097          	auipc	ra,0x1
    8000419e:	fd8080e7          	jalr	-40(ra) # 80005172 <acquiresleep>
  if(ip->valid == 0){
    800041a2:	40bc                	lw	a5,64(s1)
    800041a4:	cf99                	beqz	a5,800041c2 <ilock+0x40>
}
    800041a6:	60e2                	ld	ra,24(sp)
    800041a8:	6442                	ld	s0,16(sp)
    800041aa:	64a2                	ld	s1,8(sp)
    800041ac:	6902                	ld	s2,0(sp)
    800041ae:	6105                	addi	sp,sp,32
    800041b0:	8082                	ret
    panic("ilock");
    800041b2:	00006517          	auipc	a0,0x6
    800041b6:	a7650513          	addi	a0,a0,-1418 # 80009c28 <syscalls+0x180>
    800041ba:	ffffc097          	auipc	ra,0xffffc
    800041be:	370080e7          	jalr	880(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800041c2:	40dc                	lw	a5,4(s1)
    800041c4:	0047d79b          	srliw	a5,a5,0x4
    800041c8:	00025597          	auipc	a1,0x25
    800041cc:	ff85a583          	lw	a1,-8(a1) # 800291c0 <sb+0x18>
    800041d0:	9dbd                	addw	a1,a1,a5
    800041d2:	4088                	lw	a0,0(s1)
    800041d4:	fffff097          	auipc	ra,0xfffff
    800041d8:	7aa080e7          	jalr	1962(ra) # 8000397e <bread>
    800041dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800041de:	05850593          	addi	a1,a0,88
    800041e2:	40dc                	lw	a5,4(s1)
    800041e4:	8bbd                	andi	a5,a5,15
    800041e6:	079a                	slli	a5,a5,0x6
    800041e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800041ea:	00059783          	lh	a5,0(a1)
    800041ee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800041f2:	00259783          	lh	a5,2(a1)
    800041f6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800041fa:	00459783          	lh	a5,4(a1)
    800041fe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004202:	00659783          	lh	a5,6(a1)
    80004206:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000420a:	459c                	lw	a5,8(a1)
    8000420c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000420e:	03400613          	li	a2,52
    80004212:	05b1                	addi	a1,a1,12
    80004214:	05048513          	addi	a0,s1,80
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	b02080e7          	jalr	-1278(ra) # 80000d1a <memmove>
    brelse(bp);
    80004220:	854a                	mv	a0,s2
    80004222:	00000097          	auipc	ra,0x0
    80004226:	88c080e7          	jalr	-1908(ra) # 80003aae <brelse>
    ip->valid = 1;
    8000422a:	4785                	li	a5,1
    8000422c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000422e:	04449783          	lh	a5,68(s1)
    80004232:	fbb5                	bnez	a5,800041a6 <ilock+0x24>
      panic("ilock: no type");
    80004234:	00006517          	auipc	a0,0x6
    80004238:	9fc50513          	addi	a0,a0,-1540 # 80009c30 <syscalls+0x188>
    8000423c:	ffffc097          	auipc	ra,0xffffc
    80004240:	2ee080e7          	jalr	750(ra) # 8000052a <panic>

0000000080004244 <iunlock>:
{
    80004244:	1101                	addi	sp,sp,-32
    80004246:	ec06                	sd	ra,24(sp)
    80004248:	e822                	sd	s0,16(sp)
    8000424a:	e426                	sd	s1,8(sp)
    8000424c:	e04a                	sd	s2,0(sp)
    8000424e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004250:	c905                	beqz	a0,80004280 <iunlock+0x3c>
    80004252:	84aa                	mv	s1,a0
    80004254:	01050913          	addi	s2,a0,16
    80004258:	854a                	mv	a0,s2
    8000425a:	00001097          	auipc	ra,0x1
    8000425e:	fb2080e7          	jalr	-78(ra) # 8000520c <holdingsleep>
    80004262:	cd19                	beqz	a0,80004280 <iunlock+0x3c>
    80004264:	449c                	lw	a5,8(s1)
    80004266:	00f05d63          	blez	a5,80004280 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000426a:	854a                	mv	a0,s2
    8000426c:	00001097          	auipc	ra,0x1
    80004270:	f5c080e7          	jalr	-164(ra) # 800051c8 <releasesleep>
}
    80004274:	60e2                	ld	ra,24(sp)
    80004276:	6442                	ld	s0,16(sp)
    80004278:	64a2                	ld	s1,8(sp)
    8000427a:	6902                	ld	s2,0(sp)
    8000427c:	6105                	addi	sp,sp,32
    8000427e:	8082                	ret
    panic("iunlock");
    80004280:	00006517          	auipc	a0,0x6
    80004284:	9c050513          	addi	a0,a0,-1600 # 80009c40 <syscalls+0x198>
    80004288:	ffffc097          	auipc	ra,0xffffc
    8000428c:	2a2080e7          	jalr	674(ra) # 8000052a <panic>

0000000080004290 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004290:	7179                	addi	sp,sp,-48
    80004292:	f406                	sd	ra,40(sp)
    80004294:	f022                	sd	s0,32(sp)
    80004296:	ec26                	sd	s1,24(sp)
    80004298:	e84a                	sd	s2,16(sp)
    8000429a:	e44e                	sd	s3,8(sp)
    8000429c:	e052                	sd	s4,0(sp)
    8000429e:	1800                	addi	s0,sp,48
    800042a0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800042a2:	05050493          	addi	s1,a0,80
    800042a6:	08050913          	addi	s2,a0,128
    800042aa:	a021                	j	800042b2 <itrunc+0x22>
    800042ac:	0491                	addi	s1,s1,4
    800042ae:	01248d63          	beq	s1,s2,800042c8 <itrunc+0x38>
    if(ip->addrs[i]){
    800042b2:	408c                	lw	a1,0(s1)
    800042b4:	dde5                	beqz	a1,800042ac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800042b6:	0009a503          	lw	a0,0(s3)
    800042ba:	00000097          	auipc	ra,0x0
    800042be:	90a080e7          	jalr	-1782(ra) # 80003bc4 <bfree>
      ip->addrs[i] = 0;
    800042c2:	0004a023          	sw	zero,0(s1)
    800042c6:	b7dd                	j	800042ac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800042c8:	0809a583          	lw	a1,128(s3)
    800042cc:	e185                	bnez	a1,800042ec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800042ce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800042d2:	854e                	mv	a0,s3
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	de4080e7          	jalr	-540(ra) # 800040b8 <iupdate>
}
    800042dc:	70a2                	ld	ra,40(sp)
    800042de:	7402                	ld	s0,32(sp)
    800042e0:	64e2                	ld	s1,24(sp)
    800042e2:	6942                	ld	s2,16(sp)
    800042e4:	69a2                	ld	s3,8(sp)
    800042e6:	6a02                	ld	s4,0(sp)
    800042e8:	6145                	addi	sp,sp,48
    800042ea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800042ec:	0009a503          	lw	a0,0(s3)
    800042f0:	fffff097          	auipc	ra,0xfffff
    800042f4:	68e080e7          	jalr	1678(ra) # 8000397e <bread>
    800042f8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800042fa:	05850493          	addi	s1,a0,88
    800042fe:	45850913          	addi	s2,a0,1112
    80004302:	a021                	j	8000430a <itrunc+0x7a>
    80004304:	0491                	addi	s1,s1,4
    80004306:	01248b63          	beq	s1,s2,8000431c <itrunc+0x8c>
      if(a[j])
    8000430a:	408c                	lw	a1,0(s1)
    8000430c:	dde5                	beqz	a1,80004304 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000430e:	0009a503          	lw	a0,0(s3)
    80004312:	00000097          	auipc	ra,0x0
    80004316:	8b2080e7          	jalr	-1870(ra) # 80003bc4 <bfree>
    8000431a:	b7ed                	j	80004304 <itrunc+0x74>
    brelse(bp);
    8000431c:	8552                	mv	a0,s4
    8000431e:	fffff097          	auipc	ra,0xfffff
    80004322:	790080e7          	jalr	1936(ra) # 80003aae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004326:	0809a583          	lw	a1,128(s3)
    8000432a:	0009a503          	lw	a0,0(s3)
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	896080e7          	jalr	-1898(ra) # 80003bc4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004336:	0809a023          	sw	zero,128(s3)
    8000433a:	bf51                	j	800042ce <itrunc+0x3e>

000000008000433c <iput>:
{
    8000433c:	1101                	addi	sp,sp,-32
    8000433e:	ec06                	sd	ra,24(sp)
    80004340:	e822                	sd	s0,16(sp)
    80004342:	e426                	sd	s1,8(sp)
    80004344:	e04a                	sd	s2,0(sp)
    80004346:	1000                	addi	s0,sp,32
    80004348:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000434a:	00025517          	auipc	a0,0x25
    8000434e:	e7e50513          	addi	a0,a0,-386 # 800291c8 <itable>
    80004352:	ffffd097          	auipc	ra,0xffffd
    80004356:	870080e7          	jalr	-1936(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000435a:	4498                	lw	a4,8(s1)
    8000435c:	4785                	li	a5,1
    8000435e:	02f70363          	beq	a4,a5,80004384 <iput+0x48>
  ip->ref--;
    80004362:	449c                	lw	a5,8(s1)
    80004364:	37fd                	addiw	a5,a5,-1
    80004366:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004368:	00025517          	auipc	a0,0x25
    8000436c:	e6050513          	addi	a0,a0,-416 # 800291c8 <itable>
    80004370:	ffffd097          	auipc	ra,0xffffd
    80004374:	906080e7          	jalr	-1786(ra) # 80000c76 <release>
}
    80004378:	60e2                	ld	ra,24(sp)
    8000437a:	6442                	ld	s0,16(sp)
    8000437c:	64a2                	ld	s1,8(sp)
    8000437e:	6902                	ld	s2,0(sp)
    80004380:	6105                	addi	sp,sp,32
    80004382:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004384:	40bc                	lw	a5,64(s1)
    80004386:	dff1                	beqz	a5,80004362 <iput+0x26>
    80004388:	04a49783          	lh	a5,74(s1)
    8000438c:	fbf9                	bnez	a5,80004362 <iput+0x26>
    acquiresleep(&ip->lock);
    8000438e:	01048913          	addi	s2,s1,16
    80004392:	854a                	mv	a0,s2
    80004394:	00001097          	auipc	ra,0x1
    80004398:	dde080e7          	jalr	-546(ra) # 80005172 <acquiresleep>
    release(&itable.lock);
    8000439c:	00025517          	auipc	a0,0x25
    800043a0:	e2c50513          	addi	a0,a0,-468 # 800291c8 <itable>
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	8d2080e7          	jalr	-1838(ra) # 80000c76 <release>
    itrunc(ip);
    800043ac:	8526                	mv	a0,s1
    800043ae:	00000097          	auipc	ra,0x0
    800043b2:	ee2080e7          	jalr	-286(ra) # 80004290 <itrunc>
    ip->type = 0;
    800043b6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800043ba:	8526                	mv	a0,s1
    800043bc:	00000097          	auipc	ra,0x0
    800043c0:	cfc080e7          	jalr	-772(ra) # 800040b8 <iupdate>
    ip->valid = 0;
    800043c4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800043c8:	854a                	mv	a0,s2
    800043ca:	00001097          	auipc	ra,0x1
    800043ce:	dfe080e7          	jalr	-514(ra) # 800051c8 <releasesleep>
    acquire(&itable.lock);
    800043d2:	00025517          	auipc	a0,0x25
    800043d6:	df650513          	addi	a0,a0,-522 # 800291c8 <itable>
    800043da:	ffffc097          	auipc	ra,0xffffc
    800043de:	7e8080e7          	jalr	2024(ra) # 80000bc2 <acquire>
    800043e2:	b741                	j	80004362 <iput+0x26>

00000000800043e4 <iunlockput>:
{
    800043e4:	1101                	addi	sp,sp,-32
    800043e6:	ec06                	sd	ra,24(sp)
    800043e8:	e822                	sd	s0,16(sp)
    800043ea:	e426                	sd	s1,8(sp)
    800043ec:	1000                	addi	s0,sp,32
    800043ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	e54080e7          	jalr	-428(ra) # 80004244 <iunlock>
  iput(ip);
    800043f8:	8526                	mv	a0,s1
    800043fa:	00000097          	auipc	ra,0x0
    800043fe:	f42080e7          	jalr	-190(ra) # 8000433c <iput>
}
    80004402:	60e2                	ld	ra,24(sp)
    80004404:	6442                	ld	s0,16(sp)
    80004406:	64a2                	ld	s1,8(sp)
    80004408:	6105                	addi	sp,sp,32
    8000440a:	8082                	ret

000000008000440c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000440c:	1141                	addi	sp,sp,-16
    8000440e:	e422                	sd	s0,8(sp)
    80004410:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004412:	411c                	lw	a5,0(a0)
    80004414:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004416:	415c                	lw	a5,4(a0)
    80004418:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000441a:	04451783          	lh	a5,68(a0)
    8000441e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004422:	04a51783          	lh	a5,74(a0)
    80004426:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000442a:	04c56783          	lwu	a5,76(a0)
    8000442e:	e99c                	sd	a5,16(a1)
}
    80004430:	6422                	ld	s0,8(sp)
    80004432:	0141                	addi	sp,sp,16
    80004434:	8082                	ret

0000000080004436 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004436:	457c                	lw	a5,76(a0)
    80004438:	0ed7e963          	bltu	a5,a3,8000452a <readi+0xf4>
{
    8000443c:	7159                	addi	sp,sp,-112
    8000443e:	f486                	sd	ra,104(sp)
    80004440:	f0a2                	sd	s0,96(sp)
    80004442:	eca6                	sd	s1,88(sp)
    80004444:	e8ca                	sd	s2,80(sp)
    80004446:	e4ce                	sd	s3,72(sp)
    80004448:	e0d2                	sd	s4,64(sp)
    8000444a:	fc56                	sd	s5,56(sp)
    8000444c:	f85a                	sd	s6,48(sp)
    8000444e:	f45e                	sd	s7,40(sp)
    80004450:	f062                	sd	s8,32(sp)
    80004452:	ec66                	sd	s9,24(sp)
    80004454:	e86a                	sd	s10,16(sp)
    80004456:	e46e                	sd	s11,8(sp)
    80004458:	1880                	addi	s0,sp,112
    8000445a:	8baa                	mv	s7,a0
    8000445c:	8c2e                	mv	s8,a1
    8000445e:	8ab2                	mv	s5,a2
    80004460:	84b6                	mv	s1,a3
    80004462:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004464:	9f35                	addw	a4,a4,a3
    return 0;
    80004466:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004468:	0ad76063          	bltu	a4,a3,80004508 <readi+0xd2>
  if(off + n > ip->size)
    8000446c:	00e7f463          	bgeu	a5,a4,80004474 <readi+0x3e>
    n = ip->size - off;
    80004470:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004474:	0a0b0963          	beqz	s6,80004526 <readi+0xf0>
    80004478:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000447a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000447e:	5cfd                	li	s9,-1
    80004480:	a82d                	j	800044ba <readi+0x84>
    80004482:	020a1d93          	slli	s11,s4,0x20
    80004486:	020ddd93          	srli	s11,s11,0x20
    8000448a:	05890793          	addi	a5,s2,88
    8000448e:	86ee                	mv	a3,s11
    80004490:	963e                	add	a2,a2,a5
    80004492:	85d6                	mv	a1,s5
    80004494:	8562                	mv	a0,s8
    80004496:	ffffe097          	auipc	ra,0xffffe
    8000449a:	140080e7          	jalr	320(ra) # 800025d6 <either_copyout>
    8000449e:	05950d63          	beq	a0,s9,800044f8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800044a2:	854a                	mv	a0,s2
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	60a080e7          	jalr	1546(ra) # 80003aae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800044ac:	013a09bb          	addw	s3,s4,s3
    800044b0:	009a04bb          	addw	s1,s4,s1
    800044b4:	9aee                	add	s5,s5,s11
    800044b6:	0569f763          	bgeu	s3,s6,80004504 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800044ba:	000ba903          	lw	s2,0(s7)
    800044be:	00a4d59b          	srliw	a1,s1,0xa
    800044c2:	855e                	mv	a0,s7
    800044c4:	00000097          	auipc	ra,0x0
    800044c8:	8ae080e7          	jalr	-1874(ra) # 80003d72 <bmap>
    800044cc:	0005059b          	sext.w	a1,a0
    800044d0:	854a                	mv	a0,s2
    800044d2:	fffff097          	auipc	ra,0xfffff
    800044d6:	4ac080e7          	jalr	1196(ra) # 8000397e <bread>
    800044da:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044dc:	3ff4f613          	andi	a2,s1,1023
    800044e0:	40cd07bb          	subw	a5,s10,a2
    800044e4:	413b073b          	subw	a4,s6,s3
    800044e8:	8a3e                	mv	s4,a5
    800044ea:	2781                	sext.w	a5,a5
    800044ec:	0007069b          	sext.w	a3,a4
    800044f0:	f8f6f9e3          	bgeu	a3,a5,80004482 <readi+0x4c>
    800044f4:	8a3a                	mv	s4,a4
    800044f6:	b771                	j	80004482 <readi+0x4c>
      brelse(bp);
    800044f8:	854a                	mv	a0,s2
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	5b4080e7          	jalr	1460(ra) # 80003aae <brelse>
      tot = -1;
    80004502:	59fd                	li	s3,-1
  }
  return tot;
    80004504:	0009851b          	sext.w	a0,s3
}
    80004508:	70a6                	ld	ra,104(sp)
    8000450a:	7406                	ld	s0,96(sp)
    8000450c:	64e6                	ld	s1,88(sp)
    8000450e:	6946                	ld	s2,80(sp)
    80004510:	69a6                	ld	s3,72(sp)
    80004512:	6a06                	ld	s4,64(sp)
    80004514:	7ae2                	ld	s5,56(sp)
    80004516:	7b42                	ld	s6,48(sp)
    80004518:	7ba2                	ld	s7,40(sp)
    8000451a:	7c02                	ld	s8,32(sp)
    8000451c:	6ce2                	ld	s9,24(sp)
    8000451e:	6d42                	ld	s10,16(sp)
    80004520:	6da2                	ld	s11,8(sp)
    80004522:	6165                	addi	sp,sp,112
    80004524:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004526:	89da                	mv	s3,s6
    80004528:	bff1                	j	80004504 <readi+0xce>
    return 0;
    8000452a:	4501                	li	a0,0
}
    8000452c:	8082                	ret

000000008000452e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000452e:	457c                	lw	a5,76(a0)
    80004530:	10d7e863          	bltu	a5,a3,80004640 <writei+0x112>
{
    80004534:	7159                	addi	sp,sp,-112
    80004536:	f486                	sd	ra,104(sp)
    80004538:	f0a2                	sd	s0,96(sp)
    8000453a:	eca6                	sd	s1,88(sp)
    8000453c:	e8ca                	sd	s2,80(sp)
    8000453e:	e4ce                	sd	s3,72(sp)
    80004540:	e0d2                	sd	s4,64(sp)
    80004542:	fc56                	sd	s5,56(sp)
    80004544:	f85a                	sd	s6,48(sp)
    80004546:	f45e                	sd	s7,40(sp)
    80004548:	f062                	sd	s8,32(sp)
    8000454a:	ec66                	sd	s9,24(sp)
    8000454c:	e86a                	sd	s10,16(sp)
    8000454e:	e46e                	sd	s11,8(sp)
    80004550:	1880                	addi	s0,sp,112
    80004552:	8b2a                	mv	s6,a0
    80004554:	8c2e                	mv	s8,a1
    80004556:	8ab2                	mv	s5,a2
    80004558:	8936                	mv	s2,a3
    8000455a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000455c:	00e687bb          	addw	a5,a3,a4
    80004560:	0ed7e263          	bltu	a5,a3,80004644 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004564:	00043737          	lui	a4,0x43
    80004568:	0ef76063          	bltu	a4,a5,80004648 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000456c:	0c0b8863          	beqz	s7,8000463c <writei+0x10e>
    80004570:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004572:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004576:	5cfd                	li	s9,-1
    80004578:	a091                	j	800045bc <writei+0x8e>
    8000457a:	02099d93          	slli	s11,s3,0x20
    8000457e:	020ddd93          	srli	s11,s11,0x20
    80004582:	05848793          	addi	a5,s1,88
    80004586:	86ee                	mv	a3,s11
    80004588:	8656                	mv	a2,s5
    8000458a:	85e2                	mv	a1,s8
    8000458c:	953e                	add	a0,a0,a5
    8000458e:	ffffe097          	auipc	ra,0xffffe
    80004592:	09e080e7          	jalr	158(ra) # 8000262c <either_copyin>
    80004596:	07950263          	beq	a0,s9,800045fa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000459a:	8526                	mv	a0,s1
    8000459c:	00001097          	auipc	ra,0x1
    800045a0:	ab6080e7          	jalr	-1354(ra) # 80005052 <log_write>
    brelse(bp);
    800045a4:	8526                	mv	a0,s1
    800045a6:	fffff097          	auipc	ra,0xfffff
    800045aa:	508080e7          	jalr	1288(ra) # 80003aae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800045ae:	01498a3b          	addw	s4,s3,s4
    800045b2:	0129893b          	addw	s2,s3,s2
    800045b6:	9aee                	add	s5,s5,s11
    800045b8:	057a7663          	bgeu	s4,s7,80004604 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800045bc:	000b2483          	lw	s1,0(s6)
    800045c0:	00a9559b          	srliw	a1,s2,0xa
    800045c4:	855a                	mv	a0,s6
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	7ac080e7          	jalr	1964(ra) # 80003d72 <bmap>
    800045ce:	0005059b          	sext.w	a1,a0
    800045d2:	8526                	mv	a0,s1
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	3aa080e7          	jalr	938(ra) # 8000397e <bread>
    800045dc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800045de:	3ff97513          	andi	a0,s2,1023
    800045e2:	40ad07bb          	subw	a5,s10,a0
    800045e6:	414b873b          	subw	a4,s7,s4
    800045ea:	89be                	mv	s3,a5
    800045ec:	2781                	sext.w	a5,a5
    800045ee:	0007069b          	sext.w	a3,a4
    800045f2:	f8f6f4e3          	bgeu	a3,a5,8000457a <writei+0x4c>
    800045f6:	89ba                	mv	s3,a4
    800045f8:	b749                	j	8000457a <writei+0x4c>
      brelse(bp);
    800045fa:	8526                	mv	a0,s1
    800045fc:	fffff097          	auipc	ra,0xfffff
    80004600:	4b2080e7          	jalr	1202(ra) # 80003aae <brelse>
  }

  if(off > ip->size)
    80004604:	04cb2783          	lw	a5,76(s6)
    80004608:	0127f463          	bgeu	a5,s2,80004610 <writei+0xe2>
    ip->size = off;
    8000460c:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004610:	855a                	mv	a0,s6
    80004612:	00000097          	auipc	ra,0x0
    80004616:	aa6080e7          	jalr	-1370(ra) # 800040b8 <iupdate>

  return tot;
    8000461a:	000a051b          	sext.w	a0,s4
}
    8000461e:	70a6                	ld	ra,104(sp)
    80004620:	7406                	ld	s0,96(sp)
    80004622:	64e6                	ld	s1,88(sp)
    80004624:	6946                	ld	s2,80(sp)
    80004626:	69a6                	ld	s3,72(sp)
    80004628:	6a06                	ld	s4,64(sp)
    8000462a:	7ae2                	ld	s5,56(sp)
    8000462c:	7b42                	ld	s6,48(sp)
    8000462e:	7ba2                	ld	s7,40(sp)
    80004630:	7c02                	ld	s8,32(sp)
    80004632:	6ce2                	ld	s9,24(sp)
    80004634:	6d42                	ld	s10,16(sp)
    80004636:	6da2                	ld	s11,8(sp)
    80004638:	6165                	addi	sp,sp,112
    8000463a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000463c:	8a5e                	mv	s4,s7
    8000463e:	bfc9                	j	80004610 <writei+0xe2>
    return -1;
    80004640:	557d                	li	a0,-1
}
    80004642:	8082                	ret
    return -1;
    80004644:	557d                	li	a0,-1
    80004646:	bfe1                	j	8000461e <writei+0xf0>
    return -1;
    80004648:	557d                	li	a0,-1
    8000464a:	bfd1                	j	8000461e <writei+0xf0>

000000008000464c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000464c:	1141                	addi	sp,sp,-16
    8000464e:	e406                	sd	ra,8(sp)
    80004650:	e022                	sd	s0,0(sp)
    80004652:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004654:	4639                	li	a2,14
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	740080e7          	jalr	1856(ra) # 80000d96 <strncmp>
}
    8000465e:	60a2                	ld	ra,8(sp)
    80004660:	6402                	ld	s0,0(sp)
    80004662:	0141                	addi	sp,sp,16
    80004664:	8082                	ret

0000000080004666 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004666:	7139                	addi	sp,sp,-64
    80004668:	fc06                	sd	ra,56(sp)
    8000466a:	f822                	sd	s0,48(sp)
    8000466c:	f426                	sd	s1,40(sp)
    8000466e:	f04a                	sd	s2,32(sp)
    80004670:	ec4e                	sd	s3,24(sp)
    80004672:	e852                	sd	s4,16(sp)
    80004674:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004676:	04451703          	lh	a4,68(a0)
    8000467a:	4785                	li	a5,1
    8000467c:	00f71a63          	bne	a4,a5,80004690 <dirlookup+0x2a>
    80004680:	892a                	mv	s2,a0
    80004682:	89ae                	mv	s3,a1
    80004684:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004686:	457c                	lw	a5,76(a0)
    80004688:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000468a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000468c:	e79d                	bnez	a5,800046ba <dirlookup+0x54>
    8000468e:	a8a5                	j	80004706 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004690:	00005517          	auipc	a0,0x5
    80004694:	5b850513          	addi	a0,a0,1464 # 80009c48 <syscalls+0x1a0>
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	e92080e7          	jalr	-366(ra) # 8000052a <panic>
      panic("dirlookup read");
    800046a0:	00005517          	auipc	a0,0x5
    800046a4:	5c050513          	addi	a0,a0,1472 # 80009c60 <syscalls+0x1b8>
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	e82080e7          	jalr	-382(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046b0:	24c1                	addiw	s1,s1,16
    800046b2:	04c92783          	lw	a5,76(s2)
    800046b6:	04f4f763          	bgeu	s1,a5,80004704 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046ba:	4741                	li	a4,16
    800046bc:	86a6                	mv	a3,s1
    800046be:	fc040613          	addi	a2,s0,-64
    800046c2:	4581                	li	a1,0
    800046c4:	854a                	mv	a0,s2
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	d70080e7          	jalr	-656(ra) # 80004436 <readi>
    800046ce:	47c1                	li	a5,16
    800046d0:	fcf518e3          	bne	a0,a5,800046a0 <dirlookup+0x3a>
    if(de.inum == 0)
    800046d4:	fc045783          	lhu	a5,-64(s0)
    800046d8:	dfe1                	beqz	a5,800046b0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800046da:	fc240593          	addi	a1,s0,-62
    800046de:	854e                	mv	a0,s3
    800046e0:	00000097          	auipc	ra,0x0
    800046e4:	f6c080e7          	jalr	-148(ra) # 8000464c <namecmp>
    800046e8:	f561                	bnez	a0,800046b0 <dirlookup+0x4a>
      if(poff)
    800046ea:	000a0463          	beqz	s4,800046f2 <dirlookup+0x8c>
        *poff = off;
    800046ee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800046f2:	fc045583          	lhu	a1,-64(s0)
    800046f6:	00092503          	lw	a0,0(s2)
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	754080e7          	jalr	1876(ra) # 80003e4e <iget>
    80004702:	a011                	j	80004706 <dirlookup+0xa0>
  return 0;
    80004704:	4501                	li	a0,0
}
    80004706:	70e2                	ld	ra,56(sp)
    80004708:	7442                	ld	s0,48(sp)
    8000470a:	74a2                	ld	s1,40(sp)
    8000470c:	7902                	ld	s2,32(sp)
    8000470e:	69e2                	ld	s3,24(sp)
    80004710:	6a42                	ld	s4,16(sp)
    80004712:	6121                	addi	sp,sp,64
    80004714:	8082                	ret

0000000080004716 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004716:	711d                	addi	sp,sp,-96
    80004718:	ec86                	sd	ra,88(sp)
    8000471a:	e8a2                	sd	s0,80(sp)
    8000471c:	e4a6                	sd	s1,72(sp)
    8000471e:	e0ca                	sd	s2,64(sp)
    80004720:	fc4e                	sd	s3,56(sp)
    80004722:	f852                	sd	s4,48(sp)
    80004724:	f456                	sd	s5,40(sp)
    80004726:	f05a                	sd	s6,32(sp)
    80004728:	ec5e                	sd	s7,24(sp)
    8000472a:	e862                	sd	s8,16(sp)
    8000472c:	e466                	sd	s9,8(sp)
    8000472e:	1080                	addi	s0,sp,96
    80004730:	84aa                	mv	s1,a0
    80004732:	8aae                	mv	s5,a1
    80004734:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004736:	00054703          	lbu	a4,0(a0)
    8000473a:	02f00793          	li	a5,47
    8000473e:	02f70363          	beq	a4,a5,80004764 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004742:	ffffd097          	auipc	ra,0xffffd
    80004746:	5ee080e7          	jalr	1518(ra) # 80001d30 <myproc>
    8000474a:	15053503          	ld	a0,336(a0)
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	9f6080e7          	jalr	-1546(ra) # 80004144 <idup>
    80004756:	89aa                	mv	s3,a0
  while(*path == '/')
    80004758:	02f00913          	li	s2,47
  len = path - s;
    8000475c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000475e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004760:	4b85                	li	s7,1
    80004762:	a865                	j	8000481a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004764:	4585                	li	a1,1
    80004766:	4505                	li	a0,1
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	6e6080e7          	jalr	1766(ra) # 80003e4e <iget>
    80004770:	89aa                	mv	s3,a0
    80004772:	b7dd                	j	80004758 <namex+0x42>
      iunlockput(ip);
    80004774:	854e                	mv	a0,s3
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	c6e080e7          	jalr	-914(ra) # 800043e4 <iunlockput>
      return 0;
    8000477e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004780:	854e                	mv	a0,s3
    80004782:	60e6                	ld	ra,88(sp)
    80004784:	6446                	ld	s0,80(sp)
    80004786:	64a6                	ld	s1,72(sp)
    80004788:	6906                	ld	s2,64(sp)
    8000478a:	79e2                	ld	s3,56(sp)
    8000478c:	7a42                	ld	s4,48(sp)
    8000478e:	7aa2                	ld	s5,40(sp)
    80004790:	7b02                	ld	s6,32(sp)
    80004792:	6be2                	ld	s7,24(sp)
    80004794:	6c42                	ld	s8,16(sp)
    80004796:	6ca2                	ld	s9,8(sp)
    80004798:	6125                	addi	sp,sp,96
    8000479a:	8082                	ret
      iunlock(ip);
    8000479c:	854e                	mv	a0,s3
    8000479e:	00000097          	auipc	ra,0x0
    800047a2:	aa6080e7          	jalr	-1370(ra) # 80004244 <iunlock>
      return ip;
    800047a6:	bfe9                	j	80004780 <namex+0x6a>
      iunlockput(ip);
    800047a8:	854e                	mv	a0,s3
    800047aa:	00000097          	auipc	ra,0x0
    800047ae:	c3a080e7          	jalr	-966(ra) # 800043e4 <iunlockput>
      return 0;
    800047b2:	89e6                	mv	s3,s9
    800047b4:	b7f1                	j	80004780 <namex+0x6a>
  len = path - s;
    800047b6:	40b48633          	sub	a2,s1,a1
    800047ba:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800047be:	099c5463          	bge	s8,s9,80004846 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800047c2:	4639                	li	a2,14
    800047c4:	8552                	mv	a0,s4
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	554080e7          	jalr	1364(ra) # 80000d1a <memmove>
  while(*path == '/')
    800047ce:	0004c783          	lbu	a5,0(s1)
    800047d2:	01279763          	bne	a5,s2,800047e0 <namex+0xca>
    path++;
    800047d6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800047d8:	0004c783          	lbu	a5,0(s1)
    800047dc:	ff278de3          	beq	a5,s2,800047d6 <namex+0xc0>
    ilock(ip);
    800047e0:	854e                	mv	a0,s3
    800047e2:	00000097          	auipc	ra,0x0
    800047e6:	9a0080e7          	jalr	-1632(ra) # 80004182 <ilock>
    if(ip->type != T_DIR){
    800047ea:	04499783          	lh	a5,68(s3)
    800047ee:	f97793e3          	bne	a5,s7,80004774 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800047f2:	000a8563          	beqz	s5,800047fc <namex+0xe6>
    800047f6:	0004c783          	lbu	a5,0(s1)
    800047fa:	d3cd                	beqz	a5,8000479c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800047fc:	865a                	mv	a2,s6
    800047fe:	85d2                	mv	a1,s4
    80004800:	854e                	mv	a0,s3
    80004802:	00000097          	auipc	ra,0x0
    80004806:	e64080e7          	jalr	-412(ra) # 80004666 <dirlookup>
    8000480a:	8caa                	mv	s9,a0
    8000480c:	dd51                	beqz	a0,800047a8 <namex+0x92>
    iunlockput(ip);
    8000480e:	854e                	mv	a0,s3
    80004810:	00000097          	auipc	ra,0x0
    80004814:	bd4080e7          	jalr	-1068(ra) # 800043e4 <iunlockput>
    ip = next;
    80004818:	89e6                	mv	s3,s9
  while(*path == '/')
    8000481a:	0004c783          	lbu	a5,0(s1)
    8000481e:	05279763          	bne	a5,s2,8000486c <namex+0x156>
    path++;
    80004822:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004824:	0004c783          	lbu	a5,0(s1)
    80004828:	ff278de3          	beq	a5,s2,80004822 <namex+0x10c>
  if(*path == 0)
    8000482c:	c79d                	beqz	a5,8000485a <namex+0x144>
    path++;
    8000482e:	85a6                	mv	a1,s1
  len = path - s;
    80004830:	8cda                	mv	s9,s6
    80004832:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004834:	01278963          	beq	a5,s2,80004846 <namex+0x130>
    80004838:	dfbd                	beqz	a5,800047b6 <namex+0xa0>
    path++;
    8000483a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000483c:	0004c783          	lbu	a5,0(s1)
    80004840:	ff279ce3          	bne	a5,s2,80004838 <namex+0x122>
    80004844:	bf8d                	j	800047b6 <namex+0xa0>
    memmove(name, s, len);
    80004846:	2601                	sext.w	a2,a2
    80004848:	8552                	mv	a0,s4
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	4d0080e7          	jalr	1232(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004852:	9cd2                	add	s9,s9,s4
    80004854:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004858:	bf9d                	j	800047ce <namex+0xb8>
  if(nameiparent){
    8000485a:	f20a83e3          	beqz	s5,80004780 <namex+0x6a>
    iput(ip);
    8000485e:	854e                	mv	a0,s3
    80004860:	00000097          	auipc	ra,0x0
    80004864:	adc080e7          	jalr	-1316(ra) # 8000433c <iput>
    return 0;
    80004868:	4981                	li	s3,0
    8000486a:	bf19                	j	80004780 <namex+0x6a>
  if(*path == 0)
    8000486c:	d7fd                	beqz	a5,8000485a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000486e:	0004c783          	lbu	a5,0(s1)
    80004872:	85a6                	mv	a1,s1
    80004874:	b7d1                	j	80004838 <namex+0x122>

0000000080004876 <dirlink>:
{
    80004876:	7139                	addi	sp,sp,-64
    80004878:	fc06                	sd	ra,56(sp)
    8000487a:	f822                	sd	s0,48(sp)
    8000487c:	f426                	sd	s1,40(sp)
    8000487e:	f04a                	sd	s2,32(sp)
    80004880:	ec4e                	sd	s3,24(sp)
    80004882:	e852                	sd	s4,16(sp)
    80004884:	0080                	addi	s0,sp,64
    80004886:	892a                	mv	s2,a0
    80004888:	8a2e                	mv	s4,a1
    8000488a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000488c:	4601                	li	a2,0
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	dd8080e7          	jalr	-552(ra) # 80004666 <dirlookup>
    80004896:	e93d                	bnez	a0,8000490c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004898:	04c92483          	lw	s1,76(s2)
    8000489c:	c49d                	beqz	s1,800048ca <dirlink+0x54>
    8000489e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048a0:	4741                	li	a4,16
    800048a2:	86a6                	mv	a3,s1
    800048a4:	fc040613          	addi	a2,s0,-64
    800048a8:	4581                	li	a1,0
    800048aa:	854a                	mv	a0,s2
    800048ac:	00000097          	auipc	ra,0x0
    800048b0:	b8a080e7          	jalr	-1142(ra) # 80004436 <readi>
    800048b4:	47c1                	li	a5,16
    800048b6:	06f51163          	bne	a0,a5,80004918 <dirlink+0xa2>
    if(de.inum == 0)
    800048ba:	fc045783          	lhu	a5,-64(s0)
    800048be:	c791                	beqz	a5,800048ca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800048c0:	24c1                	addiw	s1,s1,16
    800048c2:	04c92783          	lw	a5,76(s2)
    800048c6:	fcf4ede3          	bltu	s1,a5,800048a0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800048ca:	4639                	li	a2,14
    800048cc:	85d2                	mv	a1,s4
    800048ce:	fc240513          	addi	a0,s0,-62
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	500080e7          	jalr	1280(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800048da:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048de:	4741                	li	a4,16
    800048e0:	86a6                	mv	a3,s1
    800048e2:	fc040613          	addi	a2,s0,-64
    800048e6:	4581                	li	a1,0
    800048e8:	854a                	mv	a0,s2
    800048ea:	00000097          	auipc	ra,0x0
    800048ee:	c44080e7          	jalr	-956(ra) # 8000452e <writei>
    800048f2:	872a                	mv	a4,a0
    800048f4:	47c1                	li	a5,16
  return 0;
    800048f6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800048f8:	02f71863          	bne	a4,a5,80004928 <dirlink+0xb2>
}
    800048fc:	70e2                	ld	ra,56(sp)
    800048fe:	7442                	ld	s0,48(sp)
    80004900:	74a2                	ld	s1,40(sp)
    80004902:	7902                	ld	s2,32(sp)
    80004904:	69e2                	ld	s3,24(sp)
    80004906:	6a42                	ld	s4,16(sp)
    80004908:	6121                	addi	sp,sp,64
    8000490a:	8082                	ret
    iput(ip);
    8000490c:	00000097          	auipc	ra,0x0
    80004910:	a30080e7          	jalr	-1488(ra) # 8000433c <iput>
    return -1;
    80004914:	557d                	li	a0,-1
    80004916:	b7dd                	j	800048fc <dirlink+0x86>
      panic("dirlink read");
    80004918:	00005517          	auipc	a0,0x5
    8000491c:	35850513          	addi	a0,a0,856 # 80009c70 <syscalls+0x1c8>
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	c0a080e7          	jalr	-1014(ra) # 8000052a <panic>
    panic("dirlink");
    80004928:	00005517          	auipc	a0,0x5
    8000492c:	54850513          	addi	a0,a0,1352 # 80009e70 <syscalls+0x3c8>
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	bfa080e7          	jalr	-1030(ra) # 8000052a <panic>

0000000080004938 <namei>:

struct inode*
namei(char *path)
{
    80004938:	1101                	addi	sp,sp,-32
    8000493a:	ec06                	sd	ra,24(sp)
    8000493c:	e822                	sd	s0,16(sp)
    8000493e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004940:	fe040613          	addi	a2,s0,-32
    80004944:	4581                	li	a1,0
    80004946:	00000097          	auipc	ra,0x0
    8000494a:	dd0080e7          	jalr	-560(ra) # 80004716 <namex>
}
    8000494e:	60e2                	ld	ra,24(sp)
    80004950:	6442                	ld	s0,16(sp)
    80004952:	6105                	addi	sp,sp,32
    80004954:	8082                	ret

0000000080004956 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004956:	1141                	addi	sp,sp,-16
    80004958:	e406                	sd	ra,8(sp)
    8000495a:	e022                	sd	s0,0(sp)
    8000495c:	0800                	addi	s0,sp,16
    8000495e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004960:	4585                	li	a1,1
    80004962:	00000097          	auipc	ra,0x0
    80004966:	db4080e7          	jalr	-588(ra) # 80004716 <namex>
}
    8000496a:	60a2                	ld	ra,8(sp)
    8000496c:	6402                	ld	s0,0(sp)
    8000496e:	0141                	addi	sp,sp,16
    80004970:	8082                	ret

0000000080004972 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004972:	1101                	addi	sp,sp,-32
    80004974:	ec22                	sd	s0,24(sp)
    80004976:	1000                	addi	s0,sp,32
    80004978:	872a                	mv	a4,a0
    8000497a:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    8000497c:	00005797          	auipc	a5,0x5
    80004980:	30478793          	addi	a5,a5,772 # 80009c80 <syscalls+0x1d8>
    80004984:	6394                	ld	a3,0(a5)
    80004986:	fed43023          	sd	a3,-32(s0)
    8000498a:	0087d683          	lhu	a3,8(a5)
    8000498e:	fed41423          	sh	a3,-24(s0)
    80004992:	00a7c783          	lbu	a5,10(a5)
    80004996:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    8000499a:	87ae                	mv	a5,a1
    if(i<0){
    8000499c:	02074b63          	bltz	a4,800049d2 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800049a0:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800049a2:	4629                	li	a2,10
        ++p;
    800049a4:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800049a6:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800049aa:	feed                	bnez	a3,800049a4 <itoa+0x32>
    *p = '\0';
    800049ac:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800049b0:	4629                	li	a2,10
    800049b2:	17fd                	addi	a5,a5,-1
    800049b4:	02c766bb          	remw	a3,a4,a2
    800049b8:	ff040593          	addi	a1,s0,-16
    800049bc:	96ae                	add	a3,a3,a1
    800049be:	ff06c683          	lbu	a3,-16(a3)
    800049c2:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800049c6:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800049ca:	f765                	bnez	a4,800049b2 <itoa+0x40>
    return b;
}
    800049cc:	6462                	ld	s0,24(sp)
    800049ce:	6105                	addi	sp,sp,32
    800049d0:	8082                	ret
        *p++ = '-';
    800049d2:	00158793          	addi	a5,a1,1
    800049d6:	02d00693          	li	a3,45
    800049da:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800049de:	40e0073b          	negw	a4,a4
    800049e2:	bf7d                	j	800049a0 <itoa+0x2e>

00000000800049e4 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800049e4:	711d                	addi	sp,sp,-96
    800049e6:	ec86                	sd	ra,88(sp)
    800049e8:	e8a2                	sd	s0,80(sp)
    800049ea:	e4a6                	sd	s1,72(sp)
    800049ec:	e0ca                	sd	s2,64(sp)
    800049ee:	1080                	addi	s0,sp,96
    800049f0:	84aa                	mv	s1,a0
    printf("in RemoveSwapFile\n"); //TODO: delete
    800049f2:	00005517          	auipc	a0,0x5
    800049f6:	29e50513          	addi	a0,a0,670 # 80009c90 <syscalls+0x1e8>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	b7a080e7          	jalr	-1158(ra) # 80000574 <printf>

  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004a02:	4619                	li	a2,6
    80004a04:	00005597          	auipc	a1,0x5
    80004a08:	2a458593          	addi	a1,a1,676 # 80009ca8 <syscalls+0x200>
    80004a0c:	fd040513          	addi	a0,s0,-48
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	30a080e7          	jalr	778(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004a18:	fd640593          	addi	a1,s0,-42
    80004a1c:	5888                	lw	a0,48(s1)
    80004a1e:	00000097          	auipc	ra,0x0
    80004a22:	f54080e7          	jalr	-172(ra) # 80004972 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    80004a26:	1684b503          	ld	a0,360(s1)
    80004a2a:	16050763          	beqz	a0,80004b98 <removeSwapFile+0x1b4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004a2e:	00001097          	auipc	ra,0x1
    80004a32:	918080e7          	jalr	-1768(ra) # 80005346 <fileclose>

  begin_op();
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	444080e7          	jalr	1092(ra) # 80004e7a <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004a3e:	fb040593          	addi	a1,s0,-80
    80004a42:	fd040513          	addi	a0,s0,-48
    80004a46:	00000097          	auipc	ra,0x0
    80004a4a:	f10080e7          	jalr	-240(ra) # 80004956 <nameiparent>
    80004a4e:	892a                	mv	s2,a0
    80004a50:	cd69                	beqz	a0,80004b2a <removeSwapFile+0x146>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004a52:	fffff097          	auipc	ra,0xfffff
    80004a56:	730080e7          	jalr	1840(ra) # 80004182 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a5a:	00005597          	auipc	a1,0x5
    80004a5e:	25658593          	addi	a1,a1,598 # 80009cb0 <syscalls+0x208>
    80004a62:	fb040513          	addi	a0,s0,-80
    80004a66:	00000097          	auipc	ra,0x0
    80004a6a:	be6080e7          	jalr	-1050(ra) # 8000464c <namecmp>
    80004a6e:	c57d                	beqz	a0,80004b5c <removeSwapFile+0x178>
    80004a70:	00005597          	auipc	a1,0x5
    80004a74:	24858593          	addi	a1,a1,584 # 80009cb8 <syscalls+0x210>
    80004a78:	fb040513          	addi	a0,s0,-80
    80004a7c:	00000097          	auipc	ra,0x0
    80004a80:	bd0080e7          	jalr	-1072(ra) # 8000464c <namecmp>
    80004a84:	cd61                	beqz	a0,80004b5c <removeSwapFile+0x178>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80004a86:	fac40613          	addi	a2,s0,-84
    80004a8a:	fb040593          	addi	a1,s0,-80
    80004a8e:	854a                	mv	a0,s2
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	bd6080e7          	jalr	-1066(ra) # 80004666 <dirlookup>
    80004a98:	84aa                	mv	s1,a0
    80004a9a:	c169                	beqz	a0,80004b5c <removeSwapFile+0x178>
    goto bad;
  ilock(ip);
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	6e6080e7          	jalr	1766(ra) # 80004182 <ilock>

  if(ip->nlink < 1)
    80004aa4:	04a49783          	lh	a5,74(s1)
    80004aa8:	08f05763          	blez	a5,80004b36 <removeSwapFile+0x152>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004aac:	04449703          	lh	a4,68(s1)
    80004ab0:	4785                	li	a5,1
    80004ab2:	08f70a63          	beq	a4,a5,80004b46 <removeSwapFile+0x162>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80004ab6:	4641                	li	a2,16
    80004ab8:	4581                	li	a1,0
    80004aba:	fc040513          	addi	a0,s0,-64
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	200080e7          	jalr	512(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ac6:	4741                	li	a4,16
    80004ac8:	fac42683          	lw	a3,-84(s0)
    80004acc:	fc040613          	addi	a2,s0,-64
    80004ad0:	4581                	li	a1,0
    80004ad2:	854a                	mv	a0,s2
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	a5a080e7          	jalr	-1446(ra) # 8000452e <writei>
    80004adc:	47c1                	li	a5,16
    80004ade:	08f51a63          	bne	a0,a5,80004b72 <removeSwapFile+0x18e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80004ae2:	04449703          	lh	a4,68(s1)
    80004ae6:	4785                	li	a5,1
    80004ae8:	08f70d63          	beq	a4,a5,80004b82 <removeSwapFile+0x19e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80004aec:	854a                	mv	a0,s2
    80004aee:	00000097          	auipc	ra,0x0
    80004af2:	8f6080e7          	jalr	-1802(ra) # 800043e4 <iunlockput>

  ip->nlink--;
    80004af6:	04a4d783          	lhu	a5,74(s1)
    80004afa:	37fd                	addiw	a5,a5,-1
    80004afc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b00:	8526                	mv	a0,s1
    80004b02:	fffff097          	auipc	ra,0xfffff
    80004b06:	5b6080e7          	jalr	1462(ra) # 800040b8 <iupdate>
  iunlockput(ip);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	00000097          	auipc	ra,0x0
    80004b10:	8d8080e7          	jalr	-1832(ra) # 800043e4 <iunlockput>

  end_op();
    80004b14:	00000097          	auipc	ra,0x0
    80004b18:	3e6080e7          	jalr	998(ra) # 80004efa <end_op>

  return 0;
    80004b1c:	4501                	li	a0,0
    iunlockput(dp);
    end_op();
    return -1;
    printf("end RemoveSwapFile\n"); //TODO: delete

}
    80004b1e:	60e6                	ld	ra,88(sp)
    80004b20:	6446                	ld	s0,80(sp)
    80004b22:	64a6                	ld	s1,72(sp)
    80004b24:	6906                	ld	s2,64(sp)
    80004b26:	6125                	addi	sp,sp,96
    80004b28:	8082                	ret
    end_op();
    80004b2a:	00000097          	auipc	ra,0x0
    80004b2e:	3d0080e7          	jalr	976(ra) # 80004efa <end_op>
    return -1;
    80004b32:	557d                	li	a0,-1
    80004b34:	b7ed                	j	80004b1e <removeSwapFile+0x13a>
    panic("unlink: nlink < 1");
    80004b36:	00005517          	auipc	a0,0x5
    80004b3a:	18a50513          	addi	a0,a0,394 # 80009cc0 <syscalls+0x218>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	9ec080e7          	jalr	-1556(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004b46:	8526                	mv	a0,s1
    80004b48:	00001097          	auipc	ra,0x1
    80004b4c:	7fa080e7          	jalr	2042(ra) # 80006342 <isdirempty>
    80004b50:	f13d                	bnez	a0,80004ab6 <removeSwapFile+0xd2>
    iunlockput(ip);
    80004b52:	8526                	mv	a0,s1
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	890080e7          	jalr	-1904(ra) # 800043e4 <iunlockput>
    iunlockput(dp);
    80004b5c:	854a                	mv	a0,s2
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	886080e7          	jalr	-1914(ra) # 800043e4 <iunlockput>
    end_op();
    80004b66:	00000097          	auipc	ra,0x0
    80004b6a:	394080e7          	jalr	916(ra) # 80004efa <end_op>
    return -1;
    80004b6e:	557d                	li	a0,-1
    80004b70:	b77d                	j	80004b1e <removeSwapFile+0x13a>
    panic("unlink: writei");
    80004b72:	00005517          	auipc	a0,0x5
    80004b76:	16650513          	addi	a0,a0,358 # 80009cd8 <syscalls+0x230>
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	9b0080e7          	jalr	-1616(ra) # 8000052a <panic>
    dp->nlink--;
    80004b82:	04a95783          	lhu	a5,74(s2)
    80004b86:	37fd                	addiw	a5,a5,-1
    80004b88:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	fffff097          	auipc	ra,0xfffff
    80004b92:	52a080e7          	jalr	1322(ra) # 800040b8 <iupdate>
    80004b96:	bf99                	j	80004aec <removeSwapFile+0x108>
    return -1;
    80004b98:	557d                	li	a0,-1
    80004b9a:	b751                	j	80004b1e <removeSwapFile+0x13a>

0000000080004b9c <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    80004b9c:	7179                	addi	sp,sp,-48
    80004b9e:	f406                	sd	ra,40(sp)
    80004ba0:	f022                	sd	s0,32(sp)
    80004ba2:	ec26                	sd	s1,24(sp)
    80004ba4:	e84a                	sd	s2,16(sp)
    80004ba6:	1800                	addi	s0,sp,48
    80004ba8:	84aa                	mv	s1,a0
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004baa:	4619                	li	a2,6
    80004bac:	00005597          	auipc	a1,0x5
    80004bb0:	0fc58593          	addi	a1,a1,252 # 80009ca8 <syscalls+0x200>
    80004bb4:	fd040513          	addi	a0,s0,-48
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	162080e7          	jalr	354(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    80004bc0:	fd640593          	addi	a1,s0,-42
    80004bc4:	5888                	lw	a0,48(s1)
    80004bc6:	00000097          	auipc	ra,0x0
    80004bca:	dac080e7          	jalr	-596(ra) # 80004972 <itoa>

  begin_op();
    80004bce:	00000097          	auipc	ra,0x0
    80004bd2:	2ac080e7          	jalr	684(ra) # 80004e7a <begin_op>

  struct inode * in = create(path, T_FILE, 0, 0);
    80004bd6:	4681                	li	a3,0
    80004bd8:	4601                	li	a2,0
    80004bda:	4589                	li	a1,2
    80004bdc:	fd040513          	addi	a0,s0,-48
    80004be0:	00002097          	auipc	ra,0x2
    80004be4:	956080e7          	jalr	-1706(ra) # 80006536 <create>
    80004be8:	892a                	mv	s2,a0
  iunlock(in);
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	65a080e7          	jalr	1626(ra) # 80004244 <iunlock>
  p->swapFile = filealloc();  if (p->swapFile == 0)
    80004bf2:	00000097          	auipc	ra,0x0
    80004bf6:	698080e7          	jalr	1688(ra) # 8000528a <filealloc>
    80004bfa:	16a4b423          	sd	a0,360(s1)
    80004bfe:	cd1d                	beqz	a0,80004c3c <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004c00:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004c04:	1684b703          	ld	a4,360(s1)
    80004c08:	4789                	li	a5,2
    80004c0a:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004c0c:	1684b703          	ld	a4,360(s1)
    80004c10:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004c14:	1684b703          	ld	a4,360(s1)
    80004c18:	4685                	li	a3,1
    80004c1a:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004c1e:	1684b703          	ld	a4,360(s1)
    80004c22:	00f704a3          	sb	a5,9(a4)
    end_op();
    80004c26:	00000097          	auipc	ra,0x0
    80004c2a:	2d4080e7          	jalr	724(ra) # 80004efa <end_op>

    return 0;
}
    80004c2e:	4501                	li	a0,0
    80004c30:	70a2                	ld	ra,40(sp)
    80004c32:	7402                	ld	s0,32(sp)
    80004c34:	64e2                	ld	s1,24(sp)
    80004c36:	6942                	ld	s2,16(sp)
    80004c38:	6145                	addi	sp,sp,48
    80004c3a:	8082                	ret
    panic("no slot for files on /store");
    80004c3c:	00005517          	auipc	a0,0x5
    80004c40:	0ac50513          	addi	a0,a0,172 # 80009ce8 <syscalls+0x240>
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	8e6080e7          	jalr	-1818(ra) # 8000052a <panic>

0000000080004c4c <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004c4c:	1141                	addi	sp,sp,-16
    80004c4e:	e406                	sd	ra,8(sp)
    80004c50:	e022                	sd	s0,0(sp)
    80004c52:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004c54:	16853783          	ld	a5,360(a0)
    80004c58:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    80004c5a:	8636                	mv	a2,a3
    80004c5c:	16853503          	ld	a0,360(a0)
    80004c60:	00001097          	auipc	ra,0x1
    80004c64:	ad8080e7          	jalr	-1320(ra) # 80005738 <kfilewrite>
}
    80004c68:	60a2                	ld	ra,8(sp)
    80004c6a:	6402                	ld	s0,0(sp)
    80004c6c:	0141                	addi	sp,sp,16
    80004c6e:	8082                	ret

0000000080004c70 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004c70:	1141                	addi	sp,sp,-16
    80004c72:	e406                	sd	ra,8(sp)
    80004c74:	e022                	sd	s0,0(sp)
    80004c76:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004c78:	16853783          	ld	a5,360(a0)
    80004c7c:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004c7e:	8636                	mv	a2,a3
    80004c80:	16853503          	ld	a0,360(a0)
    80004c84:	00001097          	auipc	ra,0x1
    80004c88:	9f2080e7          	jalr	-1550(ra) # 80005676 <kfileread>
    80004c8c:	60a2                	ld	ra,8(sp)
    80004c8e:	6402                	ld	s0,0(sp)
    80004c90:	0141                	addi	sp,sp,16
    80004c92:	8082                	ret

0000000080004c94 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004c94:	1101                	addi	sp,sp,-32
    80004c96:	ec06                	sd	ra,24(sp)
    80004c98:	e822                	sd	s0,16(sp)
    80004c9a:	e426                	sd	s1,8(sp)
    80004c9c:	e04a                	sd	s2,0(sp)
    80004c9e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ca0:	00026917          	auipc	s2,0x26
    80004ca4:	fd090913          	addi	s2,s2,-48 # 8002ac70 <log>
    80004ca8:	01892583          	lw	a1,24(s2)
    80004cac:	02892503          	lw	a0,40(s2)
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	cce080e7          	jalr	-818(ra) # 8000397e <bread>
    80004cb8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004cba:	02c92683          	lw	a3,44(s2)
    80004cbe:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004cc0:	02d05863          	blez	a3,80004cf0 <write_head+0x5c>
    80004cc4:	00026797          	auipc	a5,0x26
    80004cc8:	fdc78793          	addi	a5,a5,-36 # 8002aca0 <log+0x30>
    80004ccc:	05c50713          	addi	a4,a0,92
    80004cd0:	36fd                	addiw	a3,a3,-1
    80004cd2:	02069613          	slli	a2,a3,0x20
    80004cd6:	01e65693          	srli	a3,a2,0x1e
    80004cda:	00026617          	auipc	a2,0x26
    80004cde:	fca60613          	addi	a2,a2,-54 # 8002aca4 <log+0x34>
    80004ce2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004ce4:	4390                	lw	a2,0(a5)
    80004ce6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004ce8:	0791                	addi	a5,a5,4
    80004cea:	0711                	addi	a4,a4,4
    80004cec:	fed79ce3          	bne	a5,a3,80004ce4 <write_head+0x50>
  }
  bwrite(buf);
    80004cf0:	8526                	mv	a0,s1
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	d7e080e7          	jalr	-642(ra) # 80003a70 <bwrite>
  brelse(buf);
    80004cfa:	8526                	mv	a0,s1
    80004cfc:	fffff097          	auipc	ra,0xfffff
    80004d00:	db2080e7          	jalr	-590(ra) # 80003aae <brelse>
}
    80004d04:	60e2                	ld	ra,24(sp)
    80004d06:	6442                	ld	s0,16(sp)
    80004d08:	64a2                	ld	s1,8(sp)
    80004d0a:	6902                	ld	s2,0(sp)
    80004d0c:	6105                	addi	sp,sp,32
    80004d0e:	8082                	ret

0000000080004d10 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d10:	00026797          	auipc	a5,0x26
    80004d14:	f8c7a783          	lw	a5,-116(a5) # 8002ac9c <log+0x2c>
    80004d18:	0af05d63          	blez	a5,80004dd2 <install_trans+0xc2>
{
    80004d1c:	7139                	addi	sp,sp,-64
    80004d1e:	fc06                	sd	ra,56(sp)
    80004d20:	f822                	sd	s0,48(sp)
    80004d22:	f426                	sd	s1,40(sp)
    80004d24:	f04a                	sd	s2,32(sp)
    80004d26:	ec4e                	sd	s3,24(sp)
    80004d28:	e852                	sd	s4,16(sp)
    80004d2a:	e456                	sd	s5,8(sp)
    80004d2c:	e05a                	sd	s6,0(sp)
    80004d2e:	0080                	addi	s0,sp,64
    80004d30:	8b2a                	mv	s6,a0
    80004d32:	00026a97          	auipc	s5,0x26
    80004d36:	f6ea8a93          	addi	s5,s5,-146 # 8002aca0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d3a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004d3c:	00026997          	auipc	s3,0x26
    80004d40:	f3498993          	addi	s3,s3,-204 # 8002ac70 <log>
    80004d44:	a00d                	j	80004d66 <install_trans+0x56>
    brelse(lbuf);
    80004d46:	854a                	mv	a0,s2
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	d66080e7          	jalr	-666(ra) # 80003aae <brelse>
    brelse(dbuf);
    80004d50:	8526                	mv	a0,s1
    80004d52:	fffff097          	auipc	ra,0xfffff
    80004d56:	d5c080e7          	jalr	-676(ra) # 80003aae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004d5a:	2a05                	addiw	s4,s4,1
    80004d5c:	0a91                	addi	s5,s5,4
    80004d5e:	02c9a783          	lw	a5,44(s3)
    80004d62:	04fa5e63          	bge	s4,a5,80004dbe <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004d66:	0189a583          	lw	a1,24(s3)
    80004d6a:	014585bb          	addw	a1,a1,s4
    80004d6e:	2585                	addiw	a1,a1,1
    80004d70:	0289a503          	lw	a0,40(s3)
    80004d74:	fffff097          	auipc	ra,0xfffff
    80004d78:	c0a080e7          	jalr	-1014(ra) # 8000397e <bread>
    80004d7c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004d7e:	000aa583          	lw	a1,0(s5)
    80004d82:	0289a503          	lw	a0,40(s3)
    80004d86:	fffff097          	auipc	ra,0xfffff
    80004d8a:	bf8080e7          	jalr	-1032(ra) # 8000397e <bread>
    80004d8e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004d90:	40000613          	li	a2,1024
    80004d94:	05890593          	addi	a1,s2,88
    80004d98:	05850513          	addi	a0,a0,88
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	f7e080e7          	jalr	-130(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004da4:	8526                	mv	a0,s1
    80004da6:	fffff097          	auipc	ra,0xfffff
    80004daa:	cca080e7          	jalr	-822(ra) # 80003a70 <bwrite>
    if(recovering == 0)
    80004dae:	f80b1ce3          	bnez	s6,80004d46 <install_trans+0x36>
      bunpin(dbuf);
    80004db2:	8526                	mv	a0,s1
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	dd4080e7          	jalr	-556(ra) # 80003b88 <bunpin>
    80004dbc:	b769                	j	80004d46 <install_trans+0x36>
}
    80004dbe:	70e2                	ld	ra,56(sp)
    80004dc0:	7442                	ld	s0,48(sp)
    80004dc2:	74a2                	ld	s1,40(sp)
    80004dc4:	7902                	ld	s2,32(sp)
    80004dc6:	69e2                	ld	s3,24(sp)
    80004dc8:	6a42                	ld	s4,16(sp)
    80004dca:	6aa2                	ld	s5,8(sp)
    80004dcc:	6b02                	ld	s6,0(sp)
    80004dce:	6121                	addi	sp,sp,64
    80004dd0:	8082                	ret
    80004dd2:	8082                	ret

0000000080004dd4 <initlog>:
{
    80004dd4:	7179                	addi	sp,sp,-48
    80004dd6:	f406                	sd	ra,40(sp)
    80004dd8:	f022                	sd	s0,32(sp)
    80004dda:	ec26                	sd	s1,24(sp)
    80004ddc:	e84a                	sd	s2,16(sp)
    80004dde:	e44e                	sd	s3,8(sp)
    80004de0:	1800                	addi	s0,sp,48
    80004de2:	892a                	mv	s2,a0
    80004de4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004de6:	00026497          	auipc	s1,0x26
    80004dea:	e8a48493          	addi	s1,s1,-374 # 8002ac70 <log>
    80004dee:	00005597          	auipc	a1,0x5
    80004df2:	f1a58593          	addi	a1,a1,-230 # 80009d08 <syscalls+0x260>
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	d3a080e7          	jalr	-710(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004e00:	0149a583          	lw	a1,20(s3)
    80004e04:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004e06:	0109a783          	lw	a5,16(s3)
    80004e0a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004e0c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004e10:	854a                	mv	a0,s2
    80004e12:	fffff097          	auipc	ra,0xfffff
    80004e16:	b6c080e7          	jalr	-1172(ra) # 8000397e <bread>
  log.lh.n = lh->n;
    80004e1a:	4d34                	lw	a3,88(a0)
    80004e1c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004e1e:	02d05663          	blez	a3,80004e4a <initlog+0x76>
    80004e22:	05c50793          	addi	a5,a0,92
    80004e26:	00026717          	auipc	a4,0x26
    80004e2a:	e7a70713          	addi	a4,a4,-390 # 8002aca0 <log+0x30>
    80004e2e:	36fd                	addiw	a3,a3,-1
    80004e30:	02069613          	slli	a2,a3,0x20
    80004e34:	01e65693          	srli	a3,a2,0x1e
    80004e38:	06050613          	addi	a2,a0,96
    80004e3c:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004e3e:	4390                	lw	a2,0(a5)
    80004e40:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004e42:	0791                	addi	a5,a5,4
    80004e44:	0711                	addi	a4,a4,4
    80004e46:	fed79ce3          	bne	a5,a3,80004e3e <initlog+0x6a>
  brelse(buf);
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	c64080e7          	jalr	-924(ra) # 80003aae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004e52:	4505                	li	a0,1
    80004e54:	00000097          	auipc	ra,0x0
    80004e58:	ebc080e7          	jalr	-324(ra) # 80004d10 <install_trans>
  log.lh.n = 0;
    80004e5c:	00026797          	auipc	a5,0x26
    80004e60:	e407a023          	sw	zero,-448(a5) # 8002ac9c <log+0x2c>
  write_head(); // clear the log
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	e30080e7          	jalr	-464(ra) # 80004c94 <write_head>
}
    80004e6c:	70a2                	ld	ra,40(sp)
    80004e6e:	7402                	ld	s0,32(sp)
    80004e70:	64e2                	ld	s1,24(sp)
    80004e72:	6942                	ld	s2,16(sp)
    80004e74:	69a2                	ld	s3,8(sp)
    80004e76:	6145                	addi	sp,sp,48
    80004e78:	8082                	ret

0000000080004e7a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004e7a:	1101                	addi	sp,sp,-32
    80004e7c:	ec06                	sd	ra,24(sp)
    80004e7e:	e822                	sd	s0,16(sp)
    80004e80:	e426                	sd	s1,8(sp)
    80004e82:	e04a                	sd	s2,0(sp)
    80004e84:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004e86:	00026517          	auipc	a0,0x26
    80004e8a:	dea50513          	addi	a0,a0,-534 # 8002ac70 <log>
    80004e8e:	ffffc097          	auipc	ra,0xffffc
    80004e92:	d34080e7          	jalr	-716(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004e96:	00026497          	auipc	s1,0x26
    80004e9a:	dda48493          	addi	s1,s1,-550 # 8002ac70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004e9e:	4979                	li	s2,30
    80004ea0:	a039                	j	80004eae <begin_op+0x34>
      sleep(&log, &log.lock);
    80004ea2:	85a6                	mv	a1,s1
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffd097          	auipc	ra,0xffffd
    80004eaa:	382080e7          	jalr	898(ra) # 80002228 <sleep>
    if(log.committing){
    80004eae:	50dc                	lw	a5,36(s1)
    80004eb0:	fbed                	bnez	a5,80004ea2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004eb2:	509c                	lw	a5,32(s1)
    80004eb4:	0017871b          	addiw	a4,a5,1
    80004eb8:	0007069b          	sext.w	a3,a4
    80004ebc:	0027179b          	slliw	a5,a4,0x2
    80004ec0:	9fb9                	addw	a5,a5,a4
    80004ec2:	0017979b          	slliw	a5,a5,0x1
    80004ec6:	54d8                	lw	a4,44(s1)
    80004ec8:	9fb9                	addw	a5,a5,a4
    80004eca:	00f95963          	bge	s2,a5,80004edc <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004ece:	85a6                	mv	a1,s1
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	ffffd097          	auipc	ra,0xffffd
    80004ed6:	356080e7          	jalr	854(ra) # 80002228 <sleep>
    80004eda:	bfd1                	j	80004eae <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004edc:	00026517          	auipc	a0,0x26
    80004ee0:	d9450513          	addi	a0,a0,-620 # 8002ac70 <log>
    80004ee4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004ee6:	ffffc097          	auipc	ra,0xffffc
    80004eea:	d90080e7          	jalr	-624(ra) # 80000c76 <release>
      break;
    }
  }
}
    80004eee:	60e2                	ld	ra,24(sp)
    80004ef0:	6442                	ld	s0,16(sp)
    80004ef2:	64a2                	ld	s1,8(sp)
    80004ef4:	6902                	ld	s2,0(sp)
    80004ef6:	6105                	addi	sp,sp,32
    80004ef8:	8082                	ret

0000000080004efa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004efa:	7139                	addi	sp,sp,-64
    80004efc:	fc06                	sd	ra,56(sp)
    80004efe:	f822                	sd	s0,48(sp)
    80004f00:	f426                	sd	s1,40(sp)
    80004f02:	f04a                	sd	s2,32(sp)
    80004f04:	ec4e                	sd	s3,24(sp)
    80004f06:	e852                	sd	s4,16(sp)
    80004f08:	e456                	sd	s5,8(sp)
    80004f0a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004f0c:	00026497          	auipc	s1,0x26
    80004f10:	d6448493          	addi	s1,s1,-668 # 8002ac70 <log>
    80004f14:	8526                	mv	a0,s1
    80004f16:	ffffc097          	auipc	ra,0xffffc
    80004f1a:	cac080e7          	jalr	-852(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004f1e:	509c                	lw	a5,32(s1)
    80004f20:	37fd                	addiw	a5,a5,-1
    80004f22:	0007891b          	sext.w	s2,a5
    80004f26:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004f28:	50dc                	lw	a5,36(s1)
    80004f2a:	e7b9                	bnez	a5,80004f78 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004f2c:	04091e63          	bnez	s2,80004f88 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004f30:	00026497          	auipc	s1,0x26
    80004f34:	d4048493          	addi	s1,s1,-704 # 8002ac70 <log>
    80004f38:	4785                	li	a5,1
    80004f3a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	d38080e7          	jalr	-712(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004f46:	54dc                	lw	a5,44(s1)
    80004f48:	06f04763          	bgtz	a5,80004fb6 <end_op+0xbc>
    acquire(&log.lock);
    80004f4c:	00026497          	auipc	s1,0x26
    80004f50:	d2448493          	addi	s1,s1,-732 # 8002ac70 <log>
    80004f54:	8526                	mv	a0,s1
    80004f56:	ffffc097          	auipc	ra,0xffffc
    80004f5a:	c6c080e7          	jalr	-916(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004f5e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004f62:	8526                	mv	a0,s1
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	450080e7          	jalr	1104(ra) # 800023b4 <wakeup>
    release(&log.lock);
    80004f6c:	8526                	mv	a0,s1
    80004f6e:	ffffc097          	auipc	ra,0xffffc
    80004f72:	d08080e7          	jalr	-760(ra) # 80000c76 <release>
}
    80004f76:	a03d                	j	80004fa4 <end_op+0xaa>
    panic("log.committing");
    80004f78:	00005517          	auipc	a0,0x5
    80004f7c:	d9850513          	addi	a0,a0,-616 # 80009d10 <syscalls+0x268>
    80004f80:	ffffb097          	auipc	ra,0xffffb
    80004f84:	5aa080e7          	jalr	1450(ra) # 8000052a <panic>
    wakeup(&log);
    80004f88:	00026497          	auipc	s1,0x26
    80004f8c:	ce848493          	addi	s1,s1,-792 # 8002ac70 <log>
    80004f90:	8526                	mv	a0,s1
    80004f92:	ffffd097          	auipc	ra,0xffffd
    80004f96:	422080e7          	jalr	1058(ra) # 800023b4 <wakeup>
  release(&log.lock);
    80004f9a:	8526                	mv	a0,s1
    80004f9c:	ffffc097          	auipc	ra,0xffffc
    80004fa0:	cda080e7          	jalr	-806(ra) # 80000c76 <release>
}
    80004fa4:	70e2                	ld	ra,56(sp)
    80004fa6:	7442                	ld	s0,48(sp)
    80004fa8:	74a2                	ld	s1,40(sp)
    80004faa:	7902                	ld	s2,32(sp)
    80004fac:	69e2                	ld	s3,24(sp)
    80004fae:	6a42                	ld	s4,16(sp)
    80004fb0:	6aa2                	ld	s5,8(sp)
    80004fb2:	6121                	addi	sp,sp,64
    80004fb4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004fb6:	00026a97          	auipc	s5,0x26
    80004fba:	ceaa8a93          	addi	s5,s5,-790 # 8002aca0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004fbe:	00026a17          	auipc	s4,0x26
    80004fc2:	cb2a0a13          	addi	s4,s4,-846 # 8002ac70 <log>
    80004fc6:	018a2583          	lw	a1,24(s4)
    80004fca:	012585bb          	addw	a1,a1,s2
    80004fce:	2585                	addiw	a1,a1,1
    80004fd0:	028a2503          	lw	a0,40(s4)
    80004fd4:	fffff097          	auipc	ra,0xfffff
    80004fd8:	9aa080e7          	jalr	-1622(ra) # 8000397e <bread>
    80004fdc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004fde:	000aa583          	lw	a1,0(s5)
    80004fe2:	028a2503          	lw	a0,40(s4)
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	998080e7          	jalr	-1640(ra) # 8000397e <bread>
    80004fee:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004ff0:	40000613          	li	a2,1024
    80004ff4:	05850593          	addi	a1,a0,88
    80004ff8:	05848513          	addi	a0,s1,88
    80004ffc:	ffffc097          	auipc	ra,0xffffc
    80005000:	d1e080e7          	jalr	-738(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80005004:	8526                	mv	a0,s1
    80005006:	fffff097          	auipc	ra,0xfffff
    8000500a:	a6a080e7          	jalr	-1430(ra) # 80003a70 <bwrite>
    brelse(from);
    8000500e:	854e                	mv	a0,s3
    80005010:	fffff097          	auipc	ra,0xfffff
    80005014:	a9e080e7          	jalr	-1378(ra) # 80003aae <brelse>
    brelse(to);
    80005018:	8526                	mv	a0,s1
    8000501a:	fffff097          	auipc	ra,0xfffff
    8000501e:	a94080e7          	jalr	-1388(ra) # 80003aae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80005022:	2905                	addiw	s2,s2,1
    80005024:	0a91                	addi	s5,s5,4
    80005026:	02ca2783          	lw	a5,44(s4)
    8000502a:	f8f94ee3          	blt	s2,a5,80004fc6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000502e:	00000097          	auipc	ra,0x0
    80005032:	c66080e7          	jalr	-922(ra) # 80004c94 <write_head>
    install_trans(0); // Now install writes to home locations
    80005036:	4501                	li	a0,0
    80005038:	00000097          	auipc	ra,0x0
    8000503c:	cd8080e7          	jalr	-808(ra) # 80004d10 <install_trans>
    log.lh.n = 0;
    80005040:	00026797          	auipc	a5,0x26
    80005044:	c407ae23          	sw	zero,-932(a5) # 8002ac9c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005048:	00000097          	auipc	ra,0x0
    8000504c:	c4c080e7          	jalr	-948(ra) # 80004c94 <write_head>
    80005050:	bdf5                	j	80004f4c <end_op+0x52>

0000000080005052 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005052:	1101                	addi	sp,sp,-32
    80005054:	ec06                	sd	ra,24(sp)
    80005056:	e822                	sd	s0,16(sp)
    80005058:	e426                	sd	s1,8(sp)
    8000505a:	e04a                	sd	s2,0(sp)
    8000505c:	1000                	addi	s0,sp,32
    8000505e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005060:	00026917          	auipc	s2,0x26
    80005064:	c1090913          	addi	s2,s2,-1008 # 8002ac70 <log>
    80005068:	854a                	mv	a0,s2
    8000506a:	ffffc097          	auipc	ra,0xffffc
    8000506e:	b58080e7          	jalr	-1192(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005072:	02c92603          	lw	a2,44(s2)
    80005076:	47f5                	li	a5,29
    80005078:	06c7c563          	blt	a5,a2,800050e2 <log_write+0x90>
    8000507c:	00026797          	auipc	a5,0x26
    80005080:	c107a783          	lw	a5,-1008(a5) # 8002ac8c <log+0x1c>
    80005084:	37fd                	addiw	a5,a5,-1
    80005086:	04f65e63          	bge	a2,a5,800050e2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000508a:	00026797          	auipc	a5,0x26
    8000508e:	c067a783          	lw	a5,-1018(a5) # 8002ac90 <log+0x20>
    80005092:	06f05063          	blez	a5,800050f2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005096:	4781                	li	a5,0
    80005098:	06c05563          	blez	a2,80005102 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000509c:	44cc                	lw	a1,12(s1)
    8000509e:	00026717          	auipc	a4,0x26
    800050a2:	c0270713          	addi	a4,a4,-1022 # 8002aca0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800050a6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800050a8:	4314                	lw	a3,0(a4)
    800050aa:	04b68c63          	beq	a3,a1,80005102 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800050ae:	2785                	addiw	a5,a5,1
    800050b0:	0711                	addi	a4,a4,4
    800050b2:	fef61be3          	bne	a2,a5,800050a8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800050b6:	0621                	addi	a2,a2,8
    800050b8:	060a                	slli	a2,a2,0x2
    800050ba:	00026797          	auipc	a5,0x26
    800050be:	bb678793          	addi	a5,a5,-1098 # 8002ac70 <log>
    800050c2:	963e                	add	a2,a2,a5
    800050c4:	44dc                	lw	a5,12(s1)
    800050c6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800050c8:	8526                	mv	a0,s1
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	a82080e7          	jalr	-1406(ra) # 80003b4c <bpin>
    log.lh.n++;
    800050d2:	00026717          	auipc	a4,0x26
    800050d6:	b9e70713          	addi	a4,a4,-1122 # 8002ac70 <log>
    800050da:	575c                	lw	a5,44(a4)
    800050dc:	2785                	addiw	a5,a5,1
    800050de:	d75c                	sw	a5,44(a4)
    800050e0:	a835                	j	8000511c <log_write+0xca>
    panic("too big a transaction");
    800050e2:	00005517          	auipc	a0,0x5
    800050e6:	c3e50513          	addi	a0,a0,-962 # 80009d20 <syscalls+0x278>
    800050ea:	ffffb097          	auipc	ra,0xffffb
    800050ee:	440080e7          	jalr	1088(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    800050f2:	00005517          	auipc	a0,0x5
    800050f6:	c4650513          	addi	a0,a0,-954 # 80009d38 <syscalls+0x290>
    800050fa:	ffffb097          	auipc	ra,0xffffb
    800050fe:	430080e7          	jalr	1072(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80005102:	00878713          	addi	a4,a5,8
    80005106:	00271693          	slli	a3,a4,0x2
    8000510a:	00026717          	auipc	a4,0x26
    8000510e:	b6670713          	addi	a4,a4,-1178 # 8002ac70 <log>
    80005112:	9736                	add	a4,a4,a3
    80005114:	44d4                	lw	a3,12(s1)
    80005116:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005118:	faf608e3          	beq	a2,a5,800050c8 <log_write+0x76>
  }
  release(&log.lock);
    8000511c:	00026517          	auipc	a0,0x26
    80005120:	b5450513          	addi	a0,a0,-1196 # 8002ac70 <log>
    80005124:	ffffc097          	auipc	ra,0xffffc
    80005128:	b52080e7          	jalr	-1198(ra) # 80000c76 <release>
}
    8000512c:	60e2                	ld	ra,24(sp)
    8000512e:	6442                	ld	s0,16(sp)
    80005130:	64a2                	ld	s1,8(sp)
    80005132:	6902                	ld	s2,0(sp)
    80005134:	6105                	addi	sp,sp,32
    80005136:	8082                	ret

0000000080005138 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80005138:	1101                	addi	sp,sp,-32
    8000513a:	ec06                	sd	ra,24(sp)
    8000513c:	e822                	sd	s0,16(sp)
    8000513e:	e426                	sd	s1,8(sp)
    80005140:	e04a                	sd	s2,0(sp)
    80005142:	1000                	addi	s0,sp,32
    80005144:	84aa                	mv	s1,a0
    80005146:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005148:	00005597          	auipc	a1,0x5
    8000514c:	c1058593          	addi	a1,a1,-1008 # 80009d58 <syscalls+0x2b0>
    80005150:	0521                	addi	a0,a0,8
    80005152:	ffffc097          	auipc	ra,0xffffc
    80005156:	9e0080e7          	jalr	-1568(ra) # 80000b32 <initlock>
  lk->name = name;
    8000515a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000515e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005162:	0204a423          	sw	zero,40(s1)
}
    80005166:	60e2                	ld	ra,24(sp)
    80005168:	6442                	ld	s0,16(sp)
    8000516a:	64a2                	ld	s1,8(sp)
    8000516c:	6902                	ld	s2,0(sp)
    8000516e:	6105                	addi	sp,sp,32
    80005170:	8082                	ret

0000000080005172 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005172:	1101                	addi	sp,sp,-32
    80005174:	ec06                	sd	ra,24(sp)
    80005176:	e822                	sd	s0,16(sp)
    80005178:	e426                	sd	s1,8(sp)
    8000517a:	e04a                	sd	s2,0(sp)
    8000517c:	1000                	addi	s0,sp,32
    8000517e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005180:	00850913          	addi	s2,a0,8
    80005184:	854a                	mv	a0,s2
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	a3c080e7          	jalr	-1476(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    8000518e:	409c                	lw	a5,0(s1)
    80005190:	cb89                	beqz	a5,800051a2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005192:	85ca                	mv	a1,s2
    80005194:	8526                	mv	a0,s1
    80005196:	ffffd097          	auipc	ra,0xffffd
    8000519a:	092080e7          	jalr	146(ra) # 80002228 <sleep>
  while (lk->locked) {
    8000519e:	409c                	lw	a5,0(s1)
    800051a0:	fbed                	bnez	a5,80005192 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800051a2:	4785                	li	a5,1
    800051a4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800051a6:	ffffd097          	auipc	ra,0xffffd
    800051aa:	b8a080e7          	jalr	-1142(ra) # 80001d30 <myproc>
    800051ae:	591c                	lw	a5,48(a0)
    800051b0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800051b2:	854a                	mv	a0,s2
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	ac2080e7          	jalr	-1342(ra) # 80000c76 <release>
}
    800051bc:	60e2                	ld	ra,24(sp)
    800051be:	6442                	ld	s0,16(sp)
    800051c0:	64a2                	ld	s1,8(sp)
    800051c2:	6902                	ld	s2,0(sp)
    800051c4:	6105                	addi	sp,sp,32
    800051c6:	8082                	ret

00000000800051c8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800051c8:	1101                	addi	sp,sp,-32
    800051ca:	ec06                	sd	ra,24(sp)
    800051cc:	e822                	sd	s0,16(sp)
    800051ce:	e426                	sd	s1,8(sp)
    800051d0:	e04a                	sd	s2,0(sp)
    800051d2:	1000                	addi	s0,sp,32
    800051d4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800051d6:	00850913          	addi	s2,a0,8
    800051da:	854a                	mv	a0,s2
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	9e6080e7          	jalr	-1562(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800051e4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800051e8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800051ec:	8526                	mv	a0,s1
    800051ee:	ffffd097          	auipc	ra,0xffffd
    800051f2:	1c6080e7          	jalr	454(ra) # 800023b4 <wakeup>
  release(&lk->lk);
    800051f6:	854a                	mv	a0,s2
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	a7e080e7          	jalr	-1410(ra) # 80000c76 <release>
}
    80005200:	60e2                	ld	ra,24(sp)
    80005202:	6442                	ld	s0,16(sp)
    80005204:	64a2                	ld	s1,8(sp)
    80005206:	6902                	ld	s2,0(sp)
    80005208:	6105                	addi	sp,sp,32
    8000520a:	8082                	ret

000000008000520c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000520c:	7179                	addi	sp,sp,-48
    8000520e:	f406                	sd	ra,40(sp)
    80005210:	f022                	sd	s0,32(sp)
    80005212:	ec26                	sd	s1,24(sp)
    80005214:	e84a                	sd	s2,16(sp)
    80005216:	e44e                	sd	s3,8(sp)
    80005218:	1800                	addi	s0,sp,48
    8000521a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000521c:	00850913          	addi	s2,a0,8
    80005220:	854a                	mv	a0,s2
    80005222:	ffffc097          	auipc	ra,0xffffc
    80005226:	9a0080e7          	jalr	-1632(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000522a:	409c                	lw	a5,0(s1)
    8000522c:	ef99                	bnez	a5,8000524a <holdingsleep+0x3e>
    8000522e:	4481                	li	s1,0
  release(&lk->lk);
    80005230:	854a                	mv	a0,s2
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	a44080e7          	jalr	-1468(ra) # 80000c76 <release>
  return r;
}
    8000523a:	8526                	mv	a0,s1
    8000523c:	70a2                	ld	ra,40(sp)
    8000523e:	7402                	ld	s0,32(sp)
    80005240:	64e2                	ld	s1,24(sp)
    80005242:	6942                	ld	s2,16(sp)
    80005244:	69a2                	ld	s3,8(sp)
    80005246:	6145                	addi	sp,sp,48
    80005248:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000524a:	0284a983          	lw	s3,40(s1)
    8000524e:	ffffd097          	auipc	ra,0xffffd
    80005252:	ae2080e7          	jalr	-1310(ra) # 80001d30 <myproc>
    80005256:	5904                	lw	s1,48(a0)
    80005258:	413484b3          	sub	s1,s1,s3
    8000525c:	0014b493          	seqz	s1,s1
    80005260:	bfc1                	j	80005230 <holdingsleep+0x24>

0000000080005262 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005262:	1141                	addi	sp,sp,-16
    80005264:	e406                	sd	ra,8(sp)
    80005266:	e022                	sd	s0,0(sp)
    80005268:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000526a:	00005597          	auipc	a1,0x5
    8000526e:	afe58593          	addi	a1,a1,-1282 # 80009d68 <syscalls+0x2c0>
    80005272:	00026517          	auipc	a0,0x26
    80005276:	b4650513          	addi	a0,a0,-1210 # 8002adb8 <ftable>
    8000527a:	ffffc097          	auipc	ra,0xffffc
    8000527e:	8b8080e7          	jalr	-1864(ra) # 80000b32 <initlock>
}
    80005282:	60a2                	ld	ra,8(sp)
    80005284:	6402                	ld	s0,0(sp)
    80005286:	0141                	addi	sp,sp,16
    80005288:	8082                	ret

000000008000528a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000528a:	1101                	addi	sp,sp,-32
    8000528c:	ec06                	sd	ra,24(sp)
    8000528e:	e822                	sd	s0,16(sp)
    80005290:	e426                	sd	s1,8(sp)
    80005292:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005294:	00026517          	auipc	a0,0x26
    80005298:	b2450513          	addi	a0,a0,-1244 # 8002adb8 <ftable>
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	926080e7          	jalr	-1754(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800052a4:	00026497          	auipc	s1,0x26
    800052a8:	b2c48493          	addi	s1,s1,-1236 # 8002add0 <ftable+0x18>
    800052ac:	00027717          	auipc	a4,0x27
    800052b0:	ac470713          	addi	a4,a4,-1340 # 8002bd70 <ftable+0xfb8>
    if(f->ref == 0){
    800052b4:	40dc                	lw	a5,4(s1)
    800052b6:	cf99                	beqz	a5,800052d4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800052b8:	02848493          	addi	s1,s1,40
    800052bc:	fee49ce3          	bne	s1,a4,800052b4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800052c0:	00026517          	auipc	a0,0x26
    800052c4:	af850513          	addi	a0,a0,-1288 # 8002adb8 <ftable>
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	9ae080e7          	jalr	-1618(ra) # 80000c76 <release>
  return 0;
    800052d0:	4481                	li	s1,0
    800052d2:	a819                	j	800052e8 <filealloc+0x5e>
      f->ref = 1;
    800052d4:	4785                	li	a5,1
    800052d6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800052d8:	00026517          	auipc	a0,0x26
    800052dc:	ae050513          	addi	a0,a0,-1312 # 8002adb8 <ftable>
    800052e0:	ffffc097          	auipc	ra,0xffffc
    800052e4:	996080e7          	jalr	-1642(ra) # 80000c76 <release>
}
    800052e8:	8526                	mv	a0,s1
    800052ea:	60e2                	ld	ra,24(sp)
    800052ec:	6442                	ld	s0,16(sp)
    800052ee:	64a2                	ld	s1,8(sp)
    800052f0:	6105                	addi	sp,sp,32
    800052f2:	8082                	ret

00000000800052f4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800052f4:	1101                	addi	sp,sp,-32
    800052f6:	ec06                	sd	ra,24(sp)
    800052f8:	e822                	sd	s0,16(sp)
    800052fa:	e426                	sd	s1,8(sp)
    800052fc:	1000                	addi	s0,sp,32
    800052fe:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005300:	00026517          	auipc	a0,0x26
    80005304:	ab850513          	addi	a0,a0,-1352 # 8002adb8 <ftable>
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	8ba080e7          	jalr	-1862(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80005310:	40dc                	lw	a5,4(s1)
    80005312:	02f05263          	blez	a5,80005336 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80005316:	2785                	addiw	a5,a5,1
    80005318:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000531a:	00026517          	auipc	a0,0x26
    8000531e:	a9e50513          	addi	a0,a0,-1378 # 8002adb8 <ftable>
    80005322:	ffffc097          	auipc	ra,0xffffc
    80005326:	954080e7          	jalr	-1708(ra) # 80000c76 <release>
  return f;
}
    8000532a:	8526                	mv	a0,s1
    8000532c:	60e2                	ld	ra,24(sp)
    8000532e:	6442                	ld	s0,16(sp)
    80005330:	64a2                	ld	s1,8(sp)
    80005332:	6105                	addi	sp,sp,32
    80005334:	8082                	ret
    panic("filedup");
    80005336:	00005517          	auipc	a0,0x5
    8000533a:	a3a50513          	addi	a0,a0,-1478 # 80009d70 <syscalls+0x2c8>
    8000533e:	ffffb097          	auipc	ra,0xffffb
    80005342:	1ec080e7          	jalr	492(ra) # 8000052a <panic>

0000000080005346 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005346:	7139                	addi	sp,sp,-64
    80005348:	fc06                	sd	ra,56(sp)
    8000534a:	f822                	sd	s0,48(sp)
    8000534c:	f426                	sd	s1,40(sp)
    8000534e:	f04a                	sd	s2,32(sp)
    80005350:	ec4e                	sd	s3,24(sp)
    80005352:	e852                	sd	s4,16(sp)
    80005354:	e456                	sd	s5,8(sp)
    80005356:	0080                	addi	s0,sp,64
    80005358:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000535a:	00026517          	auipc	a0,0x26
    8000535e:	a5e50513          	addi	a0,a0,-1442 # 8002adb8 <ftable>
    80005362:	ffffc097          	auipc	ra,0xffffc
    80005366:	860080e7          	jalr	-1952(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    8000536a:	40dc                	lw	a5,4(s1)
    8000536c:	06f05163          	blez	a5,800053ce <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005370:	37fd                	addiw	a5,a5,-1
    80005372:	0007871b          	sext.w	a4,a5
    80005376:	c0dc                	sw	a5,4(s1)
    80005378:	06e04363          	bgtz	a4,800053de <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000537c:	0004a903          	lw	s2,0(s1)
    80005380:	0094ca83          	lbu	s5,9(s1)
    80005384:	0104ba03          	ld	s4,16(s1)
    80005388:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000538c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005390:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005394:	00026517          	auipc	a0,0x26
    80005398:	a2450513          	addi	a0,a0,-1500 # 8002adb8 <ftable>
    8000539c:	ffffc097          	auipc	ra,0xffffc
    800053a0:	8da080e7          	jalr	-1830(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    800053a4:	4785                	li	a5,1
    800053a6:	04f90d63          	beq	s2,a5,80005400 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800053aa:	3979                	addiw	s2,s2,-2
    800053ac:	4785                	li	a5,1
    800053ae:	0527e063          	bltu	a5,s2,800053ee <fileclose+0xa8>
    begin_op();
    800053b2:	00000097          	auipc	ra,0x0
    800053b6:	ac8080e7          	jalr	-1336(ra) # 80004e7a <begin_op>
    iput(ff.ip);
    800053ba:	854e                	mv	a0,s3
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	f80080e7          	jalr	-128(ra) # 8000433c <iput>
    end_op();
    800053c4:	00000097          	auipc	ra,0x0
    800053c8:	b36080e7          	jalr	-1226(ra) # 80004efa <end_op>
    800053cc:	a00d                	j	800053ee <fileclose+0xa8>
    panic("fileclose");
    800053ce:	00005517          	auipc	a0,0x5
    800053d2:	9aa50513          	addi	a0,a0,-1622 # 80009d78 <syscalls+0x2d0>
    800053d6:	ffffb097          	auipc	ra,0xffffb
    800053da:	154080e7          	jalr	340(ra) # 8000052a <panic>
    release(&ftable.lock);
    800053de:	00026517          	auipc	a0,0x26
    800053e2:	9da50513          	addi	a0,a0,-1574 # 8002adb8 <ftable>
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	890080e7          	jalr	-1904(ra) # 80000c76 <release>
  }
}
    800053ee:	70e2                	ld	ra,56(sp)
    800053f0:	7442                	ld	s0,48(sp)
    800053f2:	74a2                	ld	s1,40(sp)
    800053f4:	7902                	ld	s2,32(sp)
    800053f6:	69e2                	ld	s3,24(sp)
    800053f8:	6a42                	ld	s4,16(sp)
    800053fa:	6aa2                	ld	s5,8(sp)
    800053fc:	6121                	addi	sp,sp,64
    800053fe:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005400:	85d6                	mv	a1,s5
    80005402:	8552                	mv	a0,s4
    80005404:	00000097          	auipc	ra,0x0
    80005408:	542080e7          	jalr	1346(ra) # 80005946 <pipeclose>
    8000540c:	b7cd                	j	800053ee <fileclose+0xa8>

000000008000540e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000540e:	715d                	addi	sp,sp,-80
    80005410:	e486                	sd	ra,72(sp)
    80005412:	e0a2                	sd	s0,64(sp)
    80005414:	fc26                	sd	s1,56(sp)
    80005416:	f84a                	sd	s2,48(sp)
    80005418:	f44e                	sd	s3,40(sp)
    8000541a:	0880                	addi	s0,sp,80
    8000541c:	84aa                	mv	s1,a0
    8000541e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005420:	ffffd097          	auipc	ra,0xffffd
    80005424:	910080e7          	jalr	-1776(ra) # 80001d30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005428:	409c                	lw	a5,0(s1)
    8000542a:	37f9                	addiw	a5,a5,-2
    8000542c:	4705                	li	a4,1
    8000542e:	04f76763          	bltu	a4,a5,8000547c <filestat+0x6e>
    80005432:	892a                	mv	s2,a0
    ilock(f->ip);
    80005434:	6c88                	ld	a0,24(s1)
    80005436:	fffff097          	auipc	ra,0xfffff
    8000543a:	d4c080e7          	jalr	-692(ra) # 80004182 <ilock>
    stati(f->ip, &st);
    8000543e:	fb840593          	addi	a1,s0,-72
    80005442:	6c88                	ld	a0,24(s1)
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	fc8080e7          	jalr	-56(ra) # 8000440c <stati>
    iunlock(f->ip);
    8000544c:	6c88                	ld	a0,24(s1)
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	df6080e7          	jalr	-522(ra) # 80004244 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005456:	46e1                	li	a3,24
    80005458:	fb840613          	addi	a2,s0,-72
    8000545c:	85ce                	mv	a1,s3
    8000545e:	05093503          	ld	a0,80(s2)
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	f30080e7          	jalr	-208(ra) # 80001392 <copyout>
    8000546a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000546e:	60a6                	ld	ra,72(sp)
    80005470:	6406                	ld	s0,64(sp)
    80005472:	74e2                	ld	s1,56(sp)
    80005474:	7942                	ld	s2,48(sp)
    80005476:	79a2                	ld	s3,40(sp)
    80005478:	6161                	addi	sp,sp,80
    8000547a:	8082                	ret
  return -1;
    8000547c:	557d                	li	a0,-1
    8000547e:	bfc5                	j	8000546e <filestat+0x60>

0000000080005480 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005480:	7179                	addi	sp,sp,-48
    80005482:	f406                	sd	ra,40(sp)
    80005484:	f022                	sd	s0,32(sp)
    80005486:	ec26                	sd	s1,24(sp)
    80005488:	e84a                	sd	s2,16(sp)
    8000548a:	e44e                	sd	s3,8(sp)
    8000548c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000548e:	00854783          	lbu	a5,8(a0)
    80005492:	c3d5                	beqz	a5,80005536 <fileread+0xb6>
    80005494:	84aa                	mv	s1,a0
    80005496:	89ae                	mv	s3,a1
    80005498:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000549a:	411c                	lw	a5,0(a0)
    8000549c:	4705                	li	a4,1
    8000549e:	04e78963          	beq	a5,a4,800054f0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800054a2:	470d                	li	a4,3
    800054a4:	04e78d63          	beq	a5,a4,800054fe <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800054a8:	4709                	li	a4,2
    800054aa:	06e79e63          	bne	a5,a4,80005526 <fileread+0xa6>
    ilock(f->ip);
    800054ae:	6d08                	ld	a0,24(a0)
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	cd2080e7          	jalr	-814(ra) # 80004182 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800054b8:	874a                	mv	a4,s2
    800054ba:	5094                	lw	a3,32(s1)
    800054bc:	864e                	mv	a2,s3
    800054be:	4585                	li	a1,1
    800054c0:	6c88                	ld	a0,24(s1)
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	f74080e7          	jalr	-140(ra) # 80004436 <readi>
    800054ca:	892a                	mv	s2,a0
    800054cc:	00a05563          	blez	a0,800054d6 <fileread+0x56>
      f->off += r;
    800054d0:	509c                	lw	a5,32(s1)
    800054d2:	9fa9                	addw	a5,a5,a0
    800054d4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800054d6:	6c88                	ld	a0,24(s1)
    800054d8:	fffff097          	auipc	ra,0xfffff
    800054dc:	d6c080e7          	jalr	-660(ra) # 80004244 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800054e0:	854a                	mv	a0,s2
    800054e2:	70a2                	ld	ra,40(sp)
    800054e4:	7402                	ld	s0,32(sp)
    800054e6:	64e2                	ld	s1,24(sp)
    800054e8:	6942                	ld	s2,16(sp)
    800054ea:	69a2                	ld	s3,8(sp)
    800054ec:	6145                	addi	sp,sp,48
    800054ee:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800054f0:	6908                	ld	a0,16(a0)
    800054f2:	00000097          	auipc	ra,0x0
    800054f6:	5b6080e7          	jalr	1462(ra) # 80005aa8 <piperead>
    800054fa:	892a                	mv	s2,a0
    800054fc:	b7d5                	j	800054e0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800054fe:	02451783          	lh	a5,36(a0)
    80005502:	03079693          	slli	a3,a5,0x30
    80005506:	92c1                	srli	a3,a3,0x30
    80005508:	4725                	li	a4,9
    8000550a:	02d76863          	bltu	a4,a3,8000553a <fileread+0xba>
    8000550e:	0792                	slli	a5,a5,0x4
    80005510:	00026717          	auipc	a4,0x26
    80005514:	80870713          	addi	a4,a4,-2040 # 8002ad18 <devsw>
    80005518:	97ba                	add	a5,a5,a4
    8000551a:	639c                	ld	a5,0(a5)
    8000551c:	c38d                	beqz	a5,8000553e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000551e:	4505                	li	a0,1
    80005520:	9782                	jalr	a5
    80005522:	892a                	mv	s2,a0
    80005524:	bf75                	j	800054e0 <fileread+0x60>
    panic("fileread");
    80005526:	00005517          	auipc	a0,0x5
    8000552a:	86250513          	addi	a0,a0,-1950 # 80009d88 <syscalls+0x2e0>
    8000552e:	ffffb097          	auipc	ra,0xffffb
    80005532:	ffc080e7          	jalr	-4(ra) # 8000052a <panic>
    return -1;
    80005536:	597d                	li	s2,-1
    80005538:	b765                	j	800054e0 <fileread+0x60>
      return -1;
    8000553a:	597d                	li	s2,-1
    8000553c:	b755                	j	800054e0 <fileread+0x60>
    8000553e:	597d                	li	s2,-1
    80005540:	b745                	j	800054e0 <fileread+0x60>

0000000080005542 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005542:	715d                	addi	sp,sp,-80
    80005544:	e486                	sd	ra,72(sp)
    80005546:	e0a2                	sd	s0,64(sp)
    80005548:	fc26                	sd	s1,56(sp)
    8000554a:	f84a                	sd	s2,48(sp)
    8000554c:	f44e                	sd	s3,40(sp)
    8000554e:	f052                	sd	s4,32(sp)
    80005550:	ec56                	sd	s5,24(sp)
    80005552:	e85a                	sd	s6,16(sp)
    80005554:	e45e                	sd	s7,8(sp)
    80005556:	e062                	sd	s8,0(sp)
    80005558:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000555a:	00954783          	lbu	a5,9(a0)
    8000555e:	10078663          	beqz	a5,8000566a <filewrite+0x128>
    80005562:	892a                	mv	s2,a0
    80005564:	8aae                	mv	s5,a1
    80005566:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005568:	411c                	lw	a5,0(a0)
    8000556a:	4705                	li	a4,1
    8000556c:	02e78263          	beq	a5,a4,80005590 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005570:	470d                	li	a4,3
    80005572:	02e78663          	beq	a5,a4,8000559e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005576:	4709                	li	a4,2
    80005578:	0ee79163          	bne	a5,a4,8000565a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000557c:	0ac05d63          	blez	a2,80005636 <filewrite+0xf4>
    int i = 0;
    80005580:	4981                	li	s3,0
    80005582:	6b05                	lui	s6,0x1
    80005584:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005588:	6b85                	lui	s7,0x1
    8000558a:	c00b8b9b          	addiw	s7,s7,-1024
    8000558e:	a861                	j	80005626 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005590:	6908                	ld	a0,16(a0)
    80005592:	00000097          	auipc	ra,0x0
    80005596:	424080e7          	jalr	1060(ra) # 800059b6 <pipewrite>
    8000559a:	8a2a                	mv	s4,a0
    8000559c:	a045                	j	8000563c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000559e:	02451783          	lh	a5,36(a0)
    800055a2:	03079693          	slli	a3,a5,0x30
    800055a6:	92c1                	srli	a3,a3,0x30
    800055a8:	4725                	li	a4,9
    800055aa:	0cd76263          	bltu	a4,a3,8000566e <filewrite+0x12c>
    800055ae:	0792                	slli	a5,a5,0x4
    800055b0:	00025717          	auipc	a4,0x25
    800055b4:	76870713          	addi	a4,a4,1896 # 8002ad18 <devsw>
    800055b8:	97ba                	add	a5,a5,a4
    800055ba:	679c                	ld	a5,8(a5)
    800055bc:	cbdd                	beqz	a5,80005672 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800055be:	4505                	li	a0,1
    800055c0:	9782                	jalr	a5
    800055c2:	8a2a                	mv	s4,a0
    800055c4:	a8a5                	j	8000563c <filewrite+0xfa>
    800055c6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800055ca:	00000097          	auipc	ra,0x0
    800055ce:	8b0080e7          	jalr	-1872(ra) # 80004e7a <begin_op>
      ilock(f->ip);
    800055d2:	01893503          	ld	a0,24(s2)
    800055d6:	fffff097          	auipc	ra,0xfffff
    800055da:	bac080e7          	jalr	-1108(ra) # 80004182 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800055de:	8762                	mv	a4,s8
    800055e0:	02092683          	lw	a3,32(s2)
    800055e4:	01598633          	add	a2,s3,s5
    800055e8:	4585                	li	a1,1
    800055ea:	01893503          	ld	a0,24(s2)
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	f40080e7          	jalr	-192(ra) # 8000452e <writei>
    800055f6:	84aa                	mv	s1,a0
    800055f8:	00a05763          	blez	a0,80005606 <filewrite+0xc4>
        f->off += r;
    800055fc:	02092783          	lw	a5,32(s2)
    80005600:	9fa9                	addw	a5,a5,a0
    80005602:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005606:	01893503          	ld	a0,24(s2)
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	c3a080e7          	jalr	-966(ra) # 80004244 <iunlock>
      end_op();
    80005612:	00000097          	auipc	ra,0x0
    80005616:	8e8080e7          	jalr	-1816(ra) # 80004efa <end_op>

      if(r != n1){
    8000561a:	009c1f63          	bne	s8,s1,80005638 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000561e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005622:	0149db63          	bge	s3,s4,80005638 <filewrite+0xf6>
      int n1 = n - i;
    80005626:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000562a:	84be                	mv	s1,a5
    8000562c:	2781                	sext.w	a5,a5
    8000562e:	f8fb5ce3          	bge	s6,a5,800055c6 <filewrite+0x84>
    80005632:	84de                	mv	s1,s7
    80005634:	bf49                	j	800055c6 <filewrite+0x84>
    int i = 0;
    80005636:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005638:	013a1f63          	bne	s4,s3,80005656 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000563c:	8552                	mv	a0,s4
    8000563e:	60a6                	ld	ra,72(sp)
    80005640:	6406                	ld	s0,64(sp)
    80005642:	74e2                	ld	s1,56(sp)
    80005644:	7942                	ld	s2,48(sp)
    80005646:	79a2                	ld	s3,40(sp)
    80005648:	7a02                	ld	s4,32(sp)
    8000564a:	6ae2                	ld	s5,24(sp)
    8000564c:	6b42                	ld	s6,16(sp)
    8000564e:	6ba2                	ld	s7,8(sp)
    80005650:	6c02                	ld	s8,0(sp)
    80005652:	6161                	addi	sp,sp,80
    80005654:	8082                	ret
    ret = (i == n ? n : -1);
    80005656:	5a7d                	li	s4,-1
    80005658:	b7d5                	j	8000563c <filewrite+0xfa>
    panic("filewrite");
    8000565a:	00004517          	auipc	a0,0x4
    8000565e:	73e50513          	addi	a0,a0,1854 # 80009d98 <syscalls+0x2f0>
    80005662:	ffffb097          	auipc	ra,0xffffb
    80005666:	ec8080e7          	jalr	-312(ra) # 8000052a <panic>
    return -1;
    8000566a:	5a7d                	li	s4,-1
    8000566c:	bfc1                	j	8000563c <filewrite+0xfa>
      return -1;
    8000566e:	5a7d                	li	s4,-1
    80005670:	b7f1                	j	8000563c <filewrite+0xfa>
    80005672:	5a7d                	li	s4,-1
    80005674:	b7e1                	j	8000563c <filewrite+0xfa>

0000000080005676 <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    80005676:	7179                	addi	sp,sp,-48
    80005678:	f406                	sd	ra,40(sp)
    8000567a:	f022                	sd	s0,32(sp)
    8000567c:	ec26                	sd	s1,24(sp)
    8000567e:	e84a                	sd	s2,16(sp)
    80005680:	e44e                	sd	s3,8(sp)
    80005682:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005684:	00854783          	lbu	a5,8(a0)
    80005688:	c3d5                	beqz	a5,8000572c <kfileread+0xb6>
    8000568a:	84aa                	mv	s1,a0
    8000568c:	89ae                	mv	s3,a1
    8000568e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005690:	411c                	lw	a5,0(a0)
    80005692:	4705                	li	a4,1
    80005694:	04e78963          	beq	a5,a4,800056e6 <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005698:	470d                	li	a4,3
    8000569a:	04e78d63          	beq	a5,a4,800056f4 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000569e:	4709                	li	a4,2
    800056a0:	06e79e63          	bne	a5,a4,8000571c <kfileread+0xa6>
    ilock(f->ip);
    800056a4:	6d08                	ld	a0,24(a0)
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	adc080e7          	jalr	-1316(ra) # 80004182 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    800056ae:	874a                	mv	a4,s2
    800056b0:	5094                	lw	a3,32(s1)
    800056b2:	864e                	mv	a2,s3
    800056b4:	4581                	li	a1,0
    800056b6:	6c88                	ld	a0,24(s1)
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	d7e080e7          	jalr	-642(ra) # 80004436 <readi>
    800056c0:	892a                	mv	s2,a0
    800056c2:	00a05563          	blez	a0,800056cc <kfileread+0x56>
      f->off += r;
    800056c6:	509c                	lw	a5,32(s1)
    800056c8:	9fa9                	addw	a5,a5,a0
    800056ca:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800056cc:	6c88                	ld	a0,24(s1)
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	b76080e7          	jalr	-1162(ra) # 80004244 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800056d6:	854a                	mv	a0,s2
    800056d8:	70a2                	ld	ra,40(sp)
    800056da:	7402                	ld	s0,32(sp)
    800056dc:	64e2                	ld	s1,24(sp)
    800056de:	6942                	ld	s2,16(sp)
    800056e0:	69a2                	ld	s3,8(sp)
    800056e2:	6145                	addi	sp,sp,48
    800056e4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800056e6:	6908                	ld	a0,16(a0)
    800056e8:	00000097          	auipc	ra,0x0
    800056ec:	3c0080e7          	jalr	960(ra) # 80005aa8 <piperead>
    800056f0:	892a                	mv	s2,a0
    800056f2:	b7d5                	j	800056d6 <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800056f4:	02451783          	lh	a5,36(a0)
    800056f8:	03079693          	slli	a3,a5,0x30
    800056fc:	92c1                	srli	a3,a3,0x30
    800056fe:	4725                	li	a4,9
    80005700:	02d76863          	bltu	a4,a3,80005730 <kfileread+0xba>
    80005704:	0792                	slli	a5,a5,0x4
    80005706:	00025717          	auipc	a4,0x25
    8000570a:	61270713          	addi	a4,a4,1554 # 8002ad18 <devsw>
    8000570e:	97ba                	add	a5,a5,a4
    80005710:	639c                	ld	a5,0(a5)
    80005712:	c38d                	beqz	a5,80005734 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005714:	4505                	li	a0,1
    80005716:	9782                	jalr	a5
    80005718:	892a                	mv	s2,a0
    8000571a:	bf75                	j	800056d6 <kfileread+0x60>
    panic("fileread");
    8000571c:	00004517          	auipc	a0,0x4
    80005720:	66c50513          	addi	a0,a0,1644 # 80009d88 <syscalls+0x2e0>
    80005724:	ffffb097          	auipc	ra,0xffffb
    80005728:	e06080e7          	jalr	-506(ra) # 8000052a <panic>
    return -1;
    8000572c:	597d                	li	s2,-1
    8000572e:	b765                	j	800056d6 <kfileread+0x60>
      return -1;
    80005730:	597d                	li	s2,-1
    80005732:	b755                	j	800056d6 <kfileread+0x60>
    80005734:	597d                	li	s2,-1
    80005736:	b745                	j	800056d6 <kfileread+0x60>

0000000080005738 <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    80005738:	715d                	addi	sp,sp,-80
    8000573a:	e486                	sd	ra,72(sp)
    8000573c:	e0a2                	sd	s0,64(sp)
    8000573e:	fc26                	sd	s1,56(sp)
    80005740:	f84a                	sd	s2,48(sp)
    80005742:	f44e                	sd	s3,40(sp)
    80005744:	f052                	sd	s4,32(sp)
    80005746:	ec56                	sd	s5,24(sp)
    80005748:	e85a                	sd	s6,16(sp)
    8000574a:	e45e                	sd	s7,8(sp)
    8000574c:	e062                	sd	s8,0(sp)
    8000574e:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005750:	00954783          	lbu	a5,9(a0)
    80005754:	10078663          	beqz	a5,80005860 <kfilewrite+0x128>
    80005758:	892a                	mv	s2,a0
    8000575a:	8aae                	mv	s5,a1
    8000575c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000575e:	411c                	lw	a5,0(a0)
    80005760:	4705                	li	a4,1
    80005762:	02e78263          	beq	a5,a4,80005786 <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005766:	470d                	li	a4,3
    80005768:	02e78663          	beq	a5,a4,80005794 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000576c:	4709                	li	a4,2
    8000576e:	0ee79163          	bne	a5,a4,80005850 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005772:	0ac05d63          	blez	a2,8000582c <kfilewrite+0xf4>
    int i = 0;
    80005776:	4981                	li	s3,0
    80005778:	6b05                	lui	s6,0x1
    8000577a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000577e:	6b85                	lui	s7,0x1
    80005780:	c00b8b9b          	addiw	s7,s7,-1024
    80005784:	a861                	j	8000581c <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005786:	6908                	ld	a0,16(a0)
    80005788:	00000097          	auipc	ra,0x0
    8000578c:	22e080e7          	jalr	558(ra) # 800059b6 <pipewrite>
    80005790:	8a2a                	mv	s4,a0
    80005792:	a045                	j	80005832 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005794:	02451783          	lh	a5,36(a0)
    80005798:	03079693          	slli	a3,a5,0x30
    8000579c:	92c1                	srli	a3,a3,0x30
    8000579e:	4725                	li	a4,9
    800057a0:	0cd76263          	bltu	a4,a3,80005864 <kfilewrite+0x12c>
    800057a4:	0792                	slli	a5,a5,0x4
    800057a6:	00025717          	auipc	a4,0x25
    800057aa:	57270713          	addi	a4,a4,1394 # 8002ad18 <devsw>
    800057ae:	97ba                	add	a5,a5,a4
    800057b0:	679c                	ld	a5,8(a5)
    800057b2:	cbdd                	beqz	a5,80005868 <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800057b4:	4505                	li	a0,1
    800057b6:	9782                	jalr	a5
    800057b8:	8a2a                	mv	s4,a0
    800057ba:	a8a5                	j	80005832 <kfilewrite+0xfa>
    800057bc:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	6ba080e7          	jalr	1722(ra) # 80004e7a <begin_op>
      ilock(f->ip);
    800057c8:	01893503          	ld	a0,24(s2)
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	9b6080e7          	jalr	-1610(ra) # 80004182 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    800057d4:	8762                	mv	a4,s8
    800057d6:	02092683          	lw	a3,32(s2)
    800057da:	01598633          	add	a2,s3,s5
    800057de:	4581                	li	a1,0
    800057e0:	01893503          	ld	a0,24(s2)
    800057e4:	fffff097          	auipc	ra,0xfffff
    800057e8:	d4a080e7          	jalr	-694(ra) # 8000452e <writei>
    800057ec:	84aa                	mv	s1,a0
    800057ee:	00a05763          	blez	a0,800057fc <kfilewrite+0xc4>
        f->off += r;
    800057f2:	02092783          	lw	a5,32(s2)
    800057f6:	9fa9                	addw	a5,a5,a0
    800057f8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800057fc:	01893503          	ld	a0,24(s2)
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	a44080e7          	jalr	-1468(ra) # 80004244 <iunlock>
      end_op();
    80005808:	fffff097          	auipc	ra,0xfffff
    8000580c:	6f2080e7          	jalr	1778(ra) # 80004efa <end_op>

      if(r != n1){
    80005810:	009c1f63          	bne	s8,s1,8000582e <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005814:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005818:	0149db63          	bge	s3,s4,8000582e <kfilewrite+0xf6>
      int n1 = n - i;
    8000581c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005820:	84be                	mv	s1,a5
    80005822:	2781                	sext.w	a5,a5
    80005824:	f8fb5ce3          	bge	s6,a5,800057bc <kfilewrite+0x84>
    80005828:	84de                	mv	s1,s7
    8000582a:	bf49                	j	800057bc <kfilewrite+0x84>
    int i = 0;
    8000582c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000582e:	013a1f63          	bne	s4,s3,8000584c <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005832:	8552                	mv	a0,s4
    80005834:	60a6                	ld	ra,72(sp)
    80005836:	6406                	ld	s0,64(sp)
    80005838:	74e2                	ld	s1,56(sp)
    8000583a:	7942                	ld	s2,48(sp)
    8000583c:	79a2                	ld	s3,40(sp)
    8000583e:	7a02                	ld	s4,32(sp)
    80005840:	6ae2                	ld	s5,24(sp)
    80005842:	6b42                	ld	s6,16(sp)
    80005844:	6ba2                	ld	s7,8(sp)
    80005846:	6c02                	ld	s8,0(sp)
    80005848:	6161                	addi	sp,sp,80
    8000584a:	8082                	ret
    ret = (i == n ? n : -1);
    8000584c:	5a7d                	li	s4,-1
    8000584e:	b7d5                	j	80005832 <kfilewrite+0xfa>
    panic("filewrite");
    80005850:	00004517          	auipc	a0,0x4
    80005854:	54850513          	addi	a0,a0,1352 # 80009d98 <syscalls+0x2f0>
    80005858:	ffffb097          	auipc	ra,0xffffb
    8000585c:	cd2080e7          	jalr	-814(ra) # 8000052a <panic>
    return -1;
    80005860:	5a7d                	li	s4,-1
    80005862:	bfc1                	j	80005832 <kfilewrite+0xfa>
      return -1;
    80005864:	5a7d                	li	s4,-1
    80005866:	b7f1                	j	80005832 <kfilewrite+0xfa>
    80005868:	5a7d                	li	s4,-1
    8000586a:	b7e1                	j	80005832 <kfilewrite+0xfa>

000000008000586c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000586c:	7179                	addi	sp,sp,-48
    8000586e:	f406                	sd	ra,40(sp)
    80005870:	f022                	sd	s0,32(sp)
    80005872:	ec26                	sd	s1,24(sp)
    80005874:	e84a                	sd	s2,16(sp)
    80005876:	e44e                	sd	s3,8(sp)
    80005878:	e052                	sd	s4,0(sp)
    8000587a:	1800                	addi	s0,sp,48
    8000587c:	84aa                	mv	s1,a0
    8000587e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005880:	0005b023          	sd	zero,0(a1)
    80005884:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005888:	00000097          	auipc	ra,0x0
    8000588c:	a02080e7          	jalr	-1534(ra) # 8000528a <filealloc>
    80005890:	e088                	sd	a0,0(s1)
    80005892:	c551                	beqz	a0,8000591e <pipealloc+0xb2>
    80005894:	00000097          	auipc	ra,0x0
    80005898:	9f6080e7          	jalr	-1546(ra) # 8000528a <filealloc>
    8000589c:	00aa3023          	sd	a0,0(s4)
    800058a0:	c92d                	beqz	a0,80005912 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800058a2:	ffffb097          	auipc	ra,0xffffb
    800058a6:	230080e7          	jalr	560(ra) # 80000ad2 <kalloc>
    800058aa:	892a                	mv	s2,a0
    800058ac:	c125                	beqz	a0,8000590c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800058ae:	4985                	li	s3,1
    800058b0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800058b4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800058b8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800058bc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800058c0:	00004597          	auipc	a1,0x4
    800058c4:	4e858593          	addi	a1,a1,1256 # 80009da8 <syscalls+0x300>
    800058c8:	ffffb097          	auipc	ra,0xffffb
    800058cc:	26a080e7          	jalr	618(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800058d0:	609c                	ld	a5,0(s1)
    800058d2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800058d6:	609c                	ld	a5,0(s1)
    800058d8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800058dc:	609c                	ld	a5,0(s1)
    800058de:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800058e2:	609c                	ld	a5,0(s1)
    800058e4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800058e8:	000a3783          	ld	a5,0(s4)
    800058ec:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800058f0:	000a3783          	ld	a5,0(s4)
    800058f4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800058f8:	000a3783          	ld	a5,0(s4)
    800058fc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005900:	000a3783          	ld	a5,0(s4)
    80005904:	0127b823          	sd	s2,16(a5)
  return 0;
    80005908:	4501                	li	a0,0
    8000590a:	a025                	j	80005932 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000590c:	6088                	ld	a0,0(s1)
    8000590e:	e501                	bnez	a0,80005916 <pipealloc+0xaa>
    80005910:	a039                	j	8000591e <pipealloc+0xb2>
    80005912:	6088                	ld	a0,0(s1)
    80005914:	c51d                	beqz	a0,80005942 <pipealloc+0xd6>
    fileclose(*f0);
    80005916:	00000097          	auipc	ra,0x0
    8000591a:	a30080e7          	jalr	-1488(ra) # 80005346 <fileclose>
  if(*f1)
    8000591e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005922:	557d                	li	a0,-1
  if(*f1)
    80005924:	c799                	beqz	a5,80005932 <pipealloc+0xc6>
    fileclose(*f1);
    80005926:	853e                	mv	a0,a5
    80005928:	00000097          	auipc	ra,0x0
    8000592c:	a1e080e7          	jalr	-1506(ra) # 80005346 <fileclose>
  return -1;
    80005930:	557d                	li	a0,-1
}
    80005932:	70a2                	ld	ra,40(sp)
    80005934:	7402                	ld	s0,32(sp)
    80005936:	64e2                	ld	s1,24(sp)
    80005938:	6942                	ld	s2,16(sp)
    8000593a:	69a2                	ld	s3,8(sp)
    8000593c:	6a02                	ld	s4,0(sp)
    8000593e:	6145                	addi	sp,sp,48
    80005940:	8082                	ret
  return -1;
    80005942:	557d                	li	a0,-1
    80005944:	b7fd                	j	80005932 <pipealloc+0xc6>

0000000080005946 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005946:	1101                	addi	sp,sp,-32
    80005948:	ec06                	sd	ra,24(sp)
    8000594a:	e822                	sd	s0,16(sp)
    8000594c:	e426                	sd	s1,8(sp)
    8000594e:	e04a                	sd	s2,0(sp)
    80005950:	1000                	addi	s0,sp,32
    80005952:	84aa                	mv	s1,a0
    80005954:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005956:	ffffb097          	auipc	ra,0xffffb
    8000595a:	26c080e7          	jalr	620(ra) # 80000bc2 <acquire>
  if(writable){
    8000595e:	02090d63          	beqz	s2,80005998 <pipeclose+0x52>
    pi->writeopen = 0;
    80005962:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005966:	21848513          	addi	a0,s1,536
    8000596a:	ffffd097          	auipc	ra,0xffffd
    8000596e:	a4a080e7          	jalr	-1462(ra) # 800023b4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005972:	2204b783          	ld	a5,544(s1)
    80005976:	eb95                	bnez	a5,800059aa <pipeclose+0x64>
    release(&pi->lock);
    80005978:	8526                	mv	a0,s1
    8000597a:	ffffb097          	auipc	ra,0xffffb
    8000597e:	2fc080e7          	jalr	764(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005982:	8526                	mv	a0,s1
    80005984:	ffffb097          	auipc	ra,0xffffb
    80005988:	052080e7          	jalr	82(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    8000598c:	60e2                	ld	ra,24(sp)
    8000598e:	6442                	ld	s0,16(sp)
    80005990:	64a2                	ld	s1,8(sp)
    80005992:	6902                	ld	s2,0(sp)
    80005994:	6105                	addi	sp,sp,32
    80005996:	8082                	ret
    pi->readopen = 0;
    80005998:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000599c:	21c48513          	addi	a0,s1,540
    800059a0:	ffffd097          	auipc	ra,0xffffd
    800059a4:	a14080e7          	jalr	-1516(ra) # 800023b4 <wakeup>
    800059a8:	b7e9                	j	80005972 <pipeclose+0x2c>
    release(&pi->lock);
    800059aa:	8526                	mv	a0,s1
    800059ac:	ffffb097          	auipc	ra,0xffffb
    800059b0:	2ca080e7          	jalr	714(ra) # 80000c76 <release>
}
    800059b4:	bfe1                	j	8000598c <pipeclose+0x46>

00000000800059b6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800059b6:	711d                	addi	sp,sp,-96
    800059b8:	ec86                	sd	ra,88(sp)
    800059ba:	e8a2                	sd	s0,80(sp)
    800059bc:	e4a6                	sd	s1,72(sp)
    800059be:	e0ca                	sd	s2,64(sp)
    800059c0:	fc4e                	sd	s3,56(sp)
    800059c2:	f852                	sd	s4,48(sp)
    800059c4:	f456                	sd	s5,40(sp)
    800059c6:	f05a                	sd	s6,32(sp)
    800059c8:	ec5e                	sd	s7,24(sp)
    800059ca:	e862                	sd	s8,16(sp)
    800059cc:	1080                	addi	s0,sp,96
    800059ce:	84aa                	mv	s1,a0
    800059d0:	8aae                	mv	s5,a1
    800059d2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	35c080e7          	jalr	860(ra) # 80001d30 <myproc>
    800059dc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffb097          	auipc	ra,0xffffb
    800059e4:	1e2080e7          	jalr	482(ra) # 80000bc2 <acquire>
  while(i < n){
    800059e8:	0b405363          	blez	s4,80005a8e <pipewrite+0xd8>
  int i = 0;
    800059ec:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800059ee:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800059f0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800059f4:	21c48b93          	addi	s7,s1,540
    800059f8:	a089                	j	80005a3a <pipewrite+0x84>
      release(&pi->lock);
    800059fa:	8526                	mv	a0,s1
    800059fc:	ffffb097          	auipc	ra,0xffffb
    80005a00:	27a080e7          	jalr	634(ra) # 80000c76 <release>
      return -1;
    80005a04:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005a06:	854a                	mv	a0,s2
    80005a08:	60e6                	ld	ra,88(sp)
    80005a0a:	6446                	ld	s0,80(sp)
    80005a0c:	64a6                	ld	s1,72(sp)
    80005a0e:	6906                	ld	s2,64(sp)
    80005a10:	79e2                	ld	s3,56(sp)
    80005a12:	7a42                	ld	s4,48(sp)
    80005a14:	7aa2                	ld	s5,40(sp)
    80005a16:	7b02                	ld	s6,32(sp)
    80005a18:	6be2                	ld	s7,24(sp)
    80005a1a:	6c42                	ld	s8,16(sp)
    80005a1c:	6125                	addi	sp,sp,96
    80005a1e:	8082                	ret
      wakeup(&pi->nread);
    80005a20:	8562                	mv	a0,s8
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	992080e7          	jalr	-1646(ra) # 800023b4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005a2a:	85a6                	mv	a1,s1
    80005a2c:	855e                	mv	a0,s7
    80005a2e:	ffffc097          	auipc	ra,0xffffc
    80005a32:	7fa080e7          	jalr	2042(ra) # 80002228 <sleep>
  while(i < n){
    80005a36:	05495d63          	bge	s2,s4,80005a90 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005a3a:	2204a783          	lw	a5,544(s1)
    80005a3e:	dfd5                	beqz	a5,800059fa <pipewrite+0x44>
    80005a40:	0289a783          	lw	a5,40(s3)
    80005a44:	fbdd                	bnez	a5,800059fa <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005a46:	2184a783          	lw	a5,536(s1)
    80005a4a:	21c4a703          	lw	a4,540(s1)
    80005a4e:	2007879b          	addiw	a5,a5,512
    80005a52:	fcf707e3          	beq	a4,a5,80005a20 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005a56:	4685                	li	a3,1
    80005a58:	01590633          	add	a2,s2,s5
    80005a5c:	faf40593          	addi	a1,s0,-81
    80005a60:	0509b503          	ld	a0,80(s3)
    80005a64:	ffffc097          	auipc	ra,0xffffc
    80005a68:	9bc080e7          	jalr	-1604(ra) # 80001420 <copyin>
    80005a6c:	03650263          	beq	a0,s6,80005a90 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005a70:	21c4a783          	lw	a5,540(s1)
    80005a74:	0017871b          	addiw	a4,a5,1
    80005a78:	20e4ae23          	sw	a4,540(s1)
    80005a7c:	1ff7f793          	andi	a5,a5,511
    80005a80:	97a6                	add	a5,a5,s1
    80005a82:	faf44703          	lbu	a4,-81(s0)
    80005a86:	00e78c23          	sb	a4,24(a5)
      i++;
    80005a8a:	2905                	addiw	s2,s2,1
    80005a8c:	b76d                	j	80005a36 <pipewrite+0x80>
  int i = 0;
    80005a8e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005a90:	21848513          	addi	a0,s1,536
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	920080e7          	jalr	-1760(ra) # 800023b4 <wakeup>
  release(&pi->lock);
    80005a9c:	8526                	mv	a0,s1
    80005a9e:	ffffb097          	auipc	ra,0xffffb
    80005aa2:	1d8080e7          	jalr	472(ra) # 80000c76 <release>
  return i;
    80005aa6:	b785                	j	80005a06 <pipewrite+0x50>

0000000080005aa8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005aa8:	715d                	addi	sp,sp,-80
    80005aaa:	e486                	sd	ra,72(sp)
    80005aac:	e0a2                	sd	s0,64(sp)
    80005aae:	fc26                	sd	s1,56(sp)
    80005ab0:	f84a                	sd	s2,48(sp)
    80005ab2:	f44e                	sd	s3,40(sp)
    80005ab4:	f052                	sd	s4,32(sp)
    80005ab6:	ec56                	sd	s5,24(sp)
    80005ab8:	e85a                	sd	s6,16(sp)
    80005aba:	0880                	addi	s0,sp,80
    80005abc:	84aa                	mv	s1,a0
    80005abe:	892e                	mv	s2,a1
    80005ac0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005ac2:	ffffc097          	auipc	ra,0xffffc
    80005ac6:	26e080e7          	jalr	622(ra) # 80001d30 <myproc>
    80005aca:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005acc:	8526                	mv	a0,s1
    80005ace:	ffffb097          	auipc	ra,0xffffb
    80005ad2:	0f4080e7          	jalr	244(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ad6:	2184a703          	lw	a4,536(s1)
    80005ada:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005ade:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ae2:	02f71463          	bne	a4,a5,80005b0a <piperead+0x62>
    80005ae6:	2244a783          	lw	a5,548(s1)
    80005aea:	c385                	beqz	a5,80005b0a <piperead+0x62>
    if(pr->killed){
    80005aec:	028a2783          	lw	a5,40(s4)
    80005af0:	ebc1                	bnez	a5,80005b80 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005af2:	85a6                	mv	a1,s1
    80005af4:	854e                	mv	a0,s3
    80005af6:	ffffc097          	auipc	ra,0xffffc
    80005afa:	732080e7          	jalr	1842(ra) # 80002228 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005afe:	2184a703          	lw	a4,536(s1)
    80005b02:	21c4a783          	lw	a5,540(s1)
    80005b06:	fef700e3          	beq	a4,a5,80005ae6 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b0a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b0c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b0e:	05505363          	blez	s5,80005b54 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005b12:	2184a783          	lw	a5,536(s1)
    80005b16:	21c4a703          	lw	a4,540(s1)
    80005b1a:	02f70d63          	beq	a4,a5,80005b54 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005b1e:	0017871b          	addiw	a4,a5,1
    80005b22:	20e4ac23          	sw	a4,536(s1)
    80005b26:	1ff7f793          	andi	a5,a5,511
    80005b2a:	97a6                	add	a5,a5,s1
    80005b2c:	0187c783          	lbu	a5,24(a5)
    80005b30:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005b34:	4685                	li	a3,1
    80005b36:	fbf40613          	addi	a2,s0,-65
    80005b3a:	85ca                	mv	a1,s2
    80005b3c:	050a3503          	ld	a0,80(s4)
    80005b40:	ffffc097          	auipc	ra,0xffffc
    80005b44:	852080e7          	jalr	-1966(ra) # 80001392 <copyout>
    80005b48:	01650663          	beq	a0,s6,80005b54 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005b4c:	2985                	addiw	s3,s3,1
    80005b4e:	0905                	addi	s2,s2,1
    80005b50:	fd3a91e3          	bne	s5,s3,80005b12 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005b54:	21c48513          	addi	a0,s1,540
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	85c080e7          	jalr	-1956(ra) # 800023b4 <wakeup>
  release(&pi->lock);
    80005b60:	8526                	mv	a0,s1
    80005b62:	ffffb097          	auipc	ra,0xffffb
    80005b66:	114080e7          	jalr	276(ra) # 80000c76 <release>
  return i;
}
    80005b6a:	854e                	mv	a0,s3
    80005b6c:	60a6                	ld	ra,72(sp)
    80005b6e:	6406                	ld	s0,64(sp)
    80005b70:	74e2                	ld	s1,56(sp)
    80005b72:	7942                	ld	s2,48(sp)
    80005b74:	79a2                	ld	s3,40(sp)
    80005b76:	7a02                	ld	s4,32(sp)
    80005b78:	6ae2                	ld	s5,24(sp)
    80005b7a:	6b42                	ld	s6,16(sp)
    80005b7c:	6161                	addi	sp,sp,80
    80005b7e:	8082                	ret
      release(&pi->lock);
    80005b80:	8526                	mv	a0,s1
    80005b82:	ffffb097          	auipc	ra,0xffffb
    80005b86:	0f4080e7          	jalr	244(ra) # 80000c76 <release>
      return -1;
    80005b8a:	59fd                	li	s3,-1
    80005b8c:	bff9                	j	80005b6a <piperead+0xc2>

0000000080005b8e <exec>:
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int exec(char *path, char **argv)
{
    80005b8e:	de010113          	addi	sp,sp,-544
    80005b92:	20113c23          	sd	ra,536(sp)
    80005b96:	20813823          	sd	s0,528(sp)
    80005b9a:	20913423          	sd	s1,520(sp)
    80005b9e:	21213023          	sd	s2,512(sp)
    80005ba2:	ffce                	sd	s3,504(sp)
    80005ba4:	fbd2                	sd	s4,496(sp)
    80005ba6:	f7d6                	sd	s5,488(sp)
    80005ba8:	f3da                	sd	s6,480(sp)
    80005baa:	efde                	sd	s7,472(sp)
    80005bac:	ebe2                	sd	s8,464(sp)
    80005bae:	e7e6                	sd	s9,456(sp)
    80005bb0:	e3ea                	sd	s10,448(sp)
    80005bb2:	ff6e                	sd	s11,440(sp)
    80005bb4:	1400                	addi	s0,sp,544
    80005bb6:	892a                	mv	s2,a0
    80005bb8:	dea43423          	sd	a0,-536(s0)
    80005bbc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005bc0:	ffffc097          	auipc	ra,0xffffc
    80005bc4:	170080e7          	jalr	368(ra) # 80001d30 <myproc>
    80005bc8:	84aa                	mv	s1,a0

  begin_op();
    80005bca:	fffff097          	auipc	ra,0xfffff
    80005bce:	2b0080e7          	jalr	688(ra) # 80004e7a <begin_op>

  if ((ip = namei(path)) == 0)
    80005bd2:	854a                	mv	a0,s2
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	d64080e7          	jalr	-668(ra) # 80004938 <namei>
    80005bdc:	c93d                	beqz	a0,80005c52 <exec+0xc4>
    80005bde:	8aaa                	mv	s5,a0
  {
    end_op();
    return -1;
  }
  ilock(ip);
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	5a2080e7          	jalr	1442(ra) # 80004182 <ilock>

  // Check ELF header
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005be8:	04000713          	li	a4,64
    80005bec:	4681                	li	a3,0
    80005bee:	e4840613          	addi	a2,s0,-440
    80005bf2:	4581                	li	a1,0
    80005bf4:	8556                	mv	a0,s5
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	840080e7          	jalr	-1984(ra) # 80004436 <readi>
    80005bfe:	04000793          	li	a5,64
    80005c02:	00f51a63          	bne	a0,a5,80005c16 <exec+0x88>
    goto bad;
  if (elf.magic != ELF_MAGIC)
    80005c06:	e4842703          	lw	a4,-440(s0)
    80005c0a:	464c47b7          	lui	a5,0x464c4
    80005c0e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005c12:	04f70663          	beq	a4,a5,80005c5e <exec+0xd0>
bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip)
  {
    iunlockput(ip);
    80005c16:	8556                	mv	a0,s5
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	7cc080e7          	jalr	1996(ra) # 800043e4 <iunlockput>
    end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	2da080e7          	jalr	730(ra) # 80004efa <end_op>
  }
  return -1;
    80005c28:	557d                	li	a0,-1
}
    80005c2a:	21813083          	ld	ra,536(sp)
    80005c2e:	21013403          	ld	s0,528(sp)
    80005c32:	20813483          	ld	s1,520(sp)
    80005c36:	20013903          	ld	s2,512(sp)
    80005c3a:	79fe                	ld	s3,504(sp)
    80005c3c:	7a5e                	ld	s4,496(sp)
    80005c3e:	7abe                	ld	s5,488(sp)
    80005c40:	7b1e                	ld	s6,480(sp)
    80005c42:	6bfe                	ld	s7,472(sp)
    80005c44:	6c5e                	ld	s8,464(sp)
    80005c46:	6cbe                	ld	s9,456(sp)
    80005c48:	6d1e                	ld	s10,448(sp)
    80005c4a:	7dfa                	ld	s11,440(sp)
    80005c4c:	22010113          	addi	sp,sp,544
    80005c50:	8082                	ret
    end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	2a8080e7          	jalr	680(ra) # 80004efa <end_op>
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	b7f9                	j	80005c2a <exec+0x9c>
  if ((pagetable = proc_pagetable(p)) == 0)
    80005c5e:	8526                	mv	a0,s1
    80005c60:	ffffc097          	auipc	ra,0xffffc
    80005c64:	194080e7          	jalr	404(ra) # 80001df4 <proc_pagetable>
    80005c68:	8b2a                	mv	s6,a0
    80005c6a:	d555                	beqz	a0,80005c16 <exec+0x88>
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005c6c:	e6842783          	lw	a5,-408(s0)
    80005c70:	e8045703          	lhu	a4,-384(s0)
    80005c74:	c73d                	beqz	a4,80005ce2 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005c76:	4481                	li	s1,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005c78:	e0043423          	sd	zero,-504(s0)
    if (ph.vaddr % PGSIZE != 0)
    80005c7c:	6a05                	lui	s4,0x1
    80005c7e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005c82:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if ((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for (i = 0; i < sz; i += PGSIZE)
    80005c86:	6d85                	lui	s11,0x1
    80005c88:	7d7d                	lui	s10,0xfffff
    80005c8a:	ac61                	j	80005f22 <exec+0x394>
  {
    pa = walkaddr(pagetable, va + i, 0);
    if (pa == 0)
      panic("loadseg: address should exist");
    80005c8c:	00004517          	auipc	a0,0x4
    80005c90:	12450513          	addi	a0,a0,292 # 80009db0 <syscalls+0x308>
    80005c94:	ffffb097          	auipc	ra,0xffffb
    80005c98:	896080e7          	jalr	-1898(ra) # 8000052a <panic>
    if (sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80005c9c:	874a                	mv	a4,s2
    80005c9e:	009c86bb          	addw	a3,s9,s1
    80005ca2:	4581                	li	a1,0
    80005ca4:	8556                	mv	a0,s5
    80005ca6:	ffffe097          	auipc	ra,0xffffe
    80005caa:	790080e7          	jalr	1936(ra) # 80004436 <readi>
    80005cae:	2501                	sext.w	a0,a0
    80005cb0:	20a91963          	bne	s2,a0,80005ec2 <exec+0x334>
  for (i = 0; i < sz; i += PGSIZE)
    80005cb4:	009d84bb          	addw	s1,s11,s1
    80005cb8:	013d09bb          	addw	s3,s10,s3
    80005cbc:	2574f363          	bgeu	s1,s7,80005f02 <exec+0x374>
    pa = walkaddr(pagetable, va + i, 0);
    80005cc0:	02049593          	slli	a1,s1,0x20
    80005cc4:	9181                	srli	a1,a1,0x20
    80005cc6:	4601                	li	a2,0
    80005cc8:	95e2                	add	a1,a1,s8
    80005cca:	855a                	mv	a0,s6
    80005ccc:	ffffb097          	auipc	ra,0xffffb
    80005cd0:	380080e7          	jalr	896(ra) # 8000104c <walkaddr>
    80005cd4:	862a                	mv	a2,a0
    if (pa == 0)
    80005cd6:	d95d                	beqz	a0,80005c8c <exec+0xfe>
      n = PGSIZE;
    80005cd8:	8952                	mv	s2,s4
    if (sz - i < PGSIZE)
    80005cda:	fd49f1e3          	bgeu	s3,s4,80005c9c <exec+0x10e>
      n = sz - i;
    80005cde:	894e                	mv	s2,s3
    80005ce0:	bf75                	j	80005c9c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG + 1], stackbase;
    80005ce2:	4481                	li	s1,0
  iunlockput(ip);
    80005ce4:	8556                	mv	a0,s5
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	6fe080e7          	jalr	1790(ra) # 800043e4 <iunlockput>
  end_op();
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	20c080e7          	jalr	524(ra) # 80004efa <end_op>
  p = myproc();
    80005cf6:	ffffc097          	auipc	ra,0xffffc
    80005cfa:	03a080e7          	jalr	58(ra) # 80001d30 <myproc>
    80005cfe:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005d00:	04853d83          	ld	s11,72(a0)
  sz = PGROUNDUP(sz);
    80005d04:	6785                	lui	a5,0x1
    80005d06:	17fd                	addi	a5,a5,-1
    80005d08:	94be                	add	s1,s1,a5
    80005d0a:	77fd                	lui	a5,0xfffff
    80005d0c:	8fe5                	and	a5,a5,s1
    80005d0e:	def43c23          	sd	a5,-520(s0)
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005d12:	6609                	lui	a2,0x2
    80005d14:	963e                	add	a2,a2,a5
    80005d16:	85be                	mv	a1,a5
    80005d18:	855a                	mv	a0,s6
    80005d1a:	ffffc097          	auipc	ra,0xffffc
    80005d1e:	bf0080e7          	jalr	-1040(ra) # 8000190a <uvmalloc>
    80005d22:	8d2a                	mv	s10,a0
  ip = 0;
    80005d24:	4a81                	li	s5,0
  if ((sz1 = uvmalloc(pagetable, sz, sz + 2 * PGSIZE)) == 0)
    80005d26:	18050e63          	beqz	a0,80005ec2 <exec+0x334>
  uvmclear(pagetable, sz - 2 * PGSIZE);
    80005d2a:	75f9                	lui	a1,0xffffe
    80005d2c:	95aa                	add	a1,a1,a0
    80005d2e:	855a                	mv	a0,s6
    80005d30:	ffffb097          	auipc	ra,0xffffb
    80005d34:	630080e7          	jalr	1584(ra) # 80001360 <uvmclear>
  stackbase = sp - PGSIZE;
    80005d38:	7afd                	lui	s5,0xfffff
    80005d3a:	9aea                	add	s5,s5,s10
  for (argc = 0; argv[argc]; argc++)
    80005d3c:	df043783          	ld	a5,-528(s0)
    80005d40:	6388                	ld	a0,0(a5)
    80005d42:	c149                	beqz	a0,80005dc4 <exec+0x236>
    80005d44:	e8840993          	addi	s3,s0,-376
    80005d48:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005d4c:	896a                	mv	s2,s10
  for (argc = 0; argv[argc]; argc++)
    80005d4e:	4481                	li	s1,0
    printf("copyout in exec 1\n"); //TODO: delete
    80005d50:	00004c17          	auipc	s8,0x4
    80005d54:	080c0c13          	addi	s8,s8,128 # 80009dd0 <syscalls+0x328>
    sp -= strlen(argv[argc]) + 1;
    80005d58:	ffffb097          	auipc	ra,0xffffb
    80005d5c:	0ea080e7          	jalr	234(ra) # 80000e42 <strlen>
    80005d60:	0015079b          	addiw	a5,a0,1
    80005d64:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005d68:	ff097913          	andi	s2,s2,-16
    if (sp < stackbase)
    80005d6c:	17596f63          	bltu	s2,s5,80005eea <exec+0x35c>
    printf("copyout in exec 1\n"); //TODO: delete
    80005d70:	8562                	mv	a0,s8
    80005d72:	ffffb097          	auipc	ra,0xffffb
    80005d76:	802080e7          	jalr	-2046(ra) # 80000574 <printf>
    if (copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005d7a:	df043783          	ld	a5,-528(s0)
    80005d7e:	0007ba03          	ld	s4,0(a5) # fffffffffffff000 <end+0xffffffff7ffd0000>
    80005d82:	8552                	mv	a0,s4
    80005d84:	ffffb097          	auipc	ra,0xffffb
    80005d88:	0be080e7          	jalr	190(ra) # 80000e42 <strlen>
    80005d8c:	0015069b          	addiw	a3,a0,1
    80005d90:	8652                	mv	a2,s4
    80005d92:	85ca                	mv	a1,s2
    80005d94:	855a                	mv	a0,s6
    80005d96:	ffffb097          	auipc	ra,0xffffb
    80005d9a:	5fc080e7          	jalr	1532(ra) # 80001392 <copyout>
    80005d9e:	14054a63          	bltz	a0,80005ef2 <exec+0x364>
    ustack[argc] = sp;
    80005da2:	0129b023          	sd	s2,0(s3)
  for (argc = 0; argv[argc]; argc++)
    80005da6:	0485                	addi	s1,s1,1
    80005da8:	df043783          	ld	a5,-528(s0)
    80005dac:	07a1                	addi	a5,a5,8
    80005dae:	def43823          	sd	a5,-528(s0)
    80005db2:	6388                	ld	a0,0(a5)
    80005db4:	c911                	beqz	a0,80005dc8 <exec+0x23a>
    if (argc >= MAXARG)
    80005db6:	09a1                	addi	s3,s3,8
    80005db8:	fb3c90e3          	bne	s9,s3,80005d58 <exec+0x1ca>
  sz = sz1;
    80005dbc:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005dc0:	4a81                	li	s5,0
    80005dc2:	a201                	j	80005ec2 <exec+0x334>
  sp = sz;
    80005dc4:	896a                	mv	s2,s10
  for (argc = 0; argv[argc]; argc++)
    80005dc6:	4481                	li	s1,0
  ustack[argc] = 0;
    80005dc8:	00349793          	slli	a5,s1,0x3
    80005dcc:	f9040713          	addi	a4,s0,-112
    80005dd0:	97ba                	add	a5,a5,a4
    80005dd2:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80005dd6:	00148993          	addi	s3,s1,1
    80005dda:	098e                	slli	s3,s3,0x3
    80005ddc:	41390933          	sub	s2,s2,s3
  sp -= sp % 16;
    80005de0:	ff097913          	andi	s2,s2,-16
  if (sp < stackbase)
    80005de4:	01597663          	bgeu	s2,s5,80005df0 <exec+0x262>
  sz = sz1;
    80005de8:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005dec:	4a81                	li	s5,0
    80005dee:	a8d1                	j	80005ec2 <exec+0x334>
  printf("copyout in exec 2\n"); //TODO: delete
    80005df0:	00004517          	auipc	a0,0x4
    80005df4:	ff850513          	addi	a0,a0,-8 # 80009de8 <syscalls+0x340>
    80005df8:	ffffa097          	auipc	ra,0xffffa
    80005dfc:	77c080e7          	jalr	1916(ra) # 80000574 <printf>
  if (copyout(pagetable, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) < 0)
    80005e00:	86ce                	mv	a3,s3
    80005e02:	e8840613          	addi	a2,s0,-376
    80005e06:	85ca                	mv	a1,s2
    80005e08:	855a                	mv	a0,s6
    80005e0a:	ffffb097          	auipc	ra,0xffffb
    80005e0e:	588080e7          	jalr	1416(ra) # 80001392 <copyout>
    80005e12:	0e054463          	bltz	a0,80005efa <exec+0x36c>
  p->trapframe->a1 = sp;
    80005e16:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80005e1a:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    80005e1e:	de843783          	ld	a5,-536(s0)
    80005e22:	0007c703          	lbu	a4,0(a5)
    80005e26:	cf11                	beqz	a4,80005e42 <exec+0x2b4>
    80005e28:	0785                	addi	a5,a5,1
    if (*s == '/')
    80005e2a:	02f00693          	li	a3,47
    80005e2e:	a039                	j	80005e3c <exec+0x2ae>
      last = s + 1;
    80005e30:	def43423          	sd	a5,-536(s0)
  for (last = s = path; *s; s++)
    80005e34:	0785                	addi	a5,a5,1
    80005e36:	fff7c703          	lbu	a4,-1(a5)
    80005e3a:	c701                	beqz	a4,80005e42 <exec+0x2b4>
    if (*s == '/')
    80005e3c:	fed71ce3          	bne	a4,a3,80005e34 <exec+0x2a6>
    80005e40:	bfc5                	j	80005e30 <exec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    80005e42:	4641                	li	a2,16
    80005e44:	de843583          	ld	a1,-536(s0)
    80005e48:	158b8513          	addi	a0,s7,344
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	fc4080e7          	jalr	-60(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005e54:	050bb983          	ld	s3,80(s7)
  p->pagetable = pagetable;
    80005e58:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005e5c:	05abb423          	sd	s10,72(s7)
  p->trapframe->epc = elf.entry; // initial program counter = main
    80005e60:	058bb783          	ld	a5,88(s7)
    80005e64:	e6043703          	ld	a4,-416(s0)
    80005e68:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80005e6a:	058bb783          	ld	a5,88(s7)
    80005e6e:	0327b823          	sd	s2,48(a5)
  printf("before freepagetable\n");
    80005e72:	00004517          	auipc	a0,0x4
    80005e76:	f8e50513          	addi	a0,a0,-114 # 80009e00 <syscalls+0x358>
    80005e7a:	ffffa097          	auipc	ra,0xffffa
    80005e7e:	6fa080e7          	jalr	1786(ra) # 80000574 <printf>
  proc_freepagetable(oldpagetable, oldsz); // also remove swapfile
    80005e82:	85ee                	mv	a1,s11
    80005e84:	854e                	mv	a0,s3
    80005e86:	ffffc097          	auipc	ra,0xffffc
    80005e8a:	00a080e7          	jalr	10(ra) # 80001e90 <proc_freepagetable>
  printf("after freepagetable\n");
    80005e8e:	00004517          	auipc	a0,0x4
    80005e92:	f8a50513          	addi	a0,a0,-118 # 80009e18 <syscalls+0x370>
    80005e96:	ffffa097          	auipc	ra,0xffffa
    80005e9a:	6de080e7          	jalr	1758(ra) # 80000574 <printf>
  if(p->pid >2){
    80005e9e:	030ba703          	lw	a4,48(s7)
    80005ea2:	4789                	li	a5,2
    80005ea4:	00e7da63          	bge	a5,a4,80005eb8 <exec+0x32a>
    p->physical_pages_num = 0;
    80005ea8:	160ba823          	sw	zero,368(s7)
    p->total_pages_num = 0;
    80005eac:	160baa23          	sw	zero,372(s7)
    p->pages_physc_info.free_spaces = 0;
    80005eb0:	280b9023          	sh	zero,640(s7)
    p->pages_swap_info.free_spaces = 0;
    80005eb4:	160b9c23          	sh	zero,376(s7)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005eb8:	0004851b          	sext.w	a0,s1
    80005ebc:	b3bd                	j	80005c2a <exec+0x9c>
    80005ebe:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005ec2:	df843583          	ld	a1,-520(s0)
    80005ec6:	855a                	mv	a0,s6
    80005ec8:	ffffc097          	auipc	ra,0xffffc
    80005ecc:	fc8080e7          	jalr	-56(ra) # 80001e90 <proc_freepagetable>
  if (ip)
    80005ed0:	d40a93e3          	bnez	s5,80005c16 <exec+0x88>
  return -1;
    80005ed4:	557d                	li	a0,-1
    80005ed6:	bb91                	j	80005c2a <exec+0x9c>
    80005ed8:	de943c23          	sd	s1,-520(s0)
    80005edc:	b7dd                	j	80005ec2 <exec+0x334>
    80005ede:	de943c23          	sd	s1,-520(s0)
    80005ee2:	b7c5                	j	80005ec2 <exec+0x334>
    80005ee4:	de943c23          	sd	s1,-520(s0)
    80005ee8:	bfe9                	j	80005ec2 <exec+0x334>
  sz = sz1;
    80005eea:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005eee:	4a81                	li	s5,0
    80005ef0:	bfc9                	j	80005ec2 <exec+0x334>
  sz = sz1;
    80005ef2:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005ef6:	4a81                	li	s5,0
    80005ef8:	b7e9                	j	80005ec2 <exec+0x334>
  sz = sz1;
    80005efa:	dfa43c23          	sd	s10,-520(s0)
  ip = 0;
    80005efe:	4a81                	li	s5,0
    80005f00:	b7c9                	j	80005ec2 <exec+0x334>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005f02:	df843483          	ld	s1,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph))
    80005f06:	e0843783          	ld	a5,-504(s0)
    80005f0a:	0017869b          	addiw	a3,a5,1
    80005f0e:	e0d43423          	sd	a3,-504(s0)
    80005f12:	e0043783          	ld	a5,-512(s0)
    80005f16:	0387879b          	addiw	a5,a5,56
    80005f1a:	e8045703          	lhu	a4,-384(s0)
    80005f1e:	dce6d3e3          	bge	a3,a4,80005ce4 <exec+0x156>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005f22:	2781                	sext.w	a5,a5
    80005f24:	e0f43023          	sd	a5,-512(s0)
    80005f28:	03800713          	li	a4,56
    80005f2c:	86be                	mv	a3,a5
    80005f2e:	e1040613          	addi	a2,s0,-496
    80005f32:	4581                	li	a1,0
    80005f34:	8556                	mv	a0,s5
    80005f36:	ffffe097          	auipc	ra,0xffffe
    80005f3a:	500080e7          	jalr	1280(ra) # 80004436 <readi>
    80005f3e:	03800793          	li	a5,56
    80005f42:	f6f51ee3          	bne	a0,a5,80005ebe <exec+0x330>
    if (ph.type != ELF_PROG_LOAD)
    80005f46:	e1042783          	lw	a5,-496(s0)
    80005f4a:	4705                	li	a4,1
    80005f4c:	fae79de3          	bne	a5,a4,80005f06 <exec+0x378>
    if (ph.memsz < ph.filesz)
    80005f50:	e3843603          	ld	a2,-456(s0)
    80005f54:	e3043783          	ld	a5,-464(s0)
    80005f58:	f8f660e3          	bltu	a2,a5,80005ed8 <exec+0x34a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80005f5c:	e2043783          	ld	a5,-480(s0)
    80005f60:	963e                	add	a2,a2,a5
    80005f62:	f6f66ee3          	bltu	a2,a5,80005ede <exec+0x350>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005f66:	85a6                	mv	a1,s1
    80005f68:	855a                	mv	a0,s6
    80005f6a:	ffffc097          	auipc	ra,0xffffc
    80005f6e:	9a0080e7          	jalr	-1632(ra) # 8000190a <uvmalloc>
    80005f72:	dea43c23          	sd	a0,-520(s0)
    80005f76:	d53d                	beqz	a0,80005ee4 <exec+0x356>
    if (ph.vaddr % PGSIZE != 0)
    80005f78:	e2043c03          	ld	s8,-480(s0)
    80005f7c:	de043783          	ld	a5,-544(s0)
    80005f80:	00fc77b3          	and	a5,s8,a5
    80005f84:	ff9d                	bnez	a5,80005ec2 <exec+0x334>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005f86:	e1842c83          	lw	s9,-488(s0)
    80005f8a:	e3042b83          	lw	s7,-464(s0)
  for (i = 0; i < sz; i += PGSIZE)
    80005f8e:	f60b8ae3          	beqz	s7,80005f02 <exec+0x374>
    80005f92:	89de                	mv	s3,s7
    80005f94:	4481                	li	s1,0
    80005f96:	b32d                	j	80005cc0 <exec+0x132>

0000000080005f98 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005f98:	7179                	addi	sp,sp,-48
    80005f9a:	f406                	sd	ra,40(sp)
    80005f9c:	f022                	sd	s0,32(sp)
    80005f9e:	ec26                	sd	s1,24(sp)
    80005fa0:	e84a                	sd	s2,16(sp)
    80005fa2:	1800                	addi	s0,sp,48
    80005fa4:	892e                	mv	s2,a1
    80005fa6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005fa8:	fdc40593          	addi	a1,s0,-36
    80005fac:	ffffd097          	auipc	ra,0xffffd
    80005fb0:	664080e7          	jalr	1636(ra) # 80003610 <argint>
    80005fb4:	04054063          	bltz	a0,80005ff4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005fb8:	fdc42703          	lw	a4,-36(s0)
    80005fbc:	47bd                	li	a5,15
    80005fbe:	02e7ed63          	bltu	a5,a4,80005ff8 <argfd+0x60>
    80005fc2:	ffffc097          	auipc	ra,0xffffc
    80005fc6:	d6e080e7          	jalr	-658(ra) # 80001d30 <myproc>
    80005fca:	fdc42703          	lw	a4,-36(s0)
    80005fce:	01a70793          	addi	a5,a4,26
    80005fd2:	078e                	slli	a5,a5,0x3
    80005fd4:	953e                	add	a0,a0,a5
    80005fd6:	611c                	ld	a5,0(a0)
    80005fd8:	c395                	beqz	a5,80005ffc <argfd+0x64>
    return -1;
  if(pfd)
    80005fda:	00090463          	beqz	s2,80005fe2 <argfd+0x4a>
    *pfd = fd;
    80005fde:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005fe2:	4501                	li	a0,0
  if(pf)
    80005fe4:	c091                	beqz	s1,80005fe8 <argfd+0x50>
    *pf = f;
    80005fe6:	e09c                	sd	a5,0(s1)
}
    80005fe8:	70a2                	ld	ra,40(sp)
    80005fea:	7402                	ld	s0,32(sp)
    80005fec:	64e2                	ld	s1,24(sp)
    80005fee:	6942                	ld	s2,16(sp)
    80005ff0:	6145                	addi	sp,sp,48
    80005ff2:	8082                	ret
    return -1;
    80005ff4:	557d                	li	a0,-1
    80005ff6:	bfcd                	j	80005fe8 <argfd+0x50>
    return -1;
    80005ff8:	557d                	li	a0,-1
    80005ffa:	b7fd                	j	80005fe8 <argfd+0x50>
    80005ffc:	557d                	li	a0,-1
    80005ffe:	b7ed                	j	80005fe8 <argfd+0x50>

0000000080006000 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006000:	1101                	addi	sp,sp,-32
    80006002:	ec06                	sd	ra,24(sp)
    80006004:	e822                	sd	s0,16(sp)
    80006006:	e426                	sd	s1,8(sp)
    80006008:	1000                	addi	s0,sp,32
    8000600a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000600c:	ffffc097          	auipc	ra,0xffffc
    80006010:	d24080e7          	jalr	-732(ra) # 80001d30 <myproc>
    80006014:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006016:	0d050793          	addi	a5,a0,208
    8000601a:	4501                	li	a0,0
    8000601c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000601e:	6398                	ld	a4,0(a5)
    80006020:	cb19                	beqz	a4,80006036 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006022:	2505                	addiw	a0,a0,1
    80006024:	07a1                	addi	a5,a5,8
    80006026:	fed51ce3          	bne	a0,a3,8000601e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000602a:	557d                	li	a0,-1
}
    8000602c:	60e2                	ld	ra,24(sp)
    8000602e:	6442                	ld	s0,16(sp)
    80006030:	64a2                	ld	s1,8(sp)
    80006032:	6105                	addi	sp,sp,32
    80006034:	8082                	ret
      p->ofile[fd] = f;
    80006036:	01a50793          	addi	a5,a0,26
    8000603a:	078e                	slli	a5,a5,0x3
    8000603c:	963e                	add	a2,a2,a5
    8000603e:	e204                	sd	s1,0(a2)
      return fd;
    80006040:	b7f5                	j	8000602c <fdalloc+0x2c>

0000000080006042 <sys_dup>:

uint64
sys_dup(void)
{
    80006042:	7179                	addi	sp,sp,-48
    80006044:	f406                	sd	ra,40(sp)
    80006046:	f022                	sd	s0,32(sp)
    80006048:	ec26                	sd	s1,24(sp)
    8000604a:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    8000604c:	fd840613          	addi	a2,s0,-40
    80006050:	4581                	li	a1,0
    80006052:	4501                	li	a0,0
    80006054:	00000097          	auipc	ra,0x0
    80006058:	f44080e7          	jalr	-188(ra) # 80005f98 <argfd>
    return -1;
    8000605c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000605e:	02054363          	bltz	a0,80006084 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80006062:	fd843503          	ld	a0,-40(s0)
    80006066:	00000097          	auipc	ra,0x0
    8000606a:	f9a080e7          	jalr	-102(ra) # 80006000 <fdalloc>
    8000606e:	84aa                	mv	s1,a0
    return -1;
    80006070:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80006072:	00054963          	bltz	a0,80006084 <sys_dup+0x42>
  filedup(f);
    80006076:	fd843503          	ld	a0,-40(s0)
    8000607a:	fffff097          	auipc	ra,0xfffff
    8000607e:	27a080e7          	jalr	634(ra) # 800052f4 <filedup>
  return fd;
    80006082:	87a6                	mv	a5,s1
}
    80006084:	853e                	mv	a0,a5
    80006086:	70a2                	ld	ra,40(sp)
    80006088:	7402                	ld	s0,32(sp)
    8000608a:	64e2                	ld	s1,24(sp)
    8000608c:	6145                	addi	sp,sp,48
    8000608e:	8082                	ret

0000000080006090 <sys_read>:

uint64
sys_read(void)
{
    80006090:	7179                	addi	sp,sp,-48
    80006092:	f406                	sd	ra,40(sp)
    80006094:	f022                	sd	s0,32(sp)
    80006096:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006098:	fe840613          	addi	a2,s0,-24
    8000609c:	4581                	li	a1,0
    8000609e:	4501                	li	a0,0
    800060a0:	00000097          	auipc	ra,0x0
    800060a4:	ef8080e7          	jalr	-264(ra) # 80005f98 <argfd>
    return -1;
    800060a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060aa:	04054163          	bltz	a0,800060ec <sys_read+0x5c>
    800060ae:	fe440593          	addi	a1,s0,-28
    800060b2:	4509                	li	a0,2
    800060b4:	ffffd097          	auipc	ra,0xffffd
    800060b8:	55c080e7          	jalr	1372(ra) # 80003610 <argint>
    return -1;
    800060bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060be:	02054763          	bltz	a0,800060ec <sys_read+0x5c>
    800060c2:	fd840593          	addi	a1,s0,-40
    800060c6:	4505                	li	a0,1
    800060c8:	ffffd097          	auipc	ra,0xffffd
    800060cc:	56a080e7          	jalr	1386(ra) # 80003632 <argaddr>
    return -1;
    800060d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060d2:	00054d63          	bltz	a0,800060ec <sys_read+0x5c>
  return fileread(f, p, n);
    800060d6:	fe442603          	lw	a2,-28(s0)
    800060da:	fd843583          	ld	a1,-40(s0)
    800060de:	fe843503          	ld	a0,-24(s0)
    800060e2:	fffff097          	auipc	ra,0xfffff
    800060e6:	39e080e7          	jalr	926(ra) # 80005480 <fileread>
    800060ea:	87aa                	mv	a5,a0
}
    800060ec:	853e                	mv	a0,a5
    800060ee:	70a2                	ld	ra,40(sp)
    800060f0:	7402                	ld	s0,32(sp)
    800060f2:	6145                	addi	sp,sp,48
    800060f4:	8082                	ret

00000000800060f6 <sys_write>:

uint64
sys_write(void)
{
    800060f6:	7179                	addi	sp,sp,-48
    800060f8:	f406                	sd	ra,40(sp)
    800060fa:	f022                	sd	s0,32(sp)
    800060fc:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800060fe:	fe840613          	addi	a2,s0,-24
    80006102:	4581                	li	a1,0
    80006104:	4501                	li	a0,0
    80006106:	00000097          	auipc	ra,0x0
    8000610a:	e92080e7          	jalr	-366(ra) # 80005f98 <argfd>
    return -1;
    8000610e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006110:	04054163          	bltz	a0,80006152 <sys_write+0x5c>
    80006114:	fe440593          	addi	a1,s0,-28
    80006118:	4509                	li	a0,2
    8000611a:	ffffd097          	auipc	ra,0xffffd
    8000611e:	4f6080e7          	jalr	1270(ra) # 80003610 <argint>
    return -1;
    80006122:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006124:	02054763          	bltz	a0,80006152 <sys_write+0x5c>
    80006128:	fd840593          	addi	a1,s0,-40
    8000612c:	4505                	li	a0,1
    8000612e:	ffffd097          	auipc	ra,0xffffd
    80006132:	504080e7          	jalr	1284(ra) # 80003632 <argaddr>
    return -1;
    80006136:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006138:	00054d63          	bltz	a0,80006152 <sys_write+0x5c>

  return filewrite(f, p, n);
    8000613c:	fe442603          	lw	a2,-28(s0)
    80006140:	fd843583          	ld	a1,-40(s0)
    80006144:	fe843503          	ld	a0,-24(s0)
    80006148:	fffff097          	auipc	ra,0xfffff
    8000614c:	3fa080e7          	jalr	1018(ra) # 80005542 <filewrite>
    80006150:	87aa                	mv	a5,a0
}
    80006152:	853e                	mv	a0,a5
    80006154:	70a2                	ld	ra,40(sp)
    80006156:	7402                	ld	s0,32(sp)
    80006158:	6145                	addi	sp,sp,48
    8000615a:	8082                	ret

000000008000615c <sys_close>:

uint64
sys_close(void)
{
    8000615c:	1101                	addi	sp,sp,-32
    8000615e:	ec06                	sd	ra,24(sp)
    80006160:	e822                	sd	s0,16(sp)
    80006162:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80006164:	fe040613          	addi	a2,s0,-32
    80006168:	fec40593          	addi	a1,s0,-20
    8000616c:	4501                	li	a0,0
    8000616e:	00000097          	auipc	ra,0x0
    80006172:	e2a080e7          	jalr	-470(ra) # 80005f98 <argfd>
    return -1;
    80006176:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80006178:	02054463          	bltz	a0,800061a0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000617c:	ffffc097          	auipc	ra,0xffffc
    80006180:	bb4080e7          	jalr	-1100(ra) # 80001d30 <myproc>
    80006184:	fec42783          	lw	a5,-20(s0)
    80006188:	07e9                	addi	a5,a5,26
    8000618a:	078e                	slli	a5,a5,0x3
    8000618c:	97aa                	add	a5,a5,a0
    8000618e:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006192:	fe043503          	ld	a0,-32(s0)
    80006196:	fffff097          	auipc	ra,0xfffff
    8000619a:	1b0080e7          	jalr	432(ra) # 80005346 <fileclose>
  return 0;
    8000619e:	4781                	li	a5,0
}
    800061a0:	853e                	mv	a0,a5
    800061a2:	60e2                	ld	ra,24(sp)
    800061a4:	6442                	ld	s0,16(sp)
    800061a6:	6105                	addi	sp,sp,32
    800061a8:	8082                	ret

00000000800061aa <sys_fstat>:

uint64
sys_fstat(void)
{
    800061aa:	1101                	addi	sp,sp,-32
    800061ac:	ec06                	sd	ra,24(sp)
    800061ae:	e822                	sd	s0,16(sp)
    800061b0:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061b2:	fe840613          	addi	a2,s0,-24
    800061b6:	4581                	li	a1,0
    800061b8:	4501                	li	a0,0
    800061ba:	00000097          	auipc	ra,0x0
    800061be:	dde080e7          	jalr	-546(ra) # 80005f98 <argfd>
    return -1;
    800061c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061c4:	02054563          	bltz	a0,800061ee <sys_fstat+0x44>
    800061c8:	fe040593          	addi	a1,s0,-32
    800061cc:	4505                	li	a0,1
    800061ce:	ffffd097          	auipc	ra,0xffffd
    800061d2:	464080e7          	jalr	1124(ra) # 80003632 <argaddr>
    return -1;
    800061d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800061d8:	00054b63          	bltz	a0,800061ee <sys_fstat+0x44>
  return filestat(f, st);
    800061dc:	fe043583          	ld	a1,-32(s0)
    800061e0:	fe843503          	ld	a0,-24(s0)
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	22a080e7          	jalr	554(ra) # 8000540e <filestat>
    800061ec:	87aa                	mv	a5,a0
}
    800061ee:	853e                	mv	a0,a5
    800061f0:	60e2                	ld	ra,24(sp)
    800061f2:	6442                	ld	s0,16(sp)
    800061f4:	6105                	addi	sp,sp,32
    800061f6:	8082                	ret

00000000800061f8 <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    800061f8:	7169                	addi	sp,sp,-304
    800061fa:	f606                	sd	ra,296(sp)
    800061fc:	f222                	sd	s0,288(sp)
    800061fe:	ee26                	sd	s1,280(sp)
    80006200:	ea4a                	sd	s2,272(sp)
    80006202:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006204:	08000613          	li	a2,128
    80006208:	ed040593          	addi	a1,s0,-304
    8000620c:	4501                	li	a0,0
    8000620e:	ffffd097          	auipc	ra,0xffffd
    80006212:	446080e7          	jalr	1094(ra) # 80003654 <argstr>
    return -1;
    80006216:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006218:	10054e63          	bltz	a0,80006334 <sys_link+0x13c>
    8000621c:	08000613          	li	a2,128
    80006220:	f5040593          	addi	a1,s0,-176
    80006224:	4505                	li	a0,1
    80006226:	ffffd097          	auipc	ra,0xffffd
    8000622a:	42e080e7          	jalr	1070(ra) # 80003654 <argstr>
    return -1;
    8000622e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006230:	10054263          	bltz	a0,80006334 <sys_link+0x13c>

  begin_op();
    80006234:	fffff097          	auipc	ra,0xfffff
    80006238:	c46080e7          	jalr	-954(ra) # 80004e7a <begin_op>
  if((ip = namei(old)) == 0){
    8000623c:	ed040513          	addi	a0,s0,-304
    80006240:	ffffe097          	auipc	ra,0xffffe
    80006244:	6f8080e7          	jalr	1784(ra) # 80004938 <namei>
    80006248:	84aa                	mv	s1,a0
    8000624a:	c551                	beqz	a0,800062d6 <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    8000624c:	ffffe097          	auipc	ra,0xffffe
    80006250:	f36080e7          	jalr	-202(ra) # 80004182 <ilock>
  if(ip->type == T_DIR){
    80006254:	04449703          	lh	a4,68(s1)
    80006258:	4785                	li	a5,1
    8000625a:	08f70463          	beq	a4,a5,800062e2 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    8000625e:	04a4d783          	lhu	a5,74(s1)
    80006262:	2785                	addiw	a5,a5,1
    80006264:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006268:	8526                	mv	a0,s1
    8000626a:	ffffe097          	auipc	ra,0xffffe
    8000626e:	e4e080e7          	jalr	-434(ra) # 800040b8 <iupdate>
  iunlock(ip);
    80006272:	8526                	mv	a0,s1
    80006274:	ffffe097          	auipc	ra,0xffffe
    80006278:	fd0080e7          	jalr	-48(ra) # 80004244 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    8000627c:	fd040593          	addi	a1,s0,-48
    80006280:	f5040513          	addi	a0,s0,-176
    80006284:	ffffe097          	auipc	ra,0xffffe
    80006288:	6d2080e7          	jalr	1746(ra) # 80004956 <nameiparent>
    8000628c:	892a                	mv	s2,a0
    8000628e:	c935                	beqz	a0,80006302 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80006290:	ffffe097          	auipc	ra,0xffffe
    80006294:	ef2080e7          	jalr	-270(ra) # 80004182 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006298:	00092703          	lw	a4,0(s2)
    8000629c:	409c                	lw	a5,0(s1)
    8000629e:	04f71d63          	bne	a4,a5,800062f8 <sys_link+0x100>
    800062a2:	40d0                	lw	a2,4(s1)
    800062a4:	fd040593          	addi	a1,s0,-48
    800062a8:	854a                	mv	a0,s2
    800062aa:	ffffe097          	auipc	ra,0xffffe
    800062ae:	5cc080e7          	jalr	1484(ra) # 80004876 <dirlink>
    800062b2:	04054363          	bltz	a0,800062f8 <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    800062b6:	854a                	mv	a0,s2
    800062b8:	ffffe097          	auipc	ra,0xffffe
    800062bc:	12c080e7          	jalr	300(ra) # 800043e4 <iunlockput>
  iput(ip);
    800062c0:	8526                	mv	a0,s1
    800062c2:	ffffe097          	auipc	ra,0xffffe
    800062c6:	07a080e7          	jalr	122(ra) # 8000433c <iput>

  end_op();
    800062ca:	fffff097          	auipc	ra,0xfffff
    800062ce:	c30080e7          	jalr	-976(ra) # 80004efa <end_op>

  return 0;
    800062d2:	4781                	li	a5,0
    800062d4:	a085                	j	80006334 <sys_link+0x13c>
    end_op();
    800062d6:	fffff097          	auipc	ra,0xfffff
    800062da:	c24080e7          	jalr	-988(ra) # 80004efa <end_op>
    return -1;
    800062de:	57fd                	li	a5,-1
    800062e0:	a891                	j	80006334 <sys_link+0x13c>
    iunlockput(ip);
    800062e2:	8526                	mv	a0,s1
    800062e4:	ffffe097          	auipc	ra,0xffffe
    800062e8:	100080e7          	jalr	256(ra) # 800043e4 <iunlockput>
    end_op();
    800062ec:	fffff097          	auipc	ra,0xfffff
    800062f0:	c0e080e7          	jalr	-1010(ra) # 80004efa <end_op>
    return -1;
    800062f4:	57fd                	li	a5,-1
    800062f6:	a83d                	j	80006334 <sys_link+0x13c>
    iunlockput(dp);
    800062f8:	854a                	mv	a0,s2
    800062fa:	ffffe097          	auipc	ra,0xffffe
    800062fe:	0ea080e7          	jalr	234(ra) # 800043e4 <iunlockput>

bad:
  ilock(ip);
    80006302:	8526                	mv	a0,s1
    80006304:	ffffe097          	auipc	ra,0xffffe
    80006308:	e7e080e7          	jalr	-386(ra) # 80004182 <ilock>
  ip->nlink--;
    8000630c:	04a4d783          	lhu	a5,74(s1)
    80006310:	37fd                	addiw	a5,a5,-1
    80006312:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006316:	8526                	mv	a0,s1
    80006318:	ffffe097          	auipc	ra,0xffffe
    8000631c:	da0080e7          	jalr	-608(ra) # 800040b8 <iupdate>
  iunlockput(ip);
    80006320:	8526                	mv	a0,s1
    80006322:	ffffe097          	auipc	ra,0xffffe
    80006326:	0c2080e7          	jalr	194(ra) # 800043e4 <iunlockput>
  end_op();
    8000632a:	fffff097          	auipc	ra,0xfffff
    8000632e:	bd0080e7          	jalr	-1072(ra) # 80004efa <end_op>
  return -1;
    80006332:	57fd                	li	a5,-1
}
    80006334:	853e                	mv	a0,a5
    80006336:	70b2                	ld	ra,296(sp)
    80006338:	7412                	ld	s0,288(sp)
    8000633a:	64f2                	ld	s1,280(sp)
    8000633c:	6952                	ld	s2,272(sp)
    8000633e:	6155                	addi	sp,sp,304
    80006340:	8082                	ret

0000000080006342 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006342:	4578                	lw	a4,76(a0)
    80006344:	02000793          	li	a5,32
    80006348:	04e7fa63          	bgeu	a5,a4,8000639c <isdirempty+0x5a>
{
    8000634c:	7179                	addi	sp,sp,-48
    8000634e:	f406                	sd	ra,40(sp)
    80006350:	f022                	sd	s0,32(sp)
    80006352:	ec26                	sd	s1,24(sp)
    80006354:	e84a                	sd	s2,16(sp)
    80006356:	1800                	addi	s0,sp,48
    80006358:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000635a:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000635e:	4741                	li	a4,16
    80006360:	86a6                	mv	a3,s1
    80006362:	fd040613          	addi	a2,s0,-48
    80006366:	4581                	li	a1,0
    80006368:	854a                	mv	a0,s2
    8000636a:	ffffe097          	auipc	ra,0xffffe
    8000636e:	0cc080e7          	jalr	204(ra) # 80004436 <readi>
    80006372:	47c1                	li	a5,16
    80006374:	00f51c63          	bne	a0,a5,8000638c <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80006378:	fd045783          	lhu	a5,-48(s0)
    8000637c:	e395                	bnez	a5,800063a0 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000637e:	24c1                	addiw	s1,s1,16
    80006380:	04c92783          	lw	a5,76(s2)
    80006384:	fcf4ede3          	bltu	s1,a5,8000635e <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80006388:	4505                	li	a0,1
    8000638a:	a821                	j	800063a2 <isdirempty+0x60>
      panic("isdirempty: readi");
    8000638c:	00004517          	auipc	a0,0x4
    80006390:	aa450513          	addi	a0,a0,-1372 # 80009e30 <syscalls+0x388>
    80006394:	ffffa097          	auipc	ra,0xffffa
    80006398:	196080e7          	jalr	406(ra) # 8000052a <panic>
  return 1;
    8000639c:	4505                	li	a0,1
}
    8000639e:	8082                	ret
      return 0;
    800063a0:	4501                	li	a0,0
}
    800063a2:	70a2                	ld	ra,40(sp)
    800063a4:	7402                	ld	s0,32(sp)
    800063a6:	64e2                	ld	s1,24(sp)
    800063a8:	6942                	ld	s2,16(sp)
    800063aa:	6145                	addi	sp,sp,48
    800063ac:	8082                	ret

00000000800063ae <sys_unlink>:

uint64
sys_unlink(void)
{
    800063ae:	7155                	addi	sp,sp,-208
    800063b0:	e586                	sd	ra,200(sp)
    800063b2:	e1a2                	sd	s0,192(sp)
    800063b4:	fd26                	sd	s1,184(sp)
    800063b6:	f94a                	sd	s2,176(sp)
    800063b8:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800063ba:	08000613          	li	a2,128
    800063be:	f4040593          	addi	a1,s0,-192
    800063c2:	4501                	li	a0,0
    800063c4:	ffffd097          	auipc	ra,0xffffd
    800063c8:	290080e7          	jalr	656(ra) # 80003654 <argstr>
    800063cc:	16054363          	bltz	a0,80006532 <sys_unlink+0x184>
    return -1;

  begin_op();
    800063d0:	fffff097          	auipc	ra,0xfffff
    800063d4:	aaa080e7          	jalr	-1366(ra) # 80004e7a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800063d8:	fc040593          	addi	a1,s0,-64
    800063dc:	f4040513          	addi	a0,s0,-192
    800063e0:	ffffe097          	auipc	ra,0xffffe
    800063e4:	576080e7          	jalr	1398(ra) # 80004956 <nameiparent>
    800063e8:	84aa                	mv	s1,a0
    800063ea:	c961                	beqz	a0,800064ba <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    800063ec:	ffffe097          	auipc	ra,0xffffe
    800063f0:	d96080e7          	jalr	-618(ra) # 80004182 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800063f4:	00004597          	auipc	a1,0x4
    800063f8:	8bc58593          	addi	a1,a1,-1860 # 80009cb0 <syscalls+0x208>
    800063fc:	fc040513          	addi	a0,s0,-64
    80006400:	ffffe097          	auipc	ra,0xffffe
    80006404:	24c080e7          	jalr	588(ra) # 8000464c <namecmp>
    80006408:	c175                	beqz	a0,800064ec <sys_unlink+0x13e>
    8000640a:	00004597          	auipc	a1,0x4
    8000640e:	8ae58593          	addi	a1,a1,-1874 # 80009cb8 <syscalls+0x210>
    80006412:	fc040513          	addi	a0,s0,-64
    80006416:	ffffe097          	auipc	ra,0xffffe
    8000641a:	236080e7          	jalr	566(ra) # 8000464c <namecmp>
    8000641e:	c579                	beqz	a0,800064ec <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80006420:	f3c40613          	addi	a2,s0,-196
    80006424:	fc040593          	addi	a1,s0,-64
    80006428:	8526                	mv	a0,s1
    8000642a:	ffffe097          	auipc	ra,0xffffe
    8000642e:	23c080e7          	jalr	572(ra) # 80004666 <dirlookup>
    80006432:	892a                	mv	s2,a0
    80006434:	cd45                	beqz	a0,800064ec <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80006436:	ffffe097          	auipc	ra,0xffffe
    8000643a:	d4c080e7          	jalr	-692(ra) # 80004182 <ilock>

  if(ip->nlink < 1)
    8000643e:	04a91783          	lh	a5,74(s2)
    80006442:	08f05263          	blez	a5,800064c6 <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006446:	04491703          	lh	a4,68(s2)
    8000644a:	4785                	li	a5,1
    8000644c:	08f70563          	beq	a4,a5,800064d6 <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80006450:	4641                	li	a2,16
    80006452:	4581                	li	a1,0
    80006454:	fd040513          	addi	a0,s0,-48
    80006458:	ffffb097          	auipc	ra,0xffffb
    8000645c:	866080e7          	jalr	-1946(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006460:	4741                	li	a4,16
    80006462:	f3c42683          	lw	a3,-196(s0)
    80006466:	fd040613          	addi	a2,s0,-48
    8000646a:	4581                	li	a1,0
    8000646c:	8526                	mv	a0,s1
    8000646e:	ffffe097          	auipc	ra,0xffffe
    80006472:	0c0080e7          	jalr	192(ra) # 8000452e <writei>
    80006476:	47c1                	li	a5,16
    80006478:	08f51a63          	bne	a0,a5,8000650c <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    8000647c:	04491703          	lh	a4,68(s2)
    80006480:	4785                	li	a5,1
    80006482:	08f70d63          	beq	a4,a5,8000651c <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80006486:	8526                	mv	a0,s1
    80006488:	ffffe097          	auipc	ra,0xffffe
    8000648c:	f5c080e7          	jalr	-164(ra) # 800043e4 <iunlockput>

  ip->nlink--;
    80006490:	04a95783          	lhu	a5,74(s2)
    80006494:	37fd                	addiw	a5,a5,-1
    80006496:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000649a:	854a                	mv	a0,s2
    8000649c:	ffffe097          	auipc	ra,0xffffe
    800064a0:	c1c080e7          	jalr	-996(ra) # 800040b8 <iupdate>
  iunlockput(ip);
    800064a4:	854a                	mv	a0,s2
    800064a6:	ffffe097          	auipc	ra,0xffffe
    800064aa:	f3e080e7          	jalr	-194(ra) # 800043e4 <iunlockput>

  end_op();
    800064ae:	fffff097          	auipc	ra,0xfffff
    800064b2:	a4c080e7          	jalr	-1460(ra) # 80004efa <end_op>

  return 0;
    800064b6:	4501                	li	a0,0
    800064b8:	a0a1                	j	80006500 <sys_unlink+0x152>
    end_op();
    800064ba:	fffff097          	auipc	ra,0xfffff
    800064be:	a40080e7          	jalr	-1472(ra) # 80004efa <end_op>
    return -1;
    800064c2:	557d                	li	a0,-1
    800064c4:	a835                	j	80006500 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    800064c6:	00003517          	auipc	a0,0x3
    800064ca:	7fa50513          	addi	a0,a0,2042 # 80009cc0 <syscalls+0x218>
    800064ce:	ffffa097          	auipc	ra,0xffffa
    800064d2:	05c080e7          	jalr	92(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800064d6:	854a                	mv	a0,s2
    800064d8:	00000097          	auipc	ra,0x0
    800064dc:	e6a080e7          	jalr	-406(ra) # 80006342 <isdirempty>
    800064e0:	f925                	bnez	a0,80006450 <sys_unlink+0xa2>
    iunlockput(ip);
    800064e2:	854a                	mv	a0,s2
    800064e4:	ffffe097          	auipc	ra,0xffffe
    800064e8:	f00080e7          	jalr	-256(ra) # 800043e4 <iunlockput>

bad:
  iunlockput(dp);
    800064ec:	8526                	mv	a0,s1
    800064ee:	ffffe097          	auipc	ra,0xffffe
    800064f2:	ef6080e7          	jalr	-266(ra) # 800043e4 <iunlockput>
  end_op();
    800064f6:	fffff097          	auipc	ra,0xfffff
    800064fa:	a04080e7          	jalr	-1532(ra) # 80004efa <end_op>
  return -1;
    800064fe:	557d                	li	a0,-1
}
    80006500:	60ae                	ld	ra,200(sp)
    80006502:	640e                	ld	s0,192(sp)
    80006504:	74ea                	ld	s1,184(sp)
    80006506:	794a                	ld	s2,176(sp)
    80006508:	6169                	addi	sp,sp,208
    8000650a:	8082                	ret
    panic("unlink: writei");
    8000650c:	00003517          	auipc	a0,0x3
    80006510:	7cc50513          	addi	a0,a0,1996 # 80009cd8 <syscalls+0x230>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	016080e7          	jalr	22(ra) # 8000052a <panic>
    dp->nlink--;
    8000651c:	04a4d783          	lhu	a5,74(s1)
    80006520:	37fd                	addiw	a5,a5,-1
    80006522:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006526:	8526                	mv	a0,s1
    80006528:	ffffe097          	auipc	ra,0xffffe
    8000652c:	b90080e7          	jalr	-1136(ra) # 800040b8 <iupdate>
    80006530:	bf99                	j	80006486 <sys_unlink+0xd8>
    return -1;
    80006532:	557d                	li	a0,-1
    80006534:	b7f1                	j	80006500 <sys_unlink+0x152>

0000000080006536 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80006536:	715d                	addi	sp,sp,-80
    80006538:	e486                	sd	ra,72(sp)
    8000653a:	e0a2                	sd	s0,64(sp)
    8000653c:	fc26                	sd	s1,56(sp)
    8000653e:	f84a                	sd	s2,48(sp)
    80006540:	f44e                	sd	s3,40(sp)
    80006542:	f052                	sd	s4,32(sp)
    80006544:	ec56                	sd	s5,24(sp)
    80006546:	0880                	addi	s0,sp,80
    80006548:	89ae                	mv	s3,a1
    8000654a:	8ab2                	mv	s5,a2
    8000654c:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000654e:	fb040593          	addi	a1,s0,-80
    80006552:	ffffe097          	auipc	ra,0xffffe
    80006556:	404080e7          	jalr	1028(ra) # 80004956 <nameiparent>
    8000655a:	892a                	mv	s2,a0
    8000655c:	12050e63          	beqz	a0,80006698 <create+0x162>
    return 0;

  ilock(dp);
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	c22080e7          	jalr	-990(ra) # 80004182 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    80006568:	4601                	li	a2,0
    8000656a:	fb040593          	addi	a1,s0,-80
    8000656e:	854a                	mv	a0,s2
    80006570:	ffffe097          	auipc	ra,0xffffe
    80006574:	0f6080e7          	jalr	246(ra) # 80004666 <dirlookup>
    80006578:	84aa                	mv	s1,a0
    8000657a:	c921                	beqz	a0,800065ca <create+0x94>
    iunlockput(dp);
    8000657c:	854a                	mv	a0,s2
    8000657e:	ffffe097          	auipc	ra,0xffffe
    80006582:	e66080e7          	jalr	-410(ra) # 800043e4 <iunlockput>
    ilock(ip);
    80006586:	8526                	mv	a0,s1
    80006588:	ffffe097          	auipc	ra,0xffffe
    8000658c:	bfa080e7          	jalr	-1030(ra) # 80004182 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006590:	2981                	sext.w	s3,s3
    80006592:	4789                	li	a5,2
    80006594:	02f99463          	bne	s3,a5,800065bc <create+0x86>
    80006598:	0444d783          	lhu	a5,68(s1)
    8000659c:	37f9                	addiw	a5,a5,-2
    8000659e:	17c2                	slli	a5,a5,0x30
    800065a0:	93c1                	srli	a5,a5,0x30
    800065a2:	4705                	li	a4,1
    800065a4:	00f76c63          	bltu	a4,a5,800065bc <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800065a8:	8526                	mv	a0,s1
    800065aa:	60a6                	ld	ra,72(sp)
    800065ac:	6406                	ld	s0,64(sp)
    800065ae:	74e2                	ld	s1,56(sp)
    800065b0:	7942                	ld	s2,48(sp)
    800065b2:	79a2                	ld	s3,40(sp)
    800065b4:	7a02                	ld	s4,32(sp)
    800065b6:	6ae2                	ld	s5,24(sp)
    800065b8:	6161                	addi	sp,sp,80
    800065ba:	8082                	ret
    iunlockput(ip);
    800065bc:	8526                	mv	a0,s1
    800065be:	ffffe097          	auipc	ra,0xffffe
    800065c2:	e26080e7          	jalr	-474(ra) # 800043e4 <iunlockput>
    return 0;
    800065c6:	4481                	li	s1,0
    800065c8:	b7c5                	j	800065a8 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800065ca:	85ce                	mv	a1,s3
    800065cc:	00092503          	lw	a0,0(s2)
    800065d0:	ffffe097          	auipc	ra,0xffffe
    800065d4:	a1a080e7          	jalr	-1510(ra) # 80003fea <ialloc>
    800065d8:	84aa                	mv	s1,a0
    800065da:	c521                	beqz	a0,80006622 <create+0xec>
  ilock(ip);
    800065dc:	ffffe097          	auipc	ra,0xffffe
    800065e0:	ba6080e7          	jalr	-1114(ra) # 80004182 <ilock>
  ip->major = major;
    800065e4:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800065e8:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800065ec:	4a05                	li	s4,1
    800065ee:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800065f2:	8526                	mv	a0,s1
    800065f4:	ffffe097          	auipc	ra,0xffffe
    800065f8:	ac4080e7          	jalr	-1340(ra) # 800040b8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800065fc:	2981                	sext.w	s3,s3
    800065fe:	03498a63          	beq	s3,s4,80006632 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80006602:	40d0                	lw	a2,4(s1)
    80006604:	fb040593          	addi	a1,s0,-80
    80006608:	854a                	mv	a0,s2
    8000660a:	ffffe097          	auipc	ra,0xffffe
    8000660e:	26c080e7          	jalr	620(ra) # 80004876 <dirlink>
    80006612:	06054b63          	bltz	a0,80006688 <create+0x152>
  iunlockput(dp);
    80006616:	854a                	mv	a0,s2
    80006618:	ffffe097          	auipc	ra,0xffffe
    8000661c:	dcc080e7          	jalr	-564(ra) # 800043e4 <iunlockput>
  return ip;
    80006620:	b761                	j	800065a8 <create+0x72>
    panic("create: ialloc");
    80006622:	00004517          	auipc	a0,0x4
    80006626:	82650513          	addi	a0,a0,-2010 # 80009e48 <syscalls+0x3a0>
    8000662a:	ffffa097          	auipc	ra,0xffffa
    8000662e:	f00080e7          	jalr	-256(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80006632:	04a95783          	lhu	a5,74(s2)
    80006636:	2785                	addiw	a5,a5,1
    80006638:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000663c:	854a                	mv	a0,s2
    8000663e:	ffffe097          	auipc	ra,0xffffe
    80006642:	a7a080e7          	jalr	-1414(ra) # 800040b8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006646:	40d0                	lw	a2,4(s1)
    80006648:	00003597          	auipc	a1,0x3
    8000664c:	66858593          	addi	a1,a1,1640 # 80009cb0 <syscalls+0x208>
    80006650:	8526                	mv	a0,s1
    80006652:	ffffe097          	auipc	ra,0xffffe
    80006656:	224080e7          	jalr	548(ra) # 80004876 <dirlink>
    8000665a:	00054f63          	bltz	a0,80006678 <create+0x142>
    8000665e:	00492603          	lw	a2,4(s2)
    80006662:	00003597          	auipc	a1,0x3
    80006666:	65658593          	addi	a1,a1,1622 # 80009cb8 <syscalls+0x210>
    8000666a:	8526                	mv	a0,s1
    8000666c:	ffffe097          	auipc	ra,0xffffe
    80006670:	20a080e7          	jalr	522(ra) # 80004876 <dirlink>
    80006674:	f80557e3          	bgez	a0,80006602 <create+0xcc>
      panic("create dots");
    80006678:	00003517          	auipc	a0,0x3
    8000667c:	7e050513          	addi	a0,a0,2016 # 80009e58 <syscalls+0x3b0>
    80006680:	ffffa097          	auipc	ra,0xffffa
    80006684:	eaa080e7          	jalr	-342(ra) # 8000052a <panic>
    panic("create: dirlink");
    80006688:	00003517          	auipc	a0,0x3
    8000668c:	7e050513          	addi	a0,a0,2016 # 80009e68 <syscalls+0x3c0>
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	e9a080e7          	jalr	-358(ra) # 8000052a <panic>
    return 0;
    80006698:	84aa                	mv	s1,a0
    8000669a:	b739                	j	800065a8 <create+0x72>

000000008000669c <sys_open>:

uint64
sys_open(void)
{
    8000669c:	7131                	addi	sp,sp,-192
    8000669e:	fd06                	sd	ra,184(sp)
    800066a0:	f922                	sd	s0,176(sp)
    800066a2:	f526                	sd	s1,168(sp)
    800066a4:	f14a                	sd	s2,160(sp)
    800066a6:	ed4e                	sd	s3,152(sp)
    800066a8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800066aa:	08000613          	li	a2,128
    800066ae:	f5040593          	addi	a1,s0,-176
    800066b2:	4501                	li	a0,0
    800066b4:	ffffd097          	auipc	ra,0xffffd
    800066b8:	fa0080e7          	jalr	-96(ra) # 80003654 <argstr>
    return -1;
    800066bc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800066be:	0c054163          	bltz	a0,80006780 <sys_open+0xe4>
    800066c2:	f4c40593          	addi	a1,s0,-180
    800066c6:	4505                	li	a0,1
    800066c8:	ffffd097          	auipc	ra,0xffffd
    800066cc:	f48080e7          	jalr	-184(ra) # 80003610 <argint>
    800066d0:	0a054863          	bltz	a0,80006780 <sys_open+0xe4>

  begin_op();
    800066d4:	ffffe097          	auipc	ra,0xffffe
    800066d8:	7a6080e7          	jalr	1958(ra) # 80004e7a <begin_op>

  if(omode & O_CREATE){
    800066dc:	f4c42783          	lw	a5,-180(s0)
    800066e0:	2007f793          	andi	a5,a5,512
    800066e4:	cbdd                	beqz	a5,8000679a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800066e6:	4681                	li	a3,0
    800066e8:	4601                	li	a2,0
    800066ea:	4589                	li	a1,2
    800066ec:	f5040513          	addi	a0,s0,-176
    800066f0:	00000097          	auipc	ra,0x0
    800066f4:	e46080e7          	jalr	-442(ra) # 80006536 <create>
    800066f8:	892a                	mv	s2,a0
    if(ip == 0){
    800066fa:	c959                	beqz	a0,80006790 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800066fc:	04491703          	lh	a4,68(s2)
    80006700:	478d                	li	a5,3
    80006702:	00f71763          	bne	a4,a5,80006710 <sys_open+0x74>
    80006706:	04695703          	lhu	a4,70(s2)
    8000670a:	47a5                	li	a5,9
    8000670c:	0ce7ec63          	bltu	a5,a4,800067e4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006710:	fffff097          	auipc	ra,0xfffff
    80006714:	b7a080e7          	jalr	-1158(ra) # 8000528a <filealloc>
    80006718:	89aa                	mv	s3,a0
    8000671a:	10050263          	beqz	a0,8000681e <sys_open+0x182>
    8000671e:	00000097          	auipc	ra,0x0
    80006722:	8e2080e7          	jalr	-1822(ra) # 80006000 <fdalloc>
    80006726:	84aa                	mv	s1,a0
    80006728:	0e054663          	bltz	a0,80006814 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000672c:	04491703          	lh	a4,68(s2)
    80006730:	478d                	li	a5,3
    80006732:	0cf70463          	beq	a4,a5,800067fa <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006736:	4789                	li	a5,2
    80006738:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000673c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006740:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006744:	f4c42783          	lw	a5,-180(s0)
    80006748:	0017c713          	xori	a4,a5,1
    8000674c:	8b05                	andi	a4,a4,1
    8000674e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006752:	0037f713          	andi	a4,a5,3
    80006756:	00e03733          	snez	a4,a4
    8000675a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000675e:	4007f793          	andi	a5,a5,1024
    80006762:	c791                	beqz	a5,8000676e <sys_open+0xd2>
    80006764:	04491703          	lh	a4,68(s2)
    80006768:	4789                	li	a5,2
    8000676a:	08f70f63          	beq	a4,a5,80006808 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000676e:	854a                	mv	a0,s2
    80006770:	ffffe097          	auipc	ra,0xffffe
    80006774:	ad4080e7          	jalr	-1324(ra) # 80004244 <iunlock>
  end_op();
    80006778:	ffffe097          	auipc	ra,0xffffe
    8000677c:	782080e7          	jalr	1922(ra) # 80004efa <end_op>

  return fd;
}
    80006780:	8526                	mv	a0,s1
    80006782:	70ea                	ld	ra,184(sp)
    80006784:	744a                	ld	s0,176(sp)
    80006786:	74aa                	ld	s1,168(sp)
    80006788:	790a                	ld	s2,160(sp)
    8000678a:	69ea                	ld	s3,152(sp)
    8000678c:	6129                	addi	sp,sp,192
    8000678e:	8082                	ret
      end_op();
    80006790:	ffffe097          	auipc	ra,0xffffe
    80006794:	76a080e7          	jalr	1898(ra) # 80004efa <end_op>
      return -1;
    80006798:	b7e5                	j	80006780 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000679a:	f5040513          	addi	a0,s0,-176
    8000679e:	ffffe097          	auipc	ra,0xffffe
    800067a2:	19a080e7          	jalr	410(ra) # 80004938 <namei>
    800067a6:	892a                	mv	s2,a0
    800067a8:	c905                	beqz	a0,800067d8 <sys_open+0x13c>
    ilock(ip);
    800067aa:	ffffe097          	auipc	ra,0xffffe
    800067ae:	9d8080e7          	jalr	-1576(ra) # 80004182 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800067b2:	04491703          	lh	a4,68(s2)
    800067b6:	4785                	li	a5,1
    800067b8:	f4f712e3          	bne	a4,a5,800066fc <sys_open+0x60>
    800067bc:	f4c42783          	lw	a5,-180(s0)
    800067c0:	dba1                	beqz	a5,80006710 <sys_open+0x74>
      iunlockput(ip);
    800067c2:	854a                	mv	a0,s2
    800067c4:	ffffe097          	auipc	ra,0xffffe
    800067c8:	c20080e7          	jalr	-992(ra) # 800043e4 <iunlockput>
      end_op();
    800067cc:	ffffe097          	auipc	ra,0xffffe
    800067d0:	72e080e7          	jalr	1838(ra) # 80004efa <end_op>
      return -1;
    800067d4:	54fd                	li	s1,-1
    800067d6:	b76d                	j	80006780 <sys_open+0xe4>
      end_op();
    800067d8:	ffffe097          	auipc	ra,0xffffe
    800067dc:	722080e7          	jalr	1826(ra) # 80004efa <end_op>
      return -1;
    800067e0:	54fd                	li	s1,-1
    800067e2:	bf79                	j	80006780 <sys_open+0xe4>
    iunlockput(ip);
    800067e4:	854a                	mv	a0,s2
    800067e6:	ffffe097          	auipc	ra,0xffffe
    800067ea:	bfe080e7          	jalr	-1026(ra) # 800043e4 <iunlockput>
    end_op();
    800067ee:	ffffe097          	auipc	ra,0xffffe
    800067f2:	70c080e7          	jalr	1804(ra) # 80004efa <end_op>
    return -1;
    800067f6:	54fd                	li	s1,-1
    800067f8:	b761                	j	80006780 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800067fa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800067fe:	04691783          	lh	a5,70(s2)
    80006802:	02f99223          	sh	a5,36(s3)
    80006806:	bf2d                	j	80006740 <sys_open+0xa4>
    itrunc(ip);
    80006808:	854a                	mv	a0,s2
    8000680a:	ffffe097          	auipc	ra,0xffffe
    8000680e:	a86080e7          	jalr	-1402(ra) # 80004290 <itrunc>
    80006812:	bfb1                	j	8000676e <sys_open+0xd2>
      fileclose(f);
    80006814:	854e                	mv	a0,s3
    80006816:	fffff097          	auipc	ra,0xfffff
    8000681a:	b30080e7          	jalr	-1232(ra) # 80005346 <fileclose>
    iunlockput(ip);
    8000681e:	854a                	mv	a0,s2
    80006820:	ffffe097          	auipc	ra,0xffffe
    80006824:	bc4080e7          	jalr	-1084(ra) # 800043e4 <iunlockput>
    end_op();
    80006828:	ffffe097          	auipc	ra,0xffffe
    8000682c:	6d2080e7          	jalr	1746(ra) # 80004efa <end_op>
    return -1;
    80006830:	54fd                	li	s1,-1
    80006832:	b7b9                	j	80006780 <sys_open+0xe4>

0000000080006834 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006834:	7175                	addi	sp,sp,-144
    80006836:	e506                	sd	ra,136(sp)
    80006838:	e122                	sd	s0,128(sp)
    8000683a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000683c:	ffffe097          	auipc	ra,0xffffe
    80006840:	63e080e7          	jalr	1598(ra) # 80004e7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006844:	08000613          	li	a2,128
    80006848:	f7040593          	addi	a1,s0,-144
    8000684c:	4501                	li	a0,0
    8000684e:	ffffd097          	auipc	ra,0xffffd
    80006852:	e06080e7          	jalr	-506(ra) # 80003654 <argstr>
    80006856:	02054963          	bltz	a0,80006888 <sys_mkdir+0x54>
    8000685a:	4681                	li	a3,0
    8000685c:	4601                	li	a2,0
    8000685e:	4585                	li	a1,1
    80006860:	f7040513          	addi	a0,s0,-144
    80006864:	00000097          	auipc	ra,0x0
    80006868:	cd2080e7          	jalr	-814(ra) # 80006536 <create>
    8000686c:	cd11                	beqz	a0,80006888 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000686e:	ffffe097          	auipc	ra,0xffffe
    80006872:	b76080e7          	jalr	-1162(ra) # 800043e4 <iunlockput>
  end_op();
    80006876:	ffffe097          	auipc	ra,0xffffe
    8000687a:	684080e7          	jalr	1668(ra) # 80004efa <end_op>
  return 0;
    8000687e:	4501                	li	a0,0
}
    80006880:	60aa                	ld	ra,136(sp)
    80006882:	640a                	ld	s0,128(sp)
    80006884:	6149                	addi	sp,sp,144
    80006886:	8082                	ret
    end_op();
    80006888:	ffffe097          	auipc	ra,0xffffe
    8000688c:	672080e7          	jalr	1650(ra) # 80004efa <end_op>
    return -1;
    80006890:	557d                	li	a0,-1
    80006892:	b7fd                	j	80006880 <sys_mkdir+0x4c>

0000000080006894 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006894:	7135                	addi	sp,sp,-160
    80006896:	ed06                	sd	ra,152(sp)
    80006898:	e922                	sd	s0,144(sp)
    8000689a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000689c:	ffffe097          	auipc	ra,0xffffe
    800068a0:	5de080e7          	jalr	1502(ra) # 80004e7a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800068a4:	08000613          	li	a2,128
    800068a8:	f7040593          	addi	a1,s0,-144
    800068ac:	4501                	li	a0,0
    800068ae:	ffffd097          	auipc	ra,0xffffd
    800068b2:	da6080e7          	jalr	-602(ra) # 80003654 <argstr>
    800068b6:	04054a63          	bltz	a0,8000690a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800068ba:	f6c40593          	addi	a1,s0,-148
    800068be:	4505                	li	a0,1
    800068c0:	ffffd097          	auipc	ra,0xffffd
    800068c4:	d50080e7          	jalr	-688(ra) # 80003610 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800068c8:	04054163          	bltz	a0,8000690a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800068cc:	f6840593          	addi	a1,s0,-152
    800068d0:	4509                	li	a0,2
    800068d2:	ffffd097          	auipc	ra,0xffffd
    800068d6:	d3e080e7          	jalr	-706(ra) # 80003610 <argint>
     argint(1, &major) < 0 ||
    800068da:	02054863          	bltz	a0,8000690a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800068de:	f6841683          	lh	a3,-152(s0)
    800068e2:	f6c41603          	lh	a2,-148(s0)
    800068e6:	458d                	li	a1,3
    800068e8:	f7040513          	addi	a0,s0,-144
    800068ec:	00000097          	auipc	ra,0x0
    800068f0:	c4a080e7          	jalr	-950(ra) # 80006536 <create>
     argint(2, &minor) < 0 ||
    800068f4:	c919                	beqz	a0,8000690a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800068f6:	ffffe097          	auipc	ra,0xffffe
    800068fa:	aee080e7          	jalr	-1298(ra) # 800043e4 <iunlockput>
  end_op();
    800068fe:	ffffe097          	auipc	ra,0xffffe
    80006902:	5fc080e7          	jalr	1532(ra) # 80004efa <end_op>
  return 0;
    80006906:	4501                	li	a0,0
    80006908:	a031                	j	80006914 <sys_mknod+0x80>
    end_op();
    8000690a:	ffffe097          	auipc	ra,0xffffe
    8000690e:	5f0080e7          	jalr	1520(ra) # 80004efa <end_op>
    return -1;
    80006912:	557d                	li	a0,-1
}
    80006914:	60ea                	ld	ra,152(sp)
    80006916:	644a                	ld	s0,144(sp)
    80006918:	610d                	addi	sp,sp,160
    8000691a:	8082                	ret

000000008000691c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000691c:	7135                	addi	sp,sp,-160
    8000691e:	ed06                	sd	ra,152(sp)
    80006920:	e922                	sd	s0,144(sp)
    80006922:	e526                	sd	s1,136(sp)
    80006924:	e14a                	sd	s2,128(sp)
    80006926:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006928:	ffffb097          	auipc	ra,0xffffb
    8000692c:	408080e7          	jalr	1032(ra) # 80001d30 <myproc>
    80006930:	892a                	mv	s2,a0
  
  begin_op();
    80006932:	ffffe097          	auipc	ra,0xffffe
    80006936:	548080e7          	jalr	1352(ra) # 80004e7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000693a:	08000613          	li	a2,128
    8000693e:	f6040593          	addi	a1,s0,-160
    80006942:	4501                	li	a0,0
    80006944:	ffffd097          	auipc	ra,0xffffd
    80006948:	d10080e7          	jalr	-752(ra) # 80003654 <argstr>
    8000694c:	04054b63          	bltz	a0,800069a2 <sys_chdir+0x86>
    80006950:	f6040513          	addi	a0,s0,-160
    80006954:	ffffe097          	auipc	ra,0xffffe
    80006958:	fe4080e7          	jalr	-28(ra) # 80004938 <namei>
    8000695c:	84aa                	mv	s1,a0
    8000695e:	c131                	beqz	a0,800069a2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006960:	ffffe097          	auipc	ra,0xffffe
    80006964:	822080e7          	jalr	-2014(ra) # 80004182 <ilock>
  if(ip->type != T_DIR){
    80006968:	04449703          	lh	a4,68(s1)
    8000696c:	4785                	li	a5,1
    8000696e:	04f71063          	bne	a4,a5,800069ae <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006972:	8526                	mv	a0,s1
    80006974:	ffffe097          	auipc	ra,0xffffe
    80006978:	8d0080e7          	jalr	-1840(ra) # 80004244 <iunlock>
  iput(p->cwd);
    8000697c:	15093503          	ld	a0,336(s2)
    80006980:	ffffe097          	auipc	ra,0xffffe
    80006984:	9bc080e7          	jalr	-1604(ra) # 8000433c <iput>
  end_op();
    80006988:	ffffe097          	auipc	ra,0xffffe
    8000698c:	572080e7          	jalr	1394(ra) # 80004efa <end_op>
  p->cwd = ip;
    80006990:	14993823          	sd	s1,336(s2)
  return 0;
    80006994:	4501                	li	a0,0
}
    80006996:	60ea                	ld	ra,152(sp)
    80006998:	644a                	ld	s0,144(sp)
    8000699a:	64aa                	ld	s1,136(sp)
    8000699c:	690a                	ld	s2,128(sp)
    8000699e:	610d                	addi	sp,sp,160
    800069a0:	8082                	ret
    end_op();
    800069a2:	ffffe097          	auipc	ra,0xffffe
    800069a6:	558080e7          	jalr	1368(ra) # 80004efa <end_op>
    return -1;
    800069aa:	557d                	li	a0,-1
    800069ac:	b7ed                	j	80006996 <sys_chdir+0x7a>
    iunlockput(ip);
    800069ae:	8526                	mv	a0,s1
    800069b0:	ffffe097          	auipc	ra,0xffffe
    800069b4:	a34080e7          	jalr	-1484(ra) # 800043e4 <iunlockput>
    end_op();
    800069b8:	ffffe097          	auipc	ra,0xffffe
    800069bc:	542080e7          	jalr	1346(ra) # 80004efa <end_op>
    return -1;
    800069c0:	557d                	li	a0,-1
    800069c2:	bfd1                	j	80006996 <sys_chdir+0x7a>

00000000800069c4 <sys_exec>:

uint64
sys_exec(void)
{
    800069c4:	7145                	addi	sp,sp,-464
    800069c6:	e786                	sd	ra,456(sp)
    800069c8:	e3a2                	sd	s0,448(sp)
    800069ca:	ff26                	sd	s1,440(sp)
    800069cc:	fb4a                	sd	s2,432(sp)
    800069ce:	f74e                	sd	s3,424(sp)
    800069d0:	f352                	sd	s4,416(sp)
    800069d2:	ef56                	sd	s5,408(sp)
    800069d4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800069d6:	08000613          	li	a2,128
    800069da:	f4040593          	addi	a1,s0,-192
    800069de:	4501                	li	a0,0
    800069e0:	ffffd097          	auipc	ra,0xffffd
    800069e4:	c74080e7          	jalr	-908(ra) # 80003654 <argstr>
    return -1;
    800069e8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800069ea:	0c054a63          	bltz	a0,80006abe <sys_exec+0xfa>
    800069ee:	e3840593          	addi	a1,s0,-456
    800069f2:	4505                	li	a0,1
    800069f4:	ffffd097          	auipc	ra,0xffffd
    800069f8:	c3e080e7          	jalr	-962(ra) # 80003632 <argaddr>
    800069fc:	0c054163          	bltz	a0,80006abe <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006a00:	10000613          	li	a2,256
    80006a04:	4581                	li	a1,0
    80006a06:	e4040513          	addi	a0,s0,-448
    80006a0a:	ffffa097          	auipc	ra,0xffffa
    80006a0e:	2b4080e7          	jalr	692(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006a12:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006a16:	89a6                	mv	s3,s1
    80006a18:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006a1a:	02000a13          	li	s4,32
    80006a1e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006a22:	00391793          	slli	a5,s2,0x3
    80006a26:	e3040593          	addi	a1,s0,-464
    80006a2a:	e3843503          	ld	a0,-456(s0)
    80006a2e:	953e                	add	a0,a0,a5
    80006a30:	ffffd097          	auipc	ra,0xffffd
    80006a34:	b46080e7          	jalr	-1210(ra) # 80003576 <fetchaddr>
    80006a38:	02054a63          	bltz	a0,80006a6c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006a3c:	e3043783          	ld	a5,-464(s0)
    80006a40:	c3b9                	beqz	a5,80006a86 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006a42:	ffffa097          	auipc	ra,0xffffa
    80006a46:	090080e7          	jalr	144(ra) # 80000ad2 <kalloc>
    80006a4a:	85aa                	mv	a1,a0
    80006a4c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006a50:	cd11                	beqz	a0,80006a6c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006a52:	6605                	lui	a2,0x1
    80006a54:	e3043503          	ld	a0,-464(s0)
    80006a58:	ffffd097          	auipc	ra,0xffffd
    80006a5c:	b70080e7          	jalr	-1168(ra) # 800035c8 <fetchstr>
    80006a60:	00054663          	bltz	a0,80006a6c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006a64:	0905                	addi	s2,s2,1
    80006a66:	09a1                	addi	s3,s3,8
    80006a68:	fb491be3          	bne	s2,s4,80006a1e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006a6c:	10048913          	addi	s2,s1,256
    80006a70:	6088                	ld	a0,0(s1)
    80006a72:	c529                	beqz	a0,80006abc <sys_exec+0xf8>
    kfree(argv[i]);
    80006a74:	ffffa097          	auipc	ra,0xffffa
    80006a78:	f62080e7          	jalr	-158(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006a7c:	04a1                	addi	s1,s1,8
    80006a7e:	ff2499e3          	bne	s1,s2,80006a70 <sys_exec+0xac>
  return -1;
    80006a82:	597d                	li	s2,-1
    80006a84:	a82d                	j	80006abe <sys_exec+0xfa>
      argv[i] = 0;
    80006a86:	0a8e                	slli	s5,s5,0x3
    80006a88:	fc040793          	addi	a5,s0,-64
    80006a8c:	9abe                	add	s5,s5,a5
    80006a8e:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffcfe80>
  int ret = exec(path, argv);
    80006a92:	e4040593          	addi	a1,s0,-448
    80006a96:	f4040513          	addi	a0,s0,-192
    80006a9a:	fffff097          	auipc	ra,0xfffff
    80006a9e:	0f4080e7          	jalr	244(ra) # 80005b8e <exec>
    80006aa2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006aa4:	10048993          	addi	s3,s1,256
    80006aa8:	6088                	ld	a0,0(s1)
    80006aaa:	c911                	beqz	a0,80006abe <sys_exec+0xfa>
    kfree(argv[i]);
    80006aac:	ffffa097          	auipc	ra,0xffffa
    80006ab0:	f2a080e7          	jalr	-214(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ab4:	04a1                	addi	s1,s1,8
    80006ab6:	ff3499e3          	bne	s1,s3,80006aa8 <sys_exec+0xe4>
    80006aba:	a011                	j	80006abe <sys_exec+0xfa>
  return -1;
    80006abc:	597d                	li	s2,-1
}
    80006abe:	854a                	mv	a0,s2
    80006ac0:	60be                	ld	ra,456(sp)
    80006ac2:	641e                	ld	s0,448(sp)
    80006ac4:	74fa                	ld	s1,440(sp)
    80006ac6:	795a                	ld	s2,432(sp)
    80006ac8:	79ba                	ld	s3,424(sp)
    80006aca:	7a1a                	ld	s4,416(sp)
    80006acc:	6afa                	ld	s5,408(sp)
    80006ace:	6179                	addi	sp,sp,464
    80006ad0:	8082                	ret

0000000080006ad2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006ad2:	7139                	addi	sp,sp,-64
    80006ad4:	fc06                	sd	ra,56(sp)
    80006ad6:	f822                	sd	s0,48(sp)
    80006ad8:	f426                	sd	s1,40(sp)
    80006ada:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006adc:	ffffb097          	auipc	ra,0xffffb
    80006ae0:	254080e7          	jalr	596(ra) # 80001d30 <myproc>
    80006ae4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006ae6:	fd840593          	addi	a1,s0,-40
    80006aea:	4501                	li	a0,0
    80006aec:	ffffd097          	auipc	ra,0xffffd
    80006af0:	b46080e7          	jalr	-1210(ra) # 80003632 <argaddr>
    return -1;
    80006af4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006af6:	0e054063          	bltz	a0,80006bd6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006afa:	fc840593          	addi	a1,s0,-56
    80006afe:	fd040513          	addi	a0,s0,-48
    80006b02:	fffff097          	auipc	ra,0xfffff
    80006b06:	d6a080e7          	jalr	-662(ra) # 8000586c <pipealloc>
    return -1;
    80006b0a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006b0c:	0c054563          	bltz	a0,80006bd6 <sys_pipe+0x104>
  fd0 = -1;
    80006b10:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006b14:	fd043503          	ld	a0,-48(s0)
    80006b18:	fffff097          	auipc	ra,0xfffff
    80006b1c:	4e8080e7          	jalr	1256(ra) # 80006000 <fdalloc>
    80006b20:	fca42223          	sw	a0,-60(s0)
    80006b24:	08054c63          	bltz	a0,80006bbc <sys_pipe+0xea>
    80006b28:	fc843503          	ld	a0,-56(s0)
    80006b2c:	fffff097          	auipc	ra,0xfffff
    80006b30:	4d4080e7          	jalr	1236(ra) # 80006000 <fdalloc>
    80006b34:	fca42023          	sw	a0,-64(s0)
    80006b38:	06054863          	bltz	a0,80006ba8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006b3c:	4691                	li	a3,4
    80006b3e:	fc440613          	addi	a2,s0,-60
    80006b42:	fd843583          	ld	a1,-40(s0)
    80006b46:	68a8                	ld	a0,80(s1)
    80006b48:	ffffb097          	auipc	ra,0xffffb
    80006b4c:	84a080e7          	jalr	-1974(ra) # 80001392 <copyout>
    80006b50:	02054063          	bltz	a0,80006b70 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006b54:	4691                	li	a3,4
    80006b56:	fc040613          	addi	a2,s0,-64
    80006b5a:	fd843583          	ld	a1,-40(s0)
    80006b5e:	0591                	addi	a1,a1,4
    80006b60:	68a8                	ld	a0,80(s1)
    80006b62:	ffffb097          	auipc	ra,0xffffb
    80006b66:	830080e7          	jalr	-2000(ra) # 80001392 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006b6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006b6c:	06055563          	bgez	a0,80006bd6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006b70:	fc442783          	lw	a5,-60(s0)
    80006b74:	07e9                	addi	a5,a5,26
    80006b76:	078e                	slli	a5,a5,0x3
    80006b78:	97a6                	add	a5,a5,s1
    80006b7a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006b7e:	fc042503          	lw	a0,-64(s0)
    80006b82:	0569                	addi	a0,a0,26
    80006b84:	050e                	slli	a0,a0,0x3
    80006b86:	9526                	add	a0,a0,s1
    80006b88:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006b8c:	fd043503          	ld	a0,-48(s0)
    80006b90:	ffffe097          	auipc	ra,0xffffe
    80006b94:	7b6080e7          	jalr	1974(ra) # 80005346 <fileclose>
    fileclose(wf);
    80006b98:	fc843503          	ld	a0,-56(s0)
    80006b9c:	ffffe097          	auipc	ra,0xffffe
    80006ba0:	7aa080e7          	jalr	1962(ra) # 80005346 <fileclose>
    return -1;
    80006ba4:	57fd                	li	a5,-1
    80006ba6:	a805                	j	80006bd6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006ba8:	fc442783          	lw	a5,-60(s0)
    80006bac:	0007c863          	bltz	a5,80006bbc <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006bb0:	01a78513          	addi	a0,a5,26
    80006bb4:	050e                	slli	a0,a0,0x3
    80006bb6:	9526                	add	a0,a0,s1
    80006bb8:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006bbc:	fd043503          	ld	a0,-48(s0)
    80006bc0:	ffffe097          	auipc	ra,0xffffe
    80006bc4:	786080e7          	jalr	1926(ra) # 80005346 <fileclose>
    fileclose(wf);
    80006bc8:	fc843503          	ld	a0,-56(s0)
    80006bcc:	ffffe097          	auipc	ra,0xffffe
    80006bd0:	77a080e7          	jalr	1914(ra) # 80005346 <fileclose>
    return -1;
    80006bd4:	57fd                	li	a5,-1
}
    80006bd6:	853e                	mv	a0,a5
    80006bd8:	70e2                	ld	ra,56(sp)
    80006bda:	7442                	ld	s0,48(sp)
    80006bdc:	74a2                	ld	s1,40(sp)
    80006bde:	6121                	addi	sp,sp,64
    80006be0:	8082                	ret
	...

0000000080006bf0 <kernelvec>:
    80006bf0:	7111                	addi	sp,sp,-256
    80006bf2:	e006                	sd	ra,0(sp)
    80006bf4:	e40a                	sd	sp,8(sp)
    80006bf6:	e80e                	sd	gp,16(sp)
    80006bf8:	ec12                	sd	tp,24(sp)
    80006bfa:	f016                	sd	t0,32(sp)
    80006bfc:	f41a                	sd	t1,40(sp)
    80006bfe:	f81e                	sd	t2,48(sp)
    80006c00:	fc22                	sd	s0,56(sp)
    80006c02:	e0a6                	sd	s1,64(sp)
    80006c04:	e4aa                	sd	a0,72(sp)
    80006c06:	e8ae                	sd	a1,80(sp)
    80006c08:	ecb2                	sd	a2,88(sp)
    80006c0a:	f0b6                	sd	a3,96(sp)
    80006c0c:	f4ba                	sd	a4,104(sp)
    80006c0e:	f8be                	sd	a5,112(sp)
    80006c10:	fcc2                	sd	a6,120(sp)
    80006c12:	e146                	sd	a7,128(sp)
    80006c14:	e54a                	sd	s2,136(sp)
    80006c16:	e94e                	sd	s3,144(sp)
    80006c18:	ed52                	sd	s4,152(sp)
    80006c1a:	f156                	sd	s5,160(sp)
    80006c1c:	f55a                	sd	s6,168(sp)
    80006c1e:	f95e                	sd	s7,176(sp)
    80006c20:	fd62                	sd	s8,184(sp)
    80006c22:	e1e6                	sd	s9,192(sp)
    80006c24:	e5ea                	sd	s10,200(sp)
    80006c26:	e9ee                	sd	s11,208(sp)
    80006c28:	edf2                	sd	t3,216(sp)
    80006c2a:	f1f6                	sd	t4,224(sp)
    80006c2c:	f5fa                	sd	t5,232(sp)
    80006c2e:	f9fe                	sd	t6,240(sp)
    80006c30:	813fc0ef          	jal	ra,80003442 <kerneltrap>
    80006c34:	6082                	ld	ra,0(sp)
    80006c36:	6122                	ld	sp,8(sp)
    80006c38:	61c2                	ld	gp,16(sp)
    80006c3a:	7282                	ld	t0,32(sp)
    80006c3c:	7322                	ld	t1,40(sp)
    80006c3e:	73c2                	ld	t2,48(sp)
    80006c40:	7462                	ld	s0,56(sp)
    80006c42:	6486                	ld	s1,64(sp)
    80006c44:	6526                	ld	a0,72(sp)
    80006c46:	65c6                	ld	a1,80(sp)
    80006c48:	6666                	ld	a2,88(sp)
    80006c4a:	7686                	ld	a3,96(sp)
    80006c4c:	7726                	ld	a4,104(sp)
    80006c4e:	77c6                	ld	a5,112(sp)
    80006c50:	7866                	ld	a6,120(sp)
    80006c52:	688a                	ld	a7,128(sp)
    80006c54:	692a                	ld	s2,136(sp)
    80006c56:	69ca                	ld	s3,144(sp)
    80006c58:	6a6a                	ld	s4,152(sp)
    80006c5a:	7a8a                	ld	s5,160(sp)
    80006c5c:	7b2a                	ld	s6,168(sp)
    80006c5e:	7bca                	ld	s7,176(sp)
    80006c60:	7c6a                	ld	s8,184(sp)
    80006c62:	6c8e                	ld	s9,192(sp)
    80006c64:	6d2e                	ld	s10,200(sp)
    80006c66:	6dce                	ld	s11,208(sp)
    80006c68:	6e6e                	ld	t3,216(sp)
    80006c6a:	7e8e                	ld	t4,224(sp)
    80006c6c:	7f2e                	ld	t5,232(sp)
    80006c6e:	7fce                	ld	t6,240(sp)
    80006c70:	6111                	addi	sp,sp,256
    80006c72:	10200073          	sret
    80006c76:	00000013          	nop
    80006c7a:	00000013          	nop
    80006c7e:	0001                	nop

0000000080006c80 <timervec>:
    80006c80:	34051573          	csrrw	a0,mscratch,a0
    80006c84:	e10c                	sd	a1,0(a0)
    80006c86:	e510                	sd	a2,8(a0)
    80006c88:	e914                	sd	a3,16(a0)
    80006c8a:	6d0c                	ld	a1,24(a0)
    80006c8c:	7110                	ld	a2,32(a0)
    80006c8e:	6194                	ld	a3,0(a1)
    80006c90:	96b2                	add	a3,a3,a2
    80006c92:	e194                	sd	a3,0(a1)
    80006c94:	4589                	li	a1,2
    80006c96:	14459073          	csrw	sip,a1
    80006c9a:	6914                	ld	a3,16(a0)
    80006c9c:	6510                	ld	a2,8(a0)
    80006c9e:	610c                	ld	a1,0(a0)
    80006ca0:	34051573          	csrrw	a0,mscratch,a0
    80006ca4:	30200073          	mret
	...

0000000080006caa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006caa:	1141                	addi	sp,sp,-16
    80006cac:	e422                	sd	s0,8(sp)
    80006cae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006cb0:	0c0007b7          	lui	a5,0xc000
    80006cb4:	4705                	li	a4,1
    80006cb6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006cb8:	c3d8                	sw	a4,4(a5)
}
    80006cba:	6422                	ld	s0,8(sp)
    80006cbc:	0141                	addi	sp,sp,16
    80006cbe:	8082                	ret

0000000080006cc0 <plicinithart>:

void
plicinithart(void)
{
    80006cc0:	1141                	addi	sp,sp,-16
    80006cc2:	e406                	sd	ra,8(sp)
    80006cc4:	e022                	sd	s0,0(sp)
    80006cc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006cc8:	ffffb097          	auipc	ra,0xffffb
    80006ccc:	03c080e7          	jalr	60(ra) # 80001d04 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006cd0:	0085171b          	slliw	a4,a0,0x8
    80006cd4:	0c0027b7          	lui	a5,0xc002
    80006cd8:	97ba                	add	a5,a5,a4
    80006cda:	40200713          	li	a4,1026
    80006cde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006ce2:	00d5151b          	slliw	a0,a0,0xd
    80006ce6:	0c2017b7          	lui	a5,0xc201
    80006cea:	953e                	add	a0,a0,a5
    80006cec:	00052023          	sw	zero,0(a0)
}
    80006cf0:	60a2                	ld	ra,8(sp)
    80006cf2:	6402                	ld	s0,0(sp)
    80006cf4:	0141                	addi	sp,sp,16
    80006cf6:	8082                	ret

0000000080006cf8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006cf8:	1141                	addi	sp,sp,-16
    80006cfa:	e406                	sd	ra,8(sp)
    80006cfc:	e022                	sd	s0,0(sp)
    80006cfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006d00:	ffffb097          	auipc	ra,0xffffb
    80006d04:	004080e7          	jalr	4(ra) # 80001d04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006d08:	00d5179b          	slliw	a5,a0,0xd
    80006d0c:	0c201537          	lui	a0,0xc201
    80006d10:	953e                	add	a0,a0,a5
  return irq;
}
    80006d12:	4148                	lw	a0,4(a0)
    80006d14:	60a2                	ld	ra,8(sp)
    80006d16:	6402                	ld	s0,0(sp)
    80006d18:	0141                	addi	sp,sp,16
    80006d1a:	8082                	ret

0000000080006d1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006d1c:	1101                	addi	sp,sp,-32
    80006d1e:	ec06                	sd	ra,24(sp)
    80006d20:	e822                	sd	s0,16(sp)
    80006d22:	e426                	sd	s1,8(sp)
    80006d24:	1000                	addi	s0,sp,32
    80006d26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006d28:	ffffb097          	auipc	ra,0xffffb
    80006d2c:	fdc080e7          	jalr	-36(ra) # 80001d04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006d30:	00d5151b          	slliw	a0,a0,0xd
    80006d34:	0c2017b7          	lui	a5,0xc201
    80006d38:	97aa                	add	a5,a5,a0
    80006d3a:	c3c4                	sw	s1,4(a5)
}
    80006d3c:	60e2                	ld	ra,24(sp)
    80006d3e:	6442                	ld	s0,16(sp)
    80006d40:	64a2                	ld	s1,8(sp)
    80006d42:	6105                	addi	sp,sp,32
    80006d44:	8082                	ret

0000000080006d46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006d46:	1141                	addi	sp,sp,-16
    80006d48:	e406                	sd	ra,8(sp)
    80006d4a:	e022                	sd	s0,0(sp)
    80006d4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006d4e:	479d                	li	a5,7
    80006d50:	06a7c963          	blt	a5,a0,80006dc2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006d54:	00025797          	auipc	a5,0x25
    80006d58:	2ac78793          	addi	a5,a5,684 # 8002c000 <disk>
    80006d5c:	00a78733          	add	a4,a5,a0
    80006d60:	6789                	lui	a5,0x2
    80006d62:	97ba                	add	a5,a5,a4
    80006d64:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006d68:	e7ad                	bnez	a5,80006dd2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006d6a:	00451793          	slli	a5,a0,0x4
    80006d6e:	00027717          	auipc	a4,0x27
    80006d72:	29270713          	addi	a4,a4,658 # 8002e000 <disk+0x2000>
    80006d76:	6314                	ld	a3,0(a4)
    80006d78:	96be                	add	a3,a3,a5
    80006d7a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006d7e:	6314                	ld	a3,0(a4)
    80006d80:	96be                	add	a3,a3,a5
    80006d82:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006d86:	6314                	ld	a3,0(a4)
    80006d88:	96be                	add	a3,a3,a5
    80006d8a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006d8e:	6318                	ld	a4,0(a4)
    80006d90:	97ba                	add	a5,a5,a4
    80006d92:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006d96:	00025797          	auipc	a5,0x25
    80006d9a:	26a78793          	addi	a5,a5,618 # 8002c000 <disk>
    80006d9e:	97aa                	add	a5,a5,a0
    80006da0:	6509                	lui	a0,0x2
    80006da2:	953e                	add	a0,a0,a5
    80006da4:	4785                	li	a5,1
    80006da6:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006daa:	00027517          	auipc	a0,0x27
    80006dae:	26e50513          	addi	a0,a0,622 # 8002e018 <disk+0x2018>
    80006db2:	ffffb097          	auipc	ra,0xffffb
    80006db6:	602080e7          	jalr	1538(ra) # 800023b4 <wakeup>
}
    80006dba:	60a2                	ld	ra,8(sp)
    80006dbc:	6402                	ld	s0,0(sp)
    80006dbe:	0141                	addi	sp,sp,16
    80006dc0:	8082                	ret
    panic("free_desc 1");
    80006dc2:	00003517          	auipc	a0,0x3
    80006dc6:	0b650513          	addi	a0,a0,182 # 80009e78 <syscalls+0x3d0>
    80006dca:	ffff9097          	auipc	ra,0xffff9
    80006dce:	760080e7          	jalr	1888(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006dd2:	00003517          	auipc	a0,0x3
    80006dd6:	0b650513          	addi	a0,a0,182 # 80009e88 <syscalls+0x3e0>
    80006dda:	ffff9097          	auipc	ra,0xffff9
    80006dde:	750080e7          	jalr	1872(ra) # 8000052a <panic>

0000000080006de2 <virtio_disk_init>:
{
    80006de2:	1101                	addi	sp,sp,-32
    80006de4:	ec06                	sd	ra,24(sp)
    80006de6:	e822                	sd	s0,16(sp)
    80006de8:	e426                	sd	s1,8(sp)
    80006dea:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006dec:	00003597          	auipc	a1,0x3
    80006df0:	0ac58593          	addi	a1,a1,172 # 80009e98 <syscalls+0x3f0>
    80006df4:	00027517          	auipc	a0,0x27
    80006df8:	33450513          	addi	a0,a0,820 # 8002e128 <disk+0x2128>
    80006dfc:	ffffa097          	auipc	ra,0xffffa
    80006e00:	d36080e7          	jalr	-714(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e04:	100017b7          	lui	a5,0x10001
    80006e08:	4398                	lw	a4,0(a5)
    80006e0a:	2701                	sext.w	a4,a4
    80006e0c:	747277b7          	lui	a5,0x74727
    80006e10:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006e14:	0ef71163          	bne	a4,a5,80006ef6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e18:	100017b7          	lui	a5,0x10001
    80006e1c:	43dc                	lw	a5,4(a5)
    80006e1e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006e20:	4705                	li	a4,1
    80006e22:	0ce79a63          	bne	a5,a4,80006ef6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e26:	100017b7          	lui	a5,0x10001
    80006e2a:	479c                	lw	a5,8(a5)
    80006e2c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006e2e:	4709                	li	a4,2
    80006e30:	0ce79363          	bne	a5,a4,80006ef6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006e34:	100017b7          	lui	a5,0x10001
    80006e38:	47d8                	lw	a4,12(a5)
    80006e3a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006e3c:	554d47b7          	lui	a5,0x554d4
    80006e40:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006e44:	0af71963          	bne	a4,a5,80006ef6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e48:	100017b7          	lui	a5,0x10001
    80006e4c:	4705                	li	a4,1
    80006e4e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e50:	470d                	li	a4,3
    80006e52:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006e54:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006e56:	c7ffe737          	lui	a4,0xc7ffe
    80006e5a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fcf75f>
    80006e5e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006e60:	2701                	sext.w	a4,a4
    80006e62:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e64:	472d                	li	a4,11
    80006e66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006e68:	473d                	li	a4,15
    80006e6a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006e6c:	6705                	lui	a4,0x1
    80006e6e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006e70:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006e74:	5bdc                	lw	a5,52(a5)
    80006e76:	2781                	sext.w	a5,a5
  if(max == 0)
    80006e78:	c7d9                	beqz	a5,80006f06 <virtio_disk_init+0x124>
  if(max < NUM)
    80006e7a:	471d                	li	a4,7
    80006e7c:	08f77d63          	bgeu	a4,a5,80006f16 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006e80:	100014b7          	lui	s1,0x10001
    80006e84:	47a1                	li	a5,8
    80006e86:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006e88:	6609                	lui	a2,0x2
    80006e8a:	4581                	li	a1,0
    80006e8c:	00025517          	auipc	a0,0x25
    80006e90:	17450513          	addi	a0,a0,372 # 8002c000 <disk>
    80006e94:	ffffa097          	auipc	ra,0xffffa
    80006e98:	e2a080e7          	jalr	-470(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006e9c:	00025717          	auipc	a4,0x25
    80006ea0:	16470713          	addi	a4,a4,356 # 8002c000 <disk>
    80006ea4:	00c75793          	srli	a5,a4,0xc
    80006ea8:	2781                	sext.w	a5,a5
    80006eaa:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006eac:	00027797          	auipc	a5,0x27
    80006eb0:	15478793          	addi	a5,a5,340 # 8002e000 <disk+0x2000>
    80006eb4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006eb6:	00025717          	auipc	a4,0x25
    80006eba:	1ca70713          	addi	a4,a4,458 # 8002c080 <disk+0x80>
    80006ebe:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006ec0:	00026717          	auipc	a4,0x26
    80006ec4:	14070713          	addi	a4,a4,320 # 8002d000 <disk+0x1000>
    80006ec8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006eca:	4705                	li	a4,1
    80006ecc:	00e78c23          	sb	a4,24(a5)
    80006ed0:	00e78ca3          	sb	a4,25(a5)
    80006ed4:	00e78d23          	sb	a4,26(a5)
    80006ed8:	00e78da3          	sb	a4,27(a5)
    80006edc:	00e78e23          	sb	a4,28(a5)
    80006ee0:	00e78ea3          	sb	a4,29(a5)
    80006ee4:	00e78f23          	sb	a4,30(a5)
    80006ee8:	00e78fa3          	sb	a4,31(a5)
}
    80006eec:	60e2                	ld	ra,24(sp)
    80006eee:	6442                	ld	s0,16(sp)
    80006ef0:	64a2                	ld	s1,8(sp)
    80006ef2:	6105                	addi	sp,sp,32
    80006ef4:	8082                	ret
    panic("could not find virtio disk");
    80006ef6:	00003517          	auipc	a0,0x3
    80006efa:	fb250513          	addi	a0,a0,-78 # 80009ea8 <syscalls+0x400>
    80006efe:	ffff9097          	auipc	ra,0xffff9
    80006f02:	62c080e7          	jalr	1580(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006f06:	00003517          	auipc	a0,0x3
    80006f0a:	fc250513          	addi	a0,a0,-62 # 80009ec8 <syscalls+0x420>
    80006f0e:	ffff9097          	auipc	ra,0xffff9
    80006f12:	61c080e7          	jalr	1564(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006f16:	00003517          	auipc	a0,0x3
    80006f1a:	fd250513          	addi	a0,a0,-46 # 80009ee8 <syscalls+0x440>
    80006f1e:	ffff9097          	auipc	ra,0xffff9
    80006f22:	60c080e7          	jalr	1548(ra) # 8000052a <panic>

0000000080006f26 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006f26:	7119                	addi	sp,sp,-128
    80006f28:	fc86                	sd	ra,120(sp)
    80006f2a:	f8a2                	sd	s0,112(sp)
    80006f2c:	f4a6                	sd	s1,104(sp)
    80006f2e:	f0ca                	sd	s2,96(sp)
    80006f30:	ecce                	sd	s3,88(sp)
    80006f32:	e8d2                	sd	s4,80(sp)
    80006f34:	e4d6                	sd	s5,72(sp)
    80006f36:	e0da                	sd	s6,64(sp)
    80006f38:	fc5e                	sd	s7,56(sp)
    80006f3a:	f862                	sd	s8,48(sp)
    80006f3c:	f466                	sd	s9,40(sp)
    80006f3e:	f06a                	sd	s10,32(sp)
    80006f40:	ec6e                	sd	s11,24(sp)
    80006f42:	0100                	addi	s0,sp,128
    80006f44:	8aaa                	mv	s5,a0
    80006f46:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006f48:	00c52c83          	lw	s9,12(a0)
    80006f4c:	001c9c9b          	slliw	s9,s9,0x1
    80006f50:	1c82                	slli	s9,s9,0x20
    80006f52:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006f56:	00027517          	auipc	a0,0x27
    80006f5a:	1d250513          	addi	a0,a0,466 # 8002e128 <disk+0x2128>
    80006f5e:	ffffa097          	auipc	ra,0xffffa
    80006f62:	c64080e7          	jalr	-924(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006f66:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006f68:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006f6a:	00025c17          	auipc	s8,0x25
    80006f6e:	096c0c13          	addi	s8,s8,150 # 8002c000 <disk>
    80006f72:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006f74:	4b0d                	li	s6,3
    80006f76:	a0ad                	j	80006fe0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006f78:	00fc0733          	add	a4,s8,a5
    80006f7c:	975e                	add	a4,a4,s7
    80006f7e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006f82:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006f84:	0207c563          	bltz	a5,80006fae <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006f88:	2905                	addiw	s2,s2,1
    80006f8a:	0611                	addi	a2,a2,4
    80006f8c:	19690d63          	beq	s2,s6,80007126 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006f90:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006f92:	00027717          	auipc	a4,0x27
    80006f96:	08670713          	addi	a4,a4,134 # 8002e018 <disk+0x2018>
    80006f9a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006f9c:	00074683          	lbu	a3,0(a4)
    80006fa0:	fee1                	bnez	a3,80006f78 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006fa2:	2785                	addiw	a5,a5,1
    80006fa4:	0705                	addi	a4,a4,1
    80006fa6:	fe979be3          	bne	a5,s1,80006f9c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006faa:	57fd                	li	a5,-1
    80006fac:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006fae:	01205d63          	blez	s2,80006fc8 <virtio_disk_rw+0xa2>
    80006fb2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006fb4:	000a2503          	lw	a0,0(s4)
    80006fb8:	00000097          	auipc	ra,0x0
    80006fbc:	d8e080e7          	jalr	-626(ra) # 80006d46 <free_desc>
      for(int j = 0; j < i; j++)
    80006fc0:	2d85                	addiw	s11,s11,1
    80006fc2:	0a11                	addi	s4,s4,4
    80006fc4:	ffb918e3          	bne	s2,s11,80006fb4 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006fc8:	00027597          	auipc	a1,0x27
    80006fcc:	16058593          	addi	a1,a1,352 # 8002e128 <disk+0x2128>
    80006fd0:	00027517          	auipc	a0,0x27
    80006fd4:	04850513          	addi	a0,a0,72 # 8002e018 <disk+0x2018>
    80006fd8:	ffffb097          	auipc	ra,0xffffb
    80006fdc:	250080e7          	jalr	592(ra) # 80002228 <sleep>
  for(int i = 0; i < 3; i++){
    80006fe0:	f8040a13          	addi	s4,s0,-128
{
    80006fe4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006fe6:	894e                	mv	s2,s3
    80006fe8:	b765                	j	80006f90 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006fea:	00027697          	auipc	a3,0x27
    80006fee:	0166b683          	ld	a3,22(a3) # 8002e000 <disk+0x2000>
    80006ff2:	96ba                	add	a3,a3,a4
    80006ff4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006ff8:	00025817          	auipc	a6,0x25
    80006ffc:	00880813          	addi	a6,a6,8 # 8002c000 <disk>
    80007000:	00027697          	auipc	a3,0x27
    80007004:	00068693          	mv	a3,a3
    80007008:	6290                	ld	a2,0(a3)
    8000700a:	963a                	add	a2,a2,a4
    8000700c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80007010:	0015e593          	ori	a1,a1,1
    80007014:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80007018:	f8842603          	lw	a2,-120(s0)
    8000701c:	628c                	ld	a1,0(a3)
    8000701e:	972e                	add	a4,a4,a1
    80007020:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007024:	20050593          	addi	a1,a0,512
    80007028:	0592                	slli	a1,a1,0x4
    8000702a:	95c2                	add	a1,a1,a6
    8000702c:	577d                	li	a4,-1
    8000702e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007032:	00461713          	slli	a4,a2,0x4
    80007036:	6290                	ld	a2,0(a3)
    80007038:	963a                	add	a2,a2,a4
    8000703a:	03078793          	addi	a5,a5,48
    8000703e:	97c2                	add	a5,a5,a6
    80007040:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007042:	629c                	ld	a5,0(a3)
    80007044:	97ba                	add	a5,a5,a4
    80007046:	4605                	li	a2,1
    80007048:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000704a:	629c                	ld	a5,0(a3)
    8000704c:	97ba                	add	a5,a5,a4
    8000704e:	4809                	li	a6,2
    80007050:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007054:	629c                	ld	a5,0(a3)
    80007056:	973e                	add	a4,a4,a5
    80007058:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000705c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007060:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007064:	6698                	ld	a4,8(a3)
    80007066:	00275783          	lhu	a5,2(a4)
    8000706a:	8b9d                	andi	a5,a5,7
    8000706c:	0786                	slli	a5,a5,0x1
    8000706e:	97ba                	add	a5,a5,a4
    80007070:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007074:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007078:	6698                	ld	a4,8(a3)
    8000707a:	00275783          	lhu	a5,2(a4)
    8000707e:	2785                	addiw	a5,a5,1
    80007080:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007084:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007088:	100017b7          	lui	a5,0x10001
    8000708c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007090:	004aa783          	lw	a5,4(s5)
    80007094:	02c79163          	bne	a5,a2,800070b6 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007098:	00027917          	auipc	s2,0x27
    8000709c:	09090913          	addi	s2,s2,144 # 8002e128 <disk+0x2128>
  while(b->disk == 1) {
    800070a0:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800070a2:	85ca                	mv	a1,s2
    800070a4:	8556                	mv	a0,s5
    800070a6:	ffffb097          	auipc	ra,0xffffb
    800070aa:	182080e7          	jalr	386(ra) # 80002228 <sleep>
  while(b->disk == 1) {
    800070ae:	004aa783          	lw	a5,4(s5)
    800070b2:	fe9788e3          	beq	a5,s1,800070a2 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800070b6:	f8042903          	lw	s2,-128(s0)
    800070ba:	20090793          	addi	a5,s2,512
    800070be:	00479713          	slli	a4,a5,0x4
    800070c2:	00025797          	auipc	a5,0x25
    800070c6:	f3e78793          	addi	a5,a5,-194 # 8002c000 <disk>
    800070ca:	97ba                	add	a5,a5,a4
    800070cc:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800070d0:	00027997          	auipc	s3,0x27
    800070d4:	f3098993          	addi	s3,s3,-208 # 8002e000 <disk+0x2000>
    800070d8:	00491713          	slli	a4,s2,0x4
    800070dc:	0009b783          	ld	a5,0(s3)
    800070e0:	97ba                	add	a5,a5,a4
    800070e2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800070e6:	854a                	mv	a0,s2
    800070e8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800070ec:	00000097          	auipc	ra,0x0
    800070f0:	c5a080e7          	jalr	-934(ra) # 80006d46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800070f4:	8885                	andi	s1,s1,1
    800070f6:	f0ed                	bnez	s1,800070d8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800070f8:	00027517          	auipc	a0,0x27
    800070fc:	03050513          	addi	a0,a0,48 # 8002e128 <disk+0x2128>
    80007100:	ffffa097          	auipc	ra,0xffffa
    80007104:	b76080e7          	jalr	-1162(ra) # 80000c76 <release>
}
    80007108:	70e6                	ld	ra,120(sp)
    8000710a:	7446                	ld	s0,112(sp)
    8000710c:	74a6                	ld	s1,104(sp)
    8000710e:	7906                	ld	s2,96(sp)
    80007110:	69e6                	ld	s3,88(sp)
    80007112:	6a46                	ld	s4,80(sp)
    80007114:	6aa6                	ld	s5,72(sp)
    80007116:	6b06                	ld	s6,64(sp)
    80007118:	7be2                	ld	s7,56(sp)
    8000711a:	7c42                	ld	s8,48(sp)
    8000711c:	7ca2                	ld	s9,40(sp)
    8000711e:	7d02                	ld	s10,32(sp)
    80007120:	6de2                	ld	s11,24(sp)
    80007122:	6109                	addi	sp,sp,128
    80007124:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007126:	f8042503          	lw	a0,-128(s0)
    8000712a:	20050793          	addi	a5,a0,512
    8000712e:	0792                	slli	a5,a5,0x4
  if(write)
    80007130:	00025817          	auipc	a6,0x25
    80007134:	ed080813          	addi	a6,a6,-304 # 8002c000 <disk>
    80007138:	00f80733          	add	a4,a6,a5
    8000713c:	01a036b3          	snez	a3,s10
    80007140:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007144:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007148:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000714c:	7679                	lui	a2,0xffffe
    8000714e:	963e                	add	a2,a2,a5
    80007150:	00027697          	auipc	a3,0x27
    80007154:	eb068693          	addi	a3,a3,-336 # 8002e000 <disk+0x2000>
    80007158:	6298                	ld	a4,0(a3)
    8000715a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000715c:	0a878593          	addi	a1,a5,168
    80007160:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007162:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007164:	6298                	ld	a4,0(a3)
    80007166:	9732                	add	a4,a4,a2
    80007168:	45c1                	li	a1,16
    8000716a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000716c:	6298                	ld	a4,0(a3)
    8000716e:	9732                	add	a4,a4,a2
    80007170:	4585                	li	a1,1
    80007172:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007176:	f8442703          	lw	a4,-124(s0)
    8000717a:	628c                	ld	a1,0(a3)
    8000717c:	962e                	add	a2,a2,a1
    8000717e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffcf00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007182:	0712                	slli	a4,a4,0x4
    80007184:	6290                	ld	a2,0(a3)
    80007186:	963a                	add	a2,a2,a4
    80007188:	058a8593          	addi	a1,s5,88
    8000718c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000718e:	6294                	ld	a3,0(a3)
    80007190:	96ba                	add	a3,a3,a4
    80007192:	40000613          	li	a2,1024
    80007196:	c690                	sw	a2,8(a3)
  if(write)
    80007198:	e40d19e3          	bnez	s10,80006fea <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000719c:	00027697          	auipc	a3,0x27
    800071a0:	e646b683          	ld	a3,-412(a3) # 8002e000 <disk+0x2000>
    800071a4:	96ba                	add	a3,a3,a4
    800071a6:	4609                	li	a2,2
    800071a8:	00c69623          	sh	a2,12(a3)
    800071ac:	b5b1                	j	80006ff8 <virtio_disk_rw+0xd2>

00000000800071ae <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800071ae:	1101                	addi	sp,sp,-32
    800071b0:	ec06                	sd	ra,24(sp)
    800071b2:	e822                	sd	s0,16(sp)
    800071b4:	e426                	sd	s1,8(sp)
    800071b6:	e04a                	sd	s2,0(sp)
    800071b8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800071ba:	00027517          	auipc	a0,0x27
    800071be:	f6e50513          	addi	a0,a0,-146 # 8002e128 <disk+0x2128>
    800071c2:	ffffa097          	auipc	ra,0xffffa
    800071c6:	a00080e7          	jalr	-1536(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800071ca:	10001737          	lui	a4,0x10001
    800071ce:	533c                	lw	a5,96(a4)
    800071d0:	8b8d                	andi	a5,a5,3
    800071d2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800071d4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800071d8:	00027797          	auipc	a5,0x27
    800071dc:	e2878793          	addi	a5,a5,-472 # 8002e000 <disk+0x2000>
    800071e0:	6b94                	ld	a3,16(a5)
    800071e2:	0207d703          	lhu	a4,32(a5)
    800071e6:	0026d783          	lhu	a5,2(a3)
    800071ea:	06f70163          	beq	a4,a5,8000724c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800071ee:	00025917          	auipc	s2,0x25
    800071f2:	e1290913          	addi	s2,s2,-494 # 8002c000 <disk>
    800071f6:	00027497          	auipc	s1,0x27
    800071fa:	e0a48493          	addi	s1,s1,-502 # 8002e000 <disk+0x2000>
    __sync_synchronize();
    800071fe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80007202:	6898                	ld	a4,16(s1)
    80007204:	0204d783          	lhu	a5,32(s1)
    80007208:	8b9d                	andi	a5,a5,7
    8000720a:	078e                	slli	a5,a5,0x3
    8000720c:	97ba                	add	a5,a5,a4
    8000720e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80007210:	20078713          	addi	a4,a5,512
    80007214:	0712                	slli	a4,a4,0x4
    80007216:	974a                	add	a4,a4,s2
    80007218:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000721c:	e731                	bnez	a4,80007268 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000721e:	20078793          	addi	a5,a5,512
    80007222:	0792                	slli	a5,a5,0x4
    80007224:	97ca                	add	a5,a5,s2
    80007226:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007228:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000722c:	ffffb097          	auipc	ra,0xffffb
    80007230:	188080e7          	jalr	392(ra) # 800023b4 <wakeup>

    disk.used_idx += 1;
    80007234:	0204d783          	lhu	a5,32(s1)
    80007238:	2785                	addiw	a5,a5,1
    8000723a:	17c2                	slli	a5,a5,0x30
    8000723c:	93c1                	srli	a5,a5,0x30
    8000723e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007242:	6898                	ld	a4,16(s1)
    80007244:	00275703          	lhu	a4,2(a4)
    80007248:	faf71be3          	bne	a4,a5,800071fe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000724c:	00027517          	auipc	a0,0x27
    80007250:	edc50513          	addi	a0,a0,-292 # 8002e128 <disk+0x2128>
    80007254:	ffffa097          	auipc	ra,0xffffa
    80007258:	a22080e7          	jalr	-1502(ra) # 80000c76 <release>
}
    8000725c:	60e2                	ld	ra,24(sp)
    8000725e:	6442                	ld	s0,16(sp)
    80007260:	64a2                	ld	s1,8(sp)
    80007262:	6902                	ld	s2,0(sp)
    80007264:	6105                	addi	sp,sp,32
    80007266:	8082                	ret
      panic("virtio_disk_intr status");
    80007268:	00003517          	auipc	a0,0x3
    8000726c:	ca050513          	addi	a0,a0,-864 # 80009f08 <syscalls+0x460>
    80007270:	ffff9097          	auipc	ra,0xffff9
    80007274:	2ba080e7          	jalr	698(ra) # 8000052a <panic>
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
