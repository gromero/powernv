/* Head in asm to call 'main' function in uart.c */

#define STACK_TOP 0x60000
#define LOAD_IMM64(r, e)                        \
        lis     r,(e)@highest;                  \
        ori     r,r,(e)@higher;                 \
        rldicr  r,r, 32, 31;                    \
        oris    r,r, (e)@h;                     \
        ori     r,r, (e)@l;


.section ".head","ax"
.globl _start
_start:
	. = 0x00
	b 0x10
	. = 0x10	  /* QEMU powernv will jump here        */
loop:	or 2,2,2
        li      3, 42
        sldi    6,3,(24+32)
        li      3,0x58
        li      4,0
        li      5,1
        .long   0x44000022
        b loop

	. = 0x100
	b 0x10
