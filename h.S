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
	b 1f
	. = 0x10	  /* QEMU powernv will jump here        */
	b 1f
	. = 0x100
	b 1f
1:
	mr 14, 3 // Save device tree pointer to r14, since r3 will be clobbered on funcs call
        LOAD_IMM64(1, STACK_TOP - 0x100) // Set stack with some room (0x100) since we can spill to the previous (non-existing) frame 
        LOAD_IMM64(3, 0x800) // Move 'main' function pointer to CTR so we can branch w/ LR to it
        mtctr   3
        bctrl // 'b main' doesn't work here because it skips the TOC to r2 in func prologue, hence a 'bctrl'
