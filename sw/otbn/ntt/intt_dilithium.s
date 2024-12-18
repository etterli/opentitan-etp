/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * from
 * https://github.com/dop-amin/dilithium-on-opentitan-thesis
*/

/**
 * THIS CONTAINS CODE WITH UNSUPPORTED INSTRUCTIONS.
 * IT SERVES AS A REFERENCE ONLY
 */

.text
/* Macros */
.macro push reg
    addi sp, sp, -4     /* Decrement stack pointer by 4 bytes */
    sw \reg, 0(sp)      /* Store register value at the top of the stack */
.endm

.macro pop reg
    lw \reg, 0(sp)     /* Load value from the top of the stack into register */
    addi sp, sp, 4     /* Increment stack pointer by 4 bytes */
.endm

/**
 * Constant Time Dilithium inverse NTT
 *
 * Returns: INTT(input)
 *
 * This implements the in-place INTT for Dilithium, where n=256, q=8380417.
 *
 * Flags: -
 *
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors,
                    last element is n^{-1} mod q
 * @param[in]  w31: all-zero
 * @param[out] x10: dmem pointer to result
 *
 * clobbered registers: x4-x30, w0-w23, w30
 */
.global intt_dilithium
intt_dilithium:

    /* Save callee-saved registers */
    .irp reg,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11
        push \reg
    .endr

    /* Set up constants for input/state */
    li x4, 0
    li x5, 1 
    li x6, 2 
    li x7, 3 
    li x8, 4 
    li x9, 5 
    li x13, 6 
    li x14, 7 
    li x15, 8
    li x16, 9
    li x17, 10
    li x18, 11
    li x19, 12
    li x20, 13
    li x21, 14
    li x22, 15

    /* Set up constants for input/twiddle factors */
    li x23, 16
    li x24, 17
    li x25, 18
    li x26, 19
    li x31, 20
    li x28, 21
    li x29, 22
    li x30, 23

    LOOPI 2, 175
        /* Load input data */
        bn.lid x4, 0(x10)
        bn.lid x5, 32(x10)
        bn.lid x6, 64(x10)
        bn.lid x7, 96(x10)
        bn.lid x8, 128(x10)
        bn.lid x9, 160(x10)
        bn.lid x13, 192(x10)
        bn.lid x14, 224(x10)
        bn.lid x15, 256(x10)
        bn.lid x16, 288(x10)
        bn.lid x17, 320(x10)
        bn.lid x18, 352(x10)
        bn.lid x19, 384(x10)
        bn.lid x20, 416(x10)
        bn.lid x21, 448(x10)
        bn.lid x22, 480(x10)

        /* Transpose */
        /* bn.trans8 w0, w0 */
        bn.trans.8S w24, w0, 0
        bn.trans.8S w24, w1, 1
        bn.trans.8S w24, w2, 2
        bn.trans.8S w24, w3, 3
        bn.trans.8S w24, w4, 4
        bn.trans.8S w24, w5, 5
        bn.trans.8S w24, w6, 6
        bn.trans.8S w24, w7, 7
        
        /* bn.trans8 w8, w8 */
        bn.trans.8S w0, w8, 0
        bn.trans.8S w0, w9, 1
        bn.trans.8S w0, w10, 2
        bn.trans.8S w0, w11, 3
        bn.trans.8S w0, w12, 4
        bn.trans.8S w0, w13, 5
        bn.trans.8S w0, w14, 6
        bn.trans.8S w0, w15, 7

        /* Reverse Layer 8, stride 1 */
        #define wtmp w8
        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)
        bn.lid x25, 0(x11++)
        bn.lid x26, 0(x11++)
        bn.lid x31, 0(x11++)
        bn.lid x28, 0(x11++)
        bn.lid x29, 0(x11++)
        bn.lid x30, 0(x11++)

        /* Butterflies */
        bn.subvm.8S wtmp, w24, w25
        bn.addvm.8S w24, w24, w25
        bn.mulvm.8S w25, wtmp, w16
        bn.subvm.8S wtmp, w26, w27
        bn.addvm.8S w26, w26, w27
        bn.mulvm.8S w27, wtmp, w17
        bn.subvm.8S wtmp, w28, w29
        bn.addvm.8S w28, w28, w29
        bn.mulvm.8S w29, wtmp, w18
        bn.subvm.8S wtmp, w30, w31
        bn.addvm.8S w30, w30, w31
        bn.mulvm.8S w31, wtmp, w19
        bn.subvm.8S wtmp, w0, w1
        bn.addvm.8S w0, w0, w1
        bn.mulvm.8S w1, wtmp, w20
        bn.subvm.8S wtmp, w2, w3
        bn.addvm.8S w2, w2, w3
        bn.mulvm.8S w3, wtmp, w21
        bn.subvm.8S wtmp, w4, w5
        bn.addvm.8S w4, w4, w5
        bn.mulvm.8S w5, wtmp, w22
        bn.subvm.8S wtmp, w6, w7
        bn.addvm.8S w6, w6, w7
        bn.mulvm.8S w7, wtmp, w23

        /* Reverse Layer 7, stride 2 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)
        bn.lid x25, 0(x11++)
        bn.lid x26, 0(x11++)

        /* Butterflies */
        bn.subvm.8S wtmp, w24, w26
        bn.addvm.8S w24, w24, w26
        bn.mulvm.8S w26, wtmp, w16
        bn.subvm.8S wtmp, w25, w27
        bn.addvm.8S w25, w25, w27
        bn.mulvm.8S w27, wtmp, w16
        bn.subvm.8S wtmp, w28, w30
        bn.addvm.8S w28, w28, w30
        bn.mulvm.8S w30, wtmp, w17
        bn.subvm.8S wtmp, w29, w31
        bn.addvm.8S w29, w29, w31
        bn.mulvm.8S w31, wtmp, w17
        bn.subvm.8S wtmp, w0, w2
        bn.addvm.8S w0, w0, w2
        bn.mulvm.8S w2, wtmp, w18
        bn.subvm.8S wtmp, w1, w3
        bn.addvm.8S w1, w1, w3
        bn.mulvm.8S w3, wtmp, w18
        bn.subvm.8S wtmp, w4, w6
        bn.addvm.8S w4, w4, w6
        bn.mulvm.8S w6, wtmp, w19
        bn.subvm.8S wtmp, w5, w7
        bn.addvm.8S w5, w5, w7
        bn.mulvm.8S w7, wtmp, w19

        /* Reverse Layer 6, stride 4 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        bn.lid x24, 0(x11++)

        /* Butterflies */
        bn.subvm.8S wtmp, w24, w28
        bn.addvm.8S w24, w24, w28
        bn.mulvm.8S w28, wtmp, w16
        bn.subvm.8S wtmp, w25, w29
        bn.addvm.8S w25, w25, w29
        bn.mulvm.8S w29, wtmp, w16
        bn.subvm.8S wtmp, w26, w30
        bn.addvm.8S w26, w26, w30
        bn.mulvm.8S w30, wtmp, w16
        bn.subvm.8S wtmp, w27, w31
        bn.addvm.8S w27, w27, w31
        bn.mulvm.8S w31, wtmp, w16
        bn.subvm.8S wtmp, w0, w4
        bn.addvm.8S w0, w0, w4
        bn.mulvm.8S w4, wtmp, w17
        bn.subvm.8S wtmp, w1, w5
        bn.addvm.8S w1, w1, w5
        bn.mulvm.8S w5, wtmp, w17
        bn.subvm.8S wtmp, w2, w6
        bn.addvm.8S w2, w2, w6
        bn.mulvm.8S w6, wtmp, w17
        bn.subvm.8S wtmp, w3, w7
        bn.addvm.8S w3, w3, w7
        bn.mulvm.8S w7, wtmp, w17

        /* Transpose back */
        /* bn.trans8 w0, w0 */
        bn.trans.8S w8, w0, 0
        bn.trans.8S w8, w1, 1
        bn.trans.8S w8, w2, 2
        bn.trans.8S w8, w3, 3
        bn.trans.8S w8, w4, 4
        bn.trans.8S w8, w5, 5
        bn.trans.8S w8, w6, 6
        bn.trans.8S w8, w7, 7
        /* bn.trans8 w24, w24 */
        bn.trans.8S w0, w24, 0
        bn.trans.8S w0, w25, 1
        bn.trans.8S w0, w26, 2
        bn.trans.8S w0, w27, 3
        bn.trans.8S w0, w28, 4
        bn.trans.8S w0, w29, 5
        bn.trans.8S w0, w30, 6
        bn.trans.8S w0, w31, 7

        /* Reverse Layer 5, stride 8 */

        /* Load twiddle factors */
        bn.lid x23, 0(x11++)
        
        /* Butterflies */
        bn.subvm.8S   w30, w0, w1
        bn.addvm.8S   w0, w0, w1
        bn.mulvm.l.8S w1, w30, w16, 0
        bn.subvm.8S   w30, w2, w3
        bn.addvm.8S   w2, w2, w3
        bn.mulvm.l.8S w3, w30, w16, 1
        bn.subvm.8S   w30, w4, w5
        bn.addvm.8S   w4, w4, w5
        bn.mulvm.l.8S w5, w30, w16, 2
        bn.subvm.8S   w30, w6, w7
        bn.addvm.8S   w6, w6, w7
        bn.mulvm.l.8S w7, w30, w16, 3
        bn.subvm.8S   w30, w8, w9
        bn.addvm.8S   w8, w8, w9
        bn.mulvm.l.8S w9, w30, w16, 4
        bn.subvm.8S   w30, w10, w11
        bn.addvm.8S   w10, w10, w11
        bn.mulvm.l.8S w11, w30, w16, 5
        bn.subvm.8S   w30, w12, w13
        bn.addvm.8S   w12, w12, w13
        bn.mulvm.l.8S w13, w30, w16, 6
        bn.subvm.8S   w30, w14, w15
        bn.addvm.8S   w14, w14, w15
        bn.mulvm.l.8S w15, w30, w16, 7

        bn.sid x4, 0(x10++)
        bn.sid x5, 0(x10++)
        bn.sid x6, 0(x10++)
        bn.sid x7, 0(x10++)
        bn.sid x8, 0(x10++)
        bn.sid x9, 0(x10++)
        bn.sid x13,0(x10++)
        bn.sid x14,0(x10++)
        bn.sid x15,0(x10++)
        bn.sid x16,0(x10++)
        bn.sid x17,0(x10++)
        bn.sid x18,0(x10++)
        bn.sid x19,0(x10++)
        bn.sid x20,0(x10++)
        bn.sid x21,0(x10++)
        bn.sid x22,0(x10++)

    /* Restore input pointer */
    addi x10, x10, -1024

    /* Load twiddle factors for layers 1--4 */
    bn.lid x23, 0(x11)
    bn.lid x24, 32(x11)

    LOOPI 2, 136
        /* Load input data */
        bn.lid x4, 0(x10)
        bn.lid x5, 64(x10)
        bn.lid x6, 128(x10)
        bn.lid x7, 192(x10)
        bn.lid x8, 256(x10)
        bn.lid x9, 320(x10)
        bn.lid x13, 384(x10)
        bn.lid x14, 448(x10)
        bn.lid x15, 512(x10)
        bn.lid x16, 576(x10)
        bn.lid x17, 640(x10)
        bn.lid x18, 704(x10)
        bn.lid x19, 768(x10)
        bn.lid x20, 832(x10)
        bn.lid x21, 896(x10)
        bn.lid x22, 960(x10)

        /* Reverse Layer 4, stride 16 */
        bn.subvm.8S   w30, w0, w1
        bn.addvm.8S   w0, w0, w1
        bn.mulvm.l.8S w1, w30, w16, 0
        bn.subvm.8S   w30, w2, w3
        bn.addvm.8S   w2, w2, w3
        bn.mulvm.l.8S w3, w30, w16, 1
        bn.subvm.8S   w30, w4, w5
        bn.addvm.8S   w4, w4, w5
        bn.mulvm.l.8S w5, w30, w16, 2
        bn.subvm.8S   w30, w6, w7
        bn.addvm.8S   w6, w6, w7
        bn.mulvm.l.8S w7, w30, w16, 3
        bn.subvm.8S   w30, w8, w9
        bn.addvm.8S   w8, w8, w9
        bn.mulvm.l.8S w9, w30, w16, 4
        bn.subvm.8S   w30, w10, w11
        bn.addvm.8S   w10, w10, w11
        bn.mulvm.l.8S w11, w30, w16, 5
        bn.subvm.8S   w30, w12, w13
        bn.addvm.8S   w12, w12, w13
        bn.mulvm.l.8S w13, w30, w16, 6
        bn.subvm.8S   w30, w14, w15
        bn.addvm.8S   w14, w14, w15
        bn.mulvm.l.8S w15, w30, w16, 7

        /* Layer 3 */
        bn.subvm.8S   w30, w0, w2
        bn.addvm.8S   w0, w0, w2
        bn.mulvm.l.8S w2, w30, w17, 0
        bn.subvm.8S   w30, w1, w3
        bn.addvm.8S   w1, w1, w3
        bn.mulvm.l.8S w3, w30, w17, 0
        bn.subvm.8S   w30, w4, w6
        bn.addvm.8S   w4, w4, w6
        bn.mulvm.l.8S w6, w30, w17, 1
        bn.subvm.8S   w30, w5, w7
        bn.addvm.8S   w5, w5, w7
        bn.mulvm.l.8S w7, w30, w17, 1
        bn.subvm.8S   w30, w8, w10
        bn.addvm.8S   w8, w8, w10
        bn.mulvm.l.8S w10, w30, w17, 2
        bn.subvm.8S   w30, w9, w11
        bn.addvm.8S   w9, w9, w11
        bn.mulvm.l.8S w11, w30, w17, 2
        bn.subvm.8S   w30, w12, w14
        bn.addvm.8S   w12, w12, w14
        bn.mulvm.l.8S w14, w30, w17, 3
        bn.subvm.8S   w30, w13, w15
        bn.addvm.8S   w13, w13, w15
        bn.mulvm.l.8S w15, w30, w17, 3

        /* Layer 2 */
        bn.subvm.8S   w30, w0, w4
        bn.addvm.8S   w0, w0, w4
        bn.mulvm.l.8S w4, w30, w17, 4
        bn.subvm.8S   w30, w1, w5
        bn.addvm.8S   w1, w1, w5
        bn.mulvm.l.8S w5, w30, w17, 4
        bn.subvm.8S   w30, w2, w6
        bn.addvm.8S   w2, w2, w6
        bn.mulvm.l.8S w6, w30, w17, 4
        bn.subvm.8S   w30, w3, w7
        bn.addvm.8S   w3, w3, w7
        bn.mulvm.l.8S w7, w30, w17, 4
        bn.subvm.8S   w30, w8, w12
        bn.addvm.8S   w8, w8, w12
        bn.mulvm.l.8S w12, w30, w17, 5
        bn.subvm.8S   w30, w9, w13
        bn.addvm.8S   w9, w9, w13
        bn.mulvm.l.8S w13, w30, w17, 5
        bn.subvm.8S   w30, w10, w14
        bn.addvm.8S   w10, w10, w14
        bn.mulvm.l.8S w14, w30, w17, 5
        bn.subvm.8S   w30, w11, w15
        bn.addvm.8S   w11, w11, w15
        bn.mulvm.l.8S w15, w30, w17, 5

        /* Layer 1 */
        bn.subvm.8S   w30, w0, w8
        bn.addvm.8S   w0, w0, w8
        bn.mulvm.l.8S w8, w30, w17, 6
        bn.subvm.8S   w30, w1, w9
        bn.addvm.8S   w1, w1, w9
        bn.mulvm.l.8S w9, w30, w17, 6
        bn.subvm.8S   w30, w2, w10
        bn.addvm.8S   w2, w2, w10
        bn.mulvm.l.8S w10, w30, w17, 6
        bn.subvm.8S   w30, w3, w11
        bn.addvm.8S   w3, w3, w11
        bn.mulvm.l.8S w11, w30, w17, 6
        bn.subvm.8S   w30, w4, w12
        bn.addvm.8S   w4, w4, w12
        bn.mulvm.l.8S w12, w30, w17, 6
        bn.subvm.8S   w30, w5, w13
        bn.addvm.8S   w5, w5, w13
        bn.mulvm.l.8S w13, w30, w17, 6
        bn.subvm.8S   w30, w6, w14
        bn.addvm.8S   w6, w6, w14
        bn.mulvm.l.8S w14, w30, w17, 6
        bn.subvm.8S   w30, w7, w15
        bn.addvm.8S   w7, w7, w15
        bn.mulvm.l.8S w15, w30, w17, 6

        /* Multiply n^{-1} */
        bn.mulvm.l.8S w0, w0, w17, 7
        bn.mulvm.l.8S w1, w1, w17, 7
        bn.mulvm.l.8S w2, w2, w17, 7
        bn.mulvm.l.8S w3, w3, w17, 7
        bn.mulvm.l.8S w4, w4, w17, 7
        bn.mulvm.l.8S w5, w5, w17, 7
        bn.mulvm.l.8S w6, w6, w17, 7
        bn.mulvm.l.8S w7, w7, w17, 7

        /* Store output data */
        bn.sid x4,  0(x10)
        bn.sid x5, 64(x10)
        bn.sid x6, 128(x10)
        bn.sid x7, 192(x10)
        bn.sid x8, 256(x10)
        bn.sid x9, 320(x10)
        bn.sid x13, 384(x10)
        bn.sid x14, 448(x10)
        bn.sid x15, 512(x10)
        bn.sid x16, 576(x10)
        bn.sid x17, 640(x10)
        bn.sid x18, 704(x10)
        bn.sid x19, 768(x10)
        bn.sid x20, 832(x10)
        bn.sid x21, 896(x10)
        bn.sid x22, 960(x10++)
        
    .irp reg,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0
        pop \reg
    .endr

    bn.xor w31, w31, w31
    /* Restore input pointer */
    addi x10, x10, -64
    ret