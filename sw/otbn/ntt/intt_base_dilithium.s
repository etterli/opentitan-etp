/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* x2DX-License-Identifier: Apache-2.0 */

/**
 * intt_base_dilithium. Adapted from
 * https://github.com/dop-amin/dilithium-on-opentitan-thesis
*/

.text

/* Register aliases */
/*.equ x0, zero
.equ x2, sp
.equ x3, fp
*/

/**
 * Constant Time Dilithium inverse NTT (base)
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
.global intt_base_dilithium
intt_base_dilithium:
/* 32 byte align the sp */
    andi x6, x2, 31
    beq  x6, x0, _aligned
    sub  x2, x2, x6
_aligned:
    addi x2, x2, -4      /* Decrement stack pointer by 4 bytes */
    sw   x6, 0(x2)

    addi x2, x2, -28
    /* save fp to stack */
    addi x2, x2, -32
    sw   x3, 0(x2)

    addi x3, x2, 0
    
    /* Adjust sp to accomodate local variables */
    addi x2, x2, -32

    /* Reserve space for tmp buffer to hold a WDR */
    /* #define STACK_WDR2GPR -32 */
    /*
    #define coeff0 w0
    #define coeff1 w1
    #define coeff2 w2
    #define coeff3 w3
    #define coeff4 w4
    #define coeff5 w5
    #define coeff6 w6
    #define coeff7 w7

    #define coeff8 w8
    #define coeff9 w9
    #define coeff10 w10
    #define coeff11 w11
    #define coeff12 w12
    #define coeff13 w13
    #define coeff14 w14
    #define coeff15 w15

    #define buf0 w31
    #define buf1 w30
    #define buf2 w29
    #define buf3 w28
    #define buf4 w27
    #define buf5 w26
    #define buf6 w25
    #define buf7 w24
    */
    /* Twiddle Factors */
    /*
    #define tf1 w16
    #define buf8 w17
    #define buf9 w18
    #define buf10 w19
    */

    /* Other */
    /*
    #define wtmp w20
    #define buf11 w21
    #define wtmp3 w22
    #define buf12 w23
    */

    /* GPRs with indices to access WDRs */
    /*
    #define buf0_idx x4
    #define buf1_idx x5
    #define buf2_idx x6
    #define buf3_idx x7
    #define buf4_idx x8
    #define buf5_idx x9
    #define buf6_idx x13
    #define buf7_idx x14
    #define inp x10
    #define twp x11
    #define outp x12
    #define coeff8_idx x15
    #define coeff9_idx x16
    #define coeff10_idx x17
    #define coeff11_idx x18
    #define coeff12_idx x19
    #define coeff13_idx x20
    #define coeff14_idx x21
    #define coeff15_idx x22
    #define tf1_idx x23
    #define buf8_idx x24
    #define buf9_idx x25
    #define buf10_idx x26
    #define tmp_gpr x27
    #define tmp_gpr2 x28
    #define buf11_idx x29
    #define buf12_idx x30
    */

    /* In place */
    addi x12, x10, 0

    /* Set up constants for input/twiddle factors */
    li x23, 16

    li x15, 8
    li x16, 9
    li x17, 10
    li x18, 11
    li x19, 12
    li x20, 13
    li x21, 14
    li x22, 15

    li x4, 31
    li x5, 30
    li x6, 29
    li x7, 28
    li x8, 27
    li x9, 26
    li x13, 25
    li x14, 24
    li x24, 17
    li x25, 18
    li x26, 19
    li x29, 21
    li x30, 23

    /* Zero out one register */
    bn.xor w18, w18, w18
    /* 0xFFFFFFFF for masking */
    bn.addi w17, w18, 1
    bn.rshi w17, w17, w18 >> 224
    bn.subi w17, w17, 1 

    /* Set second WLEN/4 quad word to modulus */
    la x27, modulus
    li x28, 20 /* Load q to wtmp */
    bn.lid x28, 0(x27)
    bn.and w20, w20, w17
    bn.or w22, w18, w20 << 128
    /* Load alpha to w22.1 */
    bn.addi w20, w18, 256
    bn.or w22, w22, w20 << 64
    /* Load mask to w22.3 */
    bn.or w22, w22, w17 << 192

    bn.xor w18, w18, w18
    bn.addi w17, w18, 1
    bn.rshi w17, w17, w18 >> 224
    bn.subi w17, w17, 1 

    LOOPI 16, 232
        /* Load Data */
        bn.lid x4, 0(x10)
        bn.and  w0, w17, w31 >> 0
        bn.and  w1, w17, w31 >> 32
        bn.and  w2, w17, w31 >> 64
        bn.and  w3, w17, w31 >> 96
        bn.and  w4, w17, w31 >> 128
        bn.and  w5, w17, w31 >> 160
        bn.and  w6, w17, w31 >> 192
        bn.and  w7, w17, w31 >> 224

        bn.lid x4, 32(x10)
        bn.and  w8, w17, w31 >> 0
        bn.and  w9, w17, w31 >> 32
        bn.and  w10, w17, w31 >> 64
        bn.and  w11, w17, w31 >> 96
        bn.and  w12, w17, w31 >> 128
        bn.and  w13, w17, w31 >> 160
        bn.and  w14, w17, w31 >> 192
        bn.and  w15, w17, w31 >> 224

        /* Load layer 8 twiddle 4x */
        bn.lid x23, 0(x11++)

        /* Layer 8, stride 1 */            
        bn.subm w20, w0, w1
        bn.addm w0, w0, w1
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w1, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w2, w3
        bn.addm w2, w2, w3
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w3, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w4, w5
        bn.addm w4, w4, w5
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w5, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w6, w7
        bn.addm w6, w6, w7
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w7, w22, w20 >> 32 /* >> l */
            
        /* Load layer 8 twiddle 4x */
        bn.lid x23, 0(x11++)

        bn.subm w20, w8, w9
        bn.addm w8, w8, w9
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w9, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w10, w11
        bn.addm w10, w10, w11
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w11, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w12, w13
        bn.addm w12, w12, w13
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w13, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w14, w15
        bn.addm w14, w14, w15
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w15, w22, w20 >> 32 /* >> l */

        /* Layer 7, stride 2 */
        /* Load layer 7 4x */
        bn.lid x23, 0(x11++)

        bn.subm w20, w0, w2
        bn.addm w0, w0, w2
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w2, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w1, w3
        bn.addm w1, w1, w3
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w3, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w4, w6
        bn.addm w4, w4, w6
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w6, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w5, w7
        bn.addm w5, w5, w7
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w7, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w8, w10
        bn.addm w8, w8, w10
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w10, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w9, w11
        bn.addm w9, w9, w11
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w11, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w12, w14
        bn.addm w12, w12, w14
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w14, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w13, w15
        bn.addm w13, w13, w15
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w15, w22, w20 >> 32 /* >> l */

        /* Layer 6, stride 4 */
        /* Load layer 6 x2 + layer 5 x1 + pad */
        bn.lid x23, 0(x11++)

        bn.subm w20, w0, w4
        bn.addm w0, w0, w4
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w4, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w1, w5
        bn.addm w1, w1, w5
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w5, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w2, w6
        bn.addm w2, w2, w6
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w6, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w3, w7
        bn.addm w3, w3, w7
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w7, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w8, w12
        bn.addm w8, w8, w12
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w12, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w9, w13
        bn.addm w9, w9, w13
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w13, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w10, w14
        bn.addm w10, w10, w14
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w14, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w11, w15
        bn.addm w11, w11, w15
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w15, w22, w20 >> 32 /* >> l */

        /* Layer 5, stride 8 */         

        bn.subm w20, w0, w8
        bn.addm w0, w0, w8
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w8, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w1, w9
        bn.addm w1, w1, w9
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w9, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w2, w10
        bn.addm w2, w2, w10
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w10, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w3, w11
        bn.addm w3, w3, w11
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w11, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w4, w12
        bn.addm w4, w4, w12
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w12, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w5, w13
        bn.addm w5, w5, w13
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w13, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w6, w14
        bn.addm w6, w6, w14
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w14, w22, w20 >> 32 /* >> l */
            
        bn.subm w20, w7, w15
        bn.addm w7, w7, w15
        /* Plantard multiplication: Twiddle * (a-b) */
        bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
        bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
        bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
        bn.rshi w15, w22, w20 >> 32 /* >> l */

        /* Reassemble WDRs and store */
        bn.rshi w31, w0, w31 >> 32
        bn.rshi w31, w1, w31 >> 32
        bn.rshi w31, w2, w31 >> 32
        bn.rshi w31, w3, w31 >> 32
        bn.rshi w31, w4, w31 >> 32
        bn.rshi w31, w5, w31 >> 32
        bn.rshi w31, w6, w31 >> 32
        bn.rshi w31, w7, w31 >> 32
        bn.sid x4, 0(x10++)
        
        bn.rshi w31, w8, w31 >> 32
        bn.rshi w31, w9, w31 >> 32
        bn.rshi w31, w10, w31 >> 32
        bn.rshi w31, w11, w31 >> 32
        bn.rshi w31, w12, w31 >> 32
        bn.rshi w31, w13, w31 >> 32
        bn.rshi w31, w14, w31 >> 32
        bn.rshi w31, w15, w31 >> 32
        bn.sid x4, 0(x10++)

    /* Restore output pointer */
    addi x10, x10, -1024

    /* Set up constants for input/twiddle factors */
    li x23, 16  

    /* We can process 16 coefficients each iteration and need to process N=256, meaning we require 16 iterations. */
    LOOPI 2, 300
        /* Load coefficients into buffer registers */
        bn.lid x4, 0(x10)
        bn.lid x5, 64(x10)
        bn.lid x6, 128(x10)
        bn.lid x7, 192(x10)
        bn.lid x8, 256(x10)
        bn.lid x9, 320(x10)
        bn.lid x13, 384(x10)
        bn.lid x14, 448(x10)
        bn.lid x24, 512(x10)
        bn.lid x25, 576(x10)
        bn.lid x26, 640(x10)
        bn.lid x29, 704(x10)
        bn.lid x30, 768(x10)
        LOOPI 8, 273
            /* Extract coefficients from buffer registers into working state */
            bn.and w0, w31, w22 >> 192
            bn.and w1, w30, w22 >> 192
            bn.and w2, w29, w22 >> 192
            bn.and w3, w28, w22 >> 192
            bn.and w4, w27, w22 >> 192
            bn.and w5, w26, w22 >> 192
            bn.and w6, w25, w22 >> 192
            bn.and w7, w24, w22 >> 192
            bn.and w8, w17, w22 >> 192
            bn.and w9, w18, w22 >> 192
            bn.and w10, w19, w22 >> 192
            bn.and w11, w21, w22 >> 192
            bn.and w12, w23, w22 >> 192

            /* Coeff 13 */
            lw x27, 832(x10)
            sw x27, -32(x3)
            bn.lid x20, -32(x3)
            /* Coeff 14 */
            lw x27, 896(x10)
            sw x27, -32(x3)
            bn.lid x21, -32(x3)
            /* Coeff 15 */
            lw x27, 960(x10)
            sw x27, -32(x3)
            bn.lid x22, -32(x3)

            bn.lid x23, 0(x11)

            /* Layer 8, stride 1 */
            bn.subm w20, w0, w1
            bn.addm w0, w0, w1
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w1, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w2, w3
            bn.addm w2, w2, w3
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w3, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w4, w5
            bn.addm w4, w4, w5
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w5, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w6, w7
            bn.addm w6, w6, w7
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w7, w22, w20 >> 32 /* >> l */
                
            /* Load layer 8 twiddle 4x */
            bn.lid x23, 32(x11)

            bn.subm w20, w8, w9
            bn.addm w8, w8, w9
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w9, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w10, w11
            bn.addm w10, w10, w11
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w11, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w12, w13
            bn.addm w12, w12, w13
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w13, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w14, w15
            bn.addm w14, w14, w15
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w15, w22, w20 >> 32 /* >> l */

            /* Layer 7, stride 2 */
            /* Load layer 7 4x */
            bn.lid x23, 64(x11)

            bn.subm w20, w0, w2
            bn.addm w0, w0, w2
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w2, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w1, w3
            bn.addm w1, w1, w3
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w3, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w4, w6
            bn.addm w4, w4, w6
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w6, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w5, w7
            bn.addm w5, w5, w7
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w7, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w8, w10
            bn.addm w8, w8, w10
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w10, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w9, w11
            bn.addm w9, w9, w11
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w11, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w12, w14
            bn.addm w12, w12, w14
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w14, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w13, w15
            bn.addm w13, w13, w15
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w15, w22, w20 >> 32 /* >> l */

            /* Layer 6, stride 4 */
            /* Load layer 6 x2 + layer 5 x1 + pad */
            bn.lid x23, 96(x11)

            bn.subm w20, w0, w4
            bn.addm w0, w0, w4
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w4, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w1, w5
            bn.addm w1, w1, w5
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w5, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w2, w6
            bn.addm w2, w2, w6
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w6, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w3, w7
            bn.addm w3, w3, w7
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.0, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w7, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w8, w12
            bn.addm w8, w8, w12
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w12, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w9, w13
            bn.addm w9, w9, w13
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w13, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w10, w14
            bn.addm w10, w10, w14
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w14, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w11, w15
            bn.addm w11, w11, w15
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.1, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w15, w22, w20 >> 32 /* >> l */

            /* Layer 5, stride 8 */         

            bn.subm w20, w0, w8
            bn.addm w0, w0, w8
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w8, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w1, w9
            bn.addm w1, w1, w9
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w9, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w2, w10
            bn.addm w2, w2, w10
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w10, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w3, w11
            bn.addm w3, w3, w11
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w11, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w4, w12
            bn.addm w4, w4, w12
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w12, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w5, w13
            bn.addm w5, w5, w13
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w13, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w6, w14
            bn.addm w6, w6, w14
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w14, w22, w20 >> 32 /* >> l */
                
            bn.subm w20, w7, w15
            bn.addm w7, w7, w15
            /* Plantard multiplication: Twiddle * (a-b) */
            bn.mulqacc.wo.z w20, w20.0, w16.2, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w15, w22, w20 >> 32 /* >> l */

            /* Mul ninv */
            bn.mulqacc.wo.z w20, w0.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w0, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w1.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w1, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w2.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w2, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w3.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w3, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w4.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w4, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w5.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w5, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w6.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w6, w22, w20 >> 32 /* >> l */

            bn.mulqacc.wo.z w20, w7.0, w16.3, 192 /* a*bq' */
            bn.add w20, w22, w20 >> 160 /* + 2^alpha = 2^8 */
            bn.mulqacc.wo.z w20, w20.1, w22.2, 0 /* *q */
            bn.rshi w7, w22, w20 >> 32 /* >> l */

            /* Shift result values into the top of buffer registers */
            /* implicitly removes the old value */
            bn.rshi w31, w0, w31 >> 32
            bn.rshi w30, w1, w30 >> 32
            bn.rshi w29, w2, w29 >> 32
            bn.rshi w28, w3, w28 >> 32
            bn.rshi w27, w4, w27 >> 32
            bn.rshi w26, w5, w26 >> 32
            bn.rshi w25, w6, w25 >> 32
            bn.rshi w24, w7, w24 >> 32
            bn.rshi w17, w8, w17 >> 32
            bn.rshi w18, w9, w18 >> 32
            bn.rshi w19, w10, w19 >> 32
            bn.rshi w21, w11, w21 >> 32
            bn.rshi w23, w12, w23 >> 32

            /* Store unbuffered values */
            /* Coeff13 */
            bn.sid x20, -32(x3)
            lw x27, -32(x3)
            sw x27, 832(x10)
            /* Coeff14 */
            bn.sid x21, -32(x3)
            lw x27, -32(x3)
            sw x27, 896(x10)
            /* Coeff15 */
            bn.sid x22, -32(x3)
            lw x27, -32(x3)
            sw x27, 960(x10)
            
            /* Go to next coefficient for the unbuffered loads/stores */
            addi x10, x10, 4
            /* Inner Loop End */

        /* Subtract 32 from offset to account for the increment inside the LOOP 8 */
        bn.sid x4, -32(x10)
        bn.sid x5, 32(x10)
        bn.sid x6, 96(x10)
        bn.sid x7, 160(x10)
        bn.sid x8, 224(x10)
        bn.sid x9, 288(x10)
        bn.sid x13, 352(x10)
        bn.sid x14, 416(x10)
        bn.sid x24, 480(x10)
        bn.sid x25, 544(x10)
        bn.sid x26, 608(x10)
        bn.sid x29, 672(x10)
        bn.sid x30, 736(x10)
        /* Outer Loop End */

    /* Zero w31 again */
    bn.xor w31, w31, w31

    ret
