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
        tdi   0,0,0x48;   /* Reverse endian of b . + 8          */
        b     1f;         /* Skip trampoline if endian is good  */
        .long 0xa600607d; /* mfmsr r11                          */
        .long 0x01006b69; /* xori r11,r11,1                     */
        .long 0x05009f42; /* bcl 20,31,.+4                      */
        .long 0xa602487d; /* mflr r10                           */
        .long 0x14004a39; /* addi r10,r10,20                    */
        .long 0xa64b5a7d; /* mthsrr0 r10                        */
        .long 0xa64b7b7d; /* mthsrr1 r11                        */
        .long 0x2402004c; /* hrfid                              */

1:
	mr 14, 3 // Save device tree pointer to r14, since r3 will be clobbered on funcs call
        LOAD_IMM64(1, STACK_TOP - 0x100) // Set stack with some room (0x100) since we can spill to the previous (non-existing) frame 
        LOAD_IMM64(3, main) // Move 'main' function pointer to CTR so we can branch w/ LR to it
        mtctr   3
        bctrl // 'b main' doesn't work here because it skips the TOC to r2 in func prologue, hence a 'bctrl'
