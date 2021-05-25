
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
    80000068:	3bc78793          	addi	a5,a5,956 # 80006420 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd07ff>
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
    80000122:	1fe080e7          	jalr	510(ra) # 8000231c <either_copyin>
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
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7e8080e7          	jalr	2024(ra) # 8000199a <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	d60080e7          	jalr	-672(ra) # 80001f22 <sleep>
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
    80000202:	0c8080e7          	jalr	200(ra) # 800022c6 <either_copyout>
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
    800002e2:	094080e7          	jalr	148(ra) # 80002372 <procdump>
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
    80000436:	c7c080e7          	jalr	-900(ra) # 800020ae <wakeup>
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
    80000464:	00029797          	auipc	a5,0x29
    80000468:	4b478793          	addi	a5,a5,1204 # 80029918 <devsw>
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
    80000882:	830080e7          	jalr	-2000(ra) # 800020ae <wakeup>
    
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
    8000090a:	00001097          	auipc	ra,0x1
    8000090e:	618080e7          	jalr	1560(ra) # 80001f22 <sleep>
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
    800009ea:	0002d797          	auipc	a5,0x2d
    800009ee:	61678793          	addi	a5,a5,1558 # 8002e000 <end>
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
    80000aba:	0002d517          	auipc	a0,0x2d
    80000abe:	54650513          	addi	a0,a0,1350 # 8002e000 <end>
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
    80000b60:	e22080e7          	jalr	-478(ra) # 8000197e <mycpu>
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
    80000b92:	df0080e7          	jalr	-528(ra) # 8000197e <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	de4080e7          	jalr	-540(ra) # 8000197e <mycpu>
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
    80000bb6:	dcc080e7          	jalr	-564(ra) # 8000197e <mycpu>
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
    80000bf6:	d8c080e7          	jalr	-628(ra) # 8000197e <mycpu>
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
    80000c22:	d60080e7          	jalr	-672(ra) # 8000197e <mycpu>
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
    80000e78:	afa080e7          	jalr	-1286(ra) # 8000196e <cpuid>
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
    80000e94:	ade080e7          	jalr	-1314(ra) # 8000196e <cpuid>
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
    80000eb6:	a84080e7          	jalr	-1404(ra) # 80002936 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	5a6080e7          	jalr	1446(ra) # 80006460 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	eae080e7          	jalr	-338(ra) # 80001d70 <scheduler>
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
    80000f16:	326080e7          	jalr	806(ra) # 80001238 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	99c080e7          	jalr	-1636(ra) # 800018be <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	9e4080e7          	jalr	-1564(ra) # 8000290e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	a04080e7          	jalr	-1532(ra) # 80002936 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	510080e7          	jalr	1296(ra) # 8000644a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	51e080e7          	jalr	1310(ra) # 80006460 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	1ba080e7          	jalr	442(ra) # 80003104 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	84c080e7          	jalr	-1972(ra) # 8000379e <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	b0c080e7          	jalr	-1268(ra) # 80004a66 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	620080e7          	jalr	1568(ra) # 80006582 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	d10080e7          	jalr	-752(ra) # 80001c7a <userinit>
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
  // check if we have space in phsical addres or in case the 

  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    *pte ^= PTE_V;     // page table entry now invalid
    *pte |= PTE_PG;    // paged out to secondary storage

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
  if(pte == 0)
    80001070:	c905                	beqz	a0,800010a0 <walkaddr+0x54>
  if((*pte & PTE_V) == 0)
    80001072:	6114                	ld	a3,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0116f613          	andi	a2,a3,17
    80001078:	47c5                	li	a5,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
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
  if(to_page_out){  // case we are paging out need to update flags in pte
    80001092:	d4fd                	beqz	s1,80001080 <walkaddr+0x34>
    *pte ^= PTE_V;     // page table entry now invalid
    80001094:	0016c693          	xori	a3,a3,1
    *pte |= PTE_PG;    // paged out to secondary storage
    80001098:	2006e693          	ori	a3,a3,512
    8000109c:	e314                	sd	a3,0(a4)
    8000109e:	b7cd                	j	80001080 <walkaddr+0x34>
    return 0;
    800010a0:	4501                	li	a0,0
    800010a2:	bff9                	j	80001080 <walkaddr+0x34>

00000000800010a4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a4:	715d                	addi	sp,sp,-80
    800010a6:	e486                	sd	ra,72(sp)
    800010a8:	e0a2                	sd	s0,64(sp)
    800010aa:	fc26                	sd	s1,56(sp)
    800010ac:	f84a                	sd	s2,48(sp)
    800010ae:	f44e                	sd	s3,40(sp)
    800010b0:	f052                	sd	s4,32(sp)
    800010b2:	ec56                	sd	s5,24(sp)
    800010b4:	e85a                	sd	s6,16(sp)
    800010b6:	e45e                	sd	s7,8(sp)
    800010b8:	0880                	addi	s0,sp,80
    800010ba:	8aaa                	mv	s5,a0
    800010bc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010be:	777d                	lui	a4,0xfffff
    800010c0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c4:	167d                	addi	a2,a2,-1
    800010c6:	00b609b3          	add	s3,a2,a1
    800010ca:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ce:	893e                	mv	s2,a5
    800010d0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d4:	6b85                	lui	s7,0x1
    800010d6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010da:	4605                	li	a2,1
    800010dc:	85ca                	mv	a1,s2
    800010de:	8556                	mv	a0,s5
    800010e0:	00000097          	auipc	ra,0x0
    800010e4:	ec6080e7          	jalr	-314(ra) # 80000fa6 <walk>
    800010e8:	c51d                	beqz	a0,80001116 <mappages+0x72>
    if(*pte & PTE_V)
    800010ea:	611c                	ld	a5,0(a0)
    800010ec:	8b85                	andi	a5,a5,1
    800010ee:	ef81                	bnez	a5,80001106 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f0:	80b1                	srli	s1,s1,0xc
    800010f2:	04aa                	slli	s1,s1,0xa
    800010f4:	0164e4b3          	or	s1,s1,s6
    800010f8:	0014e493          	ori	s1,s1,1
    800010fc:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fe:	03390863          	beq	s2,s3,8000112e <mappages+0x8a>
    a += PGSIZE;
    80001102:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001104:	bfc9                	j	800010d6 <mappages+0x32>
      panic("remap");
    80001106:	00007517          	auipc	a0,0x7
    8000110a:	fd250513          	addi	a0,a0,-46 # 800080d8 <digits+0x98>
    8000110e:	fffff097          	auipc	ra,0xfffff
    80001112:	41c080e7          	jalr	1052(ra) # 8000052a <panic>
      return -1;
    80001116:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001118:	60a6                	ld	ra,72(sp)
    8000111a:	6406                	ld	s0,64(sp)
    8000111c:	74e2                	ld	s1,56(sp)
    8000111e:	7942                	ld	s2,48(sp)
    80001120:	79a2                	ld	s3,40(sp)
    80001122:	7a02                	ld	s4,32(sp)
    80001124:	6ae2                	ld	s5,24(sp)
    80001126:	6b42                	ld	s6,16(sp)
    80001128:	6ba2                	ld	s7,8(sp)
    8000112a:	6161                	addi	sp,sp,80
    8000112c:	8082                	ret
  return 0;
    8000112e:	4501                	li	a0,0
    80001130:	b7e5                	j	80001118 <mappages+0x74>

0000000080001132 <kvmmap>:
{
    80001132:	1141                	addi	sp,sp,-16
    80001134:	e406                	sd	ra,8(sp)
    80001136:	e022                	sd	s0,0(sp)
    80001138:	0800                	addi	s0,sp,16
    8000113a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113c:	86b2                	mv	a3,a2
    8000113e:	863e                	mv	a2,a5
    80001140:	00000097          	auipc	ra,0x0
    80001144:	f64080e7          	jalr	-156(ra) # 800010a4 <mappages>
    80001148:	e509                	bnez	a0,80001152 <kvmmap+0x20>
}
    8000114a:	60a2                	ld	ra,8(sp)
    8000114c:	6402                	ld	s0,0(sp)
    8000114e:	0141                	addi	sp,sp,16
    80001150:	8082                	ret
    panic("kvmmap");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f8e50513          	addi	a0,a0,-114 # 800080e0 <digits+0xa0>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	3d0080e7          	jalr	976(ra) # 8000052a <panic>

0000000080001162 <kvmmake>:
{
    80001162:	1101                	addi	sp,sp,-32
    80001164:	ec06                	sd	ra,24(sp)
    80001166:	e822                	sd	s0,16(sp)
    80001168:	e426                	sd	s1,8(sp)
    8000116a:	e04a                	sd	s2,0(sp)
    8000116c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000116e:	00000097          	auipc	ra,0x0
    80001172:	964080e7          	jalr	-1692(ra) # 80000ad2 <kalloc>
    80001176:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001178:	6605                	lui	a2,0x1
    8000117a:	4581                	li	a1,0
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	b42080e7          	jalr	-1214(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10000637          	lui	a2,0x10000
    8000118c:	100005b7          	lui	a1,0x10000
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	fa0080e7          	jalr	-96(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	6685                	lui	a3,0x1
    8000119e:	10001637          	lui	a2,0x10001
    800011a2:	100015b7          	lui	a1,0x10001
    800011a6:	8526                	mv	a0,s1
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	f8a080e7          	jalr	-118(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	004006b7          	lui	a3,0x400
    800011b6:	0c000637          	lui	a2,0xc000
    800011ba:	0c0005b7          	lui	a1,0xc000
    800011be:	8526                	mv	a0,s1
    800011c0:	00000097          	auipc	ra,0x0
    800011c4:	f72080e7          	jalr	-142(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011c8:	00007917          	auipc	s2,0x7
    800011cc:	e3890913          	addi	s2,s2,-456 # 80008000 <etext>
    800011d0:	4729                	li	a4,10
    800011d2:	80007697          	auipc	a3,0x80007
    800011d6:	e2e68693          	addi	a3,a3,-466 # 8000 <_entry-0x7fff8000>
    800011da:	4605                	li	a2,1
    800011dc:	067e                	slli	a2,a2,0x1f
    800011de:	85b2                	mv	a1,a2
    800011e0:	8526                	mv	a0,s1
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	f50080e7          	jalr	-176(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	46c5                	li	a3,17
    800011ee:	06ee                	slli	a3,a3,0x1b
    800011f0:	412686b3          	sub	a3,a3,s2
    800011f4:	864a                	mv	a2,s2
    800011f6:	85ca                	mv	a1,s2
    800011f8:	8526                	mv	a0,s1
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f38080e7          	jalr	-200(ra) # 80001132 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001202:	4729                	li	a4,10
    80001204:	6685                	lui	a3,0x1
    80001206:	00006617          	auipc	a2,0x6
    8000120a:	dfa60613          	addi	a2,a2,-518 # 80007000 <_trampoline>
    8000120e:	040005b7          	lui	a1,0x4000
    80001212:	15fd                	addi	a1,a1,-1
    80001214:	05b2                	slli	a1,a1,0xc
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f1a080e7          	jalr	-230(ra) # 80001132 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	606080e7          	jalr	1542(ra) # 80001828 <proc_mapstacks>
}
    8000122a:	8526                	mv	a0,s1
    8000122c:	60e2                	ld	ra,24(sp)
    8000122e:	6442                	ld	s0,16(sp)
    80001230:	64a2                	ld	s1,8(sp)
    80001232:	6902                	ld	s2,0(sp)
    80001234:	6105                	addi	sp,sp,32
    80001236:	8082                	ret

0000000080001238 <kvminit>:
{
    80001238:	1141                	addi	sp,sp,-16
    8000123a:	e406                	sd	ra,8(sp)
    8000123c:	e022                	sd	s0,0(sp)
    8000123e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f22080e7          	jalr	-222(ra) # 80001162 <kvmmake>
    80001248:	00008797          	auipc	a5,0x8
    8000124c:	dca7bc23          	sd	a0,-552(a5) # 80009020 <kernel_pagetable>
}
    80001250:	60a2                	ld	ra,8(sp)
    80001252:	6402                	ld	s0,0(sp)
    80001254:	0141                	addi	sp,sp,16
    80001256:	8082                	ret

0000000080001258 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001258:	715d                	addi	sp,sp,-80
    8000125a:	e486                	sd	ra,72(sp)
    8000125c:	e0a2                	sd	s0,64(sp)
    8000125e:	fc26                	sd	s1,56(sp)
    80001260:	f84a                	sd	s2,48(sp)
    80001262:	f44e                	sd	s3,40(sp)
    80001264:	f052                	sd	s4,32(sp)
    80001266:	ec56                	sd	s5,24(sp)
    80001268:	e85a                	sd	s6,16(sp)
    8000126a:	e45e                	sd	s7,8(sp)
    8000126c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000126e:	03459793          	slli	a5,a1,0x34
    80001272:	e795                	bnez	a5,8000129e <uvmunmap+0x46>
    80001274:	8a2a                	mv	s4,a0
    80001276:	892e                	mv	s2,a1
    80001278:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127a:	0632                	slli	a2,a2,0xc
    8000127c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001280:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001282:	6b05                	lui	s6,0x1
    80001284:	0735e263          	bltu	a1,s3,800012e8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001288:	60a6                	ld	ra,72(sp)
    8000128a:	6406                	ld	s0,64(sp)
    8000128c:	74e2                	ld	s1,56(sp)
    8000128e:	7942                	ld	s2,48(sp)
    80001290:	79a2                	ld	s3,40(sp)
    80001292:	7a02                	ld	s4,32(sp)
    80001294:	6ae2                	ld	s5,24(sp)
    80001296:	6b42                	ld	s6,16(sp)
    80001298:	6ba2                	ld	s7,8(sp)
    8000129a:	6161                	addi	sp,sp,80
    8000129c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000129e:	00007517          	auipc	a0,0x7
    800012a2:	e4a50513          	addi	a0,a0,-438 # 800080e8 <digits+0xa8>
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	284080e7          	jalr	644(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    800012ae:	00007517          	auipc	a0,0x7
    800012b2:	e5250513          	addi	a0,a0,-430 # 80008100 <digits+0xc0>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	274080e7          	jalr	628(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012be:	00007517          	auipc	a0,0x7
    800012c2:	e5250513          	addi	a0,a0,-430 # 80008110 <digits+0xd0>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	264080e7          	jalr	612(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012ce:	00007517          	auipc	a0,0x7
    800012d2:	e5a50513          	addi	a0,a0,-422 # 80008128 <digits+0xe8>
    800012d6:	fffff097          	auipc	ra,0xfffff
    800012da:	254080e7          	jalr	596(ra) # 8000052a <panic>
    *pte = 0;
    800012de:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e2:	995a                	add	s2,s2,s6
    800012e4:	fb3972e3          	bgeu	s2,s3,80001288 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012e8:	4601                	li	a2,0
    800012ea:	85ca                	mv	a1,s2
    800012ec:	8552                	mv	a0,s4
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	cb8080e7          	jalr	-840(ra) # 80000fa6 <walk>
    800012f6:	84aa                	mv	s1,a0
    800012f8:	d95d                	beqz	a0,800012ae <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fa:	6108                	ld	a0,0(a0)
    800012fc:	00157793          	andi	a5,a0,1
    80001300:	dfdd                	beqz	a5,800012be <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001302:	3ff57793          	andi	a5,a0,1023
    80001306:	fd7784e3          	beq	a5,s7,800012ce <uvmunmap+0x76>
    if(do_free){
    8000130a:	fc0a8ae3          	beqz	s5,800012de <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000130e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001310:	0532                	slli	a0,a0,0xc
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	6c4080e7          	jalr	1732(ra) # 800009d6 <kfree>
    8000131a:	b7d1                	j	800012de <uvmunmap+0x86>

000000008000131c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131c:	1101                	addi	sp,sp,-32
    8000131e:	ec06                	sd	ra,24(sp)
    80001320:	e822                	sd	s0,16(sp)
    80001322:	e426                	sd	s1,8(sp)
    80001324:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	7ac080e7          	jalr	1964(ra) # 80000ad2 <kalloc>
    8000132e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001330:	c519                	beqz	a0,8000133e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001332:	6605                	lui	a2,0x1
    80001334:	4581                	li	a1,0
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	988080e7          	jalr	-1656(ra) # 80000cbe <memset>
  return pagetable;
}
    8000133e:	8526                	mv	a0,s1
    80001340:	60e2                	ld	ra,24(sp)
    80001342:	6442                	ld	s0,16(sp)
    80001344:	64a2                	ld	s1,8(sp)
    80001346:	6105                	addi	sp,sp,32
    80001348:	8082                	ret

000000008000134a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134a:	7179                	addi	sp,sp,-48
    8000134c:	f406                	sd	ra,40(sp)
    8000134e:	f022                	sd	s0,32(sp)
    80001350:	ec26                	sd	s1,24(sp)
    80001352:	e84a                	sd	s2,16(sp)
    80001354:	e44e                	sd	s3,8(sp)
    80001356:	e052                	sd	s4,0(sp)
    80001358:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135a:	6785                	lui	a5,0x1
    8000135c:	04f67863          	bgeu	a2,a5,800013ac <uvminit+0x62>
    80001360:	8a2a                	mv	s4,a0
    80001362:	89ae                	mv	s3,a1
    80001364:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001366:	fffff097          	auipc	ra,0xfffff
    8000136a:	76c080e7          	jalr	1900(ra) # 80000ad2 <kalloc>
    8000136e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001370:	6605                	lui	a2,0x1
    80001372:	4581                	li	a1,0
    80001374:	00000097          	auipc	ra,0x0
    80001378:	94a080e7          	jalr	-1718(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137c:	4779                	li	a4,30
    8000137e:	86ca                	mv	a3,s2
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	8552                	mv	a0,s4
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	d1e080e7          	jalr	-738(ra) # 800010a4 <mappages>
  memmove(mem, src, sz);
    8000138e:	8626                	mv	a2,s1
    80001390:	85ce                	mv	a1,s3
    80001392:	854a                	mv	a0,s2
    80001394:	00000097          	auipc	ra,0x0
    80001398:	986080e7          	jalr	-1658(ra) # 80000d1a <memmove>
}
    8000139c:	70a2                	ld	ra,40(sp)
    8000139e:	7402                	ld	s0,32(sp)
    800013a0:	64e2                	ld	s1,24(sp)
    800013a2:	6942                	ld	s2,16(sp)
    800013a4:	69a2                	ld	s3,8(sp)
    800013a6:	6a02                	ld	s4,0(sp)
    800013a8:	6145                	addi	sp,sp,48
    800013aa:	8082                	ret
    panic("inituvm: more than a page");
    800013ac:	00007517          	auipc	a0,0x7
    800013b0:	d9450513          	addi	a0,a0,-620 # 80008140 <digits+0x100>
    800013b4:	fffff097          	auipc	ra,0xfffff
    800013b8:	176080e7          	jalr	374(ra) # 8000052a <panic>

00000000800013bc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013bc:	1101                	addi	sp,sp,-32
    800013be:	ec06                	sd	ra,24(sp)
    800013c0:	e822                	sd	s0,16(sp)
    800013c2:	e426                	sd	s1,8(sp)
    800013c4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013c8:	00b67d63          	bgeu	a2,a1,800013e2 <uvmdealloc+0x26>
    800013cc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ce:	6785                	lui	a5,0x1
    800013d0:	17fd                	addi	a5,a5,-1
    800013d2:	00f60733          	add	a4,a2,a5
    800013d6:	767d                	lui	a2,0xfffff
    800013d8:	8f71                	and	a4,a4,a2
    800013da:	97ae                	add	a5,a5,a1
    800013dc:	8ff1                	and	a5,a5,a2
    800013de:	00f76863          	bltu	a4,a5,800013ee <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e2:	8526                	mv	a0,s1
    800013e4:	60e2                	ld	ra,24(sp)
    800013e6:	6442                	ld	s0,16(sp)
    800013e8:	64a2                	ld	s1,8(sp)
    800013ea:	6105                	addi	sp,sp,32
    800013ec:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013ee:	8f99                	sub	a5,a5,a4
    800013f0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f2:	4685                	li	a3,1
    800013f4:	0007861b          	sext.w	a2,a5
    800013f8:	85ba                	mv	a1,a4
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	e5e080e7          	jalr	-418(ra) # 80001258 <uvmunmap>
    80001402:	b7c5                	j	800013e2 <uvmdealloc+0x26>

0000000080001404 <uvmalloc>:
  if(newsz < oldsz)
    80001404:	0ab66163          	bltu	a2,a1,800014a6 <uvmalloc+0xa2>
{
    80001408:	7139                	addi	sp,sp,-64
    8000140a:	fc06                	sd	ra,56(sp)
    8000140c:	f822                	sd	s0,48(sp)
    8000140e:	f426                	sd	s1,40(sp)
    80001410:	f04a                	sd	s2,32(sp)
    80001412:	ec4e                	sd	s3,24(sp)
    80001414:	e852                	sd	s4,16(sp)
    80001416:	e456                	sd	s5,8(sp)
    80001418:	0080                	addi	s0,sp,64
    8000141a:	8aaa                	mv	s5,a0
    8000141c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000141e:	6985                	lui	s3,0x1
    80001420:	19fd                	addi	s3,s3,-1
    80001422:	95ce                	add	a1,a1,s3
    80001424:	79fd                	lui	s3,0xfffff
    80001426:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142a:	08c9f063          	bgeu	s3,a2,800014aa <uvmalloc+0xa6>
    8000142e:	894e                	mv	s2,s3
    mem = kalloc();
    80001430:	fffff097          	auipc	ra,0xfffff
    80001434:	6a2080e7          	jalr	1698(ra) # 80000ad2 <kalloc>
    80001438:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143a:	c51d                	beqz	a0,80001468 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143c:	6605                	lui	a2,0x1
    8000143e:	4581                	li	a1,0
    80001440:	00000097          	auipc	ra,0x0
    80001444:	87e080e7          	jalr	-1922(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001448:	4779                	li	a4,30
    8000144a:	86a6                	mv	a3,s1
    8000144c:	6605                	lui	a2,0x1
    8000144e:	85ca                	mv	a1,s2
    80001450:	8556                	mv	a0,s5
    80001452:	00000097          	auipc	ra,0x0
    80001456:	c52080e7          	jalr	-942(ra) # 800010a4 <mappages>
    8000145a:	e905                	bnez	a0,8000148a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145c:	6785                	lui	a5,0x1
    8000145e:	993e                	add	s2,s2,a5
    80001460:	fd4968e3          	bltu	s2,s4,80001430 <uvmalloc+0x2c>
  return newsz;
    80001464:	8552                	mv	a0,s4
    80001466:	a809                	j	80001478 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001468:	864e                	mv	a2,s3
    8000146a:	85ca                	mv	a1,s2
    8000146c:	8556                	mv	a0,s5
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	f4e080e7          	jalr	-178(ra) # 800013bc <uvmdealloc>
      return 0;
    80001476:	4501                	li	a0,0
}
    80001478:	70e2                	ld	ra,56(sp)
    8000147a:	7442                	ld	s0,48(sp)
    8000147c:	74a2                	ld	s1,40(sp)
    8000147e:	7902                	ld	s2,32(sp)
    80001480:	69e2                	ld	s3,24(sp)
    80001482:	6a42                	ld	s4,16(sp)
    80001484:	6aa2                	ld	s5,8(sp)
    80001486:	6121                	addi	sp,sp,64
    80001488:	8082                	ret
      kfree(mem);
    8000148a:	8526                	mv	a0,s1
    8000148c:	fffff097          	auipc	ra,0xfffff
    80001490:	54a080e7          	jalr	1354(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001494:	864e                	mv	a2,s3
    80001496:	85ca                	mv	a1,s2
    80001498:	8556                	mv	a0,s5
    8000149a:	00000097          	auipc	ra,0x0
    8000149e:	f22080e7          	jalr	-222(ra) # 800013bc <uvmdealloc>
      return 0;
    800014a2:	4501                	li	a0,0
    800014a4:	bfd1                	j	80001478 <uvmalloc+0x74>
    return oldsz;
    800014a6:	852e                	mv	a0,a1
}
    800014a8:	8082                	ret
  return newsz;
    800014aa:	8532                	mv	a0,a2
    800014ac:	b7f1                	j	80001478 <uvmalloc+0x74>

00000000800014ae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ae:	7179                	addi	sp,sp,-48
    800014b0:	f406                	sd	ra,40(sp)
    800014b2:	f022                	sd	s0,32(sp)
    800014b4:	ec26                	sd	s1,24(sp)
    800014b6:	e84a                	sd	s2,16(sp)
    800014b8:	e44e                	sd	s3,8(sp)
    800014ba:	e052                	sd	s4,0(sp)
    800014bc:	1800                	addi	s0,sp,48
    800014be:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c0:	84aa                	mv	s1,a0
    800014c2:	6905                	lui	s2,0x1
    800014c4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c6:	4985                	li	s3,1
    800014c8:	a821                	j	800014e0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ca:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014cc:	0532                	slli	a0,a0,0xc
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	fe0080e7          	jalr	-32(ra) # 800014ae <freewalk>
      pagetable[i] = 0;
    800014d6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014da:	04a1                	addi	s1,s1,8
    800014dc:	03248163          	beq	s1,s2,800014fe <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e2:	00f57793          	andi	a5,a0,15
    800014e6:	ff3782e3          	beq	a5,s3,800014ca <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ea:	8905                	andi	a0,a0,1
    800014ec:	d57d                	beqz	a0,800014da <freewalk+0x2c>
      panic("freewalk: leaf");
    800014ee:	00007517          	auipc	a0,0x7
    800014f2:	c7250513          	addi	a0,a0,-910 # 80008160 <digits+0x120>
    800014f6:	fffff097          	auipc	ra,0xfffff
    800014fa:	034080e7          	jalr	52(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014fe:	8552                	mv	a0,s4
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	4d6080e7          	jalr	1238(ra) # 800009d6 <kfree>
}
    80001508:	70a2                	ld	ra,40(sp)
    8000150a:	7402                	ld	s0,32(sp)
    8000150c:	64e2                	ld	s1,24(sp)
    8000150e:	6942                	ld	s2,16(sp)
    80001510:	69a2                	ld	s3,8(sp)
    80001512:	6a02                	ld	s4,0(sp)
    80001514:	6145                	addi	sp,sp,48
    80001516:	8082                	ret

0000000080001518 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001518:	1101                	addi	sp,sp,-32
    8000151a:	ec06                	sd	ra,24(sp)
    8000151c:	e822                	sd	s0,16(sp)
    8000151e:	e426                	sd	s1,8(sp)
    80001520:	1000                	addi	s0,sp,32
    80001522:	84aa                	mv	s1,a0
  if(sz > 0)
    80001524:	e999                	bnez	a1,8000153a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001526:	8526                	mv	a0,s1
    80001528:	00000097          	auipc	ra,0x0
    8000152c:	f86080e7          	jalr	-122(ra) # 800014ae <freewalk>
}
    80001530:	60e2                	ld	ra,24(sp)
    80001532:	6442                	ld	s0,16(sp)
    80001534:	64a2                	ld	s1,8(sp)
    80001536:	6105                	addi	sp,sp,32
    80001538:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153a:	6605                	lui	a2,0x1
    8000153c:	167d                	addi	a2,a2,-1
    8000153e:	962e                	add	a2,a2,a1
    80001540:	4685                	li	a3,1
    80001542:	8231                	srli	a2,a2,0xc
    80001544:	4581                	li	a1,0
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	d12080e7          	jalr	-750(ra) # 80001258 <uvmunmap>
    8000154e:	bfe1                	j	80001526 <uvmfree+0xe>

0000000080001550 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001550:	c679                	beqz	a2,8000161e <uvmcopy+0xce>
{
    80001552:	715d                	addi	sp,sp,-80
    80001554:	e486                	sd	ra,72(sp)
    80001556:	e0a2                	sd	s0,64(sp)
    80001558:	fc26                	sd	s1,56(sp)
    8000155a:	f84a                	sd	s2,48(sp)
    8000155c:	f44e                	sd	s3,40(sp)
    8000155e:	f052                	sd	s4,32(sp)
    80001560:	ec56                	sd	s5,24(sp)
    80001562:	e85a                	sd	s6,16(sp)
    80001564:	e45e                	sd	s7,8(sp)
    80001566:	0880                	addi	s0,sp,80
    80001568:	8b2a                	mv	s6,a0
    8000156a:	8aae                	mv	s5,a1
    8000156c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001570:	4601                	li	a2,0
    80001572:	85ce                	mv	a1,s3
    80001574:	855a                	mv	a0,s6
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	a30080e7          	jalr	-1488(ra) # 80000fa6 <walk>
    8000157e:	c531                	beqz	a0,800015ca <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001580:	6118                	ld	a4,0(a0)
    80001582:	00177793          	andi	a5,a4,1
    80001586:	cbb1                	beqz	a5,800015da <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001588:	00a75593          	srli	a1,a4,0xa
    8000158c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001590:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	53e080e7          	jalr	1342(ra) # 80000ad2 <kalloc>
    8000159c:	892a                	mv	s2,a0
    8000159e:	c939                	beqz	a0,800015f4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a0:	6605                	lui	a2,0x1
    800015a2:	85de                	mv	a1,s7
    800015a4:	fffff097          	auipc	ra,0xfffff
    800015a8:	776080e7          	jalr	1910(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ac:	8726                	mv	a4,s1
    800015ae:	86ca                	mv	a3,s2
    800015b0:	6605                	lui	a2,0x1
    800015b2:	85ce                	mv	a1,s3
    800015b4:	8556                	mv	a0,s5
    800015b6:	00000097          	auipc	ra,0x0
    800015ba:	aee080e7          	jalr	-1298(ra) # 800010a4 <mappages>
    800015be:	e515                	bnez	a0,800015ea <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c0:	6785                	lui	a5,0x1
    800015c2:	99be                	add	s3,s3,a5
    800015c4:	fb49e6e3          	bltu	s3,s4,80001570 <uvmcopy+0x20>
    800015c8:	a081                	j	80001608 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ca:	00007517          	auipc	a0,0x7
    800015ce:	ba650513          	addi	a0,a0,-1114 # 80008170 <digits+0x130>
    800015d2:	fffff097          	auipc	ra,0xfffff
    800015d6:	f58080e7          	jalr	-168(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015da:	00007517          	auipc	a0,0x7
    800015de:	bb650513          	addi	a0,a0,-1098 # 80008190 <digits+0x150>
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	f48080e7          	jalr	-184(ra) # 8000052a <panic>
      kfree(mem);
    800015ea:	854a                	mv	a0,s2
    800015ec:	fffff097          	auipc	ra,0xfffff
    800015f0:	3ea080e7          	jalr	1002(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f4:	4685                	li	a3,1
    800015f6:	00c9d613          	srli	a2,s3,0xc
    800015fa:	4581                	li	a1,0
    800015fc:	8556                	mv	a0,s5
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	c5a080e7          	jalr	-934(ra) # 80001258 <uvmunmap>
  return -1;
    80001606:	557d                	li	a0,-1
}
    80001608:	60a6                	ld	ra,72(sp)
    8000160a:	6406                	ld	s0,64(sp)
    8000160c:	74e2                	ld	s1,56(sp)
    8000160e:	7942                	ld	s2,48(sp)
    80001610:	79a2                	ld	s3,40(sp)
    80001612:	7a02                	ld	s4,32(sp)
    80001614:	6ae2                	ld	s5,24(sp)
    80001616:	6b42                	ld	s6,16(sp)
    80001618:	6ba2                	ld	s7,8(sp)
    8000161a:	6161                	addi	sp,sp,80
    8000161c:	8082                	ret
  return 0;
    8000161e:	4501                	li	a0,0
}
    80001620:	8082                	ret

0000000080001622 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001622:	1141                	addi	sp,sp,-16
    80001624:	e406                	sd	ra,8(sp)
    80001626:	e022                	sd	s0,0(sp)
    80001628:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162a:	4601                	li	a2,0
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	97a080e7          	jalr	-1670(ra) # 80000fa6 <walk>
  if(pte == 0)
    80001634:	c901                	beqz	a0,80001644 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001636:	611c                	ld	a5,0(a0)
    80001638:	9bbd                	andi	a5,a5,-17
    8000163a:	e11c                	sd	a5,0(a0)
}
    8000163c:	60a2                	ld	ra,8(sp)
    8000163e:	6402                	ld	s0,0(sp)
    80001640:	0141                	addi	sp,sp,16
    80001642:	8082                	ret
    panic("uvmclear");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	b6c50513          	addi	a0,a0,-1172 # 800081b0 <digits+0x170>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	ede080e7          	jalr	-290(ra) # 8000052a <panic>

0000000080001654 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001654:	caa5                	beqz	a3,800016c4 <copyout+0x70>
{
    80001656:	715d                	addi	sp,sp,-80
    80001658:	e486                	sd	ra,72(sp)
    8000165a:	e0a2                	sd	s0,64(sp)
    8000165c:	fc26                	sd	s1,56(sp)
    8000165e:	f84a                	sd	s2,48(sp)
    80001660:	f44e                	sd	s3,40(sp)
    80001662:	f052                	sd	s4,32(sp)
    80001664:	ec56                	sd	s5,24(sp)
    80001666:	e85a                	sd	s6,16(sp)
    80001668:	e45e                	sd	s7,8(sp)
    8000166a:	e062                	sd	s8,0(sp)
    8000166c:	0880                	addi	s0,sp,80
    8000166e:	8b2a                	mv	s6,a0
    80001670:	8c2e                	mv	s8,a1
    80001672:	8a32                	mv	s4,a2
    80001674:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001676:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001678:	6a85                	lui	s5,0x1
    8000167a:	a015                	j	8000169e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000167c:	9562                	add	a0,a0,s8
    8000167e:	0004861b          	sext.w	a2,s1
    80001682:	85d2                	mv	a1,s4
    80001684:	41250533          	sub	a0,a0,s2
    80001688:	fffff097          	auipc	ra,0xfffff
    8000168c:	692080e7          	jalr	1682(ra) # 80000d1a <memmove>

    len -= n;
    80001690:	409989b3          	sub	s3,s3,s1
    src += n;
    80001694:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001696:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169a:	02098363          	beqz	s3,800016c0 <copyout+0x6c>
    va0 = PGROUNDDOWN(dstva);
    8000169e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    800016a2:	4601                	li	a2,0
    800016a4:	85ca                	mv	a1,s2
    800016a6:	855a                	mv	a0,s6
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	9a4080e7          	jalr	-1628(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800016b0:	cd01                	beqz	a0,800016c8 <copyout+0x74>
    n = PGSIZE - (dstva - va0);
    800016b2:	418904b3          	sub	s1,s2,s8
    800016b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b8:	fc99f2e3          	bgeu	s3,s1,8000167c <copyout+0x28>
    800016bc:	84ce                	mv	s1,s3
    800016be:	bf7d                	j	8000167c <copyout+0x28>
  }
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	a021                	j	800016ca <copyout+0x76>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret
      return -1;
    800016c8:	557d                	li	a0,-1
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6c02                	ld	s8,0(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret

00000000800016e2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	caad                	beqz	a3,80001754 <copyin+0x72>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8a2e                	mv	s4,a1
    80001700:	8c32                	mv	s8,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0, 0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a01d                	j	8000172e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170a:	018505b3          	add	a1,a0,s8
    8000170e:	0004861b          	sext.w	a2,s1
    80001712:	412585b3          	sub	a1,a1,s2
    80001716:	8552                	mv	a0,s4
    80001718:	fffff097          	auipc	ra,0xfffff
    8000171c:	602080e7          	jalr	1538(ra) # 80000d1a <memmove>

    len -= n;
    80001720:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001724:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001726:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172a:	02098363          	beqz	s3,80001750 <copyin+0x6e>
    va0 = PGROUNDDOWN(srcva);
    8000172e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0, 0);
    80001732:	4601                	li	a2,0
    80001734:	85ca                	mv	a1,s2
    80001736:	855a                	mv	a0,s6
    80001738:	00000097          	auipc	ra,0x0
    8000173c:	914080e7          	jalr	-1772(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001740:	cd01                	beqz	a0,80001758 <copyin+0x76>
    n = PGSIZE - (srcva - va0);
    80001742:	418904b3          	sub	s1,s2,s8
    80001746:	94d6                	add	s1,s1,s5
    if(n > len)
    80001748:	fc99f1e3          	bgeu	s3,s1,8000170a <copyin+0x28>
    8000174c:	84ce                	mv	s1,s3
    8000174e:	bf75                	j	8000170a <copyin+0x28>
  }
  return 0;
    80001750:	4501                	li	a0,0
    80001752:	a021                	j	8000175a <copyin+0x78>
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
    80001772:	c6cd                	beqz	a3,8000181c <copyinstr+0xaa>
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
    pa0 = walkaddr(pagetable, va0, 0);
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
    800017c0:	c8b1                	beqz	s1,80001814 <copyinstr+0xa2>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0, 0);
    800017c6:	4601                	li	a2,0
    800017c8:	85ca                	mv	a1,s2
    800017ca:	8552                	mv	a0,s4
    800017cc:	00000097          	auipc	ra,0x0
    800017d0:	880080e7          	jalr	-1920(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017d4:	c131                	beqz	a0,80001818 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    800017d6:	41790833          	sub	a6,s2,s7
    800017da:	984e                	add	a6,a6,s3
    if(n > max)
    800017dc:	0104f363          	bgeu	s1,a6,800017e2 <copyinstr+0x70>
    800017e0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e2:	955e                	add	a0,a0,s7
    800017e4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e8:	fc080ae3          	beqz	a6,800017bc <copyinstr+0x4a>
    800017ec:	985a                	add	a6,a6,s6
    800017ee:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017f0:	41650633          	sub	a2,a0,s6
    800017f4:	14fd                	addi	s1,s1,-1
    800017f6:	9b26                	add	s6,s6,s1
    800017f8:	00f60733          	add	a4,a2,a5
    800017fc:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd1000>
    80001800:	df41                	beqz	a4,80001798 <copyinstr+0x26>
        *dst = *p;
    80001802:	00e78023          	sb	a4,0(a5)
      --max;
    80001806:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000180a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000180c:	ff0796e3          	bne	a5,a6,800017f8 <copyinstr+0x86>
      dst++;
    80001810:	8b42                	mv	s6,a6
    80001812:	b76d                	j	800017bc <copyinstr+0x4a>
    80001814:	4781                	li	a5,0
    80001816:	b761                	j	8000179e <copyinstr+0x2c>
      return -1;
    80001818:	557d                	li	a0,-1
    8000181a:	b771                	j	800017a6 <copyinstr+0x34>
  int got_null = 0;
    8000181c:	4781                	li	a5,0
  if(got_null){
    8000181e:	0017b793          	seqz	a5,a5
    80001822:	40f00533          	neg	a0,a5
}
    80001826:	8082                	ret

0000000080001828 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001828:	7139                	addi	sp,sp,-64
    8000182a:	fc06                	sd	ra,56(sp)
    8000182c:	f822                	sd	s0,48(sp)
    8000182e:	f426                	sd	s1,40(sp)
    80001830:	f04a                	sd	s2,32(sp)
    80001832:	ec4e                	sd	s3,24(sp)
    80001834:	e852                	sd	s4,16(sp)
    80001836:	e456                	sd	s5,8(sp)
    80001838:	e05a                	sd	s6,0(sp)
    8000183a:	0080                	addi	s0,sp,64
    8000183c:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000183e:	00010497          	auipc	s1,0x10
    80001842:	e9248493          	addi	s1,s1,-366 # 800116d0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001846:	8b26                	mv	s6,s1
    80001848:	00006a97          	auipc	s5,0x6
    8000184c:	7b8a8a93          	addi	s5,s5,1976 # 80008000 <etext>
    80001850:	04000937          	lui	s2,0x4000
    80001854:	197d                	addi	s2,s2,-1
    80001856:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001858:	0001ea17          	auipc	s4,0x1e
    8000185c:	e78a0a13          	addi	s4,s4,-392 # 8001f6d0 <tickslock>
    char *pa = kalloc();
    80001860:	fffff097          	auipc	ra,0xfffff
    80001864:	272080e7          	jalr	626(ra) # 80000ad2 <kalloc>
    80001868:	862a                	mv	a2,a0
    if (pa == 0)
    8000186a:	c131                	beqz	a0,800018ae <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    8000186c:	416485b3          	sub	a1,s1,s6
    80001870:	859d                	srai	a1,a1,0x7
    80001872:	000ab783          	ld	a5,0(s5)
    80001876:	02f585b3          	mul	a1,a1,a5
    8000187a:	2585                	addiw	a1,a1,1
    8000187c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001880:	4719                	li	a4,6
    80001882:	6685                	lui	a3,0x1
    80001884:	40b905b3          	sub	a1,s2,a1
    80001888:	854e                	mv	a0,s3
    8000188a:	00000097          	auipc	ra,0x0
    8000188e:	8a8080e7          	jalr	-1880(ra) # 80001132 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001892:	38048493          	addi	s1,s1,896
    80001896:	fd4495e3          	bne	s1,s4,80001860 <proc_mapstacks+0x38>
  }
}
    8000189a:	70e2                	ld	ra,56(sp)
    8000189c:	7442                	ld	s0,48(sp)
    8000189e:	74a2                	ld	s1,40(sp)
    800018a0:	7902                	ld	s2,32(sp)
    800018a2:	69e2                	ld	s3,24(sp)
    800018a4:	6a42                	ld	s4,16(sp)
    800018a6:	6aa2                	ld	s5,8(sp)
    800018a8:	6b02                	ld	s6,0(sp)
    800018aa:	6121                	addi	sp,sp,64
    800018ac:	8082                	ret
      panic("kalloc");
    800018ae:	00007517          	auipc	a0,0x7
    800018b2:	91250513          	addi	a0,a0,-1774 # 800081c0 <digits+0x180>
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	c74080e7          	jalr	-908(ra) # 8000052a <panic>

00000000800018be <procinit>:

// initialize the proc table at boot time.
void procinit(void)
{
    800018be:	7139                	addi	sp,sp,-64
    800018c0:	fc06                	sd	ra,56(sp)
    800018c2:	f822                	sd	s0,48(sp)
    800018c4:	f426                	sd	s1,40(sp)
    800018c6:	f04a                	sd	s2,32(sp)
    800018c8:	ec4e                	sd	s3,24(sp)
    800018ca:	e852                	sd	s4,16(sp)
    800018cc:	e456                	sd	s5,8(sp)
    800018ce:	e05a                	sd	s6,0(sp)
    800018d0:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018d2:	00007597          	auipc	a1,0x7
    800018d6:	8f658593          	addi	a1,a1,-1802 # 800081c8 <digits+0x188>
    800018da:	00010517          	auipc	a0,0x10
    800018de:	9c650513          	addi	a0,a0,-1594 # 800112a0 <pid_lock>
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	250080e7          	jalr	592(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018ea:	00007597          	auipc	a1,0x7
    800018ee:	8e658593          	addi	a1,a1,-1818 # 800081d0 <digits+0x190>
    800018f2:	00010517          	auipc	a0,0x10
    800018f6:	9c650513          	addi	a0,a0,-1594 # 800112b8 <wait_lock>
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	238080e7          	jalr	568(ra) # 80000b32 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001902:	00010497          	auipc	s1,0x10
    80001906:	dce48493          	addi	s1,s1,-562 # 800116d0 <proc>
  {
    initlock(&p->lock, "proc");
    8000190a:	00007b17          	auipc	s6,0x7
    8000190e:	8d6b0b13          	addi	s6,s6,-1834 # 800081e0 <digits+0x1a0>
    p->kstack = KSTACK((int)(p - proc));
    80001912:	8aa6                	mv	s5,s1
    80001914:	00006a17          	auipc	s4,0x6
    80001918:	6eca0a13          	addi	s4,s4,1772 # 80008000 <etext>
    8000191c:	04000937          	lui	s2,0x4000
    80001920:	197d                	addi	s2,s2,-1
    80001922:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001924:	0001e997          	auipc	s3,0x1e
    80001928:	dac98993          	addi	s3,s3,-596 # 8001f6d0 <tickslock>
    initlock(&p->lock, "proc");
    8000192c:	85da                	mv	a1,s6
    8000192e:	8526                	mv	a0,s1
    80001930:	fffff097          	auipc	ra,0xfffff
    80001934:	202080e7          	jalr	514(ra) # 80000b32 <initlock>
    p->kstack = KSTACK((int)(p - proc));
    80001938:	415487b3          	sub	a5,s1,s5
    8000193c:	879d                	srai	a5,a5,0x7
    8000193e:	000a3703          	ld	a4,0(s4)
    80001942:	02e787b3          	mul	a5,a5,a4
    80001946:	2785                	addiw	a5,a5,1
    80001948:	00d7979b          	slliw	a5,a5,0xd
    8000194c:	40f907b3          	sub	a5,s2,a5
    80001950:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001952:	38048493          	addi	s1,s1,896
    80001956:	fd349be3          	bne	s1,s3,8000192c <procinit+0x6e>
  }
}
    8000195a:	70e2                	ld	ra,56(sp)
    8000195c:	7442                	ld	s0,48(sp)
    8000195e:	74a2                	ld	s1,40(sp)
    80001960:	7902                	ld	s2,32(sp)
    80001962:	69e2                	ld	s3,24(sp)
    80001964:	6a42                	ld	s4,16(sp)
    80001966:	6aa2                	ld	s5,8(sp)
    80001968:	6b02                	ld	s6,0(sp)
    8000196a:	6121                	addi	sp,sp,64
    8000196c:	8082                	ret

000000008000196e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000196e:	1141                	addi	sp,sp,-16
    80001970:	e422                	sd	s0,8(sp)
    80001972:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001974:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001976:	2501                	sext.w	a0,a0
    80001978:	6422                	ld	s0,8(sp)
    8000197a:	0141                	addi	sp,sp,16
    8000197c:	8082                	ret

000000008000197e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000197e:	1141                	addi	sp,sp,-16
    80001980:	e422                	sd	s0,8(sp)
    80001982:	0800                	addi	s0,sp,16
    80001984:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001986:	2781                	sext.w	a5,a5
    80001988:	079e                	slli	a5,a5,0x7
  return c;
}
    8000198a:	00010517          	auipc	a0,0x10
    8000198e:	94650513          	addi	a0,a0,-1722 # 800112d0 <cpus>
    80001992:	953e                	add	a0,a0,a5
    80001994:	6422                	ld	s0,8(sp)
    80001996:	0141                	addi	sp,sp,16
    80001998:	8082                	ret

000000008000199a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    8000199a:	1101                	addi	sp,sp,-32
    8000199c:	ec06                	sd	ra,24(sp)
    8000199e:	e822                	sd	s0,16(sp)
    800019a0:	e426                	sd	s1,8(sp)
    800019a2:	1000                	addi	s0,sp,32
  push_off();
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	1d2080e7          	jalr	466(ra) # 80000b76 <push_off>
    800019ac:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ae:	2781                	sext.w	a5,a5
    800019b0:	079e                	slli	a5,a5,0x7
    800019b2:	00010717          	auipc	a4,0x10
    800019b6:	8ee70713          	addi	a4,a4,-1810 # 800112a0 <pid_lock>
    800019ba:	97ba                	add	a5,a5,a4
    800019bc:	7b84                	ld	s1,48(a5)
  pop_off();
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	258080e7          	jalr	600(ra) # 80000c16 <pop_off>
  return p;
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6105                	addi	sp,sp,32
    800019d0:	8082                	ret

00000000800019d2 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019d2:	1141                	addi	sp,sp,-16
    800019d4:	e406                	sd	ra,8(sp)
    800019d6:	e022                	sd	s0,0(sp)
    800019d8:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019da:	00000097          	auipc	ra,0x0
    800019de:	fc0080e7          	jalr	-64(ra) # 8000199a <myproc>
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	294080e7          	jalr	660(ra) # 80000c76 <release>

  if (first)
    800019ea:	00007797          	auipc	a5,0x7
    800019ee:	fe67a783          	lw	a5,-26(a5) # 800089d0 <first.1>
    800019f2:	eb89                	bnez	a5,80001a04 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f4:	00001097          	auipc	ra,0x1
    800019f8:	f5a080e7          	jalr	-166(ra) # 8000294e <usertrapret>
}
    800019fc:	60a2                	ld	ra,8(sp)
    800019fe:	6402                	ld	s0,0(sp)
    80001a00:	0141                	addi	sp,sp,16
    80001a02:	8082                	ret
    first = 0;
    80001a04:	00007797          	auipc	a5,0x7
    80001a08:	fc07a623          	sw	zero,-52(a5) # 800089d0 <first.1>
    fsinit(ROOTDEV);
    80001a0c:	4505                	li	a0,1
    80001a0e:	00002097          	auipc	ra,0x2
    80001a12:	d10080e7          	jalr	-752(ra) # 8000371e <fsinit>
    80001a16:	bff9                	j	800019f4 <forkret+0x22>

0000000080001a18 <allocpid>:
{
    80001a18:	1101                	addi	sp,sp,-32
    80001a1a:	ec06                	sd	ra,24(sp)
    80001a1c:	e822                	sd	s0,16(sp)
    80001a1e:	e426                	sd	s1,8(sp)
    80001a20:	e04a                	sd	s2,0(sp)
    80001a22:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a24:	00010917          	auipc	s2,0x10
    80001a28:	87c90913          	addi	s2,s2,-1924 # 800112a0 <pid_lock>
    80001a2c:	854a                	mv	a0,s2
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	194080e7          	jalr	404(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a36:	00007797          	auipc	a5,0x7
    80001a3a:	f9e78793          	addi	a5,a5,-98 # 800089d4 <nextpid>
    80001a3e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a40:	0014871b          	addiw	a4,s1,1
    80001a44:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a46:	854a                	mv	a0,s2
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	22e080e7          	jalr	558(ra) # 80000c76 <release>
}
    80001a50:	8526                	mv	a0,s1
    80001a52:	60e2                	ld	ra,24(sp)
    80001a54:	6442                	ld	s0,16(sp)
    80001a56:	64a2                	ld	s1,8(sp)
    80001a58:	6902                	ld	s2,0(sp)
    80001a5a:	6105                	addi	sp,sp,32
    80001a5c:	8082                	ret

0000000080001a5e <proc_pagetable>:
{
    80001a5e:	1101                	addi	sp,sp,-32
    80001a60:	ec06                	sd	ra,24(sp)
    80001a62:	e822                	sd	s0,16(sp)
    80001a64:	e426                	sd	s1,8(sp)
    80001a66:	e04a                	sd	s2,0(sp)
    80001a68:	1000                	addi	s0,sp,32
    80001a6a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a6c:	00000097          	auipc	ra,0x0
    80001a70:	8b0080e7          	jalr	-1872(ra) # 8000131c <uvmcreate>
    80001a74:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a76:	c121                	beqz	a0,80001ab6 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a78:	4729                	li	a4,10
    80001a7a:	00005697          	auipc	a3,0x5
    80001a7e:	58668693          	addi	a3,a3,1414 # 80007000 <_trampoline>
    80001a82:	6605                	lui	a2,0x1
    80001a84:	040005b7          	lui	a1,0x4000
    80001a88:	15fd                	addi	a1,a1,-1
    80001a8a:	05b2                	slli	a1,a1,0xc
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	618080e7          	jalr	1560(ra) # 800010a4 <mappages>
    80001a94:	02054863          	bltz	a0,80001ac4 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a98:	4719                	li	a4,6
    80001a9a:	05893683          	ld	a3,88(s2)
    80001a9e:	6605                	lui	a2,0x1
    80001aa0:	020005b7          	lui	a1,0x2000
    80001aa4:	15fd                	addi	a1,a1,-1
    80001aa6:	05b6                	slli	a1,a1,0xd
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	5fa080e7          	jalr	1530(ra) # 800010a4 <mappages>
    80001ab2:	02054163          	bltz	a0,80001ad4 <proc_pagetable+0x76>
}
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	60e2                	ld	ra,24(sp)
    80001aba:	6442                	ld	s0,16(sp)
    80001abc:	64a2                	ld	s1,8(sp)
    80001abe:	6902                	ld	s2,0(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac4:	4581                	li	a1,0
    80001ac6:	8526                	mv	a0,s1
    80001ac8:	00000097          	auipc	ra,0x0
    80001acc:	a50080e7          	jalr	-1456(ra) # 80001518 <uvmfree>
    return 0;
    80001ad0:	4481                	li	s1,0
    80001ad2:	b7d5                	j	80001ab6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad4:	4681                	li	a3,0
    80001ad6:	4605                	li	a2,1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	776080e7          	jalr	1910(ra) # 80001258 <uvmunmap>
    uvmfree(pagetable, 0);
    80001aea:	4581                	li	a1,0
    80001aec:	8526                	mv	a0,s1
    80001aee:	00000097          	auipc	ra,0x0
    80001af2:	a2a080e7          	jalr	-1494(ra) # 80001518 <uvmfree>
    return 0;
    80001af6:	4481                	li	s1,0
    80001af8:	bf7d                	j	80001ab6 <proc_pagetable+0x58>

0000000080001afa <proc_freepagetable>:
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	e04a                	sd	s2,0(sp)
    80001b04:	1000                	addi	s0,sp,32
    80001b06:	84aa                	mv	s1,a0
    80001b08:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0a:	4681                	li	a3,0
    80001b0c:	4605                	li	a2,1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	addi	a1,a1,-1
    80001b14:	05b2                	slli	a1,a1,0xc
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	742080e7          	jalr	1858(ra) # 80001258 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1e:	4681                	li	a3,0
    80001b20:	4605                	li	a2,1
    80001b22:	020005b7          	lui	a1,0x2000
    80001b26:	15fd                	addi	a1,a1,-1
    80001b28:	05b6                	slli	a1,a1,0xd
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	72c080e7          	jalr	1836(ra) # 80001258 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b34:	85ca                	mv	a1,s2
    80001b36:	8526                	mv	a0,s1
    80001b38:	00000097          	auipc	ra,0x0
    80001b3c:	9e0080e7          	jalr	-1568(ra) # 80001518 <uvmfree>
}
    80001b40:	60e2                	ld	ra,24(sp)
    80001b42:	6442                	ld	s0,16(sp)
    80001b44:	64a2                	ld	s1,8(sp)
    80001b46:	6902                	ld	s2,0(sp)
    80001b48:	6105                	addi	sp,sp,32
    80001b4a:	8082                	ret

0000000080001b4c <freeproc>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	1000                	addi	s0,sp,32
    80001b56:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b58:	6d28                	ld	a0,88(a0)
    80001b5a:	c509                	beqz	a0,80001b64 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	e7a080e7          	jalr	-390(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001b64:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b68:	68a8                	ld	a0,80(s1)
    80001b6a:	c511                	beqz	a0,80001b76 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b6c:	64ac                	ld	a1,72(s1)
    80001b6e:	00000097          	auipc	ra,0x0
    80001b72:	f8c080e7          	jalr	-116(ra) # 80001afa <proc_freepagetable>
  p->pagetable = 0;
    80001b76:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b7a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b7e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b82:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b86:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b8a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b92:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b96:	0004ac23          	sw	zero,24(s1)
}
    80001b9a:	60e2                	ld	ra,24(sp)
    80001b9c:	6442                	ld	s0,16(sp)
    80001b9e:	64a2                	ld	s1,8(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <allocproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	e04a                	sd	s2,0(sp)
    80001bae:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bb0:	00010497          	auipc	s1,0x10
    80001bb4:	b2048493          	addi	s1,s1,-1248 # 800116d0 <proc>
    80001bb8:	0001e917          	auipc	s2,0x1e
    80001bbc:	b1890913          	addi	s2,s2,-1256 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	000080e7          	jalr	ra # 80000bc2 <acquire>
    if (p->state == UNUSED)
    80001bca:	4c9c                	lw	a5,24(s1)
    80001bcc:	cf81                	beqz	a5,80001be4 <allocproc+0x40>
      release(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	0a6080e7          	jalr	166(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001bd8:	38048493          	addi	s1,s1,896
    80001bdc:	ff2492e3          	bne	s1,s2,80001bc0 <allocproc+0x1c>
  return 0;
    80001be0:	4481                	li	s1,0
    80001be2:	a8a9                	j	80001c3c <allocproc+0x98>
  p->pid = allocpid();
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	e34080e7          	jalr	-460(ra) # 80001a18 <allocpid>
    80001bec:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bee:	4785                	li	a5,1
    80001bf0:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	ee0080e7          	jalr	-288(ra) # 80000ad2 <kalloc>
    80001bfa:	892a                	mv	s2,a0
    80001bfc:	eca8                	sd	a0,88(s1)
    80001bfe:	c531                	beqz	a0,80001c4a <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001c00:	8526                	mv	a0,s1
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	e5c080e7          	jalr	-420(ra) # 80001a5e <proc_pagetable>
    80001c0a:	892a                	mv	s2,a0
    80001c0c:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c0e:	c931                	beqz	a0,80001c62 <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001c10:	07000613          	li	a2,112
    80001c14:	4581                	li	a1,0
    80001c16:	06048513          	addi	a0,s1,96
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	0a4080e7          	jalr	164(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001c22:	00000797          	auipc	a5,0x0
    80001c26:	db078793          	addi	a5,a5,-592 # 800019d2 <forkret>
    80001c2a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c2c:	60bc                	ld	a5,64(s1)
    80001c2e:	6705                	lui	a4,0x1
    80001c30:	97ba                	add	a5,a5,a4
    80001c32:	f4bc                	sd	a5,104(s1)
  p->physical_pages_num = 0;
    80001c34:	1604a823          	sw	zero,368(s1)
  p->total_pages_num = 0;
    80001c38:	1604aa23          	sw	zero,372(s1)
}
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	60e2                	ld	ra,24(sp)
    80001c40:	6442                	ld	s0,16(sp)
    80001c42:	64a2                	ld	s1,8(sp)
    80001c44:	6902                	ld	s2,0(sp)
    80001c46:	6105                	addi	sp,sp,32
    80001c48:	8082                	ret
    freeproc(p);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	00000097          	auipc	ra,0x0
    80001c50:	f00080e7          	jalr	-256(ra) # 80001b4c <freeproc>
    release(&p->lock);
    80001c54:	8526                	mv	a0,s1
    80001c56:	fffff097          	auipc	ra,0xfffff
    80001c5a:	020080e7          	jalr	32(ra) # 80000c76 <release>
    return 0;
    80001c5e:	84ca                	mv	s1,s2
    80001c60:	bff1                	j	80001c3c <allocproc+0x98>
    freeproc(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	ee8080e7          	jalr	-280(ra) # 80001b4c <freeproc>
    release(&p->lock);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	fffff097          	auipc	ra,0xfffff
    80001c72:	008080e7          	jalr	8(ra) # 80000c76 <release>
    return 0;
    80001c76:	84ca                	mv	s1,s2
    80001c78:	b7d1                	j	80001c3c <allocproc+0x98>

0000000080001c7a <userinit>:
{
    80001c7a:	1101                	addi	sp,sp,-32
    80001c7c:	ec06                	sd	ra,24(sp)
    80001c7e:	e822                	sd	s0,16(sp)
    80001c80:	e426                	sd	s1,8(sp)
    80001c82:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c84:	00000097          	auipc	ra,0x0
    80001c88:	f20080e7          	jalr	-224(ra) # 80001ba4 <allocproc>
    80001c8c:	84aa                	mv	s1,a0
  initproc = p;
    80001c8e:	00007797          	auipc	a5,0x7
    80001c92:	38a7bd23          	sd	a0,922(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001c96:	03400613          	li	a2,52
    80001c9a:	00007597          	auipc	a1,0x7
    80001c9e:	d4658593          	addi	a1,a1,-698 # 800089e0 <initcode>
    80001ca2:	6928                	ld	a0,80(a0)
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	6a6080e7          	jalr	1702(ra) # 8000134a <uvminit>
  p->sz = PGSIZE;
    80001cac:	6785                	lui	a5,0x1
    80001cae:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cb0:	6cb8                	ld	a4,88(s1)
    80001cb2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001cb6:	6cb8                	ld	a4,88(s1)
    80001cb8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cba:	4641                	li	a2,16
    80001cbc:	00006597          	auipc	a1,0x6
    80001cc0:	52c58593          	addi	a1,a1,1324 # 800081e8 <digits+0x1a8>
    80001cc4:	15848513          	addi	a0,s1,344
    80001cc8:	fffff097          	auipc	ra,0xfffff
    80001ccc:	148080e7          	jalr	328(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001cd0:	00006517          	auipc	a0,0x6
    80001cd4:	52850513          	addi	a0,a0,1320 # 800081f8 <digits+0x1b8>
    80001cd8:	00002097          	auipc	ra,0x2
    80001cdc:	474080e7          	jalr	1140(ra) # 8000414c <namei>
    80001ce0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ce4:	478d                	li	a5,3
    80001ce6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	f8c080e7          	jalr	-116(ra) # 80000c76 <release>
}
    80001cf2:	60e2                	ld	ra,24(sp)
    80001cf4:	6442                	ld	s0,16(sp)
    80001cf6:	64a2                	ld	s1,8(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret

0000000080001cfc <growproc>:
{
    80001cfc:	1101                	addi	sp,sp,-32
    80001cfe:	ec06                	sd	ra,24(sp)
    80001d00:	e822                	sd	s0,16(sp)
    80001d02:	e426                	sd	s1,8(sp)
    80001d04:	e04a                	sd	s2,0(sp)
    80001d06:	1000                	addi	s0,sp,32
    80001d08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d0a:	00000097          	auipc	ra,0x0
    80001d0e:	c90080e7          	jalr	-880(ra) # 8000199a <myproc>
    80001d12:	892a                	mv	s2,a0
  sz = p->sz;
    80001d14:	652c                	ld	a1,72(a0)
    80001d16:	0005861b          	sext.w	a2,a1
  if (n > 0)
    80001d1a:	00904f63          	bgtz	s1,80001d38 <growproc+0x3c>
  else if (n < 0)
    80001d1e:	0204cc63          	bltz	s1,80001d56 <growproc+0x5a>
  p->sz = sz;
    80001d22:	1602                	slli	a2,a2,0x20
    80001d24:	9201                	srli	a2,a2,0x20
    80001d26:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d2a:	4501                	li	a0,0
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    80001d38:	9e25                	addw	a2,a2,s1
    80001d3a:	1602                	slli	a2,a2,0x20
    80001d3c:	9201                	srli	a2,a2,0x20
    80001d3e:	1582                	slli	a1,a1,0x20
    80001d40:	9181                	srli	a1,a1,0x20
    80001d42:	6928                	ld	a0,80(a0)
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	6c0080e7          	jalr	1728(ra) # 80001404 <uvmalloc>
    80001d4c:	0005061b          	sext.w	a2,a0
    80001d50:	fa69                	bnez	a2,80001d22 <growproc+0x26>
      return -1;
    80001d52:	557d                	li	a0,-1
    80001d54:	bfe1                	j	80001d2c <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d56:	9e25                	addw	a2,a2,s1
    80001d58:	1602                	slli	a2,a2,0x20
    80001d5a:	9201                	srli	a2,a2,0x20
    80001d5c:	1582                	slli	a1,a1,0x20
    80001d5e:	9181                	srli	a1,a1,0x20
    80001d60:	6928                	ld	a0,80(a0)
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	65a080e7          	jalr	1626(ra) # 800013bc <uvmdealloc>
    80001d6a:	0005061b          	sext.w	a2,a0
    80001d6e:	bf55                	j	80001d22 <growproc+0x26>

0000000080001d70 <scheduler>:
{
    80001d70:	7139                	addi	sp,sp,-64
    80001d72:	fc06                	sd	ra,56(sp)
    80001d74:	f822                	sd	s0,48(sp)
    80001d76:	f426                	sd	s1,40(sp)
    80001d78:	f04a                	sd	s2,32(sp)
    80001d7a:	ec4e                	sd	s3,24(sp)
    80001d7c:	e852                	sd	s4,16(sp)
    80001d7e:	e456                	sd	s5,8(sp)
    80001d80:	e05a                	sd	s6,0(sp)
    80001d82:	0080                	addi	s0,sp,64
    80001d84:	8792                	mv	a5,tp
  int id = r_tp();
    80001d86:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d88:	00779a93          	slli	s5,a5,0x7
    80001d8c:	0000f717          	auipc	a4,0xf
    80001d90:	51470713          	addi	a4,a4,1300 # 800112a0 <pid_lock>
    80001d94:	9756                	add	a4,a4,s5
    80001d96:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d9a:	0000f717          	auipc	a4,0xf
    80001d9e:	53e70713          	addi	a4,a4,1342 # 800112d8 <cpus+0x8>
    80001da2:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001da4:	498d                	li	s3,3
        p->state = RUNNING;
    80001da6:	4b11                	li	s6,4
        c->proc = p;
    80001da8:	079e                	slli	a5,a5,0x7
    80001daa:	0000fa17          	auipc	s4,0xf
    80001dae:	4f6a0a13          	addi	s4,s4,1270 # 800112a0 <pid_lock>
    80001db2:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001db4:	0001e917          	auipc	s2,0x1e
    80001db8:	91c90913          	addi	s2,s2,-1764 # 8001f6d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc4:	10079073          	csrw	sstatus,a5
    80001dc8:	00010497          	auipc	s1,0x10
    80001dcc:	90848493          	addi	s1,s1,-1784 # 800116d0 <proc>
    80001dd0:	a811                	j	80001de4 <scheduler+0x74>
      release(&p->lock);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	ea2080e7          	jalr	-350(ra) # 80000c76 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ddc:	38048493          	addi	s1,s1,896
    80001de0:	fd248ee3          	beq	s1,s2,80001dbc <scheduler+0x4c>
      acquire(&p->lock);
    80001de4:	8526                	mv	a0,s1
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	ddc080e7          	jalr	-548(ra) # 80000bc2 <acquire>
      if (p->state == RUNNABLE)
    80001dee:	4c9c                	lw	a5,24(s1)
    80001df0:	ff3791e3          	bne	a5,s3,80001dd2 <scheduler+0x62>
        p->state = RUNNING;
    80001df4:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001df8:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dfc:	06048593          	addi	a1,s1,96
    80001e00:	8556                	mv	a0,s5
    80001e02:	00001097          	auipc	ra,0x1
    80001e06:	aa2080e7          	jalr	-1374(ra) # 800028a4 <swtch>
        c->proc = 0;
    80001e0a:	020a3823          	sd	zero,48(s4)
    80001e0e:	b7d1                	j	80001dd2 <scheduler+0x62>

0000000080001e10 <sched>:
{
    80001e10:	7179                	addi	sp,sp,-48
    80001e12:	f406                	sd	ra,40(sp)
    80001e14:	f022                	sd	s0,32(sp)
    80001e16:	ec26                	sd	s1,24(sp)
    80001e18:	e84a                	sd	s2,16(sp)
    80001e1a:	e44e                	sd	s3,8(sp)
    80001e1c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	b7c080e7          	jalr	-1156(ra) # 8000199a <myproc>
    80001e26:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	d20080e7          	jalr	-736(ra) # 80000b48 <holding>
    80001e30:	c93d                	beqz	a0,80001ea6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e32:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001e34:	2781                	sext.w	a5,a5
    80001e36:	079e                	slli	a5,a5,0x7
    80001e38:	0000f717          	auipc	a4,0xf
    80001e3c:	46870713          	addi	a4,a4,1128 # 800112a0 <pid_lock>
    80001e40:	97ba                	add	a5,a5,a4
    80001e42:	0a87a703          	lw	a4,168(a5) # 10a8 <_entry-0x7fffef58>
    80001e46:	4785                	li	a5,1
    80001e48:	06f71763          	bne	a4,a5,80001eb6 <sched+0xa6>
  if (p->state == RUNNING)
    80001e4c:	4c98                	lw	a4,24(s1)
    80001e4e:	4791                	li	a5,4
    80001e50:	06f70b63          	beq	a4,a5,80001ec6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e54:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e58:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e5a:	efb5                	bnez	a5,80001ed6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e5c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e5e:	0000f917          	auipc	s2,0xf
    80001e62:	44290913          	addi	s2,s2,1090 # 800112a0 <pid_lock>
    80001e66:	2781                	sext.w	a5,a5
    80001e68:	079e                	slli	a5,a5,0x7
    80001e6a:	97ca                	add	a5,a5,s2
    80001e6c:	0ac7a983          	lw	s3,172(a5)
    80001e70:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e72:	2781                	sext.w	a5,a5
    80001e74:	079e                	slli	a5,a5,0x7
    80001e76:	0000f597          	auipc	a1,0xf
    80001e7a:	46258593          	addi	a1,a1,1122 # 800112d8 <cpus+0x8>
    80001e7e:	95be                	add	a1,a1,a5
    80001e80:	06048513          	addi	a0,s1,96
    80001e84:	00001097          	auipc	ra,0x1
    80001e88:	a20080e7          	jalr	-1504(ra) # 800028a4 <swtch>
    80001e8c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e8e:	2781                	sext.w	a5,a5
    80001e90:	079e                	slli	a5,a5,0x7
    80001e92:	97ca                	add	a5,a5,s2
    80001e94:	0b37a623          	sw	s3,172(a5)
}
    80001e98:	70a2                	ld	ra,40(sp)
    80001e9a:	7402                	ld	s0,32(sp)
    80001e9c:	64e2                	ld	s1,24(sp)
    80001e9e:	6942                	ld	s2,16(sp)
    80001ea0:	69a2                	ld	s3,8(sp)
    80001ea2:	6145                	addi	sp,sp,48
    80001ea4:	8082                	ret
    panic("sched p->lock");
    80001ea6:	00006517          	auipc	a0,0x6
    80001eaa:	35a50513          	addi	a0,a0,858 # 80008200 <digits+0x1c0>
    80001eae:	ffffe097          	auipc	ra,0xffffe
    80001eb2:	67c080e7          	jalr	1660(ra) # 8000052a <panic>
    panic("sched locks");
    80001eb6:	00006517          	auipc	a0,0x6
    80001eba:	35a50513          	addi	a0,a0,858 # 80008210 <digits+0x1d0>
    80001ebe:	ffffe097          	auipc	ra,0xffffe
    80001ec2:	66c080e7          	jalr	1644(ra) # 8000052a <panic>
    panic("sched running");
    80001ec6:	00006517          	auipc	a0,0x6
    80001eca:	35a50513          	addi	a0,a0,858 # 80008220 <digits+0x1e0>
    80001ece:	ffffe097          	auipc	ra,0xffffe
    80001ed2:	65c080e7          	jalr	1628(ra) # 8000052a <panic>
    panic("sched interruptible");
    80001ed6:	00006517          	auipc	a0,0x6
    80001eda:	35a50513          	addi	a0,a0,858 # 80008230 <digits+0x1f0>
    80001ede:	ffffe097          	auipc	ra,0xffffe
    80001ee2:	64c080e7          	jalr	1612(ra) # 8000052a <panic>

0000000080001ee6 <yield>:
{
    80001ee6:	1101                	addi	sp,sp,-32
    80001ee8:	ec06                	sd	ra,24(sp)
    80001eea:	e822                	sd	s0,16(sp)
    80001eec:	e426                	sd	s1,8(sp)
    80001eee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ef0:	00000097          	auipc	ra,0x0
    80001ef4:	aaa080e7          	jalr	-1366(ra) # 8000199a <myproc>
    80001ef8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	cc8080e7          	jalr	-824(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    80001f02:	478d                	li	a5,3
    80001f04:	cc9c                	sw	a5,24(s1)
  sched();
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	f0a080e7          	jalr	-246(ra) # 80001e10 <sched>
  release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d66080e7          	jalr	-666(ra) # 80000c76 <release>
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6105                	addi	sp,sp,32
    80001f20:	8082                	ret

0000000080001f22 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80001f22:	7179                	addi	sp,sp,-48
    80001f24:	f406                	sd	ra,40(sp)
    80001f26:	f022                	sd	s0,32(sp)
    80001f28:	ec26                	sd	s1,24(sp)
    80001f2a:	e84a                	sd	s2,16(sp)
    80001f2c:	e44e                	sd	s3,8(sp)
    80001f2e:	1800                	addi	s0,sp,48
    80001f30:	89aa                	mv	s3,a0
    80001f32:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	a66080e7          	jalr	-1434(ra) # 8000199a <myproc>
    80001f3c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
    80001f3e:	fffff097          	auipc	ra,0xfffff
    80001f42:	c84080e7          	jalr	-892(ra) # 80000bc2 <acquire>
  release(lk);
    80001f46:	854a                	mv	a0,s2
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	d2e080e7          	jalr	-722(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    80001f50:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f54:	4789                	li	a5,2
    80001f56:	cc9c                	sw	a5,24(s1)

  sched();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	eb8080e7          	jalr	-328(ra) # 80001e10 <sched>

  // Tidy up.
  p->chan = 0;
    80001f60:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d10080e7          	jalr	-752(ra) # 80000c76 <release>
  acquire(lk);
    80001f6e:	854a                	mv	a0,s2
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	c52080e7          	jalr	-942(ra) # 80000bc2 <acquire>
}
    80001f78:	70a2                	ld	ra,40(sp)
    80001f7a:	7402                	ld	s0,32(sp)
    80001f7c:	64e2                	ld	s1,24(sp)
    80001f7e:	6942                	ld	s2,16(sp)
    80001f80:	69a2                	ld	s3,8(sp)
    80001f82:	6145                	addi	sp,sp,48
    80001f84:	8082                	ret

0000000080001f86 <wait>:
{
    80001f86:	715d                	addi	sp,sp,-80
    80001f88:	e486                	sd	ra,72(sp)
    80001f8a:	e0a2                	sd	s0,64(sp)
    80001f8c:	fc26                	sd	s1,56(sp)
    80001f8e:	f84a                	sd	s2,48(sp)
    80001f90:	f44e                	sd	s3,40(sp)
    80001f92:	f052                	sd	s4,32(sp)
    80001f94:	ec56                	sd	s5,24(sp)
    80001f96:	e85a                	sd	s6,16(sp)
    80001f98:	e45e                	sd	s7,8(sp)
    80001f9a:	e062                	sd	s8,0(sp)
    80001f9c:	0880                	addi	s0,sp,80
    80001f9e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	9fa080e7          	jalr	-1542(ra) # 8000199a <myproc>
    80001fa8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001faa:	0000f517          	auipc	a0,0xf
    80001fae:	30e50513          	addi	a0,a0,782 # 800112b8 <wait_lock>
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	c10080e7          	jalr	-1008(ra) # 80000bc2 <acquire>
    havekids = 0;
    80001fba:	4b81                	li	s7,0
        if (np->state == ZOMBIE)
    80001fbc:	4a15                	li	s4,5
        havekids = 1;
    80001fbe:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    80001fc0:	0001d997          	auipc	s3,0x1d
    80001fc4:	71098993          	addi	s3,s3,1808 # 8001f6d0 <tickslock>
    sleep(p, &wait_lock); //DOC: wait-sleep
    80001fc8:	0000fc17          	auipc	s8,0xf
    80001fcc:	2f0c0c13          	addi	s8,s8,752 # 800112b8 <wait_lock>
    havekids = 0;
    80001fd0:	875e                	mv	a4,s7
    for (np = proc; np < &proc[NPROC]; np++)
    80001fd2:	0000f497          	auipc	s1,0xf
    80001fd6:	6fe48493          	addi	s1,s1,1790 # 800116d0 <proc>
    80001fda:	a0bd                	j	80002048 <wait+0xc2>
          pid = np->pid;
    80001fdc:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80001fe0:	000b0e63          	beqz	s6,80001ffc <wait+0x76>
    80001fe4:	4691                	li	a3,4
    80001fe6:	02c48613          	addi	a2,s1,44
    80001fea:	85da                	mv	a1,s6
    80001fec:	05093503          	ld	a0,80(s2)
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	664080e7          	jalr	1636(ra) # 80001654 <copyout>
    80001ff8:	02054563          	bltz	a0,80002022 <wait+0x9c>
          freeproc(np);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	b4e080e7          	jalr	-1202(ra) # 80001b4c <freeproc>
          release(&np->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c6e080e7          	jalr	-914(ra) # 80000c76 <release>
          release(&wait_lock);
    80002010:	0000f517          	auipc	a0,0xf
    80002014:	2a850513          	addi	a0,a0,680 # 800112b8 <wait_lock>
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	c5e080e7          	jalr	-930(ra) # 80000c76 <release>
          return pid;
    80002020:	a09d                	j	80002086 <wait+0x100>
            release(&np->lock);
    80002022:	8526                	mv	a0,s1
    80002024:	fffff097          	auipc	ra,0xfffff
    80002028:	c52080e7          	jalr	-942(ra) # 80000c76 <release>
            release(&wait_lock);
    8000202c:	0000f517          	auipc	a0,0xf
    80002030:	28c50513          	addi	a0,a0,652 # 800112b8 <wait_lock>
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c42080e7          	jalr	-958(ra) # 80000c76 <release>
            return -1;
    8000203c:	59fd                	li	s3,-1
    8000203e:	a0a1                	j	80002086 <wait+0x100>
    for (np = proc; np < &proc[NPROC]; np++)
    80002040:	38048493          	addi	s1,s1,896
    80002044:	03348463          	beq	s1,s3,8000206c <wait+0xe6>
      if (np->parent == p)
    80002048:	7c9c                	ld	a5,56(s1)
    8000204a:	ff279be3          	bne	a5,s2,80002040 <wait+0xba>
        acquire(&np->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	b72080e7          	jalr	-1166(ra) # 80000bc2 <acquire>
        if (np->state == ZOMBIE)
    80002058:	4c9c                	lw	a5,24(s1)
    8000205a:	f94781e3          	beq	a5,s4,80001fdc <wait+0x56>
        release(&np->lock);
    8000205e:	8526                	mv	a0,s1
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	c16080e7          	jalr	-1002(ra) # 80000c76 <release>
        havekids = 1;
    80002068:	8756                	mv	a4,s5
    8000206a:	bfd9                	j	80002040 <wait+0xba>
    if (!havekids || p->killed)
    8000206c:	c701                	beqz	a4,80002074 <wait+0xee>
    8000206e:	02892783          	lw	a5,40(s2)
    80002072:	c79d                	beqz	a5,800020a0 <wait+0x11a>
      release(&wait_lock);
    80002074:	0000f517          	auipc	a0,0xf
    80002078:	24450513          	addi	a0,a0,580 # 800112b8 <wait_lock>
    8000207c:	fffff097          	auipc	ra,0xfffff
    80002080:	bfa080e7          	jalr	-1030(ra) # 80000c76 <release>
      return -1;
    80002084:	59fd                	li	s3,-1
}
    80002086:	854e                	mv	a0,s3
    80002088:	60a6                	ld	ra,72(sp)
    8000208a:	6406                	ld	s0,64(sp)
    8000208c:	74e2                	ld	s1,56(sp)
    8000208e:	7942                	ld	s2,48(sp)
    80002090:	79a2                	ld	s3,40(sp)
    80002092:	7a02                	ld	s4,32(sp)
    80002094:	6ae2                	ld	s5,24(sp)
    80002096:	6b42                	ld	s6,16(sp)
    80002098:	6ba2                	ld	s7,8(sp)
    8000209a:	6c02                	ld	s8,0(sp)
    8000209c:	6161                	addi	sp,sp,80
    8000209e:	8082                	ret
    sleep(p, &wait_lock); //DOC: wait-sleep
    800020a0:	85e2                	mv	a1,s8
    800020a2:	854a                	mv	a0,s2
    800020a4:	00000097          	auipc	ra,0x0
    800020a8:	e7e080e7          	jalr	-386(ra) # 80001f22 <sleep>
    havekids = 0;
    800020ac:	b715                	j	80001fd0 <wait+0x4a>

00000000800020ae <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800020ae:	7139                	addi	sp,sp,-64
    800020b0:	fc06                	sd	ra,56(sp)
    800020b2:	f822                	sd	s0,48(sp)
    800020b4:	f426                	sd	s1,40(sp)
    800020b6:	f04a                	sd	s2,32(sp)
    800020b8:	ec4e                	sd	s3,24(sp)
    800020ba:	e852                	sd	s4,16(sp)
    800020bc:	e456                	sd	s5,8(sp)
    800020be:	0080                	addi	s0,sp,64
    800020c0:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800020c2:	0000f497          	auipc	s1,0xf
    800020c6:	60e48493          	addi	s1,s1,1550 # 800116d0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800020ca:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800020cc:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800020ce:	0001d917          	auipc	s2,0x1d
    800020d2:	60290913          	addi	s2,s2,1538 # 8001f6d0 <tickslock>
    800020d6:	a811                	j	800020ea <wakeup+0x3c>
      }
      release(&p->lock);
    800020d8:	8526                	mv	a0,s1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	b9c080e7          	jalr	-1124(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800020e2:	38048493          	addi	s1,s1,896
    800020e6:	03248663          	beq	s1,s2,80002112 <wakeup+0x64>
    if (p != myproc())
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	8b0080e7          	jalr	-1872(ra) # 8000199a <myproc>
    800020f2:	fea488e3          	beq	s1,a0,800020e2 <wakeup+0x34>
      acquire(&p->lock);
    800020f6:	8526                	mv	a0,s1
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	aca080e7          	jalr	-1334(ra) # 80000bc2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002100:	4c9c                	lw	a5,24(s1)
    80002102:	fd379be3          	bne	a5,s3,800020d8 <wakeup+0x2a>
    80002106:	709c                	ld	a5,32(s1)
    80002108:	fd4798e3          	bne	a5,s4,800020d8 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000210c:	0154ac23          	sw	s5,24(s1)
    80002110:	b7e1                	j	800020d8 <wakeup+0x2a>
    }
  }
}
    80002112:	70e2                	ld	ra,56(sp)
    80002114:	7442                	ld	s0,48(sp)
    80002116:	74a2                	ld	s1,40(sp)
    80002118:	7902                	ld	s2,32(sp)
    8000211a:	69e2                	ld	s3,24(sp)
    8000211c:	6a42                	ld	s4,16(sp)
    8000211e:	6aa2                	ld	s5,8(sp)
    80002120:	6121                	addi	sp,sp,64
    80002122:	8082                	ret

0000000080002124 <reparent>:
{
    80002124:	7179                	addi	sp,sp,-48
    80002126:	f406                	sd	ra,40(sp)
    80002128:	f022                	sd	s0,32(sp)
    8000212a:	ec26                	sd	s1,24(sp)
    8000212c:	e84a                	sd	s2,16(sp)
    8000212e:	e44e                	sd	s3,8(sp)
    80002130:	e052                	sd	s4,0(sp)
    80002132:	1800                	addi	s0,sp,48
    80002134:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002136:	0000f497          	auipc	s1,0xf
    8000213a:	59a48493          	addi	s1,s1,1434 # 800116d0 <proc>
      pp->parent = initproc;
    8000213e:	00007a17          	auipc	s4,0x7
    80002142:	eeaa0a13          	addi	s4,s4,-278 # 80009028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002146:	0001d997          	auipc	s3,0x1d
    8000214a:	58a98993          	addi	s3,s3,1418 # 8001f6d0 <tickslock>
    8000214e:	a029                	j	80002158 <reparent+0x34>
    80002150:	38048493          	addi	s1,s1,896
    80002154:	01348d63          	beq	s1,s3,8000216e <reparent+0x4a>
    if (pp->parent == p)
    80002158:	7c9c                	ld	a5,56(s1)
    8000215a:	ff279be3          	bne	a5,s2,80002150 <reparent+0x2c>
      pp->parent = initproc;
    8000215e:	000a3503          	ld	a0,0(s4)
    80002162:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002164:	00000097          	auipc	ra,0x0
    80002168:	f4a080e7          	jalr	-182(ra) # 800020ae <wakeup>
    8000216c:	b7d5                	j	80002150 <reparent+0x2c>
}
    8000216e:	70a2                	ld	ra,40(sp)
    80002170:	7402                	ld	s0,32(sp)
    80002172:	64e2                	ld	s1,24(sp)
    80002174:	6942                	ld	s2,16(sp)
    80002176:	69a2                	ld	s3,8(sp)
    80002178:	6a02                	ld	s4,0(sp)
    8000217a:	6145                	addi	sp,sp,48
    8000217c:	8082                	ret

000000008000217e <exit>:
{
    8000217e:	7179                	addi	sp,sp,-48
    80002180:	f406                	sd	ra,40(sp)
    80002182:	f022                	sd	s0,32(sp)
    80002184:	ec26                	sd	s1,24(sp)
    80002186:	e84a                	sd	s2,16(sp)
    80002188:	e44e                	sd	s3,8(sp)
    8000218a:	e052                	sd	s4,0(sp)
    8000218c:	1800                	addi	s0,sp,48
    8000218e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002190:	00000097          	auipc	ra,0x0
    80002194:	80a080e7          	jalr	-2038(ra) # 8000199a <myproc>
    80002198:	89aa                	mv	s3,a0
  if (p == initproc)
    8000219a:	00007797          	auipc	a5,0x7
    8000219e:	e8e7b783          	ld	a5,-370(a5) # 80009028 <initproc>
    800021a2:	0d050493          	addi	s1,a0,208
    800021a6:	15050913          	addi	s2,a0,336
    800021aa:	02a79363          	bne	a5,a0,800021d0 <exit+0x52>
    panic("init exiting");
    800021ae:	00006517          	auipc	a0,0x6
    800021b2:	09a50513          	addi	a0,a0,154 # 80008248 <digits+0x208>
    800021b6:	ffffe097          	auipc	ra,0xffffe
    800021ba:	374080e7          	jalr	884(ra) # 8000052a <panic>
      fileclose(f);
    800021be:	00003097          	auipc	ra,0x3
    800021c2:	98c080e7          	jalr	-1652(ra) # 80004b4a <fileclose>
      p->ofile[fd] = 0;
    800021c6:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800021ca:	04a1                	addi	s1,s1,8
    800021cc:	01248563          	beq	s1,s2,800021d6 <exit+0x58>
    if (p->ofile[fd])
    800021d0:	6088                	ld	a0,0(s1)
    800021d2:	f575                	bnez	a0,800021be <exit+0x40>
    800021d4:	bfdd                	j	800021ca <exit+0x4c>
  begin_op();
    800021d6:	00002097          	auipc	ra,0x2
    800021da:	4a8080e7          	jalr	1192(ra) # 8000467e <begin_op>
  iput(p->cwd);
    800021de:	1509b503          	ld	a0,336(s3)
    800021e2:	00002097          	auipc	ra,0x2
    800021e6:	96e080e7          	jalr	-1682(ra) # 80003b50 <iput>
  end_op();
    800021ea:	00002097          	auipc	ra,0x2
    800021ee:	514080e7          	jalr	1300(ra) # 800046fe <end_op>
  p->cwd = 0;
    800021f2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021f6:	0000f497          	auipc	s1,0xf
    800021fa:	0c248493          	addi	s1,s1,194 # 800112b8 <wait_lock>
    800021fe:	8526                	mv	a0,s1
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	9c2080e7          	jalr	-1598(ra) # 80000bc2 <acquire>
  reparent(p);
    80002208:	854e                	mv	a0,s3
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	f1a080e7          	jalr	-230(ra) # 80002124 <reparent>
  wakeup(p->parent);
    80002212:	0389b503          	ld	a0,56(s3)
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	e98080e7          	jalr	-360(ra) # 800020ae <wakeup>
  acquire(&p->lock);
    8000221e:	854e                	mv	a0,s3
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	9a2080e7          	jalr	-1630(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002228:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000222c:	4795                	li	a5,5
    8000222e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	a42080e7          	jalr	-1470(ra) # 80000c76 <release>
  sched();
    8000223c:	00000097          	auipc	ra,0x0
    80002240:	bd4080e7          	jalr	-1068(ra) # 80001e10 <sched>
  panic("zombie exit");
    80002244:	00006517          	auipc	a0,0x6
    80002248:	01450513          	addi	a0,a0,20 # 80008258 <digits+0x218>
    8000224c:	ffffe097          	auipc	ra,0xffffe
    80002250:	2de080e7          	jalr	734(ra) # 8000052a <panic>

0000000080002254 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	1800                	addi	s0,sp,48
    80002262:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002264:	0000f497          	auipc	s1,0xf
    80002268:	46c48493          	addi	s1,s1,1132 # 800116d0 <proc>
    8000226c:	0001d997          	auipc	s3,0x1d
    80002270:	46498993          	addi	s3,s3,1124 # 8001f6d0 <tickslock>
  {
    acquire(&p->lock);
    80002274:	8526                	mv	a0,s1
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	94c080e7          	jalr	-1716(ra) # 80000bc2 <acquire>
    if (p->pid == pid)
    8000227e:	589c                	lw	a5,48(s1)
    80002280:	01278d63          	beq	a5,s2,8000229a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	9f0080e7          	jalr	-1552(ra) # 80000c76 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000228e:	38048493          	addi	s1,s1,896
    80002292:	ff3491e3          	bne	s1,s3,80002274 <kill+0x20>
  }
  return -1;
    80002296:	557d                	li	a0,-1
    80002298:	a829                	j	800022b2 <kill+0x5e>
      p->killed = 1;
    8000229a:	4785                	li	a5,1
    8000229c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    8000229e:	4c98                	lw	a4,24(s1)
    800022a0:	4789                	li	a5,2
    800022a2:	00f70f63          	beq	a4,a5,800022c0 <kill+0x6c>
      release(&p->lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	9ce080e7          	jalr	-1586(ra) # 80000c76 <release>
      return 0;
    800022b0:	4501                	li	a0,0
}
    800022b2:	70a2                	ld	ra,40(sp)
    800022b4:	7402                	ld	s0,32(sp)
    800022b6:	64e2                	ld	s1,24(sp)
    800022b8:	6942                	ld	s2,16(sp)
    800022ba:	69a2                	ld	s3,8(sp)
    800022bc:	6145                	addi	sp,sp,48
    800022be:	8082                	ret
        p->state = RUNNABLE;
    800022c0:	478d                	li	a5,3
    800022c2:	cc9c                	sw	a5,24(s1)
    800022c4:	b7cd                	j	800022a6 <kill+0x52>

00000000800022c6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022c6:	7179                	addi	sp,sp,-48
    800022c8:	f406                	sd	ra,40(sp)
    800022ca:	f022                	sd	s0,32(sp)
    800022cc:	ec26                	sd	s1,24(sp)
    800022ce:	e84a                	sd	s2,16(sp)
    800022d0:	e44e                	sd	s3,8(sp)
    800022d2:	e052                	sd	s4,0(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	84aa                	mv	s1,a0
    800022d8:	892e                	mv	s2,a1
    800022da:	89b2                	mv	s3,a2
    800022dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	6bc080e7          	jalr	1724(ra) # 8000199a <myproc>
  if (user_dst)
    800022e6:	c08d                	beqz	s1,80002308 <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    800022e8:	86d2                	mv	a3,s4
    800022ea:	864e                	mv	a2,s3
    800022ec:	85ca                	mv	a1,s2
    800022ee:	6928                	ld	a0,80(a0)
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	364080e7          	jalr	868(ra) # 80001654 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022f8:	70a2                	ld	ra,40(sp)
    800022fa:	7402                	ld	s0,32(sp)
    800022fc:	64e2                	ld	s1,24(sp)
    800022fe:	6942                	ld	s2,16(sp)
    80002300:	69a2                	ld	s3,8(sp)
    80002302:	6a02                	ld	s4,0(sp)
    80002304:	6145                	addi	sp,sp,48
    80002306:	8082                	ret
    memmove((char *)dst, src, len);
    80002308:	000a061b          	sext.w	a2,s4
    8000230c:	85ce                	mv	a1,s3
    8000230e:	854a                	mv	a0,s2
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	a0a080e7          	jalr	-1526(ra) # 80000d1a <memmove>
    return 0;
    80002318:	8526                	mv	a0,s1
    8000231a:	bff9                	j	800022f8 <either_copyout+0x32>

000000008000231c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000231c:	7179                	addi	sp,sp,-48
    8000231e:	f406                	sd	ra,40(sp)
    80002320:	f022                	sd	s0,32(sp)
    80002322:	ec26                	sd	s1,24(sp)
    80002324:	e84a                	sd	s2,16(sp)
    80002326:	e44e                	sd	s3,8(sp)
    80002328:	e052                	sd	s4,0(sp)
    8000232a:	1800                	addi	s0,sp,48
    8000232c:	892a                	mv	s2,a0
    8000232e:	84ae                	mv	s1,a1
    80002330:	89b2                	mv	s3,a2
    80002332:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	666080e7          	jalr	1638(ra) # 8000199a <myproc>
  if (user_src)
    8000233c:	c08d                	beqz	s1,8000235e <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    8000233e:	86d2                	mv	a3,s4
    80002340:	864e                	mv	a2,s3
    80002342:	85ca                	mv	a1,s2
    80002344:	6928                	ld	a0,80(a0)
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	39c080e7          	jalr	924(ra) # 800016e2 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000234e:	70a2                	ld	ra,40(sp)
    80002350:	7402                	ld	s0,32(sp)
    80002352:	64e2                	ld	s1,24(sp)
    80002354:	6942                	ld	s2,16(sp)
    80002356:	69a2                	ld	s3,8(sp)
    80002358:	6a02                	ld	s4,0(sp)
    8000235a:	6145                	addi	sp,sp,48
    8000235c:	8082                	ret
    memmove(dst, (char *)src, len);
    8000235e:	000a061b          	sext.w	a2,s4
    80002362:	85ce                	mv	a1,s3
    80002364:	854a                	mv	a0,s2
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	9b4080e7          	jalr	-1612(ra) # 80000d1a <memmove>
    return 0;
    8000236e:	8526                	mv	a0,s1
    80002370:	bff9                	j	8000234e <either_copyin+0x32>

0000000080002372 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002372:	715d                	addi	sp,sp,-80
    80002374:	e486                	sd	ra,72(sp)
    80002376:	e0a2                	sd	s0,64(sp)
    80002378:	fc26                	sd	s1,56(sp)
    8000237a:	f84a                	sd	s2,48(sp)
    8000237c:	f44e                	sd	s3,40(sp)
    8000237e:	f052                	sd	s4,32(sp)
    80002380:	ec56                	sd	s5,24(sp)
    80002382:	e85a                	sd	s6,16(sp)
    80002384:	e45e                	sd	s7,8(sp)
    80002386:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002388:	00006517          	auipc	a0,0x6
    8000238c:	d4050513          	addi	a0,a0,-704 # 800080c8 <digits+0x88>
    80002390:	ffffe097          	auipc	ra,0xffffe
    80002394:	1e4080e7          	jalr	484(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002398:	0000f497          	auipc	s1,0xf
    8000239c:	49048493          	addi	s1,s1,1168 # 80011828 <proc+0x158>
    800023a0:	0001d917          	auipc	s2,0x1d
    800023a4:	48890913          	addi	s2,s2,1160 # 8001f828 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023aa:	00006997          	auipc	s3,0x6
    800023ae:	ebe98993          	addi	s3,s3,-322 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800023b2:	00006a97          	auipc	s5,0x6
    800023b6:	ebea8a93          	addi	s5,s5,-322 # 80008270 <digits+0x230>
    printf("\n");
    800023ba:	00006a17          	auipc	s4,0x6
    800023be:	d0ea0a13          	addi	s4,s4,-754 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023c2:	00006b97          	auipc	s7,0x6
    800023c6:	02eb8b93          	addi	s7,s7,46 # 800083f0 <states.0>
    800023ca:	a00d                	j	800023ec <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800023cc:	ed86a583          	lw	a1,-296(a3)
    800023d0:	8556                	mv	a0,s5
    800023d2:	ffffe097          	auipc	ra,0xffffe
    800023d6:	1a2080e7          	jalr	418(ra) # 80000574 <printf>
    printf("\n");
    800023da:	8552                	mv	a0,s4
    800023dc:	ffffe097          	auipc	ra,0xffffe
    800023e0:	198080e7          	jalr	408(ra) # 80000574 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800023e4:	38048493          	addi	s1,s1,896
    800023e8:	03248263          	beq	s1,s2,8000240c <procdump+0x9a>
    if (p->state == UNUSED)
    800023ec:	86a6                	mv	a3,s1
    800023ee:	ec04a783          	lw	a5,-320(s1)
    800023f2:	dbed                	beqz	a5,800023e4 <procdump+0x72>
      state = "???";
    800023f4:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023f6:	fcfb6be3          	bltu	s6,a5,800023cc <procdump+0x5a>
    800023fa:	02079713          	slli	a4,a5,0x20
    800023fe:	01d75793          	srli	a5,a4,0x1d
    80002402:	97de                	add	a5,a5,s7
    80002404:	6390                	ld	a2,0(a5)
    80002406:	f279                	bnez	a2,800023cc <procdump+0x5a>
      state = "???";
    80002408:	864e                	mv	a2,s3
    8000240a:	b7c9                	j	800023cc <procdump+0x5a>
  }
}
    8000240c:	60a6                	ld	ra,72(sp)
    8000240e:	6406                	ld	s0,64(sp)
    80002410:	74e2                	ld	s1,56(sp)
    80002412:	7942                	ld	s2,48(sp)
    80002414:	79a2                	ld	s3,40(sp)
    80002416:	7a02                	ld	s4,32(sp)
    80002418:	6ae2                	ld	s5,24(sp)
    8000241a:	6b42                	ld	s6,16(sp)
    8000241c:	6ba2                	ld	s7,8(sp)
    8000241e:	6161                	addi	sp,sp,80
    80002420:	8082                	ret

0000000080002422 <next_free_space_in_swap_file>:
  return psi->index;
}

// Next free space in swap file
int next_free_space_in_swap_file()
{
    80002422:	1141                	addi	sp,sp,-16
    80002424:	e406                	sd	ra,8(sp)
    80002426:	e022                	sd	s0,0(sp)
    80002428:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	570080e7          	jalr	1392(ra) # 8000199a <myproc>
  uint16 free_spaces = p->pages_swap_info.free_spaces;
    80002432:	17855783          	lhu	a5,376(a0)
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (!(free_spaces & (1 << i)))
    80002436:	0007871b          	sext.w	a4,a5
    8000243a:	8b85                	andi	a5,a5,1
    8000243c:	cf99                	beqz	a5,8000245a <next_free_space_in_swap_file+0x38>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000243e:	4505                	li	a0,1
    80002440:	46c1                	li	a3,16
    if (!(free_spaces & (1 << i)))
    80002442:	40a757bb          	sraw	a5,a4,a0
    80002446:	8b85                	andi	a5,a5,1
    80002448:	c789                	beqz	a5,80002452 <next_free_space_in_swap_file+0x30>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000244a:	2505                	addiw	a0,a0,1
    8000244c:	fed51be3          	bne	a0,a3,80002442 <next_free_space_in_swap_file+0x20>
      return i;
  }
  return -1;
    80002450:	557d                	li	a0,-1
}
    80002452:	60a2                	ld	ra,8(sp)
    80002454:	6402                	ld	s0,0(sp)
    80002456:	0141                	addi	sp,sp,16
    80002458:	8082                	ret
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    8000245a:	4501                	li	a0,0
    8000245c:	bfdd                	j	80002452 <next_free_space_in_swap_file+0x30>

000000008000245e <get_page_swap_info>:

// Get file vm and return file entery inside swap file if exist
struct page_swap_info *
get_page_swap_info(uint64 va)
{
    8000245e:	1101                	addi	sp,sp,-32
    80002460:	ec06                	sd	ra,24(sp)
    80002462:	e822                	sd	s0,16(sp)
    80002464:	e426                	sd	s1,8(sp)
    80002466:	1000                	addi	s0,sp,32
    80002468:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	530080e7          	jalr	1328(ra) # 8000199a <myproc>
  uint64 a = PGROUNDDOWN(va);
    80002472:	767d                	lui	a2,0xfffff
    80002474:	8e65                	and	a2,a2,s1
  for (int i = 0; i < MAX_TOTAL_PAGES; i++)
    80002476:	18050713          	addi	a4,a0,384
    8000247a:	4781                	li	a5,0
    8000247c:	02000593          	li	a1,32
  {
    struct page_swap_info *po = &(p->pages_swap_info.pages[i]);
    if (po->va == a)
    80002480:	6314                	ld	a3,0(a4)
    80002482:	00c68863          	beq	a3,a2,80002492 <get_page_swap_info+0x34>
  for (int i = 0; i < MAX_TOTAL_PAGES; i++)
    80002486:	2785                	addiw	a5,a5,1
    80002488:	0741                	addi	a4,a4,16
    8000248a:	feb79be3          	bne	a5,a1,80002480 <get_page_swap_info+0x22>
    {
      return po;
    }
  }

  return 0; // if not found return null
    8000248e:	4501                	li	a0,0
    80002490:	a021                	j	80002498 <get_page_swap_info+0x3a>
    struct page_swap_info *po = &(p->pages_swap_info.pages[i]);
    80002492:	07e1                	addi	a5,a5,24
    80002494:	0792                	slli	a5,a5,0x4
    80002496:	953e                	add	a0,a0,a5
}
    80002498:	60e2                	ld	ra,24(sp)
    8000249a:	6442                	ld	s0,16(sp)
    8000249c:	64a2                	ld	s1,8(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret

00000000800024a2 <where_in_swap_file>:
{
    800024a2:	1141                	addi	sp,sp,-16
    800024a4:	e406                	sd	ra,8(sp)
    800024a6:	e022                	sd	s0,0(sp)
    800024a8:	0800                	addi	s0,sp,16
  struct page_swap_info *psi = get_page_swap_info(va);
    800024aa:	00000097          	auipc	ra,0x0
    800024ae:	fb4080e7          	jalr	-76(ra) # 8000245e <get_page_swap_info>
  if (psi == 0)
    800024b2:	c511                	beqz	a0,800024be <where_in_swap_file+0x1c>
  return psi->index;
    800024b4:	4508                	lw	a0,8(a0)
}
    800024b6:	60a2                	ld	ra,8(sp)
    800024b8:	6402                	ld	s0,0(sp)
    800024ba:	0141                	addi	sp,sp,16
    800024bc:	8082                	ret
    return -2;
    800024be:	5579                	li	a0,-2
    800024c0:	bfdd                	j	800024b6 <where_in_swap_file+0x14>

00000000800024c2 <page_out>:
//  free physical memory of page which virtual address va
//  write this page to procs swap file
//  return the new free physical address
uint64
page_out(uint64 va)
{
    800024c2:	7179                	addi	sp,sp,-48
    800024c4:	f406                	sd	ra,40(sp)
    800024c6:	f022                	sd	s0,32(sp)
    800024c8:	ec26                	sd	s1,24(sp)
    800024ca:	e84a                	sd	s2,16(sp)
    800024cc:	e44e                	sd	s3,8(sp)
    800024ce:	e052                	sd	s4,0(sp)
    800024d0:	1800                	addi	s0,sp,48
    800024d2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	4c6080e7          	jalr	1222(ra) # 8000199a <myproc>
    800024dc:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	66a080e7          	jalr	1642(ra) # 80000b48 <holding>
    800024e6:	c151                	beqz	a0,8000256a <page_out+0xa8>
    panic("fadge we are not holding the lock in page_out");

  uint64 rva = PGROUNDDOWN(va);

  // find the addres of the page which sent out
  uint64 pa = walkaddr(p->pagetable, rva, 1); // return with pte valid = 0
    800024e8:	4605                	li	a2,1
    800024ea:	75fd                	lui	a1,0xfffff
    800024ec:	00ba75b3          	and	a1,s4,a1
    800024f0:	68a8                	ld	a0,80(s1)
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	b5a080e7          	jalr	-1190(ra) # 8000104c <walkaddr>
    800024fa:	89aa                	mv	s3,a0

  // insert the page to the swap file
  int free_index = next_free_space_in_swap_file();
    800024fc:	00000097          	auipc	ra,0x0
    80002500:	f26080e7          	jalr	-218(ra) # 80002422 <next_free_space_in_swap_file>
    80002504:	892a                	mv	s2,a0
  int start_offset = free_index * PGSIZE;
    80002506:	00c5161b          	slliw	a2,a0,0xc
  if (free_index < 0 || free_index >= MAX_PSYC_PAGES)
    8000250a:	0005071b          	sext.w	a4,a0
    8000250e:	47bd                	li	a5,15
    80002510:	06e7e563          	bltu	a5,a4,8000257a <page_out+0xb8>
    panic("fadge no free index in page_out");
  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE);
    80002514:	6685                	lui	a3,0x1
    80002516:	2601                	sext.w	a2,a2
    80002518:	85ce                	mv	a1,s3
    8000251a:	8526                	mv	a0,s1
    8000251c:	00002097          	auipc	ra,0x2
    80002520:	f34080e7          	jalr	-204(ra) # 80004450 <writeToSwapFile>

  // update the swap info struct
  struct pages_swap_info *pages_sw = &p->pages_swap_info;
  // mark free_index as occupied
  pages_sw->free_spaces |= (1 << free_index);
    80002524:	4785                	li	a5,1
    80002526:	0127973b          	sllw	a4,a5,s2
    8000252a:	1784d783          	lhu	a5,376(s1)
    8000252e:	8fd9                	or	a5,a5,a4
    80002530:	16f49c23          	sh	a5,376(s1)
  struct page_swap_info *pswi = get_page_swap_info(va);
    80002534:	8552                	mv	a0,s4
    80002536:	00000097          	auipc	ra,0x0
    8000253a:	f28080e7          	jalr	-216(ra) # 8000245e <get_page_swap_info>
  if (!pswi)
    8000253e:	c531                	beqz	a0,8000258a <page_out+0xc8>
    panic("fadge page swap info not found in page_out");
  pswi->index = free_index;
    80002540:	01252423          	sw	s2,8(a0)
  // update the physical page counter
  p->physical_pages_num--;
    80002544:	1704a783          	lw	a5,368(s1)
    80002548:	37fd                	addiw	a5,a5,-1
    8000254a:	16f4a823          	sw	a5,368(s1)

  // free space in physical memory
  kfree((void *)pa);
    8000254e:	854e                	mv	a0,s3
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	486080e7          	jalr	1158(ra) # 800009d6 <kfree>

  return pa;
}
    80002558:	854e                	mv	a0,s3
    8000255a:	70a2                	ld	ra,40(sp)
    8000255c:	7402                	ld	s0,32(sp)
    8000255e:	64e2                	ld	s1,24(sp)
    80002560:	6942                	ld	s2,16(sp)
    80002562:	69a2                	ld	s3,8(sp)
    80002564:	6a02                	ld	s4,0(sp)
    80002566:	6145                	addi	sp,sp,48
    80002568:	8082                	ret
    panic("fadge we are not holding the lock in page_out");
    8000256a:	00006517          	auipc	a0,0x6
    8000256e:	d1650513          	addi	a0,a0,-746 # 80008280 <digits+0x240>
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	fb8080e7          	jalr	-72(ra) # 8000052a <panic>
    panic("fadge no free index in page_out");
    8000257a:	00006517          	auipc	a0,0x6
    8000257e:	d3650513          	addi	a0,a0,-714 # 800082b0 <digits+0x270>
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	fa8080e7          	jalr	-88(ra) # 8000052a <panic>
    panic("fadge page swap info not found in page_out");
    8000258a:	00006517          	auipc	a0,0x6
    8000258e:	d4650513          	addi	a0,a0,-698 # 800082d0 <digits+0x290>
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	f98080e7          	jalr	-104(ra) # 8000052a <panic>

000000008000259a <page_in>:

// move page from swap file to physical memory
pte_t*
page_in(uint64 va, pte_t *pte)
{
    8000259a:	7179                	addi	sp,sp,-48
    8000259c:	f406                	sd	ra,40(sp)
    8000259e:	f022                	sd	s0,32(sp)
    800025a0:	ec26                	sd	s1,24(sp)
    800025a2:	e84a                	sd	s2,16(sp)
    800025a4:	e44e                	sd	s3,8(sp)
    800025a6:	e052                	sd	s4,0(sp)
    800025a8:	1800                	addi	s0,sp,48
    800025aa:	84aa                	mv	s1,a0
    800025ac:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800025ae:	fffff097          	auipc	ra,0xfffff
    800025b2:	3ec080e7          	jalr	1004(ra) # 8000199a <myproc>
    800025b6:	892a                	mv	s2,a0
  // update swap info
  int page_index = where_in_swap_file(va);
    800025b8:	8526                	mv	a0,s1
    800025ba:	00000097          	auipc	ra,0x0
    800025be:	ee8080e7          	jalr	-280(ra) # 800024a2 <where_in_swap_file>
    800025c2:	0005071b          	sext.w	a4,a0
  int start_offset = page_index * PGSIZE;
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    800025c6:	47bd                	li	a5,15
    800025c8:	06e7ed63          	bltu	a5,a4,80002642 <page_in+0xa8>
    800025cc:	00c51a1b          	slliw	s4,a0,0xc
    panic("fadge no free index in page_in");
  p->pages_swap_info.free_spaces ^= 1 << page_index;
    800025d0:	4785                	li	a5,1
    800025d2:	00e7973b          	sllw	a4,a5,a4
    800025d6:	17895783          	lhu	a5,376(s2)
    800025da:	8fb9                	xor	a5,a5,a4
    800025dc:	16f91c23          	sh	a5,376(s2)

  // remove page from swap file
  // or am i

  // alloc page in physical memory
  void *pa = kalloc();
    800025e0:	ffffe097          	auipc	ra,0xffffe
    800025e4:	4f2080e7          	jalr	1266(ra) # 80000ad2 <kalloc>
    800025e8:	84aa                	mv	s1,a0

  if (!pa)
    800025ea:	c525                	beqz	a0,80002652 <page_in+0xb8>
    panic("page in: fack kalloc failed in page_in");
  memset(pa, 0, PGSIZE);
    800025ec:	6605                	lui	a2,0x1
    800025ee:	4581                	li	a1,0
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	6ce080e7          	jalr	1742(ra) # 80000cbe <memset>

  readFromSwapFile(p, pa, start_offset, PGSIZE);
    800025f8:	6685                	lui	a3,0x1
    800025fa:	000a061b          	sext.w	a2,s4
    800025fe:	85a6                	mv	a1,s1
    80002600:	854a                	mv	a0,s2
    80002602:	00002097          	auipc	ra,0x2
    80002606:	e72080e7          	jalr	-398(ra) # 80004474 <readFromSwapFile>

  // update pte
  if (!(*pte & PTE_PG) || *pte & PTE_V)
    8000260a:	0009b783          	ld	a5,0(s3)
    8000260e:	2017f793          	andi	a5,a5,513
    80002612:	20000713          	li	a4,512
    80002616:	04e79663          	bne	a5,a4,80002662 <page_in+0xc8>
    panic("page in: page out flag was off or valid flag was on");
  *pte = PA2PTE(pa) ^ PTE_V ^ PTE_PG;
    8000261a:	80b1                	srli	s1,s1,0xc
    8000261c:	04aa                	slli	s1,s1,0xa
    8000261e:	2014c493          	xori	s1,s1,513
    80002622:	0099b023          	sd	s1,0(s3)
  p->physical_pages_num++;
    80002626:	17092783          	lw	a5,368(s2)
    8000262a:	2785                	addiw	a5,a5,1
    8000262c:	16f92823          	sw	a5,368(s2)

  return pte;
}
    80002630:	854e                	mv	a0,s3
    80002632:	70a2                	ld	ra,40(sp)
    80002634:	7402                	ld	s0,32(sp)
    80002636:	64e2                	ld	s1,24(sp)
    80002638:	6942                	ld	s2,16(sp)
    8000263a:	69a2                	ld	s3,8(sp)
    8000263c:	6a02                	ld	s4,0(sp)
    8000263e:	6145                	addi	sp,sp,48
    80002640:	8082                	ret
    panic("fadge no free index in page_in");
    80002642:	00006517          	auipc	a0,0x6
    80002646:	cbe50513          	addi	a0,a0,-834 # 80008300 <digits+0x2c0>
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	ee0080e7          	jalr	-288(ra) # 8000052a <panic>
    panic("page in: fack kalloc failed in page_in");
    80002652:	00006517          	auipc	a0,0x6
    80002656:	cce50513          	addi	a0,a0,-818 # 80008320 <digits+0x2e0>
    8000265a:	ffffe097          	auipc	ra,0xffffe
    8000265e:	ed0080e7          	jalr	-304(ra) # 8000052a <panic>
    panic("page in: page out flag was off or valid flag was on");
    80002662:	00006517          	auipc	a0,0x6
    80002666:	ce650513          	addi	a0,a0,-794 # 80008348 <digits+0x308>
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	ec0080e7          	jalr	-320(ra) # 8000052a <panic>

0000000080002672 <copySwap>:

void copySwap(struct proc *p, struct proc *np)
{
    80002672:	7139                	addi	sp,sp,-64
    80002674:	fc06                	sd	ra,56(sp)
    80002676:	f822                	sd	s0,48(sp)
    80002678:	f426                	sd	s1,40(sp)
    8000267a:	f04a                	sd	s2,32(sp)
    8000267c:	ec4e                	sd	s3,24(sp)
    8000267e:	e852                	sd	s4,16(sp)
    80002680:	e456                	sd	s5,8(sp)
    80002682:	e05a                	sd	s6,0(sp)
    80002684:	0080                	addi	s0,sp,64
    80002686:	89aa                	mv	s3,a0
    80002688:	84ae                	mv	s1,a1
  // Copy swapfile
  void *temp_page;
  if (!(temp_page = kalloc()))
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	448080e7          	jalr	1096(ra) # 80000ad2 <kalloc>
    80002692:	8a2a                	mv	s4,a0
    80002694:	4901                	li	s2,0
    panic("copySwap: kalloc failed");
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    80002696:	6b05                	lui	s6,0x1
    80002698:	6ac1                	lui	s5,0x10
  if (!(temp_page = kalloc()))
    8000269a:	c935                	beqz	a0,8000270e <copySwap+0x9c>
  {
    int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);
    8000269c:	6685                	lui	a3,0x1
    8000269e:	864a                	mv	a2,s2
    800026a0:	85d2                	mv	a1,s4
    800026a2:	854e                	mv	a0,s3
    800026a4:	00002097          	auipc	ra,0x2
    800026a8:	dd0080e7          	jalr	-560(ra) # 80004474 <readFromSwapFile>
    if (res < 0)
    800026ac:	06054963          	bltz	a0,8000271e <copySwap+0xac>
      panic("copySwap: failed read");

    res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);
    800026b0:	6685                	lui	a3,0x1
    800026b2:	864a                	mv	a2,s2
    800026b4:	85d2                	mv	a1,s4
    800026b6:	8526                	mv	a0,s1
    800026b8:	00002097          	auipc	ra,0x2
    800026bc:	d98080e7          	jalr	-616(ra) # 80004450 <writeToSwapFile>
    if (res < 0)
    800026c0:	06054763          	bltz	a0,8000272e <copySwap+0xbc>
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
    800026c4:	012b093b          	addw	s2,s6,s2
    800026c8:	fd591ae3          	bne	s2,s5,8000269c <copySwap+0x2a>
      panic("copySwap: faild write ");
  }
  kfree(temp_page);
    800026cc:	8552                	mv	a0,s4
    800026ce:	ffffe097          	auipc	ra,0xffffe
    800026d2:	308080e7          	jalr	776(ra) # 800009d6 <kfree>

  // Copy swap struct
  np->pages_swap_info.free_spaces=p->pages_swap_info.free_spaces;
    800026d6:	1789d783          	lhu	a5,376(s3)
    800026da:	16f49c23          	sh	a5,376(s1)
  for(int i=0;i<MAX_TOTAL_PAGES;i++){
    800026de:	18098793          	addi	a5,s3,384
    800026e2:	18048593          	addi	a1,s1,384
    800026e6:	38098513          	addi	a0,s3,896
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    800026ea:	6398                	ld	a4,0(a5)
    800026ec:	e198                	sd	a4,0(a1)
    800026ee:	6798                	ld	a4,8(a5)
    800026f0:	e598                	sd	a4,8(a1)
  for(int i=0;i<MAX_TOTAL_PAGES;i++){
    800026f2:	07c1                	addi	a5,a5,16
    800026f4:	05c1                	addi	a1,a1,16
    800026f6:	fea79ae3          	bne	a5,a0,800026ea <copySwap+0x78>
  }
  
    800026fa:	70e2                	ld	ra,56(sp)
    800026fc:	7442                	ld	s0,48(sp)
    800026fe:	74a2                	ld	s1,40(sp)
    80002700:	7902                	ld	s2,32(sp)
    80002702:	69e2                	ld	s3,24(sp)
    80002704:	6a42                	ld	s4,16(sp)
    80002706:	6aa2                	ld	s5,8(sp)
    80002708:	6b02                	ld	s6,0(sp)
    8000270a:	6121                	addi	sp,sp,64
    8000270c:	8082                	ret
    panic("copySwap: kalloc failed");
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	c7250513          	addi	a0,a0,-910 # 80008380 <digits+0x340>
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	e14080e7          	jalr	-492(ra) # 8000052a <panic>
      panic("copySwap: failed read");
    8000271e:	00006517          	auipc	a0,0x6
    80002722:	c7a50513          	addi	a0,a0,-902 # 80008398 <digits+0x358>
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	e04080e7          	jalr	-508(ra) # 8000052a <panic>
      panic("copySwap: faild write ");
    8000272e:	00006517          	auipc	a0,0x6
    80002732:	c8250513          	addi	a0,a0,-894 # 800083b0 <digits+0x370>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	df4080e7          	jalr	-524(ra) # 8000052a <panic>

000000008000273e <fork>:
{
    8000273e:	7139                	addi	sp,sp,-64
    80002740:	fc06                	sd	ra,56(sp)
    80002742:	f822                	sd	s0,48(sp)
    80002744:	f426                	sd	s1,40(sp)
    80002746:	f04a                	sd	s2,32(sp)
    80002748:	ec4e                	sd	s3,24(sp)
    8000274a:	e852                	sd	s4,16(sp)
    8000274c:	e456                	sd	s5,8(sp)
    8000274e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	24a080e7          	jalr	586(ra) # 8000199a <myproc>
    80002758:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    8000275a:	fffff097          	auipc	ra,0xfffff
    8000275e:	44a080e7          	jalr	1098(ra) # 80001ba4 <allocproc>
    80002762:	12050f63          	beqz	a0,800028a0 <fork+0x162>
    80002766:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002768:	048ab603          	ld	a2,72(s5) # 10048 <_entry-0x7ffeffb8>
    8000276c:	692c                	ld	a1,80(a0)
    8000276e:	050ab503          	ld	a0,80(s5)
    80002772:	fffff097          	auipc	ra,0xfffff
    80002776:	dde080e7          	jalr	-546(ra) # 80001550 <uvmcopy>
    8000277a:	04054863          	bltz	a0,800027ca <fork+0x8c>
  np->sz = p->sz;
    8000277e:	048ab783          	ld	a5,72(s5)
    80002782:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002786:	058ab683          	ld	a3,88(s5)
    8000278a:	87b6                	mv	a5,a3
    8000278c:	0589b703          	ld	a4,88(s3)
    80002790:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80002794:	0007b803          	ld	a6,0(a5)
    80002798:	6788                	ld	a0,8(a5)
    8000279a:	6b8c                	ld	a1,16(a5)
    8000279c:	6f90                	ld	a2,24(a5)
    8000279e:	01073023          	sd	a6,0(a4)
    800027a2:	e708                	sd	a0,8(a4)
    800027a4:	eb0c                	sd	a1,16(a4)
    800027a6:	ef10                	sd	a2,24(a4)
    800027a8:	02078793          	addi	a5,a5,32
    800027ac:	02070713          	addi	a4,a4,32
    800027b0:	fed792e3          	bne	a5,a3,80002794 <fork+0x56>
  np->trapframe->a0 = 0;
    800027b4:	0589b783          	ld	a5,88(s3)
    800027b8:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800027bc:	0d0a8493          	addi	s1,s5,208
    800027c0:	0d098913          	addi	s2,s3,208
    800027c4:	150a8a13          	addi	s4,s5,336
    800027c8:	a00d                	j	800027ea <fork+0xac>
    freeproc(np);
    800027ca:	854e                	mv	a0,s3
    800027cc:	fffff097          	auipc	ra,0xfffff
    800027d0:	380080e7          	jalr	896(ra) # 80001b4c <freeproc>
    release(&np->lock);
    800027d4:	854e                	mv	a0,s3
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	4a0080e7          	jalr	1184(ra) # 80000c76 <release>
    return -1;
    800027de:	597d                	li	s2,-1
    800027e0:	a075                	j	8000288c <fork+0x14e>
  for (i = 0; i < NOFILE; i++)
    800027e2:	04a1                	addi	s1,s1,8
    800027e4:	0921                	addi	s2,s2,8
    800027e6:	01448b63          	beq	s1,s4,800027fc <fork+0xbe>
    if (p->ofile[i])
    800027ea:	6088                	ld	a0,0(s1)
    800027ec:	d97d                	beqz	a0,800027e2 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800027ee:	00002097          	auipc	ra,0x2
    800027f2:	30a080e7          	jalr	778(ra) # 80004af8 <filedup>
    800027f6:	00a93023          	sd	a0,0(s2)
    800027fa:	b7e5                	j	800027e2 <fork+0xa4>
  np->cwd = idup(p->cwd);
    800027fc:	150ab503          	ld	a0,336(s5)
    80002800:	00001097          	auipc	ra,0x1
    80002804:	158080e7          	jalr	344(ra) # 80003958 <idup>
    80002808:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000280c:	4641                	li	a2,16
    8000280e:	158a8593          	addi	a1,s5,344
    80002812:	15898513          	addi	a0,s3,344
    80002816:	ffffe097          	auipc	ra,0xffffe
    8000281a:	5fa080e7          	jalr	1530(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    8000281e:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80002822:	854e                	mv	a0,s3
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	452080e7          	jalr	1106(ra) # 80000c76 <release>
  createSwapFile(np);
    8000282c:	854e                	mv	a0,s3
    8000282e:	00002097          	auipc	ra,0x2
    80002832:	b72080e7          	jalr	-1166(ra) # 800043a0 <createSwapFile>
  copySwap(p,np);
    80002836:	85ce                	mv	a1,s3
    80002838:	8556                	mv	a0,s5
    8000283a:	00000097          	auipc	ra,0x0
    8000283e:	e38080e7          	jalr	-456(ra) # 80002672 <copySwap>
  np->physical_pages_num = p->physical_pages_num;
    80002842:	170aa783          	lw	a5,368(s5)
    80002846:	16f9a823          	sw	a5,368(s3)
  np->total_pages_num = p->total_pages_num;
    8000284a:	174aa783          	lw	a5,372(s5)
    8000284e:	16f9aa23          	sw	a5,372(s3)
  acquire(&wait_lock);
    80002852:	0000f497          	auipc	s1,0xf
    80002856:	a6648493          	addi	s1,s1,-1434 # 800112b8 <wait_lock>
    8000285a:	8526                	mv	a0,s1
    8000285c:	ffffe097          	auipc	ra,0xffffe
    80002860:	366080e7          	jalr	870(ra) # 80000bc2 <acquire>
  np->parent = p;
    80002864:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	40c080e7          	jalr	1036(ra) # 80000c76 <release>
  acquire(&np->lock);
    80002872:	854e                	mv	a0,s3
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	34e080e7          	jalr	846(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    8000287c:	478d                	li	a5,3
    8000287e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002882:	854e                	mv	a0,s3
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	3f2080e7          	jalr	1010(ra) # 80000c76 <release>
}
    8000288c:	854a                	mv	a0,s2
    8000288e:	70e2                	ld	ra,56(sp)
    80002890:	7442                	ld	s0,48(sp)
    80002892:	74a2                	ld	s1,40(sp)
    80002894:	7902                	ld	s2,32(sp)
    80002896:	69e2                	ld	s3,24(sp)
    80002898:	6a42                	ld	s4,16(sp)
    8000289a:	6aa2                	ld	s5,8(sp)
    8000289c:	6121                	addi	sp,sp,64
    8000289e:	8082                	ret
    return -1;
    800028a0:	597d                	li	s2,-1
    800028a2:	b7ed                	j	8000288c <fork+0x14e>

00000000800028a4 <swtch>:
    800028a4:	00153023          	sd	ra,0(a0)
    800028a8:	00253423          	sd	sp,8(a0)
    800028ac:	e900                	sd	s0,16(a0)
    800028ae:	ed04                	sd	s1,24(a0)
    800028b0:	03253023          	sd	s2,32(a0)
    800028b4:	03353423          	sd	s3,40(a0)
    800028b8:	03453823          	sd	s4,48(a0)
    800028bc:	03553c23          	sd	s5,56(a0)
    800028c0:	05653023          	sd	s6,64(a0)
    800028c4:	05753423          	sd	s7,72(a0)
    800028c8:	05853823          	sd	s8,80(a0)
    800028cc:	05953c23          	sd	s9,88(a0)
    800028d0:	07a53023          	sd	s10,96(a0)
    800028d4:	07b53423          	sd	s11,104(a0)
    800028d8:	0005b083          	ld	ra,0(a1) # fffffffffffff000 <end+0xffffffff7ffd1000>
    800028dc:	0085b103          	ld	sp,8(a1)
    800028e0:	6980                	ld	s0,16(a1)
    800028e2:	6d84                	ld	s1,24(a1)
    800028e4:	0205b903          	ld	s2,32(a1)
    800028e8:	0285b983          	ld	s3,40(a1)
    800028ec:	0305ba03          	ld	s4,48(a1)
    800028f0:	0385ba83          	ld	s5,56(a1)
    800028f4:	0405bb03          	ld	s6,64(a1)
    800028f8:	0485bb83          	ld	s7,72(a1)
    800028fc:	0505bc03          	ld	s8,80(a1)
    80002900:	0585bc83          	ld	s9,88(a1)
    80002904:	0605bd03          	ld	s10,96(a1)
    80002908:	0685bd83          	ld	s11,104(a1)
    8000290c:	8082                	ret

000000008000290e <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000290e:	1141                	addi	sp,sp,-16
    80002910:	e406                	sd	ra,8(sp)
    80002912:	e022                	sd	s0,0(sp)
    80002914:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002916:	00006597          	auipc	a1,0x6
    8000291a:	b0a58593          	addi	a1,a1,-1270 # 80008420 <states.0+0x30>
    8000291e:	0001d517          	auipc	a0,0x1d
    80002922:	db250513          	addi	a0,a0,-590 # 8001f6d0 <tickslock>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	20c080e7          	jalr	524(ra) # 80000b32 <initlock>
}
    8000292e:	60a2                	ld	ra,8(sp)
    80002930:	6402                	ld	s0,0(sp)
    80002932:	0141                	addi	sp,sp,16
    80002934:	8082                	ret

0000000080002936 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002936:	1141                	addi	sp,sp,-16
    80002938:	e422                	sd	s0,8(sp)
    8000293a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000293c:	00004797          	auipc	a5,0x4
    80002940:	a5478793          	addi	a5,a5,-1452 # 80006390 <kernelvec>
    80002944:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002948:	6422                	ld	s0,8(sp)
    8000294a:	0141                	addi	sp,sp,16
    8000294c:	8082                	ret

000000008000294e <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000294e:	1141                	addi	sp,sp,-16
    80002950:	e406                	sd	ra,8(sp)
    80002952:	e022                	sd	s0,0(sp)
    80002954:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002956:	fffff097          	auipc	ra,0xfffff
    8000295a:	044080e7          	jalr	68(ra) # 8000199a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002962:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002964:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002968:	00004617          	auipc	a2,0x4
    8000296c:	69860613          	addi	a2,a2,1688 # 80007000 <_trampoline>
    80002970:	00004697          	auipc	a3,0x4
    80002974:	69068693          	addi	a3,a3,1680 # 80007000 <_trampoline>
    80002978:	8e91                	sub	a3,a3,a2
    8000297a:	040007b7          	lui	a5,0x4000
    8000297e:	17fd                	addi	a5,a5,-1
    80002980:	07b2                	slli	a5,a5,0xc
    80002982:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002984:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002988:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000298a:	180026f3          	csrr	a3,satp
    8000298e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002990:	6d38                	ld	a4,88(a0)
    80002992:	6134                	ld	a3,64(a0)
    80002994:	6585                	lui	a1,0x1
    80002996:	96ae                	add	a3,a3,a1
    80002998:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000299a:	6d38                	ld	a4,88(a0)
    8000299c:	00000697          	auipc	a3,0x0
    800029a0:	13868693          	addi	a3,a3,312 # 80002ad4 <usertrap>
    800029a4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029a6:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029a8:	8692                	mv	a3,tp
    800029aa:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ac:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029b0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029b4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029bc:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029be:	6f18                	ld	a4,24(a4)
    800029c0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029c4:	692c                	ld	a1,80(a0)
    800029c6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800029c8:	00004717          	auipc	a4,0x4
    800029cc:	6c870713          	addi	a4,a4,1736 # 80007090 <userret>
    800029d0:	8f11                	sub	a4,a4,a2
    800029d2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))fn)(TRAPFRAME, satp);
    800029d4:	577d                	li	a4,-1
    800029d6:	177e                	slli	a4,a4,0x3f
    800029d8:	8dd9                	or	a1,a1,a4
    800029da:	02000537          	lui	a0,0x2000
    800029de:	157d                	addi	a0,a0,-1
    800029e0:	0536                	slli	a0,a0,0xd
    800029e2:	9782                	jalr	a5
}
    800029e4:	60a2                	ld	ra,8(sp)
    800029e6:	6402                	ld	s0,0(sp)
    800029e8:	0141                	addi	sp,sp,16
    800029ea:	8082                	ret

00000000800029ec <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800029ec:	1101                	addi	sp,sp,-32
    800029ee:	ec06                	sd	ra,24(sp)
    800029f0:	e822                	sd	s0,16(sp)
    800029f2:	e426                	sd	s1,8(sp)
    800029f4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800029f6:	0001d497          	auipc	s1,0x1d
    800029fa:	cda48493          	addi	s1,s1,-806 # 8001f6d0 <tickslock>
    800029fe:	8526                	mv	a0,s1
    80002a00:	ffffe097          	auipc	ra,0xffffe
    80002a04:	1c2080e7          	jalr	450(ra) # 80000bc2 <acquire>
  ticks++;
    80002a08:	00006517          	auipc	a0,0x6
    80002a0c:	62850513          	addi	a0,a0,1576 # 80009030 <ticks>
    80002a10:	411c                	lw	a5,0(a0)
    80002a12:	2785                	addiw	a5,a5,1
    80002a14:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	698080e7          	jalr	1688(ra) # 800020ae <wakeup>
  release(&tickslock);
    80002a1e:	8526                	mv	a0,s1
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	256080e7          	jalr	598(ra) # 80000c76 <release>
}
    80002a28:	60e2                	ld	ra,24(sp)
    80002a2a:	6442                	ld	s0,16(sp)
    80002a2c:	64a2                	ld	s1,8(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret

0000000080002a32 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a32:	1101                	addi	sp,sp,-32
    80002a34:	ec06                	sd	ra,24(sp)
    80002a36:	e822                	sd	s0,16(sp)
    80002a38:	e426                	sd	s1,8(sp)
    80002a3a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a3c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002a40:	00074d63          	bltz	a4,80002a5a <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002a44:	57fd                	li	a5,-1
    80002a46:	17fe                	slli	a5,a5,0x3f
    80002a48:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002a4a:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a4c:	06f70363          	beq	a4,a5,80002ab2 <devintr+0x80>
  }
}
    80002a50:	60e2                	ld	ra,24(sp)
    80002a52:	6442                	ld	s0,16(sp)
    80002a54:	64a2                	ld	s1,8(sp)
    80002a56:	6105                	addi	sp,sp,32
    80002a58:	8082                	ret
      (scause & 0xff) == 9)
    80002a5a:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002a5e:	46a5                	li	a3,9
    80002a60:	fed792e3          	bne	a5,a3,80002a44 <devintr+0x12>
    int irq = plic_claim();
    80002a64:	00004097          	auipc	ra,0x4
    80002a68:	a34080e7          	jalr	-1484(ra) # 80006498 <plic_claim>
    80002a6c:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a6e:	47a9                	li	a5,10
    80002a70:	02f50763          	beq	a0,a5,80002a9e <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002a74:	4785                	li	a5,1
    80002a76:	02f50963          	beq	a0,a5,80002aa8 <devintr+0x76>
    return 1;
    80002a7a:	4505                	li	a0,1
    else if (irq)
    80002a7c:	d8f1                	beqz	s1,80002a50 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a7e:	85a6                	mv	a1,s1
    80002a80:	00006517          	auipc	a0,0x6
    80002a84:	9a850513          	addi	a0,a0,-1624 # 80008428 <states.0+0x38>
    80002a88:	ffffe097          	auipc	ra,0xffffe
    80002a8c:	aec080e7          	jalr	-1300(ra) # 80000574 <printf>
      plic_complete(irq);
    80002a90:	8526                	mv	a0,s1
    80002a92:	00004097          	auipc	ra,0x4
    80002a96:	a2a080e7          	jalr	-1494(ra) # 800064bc <plic_complete>
    return 1;
    80002a9a:	4505                	li	a0,1
    80002a9c:	bf55                	j	80002a50 <devintr+0x1e>
      uartintr();
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	ee8080e7          	jalr	-280(ra) # 80000986 <uartintr>
    80002aa6:	b7ed                	j	80002a90 <devintr+0x5e>
      virtio_disk_intr();
    80002aa8:	00004097          	auipc	ra,0x4
    80002aac:	ea6080e7          	jalr	-346(ra) # 8000694e <virtio_disk_intr>
    80002ab0:	b7c5                	j	80002a90 <devintr+0x5e>
    if (cpuid() == 0)
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	ebc080e7          	jalr	-324(ra) # 8000196e <cpuid>
    80002aba:	c901                	beqz	a0,80002aca <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002abc:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ac0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ac2:	14479073          	csrw	sip,a5
    return 2;
    80002ac6:	4509                	li	a0,2
    80002ac8:	b761                	j	80002a50 <devintr+0x1e>
      clockintr();
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	f22080e7          	jalr	-222(ra) # 800029ec <clockintr>
    80002ad2:	b7ed                	j	80002abc <devintr+0x8a>

0000000080002ad4 <usertrap>:
{
    80002ad4:	7179                	addi	sp,sp,-48
    80002ad6:	f406                	sd	ra,40(sp)
    80002ad8:	f022                	sd	s0,32(sp)
    80002ada:	ec26                	sd	s1,24(sp)
    80002adc:	e84a                	sd	s2,16(sp)
    80002ade:	e44e                	sd	s3,8(sp)
    80002ae0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae2:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ae6:	1007f793          	andi	a5,a5,256
    80002aea:	e3b9                	bnez	a5,80002b30 <usertrap+0x5c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aec:	00004797          	auipc	a5,0x4
    80002af0:	8a478793          	addi	a5,a5,-1884 # 80006390 <kernelvec>
    80002af4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	ea2080e7          	jalr	-350(ra) # 8000199a <myproc>
    80002b00:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b02:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b04:	14102773          	csrr	a4,sepc
    80002b08:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b0a:	142027f3          	csrr	a5,scause
  if (trap_cause == 8)
    80002b0e:	4721                	li	a4,8
    80002b10:	02e78863          	beq	a5,a4,80002b40 <usertrap+0x6c>
  else if (trap_cause == 13 || trap_cause == 15)
    80002b14:	9bf5                	andi	a5,a5,-3
    80002b16:	4735                	li	a4,13
    80002b18:	06e78763          	beq	a5,a4,80002b86 <usertrap+0xb2>
  else if ((which_dev = devintr()) != 0)
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	f16080e7          	jalr	-234(ra) # 80002a32 <devintr>
    80002b24:	892a                	mv	s2,a0
    80002b26:	c165                	beqz	a0,80002c06 <usertrap+0x132>
  if (p->killed)
    80002b28:	549c                	lw	a5,40(s1)
    80002b2a:	10078e63          	beqz	a5,80002c46 <usertrap+0x172>
    80002b2e:	a239                	j	80002c3c <usertrap+0x168>
    panic("usertrap: not from user mode");
    80002b30:	00006517          	auipc	a0,0x6
    80002b34:	91850513          	addi	a0,a0,-1768 # 80008448 <states.0+0x58>
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	9f2080e7          	jalr	-1550(ra) # 8000052a <panic>
    if (p->killed)
    80002b40:	551c                	lw	a5,40(a0)
    80002b42:	ef85                	bnez	a5,80002b7a <usertrap+0xa6>
    p->trapframe->epc += 4;
    80002b44:	6cb8                	ld	a4,88(s1)
    80002b46:	6f1c                	ld	a5,24(a4)
    80002b48:	0791                	addi	a5,a5,4
    80002b4a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b50:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b54:	10079073          	csrw	sstatus,a5
    syscall();
    80002b58:	00000097          	auipc	ra,0x0
    80002b5c:	340080e7          	jalr	832(ra) # 80002e98 <syscall>
  if (p->killed)
    80002b60:	549c                	lw	a5,40(s1)
    80002b62:	efe1                	bnez	a5,80002c3a <usertrap+0x166>
  usertrapret();
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	dea080e7          	jalr	-534(ra) # 8000294e <usertrapret>
}
    80002b6c:	70a2                	ld	ra,40(sp)
    80002b6e:	7402                	ld	s0,32(sp)
    80002b70:	64e2                	ld	s1,24(sp)
    80002b72:	6942                	ld	s2,16(sp)
    80002b74:	69a2                	ld	s3,8(sp)
    80002b76:	6145                	addi	sp,sp,48
    80002b78:	8082                	ret
      exit(-1);
    80002b7a:	557d                	li	a0,-1
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	602080e7          	jalr	1538(ra) # 8000217e <exit>
    80002b84:	b7c1                	j	80002b44 <usertrap+0x70>
    struct proc *p = myproc();
    80002b86:	fffff097          	auipc	ra,0xfffff
    80002b8a:	e14080e7          	jalr	-492(ra) # 8000199a <myproc>
    80002b8e:	892a                	mv	s2,a0
    printf("inside page fault usertrap\n"); //TODO delete
    80002b90:	00006517          	auipc	a0,0x6
    80002b94:	8d850513          	addi	a0,a0,-1832 # 80008468 <states.0+0x78>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9dc080e7          	jalr	-1572(ra) # 80000574 <printf>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ba0:	143029f3          	csrr	s3,stval
    uint64 fault_rva = PGROUNDDOWN(fault_va);
    80002ba4:	77fd                	lui	a5,0xfffff
    80002ba6:	00f9f9b3          	and	s3,s3,a5
    pte_t *pte = walk(p->pagetable, fault_rva ,0);
    80002baa:	4601                	li	a2,0
    80002bac:	85ce                	mv	a1,s3
    80002bae:	05093503          	ld	a0,80(s2)
    80002bb2:	ffffe097          	auipc	ra,0xffffe
    80002bb6:	3f4080e7          	jalr	1012(ra) # 80000fa6 <walk>
    if(!pte || p->pid<=2){//||SELECTION==0){
    80002bba:	c505                	beqz	a0,80002be2 <usertrap+0x10e>
    80002bbc:	03092703          	lw	a4,48(s2)
    80002bc0:	4789                	li	a5,2
    80002bc2:	02e7d063          	bge	a5,a4,80002be2 <usertrap+0x10e>
    else if(*pte & PTE_PG && !(*pte & PTE_V)){
    80002bc6:	611c                	ld	a5,0(a0)
    80002bc8:	2017f793          	andi	a5,a5,513
    80002bcc:	20000713          	li	a4,512
    80002bd0:	f8e798e3          	bne	a5,a4,80002b60 <usertrap+0x8c>
      pte_new = page_in(fault_rva, pte);
    80002bd4:	85aa                	mv	a1,a0
    80002bd6:	854e                	mv	a0,s3
    80002bd8:	00000097          	auipc	ra,0x0
    80002bdc:	9c2080e7          	jalr	-1598(ra) # 8000259a <page_in>
    80002be0:	b741                	j	80002b60 <usertrap+0x8c>
      printf("seg fault with pid=%d",p->pid);
    80002be2:	03092583          	lw	a1,48(s2)
    80002be6:	00006517          	auipc	a0,0x6
    80002bea:	8a250513          	addi	a0,a0,-1886 # 80008488 <states.0+0x98>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	986080e7          	jalr	-1658(ra) # 80000574 <printf>
      panic("segmentation fault oh nooooo");
    80002bf6:	00006517          	auipc	a0,0x6
    80002bfa:	8aa50513          	addi	a0,a0,-1878 # 800084a0 <states.0+0xb0>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	92c080e7          	jalr	-1748(ra) # 8000052a <panic>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c06:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c0a:	5890                	lw	a2,48(s1)
    80002c0c:	00006517          	auipc	a0,0x6
    80002c10:	8b450513          	addi	a0,a0,-1868 # 800084c0 <states.0+0xd0>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	960080e7          	jalr	-1696(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c20:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c24:	00006517          	auipc	a0,0x6
    80002c28:	8cc50513          	addi	a0,a0,-1844 # 800084f0 <states.0+0x100>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	948080e7          	jalr	-1720(ra) # 80000574 <printf>
    p->killed = 1;
    80002c34:	4785                	li	a5,1
    80002c36:	d49c                	sw	a5,40(s1)
  if (p->killed)
    80002c38:	a011                	j	80002c3c <usertrap+0x168>
    80002c3a:	4901                	li	s2,0
    exit(-1);
    80002c3c:	557d                	li	a0,-1
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	540080e7          	jalr	1344(ra) # 8000217e <exit>
  if (which_dev == 2)
    80002c46:	4789                	li	a5,2
    80002c48:	f0f91ee3          	bne	s2,a5,80002b64 <usertrap+0x90>
    yield();
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	29a080e7          	jalr	666(ra) # 80001ee6 <yield>
    80002c54:	bf01                	j	80002b64 <usertrap+0x90>

0000000080002c56 <kerneltrap>:
{
    80002c56:	7179                	addi	sp,sp,-48
    80002c58:	f406                	sd	ra,40(sp)
    80002c5a:	f022                	sd	s0,32(sp)
    80002c5c:	ec26                	sd	s1,24(sp)
    80002c5e:	e84a                	sd	s2,16(sp)
    80002c60:	e44e                	sd	s3,8(sp)
    80002c62:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c64:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c68:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c70:	1004f793          	andi	a5,s1,256
    80002c74:	cb85                	beqz	a5,80002ca4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c7a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c7c:	ef85                	bnez	a5,80002cb4 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	db4080e7          	jalr	-588(ra) # 80002a32 <devintr>
    80002c86:	cd1d                	beqz	a0,80002cc4 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c88:	4789                	li	a5,2
    80002c8a:	06f50a63          	beq	a0,a5,80002cfe <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c92:	10049073          	csrw	sstatus,s1
}
    80002c96:	70a2                	ld	ra,40(sp)
    80002c98:	7402                	ld	s0,32(sp)
    80002c9a:	64e2                	ld	s1,24(sp)
    80002c9c:	6942                	ld	s2,16(sp)
    80002c9e:	69a2                	ld	s3,8(sp)
    80002ca0:	6145                	addi	sp,sp,48
    80002ca2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ca4:	00006517          	auipc	a0,0x6
    80002ca8:	86c50513          	addi	a0,a0,-1940 # 80008510 <states.0+0x120>
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	87e080e7          	jalr	-1922(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002cb4:	00006517          	auipc	a0,0x6
    80002cb8:	88450513          	addi	a0,a0,-1916 # 80008538 <states.0+0x148>
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	86e080e7          	jalr	-1938(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002cc4:	85ce                	mv	a1,s3
    80002cc6:	00006517          	auipc	a0,0x6
    80002cca:	89250513          	addi	a0,a0,-1902 # 80008558 <states.0+0x168>
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	8a6080e7          	jalr	-1882(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cda:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cde:	00006517          	auipc	a0,0x6
    80002ce2:	88a50513          	addi	a0,a0,-1910 # 80008568 <states.0+0x178>
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	88e080e7          	jalr	-1906(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002cee:	00006517          	auipc	a0,0x6
    80002cf2:	89250513          	addi	a0,a0,-1902 # 80008580 <states.0+0x190>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	834080e7          	jalr	-1996(ra) # 8000052a <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	c9c080e7          	jalr	-868(ra) # 8000199a <myproc>
    80002d06:	d541                	beqz	a0,80002c8e <kerneltrap+0x38>
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	c92080e7          	jalr	-878(ra) # 8000199a <myproc>
    80002d10:	4d18                	lw	a4,24(a0)
    80002d12:	4791                	li	a5,4
    80002d14:	f6f71de3          	bne	a4,a5,80002c8e <kerneltrap+0x38>
    yield();
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	1ce080e7          	jalr	462(ra) # 80001ee6 <yield>
    80002d20:	b7bd                	j	80002c8e <kerneltrap+0x38>

0000000080002d22 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d22:	1101                	addi	sp,sp,-32
    80002d24:	ec06                	sd	ra,24(sp)
    80002d26:	e822                	sd	s0,16(sp)
    80002d28:	e426                	sd	s1,8(sp)
    80002d2a:	1000                	addi	s0,sp,32
    80002d2c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	c6c080e7          	jalr	-916(ra) # 8000199a <myproc>
  switch (n) {
    80002d36:	4795                	li	a5,5
    80002d38:	0497e163          	bltu	a5,s1,80002d7a <argraw+0x58>
    80002d3c:	048a                	slli	s1,s1,0x2
    80002d3e:	00006717          	auipc	a4,0x6
    80002d42:	87a70713          	addi	a4,a4,-1926 # 800085b8 <states.0+0x1c8>
    80002d46:	94ba                	add	s1,s1,a4
    80002d48:	409c                	lw	a5,0(s1)
    80002d4a:	97ba                	add	a5,a5,a4
    80002d4c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d4e:	6d3c                	ld	a5,88(a0)
    80002d50:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d52:	60e2                	ld	ra,24(sp)
    80002d54:	6442                	ld	s0,16(sp)
    80002d56:	64a2                	ld	s1,8(sp)
    80002d58:	6105                	addi	sp,sp,32
    80002d5a:	8082                	ret
    return p->trapframe->a1;
    80002d5c:	6d3c                	ld	a5,88(a0)
    80002d5e:	7fa8                	ld	a0,120(a5)
    80002d60:	bfcd                	j	80002d52 <argraw+0x30>
    return p->trapframe->a2;
    80002d62:	6d3c                	ld	a5,88(a0)
    80002d64:	63c8                	ld	a0,128(a5)
    80002d66:	b7f5                	j	80002d52 <argraw+0x30>
    return p->trapframe->a3;
    80002d68:	6d3c                	ld	a5,88(a0)
    80002d6a:	67c8                	ld	a0,136(a5)
    80002d6c:	b7dd                	j	80002d52 <argraw+0x30>
    return p->trapframe->a4;
    80002d6e:	6d3c                	ld	a5,88(a0)
    80002d70:	6bc8                	ld	a0,144(a5)
    80002d72:	b7c5                	j	80002d52 <argraw+0x30>
    return p->trapframe->a5;
    80002d74:	6d3c                	ld	a5,88(a0)
    80002d76:	6fc8                	ld	a0,152(a5)
    80002d78:	bfe9                	j	80002d52 <argraw+0x30>
  panic("argraw");
    80002d7a:	00006517          	auipc	a0,0x6
    80002d7e:	81650513          	addi	a0,a0,-2026 # 80008590 <states.0+0x1a0>
    80002d82:	ffffd097          	auipc	ra,0xffffd
    80002d86:	7a8080e7          	jalr	1960(ra) # 8000052a <panic>

0000000080002d8a <fetchaddr>:
{
    80002d8a:	1101                	addi	sp,sp,-32
    80002d8c:	ec06                	sd	ra,24(sp)
    80002d8e:	e822                	sd	s0,16(sp)
    80002d90:	e426                	sd	s1,8(sp)
    80002d92:	e04a                	sd	s2,0(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84aa                	mv	s1,a0
    80002d98:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d9a:	fffff097          	auipc	ra,0xfffff
    80002d9e:	c00080e7          	jalr	-1024(ra) # 8000199a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002da2:	653c                	ld	a5,72(a0)
    80002da4:	02f4f863          	bgeu	s1,a5,80002dd4 <fetchaddr+0x4a>
    80002da8:	00848713          	addi	a4,s1,8
    80002dac:	02e7e663          	bltu	a5,a4,80002dd8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002db0:	46a1                	li	a3,8
    80002db2:	8626                	mv	a2,s1
    80002db4:	85ca                	mv	a1,s2
    80002db6:	6928                	ld	a0,80(a0)
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	92a080e7          	jalr	-1750(ra) # 800016e2 <copyin>
    80002dc0:	00a03533          	snez	a0,a0
    80002dc4:	40a00533          	neg	a0,a0
}
    80002dc8:	60e2                	ld	ra,24(sp)
    80002dca:	6442                	ld	s0,16(sp)
    80002dcc:	64a2                	ld	s1,8(sp)
    80002dce:	6902                	ld	s2,0(sp)
    80002dd0:	6105                	addi	sp,sp,32
    80002dd2:	8082                	ret
    return -1;
    80002dd4:	557d                	li	a0,-1
    80002dd6:	bfcd                	j	80002dc8 <fetchaddr+0x3e>
    80002dd8:	557d                	li	a0,-1
    80002dda:	b7fd                	j	80002dc8 <fetchaddr+0x3e>

0000000080002ddc <fetchstr>:
{
    80002ddc:	7179                	addi	sp,sp,-48
    80002dde:	f406                	sd	ra,40(sp)
    80002de0:	f022                	sd	s0,32(sp)
    80002de2:	ec26                	sd	s1,24(sp)
    80002de4:	e84a                	sd	s2,16(sp)
    80002de6:	e44e                	sd	s3,8(sp)
    80002de8:	1800                	addi	s0,sp,48
    80002dea:	892a                	mv	s2,a0
    80002dec:	84ae                	mv	s1,a1
    80002dee:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002df0:	fffff097          	auipc	ra,0xfffff
    80002df4:	baa080e7          	jalr	-1110(ra) # 8000199a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002df8:	86ce                	mv	a3,s3
    80002dfa:	864a                	mv	a2,s2
    80002dfc:	85a6                	mv	a1,s1
    80002dfe:	6928                	ld	a0,80(a0)
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	972080e7          	jalr	-1678(ra) # 80001772 <copyinstr>
  if(err < 0)
    80002e08:	00054763          	bltz	a0,80002e16 <fetchstr+0x3a>
  return strlen(buf);
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	ffffe097          	auipc	ra,0xffffe
    80002e12:	034080e7          	jalr	52(ra) # 80000e42 <strlen>
}
    80002e16:	70a2                	ld	ra,40(sp)
    80002e18:	7402                	ld	s0,32(sp)
    80002e1a:	64e2                	ld	s1,24(sp)
    80002e1c:	6942                	ld	s2,16(sp)
    80002e1e:	69a2                	ld	s3,8(sp)
    80002e20:	6145                	addi	sp,sp,48
    80002e22:	8082                	ret

0000000080002e24 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	e426                	sd	s1,8(sp)
    80002e2c:	1000                	addi	s0,sp,32
    80002e2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	ef2080e7          	jalr	-270(ra) # 80002d22 <argraw>
    80002e38:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e3a:	4501                	li	a0,0
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	64a2                	ld	s1,8(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e46:	1101                	addi	sp,sp,-32
    80002e48:	ec06                	sd	ra,24(sp)
    80002e4a:	e822                	sd	s0,16(sp)
    80002e4c:	e426                	sd	s1,8(sp)
    80002e4e:	1000                	addi	s0,sp,32
    80002e50:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e52:	00000097          	auipc	ra,0x0
    80002e56:	ed0080e7          	jalr	-304(ra) # 80002d22 <argraw>
    80002e5a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e5c:	4501                	li	a0,0
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6105                	addi	sp,sp,32
    80002e66:	8082                	ret

0000000080002e68 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	e426                	sd	s1,8(sp)
    80002e70:	e04a                	sd	s2,0(sp)
    80002e72:	1000                	addi	s0,sp,32
    80002e74:	84ae                	mv	s1,a1
    80002e76:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e78:	00000097          	auipc	ra,0x0
    80002e7c:	eaa080e7          	jalr	-342(ra) # 80002d22 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e80:	864a                	mv	a2,s2
    80002e82:	85a6                	mv	a1,s1
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	f58080e7          	jalr	-168(ra) # 80002ddc <fetchstr>
}
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	64a2                	ld	s1,8(sp)
    80002e92:	6902                	ld	s2,0(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002e98:	1101                	addi	sp,sp,-32
    80002e9a:	ec06                	sd	ra,24(sp)
    80002e9c:	e822                	sd	s0,16(sp)
    80002e9e:	e426                	sd	s1,8(sp)
    80002ea0:	e04a                	sd	s2,0(sp)
    80002ea2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ea4:	fffff097          	auipc	ra,0xfffff
    80002ea8:	af6080e7          	jalr	-1290(ra) # 8000199a <myproc>
    80002eac:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002eae:	05853903          	ld	s2,88(a0)
    80002eb2:	0a893783          	ld	a5,168(s2)
    80002eb6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eba:	37fd                	addiw	a5,a5,-1
    80002ebc:	4751                	li	a4,20
    80002ebe:	00f76f63          	bltu	a4,a5,80002edc <syscall+0x44>
    80002ec2:	00369713          	slli	a4,a3,0x3
    80002ec6:	00005797          	auipc	a5,0x5
    80002eca:	70a78793          	addi	a5,a5,1802 # 800085d0 <syscalls>
    80002ece:	97ba                	add	a5,a5,a4
    80002ed0:	639c                	ld	a5,0(a5)
    80002ed2:	c789                	beqz	a5,80002edc <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ed4:	9782                	jalr	a5
    80002ed6:	06a93823          	sd	a0,112(s2)
    80002eda:	a839                	j	80002ef8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002edc:	15848613          	addi	a2,s1,344
    80002ee0:	588c                	lw	a1,48(s1)
    80002ee2:	00005517          	auipc	a0,0x5
    80002ee6:	6b650513          	addi	a0,a0,1718 # 80008598 <states.0+0x1a8>
    80002eea:	ffffd097          	auipc	ra,0xffffd
    80002eee:	68a080e7          	jalr	1674(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ef2:	6cbc                	ld	a5,88(s1)
    80002ef4:	577d                	li	a4,-1
    80002ef6:	fbb8                	sd	a4,112(a5)
  }
}
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6902                	ld	s2,0(sp)
    80002f00:	6105                	addi	sp,sp,32
    80002f02:	8082                	ret

0000000080002f04 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f04:	1101                	addi	sp,sp,-32
    80002f06:	ec06                	sd	ra,24(sp)
    80002f08:	e822                	sd	s0,16(sp)
    80002f0a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f0c:	fec40593          	addi	a1,s0,-20
    80002f10:	4501                	li	a0,0
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	f12080e7          	jalr	-238(ra) # 80002e24 <argint>
    return -1;
    80002f1a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f1c:	00054963          	bltz	a0,80002f2e <sys_exit+0x2a>
  exit(n);
    80002f20:	fec42503          	lw	a0,-20(s0)
    80002f24:	fffff097          	auipc	ra,0xfffff
    80002f28:	25a080e7          	jalr	602(ra) # 8000217e <exit>
  return 0;  // not reached
    80002f2c:	4781                	li	a5,0
}
    80002f2e:	853e                	mv	a0,a5
    80002f30:	60e2                	ld	ra,24(sp)
    80002f32:	6442                	ld	s0,16(sp)
    80002f34:	6105                	addi	sp,sp,32
    80002f36:	8082                	ret

0000000080002f38 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f38:	1141                	addi	sp,sp,-16
    80002f3a:	e406                	sd	ra,8(sp)
    80002f3c:	e022                	sd	s0,0(sp)
    80002f3e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	a5a080e7          	jalr	-1446(ra) # 8000199a <myproc>
}
    80002f48:	5908                	lw	a0,48(a0)
    80002f4a:	60a2                	ld	ra,8(sp)
    80002f4c:	6402                	ld	s0,0(sp)
    80002f4e:	0141                	addi	sp,sp,16
    80002f50:	8082                	ret

0000000080002f52 <sys_fork>:

uint64
sys_fork(void)
{
    80002f52:	1141                	addi	sp,sp,-16
    80002f54:	e406                	sd	ra,8(sp)
    80002f56:	e022                	sd	s0,0(sp)
    80002f58:	0800                	addi	s0,sp,16
  return fork();
    80002f5a:	fffff097          	auipc	ra,0xfffff
    80002f5e:	7e4080e7          	jalr	2020(ra) # 8000273e <fork>
}
    80002f62:	60a2                	ld	ra,8(sp)
    80002f64:	6402                	ld	s0,0(sp)
    80002f66:	0141                	addi	sp,sp,16
    80002f68:	8082                	ret

0000000080002f6a <sys_wait>:

uint64
sys_wait(void)
{
    80002f6a:	1101                	addi	sp,sp,-32
    80002f6c:	ec06                	sd	ra,24(sp)
    80002f6e:	e822                	sd	s0,16(sp)
    80002f70:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f72:	fe840593          	addi	a1,s0,-24
    80002f76:	4501                	li	a0,0
    80002f78:	00000097          	auipc	ra,0x0
    80002f7c:	ece080e7          	jalr	-306(ra) # 80002e46 <argaddr>
    80002f80:	87aa                	mv	a5,a0
    return -1;
    80002f82:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f84:	0007c863          	bltz	a5,80002f94 <sys_wait+0x2a>
  return wait(p);
    80002f88:	fe843503          	ld	a0,-24(s0)
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	ffa080e7          	jalr	-6(ra) # 80001f86 <wait>
}
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	6105                	addi	sp,sp,32
    80002f9a:	8082                	ret

0000000080002f9c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f9c:	7179                	addi	sp,sp,-48
    80002f9e:	f406                	sd	ra,40(sp)
    80002fa0:	f022                	sd	s0,32(sp)
    80002fa2:	ec26                	sd	s1,24(sp)
    80002fa4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002fa6:	fdc40593          	addi	a1,s0,-36
    80002faa:	4501                	li	a0,0
    80002fac:	00000097          	auipc	ra,0x0
    80002fb0:	e78080e7          	jalr	-392(ra) # 80002e24 <argint>
    return -1;
    80002fb4:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002fb6:	00054f63          	bltz	a0,80002fd4 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002fba:	fffff097          	auipc	ra,0xfffff
    80002fbe:	9e0080e7          	jalr	-1568(ra) # 8000199a <myproc>
    80002fc2:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002fc4:	fdc42503          	lw	a0,-36(s0)
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	d34080e7          	jalr	-716(ra) # 80001cfc <growproc>
    80002fd0:	00054863          	bltz	a0,80002fe0 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fd4:	8526                	mv	a0,s1
    80002fd6:	70a2                	ld	ra,40(sp)
    80002fd8:	7402                	ld	s0,32(sp)
    80002fda:	64e2                	ld	s1,24(sp)
    80002fdc:	6145                	addi	sp,sp,48
    80002fde:	8082                	ret
    return -1;
    80002fe0:	54fd                	li	s1,-1
    80002fe2:	bfcd                	j	80002fd4 <sys_sbrk+0x38>

0000000080002fe4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fe4:	7139                	addi	sp,sp,-64
    80002fe6:	fc06                	sd	ra,56(sp)
    80002fe8:	f822                	sd	s0,48(sp)
    80002fea:	f426                	sd	s1,40(sp)
    80002fec:	f04a                	sd	s2,32(sp)
    80002fee:	ec4e                	sd	s3,24(sp)
    80002ff0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ff2:	fcc40593          	addi	a1,s0,-52
    80002ff6:	4501                	li	a0,0
    80002ff8:	00000097          	auipc	ra,0x0
    80002ffc:	e2c080e7          	jalr	-468(ra) # 80002e24 <argint>
    return -1;
    80003000:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003002:	06054563          	bltz	a0,8000306c <sys_sleep+0x88>
  acquire(&tickslock);
    80003006:	0001c517          	auipc	a0,0x1c
    8000300a:	6ca50513          	addi	a0,a0,1738 # 8001f6d0 <tickslock>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	bb4080e7          	jalr	-1100(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003016:	00006917          	auipc	s2,0x6
    8000301a:	01a92903          	lw	s2,26(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    8000301e:	fcc42783          	lw	a5,-52(s0)
    80003022:	cf85                	beqz	a5,8000305a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003024:	0001c997          	auipc	s3,0x1c
    80003028:	6ac98993          	addi	s3,s3,1708 # 8001f6d0 <tickslock>
    8000302c:	00006497          	auipc	s1,0x6
    80003030:	00448493          	addi	s1,s1,4 # 80009030 <ticks>
    if(myproc()->killed){
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	966080e7          	jalr	-1690(ra) # 8000199a <myproc>
    8000303c:	551c                	lw	a5,40(a0)
    8000303e:	ef9d                	bnez	a5,8000307c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003040:	85ce                	mv	a1,s3
    80003042:	8526                	mv	a0,s1
    80003044:	fffff097          	auipc	ra,0xfffff
    80003048:	ede080e7          	jalr	-290(ra) # 80001f22 <sleep>
  while(ticks - ticks0 < n){
    8000304c:	409c                	lw	a5,0(s1)
    8000304e:	412787bb          	subw	a5,a5,s2
    80003052:	fcc42703          	lw	a4,-52(s0)
    80003056:	fce7efe3          	bltu	a5,a4,80003034 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000305a:	0001c517          	auipc	a0,0x1c
    8000305e:	67650513          	addi	a0,a0,1654 # 8001f6d0 <tickslock>
    80003062:	ffffe097          	auipc	ra,0xffffe
    80003066:	c14080e7          	jalr	-1004(ra) # 80000c76 <release>
  return 0;
    8000306a:	4781                	li	a5,0
}
    8000306c:	853e                	mv	a0,a5
    8000306e:	70e2                	ld	ra,56(sp)
    80003070:	7442                	ld	s0,48(sp)
    80003072:	74a2                	ld	s1,40(sp)
    80003074:	7902                	ld	s2,32(sp)
    80003076:	69e2                	ld	s3,24(sp)
    80003078:	6121                	addi	sp,sp,64
    8000307a:	8082                	ret
      release(&tickslock);
    8000307c:	0001c517          	auipc	a0,0x1c
    80003080:	65450513          	addi	a0,a0,1620 # 8001f6d0 <tickslock>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	bf2080e7          	jalr	-1038(ra) # 80000c76 <release>
      return -1;
    8000308c:	57fd                	li	a5,-1
    8000308e:	bff9                	j	8000306c <sys_sleep+0x88>

0000000080003090 <sys_kill>:

uint64
sys_kill(void)
{
    80003090:	1101                	addi	sp,sp,-32
    80003092:	ec06                	sd	ra,24(sp)
    80003094:	e822                	sd	s0,16(sp)
    80003096:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003098:	fec40593          	addi	a1,s0,-20
    8000309c:	4501                	li	a0,0
    8000309e:	00000097          	auipc	ra,0x0
    800030a2:	d86080e7          	jalr	-634(ra) # 80002e24 <argint>
    800030a6:	87aa                	mv	a5,a0
    return -1;
    800030a8:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030aa:	0007c863          	bltz	a5,800030ba <sys_kill+0x2a>
  return kill(pid);
    800030ae:	fec42503          	lw	a0,-20(s0)
    800030b2:	fffff097          	auipc	ra,0xfffff
    800030b6:	1a2080e7          	jalr	418(ra) # 80002254 <kill>
}
    800030ba:	60e2                	ld	ra,24(sp)
    800030bc:	6442                	ld	s0,16(sp)
    800030be:	6105                	addi	sp,sp,32
    800030c0:	8082                	ret

00000000800030c2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030c2:	1101                	addi	sp,sp,-32
    800030c4:	ec06                	sd	ra,24(sp)
    800030c6:	e822                	sd	s0,16(sp)
    800030c8:	e426                	sd	s1,8(sp)
    800030ca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030cc:	0001c517          	auipc	a0,0x1c
    800030d0:	60450513          	addi	a0,a0,1540 # 8001f6d0 <tickslock>
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	aee080e7          	jalr	-1298(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800030dc:	00006497          	auipc	s1,0x6
    800030e0:	f544a483          	lw	s1,-172(s1) # 80009030 <ticks>
  release(&tickslock);
    800030e4:	0001c517          	auipc	a0,0x1c
    800030e8:	5ec50513          	addi	a0,a0,1516 # 8001f6d0 <tickslock>
    800030ec:	ffffe097          	auipc	ra,0xffffe
    800030f0:	b8a080e7          	jalr	-1142(ra) # 80000c76 <release>
  return xticks;
}
    800030f4:	02049513          	slli	a0,s1,0x20
    800030f8:	9101                	srli	a0,a0,0x20
    800030fa:	60e2                	ld	ra,24(sp)
    800030fc:	6442                	ld	s0,16(sp)
    800030fe:	64a2                	ld	s1,8(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003104:	7179                	addi	sp,sp,-48
    80003106:	f406                	sd	ra,40(sp)
    80003108:	f022                	sd	s0,32(sp)
    8000310a:	ec26                	sd	s1,24(sp)
    8000310c:	e84a                	sd	s2,16(sp)
    8000310e:	e44e                	sd	s3,8(sp)
    80003110:	e052                	sd	s4,0(sp)
    80003112:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003114:	00005597          	auipc	a1,0x5
    80003118:	56c58593          	addi	a1,a1,1388 # 80008680 <syscalls+0xb0>
    8000311c:	0001c517          	auipc	a0,0x1c
    80003120:	5cc50513          	addi	a0,a0,1484 # 8001f6e8 <bcache>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	a0e080e7          	jalr	-1522(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000312c:	00024797          	auipc	a5,0x24
    80003130:	5bc78793          	addi	a5,a5,1468 # 800276e8 <bcache+0x8000>
    80003134:	00025717          	auipc	a4,0x25
    80003138:	81c70713          	addi	a4,a4,-2020 # 80027950 <bcache+0x8268>
    8000313c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003140:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003144:	0001c497          	auipc	s1,0x1c
    80003148:	5bc48493          	addi	s1,s1,1468 # 8001f700 <bcache+0x18>
    b->next = bcache.head.next;
    8000314c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000314e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003150:	00005a17          	auipc	s4,0x5
    80003154:	538a0a13          	addi	s4,s4,1336 # 80008688 <syscalls+0xb8>
    b->next = bcache.head.next;
    80003158:	2b893783          	ld	a5,696(s2)
    8000315c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000315e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003162:	85d2                	mv	a1,s4
    80003164:	01048513          	addi	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	7d4080e7          	jalr	2004(ra) # 8000493c <initsleeplock>
    bcache.head.next->prev = b;
    80003170:	2b893783          	ld	a5,696(s2)
    80003174:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003176:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000317a:	45848493          	addi	s1,s1,1112
    8000317e:	fd349de3          	bne	s1,s3,80003158 <binit+0x54>
  }
}
    80003182:	70a2                	ld	ra,40(sp)
    80003184:	7402                	ld	s0,32(sp)
    80003186:	64e2                	ld	s1,24(sp)
    80003188:	6942                	ld	s2,16(sp)
    8000318a:	69a2                	ld	s3,8(sp)
    8000318c:	6a02                	ld	s4,0(sp)
    8000318e:	6145                	addi	sp,sp,48
    80003190:	8082                	ret

0000000080003192 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003192:	7179                	addi	sp,sp,-48
    80003194:	f406                	sd	ra,40(sp)
    80003196:	f022                	sd	s0,32(sp)
    80003198:	ec26                	sd	s1,24(sp)
    8000319a:	e84a                	sd	s2,16(sp)
    8000319c:	e44e                	sd	s3,8(sp)
    8000319e:	1800                	addi	s0,sp,48
    800031a0:	892a                	mv	s2,a0
    800031a2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031a4:	0001c517          	auipc	a0,0x1c
    800031a8:	54450513          	addi	a0,a0,1348 # 8001f6e8 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	a16080e7          	jalr	-1514(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031b4:	00024497          	auipc	s1,0x24
    800031b8:	7ec4b483          	ld	s1,2028(s1) # 800279a0 <bcache+0x82b8>
    800031bc:	00024797          	auipc	a5,0x24
    800031c0:	79478793          	addi	a5,a5,1940 # 80027950 <bcache+0x8268>
    800031c4:	02f48f63          	beq	s1,a5,80003202 <bread+0x70>
    800031c8:	873e                	mv	a4,a5
    800031ca:	a021                	j	800031d2 <bread+0x40>
    800031cc:	68a4                	ld	s1,80(s1)
    800031ce:	02e48a63          	beq	s1,a4,80003202 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031d2:	449c                	lw	a5,8(s1)
    800031d4:	ff279ce3          	bne	a5,s2,800031cc <bread+0x3a>
    800031d8:	44dc                	lw	a5,12(s1)
    800031da:	ff3799e3          	bne	a5,s3,800031cc <bread+0x3a>
      b->refcnt++;
    800031de:	40bc                	lw	a5,64(s1)
    800031e0:	2785                	addiw	a5,a5,1
    800031e2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031e4:	0001c517          	auipc	a0,0x1c
    800031e8:	50450513          	addi	a0,a0,1284 # 8001f6e8 <bcache>
    800031ec:	ffffe097          	auipc	ra,0xffffe
    800031f0:	a8a080e7          	jalr	-1398(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800031f4:	01048513          	addi	a0,s1,16
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	77e080e7          	jalr	1918(ra) # 80004976 <acquiresleep>
      return b;
    80003200:	a8b9                	j	8000325e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003202:	00024497          	auipc	s1,0x24
    80003206:	7964b483          	ld	s1,1942(s1) # 80027998 <bcache+0x82b0>
    8000320a:	00024797          	auipc	a5,0x24
    8000320e:	74678793          	addi	a5,a5,1862 # 80027950 <bcache+0x8268>
    80003212:	00f48863          	beq	s1,a5,80003222 <bread+0x90>
    80003216:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003218:	40bc                	lw	a5,64(s1)
    8000321a:	cf81                	beqz	a5,80003232 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000321c:	64a4                	ld	s1,72(s1)
    8000321e:	fee49de3          	bne	s1,a4,80003218 <bread+0x86>
  panic("bget: no buffers");
    80003222:	00005517          	auipc	a0,0x5
    80003226:	46e50513          	addi	a0,a0,1134 # 80008690 <syscalls+0xc0>
    8000322a:	ffffd097          	auipc	ra,0xffffd
    8000322e:	300080e7          	jalr	768(ra) # 8000052a <panic>
      b->dev = dev;
    80003232:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003236:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000323a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000323e:	4785                	li	a5,1
    80003240:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003242:	0001c517          	auipc	a0,0x1c
    80003246:	4a650513          	addi	a0,a0,1190 # 8001f6e8 <bcache>
    8000324a:	ffffe097          	auipc	ra,0xffffe
    8000324e:	a2c080e7          	jalr	-1492(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    80003252:	01048513          	addi	a0,s1,16
    80003256:	00001097          	auipc	ra,0x1
    8000325a:	720080e7          	jalr	1824(ra) # 80004976 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000325e:	409c                	lw	a5,0(s1)
    80003260:	cb89                	beqz	a5,80003272 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003262:	8526                	mv	a0,s1
    80003264:	70a2                	ld	ra,40(sp)
    80003266:	7402                	ld	s0,32(sp)
    80003268:	64e2                	ld	s1,24(sp)
    8000326a:	6942                	ld	s2,16(sp)
    8000326c:	69a2                	ld	s3,8(sp)
    8000326e:	6145                	addi	sp,sp,48
    80003270:	8082                	ret
    virtio_disk_rw(b, 0);
    80003272:	4581                	li	a1,0
    80003274:	8526                	mv	a0,s1
    80003276:	00003097          	auipc	ra,0x3
    8000327a:	450080e7          	jalr	1104(ra) # 800066c6 <virtio_disk_rw>
    b->valid = 1;
    8000327e:	4785                	li	a5,1
    80003280:	c09c                	sw	a5,0(s1)
  return b;
    80003282:	b7c5                	j	80003262 <bread+0xd0>

0000000080003284 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003284:	1101                	addi	sp,sp,-32
    80003286:	ec06                	sd	ra,24(sp)
    80003288:	e822                	sd	s0,16(sp)
    8000328a:	e426                	sd	s1,8(sp)
    8000328c:	1000                	addi	s0,sp,32
    8000328e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003290:	0541                	addi	a0,a0,16
    80003292:	00001097          	auipc	ra,0x1
    80003296:	77e080e7          	jalr	1918(ra) # 80004a10 <holdingsleep>
    8000329a:	cd01                	beqz	a0,800032b2 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000329c:	4585                	li	a1,1
    8000329e:	8526                	mv	a0,s1
    800032a0:	00003097          	auipc	ra,0x3
    800032a4:	426080e7          	jalr	1062(ra) # 800066c6 <virtio_disk_rw>
}
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6105                	addi	sp,sp,32
    800032b0:	8082                	ret
    panic("bwrite");
    800032b2:	00005517          	auipc	a0,0x5
    800032b6:	3f650513          	addi	a0,a0,1014 # 800086a8 <syscalls+0xd8>
    800032ba:	ffffd097          	auipc	ra,0xffffd
    800032be:	270080e7          	jalr	624(ra) # 8000052a <panic>

00000000800032c2 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032c2:	1101                	addi	sp,sp,-32
    800032c4:	ec06                	sd	ra,24(sp)
    800032c6:	e822                	sd	s0,16(sp)
    800032c8:	e426                	sd	s1,8(sp)
    800032ca:	e04a                	sd	s2,0(sp)
    800032cc:	1000                	addi	s0,sp,32
    800032ce:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032d0:	01050913          	addi	s2,a0,16
    800032d4:	854a                	mv	a0,s2
    800032d6:	00001097          	auipc	ra,0x1
    800032da:	73a080e7          	jalr	1850(ra) # 80004a10 <holdingsleep>
    800032de:	c92d                	beqz	a0,80003350 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032e0:	854a                	mv	a0,s2
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	6ea080e7          	jalr	1770(ra) # 800049cc <releasesleep>

  acquire(&bcache.lock);
    800032ea:	0001c517          	auipc	a0,0x1c
    800032ee:	3fe50513          	addi	a0,a0,1022 # 8001f6e8 <bcache>
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	8d0080e7          	jalr	-1840(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800032fa:	40bc                	lw	a5,64(s1)
    800032fc:	37fd                	addiw	a5,a5,-1
    800032fe:	0007871b          	sext.w	a4,a5
    80003302:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003304:	eb05                	bnez	a4,80003334 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003306:	68bc                	ld	a5,80(s1)
    80003308:	64b8                	ld	a4,72(s1)
    8000330a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000330c:	64bc                	ld	a5,72(s1)
    8000330e:	68b8                	ld	a4,80(s1)
    80003310:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003312:	00024797          	auipc	a5,0x24
    80003316:	3d678793          	addi	a5,a5,982 # 800276e8 <bcache+0x8000>
    8000331a:	2b87b703          	ld	a4,696(a5)
    8000331e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003320:	00024717          	auipc	a4,0x24
    80003324:	63070713          	addi	a4,a4,1584 # 80027950 <bcache+0x8268>
    80003328:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000332a:	2b87b703          	ld	a4,696(a5)
    8000332e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003330:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003334:	0001c517          	auipc	a0,0x1c
    80003338:	3b450513          	addi	a0,a0,948 # 8001f6e8 <bcache>
    8000333c:	ffffe097          	auipc	ra,0xffffe
    80003340:	93a080e7          	jalr	-1734(ra) # 80000c76 <release>
}
    80003344:	60e2                	ld	ra,24(sp)
    80003346:	6442                	ld	s0,16(sp)
    80003348:	64a2                	ld	s1,8(sp)
    8000334a:	6902                	ld	s2,0(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret
    panic("brelse");
    80003350:	00005517          	auipc	a0,0x5
    80003354:	36050513          	addi	a0,a0,864 # 800086b0 <syscalls+0xe0>
    80003358:	ffffd097          	auipc	ra,0xffffd
    8000335c:	1d2080e7          	jalr	466(ra) # 8000052a <panic>

0000000080003360 <bpin>:

void
bpin(struct buf *b) {
    80003360:	1101                	addi	sp,sp,-32
    80003362:	ec06                	sd	ra,24(sp)
    80003364:	e822                	sd	s0,16(sp)
    80003366:	e426                	sd	s1,8(sp)
    80003368:	1000                	addi	s0,sp,32
    8000336a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000336c:	0001c517          	auipc	a0,0x1c
    80003370:	37c50513          	addi	a0,a0,892 # 8001f6e8 <bcache>
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	84e080e7          	jalr	-1970(ra) # 80000bc2 <acquire>
  b->refcnt++;
    8000337c:	40bc                	lw	a5,64(s1)
    8000337e:	2785                	addiw	a5,a5,1
    80003380:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003382:	0001c517          	auipc	a0,0x1c
    80003386:	36650513          	addi	a0,a0,870 # 8001f6e8 <bcache>
    8000338a:	ffffe097          	auipc	ra,0xffffe
    8000338e:	8ec080e7          	jalr	-1812(ra) # 80000c76 <release>
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	64a2                	ld	s1,8(sp)
    80003398:	6105                	addi	sp,sp,32
    8000339a:	8082                	ret

000000008000339c <bunpin>:

void
bunpin(struct buf *b) {
    8000339c:	1101                	addi	sp,sp,-32
    8000339e:	ec06                	sd	ra,24(sp)
    800033a0:	e822                	sd	s0,16(sp)
    800033a2:	e426                	sd	s1,8(sp)
    800033a4:	1000                	addi	s0,sp,32
    800033a6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033a8:	0001c517          	auipc	a0,0x1c
    800033ac:	34050513          	addi	a0,a0,832 # 8001f6e8 <bcache>
    800033b0:	ffffe097          	auipc	ra,0xffffe
    800033b4:	812080e7          	jalr	-2030(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800033b8:	40bc                	lw	a5,64(s1)
    800033ba:	37fd                	addiw	a5,a5,-1
    800033bc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033be:	0001c517          	auipc	a0,0x1c
    800033c2:	32a50513          	addi	a0,a0,810 # 8001f6e8 <bcache>
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	8b0080e7          	jalr	-1872(ra) # 80000c76 <release>
}
    800033ce:	60e2                	ld	ra,24(sp)
    800033d0:	6442                	ld	s0,16(sp)
    800033d2:	64a2                	ld	s1,8(sp)
    800033d4:	6105                	addi	sp,sp,32
    800033d6:	8082                	ret

00000000800033d8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033d8:	1101                	addi	sp,sp,-32
    800033da:	ec06                	sd	ra,24(sp)
    800033dc:	e822                	sd	s0,16(sp)
    800033de:	e426                	sd	s1,8(sp)
    800033e0:	e04a                	sd	s2,0(sp)
    800033e2:	1000                	addi	s0,sp,32
    800033e4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033e6:	00d5d59b          	srliw	a1,a1,0xd
    800033ea:	00025797          	auipc	a5,0x25
    800033ee:	9da7a783          	lw	a5,-1574(a5) # 80027dc4 <sb+0x1c>
    800033f2:	9dbd                	addw	a1,a1,a5
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	d9e080e7          	jalr	-610(ra) # 80003192 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033fc:	0074f713          	andi	a4,s1,7
    80003400:	4785                	li	a5,1
    80003402:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003406:	14ce                	slli	s1,s1,0x33
    80003408:	90d9                	srli	s1,s1,0x36
    8000340a:	00950733          	add	a4,a0,s1
    8000340e:	05874703          	lbu	a4,88(a4)
    80003412:	00e7f6b3          	and	a3,a5,a4
    80003416:	c69d                	beqz	a3,80003444 <bfree+0x6c>
    80003418:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000341a:	94aa                	add	s1,s1,a0
    8000341c:	fff7c793          	not	a5,a5
    80003420:	8ff9                	and	a5,a5,a4
    80003422:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003426:	00001097          	auipc	ra,0x1
    8000342a:	430080e7          	jalr	1072(ra) # 80004856 <log_write>
  brelse(bp);
    8000342e:	854a                	mv	a0,s2
    80003430:	00000097          	auipc	ra,0x0
    80003434:	e92080e7          	jalr	-366(ra) # 800032c2 <brelse>
}
    80003438:	60e2                	ld	ra,24(sp)
    8000343a:	6442                	ld	s0,16(sp)
    8000343c:	64a2                	ld	s1,8(sp)
    8000343e:	6902                	ld	s2,0(sp)
    80003440:	6105                	addi	sp,sp,32
    80003442:	8082                	ret
    panic("freeing free block");
    80003444:	00005517          	auipc	a0,0x5
    80003448:	27450513          	addi	a0,a0,628 # 800086b8 <syscalls+0xe8>
    8000344c:	ffffd097          	auipc	ra,0xffffd
    80003450:	0de080e7          	jalr	222(ra) # 8000052a <panic>

0000000080003454 <balloc>:
{
    80003454:	711d                	addi	sp,sp,-96
    80003456:	ec86                	sd	ra,88(sp)
    80003458:	e8a2                	sd	s0,80(sp)
    8000345a:	e4a6                	sd	s1,72(sp)
    8000345c:	e0ca                	sd	s2,64(sp)
    8000345e:	fc4e                	sd	s3,56(sp)
    80003460:	f852                	sd	s4,48(sp)
    80003462:	f456                	sd	s5,40(sp)
    80003464:	f05a                	sd	s6,32(sp)
    80003466:	ec5e                	sd	s7,24(sp)
    80003468:	e862                	sd	s8,16(sp)
    8000346a:	e466                	sd	s9,8(sp)
    8000346c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000346e:	00025797          	auipc	a5,0x25
    80003472:	93e7a783          	lw	a5,-1730(a5) # 80027dac <sb+0x4>
    80003476:	cbd1                	beqz	a5,8000350a <balloc+0xb6>
    80003478:	8baa                	mv	s7,a0
    8000347a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000347c:	00025b17          	auipc	s6,0x25
    80003480:	92cb0b13          	addi	s6,s6,-1748 # 80027da8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003484:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003486:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003488:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000348a:	6c89                	lui	s9,0x2
    8000348c:	a831                	j	800034a8 <balloc+0x54>
    brelse(bp);
    8000348e:	854a                	mv	a0,s2
    80003490:	00000097          	auipc	ra,0x0
    80003494:	e32080e7          	jalr	-462(ra) # 800032c2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003498:	015c87bb          	addw	a5,s9,s5
    8000349c:	00078a9b          	sext.w	s5,a5
    800034a0:	004b2703          	lw	a4,4(s6)
    800034a4:	06eaf363          	bgeu	s5,a4,8000350a <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800034a8:	41fad79b          	sraiw	a5,s5,0x1f
    800034ac:	0137d79b          	srliw	a5,a5,0x13
    800034b0:	015787bb          	addw	a5,a5,s5
    800034b4:	40d7d79b          	sraiw	a5,a5,0xd
    800034b8:	01cb2583          	lw	a1,28(s6)
    800034bc:	9dbd                	addw	a1,a1,a5
    800034be:	855e                	mv	a0,s7
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	cd2080e7          	jalr	-814(ra) # 80003192 <bread>
    800034c8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ca:	004b2503          	lw	a0,4(s6)
    800034ce:	000a849b          	sext.w	s1,s5
    800034d2:	8662                	mv	a2,s8
    800034d4:	faa4fde3          	bgeu	s1,a0,8000348e <balloc+0x3a>
      m = 1 << (bi % 8);
    800034d8:	41f6579b          	sraiw	a5,a2,0x1f
    800034dc:	01d7d69b          	srliw	a3,a5,0x1d
    800034e0:	00c6873b          	addw	a4,a3,a2
    800034e4:	00777793          	andi	a5,a4,7
    800034e8:	9f95                	subw	a5,a5,a3
    800034ea:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034ee:	4037571b          	sraiw	a4,a4,0x3
    800034f2:	00e906b3          	add	a3,s2,a4
    800034f6:	0586c683          	lbu	a3,88(a3)
    800034fa:	00d7f5b3          	and	a1,a5,a3
    800034fe:	cd91                	beqz	a1,8000351a <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003500:	2605                	addiw	a2,a2,1
    80003502:	2485                	addiw	s1,s1,1
    80003504:	fd4618e3          	bne	a2,s4,800034d4 <balloc+0x80>
    80003508:	b759                	j	8000348e <balloc+0x3a>
  panic("balloc: out of blocks");
    8000350a:	00005517          	auipc	a0,0x5
    8000350e:	1c650513          	addi	a0,a0,454 # 800086d0 <syscalls+0x100>
    80003512:	ffffd097          	auipc	ra,0xffffd
    80003516:	018080e7          	jalr	24(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000351a:	974a                	add	a4,a4,s2
    8000351c:	8fd5                	or	a5,a5,a3
    8000351e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003522:	854a                	mv	a0,s2
    80003524:	00001097          	auipc	ra,0x1
    80003528:	332080e7          	jalr	818(ra) # 80004856 <log_write>
        brelse(bp);
    8000352c:	854a                	mv	a0,s2
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	d94080e7          	jalr	-620(ra) # 800032c2 <brelse>
  bp = bread(dev, bno);
    80003536:	85a6                	mv	a1,s1
    80003538:	855e                	mv	a0,s7
    8000353a:	00000097          	auipc	ra,0x0
    8000353e:	c58080e7          	jalr	-936(ra) # 80003192 <bread>
    80003542:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003544:	40000613          	li	a2,1024
    80003548:	4581                	li	a1,0
    8000354a:	05850513          	addi	a0,a0,88
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	770080e7          	jalr	1904(ra) # 80000cbe <memset>
  log_write(bp);
    80003556:	854a                	mv	a0,s2
    80003558:	00001097          	auipc	ra,0x1
    8000355c:	2fe080e7          	jalr	766(ra) # 80004856 <log_write>
  brelse(bp);
    80003560:	854a                	mv	a0,s2
    80003562:	00000097          	auipc	ra,0x0
    80003566:	d60080e7          	jalr	-672(ra) # 800032c2 <brelse>
}
    8000356a:	8526                	mv	a0,s1
    8000356c:	60e6                	ld	ra,88(sp)
    8000356e:	6446                	ld	s0,80(sp)
    80003570:	64a6                	ld	s1,72(sp)
    80003572:	6906                	ld	s2,64(sp)
    80003574:	79e2                	ld	s3,56(sp)
    80003576:	7a42                	ld	s4,48(sp)
    80003578:	7aa2                	ld	s5,40(sp)
    8000357a:	7b02                	ld	s6,32(sp)
    8000357c:	6be2                	ld	s7,24(sp)
    8000357e:	6c42                	ld	s8,16(sp)
    80003580:	6ca2                	ld	s9,8(sp)
    80003582:	6125                	addi	sp,sp,96
    80003584:	8082                	ret

0000000080003586 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003586:	7179                	addi	sp,sp,-48
    80003588:	f406                	sd	ra,40(sp)
    8000358a:	f022                	sd	s0,32(sp)
    8000358c:	ec26                	sd	s1,24(sp)
    8000358e:	e84a                	sd	s2,16(sp)
    80003590:	e44e                	sd	s3,8(sp)
    80003592:	e052                	sd	s4,0(sp)
    80003594:	1800                	addi	s0,sp,48
    80003596:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003598:	47ad                	li	a5,11
    8000359a:	04b7fe63          	bgeu	a5,a1,800035f6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000359e:	ff45849b          	addiw	s1,a1,-12
    800035a2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035a6:	0ff00793          	li	a5,255
    800035aa:	0ae7e463          	bltu	a5,a4,80003652 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035ae:	08052583          	lw	a1,128(a0)
    800035b2:	c5b5                	beqz	a1,8000361e <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035b4:	00092503          	lw	a0,0(s2)
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	bda080e7          	jalr	-1062(ra) # 80003192 <bread>
    800035c0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035c2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035c6:	02049713          	slli	a4,s1,0x20
    800035ca:	01e75593          	srli	a1,a4,0x1e
    800035ce:	00b784b3          	add	s1,a5,a1
    800035d2:	0004a983          	lw	s3,0(s1)
    800035d6:	04098e63          	beqz	s3,80003632 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800035da:	8552                	mv	a0,s4
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	ce6080e7          	jalr	-794(ra) # 800032c2 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035e4:	854e                	mv	a0,s3
    800035e6:	70a2                	ld	ra,40(sp)
    800035e8:	7402                	ld	s0,32(sp)
    800035ea:	64e2                	ld	s1,24(sp)
    800035ec:	6942                	ld	s2,16(sp)
    800035ee:	69a2                	ld	s3,8(sp)
    800035f0:	6a02                	ld	s4,0(sp)
    800035f2:	6145                	addi	sp,sp,48
    800035f4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035f6:	02059793          	slli	a5,a1,0x20
    800035fa:	01e7d593          	srli	a1,a5,0x1e
    800035fe:	00b504b3          	add	s1,a0,a1
    80003602:	0504a983          	lw	s3,80(s1)
    80003606:	fc099fe3          	bnez	s3,800035e4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000360a:	4108                	lw	a0,0(a0)
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	e48080e7          	jalr	-440(ra) # 80003454 <balloc>
    80003614:	0005099b          	sext.w	s3,a0
    80003618:	0534a823          	sw	s3,80(s1)
    8000361c:	b7e1                	j	800035e4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000361e:	4108                	lw	a0,0(a0)
    80003620:	00000097          	auipc	ra,0x0
    80003624:	e34080e7          	jalr	-460(ra) # 80003454 <balloc>
    80003628:	0005059b          	sext.w	a1,a0
    8000362c:	08b92023          	sw	a1,128(s2)
    80003630:	b751                	j	800035b4 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003632:	00092503          	lw	a0,0(s2)
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	e1e080e7          	jalr	-482(ra) # 80003454 <balloc>
    8000363e:	0005099b          	sext.w	s3,a0
    80003642:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003646:	8552                	mv	a0,s4
    80003648:	00001097          	auipc	ra,0x1
    8000364c:	20e080e7          	jalr	526(ra) # 80004856 <log_write>
    80003650:	b769                	j	800035da <bmap+0x54>
  panic("bmap: out of range");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	09650513          	addi	a0,a0,150 # 800086e8 <syscalls+0x118>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	ed0080e7          	jalr	-304(ra) # 8000052a <panic>

0000000080003662 <iget>:
{
    80003662:	7179                	addi	sp,sp,-48
    80003664:	f406                	sd	ra,40(sp)
    80003666:	f022                	sd	s0,32(sp)
    80003668:	ec26                	sd	s1,24(sp)
    8000366a:	e84a                	sd	s2,16(sp)
    8000366c:	e44e                	sd	s3,8(sp)
    8000366e:	e052                	sd	s4,0(sp)
    80003670:	1800                	addi	s0,sp,48
    80003672:	89aa                	mv	s3,a0
    80003674:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003676:	00024517          	auipc	a0,0x24
    8000367a:	75250513          	addi	a0,a0,1874 # 80027dc8 <itable>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	544080e7          	jalr	1348(ra) # 80000bc2 <acquire>
  empty = 0;
    80003686:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003688:	00024497          	auipc	s1,0x24
    8000368c:	75848493          	addi	s1,s1,1880 # 80027de0 <itable+0x18>
    80003690:	00026697          	auipc	a3,0x26
    80003694:	1e068693          	addi	a3,a3,480 # 80029870 <log>
    80003698:	a039                	j	800036a6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000369a:	02090b63          	beqz	s2,800036d0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000369e:	08848493          	addi	s1,s1,136
    800036a2:	02d48a63          	beq	s1,a3,800036d6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036a6:	449c                	lw	a5,8(s1)
    800036a8:	fef059e3          	blez	a5,8000369a <iget+0x38>
    800036ac:	4098                	lw	a4,0(s1)
    800036ae:	ff3716e3          	bne	a4,s3,8000369a <iget+0x38>
    800036b2:	40d8                	lw	a4,4(s1)
    800036b4:	ff4713e3          	bne	a4,s4,8000369a <iget+0x38>
      ip->ref++;
    800036b8:	2785                	addiw	a5,a5,1
    800036ba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800036bc:	00024517          	auipc	a0,0x24
    800036c0:	70c50513          	addi	a0,a0,1804 # 80027dc8 <itable>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	5b2080e7          	jalr	1458(ra) # 80000c76 <release>
      return ip;
    800036cc:	8926                	mv	s2,s1
    800036ce:	a03d                	j	800036fc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036d0:	f7f9                	bnez	a5,8000369e <iget+0x3c>
    800036d2:	8926                	mv	s2,s1
    800036d4:	b7e9                	j	8000369e <iget+0x3c>
  if(empty == 0)
    800036d6:	02090c63          	beqz	s2,8000370e <iget+0xac>
  ip->dev = dev;
    800036da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036e2:	4785                	li	a5,1
    800036e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036e8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800036ec:	00024517          	auipc	a0,0x24
    800036f0:	6dc50513          	addi	a0,a0,1756 # 80027dc8 <itable>
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	582080e7          	jalr	1410(ra) # 80000c76 <release>
}
    800036fc:	854a                	mv	a0,s2
    800036fe:	70a2                	ld	ra,40(sp)
    80003700:	7402                	ld	s0,32(sp)
    80003702:	64e2                	ld	s1,24(sp)
    80003704:	6942                	ld	s2,16(sp)
    80003706:	69a2                	ld	s3,8(sp)
    80003708:	6a02                	ld	s4,0(sp)
    8000370a:	6145                	addi	sp,sp,48
    8000370c:	8082                	ret
    panic("iget: no inodes");
    8000370e:	00005517          	auipc	a0,0x5
    80003712:	ff250513          	addi	a0,a0,-14 # 80008700 <syscalls+0x130>
    80003716:	ffffd097          	auipc	ra,0xffffd
    8000371a:	e14080e7          	jalr	-492(ra) # 8000052a <panic>

000000008000371e <fsinit>:
fsinit(int dev) {
    8000371e:	7179                	addi	sp,sp,-48
    80003720:	f406                	sd	ra,40(sp)
    80003722:	f022                	sd	s0,32(sp)
    80003724:	ec26                	sd	s1,24(sp)
    80003726:	e84a                	sd	s2,16(sp)
    80003728:	e44e                	sd	s3,8(sp)
    8000372a:	1800                	addi	s0,sp,48
    8000372c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000372e:	4585                	li	a1,1
    80003730:	00000097          	auipc	ra,0x0
    80003734:	a62080e7          	jalr	-1438(ra) # 80003192 <bread>
    80003738:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000373a:	00024997          	auipc	s3,0x24
    8000373e:	66e98993          	addi	s3,s3,1646 # 80027da8 <sb>
    80003742:	02000613          	li	a2,32
    80003746:	05850593          	addi	a1,a0,88
    8000374a:	854e                	mv	a0,s3
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	5ce080e7          	jalr	1486(ra) # 80000d1a <memmove>
  brelse(bp);
    80003754:	8526                	mv	a0,s1
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	b6c080e7          	jalr	-1172(ra) # 800032c2 <brelse>
  if(sb.magic != FSMAGIC)
    8000375e:	0009a703          	lw	a4,0(s3)
    80003762:	102037b7          	lui	a5,0x10203
    80003766:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000376a:	02f71263          	bne	a4,a5,8000378e <fsinit+0x70>
  initlog(dev, &sb);
    8000376e:	00024597          	auipc	a1,0x24
    80003772:	63a58593          	addi	a1,a1,1594 # 80027da8 <sb>
    80003776:	854a                	mv	a0,s2
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	e60080e7          	jalr	-416(ra) # 800045d8 <initlog>
}
    80003780:	70a2                	ld	ra,40(sp)
    80003782:	7402                	ld	s0,32(sp)
    80003784:	64e2                	ld	s1,24(sp)
    80003786:	6942                	ld	s2,16(sp)
    80003788:	69a2                	ld	s3,8(sp)
    8000378a:	6145                	addi	sp,sp,48
    8000378c:	8082                	ret
    panic("invalid file system");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	f8250513          	addi	a0,a0,-126 # 80008710 <syscalls+0x140>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	d94080e7          	jalr	-620(ra) # 8000052a <panic>

000000008000379e <iinit>:
{
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800037ac:	00005597          	auipc	a1,0x5
    800037b0:	f7c58593          	addi	a1,a1,-132 # 80008728 <syscalls+0x158>
    800037b4:	00024517          	auipc	a0,0x24
    800037b8:	61450513          	addi	a0,a0,1556 # 80027dc8 <itable>
    800037bc:	ffffd097          	auipc	ra,0xffffd
    800037c0:	376080e7          	jalr	886(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    800037c4:	00024497          	auipc	s1,0x24
    800037c8:	62c48493          	addi	s1,s1,1580 # 80027df0 <itable+0x28>
    800037cc:	00026997          	auipc	s3,0x26
    800037d0:	0b498993          	addi	s3,s3,180 # 80029880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037d4:	00005917          	auipc	s2,0x5
    800037d8:	f5c90913          	addi	s2,s2,-164 # 80008730 <syscalls+0x160>
    800037dc:	85ca                	mv	a1,s2
    800037de:	8526                	mv	a0,s1
    800037e0:	00001097          	auipc	ra,0x1
    800037e4:	15c080e7          	jalr	348(ra) # 8000493c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037e8:	08848493          	addi	s1,s1,136
    800037ec:	ff3498e3          	bne	s1,s3,800037dc <iinit+0x3e>
}
    800037f0:	70a2                	ld	ra,40(sp)
    800037f2:	7402                	ld	s0,32(sp)
    800037f4:	64e2                	ld	s1,24(sp)
    800037f6:	6942                	ld	s2,16(sp)
    800037f8:	69a2                	ld	s3,8(sp)
    800037fa:	6145                	addi	sp,sp,48
    800037fc:	8082                	ret

00000000800037fe <ialloc>:
{
    800037fe:	715d                	addi	sp,sp,-80
    80003800:	e486                	sd	ra,72(sp)
    80003802:	e0a2                	sd	s0,64(sp)
    80003804:	fc26                	sd	s1,56(sp)
    80003806:	f84a                	sd	s2,48(sp)
    80003808:	f44e                	sd	s3,40(sp)
    8000380a:	f052                	sd	s4,32(sp)
    8000380c:	ec56                	sd	s5,24(sp)
    8000380e:	e85a                	sd	s6,16(sp)
    80003810:	e45e                	sd	s7,8(sp)
    80003812:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003814:	00024717          	auipc	a4,0x24
    80003818:	5a072703          	lw	a4,1440(a4) # 80027db4 <sb+0xc>
    8000381c:	4785                	li	a5,1
    8000381e:	04e7fa63          	bgeu	a5,a4,80003872 <ialloc+0x74>
    80003822:	8aaa                	mv	s5,a0
    80003824:	8bae                	mv	s7,a1
    80003826:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003828:	00024a17          	auipc	s4,0x24
    8000382c:	580a0a13          	addi	s4,s4,1408 # 80027da8 <sb>
    80003830:	00048b1b          	sext.w	s6,s1
    80003834:	0044d793          	srli	a5,s1,0x4
    80003838:	018a2583          	lw	a1,24(s4)
    8000383c:	9dbd                	addw	a1,a1,a5
    8000383e:	8556                	mv	a0,s5
    80003840:	00000097          	auipc	ra,0x0
    80003844:	952080e7          	jalr	-1710(ra) # 80003192 <bread>
    80003848:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000384a:	05850993          	addi	s3,a0,88
    8000384e:	00f4f793          	andi	a5,s1,15
    80003852:	079a                	slli	a5,a5,0x6
    80003854:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003856:	00099783          	lh	a5,0(s3)
    8000385a:	c785                	beqz	a5,80003882 <ialloc+0x84>
    brelse(bp);
    8000385c:	00000097          	auipc	ra,0x0
    80003860:	a66080e7          	jalr	-1434(ra) # 800032c2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003864:	0485                	addi	s1,s1,1
    80003866:	00ca2703          	lw	a4,12(s4)
    8000386a:	0004879b          	sext.w	a5,s1
    8000386e:	fce7e1e3          	bltu	a5,a4,80003830 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003872:	00005517          	auipc	a0,0x5
    80003876:	ec650513          	addi	a0,a0,-314 # 80008738 <syscalls+0x168>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	cb0080e7          	jalr	-848(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003882:	04000613          	li	a2,64
    80003886:	4581                	li	a1,0
    80003888:	854e                	mv	a0,s3
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	434080e7          	jalr	1076(ra) # 80000cbe <memset>
      dip->type = type;
    80003892:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003896:	854a                	mv	a0,s2
    80003898:	00001097          	auipc	ra,0x1
    8000389c:	fbe080e7          	jalr	-66(ra) # 80004856 <log_write>
      brelse(bp);
    800038a0:	854a                	mv	a0,s2
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	a20080e7          	jalr	-1504(ra) # 800032c2 <brelse>
      return iget(dev, inum);
    800038aa:	85da                	mv	a1,s6
    800038ac:	8556                	mv	a0,s5
    800038ae:	00000097          	auipc	ra,0x0
    800038b2:	db4080e7          	jalr	-588(ra) # 80003662 <iget>
}
    800038b6:	60a6                	ld	ra,72(sp)
    800038b8:	6406                	ld	s0,64(sp)
    800038ba:	74e2                	ld	s1,56(sp)
    800038bc:	7942                	ld	s2,48(sp)
    800038be:	79a2                	ld	s3,40(sp)
    800038c0:	7a02                	ld	s4,32(sp)
    800038c2:	6ae2                	ld	s5,24(sp)
    800038c4:	6b42                	ld	s6,16(sp)
    800038c6:	6ba2                	ld	s7,8(sp)
    800038c8:	6161                	addi	sp,sp,80
    800038ca:	8082                	ret

00000000800038cc <iupdate>:
{
    800038cc:	1101                	addi	sp,sp,-32
    800038ce:	ec06                	sd	ra,24(sp)
    800038d0:	e822                	sd	s0,16(sp)
    800038d2:	e426                	sd	s1,8(sp)
    800038d4:	e04a                	sd	s2,0(sp)
    800038d6:	1000                	addi	s0,sp,32
    800038d8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038da:	415c                	lw	a5,4(a0)
    800038dc:	0047d79b          	srliw	a5,a5,0x4
    800038e0:	00024597          	auipc	a1,0x24
    800038e4:	4e05a583          	lw	a1,1248(a1) # 80027dc0 <sb+0x18>
    800038e8:	9dbd                	addw	a1,a1,a5
    800038ea:	4108                	lw	a0,0(a0)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	8a6080e7          	jalr	-1882(ra) # 80003192 <bread>
    800038f4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038f6:	05850793          	addi	a5,a0,88
    800038fa:	40c8                	lw	a0,4(s1)
    800038fc:	893d                	andi	a0,a0,15
    800038fe:	051a                	slli	a0,a0,0x6
    80003900:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003902:	04449703          	lh	a4,68(s1)
    80003906:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000390a:	04649703          	lh	a4,70(s1)
    8000390e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003912:	04849703          	lh	a4,72(s1)
    80003916:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000391a:	04a49703          	lh	a4,74(s1)
    8000391e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003922:	44f8                	lw	a4,76(s1)
    80003924:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003926:	03400613          	li	a2,52
    8000392a:	05048593          	addi	a1,s1,80
    8000392e:	0531                	addi	a0,a0,12
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	3ea080e7          	jalr	1002(ra) # 80000d1a <memmove>
  log_write(bp);
    80003938:	854a                	mv	a0,s2
    8000393a:	00001097          	auipc	ra,0x1
    8000393e:	f1c080e7          	jalr	-228(ra) # 80004856 <log_write>
  brelse(bp);
    80003942:	854a                	mv	a0,s2
    80003944:	00000097          	auipc	ra,0x0
    80003948:	97e080e7          	jalr	-1666(ra) # 800032c2 <brelse>
}
    8000394c:	60e2                	ld	ra,24(sp)
    8000394e:	6442                	ld	s0,16(sp)
    80003950:	64a2                	ld	s1,8(sp)
    80003952:	6902                	ld	s2,0(sp)
    80003954:	6105                	addi	sp,sp,32
    80003956:	8082                	ret

0000000080003958 <idup>:
{
    80003958:	1101                	addi	sp,sp,-32
    8000395a:	ec06                	sd	ra,24(sp)
    8000395c:	e822                	sd	s0,16(sp)
    8000395e:	e426                	sd	s1,8(sp)
    80003960:	1000                	addi	s0,sp,32
    80003962:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003964:	00024517          	auipc	a0,0x24
    80003968:	46450513          	addi	a0,a0,1124 # 80027dc8 <itable>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	256080e7          	jalr	598(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003974:	449c                	lw	a5,8(s1)
    80003976:	2785                	addiw	a5,a5,1
    80003978:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000397a:	00024517          	auipc	a0,0x24
    8000397e:	44e50513          	addi	a0,a0,1102 # 80027dc8 <itable>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	2f4080e7          	jalr	756(ra) # 80000c76 <release>
}
    8000398a:	8526                	mv	a0,s1
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret

0000000080003996 <ilock>:
{
    80003996:	1101                	addi	sp,sp,-32
    80003998:	ec06                	sd	ra,24(sp)
    8000399a:	e822                	sd	s0,16(sp)
    8000399c:	e426                	sd	s1,8(sp)
    8000399e:	e04a                	sd	s2,0(sp)
    800039a0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039a2:	c115                	beqz	a0,800039c6 <ilock+0x30>
    800039a4:	84aa                	mv	s1,a0
    800039a6:	451c                	lw	a5,8(a0)
    800039a8:	00f05f63          	blez	a5,800039c6 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039ac:	0541                	addi	a0,a0,16
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	fc8080e7          	jalr	-56(ra) # 80004976 <acquiresleep>
  if(ip->valid == 0){
    800039b6:	40bc                	lw	a5,64(s1)
    800039b8:	cf99                	beqz	a5,800039d6 <ilock+0x40>
}
    800039ba:	60e2                	ld	ra,24(sp)
    800039bc:	6442                	ld	s0,16(sp)
    800039be:	64a2                	ld	s1,8(sp)
    800039c0:	6902                	ld	s2,0(sp)
    800039c2:	6105                	addi	sp,sp,32
    800039c4:	8082                	ret
    panic("ilock");
    800039c6:	00005517          	auipc	a0,0x5
    800039ca:	d8a50513          	addi	a0,a0,-630 # 80008750 <syscalls+0x180>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	b5c080e7          	jalr	-1188(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039d6:	40dc                	lw	a5,4(s1)
    800039d8:	0047d79b          	srliw	a5,a5,0x4
    800039dc:	00024597          	auipc	a1,0x24
    800039e0:	3e45a583          	lw	a1,996(a1) # 80027dc0 <sb+0x18>
    800039e4:	9dbd                	addw	a1,a1,a5
    800039e6:	4088                	lw	a0,0(s1)
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	7aa080e7          	jalr	1962(ra) # 80003192 <bread>
    800039f0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039f2:	05850593          	addi	a1,a0,88
    800039f6:	40dc                	lw	a5,4(s1)
    800039f8:	8bbd                	andi	a5,a5,15
    800039fa:	079a                	slli	a5,a5,0x6
    800039fc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039fe:	00059783          	lh	a5,0(a1)
    80003a02:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a06:	00259783          	lh	a5,2(a1)
    80003a0a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a0e:	00459783          	lh	a5,4(a1)
    80003a12:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a16:	00659783          	lh	a5,6(a1)
    80003a1a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003a1e:	459c                	lw	a5,8(a1)
    80003a20:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a22:	03400613          	li	a2,52
    80003a26:	05b1                	addi	a1,a1,12
    80003a28:	05048513          	addi	a0,s1,80
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	2ee080e7          	jalr	750(ra) # 80000d1a <memmove>
    brelse(bp);
    80003a34:	854a                	mv	a0,s2
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	88c080e7          	jalr	-1908(ra) # 800032c2 <brelse>
    ip->valid = 1;
    80003a3e:	4785                	li	a5,1
    80003a40:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a42:	04449783          	lh	a5,68(s1)
    80003a46:	fbb5                	bnez	a5,800039ba <ilock+0x24>
      panic("ilock: no type");
    80003a48:	00005517          	auipc	a0,0x5
    80003a4c:	d1050513          	addi	a0,a0,-752 # 80008758 <syscalls+0x188>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	ada080e7          	jalr	-1318(ra) # 8000052a <panic>

0000000080003a58 <iunlock>:
{
    80003a58:	1101                	addi	sp,sp,-32
    80003a5a:	ec06                	sd	ra,24(sp)
    80003a5c:	e822                	sd	s0,16(sp)
    80003a5e:	e426                	sd	s1,8(sp)
    80003a60:	e04a                	sd	s2,0(sp)
    80003a62:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a64:	c905                	beqz	a0,80003a94 <iunlock+0x3c>
    80003a66:	84aa                	mv	s1,a0
    80003a68:	01050913          	addi	s2,a0,16
    80003a6c:	854a                	mv	a0,s2
    80003a6e:	00001097          	auipc	ra,0x1
    80003a72:	fa2080e7          	jalr	-94(ra) # 80004a10 <holdingsleep>
    80003a76:	cd19                	beqz	a0,80003a94 <iunlock+0x3c>
    80003a78:	449c                	lw	a5,8(s1)
    80003a7a:	00f05d63          	blez	a5,80003a94 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a7e:	854a                	mv	a0,s2
    80003a80:	00001097          	auipc	ra,0x1
    80003a84:	f4c080e7          	jalr	-180(ra) # 800049cc <releasesleep>
}
    80003a88:	60e2                	ld	ra,24(sp)
    80003a8a:	6442                	ld	s0,16(sp)
    80003a8c:	64a2                	ld	s1,8(sp)
    80003a8e:	6902                	ld	s2,0(sp)
    80003a90:	6105                	addi	sp,sp,32
    80003a92:	8082                	ret
    panic("iunlock");
    80003a94:	00005517          	auipc	a0,0x5
    80003a98:	cd450513          	addi	a0,a0,-812 # 80008768 <syscalls+0x198>
    80003a9c:	ffffd097          	auipc	ra,0xffffd
    80003aa0:	a8e080e7          	jalr	-1394(ra) # 8000052a <panic>

0000000080003aa4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aa4:	7179                	addi	sp,sp,-48
    80003aa6:	f406                	sd	ra,40(sp)
    80003aa8:	f022                	sd	s0,32(sp)
    80003aaa:	ec26                	sd	s1,24(sp)
    80003aac:	e84a                	sd	s2,16(sp)
    80003aae:	e44e                	sd	s3,8(sp)
    80003ab0:	e052                	sd	s4,0(sp)
    80003ab2:	1800                	addi	s0,sp,48
    80003ab4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ab6:	05050493          	addi	s1,a0,80
    80003aba:	08050913          	addi	s2,a0,128
    80003abe:	a021                	j	80003ac6 <itrunc+0x22>
    80003ac0:	0491                	addi	s1,s1,4
    80003ac2:	01248d63          	beq	s1,s2,80003adc <itrunc+0x38>
    if(ip->addrs[i]){
    80003ac6:	408c                	lw	a1,0(s1)
    80003ac8:	dde5                	beqz	a1,80003ac0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003aca:	0009a503          	lw	a0,0(s3)
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	90a080e7          	jalr	-1782(ra) # 800033d8 <bfree>
      ip->addrs[i] = 0;
    80003ad6:	0004a023          	sw	zero,0(s1)
    80003ada:	b7dd                	j	80003ac0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003adc:	0809a583          	lw	a1,128(s3)
    80003ae0:	e185                	bnez	a1,80003b00 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ae2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ae6:	854e                	mv	a0,s3
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	de4080e7          	jalr	-540(ra) # 800038cc <iupdate>
}
    80003af0:	70a2                	ld	ra,40(sp)
    80003af2:	7402                	ld	s0,32(sp)
    80003af4:	64e2                	ld	s1,24(sp)
    80003af6:	6942                	ld	s2,16(sp)
    80003af8:	69a2                	ld	s3,8(sp)
    80003afa:	6a02                	ld	s4,0(sp)
    80003afc:	6145                	addi	sp,sp,48
    80003afe:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b00:	0009a503          	lw	a0,0(s3)
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	68e080e7          	jalr	1678(ra) # 80003192 <bread>
    80003b0c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b0e:	05850493          	addi	s1,a0,88
    80003b12:	45850913          	addi	s2,a0,1112
    80003b16:	a021                	j	80003b1e <itrunc+0x7a>
    80003b18:	0491                	addi	s1,s1,4
    80003b1a:	01248b63          	beq	s1,s2,80003b30 <itrunc+0x8c>
      if(a[j])
    80003b1e:	408c                	lw	a1,0(s1)
    80003b20:	dde5                	beqz	a1,80003b18 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b22:	0009a503          	lw	a0,0(s3)
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	8b2080e7          	jalr	-1870(ra) # 800033d8 <bfree>
    80003b2e:	b7ed                	j	80003b18 <itrunc+0x74>
    brelse(bp);
    80003b30:	8552                	mv	a0,s4
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	790080e7          	jalr	1936(ra) # 800032c2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b3a:	0809a583          	lw	a1,128(s3)
    80003b3e:	0009a503          	lw	a0,0(s3)
    80003b42:	00000097          	auipc	ra,0x0
    80003b46:	896080e7          	jalr	-1898(ra) # 800033d8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b4a:	0809a023          	sw	zero,128(s3)
    80003b4e:	bf51                	j	80003ae2 <itrunc+0x3e>

0000000080003b50 <iput>:
{
    80003b50:	1101                	addi	sp,sp,-32
    80003b52:	ec06                	sd	ra,24(sp)
    80003b54:	e822                	sd	s0,16(sp)
    80003b56:	e426                	sd	s1,8(sp)
    80003b58:	e04a                	sd	s2,0(sp)
    80003b5a:	1000                	addi	s0,sp,32
    80003b5c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b5e:	00024517          	auipc	a0,0x24
    80003b62:	26a50513          	addi	a0,a0,618 # 80027dc8 <itable>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	05c080e7          	jalr	92(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b6e:	4498                	lw	a4,8(s1)
    80003b70:	4785                	li	a5,1
    80003b72:	02f70363          	beq	a4,a5,80003b98 <iput+0x48>
  ip->ref--;
    80003b76:	449c                	lw	a5,8(s1)
    80003b78:	37fd                	addiw	a5,a5,-1
    80003b7a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b7c:	00024517          	auipc	a0,0x24
    80003b80:	24c50513          	addi	a0,a0,588 # 80027dc8 <itable>
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	0f2080e7          	jalr	242(ra) # 80000c76 <release>
}
    80003b8c:	60e2                	ld	ra,24(sp)
    80003b8e:	6442                	ld	s0,16(sp)
    80003b90:	64a2                	ld	s1,8(sp)
    80003b92:	6902                	ld	s2,0(sp)
    80003b94:	6105                	addi	sp,sp,32
    80003b96:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b98:	40bc                	lw	a5,64(s1)
    80003b9a:	dff1                	beqz	a5,80003b76 <iput+0x26>
    80003b9c:	04a49783          	lh	a5,74(s1)
    80003ba0:	fbf9                	bnez	a5,80003b76 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ba2:	01048913          	addi	s2,s1,16
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	00001097          	auipc	ra,0x1
    80003bac:	dce080e7          	jalr	-562(ra) # 80004976 <acquiresleep>
    release(&itable.lock);
    80003bb0:	00024517          	auipc	a0,0x24
    80003bb4:	21850513          	addi	a0,a0,536 # 80027dc8 <itable>
    80003bb8:	ffffd097          	auipc	ra,0xffffd
    80003bbc:	0be080e7          	jalr	190(ra) # 80000c76 <release>
    itrunc(ip);
    80003bc0:	8526                	mv	a0,s1
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	ee2080e7          	jalr	-286(ra) # 80003aa4 <itrunc>
    ip->type = 0;
    80003bca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	cfc080e7          	jalr	-772(ra) # 800038cc <iupdate>
    ip->valid = 0;
    80003bd8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00001097          	auipc	ra,0x1
    80003be2:	dee080e7          	jalr	-530(ra) # 800049cc <releasesleep>
    acquire(&itable.lock);
    80003be6:	00024517          	auipc	a0,0x24
    80003bea:	1e250513          	addi	a0,a0,482 # 80027dc8 <itable>
    80003bee:	ffffd097          	auipc	ra,0xffffd
    80003bf2:	fd4080e7          	jalr	-44(ra) # 80000bc2 <acquire>
    80003bf6:	b741                	j	80003b76 <iput+0x26>

0000000080003bf8 <iunlockput>:
{
    80003bf8:	1101                	addi	sp,sp,-32
    80003bfa:	ec06                	sd	ra,24(sp)
    80003bfc:	e822                	sd	s0,16(sp)
    80003bfe:	e426                	sd	s1,8(sp)
    80003c00:	1000                	addi	s0,sp,32
    80003c02:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	e54080e7          	jalr	-428(ra) # 80003a58 <iunlock>
  iput(ip);
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	f42080e7          	jalr	-190(ra) # 80003b50 <iput>
}
    80003c16:	60e2                	ld	ra,24(sp)
    80003c18:	6442                	ld	s0,16(sp)
    80003c1a:	64a2                	ld	s1,8(sp)
    80003c1c:	6105                	addi	sp,sp,32
    80003c1e:	8082                	ret

0000000080003c20 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c20:	1141                	addi	sp,sp,-16
    80003c22:	e422                	sd	s0,8(sp)
    80003c24:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c26:	411c                	lw	a5,0(a0)
    80003c28:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c2a:	415c                	lw	a5,4(a0)
    80003c2c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c2e:	04451783          	lh	a5,68(a0)
    80003c32:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c36:	04a51783          	lh	a5,74(a0)
    80003c3a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c3e:	04c56783          	lwu	a5,76(a0)
    80003c42:	e99c                	sd	a5,16(a1)
}
    80003c44:	6422                	ld	s0,8(sp)
    80003c46:	0141                	addi	sp,sp,16
    80003c48:	8082                	ret

0000000080003c4a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c4a:	457c                	lw	a5,76(a0)
    80003c4c:	0ed7e963          	bltu	a5,a3,80003d3e <readi+0xf4>
{
    80003c50:	7159                	addi	sp,sp,-112
    80003c52:	f486                	sd	ra,104(sp)
    80003c54:	f0a2                	sd	s0,96(sp)
    80003c56:	eca6                	sd	s1,88(sp)
    80003c58:	e8ca                	sd	s2,80(sp)
    80003c5a:	e4ce                	sd	s3,72(sp)
    80003c5c:	e0d2                	sd	s4,64(sp)
    80003c5e:	fc56                	sd	s5,56(sp)
    80003c60:	f85a                	sd	s6,48(sp)
    80003c62:	f45e                	sd	s7,40(sp)
    80003c64:	f062                	sd	s8,32(sp)
    80003c66:	ec66                	sd	s9,24(sp)
    80003c68:	e86a                	sd	s10,16(sp)
    80003c6a:	e46e                	sd	s11,8(sp)
    80003c6c:	1880                	addi	s0,sp,112
    80003c6e:	8baa                	mv	s7,a0
    80003c70:	8c2e                	mv	s8,a1
    80003c72:	8ab2                	mv	s5,a2
    80003c74:	84b6                	mv	s1,a3
    80003c76:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c78:	9f35                	addw	a4,a4,a3
    return 0;
    80003c7a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c7c:	0ad76063          	bltu	a4,a3,80003d1c <readi+0xd2>
  if(off + n > ip->size)
    80003c80:	00e7f463          	bgeu	a5,a4,80003c88 <readi+0x3e>
    n = ip->size - off;
    80003c84:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c88:	0a0b0963          	beqz	s6,80003d3a <readi+0xf0>
    80003c8c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c92:	5cfd                	li	s9,-1
    80003c94:	a82d                	j	80003cce <readi+0x84>
    80003c96:	020a1d93          	slli	s11,s4,0x20
    80003c9a:	020ddd93          	srli	s11,s11,0x20
    80003c9e:	05890793          	addi	a5,s2,88
    80003ca2:	86ee                	mv	a3,s11
    80003ca4:	963e                	add	a2,a2,a5
    80003ca6:	85d6                	mv	a1,s5
    80003ca8:	8562                	mv	a0,s8
    80003caa:	ffffe097          	auipc	ra,0xffffe
    80003cae:	61c080e7          	jalr	1564(ra) # 800022c6 <either_copyout>
    80003cb2:	05950d63          	beq	a0,s9,80003d0c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	60a080e7          	jalr	1546(ra) # 800032c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc0:	013a09bb          	addw	s3,s4,s3
    80003cc4:	009a04bb          	addw	s1,s4,s1
    80003cc8:	9aee                	add	s5,s5,s11
    80003cca:	0569f763          	bgeu	s3,s6,80003d18 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cce:	000ba903          	lw	s2,0(s7)
    80003cd2:	00a4d59b          	srliw	a1,s1,0xa
    80003cd6:	855e                	mv	a0,s7
    80003cd8:	00000097          	auipc	ra,0x0
    80003cdc:	8ae080e7          	jalr	-1874(ra) # 80003586 <bmap>
    80003ce0:	0005059b          	sext.w	a1,a0
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	fffff097          	auipc	ra,0xfffff
    80003cea:	4ac080e7          	jalr	1196(ra) # 80003192 <bread>
    80003cee:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf0:	3ff4f613          	andi	a2,s1,1023
    80003cf4:	40cd07bb          	subw	a5,s10,a2
    80003cf8:	413b073b          	subw	a4,s6,s3
    80003cfc:	8a3e                	mv	s4,a5
    80003cfe:	2781                	sext.w	a5,a5
    80003d00:	0007069b          	sext.w	a3,a4
    80003d04:	f8f6f9e3          	bgeu	a3,a5,80003c96 <readi+0x4c>
    80003d08:	8a3a                	mv	s4,a4
    80003d0a:	b771                	j	80003c96 <readi+0x4c>
      brelse(bp);
    80003d0c:	854a                	mv	a0,s2
    80003d0e:	fffff097          	auipc	ra,0xfffff
    80003d12:	5b4080e7          	jalr	1460(ra) # 800032c2 <brelse>
      tot = -1;
    80003d16:	59fd                	li	s3,-1
  }
  return tot;
    80003d18:	0009851b          	sext.w	a0,s3
}
    80003d1c:	70a6                	ld	ra,104(sp)
    80003d1e:	7406                	ld	s0,96(sp)
    80003d20:	64e6                	ld	s1,88(sp)
    80003d22:	6946                	ld	s2,80(sp)
    80003d24:	69a6                	ld	s3,72(sp)
    80003d26:	6a06                	ld	s4,64(sp)
    80003d28:	7ae2                	ld	s5,56(sp)
    80003d2a:	7b42                	ld	s6,48(sp)
    80003d2c:	7ba2                	ld	s7,40(sp)
    80003d2e:	7c02                	ld	s8,32(sp)
    80003d30:	6ce2                	ld	s9,24(sp)
    80003d32:	6d42                	ld	s10,16(sp)
    80003d34:	6da2                	ld	s11,8(sp)
    80003d36:	6165                	addi	sp,sp,112
    80003d38:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d3a:	89da                	mv	s3,s6
    80003d3c:	bff1                	j	80003d18 <readi+0xce>
    return 0;
    80003d3e:	4501                	li	a0,0
}
    80003d40:	8082                	ret

0000000080003d42 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d42:	457c                	lw	a5,76(a0)
    80003d44:	10d7e863          	bltu	a5,a3,80003e54 <writei+0x112>
{
    80003d48:	7159                	addi	sp,sp,-112
    80003d4a:	f486                	sd	ra,104(sp)
    80003d4c:	f0a2                	sd	s0,96(sp)
    80003d4e:	eca6                	sd	s1,88(sp)
    80003d50:	e8ca                	sd	s2,80(sp)
    80003d52:	e4ce                	sd	s3,72(sp)
    80003d54:	e0d2                	sd	s4,64(sp)
    80003d56:	fc56                	sd	s5,56(sp)
    80003d58:	f85a                	sd	s6,48(sp)
    80003d5a:	f45e                	sd	s7,40(sp)
    80003d5c:	f062                	sd	s8,32(sp)
    80003d5e:	ec66                	sd	s9,24(sp)
    80003d60:	e86a                	sd	s10,16(sp)
    80003d62:	e46e                	sd	s11,8(sp)
    80003d64:	1880                	addi	s0,sp,112
    80003d66:	8b2a                	mv	s6,a0
    80003d68:	8c2e                	mv	s8,a1
    80003d6a:	8ab2                	mv	s5,a2
    80003d6c:	8936                	mv	s2,a3
    80003d6e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003d70:	00e687bb          	addw	a5,a3,a4
    80003d74:	0ed7e263          	bltu	a5,a3,80003e58 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d78:	00043737          	lui	a4,0x43
    80003d7c:	0ef76063          	bltu	a4,a5,80003e5c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d80:	0c0b8863          	beqz	s7,80003e50 <writei+0x10e>
    80003d84:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d86:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d8a:	5cfd                	li	s9,-1
    80003d8c:	a091                	j	80003dd0 <writei+0x8e>
    80003d8e:	02099d93          	slli	s11,s3,0x20
    80003d92:	020ddd93          	srli	s11,s11,0x20
    80003d96:	05848793          	addi	a5,s1,88
    80003d9a:	86ee                	mv	a3,s11
    80003d9c:	8656                	mv	a2,s5
    80003d9e:	85e2                	mv	a1,s8
    80003da0:	953e                	add	a0,a0,a5
    80003da2:	ffffe097          	auipc	ra,0xffffe
    80003da6:	57a080e7          	jalr	1402(ra) # 8000231c <either_copyin>
    80003daa:	07950263          	beq	a0,s9,80003e0e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003dae:	8526                	mv	a0,s1
    80003db0:	00001097          	auipc	ra,0x1
    80003db4:	aa6080e7          	jalr	-1370(ra) # 80004856 <log_write>
    brelse(bp);
    80003db8:	8526                	mv	a0,s1
    80003dba:	fffff097          	auipc	ra,0xfffff
    80003dbe:	508080e7          	jalr	1288(ra) # 800032c2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dc2:	01498a3b          	addw	s4,s3,s4
    80003dc6:	0129893b          	addw	s2,s3,s2
    80003dca:	9aee                	add	s5,s5,s11
    80003dcc:	057a7663          	bgeu	s4,s7,80003e18 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003dd0:	000b2483          	lw	s1,0(s6)
    80003dd4:	00a9559b          	srliw	a1,s2,0xa
    80003dd8:	855a                	mv	a0,s6
    80003dda:	fffff097          	auipc	ra,0xfffff
    80003dde:	7ac080e7          	jalr	1964(ra) # 80003586 <bmap>
    80003de2:	0005059b          	sext.w	a1,a0
    80003de6:	8526                	mv	a0,s1
    80003de8:	fffff097          	auipc	ra,0xfffff
    80003dec:	3aa080e7          	jalr	938(ra) # 80003192 <bread>
    80003df0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003df2:	3ff97513          	andi	a0,s2,1023
    80003df6:	40ad07bb          	subw	a5,s10,a0
    80003dfa:	414b873b          	subw	a4,s7,s4
    80003dfe:	89be                	mv	s3,a5
    80003e00:	2781                	sext.w	a5,a5
    80003e02:	0007069b          	sext.w	a3,a4
    80003e06:	f8f6f4e3          	bgeu	a3,a5,80003d8e <writei+0x4c>
    80003e0a:	89ba                	mv	s3,a4
    80003e0c:	b749                	j	80003d8e <writei+0x4c>
      brelse(bp);
    80003e0e:	8526                	mv	a0,s1
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	4b2080e7          	jalr	1202(ra) # 800032c2 <brelse>
  }

  if(off > ip->size)
    80003e18:	04cb2783          	lw	a5,76(s6)
    80003e1c:	0127f463          	bgeu	a5,s2,80003e24 <writei+0xe2>
    ip->size = off;
    80003e20:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e24:	855a                	mv	a0,s6
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	aa6080e7          	jalr	-1370(ra) # 800038cc <iupdate>

  return tot;
    80003e2e:	000a051b          	sext.w	a0,s4
}
    80003e32:	70a6                	ld	ra,104(sp)
    80003e34:	7406                	ld	s0,96(sp)
    80003e36:	64e6                	ld	s1,88(sp)
    80003e38:	6946                	ld	s2,80(sp)
    80003e3a:	69a6                	ld	s3,72(sp)
    80003e3c:	6a06                	ld	s4,64(sp)
    80003e3e:	7ae2                	ld	s5,56(sp)
    80003e40:	7b42                	ld	s6,48(sp)
    80003e42:	7ba2                	ld	s7,40(sp)
    80003e44:	7c02                	ld	s8,32(sp)
    80003e46:	6ce2                	ld	s9,24(sp)
    80003e48:	6d42                	ld	s10,16(sp)
    80003e4a:	6da2                	ld	s11,8(sp)
    80003e4c:	6165                	addi	sp,sp,112
    80003e4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e50:	8a5e                	mv	s4,s7
    80003e52:	bfc9                	j	80003e24 <writei+0xe2>
    return -1;
    80003e54:	557d                	li	a0,-1
}
    80003e56:	8082                	ret
    return -1;
    80003e58:	557d                	li	a0,-1
    80003e5a:	bfe1                	j	80003e32 <writei+0xf0>
    return -1;
    80003e5c:	557d                	li	a0,-1
    80003e5e:	bfd1                	j	80003e32 <writei+0xf0>

0000000080003e60 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e60:	1141                	addi	sp,sp,-16
    80003e62:	e406                	sd	ra,8(sp)
    80003e64:	e022                	sd	s0,0(sp)
    80003e66:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e68:	4639                	li	a2,14
    80003e6a:	ffffd097          	auipc	ra,0xffffd
    80003e6e:	f2c080e7          	jalr	-212(ra) # 80000d96 <strncmp>
}
    80003e72:	60a2                	ld	ra,8(sp)
    80003e74:	6402                	ld	s0,0(sp)
    80003e76:	0141                	addi	sp,sp,16
    80003e78:	8082                	ret

0000000080003e7a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e7a:	7139                	addi	sp,sp,-64
    80003e7c:	fc06                	sd	ra,56(sp)
    80003e7e:	f822                	sd	s0,48(sp)
    80003e80:	f426                	sd	s1,40(sp)
    80003e82:	f04a                	sd	s2,32(sp)
    80003e84:	ec4e                	sd	s3,24(sp)
    80003e86:	e852                	sd	s4,16(sp)
    80003e88:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e8a:	04451703          	lh	a4,68(a0)
    80003e8e:	4785                	li	a5,1
    80003e90:	00f71a63          	bne	a4,a5,80003ea4 <dirlookup+0x2a>
    80003e94:	892a                	mv	s2,a0
    80003e96:	89ae                	mv	s3,a1
    80003e98:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e9a:	457c                	lw	a5,76(a0)
    80003e9c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e9e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea0:	e79d                	bnez	a5,80003ece <dirlookup+0x54>
    80003ea2:	a8a5                	j	80003f1a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003ea4:	00005517          	auipc	a0,0x5
    80003ea8:	8cc50513          	addi	a0,a0,-1844 # 80008770 <syscalls+0x1a0>
    80003eac:	ffffc097          	auipc	ra,0xffffc
    80003eb0:	67e080e7          	jalr	1662(ra) # 8000052a <panic>
      panic("dirlookup read");
    80003eb4:	00005517          	auipc	a0,0x5
    80003eb8:	8d450513          	addi	a0,a0,-1836 # 80008788 <syscalls+0x1b8>
    80003ebc:	ffffc097          	auipc	ra,0xffffc
    80003ec0:	66e080e7          	jalr	1646(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ec4:	24c1                	addiw	s1,s1,16
    80003ec6:	04c92783          	lw	a5,76(s2)
    80003eca:	04f4f763          	bgeu	s1,a5,80003f18 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ece:	4741                	li	a4,16
    80003ed0:	86a6                	mv	a3,s1
    80003ed2:	fc040613          	addi	a2,s0,-64
    80003ed6:	4581                	li	a1,0
    80003ed8:	854a                	mv	a0,s2
    80003eda:	00000097          	auipc	ra,0x0
    80003ede:	d70080e7          	jalr	-656(ra) # 80003c4a <readi>
    80003ee2:	47c1                	li	a5,16
    80003ee4:	fcf518e3          	bne	a0,a5,80003eb4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ee8:	fc045783          	lhu	a5,-64(s0)
    80003eec:	dfe1                	beqz	a5,80003ec4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eee:	fc240593          	addi	a1,s0,-62
    80003ef2:	854e                	mv	a0,s3
    80003ef4:	00000097          	auipc	ra,0x0
    80003ef8:	f6c080e7          	jalr	-148(ra) # 80003e60 <namecmp>
    80003efc:	f561                	bnez	a0,80003ec4 <dirlookup+0x4a>
      if(poff)
    80003efe:	000a0463          	beqz	s4,80003f06 <dirlookup+0x8c>
        *poff = off;
    80003f02:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f06:	fc045583          	lhu	a1,-64(s0)
    80003f0a:	00092503          	lw	a0,0(s2)
    80003f0e:	fffff097          	auipc	ra,0xfffff
    80003f12:	754080e7          	jalr	1876(ra) # 80003662 <iget>
    80003f16:	a011                	j	80003f1a <dirlookup+0xa0>
  return 0;
    80003f18:	4501                	li	a0,0
}
    80003f1a:	70e2                	ld	ra,56(sp)
    80003f1c:	7442                	ld	s0,48(sp)
    80003f1e:	74a2                	ld	s1,40(sp)
    80003f20:	7902                	ld	s2,32(sp)
    80003f22:	69e2                	ld	s3,24(sp)
    80003f24:	6a42                	ld	s4,16(sp)
    80003f26:	6121                	addi	sp,sp,64
    80003f28:	8082                	ret

0000000080003f2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f2a:	711d                	addi	sp,sp,-96
    80003f2c:	ec86                	sd	ra,88(sp)
    80003f2e:	e8a2                	sd	s0,80(sp)
    80003f30:	e4a6                	sd	s1,72(sp)
    80003f32:	e0ca                	sd	s2,64(sp)
    80003f34:	fc4e                	sd	s3,56(sp)
    80003f36:	f852                	sd	s4,48(sp)
    80003f38:	f456                	sd	s5,40(sp)
    80003f3a:	f05a                	sd	s6,32(sp)
    80003f3c:	ec5e                	sd	s7,24(sp)
    80003f3e:	e862                	sd	s8,16(sp)
    80003f40:	e466                	sd	s9,8(sp)
    80003f42:	1080                	addi	s0,sp,96
    80003f44:	84aa                	mv	s1,a0
    80003f46:	8aae                	mv	s5,a1
    80003f48:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f4a:	00054703          	lbu	a4,0(a0)
    80003f4e:	02f00793          	li	a5,47
    80003f52:	02f70363          	beq	a4,a5,80003f78 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f56:	ffffe097          	auipc	ra,0xffffe
    80003f5a:	a44080e7          	jalr	-1468(ra) # 8000199a <myproc>
    80003f5e:	15053503          	ld	a0,336(a0)
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	9f6080e7          	jalr	-1546(ra) # 80003958 <idup>
    80003f6a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f6c:	02f00913          	li	s2,47
  len = path - s;
    80003f70:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f72:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f74:	4b85                	li	s7,1
    80003f76:	a865                	j	8000402e <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f78:	4585                	li	a1,1
    80003f7a:	4505                	li	a0,1
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	6e6080e7          	jalr	1766(ra) # 80003662 <iget>
    80003f84:	89aa                	mv	s3,a0
    80003f86:	b7dd                	j	80003f6c <namex+0x42>
      iunlockput(ip);
    80003f88:	854e                	mv	a0,s3
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	c6e080e7          	jalr	-914(ra) # 80003bf8 <iunlockput>
      return 0;
    80003f92:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f94:	854e                	mv	a0,s3
    80003f96:	60e6                	ld	ra,88(sp)
    80003f98:	6446                	ld	s0,80(sp)
    80003f9a:	64a6                	ld	s1,72(sp)
    80003f9c:	6906                	ld	s2,64(sp)
    80003f9e:	79e2                	ld	s3,56(sp)
    80003fa0:	7a42                	ld	s4,48(sp)
    80003fa2:	7aa2                	ld	s5,40(sp)
    80003fa4:	7b02                	ld	s6,32(sp)
    80003fa6:	6be2                	ld	s7,24(sp)
    80003fa8:	6c42                	ld	s8,16(sp)
    80003faa:	6ca2                	ld	s9,8(sp)
    80003fac:	6125                	addi	sp,sp,96
    80003fae:	8082                	ret
      iunlock(ip);
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	aa6080e7          	jalr	-1370(ra) # 80003a58 <iunlock>
      return ip;
    80003fba:	bfe9                	j	80003f94 <namex+0x6a>
      iunlockput(ip);
    80003fbc:	854e                	mv	a0,s3
    80003fbe:	00000097          	auipc	ra,0x0
    80003fc2:	c3a080e7          	jalr	-966(ra) # 80003bf8 <iunlockput>
      return 0;
    80003fc6:	89e6                	mv	s3,s9
    80003fc8:	b7f1                	j	80003f94 <namex+0x6a>
  len = path - s;
    80003fca:	40b48633          	sub	a2,s1,a1
    80003fce:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fd2:	099c5463          	bge	s8,s9,8000405a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fd6:	4639                	li	a2,14
    80003fd8:	8552                	mv	a0,s4
    80003fda:	ffffd097          	auipc	ra,0xffffd
    80003fde:	d40080e7          	jalr	-704(ra) # 80000d1a <memmove>
  while(*path == '/')
    80003fe2:	0004c783          	lbu	a5,0(s1)
    80003fe6:	01279763          	bne	a5,s2,80003ff4 <namex+0xca>
    path++;
    80003fea:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fec:	0004c783          	lbu	a5,0(s1)
    80003ff0:	ff278de3          	beq	a5,s2,80003fea <namex+0xc0>
    ilock(ip);
    80003ff4:	854e                	mv	a0,s3
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	9a0080e7          	jalr	-1632(ra) # 80003996 <ilock>
    if(ip->type != T_DIR){
    80003ffe:	04499783          	lh	a5,68(s3)
    80004002:	f97793e3          	bne	a5,s7,80003f88 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004006:	000a8563          	beqz	s5,80004010 <namex+0xe6>
    8000400a:	0004c783          	lbu	a5,0(s1)
    8000400e:	d3cd                	beqz	a5,80003fb0 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004010:	865a                	mv	a2,s6
    80004012:	85d2                	mv	a1,s4
    80004014:	854e                	mv	a0,s3
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	e64080e7          	jalr	-412(ra) # 80003e7a <dirlookup>
    8000401e:	8caa                	mv	s9,a0
    80004020:	dd51                	beqz	a0,80003fbc <namex+0x92>
    iunlockput(ip);
    80004022:	854e                	mv	a0,s3
    80004024:	00000097          	auipc	ra,0x0
    80004028:	bd4080e7          	jalr	-1068(ra) # 80003bf8 <iunlockput>
    ip = next;
    8000402c:	89e6                	mv	s3,s9
  while(*path == '/')
    8000402e:	0004c783          	lbu	a5,0(s1)
    80004032:	05279763          	bne	a5,s2,80004080 <namex+0x156>
    path++;
    80004036:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004038:	0004c783          	lbu	a5,0(s1)
    8000403c:	ff278de3          	beq	a5,s2,80004036 <namex+0x10c>
  if(*path == 0)
    80004040:	c79d                	beqz	a5,8000406e <namex+0x144>
    path++;
    80004042:	85a6                	mv	a1,s1
  len = path - s;
    80004044:	8cda                	mv	s9,s6
    80004046:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004048:	01278963          	beq	a5,s2,8000405a <namex+0x130>
    8000404c:	dfbd                	beqz	a5,80003fca <namex+0xa0>
    path++;
    8000404e:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004050:	0004c783          	lbu	a5,0(s1)
    80004054:	ff279ce3          	bne	a5,s2,8000404c <namex+0x122>
    80004058:	bf8d                	j	80003fca <namex+0xa0>
    memmove(name, s, len);
    8000405a:	2601                	sext.w	a2,a2
    8000405c:	8552                	mv	a0,s4
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	cbc080e7          	jalr	-836(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004066:	9cd2                	add	s9,s9,s4
    80004068:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000406c:	bf9d                	j	80003fe2 <namex+0xb8>
  if(nameiparent){
    8000406e:	f20a83e3          	beqz	s5,80003f94 <namex+0x6a>
    iput(ip);
    80004072:	854e                	mv	a0,s3
    80004074:	00000097          	auipc	ra,0x0
    80004078:	adc080e7          	jalr	-1316(ra) # 80003b50 <iput>
    return 0;
    8000407c:	4981                	li	s3,0
    8000407e:	bf19                	j	80003f94 <namex+0x6a>
  if(*path == 0)
    80004080:	d7fd                	beqz	a5,8000406e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004082:	0004c783          	lbu	a5,0(s1)
    80004086:	85a6                	mv	a1,s1
    80004088:	b7d1                	j	8000404c <namex+0x122>

000000008000408a <dirlink>:
{
    8000408a:	7139                	addi	sp,sp,-64
    8000408c:	fc06                	sd	ra,56(sp)
    8000408e:	f822                	sd	s0,48(sp)
    80004090:	f426                	sd	s1,40(sp)
    80004092:	f04a                	sd	s2,32(sp)
    80004094:	ec4e                	sd	s3,24(sp)
    80004096:	e852                	sd	s4,16(sp)
    80004098:	0080                	addi	s0,sp,64
    8000409a:	892a                	mv	s2,a0
    8000409c:	8a2e                	mv	s4,a1
    8000409e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040a0:	4601                	li	a2,0
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	dd8080e7          	jalr	-552(ra) # 80003e7a <dirlookup>
    800040aa:	e93d                	bnez	a0,80004120 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ac:	04c92483          	lw	s1,76(s2)
    800040b0:	c49d                	beqz	s1,800040de <dirlink+0x54>
    800040b2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b4:	4741                	li	a4,16
    800040b6:	86a6                	mv	a3,s1
    800040b8:	fc040613          	addi	a2,s0,-64
    800040bc:	4581                	li	a1,0
    800040be:	854a                	mv	a0,s2
    800040c0:	00000097          	auipc	ra,0x0
    800040c4:	b8a080e7          	jalr	-1142(ra) # 80003c4a <readi>
    800040c8:	47c1                	li	a5,16
    800040ca:	06f51163          	bne	a0,a5,8000412c <dirlink+0xa2>
    if(de.inum == 0)
    800040ce:	fc045783          	lhu	a5,-64(s0)
    800040d2:	c791                	beqz	a5,800040de <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040d4:	24c1                	addiw	s1,s1,16
    800040d6:	04c92783          	lw	a5,76(s2)
    800040da:	fcf4ede3          	bltu	s1,a5,800040b4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040de:	4639                	li	a2,14
    800040e0:	85d2                	mv	a1,s4
    800040e2:	fc240513          	addi	a0,s0,-62
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	cec080e7          	jalr	-788(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800040ee:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f2:	4741                	li	a4,16
    800040f4:	86a6                	mv	a3,s1
    800040f6:	fc040613          	addi	a2,s0,-64
    800040fa:	4581                	li	a1,0
    800040fc:	854a                	mv	a0,s2
    800040fe:	00000097          	auipc	ra,0x0
    80004102:	c44080e7          	jalr	-956(ra) # 80003d42 <writei>
    80004106:	872a                	mv	a4,a0
    80004108:	47c1                	li	a5,16
  return 0;
    8000410a:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000410c:	02f71863          	bne	a4,a5,8000413c <dirlink+0xb2>
}
    80004110:	70e2                	ld	ra,56(sp)
    80004112:	7442                	ld	s0,48(sp)
    80004114:	74a2                	ld	s1,40(sp)
    80004116:	7902                	ld	s2,32(sp)
    80004118:	69e2                	ld	s3,24(sp)
    8000411a:	6a42                	ld	s4,16(sp)
    8000411c:	6121                	addi	sp,sp,64
    8000411e:	8082                	ret
    iput(ip);
    80004120:	00000097          	auipc	ra,0x0
    80004124:	a30080e7          	jalr	-1488(ra) # 80003b50 <iput>
    return -1;
    80004128:	557d                	li	a0,-1
    8000412a:	b7dd                	j	80004110 <dirlink+0x86>
      panic("dirlink read");
    8000412c:	00004517          	auipc	a0,0x4
    80004130:	66c50513          	addi	a0,a0,1644 # 80008798 <syscalls+0x1c8>
    80004134:	ffffc097          	auipc	ra,0xffffc
    80004138:	3f6080e7          	jalr	1014(ra) # 8000052a <panic>
    panic("dirlink");
    8000413c:	00004517          	auipc	a0,0x4
    80004140:	7e450513          	addi	a0,a0,2020 # 80008920 <syscalls+0x350>
    80004144:	ffffc097          	auipc	ra,0xffffc
    80004148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000414c <namei>:

struct inode*
namei(char *path)
{
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004154:	fe040613          	addi	a2,s0,-32
    80004158:	4581                	li	a1,0
    8000415a:	00000097          	auipc	ra,0x0
    8000415e:	dd0080e7          	jalr	-560(ra) # 80003f2a <namex>
}
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	6105                	addi	sp,sp,32
    80004168:	8082                	ret

000000008000416a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000416a:	1141                	addi	sp,sp,-16
    8000416c:	e406                	sd	ra,8(sp)
    8000416e:	e022                	sd	s0,0(sp)
    80004170:	0800                	addi	s0,sp,16
    80004172:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004174:	4585                	li	a1,1
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	db4080e7          	jalr	-588(ra) # 80003f2a <namex>
}
    8000417e:	60a2                	ld	ra,8(sp)
    80004180:	6402                	ld	s0,0(sp)
    80004182:	0141                	addi	sp,sp,16
    80004184:	8082                	ret

0000000080004186 <itoa>:


#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
    80004186:	1101                	addi	sp,sp,-32
    80004188:	ec22                	sd	s0,24(sp)
    8000418a:	1000                	addi	s0,sp,32
    8000418c:	872a                	mv	a4,a0
    8000418e:	852e                	mv	a0,a1
    char const digit[] = "0123456789";
    80004190:	00004797          	auipc	a5,0x4
    80004194:	61878793          	addi	a5,a5,1560 # 800087a8 <syscalls+0x1d8>
    80004198:	6394                	ld	a3,0(a5)
    8000419a:	fed43023          	sd	a3,-32(s0)
    8000419e:	0087d683          	lhu	a3,8(a5)
    800041a2:	fed41423          	sh	a3,-24(s0)
    800041a6:	00a7c783          	lbu	a5,10(a5)
    800041aa:	fef40523          	sb	a5,-22(s0)
    char* p = b;
    800041ae:	87ae                	mv	a5,a1
    if(i<0){
    800041b0:	02074b63          	bltz	a4,800041e6 <itoa+0x60>
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    800041b4:	86ba                	mv	a3,a4
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
    800041b6:	4629                	li	a2,10
        ++p;
    800041b8:	0785                	addi	a5,a5,1
        shifter = shifter/10;
    800041ba:	02c6c6bb          	divw	a3,a3,a2
    }while(shifter);
    800041be:	feed                	bnez	a3,800041b8 <itoa+0x32>
    *p = '\0';
    800041c0:	00078023          	sb	zero,0(a5)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
    800041c4:	4629                	li	a2,10
    800041c6:	17fd                	addi	a5,a5,-1
    800041c8:	02c766bb          	remw	a3,a4,a2
    800041cc:	ff040593          	addi	a1,s0,-16
    800041d0:	96ae                	add	a3,a3,a1
    800041d2:	ff06c683          	lbu	a3,-16(a3)
    800041d6:	00d78023          	sb	a3,0(a5)
        i = i/10;
    800041da:	02c7473b          	divw	a4,a4,a2
    }while(i);
    800041de:	f765                	bnez	a4,800041c6 <itoa+0x40>
    return b;
}
    800041e0:	6462                	ld	s0,24(sp)
    800041e2:	6105                	addi	sp,sp,32
    800041e4:	8082                	ret
        *p++ = '-';
    800041e6:	00158793          	addi	a5,a1,1
    800041ea:	02d00693          	li	a3,45
    800041ee:	00d58023          	sb	a3,0(a1)
        i *= -1;
    800041f2:	40e0073b          	negw	a4,a4
    800041f6:	bf7d                	j	800041b4 <itoa+0x2e>

00000000800041f8 <removeSwapFile>:
//remove swap file of proc p;
int
removeSwapFile(struct proc* p)
{
    800041f8:	711d                	addi	sp,sp,-96
    800041fa:	ec86                	sd	ra,88(sp)
    800041fc:	e8a2                	sd	s0,80(sp)
    800041fe:	e4a6                	sd	s1,72(sp)
    80004200:	e0ca                	sd	s2,64(sp)
    80004202:	1080                	addi	s0,sp,96
    80004204:	84aa                	mv	s1,a0
  //path of proccess
  char path[DIGITS];
  memmove(path,"/.swap", 6);
    80004206:	4619                	li	a2,6
    80004208:	00004597          	auipc	a1,0x4
    8000420c:	5b058593          	addi	a1,a1,1456 # 800087b8 <syscalls+0x1e8>
    80004210:	fd040513          	addi	a0,s0,-48
    80004214:	ffffd097          	auipc	ra,0xffffd
    80004218:	b06080e7          	jalr	-1274(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    8000421c:	fd640593          	addi	a1,s0,-42
    80004220:	5888                	lw	a0,48(s1)
    80004222:	00000097          	auipc	ra,0x0
    80004226:	f64080e7          	jalr	-156(ra) # 80004186 <itoa>
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ];
  uint off;

  if(0 == p->swapFile)
    8000422a:	1684b503          	ld	a0,360(s1)
    8000422e:	16050763          	beqz	a0,8000439c <removeSwapFile+0x1a4>
  {
    return -1;
  }
  fileclose(p->swapFile);
    80004232:	00001097          	auipc	ra,0x1
    80004236:	918080e7          	jalr	-1768(ra) # 80004b4a <fileclose>

  begin_op();
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	444080e7          	jalr	1092(ra) # 8000467e <begin_op>
  if((dp = nameiparent(path, name)) == 0)
    80004242:	fb040593          	addi	a1,s0,-80
    80004246:	fd040513          	addi	a0,s0,-48
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	f20080e7          	jalr	-224(ra) # 8000416a <nameiparent>
    80004252:	892a                	mv	s2,a0
    80004254:	cd69                	beqz	a0,8000432e <removeSwapFile+0x136>
  {
    end_op();
    return -1;
  }

  ilock(dp);
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	740080e7          	jalr	1856(ra) # 80003996 <ilock>

    // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000425e:	00004597          	auipc	a1,0x4
    80004262:	56258593          	addi	a1,a1,1378 # 800087c0 <syscalls+0x1f0>
    80004266:	fb040513          	addi	a0,s0,-80
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	bf6080e7          	jalr	-1034(ra) # 80003e60 <namecmp>
    80004272:	c57d                	beqz	a0,80004360 <removeSwapFile+0x168>
    80004274:	00004597          	auipc	a1,0x4
    80004278:	55458593          	addi	a1,a1,1364 # 800087c8 <syscalls+0x1f8>
    8000427c:	fb040513          	addi	a0,s0,-80
    80004280:	00000097          	auipc	ra,0x0
    80004284:	be0080e7          	jalr	-1056(ra) # 80003e60 <namecmp>
    80004288:	cd61                	beqz	a0,80004360 <removeSwapFile+0x168>
     goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    8000428a:	fac40613          	addi	a2,s0,-84
    8000428e:	fb040593          	addi	a1,s0,-80
    80004292:	854a                	mv	a0,s2
    80004294:	00000097          	auipc	ra,0x0
    80004298:	be6080e7          	jalr	-1050(ra) # 80003e7a <dirlookup>
    8000429c:	84aa                	mv	s1,a0
    8000429e:	c169                	beqz	a0,80004360 <removeSwapFile+0x168>
    goto bad;
  ilock(ip);
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	6f6080e7          	jalr	1782(ra) # 80003996 <ilock>

  if(ip->nlink < 1)
    800042a8:	04a49783          	lh	a5,74(s1)
    800042ac:	08f05763          	blez	a5,8000433a <removeSwapFile+0x142>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    800042b0:	04449703          	lh	a4,68(s1)
    800042b4:	4785                	li	a5,1
    800042b6:	08f70a63          	beq	a4,a5,8000434a <removeSwapFile+0x152>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    800042ba:	4641                	li	a2,16
    800042bc:	4581                	li	a1,0
    800042be:	fc040513          	addi	a0,s0,-64
    800042c2:	ffffd097          	auipc	ra,0xffffd
    800042c6:	9fc080e7          	jalr	-1540(ra) # 80000cbe <memset>
  if(writei(dp,0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ca:	4741                	li	a4,16
    800042cc:	fac42683          	lw	a3,-84(s0)
    800042d0:	fc040613          	addi	a2,s0,-64
    800042d4:	4581                	li	a1,0
    800042d6:	854a                	mv	a0,s2
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	a6a080e7          	jalr	-1430(ra) # 80003d42 <writei>
    800042e0:	47c1                	li	a5,16
    800042e2:	08f51a63          	bne	a0,a5,80004376 <removeSwapFile+0x17e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    800042e6:	04449703          	lh	a4,68(s1)
    800042ea:	4785                	li	a5,1
    800042ec:	08f70d63          	beq	a4,a5,80004386 <removeSwapFile+0x18e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    800042f0:	854a                	mv	a0,s2
    800042f2:	00000097          	auipc	ra,0x0
    800042f6:	906080e7          	jalr	-1786(ra) # 80003bf8 <iunlockput>

  ip->nlink--;
    800042fa:	04a4d783          	lhu	a5,74(s1)
    800042fe:	37fd                	addiw	a5,a5,-1
    80004300:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004304:	8526                	mv	a0,s1
    80004306:	fffff097          	auipc	ra,0xfffff
    8000430a:	5c6080e7          	jalr	1478(ra) # 800038cc <iupdate>
  iunlockput(ip);
    8000430e:	8526                	mv	a0,s1
    80004310:	00000097          	auipc	ra,0x0
    80004314:	8e8080e7          	jalr	-1816(ra) # 80003bf8 <iunlockput>

  end_op();
    80004318:	00000097          	auipc	ra,0x0
    8000431c:	3e6080e7          	jalr	998(ra) # 800046fe <end_op>

  return 0;
    80004320:	4501                	li	a0,0
  bad:
    iunlockput(dp);
    end_op();
    return -1;

}
    80004322:	60e6                	ld	ra,88(sp)
    80004324:	6446                	ld	s0,80(sp)
    80004326:	64a6                	ld	s1,72(sp)
    80004328:	6906                	ld	s2,64(sp)
    8000432a:	6125                	addi	sp,sp,96
    8000432c:	8082                	ret
    end_op();
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	3d0080e7          	jalr	976(ra) # 800046fe <end_op>
    return -1;
    80004336:	557d                	li	a0,-1
    80004338:	b7ed                	j	80004322 <removeSwapFile+0x12a>
    panic("unlink: nlink < 1");
    8000433a:	00004517          	auipc	a0,0x4
    8000433e:	49650513          	addi	a0,a0,1174 # 800087d0 <syscalls+0x200>
    80004342:	ffffc097          	auipc	ra,0xffffc
    80004346:	1e8080e7          	jalr	488(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000434a:	8526                	mv	a0,s1
    8000434c:	00001097          	auipc	ra,0x1
    80004350:	79a080e7          	jalr	1946(ra) # 80005ae6 <isdirempty>
    80004354:	f13d                	bnez	a0,800042ba <removeSwapFile+0xc2>
    iunlockput(ip);
    80004356:	8526                	mv	a0,s1
    80004358:	00000097          	auipc	ra,0x0
    8000435c:	8a0080e7          	jalr	-1888(ra) # 80003bf8 <iunlockput>
    iunlockput(dp);
    80004360:	854a                	mv	a0,s2
    80004362:	00000097          	auipc	ra,0x0
    80004366:	896080e7          	jalr	-1898(ra) # 80003bf8 <iunlockput>
    end_op();
    8000436a:	00000097          	auipc	ra,0x0
    8000436e:	394080e7          	jalr	916(ra) # 800046fe <end_op>
    return -1;
    80004372:	557d                	li	a0,-1
    80004374:	b77d                	j	80004322 <removeSwapFile+0x12a>
    panic("unlink: writei");
    80004376:	00004517          	auipc	a0,0x4
    8000437a:	47250513          	addi	a0,a0,1138 # 800087e8 <syscalls+0x218>
    8000437e:	ffffc097          	auipc	ra,0xffffc
    80004382:	1ac080e7          	jalr	428(ra) # 8000052a <panic>
    dp->nlink--;
    80004386:	04a95783          	lhu	a5,74(s2)
    8000438a:	37fd                	addiw	a5,a5,-1
    8000438c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80004390:	854a                	mv	a0,s2
    80004392:	fffff097          	auipc	ra,0xfffff
    80004396:	53a080e7          	jalr	1338(ra) # 800038cc <iupdate>
    8000439a:	bf99                	j	800042f0 <removeSwapFile+0xf8>
    return -1;
    8000439c:	557d                	li	a0,-1
    8000439e:	b751                	j	80004322 <removeSwapFile+0x12a>

00000000800043a0 <createSwapFile>:


//return 0 on success
int
createSwapFile(struct proc* p)
{
    800043a0:	7179                	addi	sp,sp,-48
    800043a2:	f406                	sd	ra,40(sp)
    800043a4:	f022                	sd	s0,32(sp)
    800043a6:	ec26                	sd	s1,24(sp)
    800043a8:	e84a                	sd	s2,16(sp)
    800043aa:	1800                	addi	s0,sp,48
    800043ac:	84aa                	mv	s1,a0

  char path[DIGITS];
  memmove(path,"/.swap", 6);
    800043ae:	4619                	li	a2,6
    800043b0:	00004597          	auipc	a1,0x4
    800043b4:	40858593          	addi	a1,a1,1032 # 800087b8 <syscalls+0x1e8>
    800043b8:	fd040513          	addi	a0,s0,-48
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	95e080e7          	jalr	-1698(ra) # 80000d1a <memmove>
  itoa(p->pid, path+ 6);
    800043c4:	fd640593          	addi	a1,s0,-42
    800043c8:	5888                	lw	a0,48(s1)
    800043ca:	00000097          	auipc	ra,0x0
    800043ce:	dbc080e7          	jalr	-580(ra) # 80004186 <itoa>

  begin_op();
    800043d2:	00000097          	auipc	ra,0x0
    800043d6:	2ac080e7          	jalr	684(ra) # 8000467e <begin_op>
  
  struct inode * in = create(path, T_FILE, 0, 0);
    800043da:	4681                	li	a3,0
    800043dc:	4601                	li	a2,0
    800043de:	4589                	li	a1,2
    800043e0:	fd040513          	addi	a0,s0,-48
    800043e4:	00002097          	auipc	ra,0x2
    800043e8:	8f6080e7          	jalr	-1802(ra) # 80005cda <create>
    800043ec:	892a                	mv	s2,a0
  iunlock(in);
    800043ee:	fffff097          	auipc	ra,0xfffff
    800043f2:	66a080e7          	jalr	1642(ra) # 80003a58 <iunlock>
  p->swapFile = filealloc();
    800043f6:	00000097          	auipc	ra,0x0
    800043fa:	698080e7          	jalr	1688(ra) # 80004a8e <filealloc>
    800043fe:	16a4b423          	sd	a0,360(s1)
  if (p->swapFile == 0)
    80004402:	cd1d                	beqz	a0,80004440 <createSwapFile+0xa0>
    panic("no slot for files on /store");

  p->swapFile->ip = in;
    80004404:	01253c23          	sd	s2,24(a0)
  p->swapFile->type = FD_INODE;
    80004408:	1684b703          	ld	a4,360(s1)
    8000440c:	4789                	li	a5,2
    8000440e:	c31c                	sw	a5,0(a4)
  p->swapFile->off = 0;
    80004410:	1684b703          	ld	a4,360(s1)
    80004414:	02072023          	sw	zero,32(a4) # 43020 <_entry-0x7ffbcfe0>
  p->swapFile->readable = O_WRONLY;
    80004418:	1684b703          	ld	a4,360(s1)
    8000441c:	4685                	li	a3,1
    8000441e:	00d70423          	sb	a3,8(a4)
  p->swapFile->writable = O_RDWR;
    80004422:	1684b703          	ld	a4,360(s1)
    80004426:	00f704a3          	sb	a5,9(a4)
    end_op();
    8000442a:	00000097          	auipc	ra,0x0
    8000442e:	2d4080e7          	jalr	724(ra) # 800046fe <end_op>

    return 0;
}
    80004432:	4501                	li	a0,0
    80004434:	70a2                	ld	ra,40(sp)
    80004436:	7402                	ld	s0,32(sp)
    80004438:	64e2                	ld	s1,24(sp)
    8000443a:	6942                	ld	s2,16(sp)
    8000443c:	6145                	addi	sp,sp,48
    8000443e:	8082                	ret
    panic("no slot for files on /store");
    80004440:	00004517          	auipc	a0,0x4
    80004444:	3b850513          	addi	a0,a0,952 # 800087f8 <syscalls+0x228>
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	0e2080e7          	jalr	226(ra) # 8000052a <panic>

0000000080004450 <writeToSwapFile>:

//return as sys_write (-1 when error)
int
writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004450:	1141                	addi	sp,sp,-16
    80004452:	e406                	sd	ra,8(sp)
    80004454:	e022                	sd	s0,0(sp)
    80004456:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    80004458:	16853783          	ld	a5,360(a0)
    8000445c:	d390                	sw	a2,32(a5)
  return kfilewrite(p->swapFile, (uint64)buffer, size);
    8000445e:	8636                	mv	a2,a3
    80004460:	16853503          	ld	a0,360(a0)
    80004464:	00001097          	auipc	ra,0x1
    80004468:	ad8080e7          	jalr	-1320(ra) # 80004f3c <kfilewrite>
}
    8000446c:	60a2                	ld	ra,8(sp)
    8000446e:	6402                	ld	s0,0(sp)
    80004470:	0141                	addi	sp,sp,16
    80004472:	8082                	ret

0000000080004474 <readFromSwapFile>:

//return as sys_read (-1 when error)
int
readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size)
{
    80004474:	1141                	addi	sp,sp,-16
    80004476:	e406                	sd	ra,8(sp)
    80004478:	e022                	sd	s0,0(sp)
    8000447a:	0800                	addi	s0,sp,16
  p->swapFile->off = placeOnFile;
    8000447c:	16853783          	ld	a5,360(a0)
    80004480:	d390                	sw	a2,32(a5)
  return kfileread(p->swapFile, (uint64)buffer,  size);
    80004482:	8636                	mv	a2,a3
    80004484:	16853503          	ld	a0,360(a0)
    80004488:	00001097          	auipc	ra,0x1
    8000448c:	9f2080e7          	jalr	-1550(ra) # 80004e7a <kfileread>
    80004490:	60a2                	ld	ra,8(sp)
    80004492:	6402                	ld	s0,0(sp)
    80004494:	0141                	addi	sp,sp,16
    80004496:	8082                	ret

0000000080004498 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004498:	1101                	addi	sp,sp,-32
    8000449a:	ec06                	sd	ra,24(sp)
    8000449c:	e822                	sd	s0,16(sp)
    8000449e:	e426                	sd	s1,8(sp)
    800044a0:	e04a                	sd	s2,0(sp)
    800044a2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044a4:	00025917          	auipc	s2,0x25
    800044a8:	3cc90913          	addi	s2,s2,972 # 80029870 <log>
    800044ac:	01892583          	lw	a1,24(s2)
    800044b0:	02892503          	lw	a0,40(s2)
    800044b4:	fffff097          	auipc	ra,0xfffff
    800044b8:	cde080e7          	jalr	-802(ra) # 80003192 <bread>
    800044bc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044be:	02c92683          	lw	a3,44(s2)
    800044c2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044c4:	02d05863          	blez	a3,800044f4 <write_head+0x5c>
    800044c8:	00025797          	auipc	a5,0x25
    800044cc:	3d878793          	addi	a5,a5,984 # 800298a0 <log+0x30>
    800044d0:	05c50713          	addi	a4,a0,92
    800044d4:	36fd                	addiw	a3,a3,-1
    800044d6:	02069613          	slli	a2,a3,0x20
    800044da:	01e65693          	srli	a3,a2,0x1e
    800044de:	00025617          	auipc	a2,0x25
    800044e2:	3c660613          	addi	a2,a2,966 # 800298a4 <log+0x34>
    800044e6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044e8:	4390                	lw	a2,0(a5)
    800044ea:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044ec:	0791                	addi	a5,a5,4
    800044ee:	0711                	addi	a4,a4,4
    800044f0:	fed79ce3          	bne	a5,a3,800044e8 <write_head+0x50>
  }
  bwrite(buf);
    800044f4:	8526                	mv	a0,s1
    800044f6:	fffff097          	auipc	ra,0xfffff
    800044fa:	d8e080e7          	jalr	-626(ra) # 80003284 <bwrite>
  brelse(buf);
    800044fe:	8526                	mv	a0,s1
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	dc2080e7          	jalr	-574(ra) # 800032c2 <brelse>
}
    80004508:	60e2                	ld	ra,24(sp)
    8000450a:	6442                	ld	s0,16(sp)
    8000450c:	64a2                	ld	s1,8(sp)
    8000450e:	6902                	ld	s2,0(sp)
    80004510:	6105                	addi	sp,sp,32
    80004512:	8082                	ret

0000000080004514 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004514:	00025797          	auipc	a5,0x25
    80004518:	3887a783          	lw	a5,904(a5) # 8002989c <log+0x2c>
    8000451c:	0af05d63          	blez	a5,800045d6 <install_trans+0xc2>
{
    80004520:	7139                	addi	sp,sp,-64
    80004522:	fc06                	sd	ra,56(sp)
    80004524:	f822                	sd	s0,48(sp)
    80004526:	f426                	sd	s1,40(sp)
    80004528:	f04a                	sd	s2,32(sp)
    8000452a:	ec4e                	sd	s3,24(sp)
    8000452c:	e852                	sd	s4,16(sp)
    8000452e:	e456                	sd	s5,8(sp)
    80004530:	e05a                	sd	s6,0(sp)
    80004532:	0080                	addi	s0,sp,64
    80004534:	8b2a                	mv	s6,a0
    80004536:	00025a97          	auipc	s5,0x25
    8000453a:	36aa8a93          	addi	s5,s5,874 # 800298a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000453e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004540:	00025997          	auipc	s3,0x25
    80004544:	33098993          	addi	s3,s3,816 # 80029870 <log>
    80004548:	a00d                	j	8000456a <install_trans+0x56>
    brelse(lbuf);
    8000454a:	854a                	mv	a0,s2
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	d76080e7          	jalr	-650(ra) # 800032c2 <brelse>
    brelse(dbuf);
    80004554:	8526                	mv	a0,s1
    80004556:	fffff097          	auipc	ra,0xfffff
    8000455a:	d6c080e7          	jalr	-660(ra) # 800032c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000455e:	2a05                	addiw	s4,s4,1
    80004560:	0a91                	addi	s5,s5,4
    80004562:	02c9a783          	lw	a5,44(s3)
    80004566:	04fa5e63          	bge	s4,a5,800045c2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000456a:	0189a583          	lw	a1,24(s3)
    8000456e:	014585bb          	addw	a1,a1,s4
    80004572:	2585                	addiw	a1,a1,1
    80004574:	0289a503          	lw	a0,40(s3)
    80004578:	fffff097          	auipc	ra,0xfffff
    8000457c:	c1a080e7          	jalr	-998(ra) # 80003192 <bread>
    80004580:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004582:	000aa583          	lw	a1,0(s5)
    80004586:	0289a503          	lw	a0,40(s3)
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	c08080e7          	jalr	-1016(ra) # 80003192 <bread>
    80004592:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004594:	40000613          	li	a2,1024
    80004598:	05890593          	addi	a1,s2,88
    8000459c:	05850513          	addi	a0,a0,88
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	77a080e7          	jalr	1914(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    800045a8:	8526                	mv	a0,s1
    800045aa:	fffff097          	auipc	ra,0xfffff
    800045ae:	cda080e7          	jalr	-806(ra) # 80003284 <bwrite>
    if(recovering == 0)
    800045b2:	f80b1ce3          	bnez	s6,8000454a <install_trans+0x36>
      bunpin(dbuf);
    800045b6:	8526                	mv	a0,s1
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	de4080e7          	jalr	-540(ra) # 8000339c <bunpin>
    800045c0:	b769                	j	8000454a <install_trans+0x36>
}
    800045c2:	70e2                	ld	ra,56(sp)
    800045c4:	7442                	ld	s0,48(sp)
    800045c6:	74a2                	ld	s1,40(sp)
    800045c8:	7902                	ld	s2,32(sp)
    800045ca:	69e2                	ld	s3,24(sp)
    800045cc:	6a42                	ld	s4,16(sp)
    800045ce:	6aa2                	ld	s5,8(sp)
    800045d0:	6b02                	ld	s6,0(sp)
    800045d2:	6121                	addi	sp,sp,64
    800045d4:	8082                	ret
    800045d6:	8082                	ret

00000000800045d8 <initlog>:
{
    800045d8:	7179                	addi	sp,sp,-48
    800045da:	f406                	sd	ra,40(sp)
    800045dc:	f022                	sd	s0,32(sp)
    800045de:	ec26                	sd	s1,24(sp)
    800045e0:	e84a                	sd	s2,16(sp)
    800045e2:	e44e                	sd	s3,8(sp)
    800045e4:	1800                	addi	s0,sp,48
    800045e6:	892a                	mv	s2,a0
    800045e8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045ea:	00025497          	auipc	s1,0x25
    800045ee:	28648493          	addi	s1,s1,646 # 80029870 <log>
    800045f2:	00004597          	auipc	a1,0x4
    800045f6:	22658593          	addi	a1,a1,550 # 80008818 <syscalls+0x248>
    800045fa:	8526                	mv	a0,s1
    800045fc:	ffffc097          	auipc	ra,0xffffc
    80004600:	536080e7          	jalr	1334(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    80004604:	0149a583          	lw	a1,20(s3)
    80004608:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000460a:	0109a783          	lw	a5,16(s3)
    8000460e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004610:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004614:	854a                	mv	a0,s2
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	b7c080e7          	jalr	-1156(ra) # 80003192 <bread>
  log.lh.n = lh->n;
    8000461e:	4d34                	lw	a3,88(a0)
    80004620:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004622:	02d05663          	blez	a3,8000464e <initlog+0x76>
    80004626:	05c50793          	addi	a5,a0,92
    8000462a:	00025717          	auipc	a4,0x25
    8000462e:	27670713          	addi	a4,a4,630 # 800298a0 <log+0x30>
    80004632:	36fd                	addiw	a3,a3,-1
    80004634:	02069613          	slli	a2,a3,0x20
    80004638:	01e65693          	srli	a3,a2,0x1e
    8000463c:	06050613          	addi	a2,a0,96
    80004640:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004642:	4390                	lw	a2,0(a5)
    80004644:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004646:	0791                	addi	a5,a5,4
    80004648:	0711                	addi	a4,a4,4
    8000464a:	fed79ce3          	bne	a5,a3,80004642 <initlog+0x6a>
  brelse(buf);
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	c74080e7          	jalr	-908(ra) # 800032c2 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004656:	4505                	li	a0,1
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	ebc080e7          	jalr	-324(ra) # 80004514 <install_trans>
  log.lh.n = 0;
    80004660:	00025797          	auipc	a5,0x25
    80004664:	2207ae23          	sw	zero,572(a5) # 8002989c <log+0x2c>
  write_head(); // clear the log
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	e30080e7          	jalr	-464(ra) # 80004498 <write_head>
}
    80004670:	70a2                	ld	ra,40(sp)
    80004672:	7402                	ld	s0,32(sp)
    80004674:	64e2                	ld	s1,24(sp)
    80004676:	6942                	ld	s2,16(sp)
    80004678:	69a2                	ld	s3,8(sp)
    8000467a:	6145                	addi	sp,sp,48
    8000467c:	8082                	ret

000000008000467e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000467e:	1101                	addi	sp,sp,-32
    80004680:	ec06                	sd	ra,24(sp)
    80004682:	e822                	sd	s0,16(sp)
    80004684:	e426                	sd	s1,8(sp)
    80004686:	e04a                	sd	s2,0(sp)
    80004688:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000468a:	00025517          	auipc	a0,0x25
    8000468e:	1e650513          	addi	a0,a0,486 # 80029870 <log>
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	530080e7          	jalr	1328(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    8000469a:	00025497          	auipc	s1,0x25
    8000469e:	1d648493          	addi	s1,s1,470 # 80029870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046a2:	4979                	li	s2,30
    800046a4:	a039                	j	800046b2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800046a6:	85a6                	mv	a1,s1
    800046a8:	8526                	mv	a0,s1
    800046aa:	ffffe097          	auipc	ra,0xffffe
    800046ae:	878080e7          	jalr	-1928(ra) # 80001f22 <sleep>
    if(log.committing){
    800046b2:	50dc                	lw	a5,36(s1)
    800046b4:	fbed                	bnez	a5,800046a6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046b6:	509c                	lw	a5,32(s1)
    800046b8:	0017871b          	addiw	a4,a5,1
    800046bc:	0007069b          	sext.w	a3,a4
    800046c0:	0027179b          	slliw	a5,a4,0x2
    800046c4:	9fb9                	addw	a5,a5,a4
    800046c6:	0017979b          	slliw	a5,a5,0x1
    800046ca:	54d8                	lw	a4,44(s1)
    800046cc:	9fb9                	addw	a5,a5,a4
    800046ce:	00f95963          	bge	s2,a5,800046e0 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046d2:	85a6                	mv	a1,s1
    800046d4:	8526                	mv	a0,s1
    800046d6:	ffffe097          	auipc	ra,0xffffe
    800046da:	84c080e7          	jalr	-1972(ra) # 80001f22 <sleep>
    800046de:	bfd1                	j	800046b2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046e0:	00025517          	auipc	a0,0x25
    800046e4:	19050513          	addi	a0,a0,400 # 80029870 <log>
    800046e8:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	58c080e7          	jalr	1420(ra) # 80000c76 <release>
      break;
    }
  }
}
    800046f2:	60e2                	ld	ra,24(sp)
    800046f4:	6442                	ld	s0,16(sp)
    800046f6:	64a2                	ld	s1,8(sp)
    800046f8:	6902                	ld	s2,0(sp)
    800046fa:	6105                	addi	sp,sp,32
    800046fc:	8082                	ret

00000000800046fe <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046fe:	7139                	addi	sp,sp,-64
    80004700:	fc06                	sd	ra,56(sp)
    80004702:	f822                	sd	s0,48(sp)
    80004704:	f426                	sd	s1,40(sp)
    80004706:	f04a                	sd	s2,32(sp)
    80004708:	ec4e                	sd	s3,24(sp)
    8000470a:	e852                	sd	s4,16(sp)
    8000470c:	e456                	sd	s5,8(sp)
    8000470e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004710:	00025497          	auipc	s1,0x25
    80004714:	16048493          	addi	s1,s1,352 # 80029870 <log>
    80004718:	8526                	mv	a0,s1
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	4a8080e7          	jalr	1192(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    80004722:	509c                	lw	a5,32(s1)
    80004724:	37fd                	addiw	a5,a5,-1
    80004726:	0007891b          	sext.w	s2,a5
    8000472a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000472c:	50dc                	lw	a5,36(s1)
    8000472e:	e7b9                	bnez	a5,8000477c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004730:	04091e63          	bnez	s2,8000478c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004734:	00025497          	auipc	s1,0x25
    80004738:	13c48493          	addi	s1,s1,316 # 80029870 <log>
    8000473c:	4785                	li	a5,1
    8000473e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004740:	8526                	mv	a0,s1
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	534080e7          	jalr	1332(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000474a:	54dc                	lw	a5,44(s1)
    8000474c:	06f04763          	bgtz	a5,800047ba <end_op+0xbc>
    acquire(&log.lock);
    80004750:	00025497          	auipc	s1,0x25
    80004754:	12048493          	addi	s1,s1,288 # 80029870 <log>
    80004758:	8526                	mv	a0,s1
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	468080e7          	jalr	1128(ra) # 80000bc2 <acquire>
    log.committing = 0;
    80004762:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004766:	8526                	mv	a0,s1
    80004768:	ffffe097          	auipc	ra,0xffffe
    8000476c:	946080e7          	jalr	-1722(ra) # 800020ae <wakeup>
    release(&log.lock);
    80004770:	8526                	mv	a0,s1
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	504080e7          	jalr	1284(ra) # 80000c76 <release>
}
    8000477a:	a03d                	j	800047a8 <end_op+0xaa>
    panic("log.committing");
    8000477c:	00004517          	auipc	a0,0x4
    80004780:	0a450513          	addi	a0,a0,164 # 80008820 <syscalls+0x250>
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	da6080e7          	jalr	-602(ra) # 8000052a <panic>
    wakeup(&log);
    8000478c:	00025497          	auipc	s1,0x25
    80004790:	0e448493          	addi	s1,s1,228 # 80029870 <log>
    80004794:	8526                	mv	a0,s1
    80004796:	ffffe097          	auipc	ra,0xffffe
    8000479a:	918080e7          	jalr	-1768(ra) # 800020ae <wakeup>
  release(&log.lock);
    8000479e:	8526                	mv	a0,s1
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	4d6080e7          	jalr	1238(ra) # 80000c76 <release>
}
    800047a8:	70e2                	ld	ra,56(sp)
    800047aa:	7442                	ld	s0,48(sp)
    800047ac:	74a2                	ld	s1,40(sp)
    800047ae:	7902                	ld	s2,32(sp)
    800047b0:	69e2                	ld	s3,24(sp)
    800047b2:	6a42                	ld	s4,16(sp)
    800047b4:	6aa2                	ld	s5,8(sp)
    800047b6:	6121                	addi	sp,sp,64
    800047b8:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ba:	00025a97          	auipc	s5,0x25
    800047be:	0e6a8a93          	addi	s5,s5,230 # 800298a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047c2:	00025a17          	auipc	s4,0x25
    800047c6:	0aea0a13          	addi	s4,s4,174 # 80029870 <log>
    800047ca:	018a2583          	lw	a1,24(s4)
    800047ce:	012585bb          	addw	a1,a1,s2
    800047d2:	2585                	addiw	a1,a1,1
    800047d4:	028a2503          	lw	a0,40(s4)
    800047d8:	fffff097          	auipc	ra,0xfffff
    800047dc:	9ba080e7          	jalr	-1606(ra) # 80003192 <bread>
    800047e0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047e2:	000aa583          	lw	a1,0(s5)
    800047e6:	028a2503          	lw	a0,40(s4)
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	9a8080e7          	jalr	-1624(ra) # 80003192 <bread>
    800047f2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047f4:	40000613          	li	a2,1024
    800047f8:	05850593          	addi	a1,a0,88
    800047fc:	05848513          	addi	a0,s1,88
    80004800:	ffffc097          	auipc	ra,0xffffc
    80004804:	51a080e7          	jalr	1306(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    80004808:	8526                	mv	a0,s1
    8000480a:	fffff097          	auipc	ra,0xfffff
    8000480e:	a7a080e7          	jalr	-1414(ra) # 80003284 <bwrite>
    brelse(from);
    80004812:	854e                	mv	a0,s3
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	aae080e7          	jalr	-1362(ra) # 800032c2 <brelse>
    brelse(to);
    8000481c:	8526                	mv	a0,s1
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	aa4080e7          	jalr	-1372(ra) # 800032c2 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004826:	2905                	addiw	s2,s2,1
    80004828:	0a91                	addi	s5,s5,4
    8000482a:	02ca2783          	lw	a5,44(s4)
    8000482e:	f8f94ee3          	blt	s2,a5,800047ca <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004832:	00000097          	auipc	ra,0x0
    80004836:	c66080e7          	jalr	-922(ra) # 80004498 <write_head>
    install_trans(0); // Now install writes to home locations
    8000483a:	4501                	li	a0,0
    8000483c:	00000097          	auipc	ra,0x0
    80004840:	cd8080e7          	jalr	-808(ra) # 80004514 <install_trans>
    log.lh.n = 0;
    80004844:	00025797          	auipc	a5,0x25
    80004848:	0407ac23          	sw	zero,88(a5) # 8002989c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	c4c080e7          	jalr	-948(ra) # 80004498 <write_head>
    80004854:	bdf5                	j	80004750 <end_op+0x52>

0000000080004856 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	e04a                	sd	s2,0(sp)
    80004860:	1000                	addi	s0,sp,32
    80004862:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004864:	00025917          	auipc	s2,0x25
    80004868:	00c90913          	addi	s2,s2,12 # 80029870 <log>
    8000486c:	854a                	mv	a0,s2
    8000486e:	ffffc097          	auipc	ra,0xffffc
    80004872:	354080e7          	jalr	852(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004876:	02c92603          	lw	a2,44(s2)
    8000487a:	47f5                	li	a5,29
    8000487c:	06c7c563          	blt	a5,a2,800048e6 <log_write+0x90>
    80004880:	00025797          	auipc	a5,0x25
    80004884:	00c7a783          	lw	a5,12(a5) # 8002988c <log+0x1c>
    80004888:	37fd                	addiw	a5,a5,-1
    8000488a:	04f65e63          	bge	a2,a5,800048e6 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000488e:	00025797          	auipc	a5,0x25
    80004892:	0027a783          	lw	a5,2(a5) # 80029890 <log+0x20>
    80004896:	06f05063          	blez	a5,800048f6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000489a:	4781                	li	a5,0
    8000489c:	06c05563          	blez	a2,80004906 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048a0:	44cc                	lw	a1,12(s1)
    800048a2:	00025717          	auipc	a4,0x25
    800048a6:	ffe70713          	addi	a4,a4,-2 # 800298a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048aa:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800048ac:	4314                	lw	a3,0(a4)
    800048ae:	04b68c63          	beq	a3,a1,80004906 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048b2:	2785                	addiw	a5,a5,1
    800048b4:	0711                	addi	a4,a4,4
    800048b6:	fef61be3          	bne	a2,a5,800048ac <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048ba:	0621                	addi	a2,a2,8
    800048bc:	060a                	slli	a2,a2,0x2
    800048be:	00025797          	auipc	a5,0x25
    800048c2:	fb278793          	addi	a5,a5,-78 # 80029870 <log>
    800048c6:	963e                	add	a2,a2,a5
    800048c8:	44dc                	lw	a5,12(s1)
    800048ca:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048cc:	8526                	mv	a0,s1
    800048ce:	fffff097          	auipc	ra,0xfffff
    800048d2:	a92080e7          	jalr	-1390(ra) # 80003360 <bpin>
    log.lh.n++;
    800048d6:	00025717          	auipc	a4,0x25
    800048da:	f9a70713          	addi	a4,a4,-102 # 80029870 <log>
    800048de:	575c                	lw	a5,44(a4)
    800048e0:	2785                	addiw	a5,a5,1
    800048e2:	d75c                	sw	a5,44(a4)
    800048e4:	a835                	j	80004920 <log_write+0xca>
    panic("too big a transaction");
    800048e6:	00004517          	auipc	a0,0x4
    800048ea:	f4a50513          	addi	a0,a0,-182 # 80008830 <syscalls+0x260>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	c3c080e7          	jalr	-964(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    800048f6:	00004517          	auipc	a0,0x4
    800048fa:	f5250513          	addi	a0,a0,-174 # 80008848 <syscalls+0x278>
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	c2c080e7          	jalr	-980(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    80004906:	00878713          	addi	a4,a5,8
    8000490a:	00271693          	slli	a3,a4,0x2
    8000490e:	00025717          	auipc	a4,0x25
    80004912:	f6270713          	addi	a4,a4,-158 # 80029870 <log>
    80004916:	9736                	add	a4,a4,a3
    80004918:	44d4                	lw	a3,12(s1)
    8000491a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000491c:	faf608e3          	beq	a2,a5,800048cc <log_write+0x76>
  }
  release(&log.lock);
    80004920:	00025517          	auipc	a0,0x25
    80004924:	f5050513          	addi	a0,a0,-176 # 80029870 <log>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	34e080e7          	jalr	846(ra) # 80000c76 <release>
}
    80004930:	60e2                	ld	ra,24(sp)
    80004932:	6442                	ld	s0,16(sp)
    80004934:	64a2                	ld	s1,8(sp)
    80004936:	6902                	ld	s2,0(sp)
    80004938:	6105                	addi	sp,sp,32
    8000493a:	8082                	ret

000000008000493c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000493c:	1101                	addi	sp,sp,-32
    8000493e:	ec06                	sd	ra,24(sp)
    80004940:	e822                	sd	s0,16(sp)
    80004942:	e426                	sd	s1,8(sp)
    80004944:	e04a                	sd	s2,0(sp)
    80004946:	1000                	addi	s0,sp,32
    80004948:	84aa                	mv	s1,a0
    8000494a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000494c:	00004597          	auipc	a1,0x4
    80004950:	f1c58593          	addi	a1,a1,-228 # 80008868 <syscalls+0x298>
    80004954:	0521                	addi	a0,a0,8
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	1dc080e7          	jalr	476(ra) # 80000b32 <initlock>
  lk->name = name;
    8000495e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004962:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004966:	0204a423          	sw	zero,40(s1)
}
    8000496a:	60e2                	ld	ra,24(sp)
    8000496c:	6442                	ld	s0,16(sp)
    8000496e:	64a2                	ld	s1,8(sp)
    80004970:	6902                	ld	s2,0(sp)
    80004972:	6105                	addi	sp,sp,32
    80004974:	8082                	ret

0000000080004976 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004976:	1101                	addi	sp,sp,-32
    80004978:	ec06                	sd	ra,24(sp)
    8000497a:	e822                	sd	s0,16(sp)
    8000497c:	e426                	sd	s1,8(sp)
    8000497e:	e04a                	sd	s2,0(sp)
    80004980:	1000                	addi	s0,sp,32
    80004982:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004984:	00850913          	addi	s2,a0,8
    80004988:	854a                	mv	a0,s2
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	238080e7          	jalr	568(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    80004992:	409c                	lw	a5,0(s1)
    80004994:	cb89                	beqz	a5,800049a6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004996:	85ca                	mv	a1,s2
    80004998:	8526                	mv	a0,s1
    8000499a:	ffffd097          	auipc	ra,0xffffd
    8000499e:	588080e7          	jalr	1416(ra) # 80001f22 <sleep>
  while (lk->locked) {
    800049a2:	409c                	lw	a5,0(s1)
    800049a4:	fbed                	bnez	a5,80004996 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049a6:	4785                	li	a5,1
    800049a8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049aa:	ffffd097          	auipc	ra,0xffffd
    800049ae:	ff0080e7          	jalr	-16(ra) # 8000199a <myproc>
    800049b2:	591c                	lw	a5,48(a0)
    800049b4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049b6:	854a                	mv	a0,s2
    800049b8:	ffffc097          	auipc	ra,0xffffc
    800049bc:	2be080e7          	jalr	702(ra) # 80000c76 <release>
}
    800049c0:	60e2                	ld	ra,24(sp)
    800049c2:	6442                	ld	s0,16(sp)
    800049c4:	64a2                	ld	s1,8(sp)
    800049c6:	6902                	ld	s2,0(sp)
    800049c8:	6105                	addi	sp,sp,32
    800049ca:	8082                	ret

00000000800049cc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049cc:	1101                	addi	sp,sp,-32
    800049ce:	ec06                	sd	ra,24(sp)
    800049d0:	e822                	sd	s0,16(sp)
    800049d2:	e426                	sd	s1,8(sp)
    800049d4:	e04a                	sd	s2,0(sp)
    800049d6:	1000                	addi	s0,sp,32
    800049d8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049da:	00850913          	addi	s2,a0,8
    800049de:	854a                	mv	a0,s2
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	1e2080e7          	jalr	482(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800049e8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049ec:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049f0:	8526                	mv	a0,s1
    800049f2:	ffffd097          	auipc	ra,0xffffd
    800049f6:	6bc080e7          	jalr	1724(ra) # 800020ae <wakeup>
  release(&lk->lk);
    800049fa:	854a                	mv	a0,s2
    800049fc:	ffffc097          	auipc	ra,0xffffc
    80004a00:	27a080e7          	jalr	634(ra) # 80000c76 <release>
}
    80004a04:	60e2                	ld	ra,24(sp)
    80004a06:	6442                	ld	s0,16(sp)
    80004a08:	64a2                	ld	s1,8(sp)
    80004a0a:	6902                	ld	s2,0(sp)
    80004a0c:	6105                	addi	sp,sp,32
    80004a0e:	8082                	ret

0000000080004a10 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a10:	7179                	addi	sp,sp,-48
    80004a12:	f406                	sd	ra,40(sp)
    80004a14:	f022                	sd	s0,32(sp)
    80004a16:	ec26                	sd	s1,24(sp)
    80004a18:	e84a                	sd	s2,16(sp)
    80004a1a:	e44e                	sd	s3,8(sp)
    80004a1c:	1800                	addi	s0,sp,48
    80004a1e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a20:	00850913          	addi	s2,a0,8
    80004a24:	854a                	mv	a0,s2
    80004a26:	ffffc097          	auipc	ra,0xffffc
    80004a2a:	19c080e7          	jalr	412(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a2e:	409c                	lw	a5,0(s1)
    80004a30:	ef99                	bnez	a5,80004a4e <holdingsleep+0x3e>
    80004a32:	4481                	li	s1,0
  release(&lk->lk);
    80004a34:	854a                	mv	a0,s2
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	240080e7          	jalr	576(ra) # 80000c76 <release>
  return r;
}
    80004a3e:	8526                	mv	a0,s1
    80004a40:	70a2                	ld	ra,40(sp)
    80004a42:	7402                	ld	s0,32(sp)
    80004a44:	64e2                	ld	s1,24(sp)
    80004a46:	6942                	ld	s2,16(sp)
    80004a48:	69a2                	ld	s3,8(sp)
    80004a4a:	6145                	addi	sp,sp,48
    80004a4c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a4e:	0284a983          	lw	s3,40(s1)
    80004a52:	ffffd097          	auipc	ra,0xffffd
    80004a56:	f48080e7          	jalr	-184(ra) # 8000199a <myproc>
    80004a5a:	5904                	lw	s1,48(a0)
    80004a5c:	413484b3          	sub	s1,s1,s3
    80004a60:	0014b493          	seqz	s1,s1
    80004a64:	bfc1                	j	80004a34 <holdingsleep+0x24>

0000000080004a66 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a66:	1141                	addi	sp,sp,-16
    80004a68:	e406                	sd	ra,8(sp)
    80004a6a:	e022                	sd	s0,0(sp)
    80004a6c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a6e:	00004597          	auipc	a1,0x4
    80004a72:	e0a58593          	addi	a1,a1,-502 # 80008878 <syscalls+0x2a8>
    80004a76:	00025517          	auipc	a0,0x25
    80004a7a:	f4250513          	addi	a0,a0,-190 # 800299b8 <ftable>
    80004a7e:	ffffc097          	auipc	ra,0xffffc
    80004a82:	0b4080e7          	jalr	180(ra) # 80000b32 <initlock>
}
    80004a86:	60a2                	ld	ra,8(sp)
    80004a88:	6402                	ld	s0,0(sp)
    80004a8a:	0141                	addi	sp,sp,16
    80004a8c:	8082                	ret

0000000080004a8e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a8e:	1101                	addi	sp,sp,-32
    80004a90:	ec06                	sd	ra,24(sp)
    80004a92:	e822                	sd	s0,16(sp)
    80004a94:	e426                	sd	s1,8(sp)
    80004a96:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a98:	00025517          	auipc	a0,0x25
    80004a9c:	f2050513          	addi	a0,a0,-224 # 800299b8 <ftable>
    80004aa0:	ffffc097          	auipc	ra,0xffffc
    80004aa4:	122080e7          	jalr	290(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004aa8:	00025497          	auipc	s1,0x25
    80004aac:	f2848493          	addi	s1,s1,-216 # 800299d0 <ftable+0x18>
    80004ab0:	00026717          	auipc	a4,0x26
    80004ab4:	ec070713          	addi	a4,a4,-320 # 8002a970 <ftable+0xfb8>
    if(f->ref == 0){
    80004ab8:	40dc                	lw	a5,4(s1)
    80004aba:	cf99                	beqz	a5,80004ad8 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004abc:	02848493          	addi	s1,s1,40
    80004ac0:	fee49ce3          	bne	s1,a4,80004ab8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004ac4:	00025517          	auipc	a0,0x25
    80004ac8:	ef450513          	addi	a0,a0,-268 # 800299b8 <ftable>
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	1aa080e7          	jalr	426(ra) # 80000c76 <release>
  return 0;
    80004ad4:	4481                	li	s1,0
    80004ad6:	a819                	j	80004aec <filealloc+0x5e>
      f->ref = 1;
    80004ad8:	4785                	li	a5,1
    80004ada:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004adc:	00025517          	auipc	a0,0x25
    80004ae0:	edc50513          	addi	a0,a0,-292 # 800299b8 <ftable>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	192080e7          	jalr	402(ra) # 80000c76 <release>
}
    80004aec:	8526                	mv	a0,s1
    80004aee:	60e2                	ld	ra,24(sp)
    80004af0:	6442                	ld	s0,16(sp)
    80004af2:	64a2                	ld	s1,8(sp)
    80004af4:	6105                	addi	sp,sp,32
    80004af6:	8082                	ret

0000000080004af8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004af8:	1101                	addi	sp,sp,-32
    80004afa:	ec06                	sd	ra,24(sp)
    80004afc:	e822                	sd	s0,16(sp)
    80004afe:	e426                	sd	s1,8(sp)
    80004b00:	1000                	addi	s0,sp,32
    80004b02:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b04:	00025517          	auipc	a0,0x25
    80004b08:	eb450513          	addi	a0,a0,-332 # 800299b8 <ftable>
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	0b6080e7          	jalr	182(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b14:	40dc                	lw	a5,4(s1)
    80004b16:	02f05263          	blez	a5,80004b3a <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b1a:	2785                	addiw	a5,a5,1
    80004b1c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b1e:	00025517          	auipc	a0,0x25
    80004b22:	e9a50513          	addi	a0,a0,-358 # 800299b8 <ftable>
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	150080e7          	jalr	336(ra) # 80000c76 <release>
  return f;
}
    80004b2e:	8526                	mv	a0,s1
    80004b30:	60e2                	ld	ra,24(sp)
    80004b32:	6442                	ld	s0,16(sp)
    80004b34:	64a2                	ld	s1,8(sp)
    80004b36:	6105                	addi	sp,sp,32
    80004b38:	8082                	ret
    panic("filedup");
    80004b3a:	00004517          	auipc	a0,0x4
    80004b3e:	d4650513          	addi	a0,a0,-698 # 80008880 <syscalls+0x2b0>
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	9e8080e7          	jalr	-1560(ra) # 8000052a <panic>

0000000080004b4a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b4a:	7139                	addi	sp,sp,-64
    80004b4c:	fc06                	sd	ra,56(sp)
    80004b4e:	f822                	sd	s0,48(sp)
    80004b50:	f426                	sd	s1,40(sp)
    80004b52:	f04a                	sd	s2,32(sp)
    80004b54:	ec4e                	sd	s3,24(sp)
    80004b56:	e852                	sd	s4,16(sp)
    80004b58:	e456                	sd	s5,8(sp)
    80004b5a:	0080                	addi	s0,sp,64
    80004b5c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b5e:	00025517          	auipc	a0,0x25
    80004b62:	e5a50513          	addi	a0,a0,-422 # 800299b8 <ftable>
    80004b66:	ffffc097          	auipc	ra,0xffffc
    80004b6a:	05c080e7          	jalr	92(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b6e:	40dc                	lw	a5,4(s1)
    80004b70:	06f05163          	blez	a5,80004bd2 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b74:	37fd                	addiw	a5,a5,-1
    80004b76:	0007871b          	sext.w	a4,a5
    80004b7a:	c0dc                	sw	a5,4(s1)
    80004b7c:	06e04363          	bgtz	a4,80004be2 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b80:	0004a903          	lw	s2,0(s1)
    80004b84:	0094ca83          	lbu	s5,9(s1)
    80004b88:	0104ba03          	ld	s4,16(s1)
    80004b8c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b90:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b94:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b98:	00025517          	auipc	a0,0x25
    80004b9c:	e2050513          	addi	a0,a0,-480 # 800299b8 <ftable>
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	0d6080e7          	jalr	214(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004ba8:	4785                	li	a5,1
    80004baa:	04f90d63          	beq	s2,a5,80004c04 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bae:	3979                	addiw	s2,s2,-2
    80004bb0:	4785                	li	a5,1
    80004bb2:	0527e063          	bltu	a5,s2,80004bf2 <fileclose+0xa8>
    begin_op();
    80004bb6:	00000097          	auipc	ra,0x0
    80004bba:	ac8080e7          	jalr	-1336(ra) # 8000467e <begin_op>
    iput(ff.ip);
    80004bbe:	854e                	mv	a0,s3
    80004bc0:	fffff097          	auipc	ra,0xfffff
    80004bc4:	f90080e7          	jalr	-112(ra) # 80003b50 <iput>
    end_op();
    80004bc8:	00000097          	auipc	ra,0x0
    80004bcc:	b36080e7          	jalr	-1226(ra) # 800046fe <end_op>
    80004bd0:	a00d                	j	80004bf2 <fileclose+0xa8>
    panic("fileclose");
    80004bd2:	00004517          	auipc	a0,0x4
    80004bd6:	cb650513          	addi	a0,a0,-842 # 80008888 <syscalls+0x2b8>
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	950080e7          	jalr	-1712(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004be2:	00025517          	auipc	a0,0x25
    80004be6:	dd650513          	addi	a0,a0,-554 # 800299b8 <ftable>
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	08c080e7          	jalr	140(ra) # 80000c76 <release>
  }
}
    80004bf2:	70e2                	ld	ra,56(sp)
    80004bf4:	7442                	ld	s0,48(sp)
    80004bf6:	74a2                	ld	s1,40(sp)
    80004bf8:	7902                	ld	s2,32(sp)
    80004bfa:	69e2                	ld	s3,24(sp)
    80004bfc:	6a42                	ld	s4,16(sp)
    80004bfe:	6aa2                	ld	s5,8(sp)
    80004c00:	6121                	addi	sp,sp,64
    80004c02:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c04:	85d6                	mv	a1,s5
    80004c06:	8552                	mv	a0,s4
    80004c08:	00000097          	auipc	ra,0x0
    80004c0c:	542080e7          	jalr	1346(ra) # 8000514a <pipeclose>
    80004c10:	b7cd                	j	80004bf2 <fileclose+0xa8>

0000000080004c12 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c12:	715d                	addi	sp,sp,-80
    80004c14:	e486                	sd	ra,72(sp)
    80004c16:	e0a2                	sd	s0,64(sp)
    80004c18:	fc26                	sd	s1,56(sp)
    80004c1a:	f84a                	sd	s2,48(sp)
    80004c1c:	f44e                	sd	s3,40(sp)
    80004c1e:	0880                	addi	s0,sp,80
    80004c20:	84aa                	mv	s1,a0
    80004c22:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	d76080e7          	jalr	-650(ra) # 8000199a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c2c:	409c                	lw	a5,0(s1)
    80004c2e:	37f9                	addiw	a5,a5,-2
    80004c30:	4705                	li	a4,1
    80004c32:	04f76763          	bltu	a4,a5,80004c80 <filestat+0x6e>
    80004c36:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c38:	6c88                	ld	a0,24(s1)
    80004c3a:	fffff097          	auipc	ra,0xfffff
    80004c3e:	d5c080e7          	jalr	-676(ra) # 80003996 <ilock>
    stati(f->ip, &st);
    80004c42:	fb840593          	addi	a1,s0,-72
    80004c46:	6c88                	ld	a0,24(s1)
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	fd8080e7          	jalr	-40(ra) # 80003c20 <stati>
    iunlock(f->ip);
    80004c50:	6c88                	ld	a0,24(s1)
    80004c52:	fffff097          	auipc	ra,0xfffff
    80004c56:	e06080e7          	jalr	-506(ra) # 80003a58 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c5a:	46e1                	li	a3,24
    80004c5c:	fb840613          	addi	a2,s0,-72
    80004c60:	85ce                	mv	a1,s3
    80004c62:	05093503          	ld	a0,80(s2)
    80004c66:	ffffd097          	auipc	ra,0xffffd
    80004c6a:	9ee080e7          	jalr	-1554(ra) # 80001654 <copyout>
    80004c6e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c72:	60a6                	ld	ra,72(sp)
    80004c74:	6406                	ld	s0,64(sp)
    80004c76:	74e2                	ld	s1,56(sp)
    80004c78:	7942                	ld	s2,48(sp)
    80004c7a:	79a2                	ld	s3,40(sp)
    80004c7c:	6161                	addi	sp,sp,80
    80004c7e:	8082                	ret
  return -1;
    80004c80:	557d                	li	a0,-1
    80004c82:	bfc5                	j	80004c72 <filestat+0x60>

0000000080004c84 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c84:	7179                	addi	sp,sp,-48
    80004c86:	f406                	sd	ra,40(sp)
    80004c88:	f022                	sd	s0,32(sp)
    80004c8a:	ec26                	sd	s1,24(sp)
    80004c8c:	e84a                	sd	s2,16(sp)
    80004c8e:	e44e                	sd	s3,8(sp)
    80004c90:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c92:	00854783          	lbu	a5,8(a0)
    80004c96:	c3d5                	beqz	a5,80004d3a <fileread+0xb6>
    80004c98:	84aa                	mv	s1,a0
    80004c9a:	89ae                	mv	s3,a1
    80004c9c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c9e:	411c                	lw	a5,0(a0)
    80004ca0:	4705                	li	a4,1
    80004ca2:	04e78963          	beq	a5,a4,80004cf4 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ca6:	470d                	li	a4,3
    80004ca8:	04e78d63          	beq	a5,a4,80004d02 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cac:	4709                	li	a4,2
    80004cae:	06e79e63          	bne	a5,a4,80004d2a <fileread+0xa6>
    ilock(f->ip);
    80004cb2:	6d08                	ld	a0,24(a0)
    80004cb4:	fffff097          	auipc	ra,0xfffff
    80004cb8:	ce2080e7          	jalr	-798(ra) # 80003996 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cbc:	874a                	mv	a4,s2
    80004cbe:	5094                	lw	a3,32(s1)
    80004cc0:	864e                	mv	a2,s3
    80004cc2:	4585                	li	a1,1
    80004cc4:	6c88                	ld	a0,24(s1)
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	f84080e7          	jalr	-124(ra) # 80003c4a <readi>
    80004cce:	892a                	mv	s2,a0
    80004cd0:	00a05563          	blez	a0,80004cda <fileread+0x56>
      f->off += r;
    80004cd4:	509c                	lw	a5,32(s1)
    80004cd6:	9fa9                	addw	a5,a5,a0
    80004cd8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cda:	6c88                	ld	a0,24(s1)
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	d7c080e7          	jalr	-644(ra) # 80003a58 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ce4:	854a                	mv	a0,s2
    80004ce6:	70a2                	ld	ra,40(sp)
    80004ce8:	7402                	ld	s0,32(sp)
    80004cea:	64e2                	ld	s1,24(sp)
    80004cec:	6942                	ld	s2,16(sp)
    80004cee:	69a2                	ld	s3,8(sp)
    80004cf0:	6145                	addi	sp,sp,48
    80004cf2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cf4:	6908                	ld	a0,16(a0)
    80004cf6:	00000097          	auipc	ra,0x0
    80004cfa:	5b6080e7          	jalr	1462(ra) # 800052ac <piperead>
    80004cfe:	892a                	mv	s2,a0
    80004d00:	b7d5                	j	80004ce4 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d02:	02451783          	lh	a5,36(a0)
    80004d06:	03079693          	slli	a3,a5,0x30
    80004d0a:	92c1                	srli	a3,a3,0x30
    80004d0c:	4725                	li	a4,9
    80004d0e:	02d76863          	bltu	a4,a3,80004d3e <fileread+0xba>
    80004d12:	0792                	slli	a5,a5,0x4
    80004d14:	00025717          	auipc	a4,0x25
    80004d18:	c0470713          	addi	a4,a4,-1020 # 80029918 <devsw>
    80004d1c:	97ba                	add	a5,a5,a4
    80004d1e:	639c                	ld	a5,0(a5)
    80004d20:	c38d                	beqz	a5,80004d42 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d22:	4505                	li	a0,1
    80004d24:	9782                	jalr	a5
    80004d26:	892a                	mv	s2,a0
    80004d28:	bf75                	j	80004ce4 <fileread+0x60>
    panic("fileread");
    80004d2a:	00004517          	auipc	a0,0x4
    80004d2e:	b6e50513          	addi	a0,a0,-1170 # 80008898 <syscalls+0x2c8>
    80004d32:	ffffb097          	auipc	ra,0xffffb
    80004d36:	7f8080e7          	jalr	2040(ra) # 8000052a <panic>
    return -1;
    80004d3a:	597d                	li	s2,-1
    80004d3c:	b765                	j	80004ce4 <fileread+0x60>
      return -1;
    80004d3e:	597d                	li	s2,-1
    80004d40:	b755                	j	80004ce4 <fileread+0x60>
    80004d42:	597d                	li	s2,-1
    80004d44:	b745                	j	80004ce4 <fileread+0x60>

0000000080004d46 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d46:	715d                	addi	sp,sp,-80
    80004d48:	e486                	sd	ra,72(sp)
    80004d4a:	e0a2                	sd	s0,64(sp)
    80004d4c:	fc26                	sd	s1,56(sp)
    80004d4e:	f84a                	sd	s2,48(sp)
    80004d50:	f44e                	sd	s3,40(sp)
    80004d52:	f052                	sd	s4,32(sp)
    80004d54:	ec56                	sd	s5,24(sp)
    80004d56:	e85a                	sd	s6,16(sp)
    80004d58:	e45e                	sd	s7,8(sp)
    80004d5a:	e062                	sd	s8,0(sp)
    80004d5c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d5e:	00954783          	lbu	a5,9(a0)
    80004d62:	10078663          	beqz	a5,80004e6e <filewrite+0x128>
    80004d66:	892a                	mv	s2,a0
    80004d68:	8aae                	mv	s5,a1
    80004d6a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d6c:	411c                	lw	a5,0(a0)
    80004d6e:	4705                	li	a4,1
    80004d70:	02e78263          	beq	a5,a4,80004d94 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d74:	470d                	li	a4,3
    80004d76:	02e78663          	beq	a5,a4,80004da2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d7a:	4709                	li	a4,2
    80004d7c:	0ee79163          	bne	a5,a4,80004e5e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d80:	0ac05d63          	blez	a2,80004e3a <filewrite+0xf4>
    int i = 0;
    80004d84:	4981                	li	s3,0
    80004d86:	6b05                	lui	s6,0x1
    80004d88:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d8c:	6b85                	lui	s7,0x1
    80004d8e:	c00b8b9b          	addiw	s7,s7,-1024
    80004d92:	a861                	j	80004e2a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d94:	6908                	ld	a0,16(a0)
    80004d96:	00000097          	auipc	ra,0x0
    80004d9a:	424080e7          	jalr	1060(ra) # 800051ba <pipewrite>
    80004d9e:	8a2a                	mv	s4,a0
    80004da0:	a045                	j	80004e40 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004da2:	02451783          	lh	a5,36(a0)
    80004da6:	03079693          	slli	a3,a5,0x30
    80004daa:	92c1                	srli	a3,a3,0x30
    80004dac:	4725                	li	a4,9
    80004dae:	0cd76263          	bltu	a4,a3,80004e72 <filewrite+0x12c>
    80004db2:	0792                	slli	a5,a5,0x4
    80004db4:	00025717          	auipc	a4,0x25
    80004db8:	b6470713          	addi	a4,a4,-1180 # 80029918 <devsw>
    80004dbc:	97ba                	add	a5,a5,a4
    80004dbe:	679c                	ld	a5,8(a5)
    80004dc0:	cbdd                	beqz	a5,80004e76 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dc2:	4505                	li	a0,1
    80004dc4:	9782                	jalr	a5
    80004dc6:	8a2a                	mv	s4,a0
    80004dc8:	a8a5                	j	80004e40 <filewrite+0xfa>
    80004dca:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004dce:	00000097          	auipc	ra,0x0
    80004dd2:	8b0080e7          	jalr	-1872(ra) # 8000467e <begin_op>
      ilock(f->ip);
    80004dd6:	01893503          	ld	a0,24(s2)
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	bbc080e7          	jalr	-1092(ra) # 80003996 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004de2:	8762                	mv	a4,s8
    80004de4:	02092683          	lw	a3,32(s2)
    80004de8:	01598633          	add	a2,s3,s5
    80004dec:	4585                	li	a1,1
    80004dee:	01893503          	ld	a0,24(s2)
    80004df2:	fffff097          	auipc	ra,0xfffff
    80004df6:	f50080e7          	jalr	-176(ra) # 80003d42 <writei>
    80004dfa:	84aa                	mv	s1,a0
    80004dfc:	00a05763          	blez	a0,80004e0a <filewrite+0xc4>
        f->off += r;
    80004e00:	02092783          	lw	a5,32(s2)
    80004e04:	9fa9                	addw	a5,a5,a0
    80004e06:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e0a:	01893503          	ld	a0,24(s2)
    80004e0e:	fffff097          	auipc	ra,0xfffff
    80004e12:	c4a080e7          	jalr	-950(ra) # 80003a58 <iunlock>
      end_op();
    80004e16:	00000097          	auipc	ra,0x0
    80004e1a:	8e8080e7          	jalr	-1816(ra) # 800046fe <end_op>

      if(r != n1){
    80004e1e:	009c1f63          	bne	s8,s1,80004e3c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e22:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e26:	0149db63          	bge	s3,s4,80004e3c <filewrite+0xf6>
      int n1 = n - i;
    80004e2a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e2e:	84be                	mv	s1,a5
    80004e30:	2781                	sext.w	a5,a5
    80004e32:	f8fb5ce3          	bge	s6,a5,80004dca <filewrite+0x84>
    80004e36:	84de                	mv	s1,s7
    80004e38:	bf49                	j	80004dca <filewrite+0x84>
    int i = 0;
    80004e3a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e3c:	013a1f63          	bne	s4,s3,80004e5a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e40:	8552                	mv	a0,s4
    80004e42:	60a6                	ld	ra,72(sp)
    80004e44:	6406                	ld	s0,64(sp)
    80004e46:	74e2                	ld	s1,56(sp)
    80004e48:	7942                	ld	s2,48(sp)
    80004e4a:	79a2                	ld	s3,40(sp)
    80004e4c:	7a02                	ld	s4,32(sp)
    80004e4e:	6ae2                	ld	s5,24(sp)
    80004e50:	6b42                	ld	s6,16(sp)
    80004e52:	6ba2                	ld	s7,8(sp)
    80004e54:	6c02                	ld	s8,0(sp)
    80004e56:	6161                	addi	sp,sp,80
    80004e58:	8082                	ret
    ret = (i == n ? n : -1);
    80004e5a:	5a7d                	li	s4,-1
    80004e5c:	b7d5                	j	80004e40 <filewrite+0xfa>
    panic("filewrite");
    80004e5e:	00004517          	auipc	a0,0x4
    80004e62:	a4a50513          	addi	a0,a0,-1462 # 800088a8 <syscalls+0x2d8>
    80004e66:	ffffb097          	auipc	ra,0xffffb
    80004e6a:	6c4080e7          	jalr	1732(ra) # 8000052a <panic>
    return -1;
    80004e6e:	5a7d                	li	s4,-1
    80004e70:	bfc1                	j	80004e40 <filewrite+0xfa>
      return -1;
    80004e72:	5a7d                	li	s4,-1
    80004e74:	b7f1                	j	80004e40 <filewrite+0xfa>
    80004e76:	5a7d                	li	s4,-1
    80004e78:	b7e1                	j	80004e40 <filewrite+0xfa>

0000000080004e7a <kfileread>:

// Read from file f.
// addr is a kernel virtual address.
int
kfileread(struct file *f, uint64 addr, int n)
{
    80004e7a:	7179                	addi	sp,sp,-48
    80004e7c:	f406                	sd	ra,40(sp)
    80004e7e:	f022                	sd	s0,32(sp)
    80004e80:	ec26                	sd	s1,24(sp)
    80004e82:	e84a                	sd	s2,16(sp)
    80004e84:	e44e                	sd	s3,8(sp)
    80004e86:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e88:	00854783          	lbu	a5,8(a0)
    80004e8c:	c3d5                	beqz	a5,80004f30 <kfileread+0xb6>
    80004e8e:	84aa                	mv	s1,a0
    80004e90:	89ae                	mv	s3,a1
    80004e92:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e94:	411c                	lw	a5,0(a0)
    80004e96:	4705                	li	a4,1
    80004e98:	04e78963          	beq	a5,a4,80004eea <kfileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e9c:	470d                	li	a4,3
    80004e9e:	04e78d63          	beq	a5,a4,80004ef8 <kfileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ea2:	4709                	li	a4,2
    80004ea4:	06e79e63          	bne	a5,a4,80004f20 <kfileread+0xa6>
    ilock(f->ip);
    80004ea8:	6d08                	ld	a0,24(a0)
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	aec080e7          	jalr	-1300(ra) # 80003996 <ilock>
    if((r = readi(f->ip, 0, addr, f->off, n)) > 0)
    80004eb2:	874a                	mv	a4,s2
    80004eb4:	5094                	lw	a3,32(s1)
    80004eb6:	864e                	mv	a2,s3
    80004eb8:	4581                	li	a1,0
    80004eba:	6c88                	ld	a0,24(s1)
    80004ebc:	fffff097          	auipc	ra,0xfffff
    80004ec0:	d8e080e7          	jalr	-626(ra) # 80003c4a <readi>
    80004ec4:	892a                	mv	s2,a0
    80004ec6:	00a05563          	blez	a0,80004ed0 <kfileread+0x56>
      f->off += r;
    80004eca:	509c                	lw	a5,32(s1)
    80004ecc:	9fa9                	addw	a5,a5,a0
    80004ece:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ed0:	6c88                	ld	a0,24(s1)
    80004ed2:	fffff097          	auipc	ra,0xfffff
    80004ed6:	b86080e7          	jalr	-1146(ra) # 80003a58 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004eda:	854a                	mv	a0,s2
    80004edc:	70a2                	ld	ra,40(sp)
    80004ede:	7402                	ld	s0,32(sp)
    80004ee0:	64e2                	ld	s1,24(sp)
    80004ee2:	6942                	ld	s2,16(sp)
    80004ee4:	69a2                	ld	s3,8(sp)
    80004ee6:	6145                	addi	sp,sp,48
    80004ee8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004eea:	6908                	ld	a0,16(a0)
    80004eec:	00000097          	auipc	ra,0x0
    80004ef0:	3c0080e7          	jalr	960(ra) # 800052ac <piperead>
    80004ef4:	892a                	mv	s2,a0
    80004ef6:	b7d5                	j	80004eda <kfileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ef8:	02451783          	lh	a5,36(a0)
    80004efc:	03079693          	slli	a3,a5,0x30
    80004f00:	92c1                	srli	a3,a3,0x30
    80004f02:	4725                	li	a4,9
    80004f04:	02d76863          	bltu	a4,a3,80004f34 <kfileread+0xba>
    80004f08:	0792                	slli	a5,a5,0x4
    80004f0a:	00025717          	auipc	a4,0x25
    80004f0e:	a0e70713          	addi	a4,a4,-1522 # 80029918 <devsw>
    80004f12:	97ba                	add	a5,a5,a4
    80004f14:	639c                	ld	a5,0(a5)
    80004f16:	c38d                	beqz	a5,80004f38 <kfileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f18:	4505                	li	a0,1
    80004f1a:	9782                	jalr	a5
    80004f1c:	892a                	mv	s2,a0
    80004f1e:	bf75                	j	80004eda <kfileread+0x60>
    panic("fileread");
    80004f20:	00004517          	auipc	a0,0x4
    80004f24:	97850513          	addi	a0,a0,-1672 # 80008898 <syscalls+0x2c8>
    80004f28:	ffffb097          	auipc	ra,0xffffb
    80004f2c:	602080e7          	jalr	1538(ra) # 8000052a <panic>
    return -1;
    80004f30:	597d                	li	s2,-1
    80004f32:	b765                	j	80004eda <kfileread+0x60>
      return -1;
    80004f34:	597d                	li	s2,-1
    80004f36:	b755                	j	80004eda <kfileread+0x60>
    80004f38:	597d                	li	s2,-1
    80004f3a:	b745                	j	80004eda <kfileread+0x60>

0000000080004f3c <kfilewrite>:

// Write to file f.
// addr is a kernel virtual address.
int
kfilewrite(struct file *f, uint64 addr, int n)
{
    80004f3c:	715d                	addi	sp,sp,-80
    80004f3e:	e486                	sd	ra,72(sp)
    80004f40:	e0a2                	sd	s0,64(sp)
    80004f42:	fc26                	sd	s1,56(sp)
    80004f44:	f84a                	sd	s2,48(sp)
    80004f46:	f44e                	sd	s3,40(sp)
    80004f48:	f052                	sd	s4,32(sp)
    80004f4a:	ec56                	sd	s5,24(sp)
    80004f4c:	e85a                	sd	s6,16(sp)
    80004f4e:	e45e                	sd	s7,8(sp)
    80004f50:	e062                	sd	s8,0(sp)
    80004f52:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f54:	00954783          	lbu	a5,9(a0)
    80004f58:	10078663          	beqz	a5,80005064 <kfilewrite+0x128>
    80004f5c:	892a                	mv	s2,a0
    80004f5e:	8aae                	mv	s5,a1
    80004f60:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f62:	411c                	lw	a5,0(a0)
    80004f64:	4705                	li	a4,1
    80004f66:	02e78263          	beq	a5,a4,80004f8a <kfilewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f6a:	470d                	li	a4,3
    80004f6c:	02e78663          	beq	a5,a4,80004f98 <kfilewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f70:	4709                	li	a4,2
    80004f72:	0ee79163          	bne	a5,a4,80005054 <kfilewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f76:	0ac05d63          	blez	a2,80005030 <kfilewrite+0xf4>
    int i = 0;
    80004f7a:	4981                	li	s3,0
    80004f7c:	6b05                	lui	s6,0x1
    80004f7e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f82:	6b85                	lui	s7,0x1
    80004f84:	c00b8b9b          	addiw	s7,s7,-1024
    80004f88:	a861                	j	80005020 <kfilewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f8a:	6908                	ld	a0,16(a0)
    80004f8c:	00000097          	auipc	ra,0x0
    80004f90:	22e080e7          	jalr	558(ra) # 800051ba <pipewrite>
    80004f94:	8a2a                	mv	s4,a0
    80004f96:	a045                	j	80005036 <kfilewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f98:	02451783          	lh	a5,36(a0)
    80004f9c:	03079693          	slli	a3,a5,0x30
    80004fa0:	92c1                	srli	a3,a3,0x30
    80004fa2:	4725                	li	a4,9
    80004fa4:	0cd76263          	bltu	a4,a3,80005068 <kfilewrite+0x12c>
    80004fa8:	0792                	slli	a5,a5,0x4
    80004faa:	00025717          	auipc	a4,0x25
    80004fae:	96e70713          	addi	a4,a4,-1682 # 80029918 <devsw>
    80004fb2:	97ba                	add	a5,a5,a4
    80004fb4:	679c                	ld	a5,8(a5)
    80004fb6:	cbdd                	beqz	a5,8000506c <kfilewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fb8:	4505                	li	a0,1
    80004fba:	9782                	jalr	a5
    80004fbc:	8a2a                	mv	s4,a0
    80004fbe:	a8a5                	j	80005036 <kfilewrite+0xfa>
    80004fc0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	6ba080e7          	jalr	1722(ra) # 8000467e <begin_op>
      ilock(f->ip);
    80004fcc:	01893503          	ld	a0,24(s2)
    80004fd0:	fffff097          	auipc	ra,0xfffff
    80004fd4:	9c6080e7          	jalr	-1594(ra) # 80003996 <ilock>
      if ((r = writei(f->ip, 0, addr + i, f->off, n1)) > 0)
    80004fd8:	8762                	mv	a4,s8
    80004fda:	02092683          	lw	a3,32(s2)
    80004fde:	01598633          	add	a2,s3,s5
    80004fe2:	4581                	li	a1,0
    80004fe4:	01893503          	ld	a0,24(s2)
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	d5a080e7          	jalr	-678(ra) # 80003d42 <writei>
    80004ff0:	84aa                	mv	s1,a0
    80004ff2:	00a05763          	blez	a0,80005000 <kfilewrite+0xc4>
        f->off += r;
    80004ff6:	02092783          	lw	a5,32(s2)
    80004ffa:	9fa9                	addw	a5,a5,a0
    80004ffc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005000:	01893503          	ld	a0,24(s2)
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	a54080e7          	jalr	-1452(ra) # 80003a58 <iunlock>
      end_op();
    8000500c:	fffff097          	auipc	ra,0xfffff
    80005010:	6f2080e7          	jalr	1778(ra) # 800046fe <end_op>

      if(r != n1){
    80005014:	009c1f63          	bne	s8,s1,80005032 <kfilewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005018:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000501c:	0149db63          	bge	s3,s4,80005032 <kfilewrite+0xf6>
      int n1 = n - i;
    80005020:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005024:	84be                	mv	s1,a5
    80005026:	2781                	sext.w	a5,a5
    80005028:	f8fb5ce3          	bge	s6,a5,80004fc0 <kfilewrite+0x84>
    8000502c:	84de                	mv	s1,s7
    8000502e:	bf49                	j	80004fc0 <kfilewrite+0x84>
    int i = 0;
    80005030:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005032:	013a1f63          	bne	s4,s3,80005050 <kfilewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
    80005036:	8552                	mv	a0,s4
    80005038:	60a6                	ld	ra,72(sp)
    8000503a:	6406                	ld	s0,64(sp)
    8000503c:	74e2                	ld	s1,56(sp)
    8000503e:	7942                	ld	s2,48(sp)
    80005040:	79a2                	ld	s3,40(sp)
    80005042:	7a02                	ld	s4,32(sp)
    80005044:	6ae2                	ld	s5,24(sp)
    80005046:	6b42                	ld	s6,16(sp)
    80005048:	6ba2                	ld	s7,8(sp)
    8000504a:	6c02                	ld	s8,0(sp)
    8000504c:	6161                	addi	sp,sp,80
    8000504e:	8082                	ret
    ret = (i == n ? n : -1);
    80005050:	5a7d                	li	s4,-1
    80005052:	b7d5                	j	80005036 <kfilewrite+0xfa>
    panic("filewrite");
    80005054:	00004517          	auipc	a0,0x4
    80005058:	85450513          	addi	a0,a0,-1964 # 800088a8 <syscalls+0x2d8>
    8000505c:	ffffb097          	auipc	ra,0xffffb
    80005060:	4ce080e7          	jalr	1230(ra) # 8000052a <panic>
    return -1;
    80005064:	5a7d                	li	s4,-1
    80005066:	bfc1                	j	80005036 <kfilewrite+0xfa>
      return -1;
    80005068:	5a7d                	li	s4,-1
    8000506a:	b7f1                	j	80005036 <kfilewrite+0xfa>
    8000506c:	5a7d                	li	s4,-1
    8000506e:	b7e1                	j	80005036 <kfilewrite+0xfa>

0000000080005070 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005070:	7179                	addi	sp,sp,-48
    80005072:	f406                	sd	ra,40(sp)
    80005074:	f022                	sd	s0,32(sp)
    80005076:	ec26                	sd	s1,24(sp)
    80005078:	e84a                	sd	s2,16(sp)
    8000507a:	e44e                	sd	s3,8(sp)
    8000507c:	e052                	sd	s4,0(sp)
    8000507e:	1800                	addi	s0,sp,48
    80005080:	84aa                	mv	s1,a0
    80005082:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005084:	0005b023          	sd	zero,0(a1)
    80005088:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000508c:	00000097          	auipc	ra,0x0
    80005090:	a02080e7          	jalr	-1534(ra) # 80004a8e <filealloc>
    80005094:	e088                	sd	a0,0(s1)
    80005096:	c551                	beqz	a0,80005122 <pipealloc+0xb2>
    80005098:	00000097          	auipc	ra,0x0
    8000509c:	9f6080e7          	jalr	-1546(ra) # 80004a8e <filealloc>
    800050a0:	00aa3023          	sd	a0,0(s4)
    800050a4:	c92d                	beqz	a0,80005116 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	a2c080e7          	jalr	-1492(ra) # 80000ad2 <kalloc>
    800050ae:	892a                	mv	s2,a0
    800050b0:	c125                	beqz	a0,80005110 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050b2:	4985                	li	s3,1
    800050b4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050b8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050bc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050c0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050c4:	00003597          	auipc	a1,0x3
    800050c8:	7f458593          	addi	a1,a1,2036 # 800088b8 <syscalls+0x2e8>
    800050cc:	ffffc097          	auipc	ra,0xffffc
    800050d0:	a66080e7          	jalr	-1434(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    800050d4:	609c                	ld	a5,0(s1)
    800050d6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050da:	609c                	ld	a5,0(s1)
    800050dc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050e0:	609c                	ld	a5,0(s1)
    800050e2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050e6:	609c                	ld	a5,0(s1)
    800050e8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050ec:	000a3783          	ld	a5,0(s4)
    800050f0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050f4:	000a3783          	ld	a5,0(s4)
    800050f8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050fc:	000a3783          	ld	a5,0(s4)
    80005100:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005104:	000a3783          	ld	a5,0(s4)
    80005108:	0127b823          	sd	s2,16(a5)
  return 0;
    8000510c:	4501                	li	a0,0
    8000510e:	a025                	j	80005136 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005110:	6088                	ld	a0,0(s1)
    80005112:	e501                	bnez	a0,8000511a <pipealloc+0xaa>
    80005114:	a039                	j	80005122 <pipealloc+0xb2>
    80005116:	6088                	ld	a0,0(s1)
    80005118:	c51d                	beqz	a0,80005146 <pipealloc+0xd6>
    fileclose(*f0);
    8000511a:	00000097          	auipc	ra,0x0
    8000511e:	a30080e7          	jalr	-1488(ra) # 80004b4a <fileclose>
  if(*f1)
    80005122:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005126:	557d                	li	a0,-1
  if(*f1)
    80005128:	c799                	beqz	a5,80005136 <pipealloc+0xc6>
    fileclose(*f1);
    8000512a:	853e                	mv	a0,a5
    8000512c:	00000097          	auipc	ra,0x0
    80005130:	a1e080e7          	jalr	-1506(ra) # 80004b4a <fileclose>
  return -1;
    80005134:	557d                	li	a0,-1
}
    80005136:	70a2                	ld	ra,40(sp)
    80005138:	7402                	ld	s0,32(sp)
    8000513a:	64e2                	ld	s1,24(sp)
    8000513c:	6942                	ld	s2,16(sp)
    8000513e:	69a2                	ld	s3,8(sp)
    80005140:	6a02                	ld	s4,0(sp)
    80005142:	6145                	addi	sp,sp,48
    80005144:	8082                	ret
  return -1;
    80005146:	557d                	li	a0,-1
    80005148:	b7fd                	j	80005136 <pipealloc+0xc6>

000000008000514a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000514a:	1101                	addi	sp,sp,-32
    8000514c:	ec06                	sd	ra,24(sp)
    8000514e:	e822                	sd	s0,16(sp)
    80005150:	e426                	sd	s1,8(sp)
    80005152:	e04a                	sd	s2,0(sp)
    80005154:	1000                	addi	s0,sp,32
    80005156:	84aa                	mv	s1,a0
    80005158:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000515a:	ffffc097          	auipc	ra,0xffffc
    8000515e:	a68080e7          	jalr	-1432(ra) # 80000bc2 <acquire>
  if(writable){
    80005162:	02090d63          	beqz	s2,8000519c <pipeclose+0x52>
    pi->writeopen = 0;
    80005166:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000516a:	21848513          	addi	a0,s1,536
    8000516e:	ffffd097          	auipc	ra,0xffffd
    80005172:	f40080e7          	jalr	-192(ra) # 800020ae <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005176:	2204b783          	ld	a5,544(s1)
    8000517a:	eb95                	bnez	a5,800051ae <pipeclose+0x64>
    release(&pi->lock);
    8000517c:	8526                	mv	a0,s1
    8000517e:	ffffc097          	auipc	ra,0xffffc
    80005182:	af8080e7          	jalr	-1288(ra) # 80000c76 <release>
    kfree((char*)pi);
    80005186:	8526                	mv	a0,s1
    80005188:	ffffc097          	auipc	ra,0xffffc
    8000518c:	84e080e7          	jalr	-1970(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80005190:	60e2                	ld	ra,24(sp)
    80005192:	6442                	ld	s0,16(sp)
    80005194:	64a2                	ld	s1,8(sp)
    80005196:	6902                	ld	s2,0(sp)
    80005198:	6105                	addi	sp,sp,32
    8000519a:	8082                	ret
    pi->readopen = 0;
    8000519c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800051a0:	21c48513          	addi	a0,s1,540
    800051a4:	ffffd097          	auipc	ra,0xffffd
    800051a8:	f0a080e7          	jalr	-246(ra) # 800020ae <wakeup>
    800051ac:	b7e9                	j	80005176 <pipeclose+0x2c>
    release(&pi->lock);
    800051ae:	8526                	mv	a0,s1
    800051b0:	ffffc097          	auipc	ra,0xffffc
    800051b4:	ac6080e7          	jalr	-1338(ra) # 80000c76 <release>
}
    800051b8:	bfe1                	j	80005190 <pipeclose+0x46>

00000000800051ba <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051ba:	711d                	addi	sp,sp,-96
    800051bc:	ec86                	sd	ra,88(sp)
    800051be:	e8a2                	sd	s0,80(sp)
    800051c0:	e4a6                	sd	s1,72(sp)
    800051c2:	e0ca                	sd	s2,64(sp)
    800051c4:	fc4e                	sd	s3,56(sp)
    800051c6:	f852                	sd	s4,48(sp)
    800051c8:	f456                	sd	s5,40(sp)
    800051ca:	f05a                	sd	s6,32(sp)
    800051cc:	ec5e                	sd	s7,24(sp)
    800051ce:	e862                	sd	s8,16(sp)
    800051d0:	1080                	addi	s0,sp,96
    800051d2:	84aa                	mv	s1,a0
    800051d4:	8aae                	mv	s5,a1
    800051d6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	7c2080e7          	jalr	1986(ra) # 8000199a <myproc>
    800051e0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051e2:	8526                	mv	a0,s1
    800051e4:	ffffc097          	auipc	ra,0xffffc
    800051e8:	9de080e7          	jalr	-1570(ra) # 80000bc2 <acquire>
  while(i < n){
    800051ec:	0b405363          	blez	s4,80005292 <pipewrite+0xd8>
  int i = 0;
    800051f0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051f2:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051f4:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051f8:	21c48b93          	addi	s7,s1,540
    800051fc:	a089                	j	8000523e <pipewrite+0x84>
      release(&pi->lock);
    800051fe:	8526                	mv	a0,s1
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	a76080e7          	jalr	-1418(ra) # 80000c76 <release>
      return -1;
    80005208:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000520a:	854a                	mv	a0,s2
    8000520c:	60e6                	ld	ra,88(sp)
    8000520e:	6446                	ld	s0,80(sp)
    80005210:	64a6                	ld	s1,72(sp)
    80005212:	6906                	ld	s2,64(sp)
    80005214:	79e2                	ld	s3,56(sp)
    80005216:	7a42                	ld	s4,48(sp)
    80005218:	7aa2                	ld	s5,40(sp)
    8000521a:	7b02                	ld	s6,32(sp)
    8000521c:	6be2                	ld	s7,24(sp)
    8000521e:	6c42                	ld	s8,16(sp)
    80005220:	6125                	addi	sp,sp,96
    80005222:	8082                	ret
      wakeup(&pi->nread);
    80005224:	8562                	mv	a0,s8
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	e88080e7          	jalr	-376(ra) # 800020ae <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000522e:	85a6                	mv	a1,s1
    80005230:	855e                	mv	a0,s7
    80005232:	ffffd097          	auipc	ra,0xffffd
    80005236:	cf0080e7          	jalr	-784(ra) # 80001f22 <sleep>
  while(i < n){
    8000523a:	05495d63          	bge	s2,s4,80005294 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    8000523e:	2204a783          	lw	a5,544(s1)
    80005242:	dfd5                	beqz	a5,800051fe <pipewrite+0x44>
    80005244:	0289a783          	lw	a5,40(s3)
    80005248:	fbdd                	bnez	a5,800051fe <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000524a:	2184a783          	lw	a5,536(s1)
    8000524e:	21c4a703          	lw	a4,540(s1)
    80005252:	2007879b          	addiw	a5,a5,512
    80005256:	fcf707e3          	beq	a4,a5,80005224 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000525a:	4685                	li	a3,1
    8000525c:	01590633          	add	a2,s2,s5
    80005260:	faf40593          	addi	a1,s0,-81
    80005264:	0509b503          	ld	a0,80(s3)
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	47a080e7          	jalr	1146(ra) # 800016e2 <copyin>
    80005270:	03650263          	beq	a0,s6,80005294 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005274:	21c4a783          	lw	a5,540(s1)
    80005278:	0017871b          	addiw	a4,a5,1
    8000527c:	20e4ae23          	sw	a4,540(s1)
    80005280:	1ff7f793          	andi	a5,a5,511
    80005284:	97a6                	add	a5,a5,s1
    80005286:	faf44703          	lbu	a4,-81(s0)
    8000528a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000528e:	2905                	addiw	s2,s2,1
    80005290:	b76d                	j	8000523a <pipewrite+0x80>
  int i = 0;
    80005292:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005294:	21848513          	addi	a0,s1,536
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	e16080e7          	jalr	-490(ra) # 800020ae <wakeup>
  release(&pi->lock);
    800052a0:	8526                	mv	a0,s1
    800052a2:	ffffc097          	auipc	ra,0xffffc
    800052a6:	9d4080e7          	jalr	-1580(ra) # 80000c76 <release>
  return i;
    800052aa:	b785                	j	8000520a <pipewrite+0x50>

00000000800052ac <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052ac:	715d                	addi	sp,sp,-80
    800052ae:	e486                	sd	ra,72(sp)
    800052b0:	e0a2                	sd	s0,64(sp)
    800052b2:	fc26                	sd	s1,56(sp)
    800052b4:	f84a                	sd	s2,48(sp)
    800052b6:	f44e                	sd	s3,40(sp)
    800052b8:	f052                	sd	s4,32(sp)
    800052ba:	ec56                	sd	s5,24(sp)
    800052bc:	e85a                	sd	s6,16(sp)
    800052be:	0880                	addi	s0,sp,80
    800052c0:	84aa                	mv	s1,a0
    800052c2:	892e                	mv	s2,a1
    800052c4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052c6:	ffffc097          	auipc	ra,0xffffc
    800052ca:	6d4080e7          	jalr	1748(ra) # 8000199a <myproc>
    800052ce:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052d0:	8526                	mv	a0,s1
    800052d2:	ffffc097          	auipc	ra,0xffffc
    800052d6:	8f0080e7          	jalr	-1808(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052da:	2184a703          	lw	a4,536(s1)
    800052de:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052e2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052e6:	02f71463          	bne	a4,a5,8000530e <piperead+0x62>
    800052ea:	2244a783          	lw	a5,548(s1)
    800052ee:	c385                	beqz	a5,8000530e <piperead+0x62>
    if(pr->killed){
    800052f0:	028a2783          	lw	a5,40(s4)
    800052f4:	ebc1                	bnez	a5,80005384 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052f6:	85a6                	mv	a1,s1
    800052f8:	854e                	mv	a0,s3
    800052fa:	ffffd097          	auipc	ra,0xffffd
    800052fe:	c28080e7          	jalr	-984(ra) # 80001f22 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005302:	2184a703          	lw	a4,536(s1)
    80005306:	21c4a783          	lw	a5,540(s1)
    8000530a:	fef700e3          	beq	a4,a5,800052ea <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000530e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005310:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005312:	05505363          	blez	s5,80005358 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80005316:	2184a783          	lw	a5,536(s1)
    8000531a:	21c4a703          	lw	a4,540(s1)
    8000531e:	02f70d63          	beq	a4,a5,80005358 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005322:	0017871b          	addiw	a4,a5,1
    80005326:	20e4ac23          	sw	a4,536(s1)
    8000532a:	1ff7f793          	andi	a5,a5,511
    8000532e:	97a6                	add	a5,a5,s1
    80005330:	0187c783          	lbu	a5,24(a5)
    80005334:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005338:	4685                	li	a3,1
    8000533a:	fbf40613          	addi	a2,s0,-65
    8000533e:	85ca                	mv	a1,s2
    80005340:	050a3503          	ld	a0,80(s4)
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	310080e7          	jalr	784(ra) # 80001654 <copyout>
    8000534c:	01650663          	beq	a0,s6,80005358 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005350:	2985                	addiw	s3,s3,1
    80005352:	0905                	addi	s2,s2,1
    80005354:	fd3a91e3          	bne	s5,s3,80005316 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005358:	21c48513          	addi	a0,s1,540
    8000535c:	ffffd097          	auipc	ra,0xffffd
    80005360:	d52080e7          	jalr	-686(ra) # 800020ae <wakeup>
  release(&pi->lock);
    80005364:	8526                	mv	a0,s1
    80005366:	ffffc097          	auipc	ra,0xffffc
    8000536a:	910080e7          	jalr	-1776(ra) # 80000c76 <release>
  return i;
}
    8000536e:	854e                	mv	a0,s3
    80005370:	60a6                	ld	ra,72(sp)
    80005372:	6406                	ld	s0,64(sp)
    80005374:	74e2                	ld	s1,56(sp)
    80005376:	7942                	ld	s2,48(sp)
    80005378:	79a2                	ld	s3,40(sp)
    8000537a:	7a02                	ld	s4,32(sp)
    8000537c:	6ae2                	ld	s5,24(sp)
    8000537e:	6b42                	ld	s6,16(sp)
    80005380:	6161                	addi	sp,sp,80
    80005382:	8082                	ret
      release(&pi->lock);
    80005384:	8526                	mv	a0,s1
    80005386:	ffffc097          	auipc	ra,0xffffc
    8000538a:	8f0080e7          	jalr	-1808(ra) # 80000c76 <release>
      return -1;
    8000538e:	59fd                	li	s3,-1
    80005390:	bff9                	j	8000536e <piperead+0xc2>

0000000080005392 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005392:	de010113          	addi	sp,sp,-544
    80005396:	20113c23          	sd	ra,536(sp)
    8000539a:	20813823          	sd	s0,528(sp)
    8000539e:	20913423          	sd	s1,520(sp)
    800053a2:	21213023          	sd	s2,512(sp)
    800053a6:	ffce                	sd	s3,504(sp)
    800053a8:	fbd2                	sd	s4,496(sp)
    800053aa:	f7d6                	sd	s5,488(sp)
    800053ac:	f3da                	sd	s6,480(sp)
    800053ae:	efde                	sd	s7,472(sp)
    800053b0:	ebe2                	sd	s8,464(sp)
    800053b2:	e7e6                	sd	s9,456(sp)
    800053b4:	e3ea                	sd	s10,448(sp)
    800053b6:	ff6e                	sd	s11,440(sp)
    800053b8:	1400                	addi	s0,sp,544
    800053ba:	892a                	mv	s2,a0
    800053bc:	dea43423          	sd	a0,-536(s0)
    800053c0:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053c4:	ffffc097          	auipc	ra,0xffffc
    800053c8:	5d6080e7          	jalr	1494(ra) # 8000199a <myproc>
    800053cc:	84aa                	mv	s1,a0

  begin_op();
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	2b0080e7          	jalr	688(ra) # 8000467e <begin_op>

  if((ip = namei(path)) == 0){
    800053d6:	854a                	mv	a0,s2
    800053d8:	fffff097          	auipc	ra,0xfffff
    800053dc:	d74080e7          	jalr	-652(ra) # 8000414c <namei>
    800053e0:	c93d                	beqz	a0,80005456 <exec+0xc4>
    800053e2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	5b2080e7          	jalr	1458(ra) # 80003996 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800053ec:	04000713          	li	a4,64
    800053f0:	4681                	li	a3,0
    800053f2:	e4840613          	addi	a2,s0,-440
    800053f6:	4581                	li	a1,0
    800053f8:	8556                	mv	a0,s5
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	850080e7          	jalr	-1968(ra) # 80003c4a <readi>
    80005402:	04000793          	li	a5,64
    80005406:	00f51a63          	bne	a0,a5,8000541a <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000540a:	e4842703          	lw	a4,-440(s0)
    8000540e:	464c47b7          	lui	a5,0x464c4
    80005412:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005416:	04f70663          	beq	a4,a5,80005462 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000541a:	8556                	mv	a0,s5
    8000541c:	ffffe097          	auipc	ra,0xffffe
    80005420:	7dc080e7          	jalr	2012(ra) # 80003bf8 <iunlockput>
    end_op();
    80005424:	fffff097          	auipc	ra,0xfffff
    80005428:	2da080e7          	jalr	730(ra) # 800046fe <end_op>
  }
  return -1;
    8000542c:	557d                	li	a0,-1
}
    8000542e:	21813083          	ld	ra,536(sp)
    80005432:	21013403          	ld	s0,528(sp)
    80005436:	20813483          	ld	s1,520(sp)
    8000543a:	20013903          	ld	s2,512(sp)
    8000543e:	79fe                	ld	s3,504(sp)
    80005440:	7a5e                	ld	s4,496(sp)
    80005442:	7abe                	ld	s5,488(sp)
    80005444:	7b1e                	ld	s6,480(sp)
    80005446:	6bfe                	ld	s7,472(sp)
    80005448:	6c5e                	ld	s8,464(sp)
    8000544a:	6cbe                	ld	s9,456(sp)
    8000544c:	6d1e                	ld	s10,448(sp)
    8000544e:	7dfa                	ld	s11,440(sp)
    80005450:	22010113          	addi	sp,sp,544
    80005454:	8082                	ret
    end_op();
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	2a8080e7          	jalr	680(ra) # 800046fe <end_op>
    return -1;
    8000545e:	557d                	li	a0,-1
    80005460:	b7f9                	j	8000542e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005462:	8526                	mv	a0,s1
    80005464:	ffffc097          	auipc	ra,0xffffc
    80005468:	5fa080e7          	jalr	1530(ra) # 80001a5e <proc_pagetable>
    8000546c:	8b2a                	mv	s6,a0
    8000546e:	d555                	beqz	a0,8000541a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005470:	e6842783          	lw	a5,-408(s0)
    80005474:	e8045703          	lhu	a4,-384(s0)
    80005478:	c73d                	beqz	a4,800054e6 <exec+0x154>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000547a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000547c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005480:	6a05                	lui	s4,0x1
    80005482:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005486:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000548a:	6d85                	lui	s11,0x1
    8000548c:	7d7d                	lui	s10,0xfffff
    8000548e:	ac25                	j	800056c6 <exec+0x334>
    pa = walkaddr(pagetable, va + i, 0);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005490:	00003517          	auipc	a0,0x3
    80005494:	43050513          	addi	a0,a0,1072 # 800088c0 <syscalls+0x2f0>
    80005498:	ffffb097          	auipc	ra,0xffffb
    8000549c:	092080e7          	jalr	146(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054a0:	874a                	mv	a4,s2
    800054a2:	009c86bb          	addw	a3,s9,s1
    800054a6:	4581                	li	a1,0
    800054a8:	8556                	mv	a0,s5
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	7a0080e7          	jalr	1952(ra) # 80003c4a <readi>
    800054b2:	2501                	sext.w	a0,a0
    800054b4:	1aa91963          	bne	s2,a0,80005666 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    800054b8:	009d84bb          	addw	s1,s11,s1
    800054bc:	013d09bb          	addw	s3,s10,s3
    800054c0:	1f74f363          	bgeu	s1,s7,800056a6 <exec+0x314>
    pa = walkaddr(pagetable, va + i, 0);
    800054c4:	02049593          	slli	a1,s1,0x20
    800054c8:	9181                	srli	a1,a1,0x20
    800054ca:	4601                	li	a2,0
    800054cc:	95e2                	add	a1,a1,s8
    800054ce:	855a                	mv	a0,s6
    800054d0:	ffffc097          	auipc	ra,0xffffc
    800054d4:	b7c080e7          	jalr	-1156(ra) # 8000104c <walkaddr>
    800054d8:	862a                	mv	a2,a0
    if(pa == 0)
    800054da:	d95d                	beqz	a0,80005490 <exec+0xfe>
      n = PGSIZE;
    800054dc:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800054de:	fd49f1e3          	bgeu	s3,s4,800054a0 <exec+0x10e>
      n = sz - i;
    800054e2:	894e                	mv	s2,s3
    800054e4:	bf75                	j	800054a0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800054e6:	4481                	li	s1,0
  iunlockput(ip);
    800054e8:	8556                	mv	a0,s5
    800054ea:	ffffe097          	auipc	ra,0xffffe
    800054ee:	70e080e7          	jalr	1806(ra) # 80003bf8 <iunlockput>
  end_op();
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	20c080e7          	jalr	524(ra) # 800046fe <end_op>
  p = myproc();
    800054fa:	ffffc097          	auipc	ra,0xffffc
    800054fe:	4a0080e7          	jalr	1184(ra) # 8000199a <myproc>
    80005502:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005504:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005508:	6785                	lui	a5,0x1
    8000550a:	17fd                	addi	a5,a5,-1
    8000550c:	94be                	add	s1,s1,a5
    8000550e:	77fd                	lui	a5,0xfffff
    80005510:	8fe5                	and	a5,a5,s1
    80005512:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005516:	6609                	lui	a2,0x2
    80005518:	963e                	add	a2,a2,a5
    8000551a:	85be                	mv	a1,a5
    8000551c:	855a                	mv	a0,s6
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	ee6080e7          	jalr	-282(ra) # 80001404 <uvmalloc>
    80005526:	8c2a                	mv	s8,a0
  ip = 0;
    80005528:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000552a:	12050e63          	beqz	a0,80005666 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000552e:	75f9                	lui	a1,0xffffe
    80005530:	95aa                	add	a1,a1,a0
    80005532:	855a                	mv	a0,s6
    80005534:	ffffc097          	auipc	ra,0xffffc
    80005538:	0ee080e7          	jalr	238(ra) # 80001622 <uvmclear>
  stackbase = sp - PGSIZE;
    8000553c:	7afd                	lui	s5,0xfffff
    8000553e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005540:	df043783          	ld	a5,-528(s0)
    80005544:	6388                	ld	a0,0(a5)
    80005546:	c925                	beqz	a0,800055b6 <exec+0x224>
    80005548:	e8840993          	addi	s3,s0,-376
    8000554c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005550:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005552:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005554:	ffffc097          	auipc	ra,0xffffc
    80005558:	8ee080e7          	jalr	-1810(ra) # 80000e42 <strlen>
    8000555c:	0015079b          	addiw	a5,a0,1
    80005560:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005564:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005568:	13596363          	bltu	s2,s5,8000568e <exec+0x2fc>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000556c:	df043d83          	ld	s11,-528(s0)
    80005570:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005574:	8552                	mv	a0,s4
    80005576:	ffffc097          	auipc	ra,0xffffc
    8000557a:	8cc080e7          	jalr	-1844(ra) # 80000e42 <strlen>
    8000557e:	0015069b          	addiw	a3,a0,1
    80005582:	8652                	mv	a2,s4
    80005584:	85ca                	mv	a1,s2
    80005586:	855a                	mv	a0,s6
    80005588:	ffffc097          	auipc	ra,0xffffc
    8000558c:	0cc080e7          	jalr	204(ra) # 80001654 <copyout>
    80005590:	10054363          	bltz	a0,80005696 <exec+0x304>
    ustack[argc] = sp;
    80005594:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005598:	0485                	addi	s1,s1,1
    8000559a:	008d8793          	addi	a5,s11,8
    8000559e:	def43823          	sd	a5,-528(s0)
    800055a2:	008db503          	ld	a0,8(s11)
    800055a6:	c911                	beqz	a0,800055ba <exec+0x228>
    if(argc >= MAXARG)
    800055a8:	09a1                	addi	s3,s3,8
    800055aa:	fb3c95e3          	bne	s9,s3,80005554 <exec+0x1c2>
  sz = sz1;
    800055ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055b2:	4a81                	li	s5,0
    800055b4:	a84d                	j	80005666 <exec+0x2d4>
  sp = sz;
    800055b6:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800055b8:	4481                	li	s1,0
  ustack[argc] = 0;
    800055ba:	00349793          	slli	a5,s1,0x3
    800055be:	f9040713          	addi	a4,s0,-112
    800055c2:	97ba                	add	a5,a5,a4
    800055c4:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0ef8>
  sp -= (argc+1) * sizeof(uint64);
    800055c8:	00148693          	addi	a3,s1,1
    800055cc:	068e                	slli	a3,a3,0x3
    800055ce:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055d2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800055d6:	01597663          	bgeu	s2,s5,800055e2 <exec+0x250>
  sz = sz1;
    800055da:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055de:	4a81                	li	s5,0
    800055e0:	a059                	j	80005666 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800055e2:	e8840613          	addi	a2,s0,-376
    800055e6:	85ca                	mv	a1,s2
    800055e8:	855a                	mv	a0,s6
    800055ea:	ffffc097          	auipc	ra,0xffffc
    800055ee:	06a080e7          	jalr	106(ra) # 80001654 <copyout>
    800055f2:	0a054663          	bltz	a0,8000569e <exec+0x30c>
  p->trapframe->a1 = sp;
    800055f6:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800055fa:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800055fe:	de843783          	ld	a5,-536(s0)
    80005602:	0007c703          	lbu	a4,0(a5)
    80005606:	cf11                	beqz	a4,80005622 <exec+0x290>
    80005608:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000560a:	02f00693          	li	a3,47
    8000560e:	a039                	j	8000561c <exec+0x28a>
      last = s+1;
    80005610:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005614:	0785                	addi	a5,a5,1
    80005616:	fff7c703          	lbu	a4,-1(a5)
    8000561a:	c701                	beqz	a4,80005622 <exec+0x290>
    if(*s == '/')
    8000561c:	fed71ce3          	bne	a4,a3,80005614 <exec+0x282>
    80005620:	bfc5                	j	80005610 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005622:	4641                	li	a2,16
    80005624:	de843583          	ld	a1,-536(s0)
    80005628:	158b8513          	addi	a0,s7,344
    8000562c:	ffffb097          	auipc	ra,0xffffb
    80005630:	7e4080e7          	jalr	2020(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005634:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005638:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000563c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005640:	058bb783          	ld	a5,88(s7)
    80005644:	e6043703          	ld	a4,-416(s0)
    80005648:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000564a:	058bb783          	ld	a5,88(s7)
    8000564e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005652:	85ea                	mv	a1,s10
    80005654:	ffffc097          	auipc	ra,0xffffc
    80005658:	4a6080e7          	jalr	1190(ra) # 80001afa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000565c:	0004851b          	sext.w	a0,s1
    80005660:	b3f9                	j	8000542e <exec+0x9c>
    80005662:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005666:	df843583          	ld	a1,-520(s0)
    8000566a:	855a                	mv	a0,s6
    8000566c:	ffffc097          	auipc	ra,0xffffc
    80005670:	48e080e7          	jalr	1166(ra) # 80001afa <proc_freepagetable>
  if(ip){
    80005674:	da0a93e3          	bnez	s5,8000541a <exec+0x88>
  return -1;
    80005678:	557d                	li	a0,-1
    8000567a:	bb55                	j	8000542e <exec+0x9c>
    8000567c:	de943c23          	sd	s1,-520(s0)
    80005680:	b7dd                	j	80005666 <exec+0x2d4>
    80005682:	de943c23          	sd	s1,-520(s0)
    80005686:	b7c5                	j	80005666 <exec+0x2d4>
    80005688:	de943c23          	sd	s1,-520(s0)
    8000568c:	bfe9                	j	80005666 <exec+0x2d4>
  sz = sz1;
    8000568e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005692:	4a81                	li	s5,0
    80005694:	bfc9                	j	80005666 <exec+0x2d4>
  sz = sz1;
    80005696:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000569a:	4a81                	li	s5,0
    8000569c:	b7e9                	j	80005666 <exec+0x2d4>
  sz = sz1;
    8000569e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056a2:	4a81                	li	s5,0
    800056a4:	b7c9                	j	80005666 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800056a6:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056aa:	e0843783          	ld	a5,-504(s0)
    800056ae:	0017869b          	addiw	a3,a5,1
    800056b2:	e0d43423          	sd	a3,-504(s0)
    800056b6:	e0043783          	ld	a5,-512(s0)
    800056ba:	0387879b          	addiw	a5,a5,56
    800056be:	e8045703          	lhu	a4,-384(s0)
    800056c2:	e2e6d3e3          	bge	a3,a4,800054e8 <exec+0x156>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056c6:	2781                	sext.w	a5,a5
    800056c8:	e0f43023          	sd	a5,-512(s0)
    800056cc:	03800713          	li	a4,56
    800056d0:	86be                	mv	a3,a5
    800056d2:	e1040613          	addi	a2,s0,-496
    800056d6:	4581                	li	a1,0
    800056d8:	8556                	mv	a0,s5
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	570080e7          	jalr	1392(ra) # 80003c4a <readi>
    800056e2:	03800793          	li	a5,56
    800056e6:	f6f51ee3          	bne	a0,a5,80005662 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    800056ea:	e1042783          	lw	a5,-496(s0)
    800056ee:	4705                	li	a4,1
    800056f0:	fae79de3          	bne	a5,a4,800056aa <exec+0x318>
    if(ph.memsz < ph.filesz)
    800056f4:	e3843603          	ld	a2,-456(s0)
    800056f8:	e3043783          	ld	a5,-464(s0)
    800056fc:	f8f660e3          	bltu	a2,a5,8000567c <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005700:	e2043783          	ld	a5,-480(s0)
    80005704:	963e                	add	a2,a2,a5
    80005706:	f6f66ee3          	bltu	a2,a5,80005682 <exec+0x2f0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000570a:	85a6                	mv	a1,s1
    8000570c:	855a                	mv	a0,s6
    8000570e:	ffffc097          	auipc	ra,0xffffc
    80005712:	cf6080e7          	jalr	-778(ra) # 80001404 <uvmalloc>
    80005716:	dea43c23          	sd	a0,-520(s0)
    8000571a:	d53d                	beqz	a0,80005688 <exec+0x2f6>
    if(ph.vaddr % PGSIZE != 0)
    8000571c:	e2043c03          	ld	s8,-480(s0)
    80005720:	de043783          	ld	a5,-544(s0)
    80005724:	00fc77b3          	and	a5,s8,a5
    80005728:	ff9d                	bnez	a5,80005666 <exec+0x2d4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000572a:	e1842c83          	lw	s9,-488(s0)
    8000572e:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005732:	f60b8ae3          	beqz	s7,800056a6 <exec+0x314>
    80005736:	89de                	mv	s3,s7
    80005738:	4481                	li	s1,0
    8000573a:	b369                	j	800054c4 <exec+0x132>

000000008000573c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000573c:	7179                	addi	sp,sp,-48
    8000573e:	f406                	sd	ra,40(sp)
    80005740:	f022                	sd	s0,32(sp)
    80005742:	ec26                	sd	s1,24(sp)
    80005744:	e84a                	sd	s2,16(sp)
    80005746:	1800                	addi	s0,sp,48
    80005748:	892e                	mv	s2,a1
    8000574a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000574c:	fdc40593          	addi	a1,s0,-36
    80005750:	ffffd097          	auipc	ra,0xffffd
    80005754:	6d4080e7          	jalr	1748(ra) # 80002e24 <argint>
    80005758:	04054063          	bltz	a0,80005798 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000575c:	fdc42703          	lw	a4,-36(s0)
    80005760:	47bd                	li	a5,15
    80005762:	02e7ed63          	bltu	a5,a4,8000579c <argfd+0x60>
    80005766:	ffffc097          	auipc	ra,0xffffc
    8000576a:	234080e7          	jalr	564(ra) # 8000199a <myproc>
    8000576e:	fdc42703          	lw	a4,-36(s0)
    80005772:	01a70793          	addi	a5,a4,26
    80005776:	078e                	slli	a5,a5,0x3
    80005778:	953e                	add	a0,a0,a5
    8000577a:	611c                	ld	a5,0(a0)
    8000577c:	c395                	beqz	a5,800057a0 <argfd+0x64>
    return -1;
  if(pfd)
    8000577e:	00090463          	beqz	s2,80005786 <argfd+0x4a>
    *pfd = fd;
    80005782:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005786:	4501                	li	a0,0
  if(pf)
    80005788:	c091                	beqz	s1,8000578c <argfd+0x50>
    *pf = f;
    8000578a:	e09c                	sd	a5,0(s1)
}
    8000578c:	70a2                	ld	ra,40(sp)
    8000578e:	7402                	ld	s0,32(sp)
    80005790:	64e2                	ld	s1,24(sp)
    80005792:	6942                	ld	s2,16(sp)
    80005794:	6145                	addi	sp,sp,48
    80005796:	8082                	ret
    return -1;
    80005798:	557d                	li	a0,-1
    8000579a:	bfcd                	j	8000578c <argfd+0x50>
    return -1;
    8000579c:	557d                	li	a0,-1
    8000579e:	b7fd                	j	8000578c <argfd+0x50>
    800057a0:	557d                	li	a0,-1
    800057a2:	b7ed                	j	8000578c <argfd+0x50>

00000000800057a4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057a4:	1101                	addi	sp,sp,-32
    800057a6:	ec06                	sd	ra,24(sp)
    800057a8:	e822                	sd	s0,16(sp)
    800057aa:	e426                	sd	s1,8(sp)
    800057ac:	1000                	addi	s0,sp,32
    800057ae:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057b0:	ffffc097          	auipc	ra,0xffffc
    800057b4:	1ea080e7          	jalr	490(ra) # 8000199a <myproc>
    800057b8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057ba:	0d050793          	addi	a5,a0,208
    800057be:	4501                	li	a0,0
    800057c0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057c2:	6398                	ld	a4,0(a5)
    800057c4:	cb19                	beqz	a4,800057da <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057c6:	2505                	addiw	a0,a0,1
    800057c8:	07a1                	addi	a5,a5,8
    800057ca:	fed51ce3          	bne	a0,a3,800057c2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800057ce:	557d                	li	a0,-1
}
    800057d0:	60e2                	ld	ra,24(sp)
    800057d2:	6442                	ld	s0,16(sp)
    800057d4:	64a2                	ld	s1,8(sp)
    800057d6:	6105                	addi	sp,sp,32
    800057d8:	8082                	ret
      p->ofile[fd] = f;
    800057da:	01a50793          	addi	a5,a0,26
    800057de:	078e                	slli	a5,a5,0x3
    800057e0:	963e                	add	a2,a2,a5
    800057e2:	e204                	sd	s1,0(a2)
      return fd;
    800057e4:	b7f5                	j	800057d0 <fdalloc+0x2c>

00000000800057e6 <sys_dup>:

uint64
sys_dup(void)
{
    800057e6:	7179                	addi	sp,sp,-48
    800057e8:	f406                	sd	ra,40(sp)
    800057ea:	f022                	sd	s0,32(sp)
    800057ec:	ec26                	sd	s1,24(sp)
    800057ee:	1800                	addi	s0,sp,48
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    800057f0:	fd840613          	addi	a2,s0,-40
    800057f4:	4581                	li	a1,0
    800057f6:	4501                	li	a0,0
    800057f8:	00000097          	auipc	ra,0x0
    800057fc:	f44080e7          	jalr	-188(ra) # 8000573c <argfd>
    return -1;
    80005800:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005802:	02054363          	bltz	a0,80005828 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005806:	fd843503          	ld	a0,-40(s0)
    8000580a:	00000097          	auipc	ra,0x0
    8000580e:	f9a080e7          	jalr	-102(ra) # 800057a4 <fdalloc>
    80005812:	84aa                	mv	s1,a0
    return -1;
    80005814:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005816:	00054963          	bltz	a0,80005828 <sys_dup+0x42>
  filedup(f);
    8000581a:	fd843503          	ld	a0,-40(s0)
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	2da080e7          	jalr	730(ra) # 80004af8 <filedup>
  return fd;
    80005826:	87a6                	mv	a5,s1
}
    80005828:	853e                	mv	a0,a5
    8000582a:	70a2                	ld	ra,40(sp)
    8000582c:	7402                	ld	s0,32(sp)
    8000582e:	64e2                	ld	s1,24(sp)
    80005830:	6145                	addi	sp,sp,48
    80005832:	8082                	ret

0000000080005834 <sys_read>:

uint64
sys_read(void)
{
    80005834:	7179                	addi	sp,sp,-48
    80005836:	f406                	sd	ra,40(sp)
    80005838:	f022                	sd	s0,32(sp)
    8000583a:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000583c:	fe840613          	addi	a2,s0,-24
    80005840:	4581                	li	a1,0
    80005842:	4501                	li	a0,0
    80005844:	00000097          	auipc	ra,0x0
    80005848:	ef8080e7          	jalr	-264(ra) # 8000573c <argfd>
    return -1;
    8000584c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000584e:	04054163          	bltz	a0,80005890 <sys_read+0x5c>
    80005852:	fe440593          	addi	a1,s0,-28
    80005856:	4509                	li	a0,2
    80005858:	ffffd097          	auipc	ra,0xffffd
    8000585c:	5cc080e7          	jalr	1484(ra) # 80002e24 <argint>
    return -1;
    80005860:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005862:	02054763          	bltz	a0,80005890 <sys_read+0x5c>
    80005866:	fd840593          	addi	a1,s0,-40
    8000586a:	4505                	li	a0,1
    8000586c:	ffffd097          	auipc	ra,0xffffd
    80005870:	5da080e7          	jalr	1498(ra) # 80002e46 <argaddr>
    return -1;
    80005874:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005876:	00054d63          	bltz	a0,80005890 <sys_read+0x5c>
  return fileread(f, p, n);
    8000587a:	fe442603          	lw	a2,-28(s0)
    8000587e:	fd843583          	ld	a1,-40(s0)
    80005882:	fe843503          	ld	a0,-24(s0)
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	3fe080e7          	jalr	1022(ra) # 80004c84 <fileread>
    8000588e:	87aa                	mv	a5,a0
}
    80005890:	853e                	mv	a0,a5
    80005892:	70a2                	ld	ra,40(sp)
    80005894:	7402                	ld	s0,32(sp)
    80005896:	6145                	addi	sp,sp,48
    80005898:	8082                	ret

000000008000589a <sys_write>:

uint64
sys_write(void)
{
    8000589a:	7179                	addi	sp,sp,-48
    8000589c:	f406                	sd	ra,40(sp)
    8000589e:	f022                	sd	s0,32(sp)
    800058a0:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058a2:	fe840613          	addi	a2,s0,-24
    800058a6:	4581                	li	a1,0
    800058a8:	4501                	li	a0,0
    800058aa:	00000097          	auipc	ra,0x0
    800058ae:	e92080e7          	jalr	-366(ra) # 8000573c <argfd>
    return -1;
    800058b2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058b4:	04054163          	bltz	a0,800058f6 <sys_write+0x5c>
    800058b8:	fe440593          	addi	a1,s0,-28
    800058bc:	4509                	li	a0,2
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	566080e7          	jalr	1382(ra) # 80002e24 <argint>
    return -1;
    800058c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058c8:	02054763          	bltz	a0,800058f6 <sys_write+0x5c>
    800058cc:	fd840593          	addi	a1,s0,-40
    800058d0:	4505                	li	a0,1
    800058d2:	ffffd097          	auipc	ra,0xffffd
    800058d6:	574080e7          	jalr	1396(ra) # 80002e46 <argaddr>
    return -1;
    800058da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058dc:	00054d63          	bltz	a0,800058f6 <sys_write+0x5c>

  return filewrite(f, p, n);
    800058e0:	fe442603          	lw	a2,-28(s0)
    800058e4:	fd843583          	ld	a1,-40(s0)
    800058e8:	fe843503          	ld	a0,-24(s0)
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	45a080e7          	jalr	1114(ra) # 80004d46 <filewrite>
    800058f4:	87aa                	mv	a5,a0
}
    800058f6:	853e                	mv	a0,a5
    800058f8:	70a2                	ld	ra,40(sp)
    800058fa:	7402                	ld	s0,32(sp)
    800058fc:	6145                	addi	sp,sp,48
    800058fe:	8082                	ret

0000000080005900 <sys_close>:

uint64
sys_close(void)
{
    80005900:	1101                	addi	sp,sp,-32
    80005902:	ec06                	sd	ra,24(sp)
    80005904:	e822                	sd	s0,16(sp)
    80005906:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80005908:	fe040613          	addi	a2,s0,-32
    8000590c:	fec40593          	addi	a1,s0,-20
    80005910:	4501                	li	a0,0
    80005912:	00000097          	auipc	ra,0x0
    80005916:	e2a080e7          	jalr	-470(ra) # 8000573c <argfd>
    return -1;
    8000591a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000591c:	02054463          	bltz	a0,80005944 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005920:	ffffc097          	auipc	ra,0xffffc
    80005924:	07a080e7          	jalr	122(ra) # 8000199a <myproc>
    80005928:	fec42783          	lw	a5,-20(s0)
    8000592c:	07e9                	addi	a5,a5,26
    8000592e:	078e                	slli	a5,a5,0x3
    80005930:	97aa                	add	a5,a5,a0
    80005932:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005936:	fe043503          	ld	a0,-32(s0)
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	210080e7          	jalr	528(ra) # 80004b4a <fileclose>
  return 0;
    80005942:	4781                	li	a5,0
}
    80005944:	853e                	mv	a0,a5
    80005946:	60e2                	ld	ra,24(sp)
    80005948:	6442                	ld	s0,16(sp)
    8000594a:	6105                	addi	sp,sp,32
    8000594c:	8082                	ret

000000008000594e <sys_fstat>:

uint64
sys_fstat(void)
{
    8000594e:	1101                	addi	sp,sp,-32
    80005950:	ec06                	sd	ra,24(sp)
    80005952:	e822                	sd	s0,16(sp)
    80005954:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005956:	fe840613          	addi	a2,s0,-24
    8000595a:	4581                	li	a1,0
    8000595c:	4501                	li	a0,0
    8000595e:	00000097          	auipc	ra,0x0
    80005962:	dde080e7          	jalr	-546(ra) # 8000573c <argfd>
    return -1;
    80005966:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005968:	02054563          	bltz	a0,80005992 <sys_fstat+0x44>
    8000596c:	fe040593          	addi	a1,s0,-32
    80005970:	4505                	li	a0,1
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	4d4080e7          	jalr	1236(ra) # 80002e46 <argaddr>
    return -1;
    8000597a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000597c:	00054b63          	bltz	a0,80005992 <sys_fstat+0x44>
  return filestat(f, st);
    80005980:	fe043583          	ld	a1,-32(s0)
    80005984:	fe843503          	ld	a0,-24(s0)
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	28a080e7          	jalr	650(ra) # 80004c12 <filestat>
    80005990:	87aa                	mv	a5,a0
}
    80005992:	853e                	mv	a0,a5
    80005994:	60e2                	ld	ra,24(sp)
    80005996:	6442                	ld	s0,16(sp)
    80005998:	6105                	addi	sp,sp,32
    8000599a:	8082                	ret

000000008000599c <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    8000599c:	7169                	addi	sp,sp,-304
    8000599e:	f606                	sd	ra,296(sp)
    800059a0:	f222                	sd	s0,288(sp)
    800059a2:	ee26                	sd	s1,280(sp)
    800059a4:	ea4a                	sd	s2,272(sp)
    800059a6:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059a8:	08000613          	li	a2,128
    800059ac:	ed040593          	addi	a1,s0,-304
    800059b0:	4501                	li	a0,0
    800059b2:	ffffd097          	auipc	ra,0xffffd
    800059b6:	4b6080e7          	jalr	1206(ra) # 80002e68 <argstr>
    return -1;
    800059ba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059bc:	10054e63          	bltz	a0,80005ad8 <sys_link+0x13c>
    800059c0:	08000613          	li	a2,128
    800059c4:	f5040593          	addi	a1,s0,-176
    800059c8:	4505                	li	a0,1
    800059ca:	ffffd097          	auipc	ra,0xffffd
    800059ce:	49e080e7          	jalr	1182(ra) # 80002e68 <argstr>
    return -1;
    800059d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059d4:	10054263          	bltz	a0,80005ad8 <sys_link+0x13c>

  begin_op();
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	ca6080e7          	jalr	-858(ra) # 8000467e <begin_op>
  if((ip = namei(old)) == 0){
    800059e0:	ed040513          	addi	a0,s0,-304
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	768080e7          	jalr	1896(ra) # 8000414c <namei>
    800059ec:	84aa                	mv	s1,a0
    800059ee:	c551                	beqz	a0,80005a7a <sys_link+0xde>
    end_op();
    return -1;
  }

  ilock(ip);
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	fa6080e7          	jalr	-90(ra) # 80003996 <ilock>
  if(ip->type == T_DIR){
    800059f8:	04449703          	lh	a4,68(s1)
    800059fc:	4785                	li	a5,1
    800059fe:	08f70463          	beq	a4,a5,80005a86 <sys_link+0xea>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
    80005a02:	04a4d783          	lhu	a5,74(s1)
    80005a06:	2785                	addiw	a5,a5,1
    80005a08:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	ebe080e7          	jalr	-322(ra) # 800038cc <iupdate>
  iunlock(ip);
    80005a16:	8526                	mv	a0,s1
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	040080e7          	jalr	64(ra) # 80003a58 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80005a20:	fd040593          	addi	a1,s0,-48
    80005a24:	f5040513          	addi	a0,s0,-176
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	742080e7          	jalr	1858(ra) # 8000416a <nameiparent>
    80005a30:	892a                	mv	s2,a0
    80005a32:	c935                	beqz	a0,80005aa6 <sys_link+0x10a>
    goto bad;
  ilock(dp);
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	f62080e7          	jalr	-158(ra) # 80003996 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a3c:	00092703          	lw	a4,0(s2)
    80005a40:	409c                	lw	a5,0(s1)
    80005a42:	04f71d63          	bne	a4,a5,80005a9c <sys_link+0x100>
    80005a46:	40d0                	lw	a2,4(s1)
    80005a48:	fd040593          	addi	a1,s0,-48
    80005a4c:	854a                	mv	a0,s2
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	63c080e7          	jalr	1596(ra) # 8000408a <dirlink>
    80005a56:	04054363          	bltz	a0,80005a9c <sys_link+0x100>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
    80005a5a:	854a                	mv	a0,s2
    80005a5c:	ffffe097          	auipc	ra,0xffffe
    80005a60:	19c080e7          	jalr	412(ra) # 80003bf8 <iunlockput>
  iput(ip);
    80005a64:	8526                	mv	a0,s1
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	0ea080e7          	jalr	234(ra) # 80003b50 <iput>

  end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	c90080e7          	jalr	-880(ra) # 800046fe <end_op>

  return 0;
    80005a76:	4781                	li	a5,0
    80005a78:	a085                	j	80005ad8 <sys_link+0x13c>
    end_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	c84080e7          	jalr	-892(ra) # 800046fe <end_op>
    return -1;
    80005a82:	57fd                	li	a5,-1
    80005a84:	a891                	j	80005ad8 <sys_link+0x13c>
    iunlockput(ip);
    80005a86:	8526                	mv	a0,s1
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	170080e7          	jalr	368(ra) # 80003bf8 <iunlockput>
    end_op();
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	c6e080e7          	jalr	-914(ra) # 800046fe <end_op>
    return -1;
    80005a98:	57fd                	li	a5,-1
    80005a9a:	a83d                	j	80005ad8 <sys_link+0x13c>
    iunlockput(dp);
    80005a9c:	854a                	mv	a0,s2
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	15a080e7          	jalr	346(ra) # 80003bf8 <iunlockput>

bad:
  ilock(ip);
    80005aa6:	8526                	mv	a0,s1
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	eee080e7          	jalr	-274(ra) # 80003996 <ilock>
  ip->nlink--;
    80005ab0:	04a4d783          	lhu	a5,74(s1)
    80005ab4:	37fd                	addiw	a5,a5,-1
    80005ab6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005aba:	8526                	mv	a0,s1
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	e10080e7          	jalr	-496(ra) # 800038cc <iupdate>
  iunlockput(ip);
    80005ac4:	8526                	mv	a0,s1
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	132080e7          	jalr	306(ra) # 80003bf8 <iunlockput>
  end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	c30080e7          	jalr	-976(ra) # 800046fe <end_op>
  return -1;
    80005ad6:	57fd                	li	a5,-1
}
    80005ad8:	853e                	mv	a0,a5
    80005ada:	70b2                	ld	ra,296(sp)
    80005adc:	7412                	ld	s0,288(sp)
    80005ade:	64f2                	ld	s1,280(sp)
    80005ae0:	6952                	ld	s2,272(sp)
    80005ae2:	6155                	addi	sp,sp,304
    80005ae4:	8082                	ret

0000000080005ae6 <isdirempty>:
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ae6:	4578                	lw	a4,76(a0)
    80005ae8:	02000793          	li	a5,32
    80005aec:	04e7fa63          	bgeu	a5,a4,80005b40 <isdirempty+0x5a>
{
    80005af0:	7179                	addi	sp,sp,-48
    80005af2:	f406                	sd	ra,40(sp)
    80005af4:	f022                	sd	s0,32(sp)
    80005af6:	ec26                	sd	s1,24(sp)
    80005af8:	e84a                	sd	s2,16(sp)
    80005afa:	1800                	addi	s0,sp,48
    80005afc:	892a                	mv	s2,a0
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005afe:	02000493          	li	s1,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b02:	4741                	li	a4,16
    80005b04:	86a6                	mv	a3,s1
    80005b06:	fd040613          	addi	a2,s0,-48
    80005b0a:	4581                	li	a1,0
    80005b0c:	854a                	mv	a0,s2
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	13c080e7          	jalr	316(ra) # 80003c4a <readi>
    80005b16:	47c1                	li	a5,16
    80005b18:	00f51c63          	bne	a0,a5,80005b30 <isdirempty+0x4a>
      panic("isdirempty: readi");
    if(de.inum != 0)
    80005b1c:	fd045783          	lhu	a5,-48(s0)
    80005b20:	e395                	bnez	a5,80005b44 <isdirempty+0x5e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b22:	24c1                	addiw	s1,s1,16
    80005b24:	04c92783          	lw	a5,76(s2)
    80005b28:	fcf4ede3          	bltu	s1,a5,80005b02 <isdirempty+0x1c>
      return 0;
  }
  return 1;
    80005b2c:	4505                	li	a0,1
    80005b2e:	a821                	j	80005b46 <isdirempty+0x60>
      panic("isdirempty: readi");
    80005b30:	00003517          	auipc	a0,0x3
    80005b34:	db050513          	addi	a0,a0,-592 # 800088e0 <syscalls+0x310>
    80005b38:	ffffb097          	auipc	ra,0xffffb
    80005b3c:	9f2080e7          	jalr	-1550(ra) # 8000052a <panic>
  return 1;
    80005b40:	4505                	li	a0,1
}
    80005b42:	8082                	ret
      return 0;
    80005b44:	4501                	li	a0,0
}
    80005b46:	70a2                	ld	ra,40(sp)
    80005b48:	7402                	ld	s0,32(sp)
    80005b4a:	64e2                	ld	s1,24(sp)
    80005b4c:	6942                	ld	s2,16(sp)
    80005b4e:	6145                	addi	sp,sp,48
    80005b50:	8082                	ret

0000000080005b52 <sys_unlink>:

uint64
sys_unlink(void)
{
    80005b52:	7155                	addi	sp,sp,-208
    80005b54:	e586                	sd	ra,200(sp)
    80005b56:	e1a2                	sd	s0,192(sp)
    80005b58:	fd26                	sd	s1,184(sp)
    80005b5a:	f94a                	sd	s2,176(sp)
    80005b5c:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    80005b5e:	08000613          	li	a2,128
    80005b62:	f4040593          	addi	a1,s0,-192
    80005b66:	4501                	li	a0,0
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	300080e7          	jalr	768(ra) # 80002e68 <argstr>
    80005b70:	16054363          	bltz	a0,80005cd6 <sys_unlink+0x184>
    return -1;

  begin_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	b0a080e7          	jalr	-1270(ra) # 8000467e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005b7c:	fc040593          	addi	a1,s0,-64
    80005b80:	f4040513          	addi	a0,s0,-192
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	5e6080e7          	jalr	1510(ra) # 8000416a <nameiparent>
    80005b8c:	84aa                	mv	s1,a0
    80005b8e:	c961                	beqz	a0,80005c5e <sys_unlink+0x10c>
    end_op();
    return -1;
  }

  ilock(dp);
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	e06080e7          	jalr	-506(ra) # 80003996 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b98:	00003597          	auipc	a1,0x3
    80005b9c:	c2858593          	addi	a1,a1,-984 # 800087c0 <syscalls+0x1f0>
    80005ba0:	fc040513          	addi	a0,s0,-64
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	2bc080e7          	jalr	700(ra) # 80003e60 <namecmp>
    80005bac:	c175                	beqz	a0,80005c90 <sys_unlink+0x13e>
    80005bae:	00003597          	auipc	a1,0x3
    80005bb2:	c1a58593          	addi	a1,a1,-998 # 800087c8 <syscalls+0x1f8>
    80005bb6:	fc040513          	addi	a0,s0,-64
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	2a6080e7          	jalr	678(ra) # 80003e60 <namecmp>
    80005bc2:	c579                	beqz	a0,80005c90 <sys_unlink+0x13e>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80005bc4:	f3c40613          	addi	a2,s0,-196
    80005bc8:	fc040593          	addi	a1,s0,-64
    80005bcc:	8526                	mv	a0,s1
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	2ac080e7          	jalr	684(ra) # 80003e7a <dirlookup>
    80005bd6:	892a                	mv	s2,a0
    80005bd8:	cd45                	beqz	a0,80005c90 <sys_unlink+0x13e>
    goto bad;
  ilock(ip);
    80005bda:	ffffe097          	auipc	ra,0xffffe
    80005bde:	dbc080e7          	jalr	-580(ra) # 80003996 <ilock>

  if(ip->nlink < 1)
    80005be2:	04a91783          	lh	a5,74(s2)
    80005be6:	08f05263          	blez	a5,80005c6a <sys_unlink+0x118>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005bea:	04491703          	lh	a4,68(s2)
    80005bee:	4785                	li	a5,1
    80005bf0:	08f70563          	beq	a4,a5,80005c7a <sys_unlink+0x128>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
    80005bf4:	4641                	li	a2,16
    80005bf6:	4581                	li	a1,0
    80005bf8:	fd040513          	addi	a0,s0,-48
    80005bfc:	ffffb097          	auipc	ra,0xffffb
    80005c00:	0c2080e7          	jalr	194(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c04:	4741                	li	a4,16
    80005c06:	f3c42683          	lw	a3,-196(s0)
    80005c0a:	fd040613          	addi	a2,s0,-48
    80005c0e:	4581                	li	a1,0
    80005c10:	8526                	mv	a0,s1
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	130080e7          	jalr	304(ra) # 80003d42 <writei>
    80005c1a:	47c1                	li	a5,16
    80005c1c:	08f51a63          	bne	a0,a5,80005cb0 <sys_unlink+0x15e>
    panic("unlink: writei");
  if(ip->type == T_DIR){
    80005c20:	04491703          	lh	a4,68(s2)
    80005c24:	4785                	li	a5,1
    80005c26:	08f70d63          	beq	a4,a5,80005cc0 <sys_unlink+0x16e>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	fcc080e7          	jalr	-52(ra) # 80003bf8 <iunlockput>

  ip->nlink--;
    80005c34:	04a95783          	lhu	a5,74(s2)
    80005c38:	37fd                	addiw	a5,a5,-1
    80005c3a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c3e:	854a                	mv	a0,s2
    80005c40:	ffffe097          	auipc	ra,0xffffe
    80005c44:	c8c080e7          	jalr	-884(ra) # 800038cc <iupdate>
  iunlockput(ip);
    80005c48:	854a                	mv	a0,s2
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	fae080e7          	jalr	-82(ra) # 80003bf8 <iunlockput>

  end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	aac080e7          	jalr	-1364(ra) # 800046fe <end_op>

  return 0;
    80005c5a:	4501                	li	a0,0
    80005c5c:	a0a1                	j	80005ca4 <sys_unlink+0x152>
    end_op();
    80005c5e:	fffff097          	auipc	ra,0xfffff
    80005c62:	aa0080e7          	jalr	-1376(ra) # 800046fe <end_op>
    return -1;
    80005c66:	557d                	li	a0,-1
    80005c68:	a835                	j	80005ca4 <sys_unlink+0x152>
    panic("unlink: nlink < 1");
    80005c6a:	00003517          	auipc	a0,0x3
    80005c6e:	b6650513          	addi	a0,a0,-1178 # 800087d0 <syscalls+0x200>
    80005c72:	ffffb097          	auipc	ra,0xffffb
    80005c76:	8b8080e7          	jalr	-1864(ra) # 8000052a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c7a:	854a                	mv	a0,s2
    80005c7c:	00000097          	auipc	ra,0x0
    80005c80:	e6a080e7          	jalr	-406(ra) # 80005ae6 <isdirempty>
    80005c84:	f925                	bnez	a0,80005bf4 <sys_unlink+0xa2>
    iunlockput(ip);
    80005c86:	854a                	mv	a0,s2
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	f70080e7          	jalr	-144(ra) # 80003bf8 <iunlockput>

bad:
  iunlockput(dp);
    80005c90:	8526                	mv	a0,s1
    80005c92:	ffffe097          	auipc	ra,0xffffe
    80005c96:	f66080e7          	jalr	-154(ra) # 80003bf8 <iunlockput>
  end_op();
    80005c9a:	fffff097          	auipc	ra,0xfffff
    80005c9e:	a64080e7          	jalr	-1436(ra) # 800046fe <end_op>
  return -1;
    80005ca2:	557d                	li	a0,-1
}
    80005ca4:	60ae                	ld	ra,200(sp)
    80005ca6:	640e                	ld	s0,192(sp)
    80005ca8:	74ea                	ld	s1,184(sp)
    80005caa:	794a                	ld	s2,176(sp)
    80005cac:	6169                	addi	sp,sp,208
    80005cae:	8082                	ret
    panic("unlink: writei");
    80005cb0:	00003517          	auipc	a0,0x3
    80005cb4:	b3850513          	addi	a0,a0,-1224 # 800087e8 <syscalls+0x218>
    80005cb8:	ffffb097          	auipc	ra,0xffffb
    80005cbc:	872080e7          	jalr	-1934(ra) # 8000052a <panic>
    dp->nlink--;
    80005cc0:	04a4d783          	lhu	a5,74(s1)
    80005cc4:	37fd                	addiw	a5,a5,-1
    80005cc6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005cca:	8526                	mv	a0,s1
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	c00080e7          	jalr	-1024(ra) # 800038cc <iupdate>
    80005cd4:	bf99                	j	80005c2a <sys_unlink+0xd8>
    return -1;
    80005cd6:	557d                	li	a0,-1
    80005cd8:	b7f1                	j	80005ca4 <sys_unlink+0x152>

0000000080005cda <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
    80005cda:	715d                	addi	sp,sp,-80
    80005cdc:	e486                	sd	ra,72(sp)
    80005cde:	e0a2                	sd	s0,64(sp)
    80005ce0:	fc26                	sd	s1,56(sp)
    80005ce2:	f84a                	sd	s2,48(sp)
    80005ce4:	f44e                	sd	s3,40(sp)
    80005ce6:	f052                	sd	s4,32(sp)
    80005ce8:	ec56                	sd	s5,24(sp)
    80005cea:	0880                	addi	s0,sp,80
    80005cec:	89ae                	mv	s3,a1
    80005cee:	8ab2                	mv	s5,a2
    80005cf0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005cf2:	fb040593          	addi	a1,s0,-80
    80005cf6:	ffffe097          	auipc	ra,0xffffe
    80005cfa:	474080e7          	jalr	1140(ra) # 8000416a <nameiparent>
    80005cfe:	892a                	mv	s2,a0
    80005d00:	12050e63          	beqz	a0,80005e3c <create+0x162>
    return 0;

  ilock(dp);
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	c92080e7          	jalr	-878(ra) # 80003996 <ilock>
  
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005d0c:	4601                	li	a2,0
    80005d0e:	fb040593          	addi	a1,s0,-80
    80005d12:	854a                	mv	a0,s2
    80005d14:	ffffe097          	auipc	ra,0xffffe
    80005d18:	166080e7          	jalr	358(ra) # 80003e7a <dirlookup>
    80005d1c:	84aa                	mv	s1,a0
    80005d1e:	c921                	beqz	a0,80005d6e <create+0x94>
    iunlockput(dp);
    80005d20:	854a                	mv	a0,s2
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	ed6080e7          	jalr	-298(ra) # 80003bf8 <iunlockput>
    ilock(ip);
    80005d2a:	8526                	mv	a0,s1
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	c6a080e7          	jalr	-918(ra) # 80003996 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005d34:	2981                	sext.w	s3,s3
    80005d36:	4789                	li	a5,2
    80005d38:	02f99463          	bne	s3,a5,80005d60 <create+0x86>
    80005d3c:	0444d783          	lhu	a5,68(s1)
    80005d40:	37f9                	addiw	a5,a5,-2
    80005d42:	17c2                	slli	a5,a5,0x30
    80005d44:	93c1                	srli	a5,a5,0x30
    80005d46:	4705                	li	a4,1
    80005d48:	00f76c63          	bltu	a4,a5,80005d60 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005d4c:	8526                	mv	a0,s1
    80005d4e:	60a6                	ld	ra,72(sp)
    80005d50:	6406                	ld	s0,64(sp)
    80005d52:	74e2                	ld	s1,56(sp)
    80005d54:	7942                	ld	s2,48(sp)
    80005d56:	79a2                	ld	s3,40(sp)
    80005d58:	7a02                	ld	s4,32(sp)
    80005d5a:	6ae2                	ld	s5,24(sp)
    80005d5c:	6161                	addi	sp,sp,80
    80005d5e:	8082                	ret
    iunlockput(ip);
    80005d60:	8526                	mv	a0,s1
    80005d62:	ffffe097          	auipc	ra,0xffffe
    80005d66:	e96080e7          	jalr	-362(ra) # 80003bf8 <iunlockput>
    return 0;
    80005d6a:	4481                	li	s1,0
    80005d6c:	b7c5                	j	80005d4c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005d6e:	85ce                	mv	a1,s3
    80005d70:	00092503          	lw	a0,0(s2)
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	a8a080e7          	jalr	-1398(ra) # 800037fe <ialloc>
    80005d7c:	84aa                	mv	s1,a0
    80005d7e:	c521                	beqz	a0,80005dc6 <create+0xec>
  ilock(ip);
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	c16080e7          	jalr	-1002(ra) # 80003996 <ilock>
  ip->major = major;
    80005d88:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005d8c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005d90:	4a05                	li	s4,1
    80005d92:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005d96:	8526                	mv	a0,s1
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	b34080e7          	jalr	-1228(ra) # 800038cc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005da0:	2981                	sext.w	s3,s3
    80005da2:	03498a63          	beq	s3,s4,80005dd6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005da6:	40d0                	lw	a2,4(s1)
    80005da8:	fb040593          	addi	a1,s0,-80
    80005dac:	854a                	mv	a0,s2
    80005dae:	ffffe097          	auipc	ra,0xffffe
    80005db2:	2dc080e7          	jalr	732(ra) # 8000408a <dirlink>
    80005db6:	06054b63          	bltz	a0,80005e2c <create+0x152>
  iunlockput(dp);
    80005dba:	854a                	mv	a0,s2
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	e3c080e7          	jalr	-452(ra) # 80003bf8 <iunlockput>
  return ip;
    80005dc4:	b761                	j	80005d4c <create+0x72>
    panic("create: ialloc");
    80005dc6:	00003517          	auipc	a0,0x3
    80005dca:	b3250513          	addi	a0,a0,-1230 # 800088f8 <syscalls+0x328>
    80005dce:	ffffa097          	auipc	ra,0xffffa
    80005dd2:	75c080e7          	jalr	1884(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    80005dd6:	04a95783          	lhu	a5,74(s2)
    80005dda:	2785                	addiw	a5,a5,1
    80005ddc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005de0:	854a                	mv	a0,s2
    80005de2:	ffffe097          	auipc	ra,0xffffe
    80005de6:	aea080e7          	jalr	-1302(ra) # 800038cc <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005dea:	40d0                	lw	a2,4(s1)
    80005dec:	00003597          	auipc	a1,0x3
    80005df0:	9d458593          	addi	a1,a1,-1580 # 800087c0 <syscalls+0x1f0>
    80005df4:	8526                	mv	a0,s1
    80005df6:	ffffe097          	auipc	ra,0xffffe
    80005dfa:	294080e7          	jalr	660(ra) # 8000408a <dirlink>
    80005dfe:	00054f63          	bltz	a0,80005e1c <create+0x142>
    80005e02:	00492603          	lw	a2,4(s2)
    80005e06:	00003597          	auipc	a1,0x3
    80005e0a:	9c258593          	addi	a1,a1,-1598 # 800087c8 <syscalls+0x1f8>
    80005e0e:	8526                	mv	a0,s1
    80005e10:	ffffe097          	auipc	ra,0xffffe
    80005e14:	27a080e7          	jalr	634(ra) # 8000408a <dirlink>
    80005e18:	f80557e3          	bgez	a0,80005da6 <create+0xcc>
      panic("create dots");
    80005e1c:	00003517          	auipc	a0,0x3
    80005e20:	aec50513          	addi	a0,a0,-1300 # 80008908 <syscalls+0x338>
    80005e24:	ffffa097          	auipc	ra,0xffffa
    80005e28:	706080e7          	jalr	1798(ra) # 8000052a <panic>
    panic("create: dirlink");
    80005e2c:	00003517          	auipc	a0,0x3
    80005e30:	aec50513          	addi	a0,a0,-1300 # 80008918 <syscalls+0x348>
    80005e34:	ffffa097          	auipc	ra,0xffffa
    80005e38:	6f6080e7          	jalr	1782(ra) # 8000052a <panic>
    return 0;
    80005e3c:	84aa                	mv	s1,a0
    80005e3e:	b739                	j	80005d4c <create+0x72>

0000000080005e40 <sys_open>:

uint64
sys_open(void)
{
    80005e40:	7131                	addi	sp,sp,-192
    80005e42:	fd06                	sd	ra,184(sp)
    80005e44:	f922                	sd	s0,176(sp)
    80005e46:	f526                	sd	s1,168(sp)
    80005e48:	f14a                	sd	s2,160(sp)
    80005e4a:	ed4e                	sd	s3,152(sp)
    80005e4c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e4e:	08000613          	li	a2,128
    80005e52:	f5040593          	addi	a1,s0,-176
    80005e56:	4501                	li	a0,0
    80005e58:	ffffd097          	auipc	ra,0xffffd
    80005e5c:	010080e7          	jalr	16(ra) # 80002e68 <argstr>
    return -1;
    80005e60:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005e62:	0c054163          	bltz	a0,80005f24 <sys_open+0xe4>
    80005e66:	f4c40593          	addi	a1,s0,-180
    80005e6a:	4505                	li	a0,1
    80005e6c:	ffffd097          	auipc	ra,0xffffd
    80005e70:	fb8080e7          	jalr	-72(ra) # 80002e24 <argint>
    80005e74:	0a054863          	bltz	a0,80005f24 <sys_open+0xe4>

  begin_op();
    80005e78:	fffff097          	auipc	ra,0xfffff
    80005e7c:	806080e7          	jalr	-2042(ra) # 8000467e <begin_op>

  if(omode & O_CREATE){
    80005e80:	f4c42783          	lw	a5,-180(s0)
    80005e84:	2007f793          	andi	a5,a5,512
    80005e88:	cbdd                	beqz	a5,80005f3e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e8a:	4681                	li	a3,0
    80005e8c:	4601                	li	a2,0
    80005e8e:	4589                	li	a1,2
    80005e90:	f5040513          	addi	a0,s0,-176
    80005e94:	00000097          	auipc	ra,0x0
    80005e98:	e46080e7          	jalr	-442(ra) # 80005cda <create>
    80005e9c:	892a                	mv	s2,a0
    if(ip == 0){
    80005e9e:	c959                	beqz	a0,80005f34 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ea0:	04491703          	lh	a4,68(s2)
    80005ea4:	478d                	li	a5,3
    80005ea6:	00f71763          	bne	a4,a5,80005eb4 <sys_open+0x74>
    80005eaa:	04695703          	lhu	a4,70(s2)
    80005eae:	47a5                	li	a5,9
    80005eb0:	0ce7ec63          	bltu	a5,a4,80005f88 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005eb4:	fffff097          	auipc	ra,0xfffff
    80005eb8:	bda080e7          	jalr	-1062(ra) # 80004a8e <filealloc>
    80005ebc:	89aa                	mv	s3,a0
    80005ebe:	10050263          	beqz	a0,80005fc2 <sys_open+0x182>
    80005ec2:	00000097          	auipc	ra,0x0
    80005ec6:	8e2080e7          	jalr	-1822(ra) # 800057a4 <fdalloc>
    80005eca:	84aa                	mv	s1,a0
    80005ecc:	0e054663          	bltz	a0,80005fb8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ed0:	04491703          	lh	a4,68(s2)
    80005ed4:	478d                	li	a5,3
    80005ed6:	0cf70463          	beq	a4,a5,80005f9e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005eda:	4789                	li	a5,2
    80005edc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ee0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ee4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ee8:	f4c42783          	lw	a5,-180(s0)
    80005eec:	0017c713          	xori	a4,a5,1
    80005ef0:	8b05                	andi	a4,a4,1
    80005ef2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ef6:	0037f713          	andi	a4,a5,3
    80005efa:	00e03733          	snez	a4,a4
    80005efe:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f02:	4007f793          	andi	a5,a5,1024
    80005f06:	c791                	beqz	a5,80005f12 <sys_open+0xd2>
    80005f08:	04491703          	lh	a4,68(s2)
    80005f0c:	4789                	li	a5,2
    80005f0e:	08f70f63          	beq	a4,a5,80005fac <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f12:	854a                	mv	a0,s2
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	b44080e7          	jalr	-1212(ra) # 80003a58 <iunlock>
  end_op();
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	7e2080e7          	jalr	2018(ra) # 800046fe <end_op>

  return fd;
}
    80005f24:	8526                	mv	a0,s1
    80005f26:	70ea                	ld	ra,184(sp)
    80005f28:	744a                	ld	s0,176(sp)
    80005f2a:	74aa                	ld	s1,168(sp)
    80005f2c:	790a                	ld	s2,160(sp)
    80005f2e:	69ea                	ld	s3,152(sp)
    80005f30:	6129                	addi	sp,sp,192
    80005f32:	8082                	ret
      end_op();
    80005f34:	ffffe097          	auipc	ra,0xffffe
    80005f38:	7ca080e7          	jalr	1994(ra) # 800046fe <end_op>
      return -1;
    80005f3c:	b7e5                	j	80005f24 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f3e:	f5040513          	addi	a0,s0,-176
    80005f42:	ffffe097          	auipc	ra,0xffffe
    80005f46:	20a080e7          	jalr	522(ra) # 8000414c <namei>
    80005f4a:	892a                	mv	s2,a0
    80005f4c:	c905                	beqz	a0,80005f7c <sys_open+0x13c>
    ilock(ip);
    80005f4e:	ffffe097          	auipc	ra,0xffffe
    80005f52:	a48080e7          	jalr	-1464(ra) # 80003996 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f56:	04491703          	lh	a4,68(s2)
    80005f5a:	4785                	li	a5,1
    80005f5c:	f4f712e3          	bne	a4,a5,80005ea0 <sys_open+0x60>
    80005f60:	f4c42783          	lw	a5,-180(s0)
    80005f64:	dba1                	beqz	a5,80005eb4 <sys_open+0x74>
      iunlockput(ip);
    80005f66:	854a                	mv	a0,s2
    80005f68:	ffffe097          	auipc	ra,0xffffe
    80005f6c:	c90080e7          	jalr	-880(ra) # 80003bf8 <iunlockput>
      end_op();
    80005f70:	ffffe097          	auipc	ra,0xffffe
    80005f74:	78e080e7          	jalr	1934(ra) # 800046fe <end_op>
      return -1;
    80005f78:	54fd                	li	s1,-1
    80005f7a:	b76d                	j	80005f24 <sys_open+0xe4>
      end_op();
    80005f7c:	ffffe097          	auipc	ra,0xffffe
    80005f80:	782080e7          	jalr	1922(ra) # 800046fe <end_op>
      return -1;
    80005f84:	54fd                	li	s1,-1
    80005f86:	bf79                	j	80005f24 <sys_open+0xe4>
    iunlockput(ip);
    80005f88:	854a                	mv	a0,s2
    80005f8a:	ffffe097          	auipc	ra,0xffffe
    80005f8e:	c6e080e7          	jalr	-914(ra) # 80003bf8 <iunlockput>
    end_op();
    80005f92:	ffffe097          	auipc	ra,0xffffe
    80005f96:	76c080e7          	jalr	1900(ra) # 800046fe <end_op>
    return -1;
    80005f9a:	54fd                	li	s1,-1
    80005f9c:	b761                	j	80005f24 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005f9e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fa2:	04691783          	lh	a5,70(s2)
    80005fa6:	02f99223          	sh	a5,36(s3)
    80005faa:	bf2d                	j	80005ee4 <sys_open+0xa4>
    itrunc(ip);
    80005fac:	854a                	mv	a0,s2
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	af6080e7          	jalr	-1290(ra) # 80003aa4 <itrunc>
    80005fb6:	bfb1                	j	80005f12 <sys_open+0xd2>
      fileclose(f);
    80005fb8:	854e                	mv	a0,s3
    80005fba:	fffff097          	auipc	ra,0xfffff
    80005fbe:	b90080e7          	jalr	-1136(ra) # 80004b4a <fileclose>
    iunlockput(ip);
    80005fc2:	854a                	mv	a0,s2
    80005fc4:	ffffe097          	auipc	ra,0xffffe
    80005fc8:	c34080e7          	jalr	-972(ra) # 80003bf8 <iunlockput>
    end_op();
    80005fcc:	ffffe097          	auipc	ra,0xffffe
    80005fd0:	732080e7          	jalr	1842(ra) # 800046fe <end_op>
    return -1;
    80005fd4:	54fd                	li	s1,-1
    80005fd6:	b7b9                	j	80005f24 <sys_open+0xe4>

0000000080005fd8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fd8:	7175                	addi	sp,sp,-144
    80005fda:	e506                	sd	ra,136(sp)
    80005fdc:	e122                	sd	s0,128(sp)
    80005fde:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005fe0:	ffffe097          	auipc	ra,0xffffe
    80005fe4:	69e080e7          	jalr	1694(ra) # 8000467e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005fe8:	08000613          	li	a2,128
    80005fec:	f7040593          	addi	a1,s0,-144
    80005ff0:	4501                	li	a0,0
    80005ff2:	ffffd097          	auipc	ra,0xffffd
    80005ff6:	e76080e7          	jalr	-394(ra) # 80002e68 <argstr>
    80005ffa:	02054963          	bltz	a0,8000602c <sys_mkdir+0x54>
    80005ffe:	4681                	li	a3,0
    80006000:	4601                	li	a2,0
    80006002:	4585                	li	a1,1
    80006004:	f7040513          	addi	a0,s0,-144
    80006008:	00000097          	auipc	ra,0x0
    8000600c:	cd2080e7          	jalr	-814(ra) # 80005cda <create>
    80006010:	cd11                	beqz	a0,8000602c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006012:	ffffe097          	auipc	ra,0xffffe
    80006016:	be6080e7          	jalr	-1050(ra) # 80003bf8 <iunlockput>
  end_op();
    8000601a:	ffffe097          	auipc	ra,0xffffe
    8000601e:	6e4080e7          	jalr	1764(ra) # 800046fe <end_op>
  return 0;
    80006022:	4501                	li	a0,0
}
    80006024:	60aa                	ld	ra,136(sp)
    80006026:	640a                	ld	s0,128(sp)
    80006028:	6149                	addi	sp,sp,144
    8000602a:	8082                	ret
    end_op();
    8000602c:	ffffe097          	auipc	ra,0xffffe
    80006030:	6d2080e7          	jalr	1746(ra) # 800046fe <end_op>
    return -1;
    80006034:	557d                	li	a0,-1
    80006036:	b7fd                	j	80006024 <sys_mkdir+0x4c>

0000000080006038 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006038:	7135                	addi	sp,sp,-160
    8000603a:	ed06                	sd	ra,152(sp)
    8000603c:	e922                	sd	s0,144(sp)
    8000603e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006040:	ffffe097          	auipc	ra,0xffffe
    80006044:	63e080e7          	jalr	1598(ra) # 8000467e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006048:	08000613          	li	a2,128
    8000604c:	f7040593          	addi	a1,s0,-144
    80006050:	4501                	li	a0,0
    80006052:	ffffd097          	auipc	ra,0xffffd
    80006056:	e16080e7          	jalr	-490(ra) # 80002e68 <argstr>
    8000605a:	04054a63          	bltz	a0,800060ae <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    8000605e:	f6c40593          	addi	a1,s0,-148
    80006062:	4505                	li	a0,1
    80006064:	ffffd097          	auipc	ra,0xffffd
    80006068:	dc0080e7          	jalr	-576(ra) # 80002e24 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000606c:	04054163          	bltz	a0,800060ae <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006070:	f6840593          	addi	a1,s0,-152
    80006074:	4509                	li	a0,2
    80006076:	ffffd097          	auipc	ra,0xffffd
    8000607a:	dae080e7          	jalr	-594(ra) # 80002e24 <argint>
     argint(1, &major) < 0 ||
    8000607e:	02054863          	bltz	a0,800060ae <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006082:	f6841683          	lh	a3,-152(s0)
    80006086:	f6c41603          	lh	a2,-148(s0)
    8000608a:	458d                	li	a1,3
    8000608c:	f7040513          	addi	a0,s0,-144
    80006090:	00000097          	auipc	ra,0x0
    80006094:	c4a080e7          	jalr	-950(ra) # 80005cda <create>
     argint(2, &minor) < 0 ||
    80006098:	c919                	beqz	a0,800060ae <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000609a:	ffffe097          	auipc	ra,0xffffe
    8000609e:	b5e080e7          	jalr	-1186(ra) # 80003bf8 <iunlockput>
  end_op();
    800060a2:	ffffe097          	auipc	ra,0xffffe
    800060a6:	65c080e7          	jalr	1628(ra) # 800046fe <end_op>
  return 0;
    800060aa:	4501                	li	a0,0
    800060ac:	a031                	j	800060b8 <sys_mknod+0x80>
    end_op();
    800060ae:	ffffe097          	auipc	ra,0xffffe
    800060b2:	650080e7          	jalr	1616(ra) # 800046fe <end_op>
    return -1;
    800060b6:	557d                	li	a0,-1
}
    800060b8:	60ea                	ld	ra,152(sp)
    800060ba:	644a                	ld	s0,144(sp)
    800060bc:	610d                	addi	sp,sp,160
    800060be:	8082                	ret

00000000800060c0 <sys_chdir>:

uint64
sys_chdir(void)
{
    800060c0:	7135                	addi	sp,sp,-160
    800060c2:	ed06                	sd	ra,152(sp)
    800060c4:	e922                	sd	s0,144(sp)
    800060c6:	e526                	sd	s1,136(sp)
    800060c8:	e14a                	sd	s2,128(sp)
    800060ca:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060cc:	ffffc097          	auipc	ra,0xffffc
    800060d0:	8ce080e7          	jalr	-1842(ra) # 8000199a <myproc>
    800060d4:	892a                	mv	s2,a0
  
  begin_op();
    800060d6:	ffffe097          	auipc	ra,0xffffe
    800060da:	5a8080e7          	jalr	1448(ra) # 8000467e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060de:	08000613          	li	a2,128
    800060e2:	f6040593          	addi	a1,s0,-160
    800060e6:	4501                	li	a0,0
    800060e8:	ffffd097          	auipc	ra,0xffffd
    800060ec:	d80080e7          	jalr	-640(ra) # 80002e68 <argstr>
    800060f0:	04054b63          	bltz	a0,80006146 <sys_chdir+0x86>
    800060f4:	f6040513          	addi	a0,s0,-160
    800060f8:	ffffe097          	auipc	ra,0xffffe
    800060fc:	054080e7          	jalr	84(ra) # 8000414c <namei>
    80006100:	84aa                	mv	s1,a0
    80006102:	c131                	beqz	a0,80006146 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	892080e7          	jalr	-1902(ra) # 80003996 <ilock>
  if(ip->type != T_DIR){
    8000610c:	04449703          	lh	a4,68(s1)
    80006110:	4785                	li	a5,1
    80006112:	04f71063          	bne	a4,a5,80006152 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006116:	8526                	mv	a0,s1
    80006118:	ffffe097          	auipc	ra,0xffffe
    8000611c:	940080e7          	jalr	-1728(ra) # 80003a58 <iunlock>
  iput(p->cwd);
    80006120:	15093503          	ld	a0,336(s2)
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	a2c080e7          	jalr	-1492(ra) # 80003b50 <iput>
  end_op();
    8000612c:	ffffe097          	auipc	ra,0xffffe
    80006130:	5d2080e7          	jalr	1490(ra) # 800046fe <end_op>
  p->cwd = ip;
    80006134:	14993823          	sd	s1,336(s2)
  return 0;
    80006138:	4501                	li	a0,0
}
    8000613a:	60ea                	ld	ra,152(sp)
    8000613c:	644a                	ld	s0,144(sp)
    8000613e:	64aa                	ld	s1,136(sp)
    80006140:	690a                	ld	s2,128(sp)
    80006142:	610d                	addi	sp,sp,160
    80006144:	8082                	ret
    end_op();
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	5b8080e7          	jalr	1464(ra) # 800046fe <end_op>
    return -1;
    8000614e:	557d                	li	a0,-1
    80006150:	b7ed                	j	8000613a <sys_chdir+0x7a>
    iunlockput(ip);
    80006152:	8526                	mv	a0,s1
    80006154:	ffffe097          	auipc	ra,0xffffe
    80006158:	aa4080e7          	jalr	-1372(ra) # 80003bf8 <iunlockput>
    end_op();
    8000615c:	ffffe097          	auipc	ra,0xffffe
    80006160:	5a2080e7          	jalr	1442(ra) # 800046fe <end_op>
    return -1;
    80006164:	557d                	li	a0,-1
    80006166:	bfd1                	j	8000613a <sys_chdir+0x7a>

0000000080006168 <sys_exec>:

uint64
sys_exec(void)
{
    80006168:	7145                	addi	sp,sp,-464
    8000616a:	e786                	sd	ra,456(sp)
    8000616c:	e3a2                	sd	s0,448(sp)
    8000616e:	ff26                	sd	s1,440(sp)
    80006170:	fb4a                	sd	s2,432(sp)
    80006172:	f74e                	sd	s3,424(sp)
    80006174:	f352                	sd	s4,416(sp)
    80006176:	ef56                	sd	s5,408(sp)
    80006178:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000617a:	08000613          	li	a2,128
    8000617e:	f4040593          	addi	a1,s0,-192
    80006182:	4501                	li	a0,0
    80006184:	ffffd097          	auipc	ra,0xffffd
    80006188:	ce4080e7          	jalr	-796(ra) # 80002e68 <argstr>
    return -1;
    8000618c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    8000618e:	0c054a63          	bltz	a0,80006262 <sys_exec+0xfa>
    80006192:	e3840593          	addi	a1,s0,-456
    80006196:	4505                	li	a0,1
    80006198:	ffffd097          	auipc	ra,0xffffd
    8000619c:	cae080e7          	jalr	-850(ra) # 80002e46 <argaddr>
    800061a0:	0c054163          	bltz	a0,80006262 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800061a4:	10000613          	li	a2,256
    800061a8:	4581                	li	a1,0
    800061aa:	e4040513          	addi	a0,s0,-448
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	b10080e7          	jalr	-1264(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061b6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061ba:	89a6                	mv	s3,s1
    800061bc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061be:	02000a13          	li	s4,32
    800061c2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061c6:	00391793          	slli	a5,s2,0x3
    800061ca:	e3040593          	addi	a1,s0,-464
    800061ce:	e3843503          	ld	a0,-456(s0)
    800061d2:	953e                	add	a0,a0,a5
    800061d4:	ffffd097          	auipc	ra,0xffffd
    800061d8:	bb6080e7          	jalr	-1098(ra) # 80002d8a <fetchaddr>
    800061dc:	02054a63          	bltz	a0,80006210 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    800061e0:	e3043783          	ld	a5,-464(s0)
    800061e4:	c3b9                	beqz	a5,8000622a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061e6:	ffffb097          	auipc	ra,0xffffb
    800061ea:	8ec080e7          	jalr	-1812(ra) # 80000ad2 <kalloc>
    800061ee:	85aa                	mv	a1,a0
    800061f0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061f4:	cd11                	beqz	a0,80006210 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061f6:	6605                	lui	a2,0x1
    800061f8:	e3043503          	ld	a0,-464(s0)
    800061fc:	ffffd097          	auipc	ra,0xffffd
    80006200:	be0080e7          	jalr	-1056(ra) # 80002ddc <fetchstr>
    80006204:	00054663          	bltz	a0,80006210 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006208:	0905                	addi	s2,s2,1
    8000620a:	09a1                	addi	s3,s3,8
    8000620c:	fb491be3          	bne	s2,s4,800061c2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006210:	10048913          	addi	s2,s1,256
    80006214:	6088                	ld	a0,0(s1)
    80006216:	c529                	beqz	a0,80006260 <sys_exec+0xf8>
    kfree(argv[i]);
    80006218:	ffffa097          	auipc	ra,0xffffa
    8000621c:	7be080e7          	jalr	1982(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006220:	04a1                	addi	s1,s1,8
    80006222:	ff2499e3          	bne	s1,s2,80006214 <sys_exec+0xac>
  return -1;
    80006226:	597d                	li	s2,-1
    80006228:	a82d                	j	80006262 <sys_exec+0xfa>
      argv[i] = 0;
    8000622a:	0a8e                	slli	s5,s5,0x3
    8000622c:	fc040793          	addi	a5,s0,-64
    80006230:	9abe                	add	s5,s5,a5
    80006232:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd0e80>
  int ret = exec(path, argv);
    80006236:	e4040593          	addi	a1,s0,-448
    8000623a:	f4040513          	addi	a0,s0,-192
    8000623e:	fffff097          	auipc	ra,0xfffff
    80006242:	154080e7          	jalr	340(ra) # 80005392 <exec>
    80006246:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006248:	10048993          	addi	s3,s1,256
    8000624c:	6088                	ld	a0,0(s1)
    8000624e:	c911                	beqz	a0,80006262 <sys_exec+0xfa>
    kfree(argv[i]);
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	786080e7          	jalr	1926(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006258:	04a1                	addi	s1,s1,8
    8000625a:	ff3499e3          	bne	s1,s3,8000624c <sys_exec+0xe4>
    8000625e:	a011                	j	80006262 <sys_exec+0xfa>
  return -1;
    80006260:	597d                	li	s2,-1
}
    80006262:	854a                	mv	a0,s2
    80006264:	60be                	ld	ra,456(sp)
    80006266:	641e                	ld	s0,448(sp)
    80006268:	74fa                	ld	s1,440(sp)
    8000626a:	795a                	ld	s2,432(sp)
    8000626c:	79ba                	ld	s3,424(sp)
    8000626e:	7a1a                	ld	s4,416(sp)
    80006270:	6afa                	ld	s5,408(sp)
    80006272:	6179                	addi	sp,sp,464
    80006274:	8082                	ret

0000000080006276 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006276:	7139                	addi	sp,sp,-64
    80006278:	fc06                	sd	ra,56(sp)
    8000627a:	f822                	sd	s0,48(sp)
    8000627c:	f426                	sd	s1,40(sp)
    8000627e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006280:	ffffb097          	auipc	ra,0xffffb
    80006284:	71a080e7          	jalr	1818(ra) # 8000199a <myproc>
    80006288:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000628a:	fd840593          	addi	a1,s0,-40
    8000628e:	4501                	li	a0,0
    80006290:	ffffd097          	auipc	ra,0xffffd
    80006294:	bb6080e7          	jalr	-1098(ra) # 80002e46 <argaddr>
    return -1;
    80006298:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000629a:	0e054063          	bltz	a0,8000637a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000629e:	fc840593          	addi	a1,s0,-56
    800062a2:	fd040513          	addi	a0,s0,-48
    800062a6:	fffff097          	auipc	ra,0xfffff
    800062aa:	dca080e7          	jalr	-566(ra) # 80005070 <pipealloc>
    return -1;
    800062ae:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062b0:	0c054563          	bltz	a0,8000637a <sys_pipe+0x104>
  fd0 = -1;
    800062b4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062b8:	fd043503          	ld	a0,-48(s0)
    800062bc:	fffff097          	auipc	ra,0xfffff
    800062c0:	4e8080e7          	jalr	1256(ra) # 800057a4 <fdalloc>
    800062c4:	fca42223          	sw	a0,-60(s0)
    800062c8:	08054c63          	bltz	a0,80006360 <sys_pipe+0xea>
    800062cc:	fc843503          	ld	a0,-56(s0)
    800062d0:	fffff097          	auipc	ra,0xfffff
    800062d4:	4d4080e7          	jalr	1236(ra) # 800057a4 <fdalloc>
    800062d8:	fca42023          	sw	a0,-64(s0)
    800062dc:	06054863          	bltz	a0,8000634c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062e0:	4691                	li	a3,4
    800062e2:	fc440613          	addi	a2,s0,-60
    800062e6:	fd843583          	ld	a1,-40(s0)
    800062ea:	68a8                	ld	a0,80(s1)
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	368080e7          	jalr	872(ra) # 80001654 <copyout>
    800062f4:	02054063          	bltz	a0,80006314 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062f8:	4691                	li	a3,4
    800062fa:	fc040613          	addi	a2,s0,-64
    800062fe:	fd843583          	ld	a1,-40(s0)
    80006302:	0591                	addi	a1,a1,4
    80006304:	68a8                	ld	a0,80(s1)
    80006306:	ffffb097          	auipc	ra,0xffffb
    8000630a:	34e080e7          	jalr	846(ra) # 80001654 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000630e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006310:	06055563          	bgez	a0,8000637a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006314:	fc442783          	lw	a5,-60(s0)
    80006318:	07e9                	addi	a5,a5,26
    8000631a:	078e                	slli	a5,a5,0x3
    8000631c:	97a6                	add	a5,a5,s1
    8000631e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006322:	fc042503          	lw	a0,-64(s0)
    80006326:	0569                	addi	a0,a0,26
    80006328:	050e                	slli	a0,a0,0x3
    8000632a:	9526                	add	a0,a0,s1
    8000632c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006330:	fd043503          	ld	a0,-48(s0)
    80006334:	fffff097          	auipc	ra,0xfffff
    80006338:	816080e7          	jalr	-2026(ra) # 80004b4a <fileclose>
    fileclose(wf);
    8000633c:	fc843503          	ld	a0,-56(s0)
    80006340:	fffff097          	auipc	ra,0xfffff
    80006344:	80a080e7          	jalr	-2038(ra) # 80004b4a <fileclose>
    return -1;
    80006348:	57fd                	li	a5,-1
    8000634a:	a805                	j	8000637a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000634c:	fc442783          	lw	a5,-60(s0)
    80006350:	0007c863          	bltz	a5,80006360 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006354:	01a78513          	addi	a0,a5,26
    80006358:	050e                	slli	a0,a0,0x3
    8000635a:	9526                	add	a0,a0,s1
    8000635c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006360:	fd043503          	ld	a0,-48(s0)
    80006364:	ffffe097          	auipc	ra,0xffffe
    80006368:	7e6080e7          	jalr	2022(ra) # 80004b4a <fileclose>
    fileclose(wf);
    8000636c:	fc843503          	ld	a0,-56(s0)
    80006370:	ffffe097          	auipc	ra,0xffffe
    80006374:	7da080e7          	jalr	2010(ra) # 80004b4a <fileclose>
    return -1;
    80006378:	57fd                	li	a5,-1
}
    8000637a:	853e                	mv	a0,a5
    8000637c:	70e2                	ld	ra,56(sp)
    8000637e:	7442                	ld	s0,48(sp)
    80006380:	74a2                	ld	s1,40(sp)
    80006382:	6121                	addi	sp,sp,64
    80006384:	8082                	ret
	...

0000000080006390 <kernelvec>:
    80006390:	7111                	addi	sp,sp,-256
    80006392:	e006                	sd	ra,0(sp)
    80006394:	e40a                	sd	sp,8(sp)
    80006396:	e80e                	sd	gp,16(sp)
    80006398:	ec12                	sd	tp,24(sp)
    8000639a:	f016                	sd	t0,32(sp)
    8000639c:	f41a                	sd	t1,40(sp)
    8000639e:	f81e                	sd	t2,48(sp)
    800063a0:	fc22                	sd	s0,56(sp)
    800063a2:	e0a6                	sd	s1,64(sp)
    800063a4:	e4aa                	sd	a0,72(sp)
    800063a6:	e8ae                	sd	a1,80(sp)
    800063a8:	ecb2                	sd	a2,88(sp)
    800063aa:	f0b6                	sd	a3,96(sp)
    800063ac:	f4ba                	sd	a4,104(sp)
    800063ae:	f8be                	sd	a5,112(sp)
    800063b0:	fcc2                	sd	a6,120(sp)
    800063b2:	e146                	sd	a7,128(sp)
    800063b4:	e54a                	sd	s2,136(sp)
    800063b6:	e94e                	sd	s3,144(sp)
    800063b8:	ed52                	sd	s4,152(sp)
    800063ba:	f156                	sd	s5,160(sp)
    800063bc:	f55a                	sd	s6,168(sp)
    800063be:	f95e                	sd	s7,176(sp)
    800063c0:	fd62                	sd	s8,184(sp)
    800063c2:	e1e6                	sd	s9,192(sp)
    800063c4:	e5ea                	sd	s10,200(sp)
    800063c6:	e9ee                	sd	s11,208(sp)
    800063c8:	edf2                	sd	t3,216(sp)
    800063ca:	f1f6                	sd	t4,224(sp)
    800063cc:	f5fa                	sd	t5,232(sp)
    800063ce:	f9fe                	sd	t6,240(sp)
    800063d0:	887fc0ef          	jal	ra,80002c56 <kerneltrap>
    800063d4:	6082                	ld	ra,0(sp)
    800063d6:	6122                	ld	sp,8(sp)
    800063d8:	61c2                	ld	gp,16(sp)
    800063da:	7282                	ld	t0,32(sp)
    800063dc:	7322                	ld	t1,40(sp)
    800063de:	73c2                	ld	t2,48(sp)
    800063e0:	7462                	ld	s0,56(sp)
    800063e2:	6486                	ld	s1,64(sp)
    800063e4:	6526                	ld	a0,72(sp)
    800063e6:	65c6                	ld	a1,80(sp)
    800063e8:	6666                	ld	a2,88(sp)
    800063ea:	7686                	ld	a3,96(sp)
    800063ec:	7726                	ld	a4,104(sp)
    800063ee:	77c6                	ld	a5,112(sp)
    800063f0:	7866                	ld	a6,120(sp)
    800063f2:	688a                	ld	a7,128(sp)
    800063f4:	692a                	ld	s2,136(sp)
    800063f6:	69ca                	ld	s3,144(sp)
    800063f8:	6a6a                	ld	s4,152(sp)
    800063fa:	7a8a                	ld	s5,160(sp)
    800063fc:	7b2a                	ld	s6,168(sp)
    800063fe:	7bca                	ld	s7,176(sp)
    80006400:	7c6a                	ld	s8,184(sp)
    80006402:	6c8e                	ld	s9,192(sp)
    80006404:	6d2e                	ld	s10,200(sp)
    80006406:	6dce                	ld	s11,208(sp)
    80006408:	6e6e                	ld	t3,216(sp)
    8000640a:	7e8e                	ld	t4,224(sp)
    8000640c:	7f2e                	ld	t5,232(sp)
    8000640e:	7fce                	ld	t6,240(sp)
    80006410:	6111                	addi	sp,sp,256
    80006412:	10200073          	sret
    80006416:	00000013          	nop
    8000641a:	00000013          	nop
    8000641e:	0001                	nop

0000000080006420 <timervec>:
    80006420:	34051573          	csrrw	a0,mscratch,a0
    80006424:	e10c                	sd	a1,0(a0)
    80006426:	e510                	sd	a2,8(a0)
    80006428:	e914                	sd	a3,16(a0)
    8000642a:	6d0c                	ld	a1,24(a0)
    8000642c:	7110                	ld	a2,32(a0)
    8000642e:	6194                	ld	a3,0(a1)
    80006430:	96b2                	add	a3,a3,a2
    80006432:	e194                	sd	a3,0(a1)
    80006434:	4589                	li	a1,2
    80006436:	14459073          	csrw	sip,a1
    8000643a:	6914                	ld	a3,16(a0)
    8000643c:	6510                	ld	a2,8(a0)
    8000643e:	610c                	ld	a1,0(a0)
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	30200073          	mret
	...

000000008000644a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000644a:	1141                	addi	sp,sp,-16
    8000644c:	e422                	sd	s0,8(sp)
    8000644e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006450:	0c0007b7          	lui	a5,0xc000
    80006454:	4705                	li	a4,1
    80006456:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006458:	c3d8                	sw	a4,4(a5)
}
    8000645a:	6422                	ld	s0,8(sp)
    8000645c:	0141                	addi	sp,sp,16
    8000645e:	8082                	ret

0000000080006460 <plicinithart>:

void
plicinithart(void)
{
    80006460:	1141                	addi	sp,sp,-16
    80006462:	e406                	sd	ra,8(sp)
    80006464:	e022                	sd	s0,0(sp)
    80006466:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006468:	ffffb097          	auipc	ra,0xffffb
    8000646c:	506080e7          	jalr	1286(ra) # 8000196e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006470:	0085171b          	slliw	a4,a0,0x8
    80006474:	0c0027b7          	lui	a5,0xc002
    80006478:	97ba                	add	a5,a5,a4
    8000647a:	40200713          	li	a4,1026
    8000647e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006482:	00d5151b          	slliw	a0,a0,0xd
    80006486:	0c2017b7          	lui	a5,0xc201
    8000648a:	953e                	add	a0,a0,a5
    8000648c:	00052023          	sw	zero,0(a0)
}
    80006490:	60a2                	ld	ra,8(sp)
    80006492:	6402                	ld	s0,0(sp)
    80006494:	0141                	addi	sp,sp,16
    80006496:	8082                	ret

0000000080006498 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006498:	1141                	addi	sp,sp,-16
    8000649a:	e406                	sd	ra,8(sp)
    8000649c:	e022                	sd	s0,0(sp)
    8000649e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064a0:	ffffb097          	auipc	ra,0xffffb
    800064a4:	4ce080e7          	jalr	1230(ra) # 8000196e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064a8:	00d5179b          	slliw	a5,a0,0xd
    800064ac:	0c201537          	lui	a0,0xc201
    800064b0:	953e                	add	a0,a0,a5
  return irq;
}
    800064b2:	4148                	lw	a0,4(a0)
    800064b4:	60a2                	ld	ra,8(sp)
    800064b6:	6402                	ld	s0,0(sp)
    800064b8:	0141                	addi	sp,sp,16
    800064ba:	8082                	ret

00000000800064bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064bc:	1101                	addi	sp,sp,-32
    800064be:	ec06                	sd	ra,24(sp)
    800064c0:	e822                	sd	s0,16(sp)
    800064c2:	e426                	sd	s1,8(sp)
    800064c4:	1000                	addi	s0,sp,32
    800064c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064c8:	ffffb097          	auipc	ra,0xffffb
    800064cc:	4a6080e7          	jalr	1190(ra) # 8000196e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064d0:	00d5151b          	slliw	a0,a0,0xd
    800064d4:	0c2017b7          	lui	a5,0xc201
    800064d8:	97aa                	add	a5,a5,a0
    800064da:	c3c4                	sw	s1,4(a5)
}
    800064dc:	60e2                	ld	ra,24(sp)
    800064de:	6442                	ld	s0,16(sp)
    800064e0:	64a2                	ld	s1,8(sp)
    800064e2:	6105                	addi	sp,sp,32
    800064e4:	8082                	ret

00000000800064e6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064e6:	1141                	addi	sp,sp,-16
    800064e8:	e406                	sd	ra,8(sp)
    800064ea:	e022                	sd	s0,0(sp)
    800064ec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064ee:	479d                	li	a5,7
    800064f0:	06a7c963          	blt	a5,a0,80006562 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800064f4:	00025797          	auipc	a5,0x25
    800064f8:	b0c78793          	addi	a5,a5,-1268 # 8002b000 <disk>
    800064fc:	00a78733          	add	a4,a5,a0
    80006500:	6789                	lui	a5,0x2
    80006502:	97ba                	add	a5,a5,a4
    80006504:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006508:	e7ad                	bnez	a5,80006572 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000650a:	00451793          	slli	a5,a0,0x4
    8000650e:	00027717          	auipc	a4,0x27
    80006512:	af270713          	addi	a4,a4,-1294 # 8002d000 <disk+0x2000>
    80006516:	6314                	ld	a3,0(a4)
    80006518:	96be                	add	a3,a3,a5
    8000651a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000651e:	6314                	ld	a3,0(a4)
    80006520:	96be                	add	a3,a3,a5
    80006522:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006526:	6314                	ld	a3,0(a4)
    80006528:	96be                	add	a3,a3,a5
    8000652a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000652e:	6318                	ld	a4,0(a4)
    80006530:	97ba                	add	a5,a5,a4
    80006532:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006536:	00025797          	auipc	a5,0x25
    8000653a:	aca78793          	addi	a5,a5,-1334 # 8002b000 <disk>
    8000653e:	97aa                	add	a5,a5,a0
    80006540:	6509                	lui	a0,0x2
    80006542:	953e                	add	a0,a0,a5
    80006544:	4785                	li	a5,1
    80006546:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000654a:	00027517          	auipc	a0,0x27
    8000654e:	ace50513          	addi	a0,a0,-1330 # 8002d018 <disk+0x2018>
    80006552:	ffffc097          	auipc	ra,0xffffc
    80006556:	b5c080e7          	jalr	-1188(ra) # 800020ae <wakeup>
}
    8000655a:	60a2                	ld	ra,8(sp)
    8000655c:	6402                	ld	s0,0(sp)
    8000655e:	0141                	addi	sp,sp,16
    80006560:	8082                	ret
    panic("free_desc 1");
    80006562:	00002517          	auipc	a0,0x2
    80006566:	3c650513          	addi	a0,a0,966 # 80008928 <syscalls+0x358>
    8000656a:	ffffa097          	auipc	ra,0xffffa
    8000656e:	fc0080e7          	jalr	-64(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006572:	00002517          	auipc	a0,0x2
    80006576:	3c650513          	addi	a0,a0,966 # 80008938 <syscalls+0x368>
    8000657a:	ffffa097          	auipc	ra,0xffffa
    8000657e:	fb0080e7          	jalr	-80(ra) # 8000052a <panic>

0000000080006582 <virtio_disk_init>:
{
    80006582:	1101                	addi	sp,sp,-32
    80006584:	ec06                	sd	ra,24(sp)
    80006586:	e822                	sd	s0,16(sp)
    80006588:	e426                	sd	s1,8(sp)
    8000658a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000658c:	00002597          	auipc	a1,0x2
    80006590:	3bc58593          	addi	a1,a1,956 # 80008948 <syscalls+0x378>
    80006594:	00027517          	auipc	a0,0x27
    80006598:	b9450513          	addi	a0,a0,-1132 # 8002d128 <disk+0x2128>
    8000659c:	ffffa097          	auipc	ra,0xffffa
    800065a0:	596080e7          	jalr	1430(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065a4:	100017b7          	lui	a5,0x10001
    800065a8:	4398                	lw	a4,0(a5)
    800065aa:	2701                	sext.w	a4,a4
    800065ac:	747277b7          	lui	a5,0x74727
    800065b0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065b4:	0ef71163          	bne	a4,a5,80006696 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800065b8:	100017b7          	lui	a5,0x10001
    800065bc:	43dc                	lw	a5,4(a5)
    800065be:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065c0:	4705                	li	a4,1
    800065c2:	0ce79a63          	bne	a5,a4,80006696 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065c6:	100017b7          	lui	a5,0x10001
    800065ca:	479c                	lw	a5,8(a5)
    800065cc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800065ce:	4709                	li	a4,2
    800065d0:	0ce79363          	bne	a5,a4,80006696 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065d4:	100017b7          	lui	a5,0x10001
    800065d8:	47d8                	lw	a4,12(a5)
    800065da:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065dc:	554d47b7          	lui	a5,0x554d4
    800065e0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065e4:	0af71963          	bne	a4,a5,80006696 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065e8:	100017b7          	lui	a5,0x10001
    800065ec:	4705                	li	a4,1
    800065ee:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065f0:	470d                	li	a4,3
    800065f2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065f4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065f6:	c7ffe737          	lui	a4,0xc7ffe
    800065fa:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd075f>
    800065fe:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006600:	2701                	sext.w	a4,a4
    80006602:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006604:	472d                	li	a4,11
    80006606:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006608:	473d                	li	a4,15
    8000660a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000660c:	6705                	lui	a4,0x1
    8000660e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006610:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006614:	5bdc                	lw	a5,52(a5)
    80006616:	2781                	sext.w	a5,a5
  if(max == 0)
    80006618:	c7d9                	beqz	a5,800066a6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000661a:	471d                	li	a4,7
    8000661c:	08f77d63          	bgeu	a4,a5,800066b6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006620:	100014b7          	lui	s1,0x10001
    80006624:	47a1                	li	a5,8
    80006626:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006628:	6609                	lui	a2,0x2
    8000662a:	4581                	li	a1,0
    8000662c:	00025517          	auipc	a0,0x25
    80006630:	9d450513          	addi	a0,a0,-1580 # 8002b000 <disk>
    80006634:	ffffa097          	auipc	ra,0xffffa
    80006638:	68a080e7          	jalr	1674(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000663c:	00025717          	auipc	a4,0x25
    80006640:	9c470713          	addi	a4,a4,-1596 # 8002b000 <disk>
    80006644:	00c75793          	srli	a5,a4,0xc
    80006648:	2781                	sext.w	a5,a5
    8000664a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000664c:	00027797          	auipc	a5,0x27
    80006650:	9b478793          	addi	a5,a5,-1612 # 8002d000 <disk+0x2000>
    80006654:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006656:	00025717          	auipc	a4,0x25
    8000665a:	a2a70713          	addi	a4,a4,-1494 # 8002b080 <disk+0x80>
    8000665e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006660:	00026717          	auipc	a4,0x26
    80006664:	9a070713          	addi	a4,a4,-1632 # 8002c000 <disk+0x1000>
    80006668:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000666a:	4705                	li	a4,1
    8000666c:	00e78c23          	sb	a4,24(a5)
    80006670:	00e78ca3          	sb	a4,25(a5)
    80006674:	00e78d23          	sb	a4,26(a5)
    80006678:	00e78da3          	sb	a4,27(a5)
    8000667c:	00e78e23          	sb	a4,28(a5)
    80006680:	00e78ea3          	sb	a4,29(a5)
    80006684:	00e78f23          	sb	a4,30(a5)
    80006688:	00e78fa3          	sb	a4,31(a5)
}
    8000668c:	60e2                	ld	ra,24(sp)
    8000668e:	6442                	ld	s0,16(sp)
    80006690:	64a2                	ld	s1,8(sp)
    80006692:	6105                	addi	sp,sp,32
    80006694:	8082                	ret
    panic("could not find virtio disk");
    80006696:	00002517          	auipc	a0,0x2
    8000669a:	2c250513          	addi	a0,a0,706 # 80008958 <syscalls+0x388>
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	e8c080e7          	jalr	-372(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    800066a6:	00002517          	auipc	a0,0x2
    800066aa:	2d250513          	addi	a0,a0,722 # 80008978 <syscalls+0x3a8>
    800066ae:	ffffa097          	auipc	ra,0xffffa
    800066b2:	e7c080e7          	jalr	-388(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    800066b6:	00002517          	auipc	a0,0x2
    800066ba:	2e250513          	addi	a0,a0,738 # 80008998 <syscalls+0x3c8>
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	e6c080e7          	jalr	-404(ra) # 8000052a <panic>

00000000800066c6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800066c6:	7119                	addi	sp,sp,-128
    800066c8:	fc86                	sd	ra,120(sp)
    800066ca:	f8a2                	sd	s0,112(sp)
    800066cc:	f4a6                	sd	s1,104(sp)
    800066ce:	f0ca                	sd	s2,96(sp)
    800066d0:	ecce                	sd	s3,88(sp)
    800066d2:	e8d2                	sd	s4,80(sp)
    800066d4:	e4d6                	sd	s5,72(sp)
    800066d6:	e0da                	sd	s6,64(sp)
    800066d8:	fc5e                	sd	s7,56(sp)
    800066da:	f862                	sd	s8,48(sp)
    800066dc:	f466                	sd	s9,40(sp)
    800066de:	f06a                	sd	s10,32(sp)
    800066e0:	ec6e                	sd	s11,24(sp)
    800066e2:	0100                	addi	s0,sp,128
    800066e4:	8aaa                	mv	s5,a0
    800066e6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800066e8:	00c52c83          	lw	s9,12(a0)
    800066ec:	001c9c9b          	slliw	s9,s9,0x1
    800066f0:	1c82                	slli	s9,s9,0x20
    800066f2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800066f6:	00027517          	auipc	a0,0x27
    800066fa:	a3250513          	addi	a0,a0,-1486 # 8002d128 <disk+0x2128>
    800066fe:	ffffa097          	auipc	ra,0xffffa
    80006702:	4c4080e7          	jalr	1220(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    80006706:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006708:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000670a:	00025c17          	auipc	s8,0x25
    8000670e:	8f6c0c13          	addi	s8,s8,-1802 # 8002b000 <disk>
    80006712:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006714:	4b0d                	li	s6,3
    80006716:	a0ad                	j	80006780 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006718:	00fc0733          	add	a4,s8,a5
    8000671c:	975e                	add	a4,a4,s7
    8000671e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006722:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006724:	0207c563          	bltz	a5,8000674e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006728:	2905                	addiw	s2,s2,1
    8000672a:	0611                	addi	a2,a2,4
    8000672c:	19690d63          	beq	s2,s6,800068c6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006730:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006732:	00027717          	auipc	a4,0x27
    80006736:	8e670713          	addi	a4,a4,-1818 # 8002d018 <disk+0x2018>
    8000673a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000673c:	00074683          	lbu	a3,0(a4)
    80006740:	fee1                	bnez	a3,80006718 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006742:	2785                	addiw	a5,a5,1
    80006744:	0705                	addi	a4,a4,1
    80006746:	fe979be3          	bne	a5,s1,8000673c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000674a:	57fd                	li	a5,-1
    8000674c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000674e:	01205d63          	blez	s2,80006768 <virtio_disk_rw+0xa2>
    80006752:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006754:	000a2503          	lw	a0,0(s4)
    80006758:	00000097          	auipc	ra,0x0
    8000675c:	d8e080e7          	jalr	-626(ra) # 800064e6 <free_desc>
      for(int j = 0; j < i; j++)
    80006760:	2d85                	addiw	s11,s11,1
    80006762:	0a11                	addi	s4,s4,4
    80006764:	ffb918e3          	bne	s2,s11,80006754 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006768:	00027597          	auipc	a1,0x27
    8000676c:	9c058593          	addi	a1,a1,-1600 # 8002d128 <disk+0x2128>
    80006770:	00027517          	auipc	a0,0x27
    80006774:	8a850513          	addi	a0,a0,-1880 # 8002d018 <disk+0x2018>
    80006778:	ffffb097          	auipc	ra,0xffffb
    8000677c:	7aa080e7          	jalr	1962(ra) # 80001f22 <sleep>
  for(int i = 0; i < 3; i++){
    80006780:	f8040a13          	addi	s4,s0,-128
{
    80006784:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006786:	894e                	mv	s2,s3
    80006788:	b765                	j	80006730 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000678a:	00027697          	auipc	a3,0x27
    8000678e:	8766b683          	ld	a3,-1930(a3) # 8002d000 <disk+0x2000>
    80006792:	96ba                	add	a3,a3,a4
    80006794:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006798:	00025817          	auipc	a6,0x25
    8000679c:	86880813          	addi	a6,a6,-1944 # 8002b000 <disk>
    800067a0:	00027697          	auipc	a3,0x27
    800067a4:	86068693          	addi	a3,a3,-1952 # 8002d000 <disk+0x2000>
    800067a8:	6290                	ld	a2,0(a3)
    800067aa:	963a                	add	a2,a2,a4
    800067ac:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800067b0:	0015e593          	ori	a1,a1,1
    800067b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800067b8:	f8842603          	lw	a2,-120(s0)
    800067bc:	628c                	ld	a1,0(a3)
    800067be:	972e                	add	a4,a4,a1
    800067c0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067c4:	20050593          	addi	a1,a0,512
    800067c8:	0592                	slli	a1,a1,0x4
    800067ca:	95c2                	add	a1,a1,a6
    800067cc:	577d                	li	a4,-1
    800067ce:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067d2:	00461713          	slli	a4,a2,0x4
    800067d6:	6290                	ld	a2,0(a3)
    800067d8:	963a                	add	a2,a2,a4
    800067da:	03078793          	addi	a5,a5,48
    800067de:	97c2                	add	a5,a5,a6
    800067e0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800067e2:	629c                	ld	a5,0(a3)
    800067e4:	97ba                	add	a5,a5,a4
    800067e6:	4605                	li	a2,1
    800067e8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800067ea:	629c                	ld	a5,0(a3)
    800067ec:	97ba                	add	a5,a5,a4
    800067ee:	4809                	li	a6,2
    800067f0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800067f4:	629c                	ld	a5,0(a3)
    800067f6:	973e                	add	a4,a4,a5
    800067f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800067fc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006800:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006804:	6698                	ld	a4,8(a3)
    80006806:	00275783          	lhu	a5,2(a4)
    8000680a:	8b9d                	andi	a5,a5,7
    8000680c:	0786                	slli	a5,a5,0x1
    8000680e:	97ba                	add	a5,a5,a4
    80006810:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006814:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006818:	6698                	ld	a4,8(a3)
    8000681a:	00275783          	lhu	a5,2(a4)
    8000681e:	2785                	addiw	a5,a5,1
    80006820:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006824:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006828:	100017b7          	lui	a5,0x10001
    8000682c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006830:	004aa783          	lw	a5,4(s5)
    80006834:	02c79163          	bne	a5,a2,80006856 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006838:	00027917          	auipc	s2,0x27
    8000683c:	8f090913          	addi	s2,s2,-1808 # 8002d128 <disk+0x2128>
  while(b->disk == 1) {
    80006840:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006842:	85ca                	mv	a1,s2
    80006844:	8556                	mv	a0,s5
    80006846:	ffffb097          	auipc	ra,0xffffb
    8000684a:	6dc080e7          	jalr	1756(ra) # 80001f22 <sleep>
  while(b->disk == 1) {
    8000684e:	004aa783          	lw	a5,4(s5)
    80006852:	fe9788e3          	beq	a5,s1,80006842 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006856:	f8042903          	lw	s2,-128(s0)
    8000685a:	20090793          	addi	a5,s2,512
    8000685e:	00479713          	slli	a4,a5,0x4
    80006862:	00024797          	auipc	a5,0x24
    80006866:	79e78793          	addi	a5,a5,1950 # 8002b000 <disk>
    8000686a:	97ba                	add	a5,a5,a4
    8000686c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006870:	00026997          	auipc	s3,0x26
    80006874:	79098993          	addi	s3,s3,1936 # 8002d000 <disk+0x2000>
    80006878:	00491713          	slli	a4,s2,0x4
    8000687c:	0009b783          	ld	a5,0(s3)
    80006880:	97ba                	add	a5,a5,a4
    80006882:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006886:	854a                	mv	a0,s2
    80006888:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000688c:	00000097          	auipc	ra,0x0
    80006890:	c5a080e7          	jalr	-934(ra) # 800064e6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006894:	8885                	andi	s1,s1,1
    80006896:	f0ed                	bnez	s1,80006878 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006898:	00027517          	auipc	a0,0x27
    8000689c:	89050513          	addi	a0,a0,-1904 # 8002d128 <disk+0x2128>
    800068a0:	ffffa097          	auipc	ra,0xffffa
    800068a4:	3d6080e7          	jalr	982(ra) # 80000c76 <release>
}
    800068a8:	70e6                	ld	ra,120(sp)
    800068aa:	7446                	ld	s0,112(sp)
    800068ac:	74a6                	ld	s1,104(sp)
    800068ae:	7906                	ld	s2,96(sp)
    800068b0:	69e6                	ld	s3,88(sp)
    800068b2:	6a46                	ld	s4,80(sp)
    800068b4:	6aa6                	ld	s5,72(sp)
    800068b6:	6b06                	ld	s6,64(sp)
    800068b8:	7be2                	ld	s7,56(sp)
    800068ba:	7c42                	ld	s8,48(sp)
    800068bc:	7ca2                	ld	s9,40(sp)
    800068be:	7d02                	ld	s10,32(sp)
    800068c0:	6de2                	ld	s11,24(sp)
    800068c2:	6109                	addi	sp,sp,128
    800068c4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068c6:	f8042503          	lw	a0,-128(s0)
    800068ca:	20050793          	addi	a5,a0,512
    800068ce:	0792                	slli	a5,a5,0x4
  if(write)
    800068d0:	00024817          	auipc	a6,0x24
    800068d4:	73080813          	addi	a6,a6,1840 # 8002b000 <disk>
    800068d8:	00f80733          	add	a4,a6,a5
    800068dc:	01a036b3          	snez	a3,s10
    800068e0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800068e4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800068e8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800068ec:	7679                	lui	a2,0xffffe
    800068ee:	963e                	add	a2,a2,a5
    800068f0:	00026697          	auipc	a3,0x26
    800068f4:	71068693          	addi	a3,a3,1808 # 8002d000 <disk+0x2000>
    800068f8:	6298                	ld	a4,0(a3)
    800068fa:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068fc:	0a878593          	addi	a1,a5,168
    80006900:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006902:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006904:	6298                	ld	a4,0(a3)
    80006906:	9732                	add	a4,a4,a2
    80006908:	45c1                	li	a1,16
    8000690a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000690c:	6298                	ld	a4,0(a3)
    8000690e:	9732                	add	a4,a4,a2
    80006910:	4585                	li	a1,1
    80006912:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006916:	f8442703          	lw	a4,-124(s0)
    8000691a:	628c                	ld	a1,0(a3)
    8000691c:	962e                	add	a2,a2,a1
    8000691e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd000e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006922:	0712                	slli	a4,a4,0x4
    80006924:	6290                	ld	a2,0(a3)
    80006926:	963a                	add	a2,a2,a4
    80006928:	058a8593          	addi	a1,s5,88
    8000692c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000692e:	6294                	ld	a3,0(a3)
    80006930:	96ba                	add	a3,a3,a4
    80006932:	40000613          	li	a2,1024
    80006936:	c690                	sw	a2,8(a3)
  if(write)
    80006938:	e40d19e3          	bnez	s10,8000678a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000693c:	00026697          	auipc	a3,0x26
    80006940:	6c46b683          	ld	a3,1732(a3) # 8002d000 <disk+0x2000>
    80006944:	96ba                	add	a3,a3,a4
    80006946:	4609                	li	a2,2
    80006948:	00c69623          	sh	a2,12(a3)
    8000694c:	b5b1                	j	80006798 <virtio_disk_rw+0xd2>

000000008000694e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000694e:	1101                	addi	sp,sp,-32
    80006950:	ec06                	sd	ra,24(sp)
    80006952:	e822                	sd	s0,16(sp)
    80006954:	e426                	sd	s1,8(sp)
    80006956:	e04a                	sd	s2,0(sp)
    80006958:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000695a:	00026517          	auipc	a0,0x26
    8000695e:	7ce50513          	addi	a0,a0,1998 # 8002d128 <disk+0x2128>
    80006962:	ffffa097          	auipc	ra,0xffffa
    80006966:	260080e7          	jalr	608(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000696a:	10001737          	lui	a4,0x10001
    8000696e:	533c                	lw	a5,96(a4)
    80006970:	8b8d                	andi	a5,a5,3
    80006972:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006974:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006978:	00026797          	auipc	a5,0x26
    8000697c:	68878793          	addi	a5,a5,1672 # 8002d000 <disk+0x2000>
    80006980:	6b94                	ld	a3,16(a5)
    80006982:	0207d703          	lhu	a4,32(a5)
    80006986:	0026d783          	lhu	a5,2(a3)
    8000698a:	06f70163          	beq	a4,a5,800069ec <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000698e:	00024917          	auipc	s2,0x24
    80006992:	67290913          	addi	s2,s2,1650 # 8002b000 <disk>
    80006996:	00026497          	auipc	s1,0x26
    8000699a:	66a48493          	addi	s1,s1,1642 # 8002d000 <disk+0x2000>
    __sync_synchronize();
    8000699e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069a2:	6898                	ld	a4,16(s1)
    800069a4:	0204d783          	lhu	a5,32(s1)
    800069a8:	8b9d                	andi	a5,a5,7
    800069aa:	078e                	slli	a5,a5,0x3
    800069ac:	97ba                	add	a5,a5,a4
    800069ae:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069b0:	20078713          	addi	a4,a5,512
    800069b4:	0712                	slli	a4,a4,0x4
    800069b6:	974a                	add	a4,a4,s2
    800069b8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800069bc:	e731                	bnez	a4,80006a08 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069be:	20078793          	addi	a5,a5,512
    800069c2:	0792                	slli	a5,a5,0x4
    800069c4:	97ca                	add	a5,a5,s2
    800069c6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800069c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800069cc:	ffffb097          	auipc	ra,0xffffb
    800069d0:	6e2080e7          	jalr	1762(ra) # 800020ae <wakeup>

    disk.used_idx += 1;
    800069d4:	0204d783          	lhu	a5,32(s1)
    800069d8:	2785                	addiw	a5,a5,1
    800069da:	17c2                	slli	a5,a5,0x30
    800069dc:	93c1                	srli	a5,a5,0x30
    800069de:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800069e2:	6898                	ld	a4,16(s1)
    800069e4:	00275703          	lhu	a4,2(a4)
    800069e8:	faf71be3          	bne	a4,a5,8000699e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800069ec:	00026517          	auipc	a0,0x26
    800069f0:	73c50513          	addi	a0,a0,1852 # 8002d128 <disk+0x2128>
    800069f4:	ffffa097          	auipc	ra,0xffffa
    800069f8:	282080e7          	jalr	642(ra) # 80000c76 <release>
}
    800069fc:	60e2                	ld	ra,24(sp)
    800069fe:	6442                	ld	s0,16(sp)
    80006a00:	64a2                	ld	s1,8(sp)
    80006a02:	6902                	ld	s2,0(sp)
    80006a04:	6105                	addi	sp,sp,32
    80006a06:	8082                	ret
      panic("virtio_disk_intr status");
    80006a08:	00002517          	auipc	a0,0x2
    80006a0c:	fb050513          	addi	a0,a0,-80 # 800089b8 <syscalls+0x3e8>
    80006a10:	ffffa097          	auipc	ra,0xffffa
    80006a14:	b1a080e7          	jalr	-1254(ra) # 8000052a <panic>
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
