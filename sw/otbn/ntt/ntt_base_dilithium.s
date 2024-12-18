/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* originally from https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/crypto/handwritten/ntt_base_dilithium.s" */

.text

/* Register aliases
  .equ x2, sp
  .equ x3, fp
*/

/**
* Constant Time Dilithium NTT
*
* Returns: NTT(input)
*
* This implements the in-place NTT for Dilithium, where n=256, q=8380417.
* It is based on the improved Plantard multiplication with l=32.
*
* Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
*
* @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
* @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors
* @param[in]  w31: all-zero
* @param[out] x12: dmem pointer to result
*
* clobbered registers: x4-x30, w2-w25, w30-w31
*/
.globl ntt_base_dilithium
ntt_base_dilithium:
  /* 32 byte align the sp */
  andi x6, x2, 31
  beq  x6, x0, _aligned
  sub  x2, x2, x6
_aligned:
  addi x2, x2, -4      /* Decrement stack pointer by 4 bytes */
  sw   x6, 0(x2)      /* Store register value at the top of the stack */

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
  #define buf8 w17
  #define buf9 w18
  #define buf10 w19 */

  /* Twiddle Factors */
  /* #define tf1 w16 */

  /* Other */
  /* #define wtmp w20
  #define buf11 w21
  #define wtmp3 w22
  #define buf12 w23 */
  
  /* GPRs with indices to access WDRs */
  /* #define buf0_idx x4
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
  #define buf12_idx x30 */

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
  /* Create 0xFFFFFFFF in w17 for masking */
  bn.addi w17, w18, 1
  bn.rshi w17, w17, w18 >> 224
  bn.subi w17, w17, 1

  /* Load q to wtmp = w20 */
  la x27, modulus
  li x28, 20
  bn.lid x28, 0(x27) 

  /* clear w20 and copy modulus to wtemp3.2 = w22.2 */
  bn.and w20, w20, w17 /* clear wdr and copy modulus to w20.0 */
  bn.or w22, w18, w20 << 128

  /* Load alpha = 256 = 2^8 to wtmp3.1 = w22.1 */
  bn.addi w20, w18, 256
  bn.or w22, w22, w20 << 64

  /* Load 32bit mask to wtmp3.3 = w22.3 */
  bn.or w22, w22, w17 << 192

  /* We have one temp WDR for compute constants. These are stored in the quarter words like:
   * wtmp3 = w22
   * w22.0 = 0x00000000_00000000
   * w22.1 = Plantard's 2^alpha = 2^8 = 256
   * w22.2 = modulus: 0x00000000_007fe001
   * w22.3 = 0x00000000_FFFFFFFF
   * 
   * This WDR is also used to add 2^alpha by using
   * bn.add w8,  w22,  w8 >> 160
   * and operating only in the 3rd quarter word
   * Thus the w22.0 must be zero.
   */

  /* We can process 16 coefficients each iteration and need to process N=256, meaning we require
   * 16 iterations. This is split into 2*8 iterations where each of the 8 inner iterations works on 16
   * coefficients.
   *
   * We also perform a 4-4 layer merge
   */
  LOOPI 2, 269
    /* Load coefficients into buffer registers and process the first 4 NTT layers.
     * We can compute the NTT layers for "even" and "odd" indeces separately until the last layer.
     * Thus we load the following coefficients per iteration: 
     * 1st iteration: 0-7,  16-23, ..., 112-119, 128-135, 144-151, ..., 240-247
     * 2nd iteration: 8-15, 24-31, ..., 120-127, 136-143, 152-159, ..., 248-255
     * and then compute the butterflies for the coefficient pairs 0:128, 1:129, ...., 16:144, ..., 119:247
     */
    bn.lid x4,    0(x10)
    bn.lid x5,   64(x10)
    bn.lid x6,  128(x10)
    bn.lid x7,  192(x10)
    bn.lid x8,  256(x10)
    bn.lid x9,  320(x10)
    bn.lid x13, 384(x10)
    bn.lid x14, 448(x10)
    bn.lid x24, 512(x10)
    bn.lid x25, 576(x10)
    bn.lid x26, 640(x10)
    bn.lid x29, 704(x10)
    bn.lid x30, 768(x10)
    LOOPI 8, 242
      /* Load 4 twiddle factors into WDR16
       * As we use the improved Plantard multiplication and do merge the multiplication of m' to 
       * convert one operand into Plantard space a twiddle factor is 64b.
       * For iteration 1 we have
       * w16.0: 0x92e0bb09 0x00ca2087 = 0x92e0bb0900ca2087 = 10583664771663011975
       * w16.1: 0x73078efd 0xb04e1826 = 0x73078efdb04e1826 =  8288750859434465318
       * w16.2: 0x72e78afc 0xf0260fa4 = 0x72e78afcf0260fa4 =  8279739258909364132
       * w16.3: 0x9e33e1bc 0x073e5788 = 0x9e33e1bc073e5788 = 11399703279496484744
       *
       * Computation of twiddle factors:
       * First transform twiddle factor in to Plantard space
       * q       = 8380417
       * tf_orig = 4808194
       *
       * tf_plan = tf_orig * -(2^(2*l)) mod q
       *
       * Then multiply with m' (precompute to simplify montgomery multiplication)
       * m' = R = q^(-1) mod 2^(2*l)
       * tf_final = m' * tf_plan mod 2^(2*l)
       *
       * tf_final = ((zeta * -(2**64)) % q) * R
       * tf_final = ((zeta * -(2**64)) % 8380417) * 1732267787797143553
       */
      bn.lid x23, 0(x11)

      /* Extract 16 coefficients from buffer registers into working state
         Only 13 have space in WDRS, load 13-15 directly, see below */
      bn.and w0,  w31, w22 >> 192
      bn.and w1,  w30, w22 >> 192
      bn.and w2,  w29, w22 >> 192
      bn.and w3,  w28, w22 >> 192
      bn.and w4,  w27, w22 >> 192
      bn.and w5,  w26, w22 >> 192
      bn.and w6,  w25, w22 >> 192
      bn.and w7,  w24, w22 >> 192
      bn.and w8,  w17, w22 >> 192
      bn.and w9,  w18, w22 >> 192
      bn.and w10, w19, w22 >> 192
      bn.and w11, w21, w22 >> 192
      bn.and w12, w23, w22 >> 192

      /* Load remaining coefficients using 32-bit loads */
      /* Coeff 13 */
      lw x27, 832(x10)
      sw x27, -32(x3)
      bn.lid  x20, -32(x3)
      /* Coeff 14 */
      lw x27, 896(x10)
      sw x27, -32(x3)
      bn.lid  x21, -32(x3)
      /* Coeff 15 */
      lw x27, 960(x10)
      sw x27, -32(x3)
      bn.lid  x22, -32(x3)

      /* Layer 1 */

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w8,  w8.0, w16.0, 192 /* a*bq'. Store result in w8.3 to discard upper 32bits */
      /* + 2^alpha = 2^8. 2^alpha is in w22.1 thus shift result of mul in w8.3 to "w8.1". */
      bn.add          w8,  w22,  w8 >> 160 /* Ignore any results outside of w8.1 */
      bn.mulqacc.wo.z w8,  w8.1, w22.2, 0 /* *q, selecting quad word .1 does the division by 2^l */
      bn.rshi         w20, w22,  w8 >> 32 /* >> l, w22.0 is zero */
      /* Butterfly */
      bn.subm w8, w0, w20
      bn.addm w0, w0, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w9,  w9.0, w16.0, 192 /* a*bq' */
      bn.add          w9,  w22,  w9 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w9,  w9.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w9 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w9, w1, w20
      bn.addm w1, w1, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w10, w10.0, w16.0, 192 /* a*bq' */
      bn.add          w10, w22,   w10 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w10, w10.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w10 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w10, w2, w20
      bn.addm w2,  w2, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w11, w11.0, w16.0, 192 /* a*bq' */
      bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w11 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w11, w3, w20
      bn.addm w3,  w3, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w12, w12.0, w16.0, 192 /* a*bq' */
      bn.add          w12, w22,   w12 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w12, w12.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w12 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w12, w4, w20
      bn.addm w4,  w4, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w13, w13.0, w16.0, 192 /* a*bq' */
      bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w13 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w13, w5, w20
      bn.addm w5,  w5, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w14, w14.0, w16.0, 192 /* a*bq' */
      bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w14 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w14, w6, w20
      bn.addm w6,  w6, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w15, w15.0, w16.0, 192 /* a*bq' */
      bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w15 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w15, w7, w20
      bn.addm w7,  w7, w20

      /* Layer 2 */

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w4, w4.0, w16.1, 192 /* a*bq' */
      bn.add          w4, w22,  w4 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w4, w4.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w4 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w4, w0, w20
      bn.addm w0, w0, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w5, w5.0, w16.1, 192 /* a*bq' */
      bn.add          w5, w22,  w5 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w5, w5.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w5 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w5, w1, w20
      bn.addm w1, w1, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w6, w6.0, w16.1, 192 /* a*bq' */
      bn.add          w6, w22,  w6 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w6, w6.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w6 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w6, w2, w20
      bn.addm w2, w2, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w7, w7.0, w16.1, 192 /* a*bq' */
      bn.add          w7, w22,  w7 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w7, w7.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w7 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w7, w3, w20
      bn.addm w3, w3, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w12, w12.0, w16.2, 192 /* a*bq' */
      bn.add          w12, w22,   w12 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w12, w12.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w12 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w12, w8, w20
      bn.addm w8,  w8, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w13, w13.0, w16.2, 192 /* a*bq' */
      bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w13 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w13, w9, w20
      bn.addm w9,  w9, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w14, w14.0, w16.2, 192 /* a*bq' */
      bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w14 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w14, w10, w20
      bn.addm w10, w10, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
      bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w15 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w15, w11, w20
      bn.addm w11, w11, w20

      /* Layer 3 */

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w2,  w2.0, w16.3, 192 /* a*bq' */
      bn.add          w2,  w22,  w2 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w2,  w2.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w2 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w2, w0, w20
      bn.addm w0, w0, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w3, w3.0, w16.3, 192 /* a*bq' */
      bn.add          w3, w22,  w3 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w3, w3.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w3 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w3, w1, w20
      bn.addm w1, w1, w20

      /* load next twiddle factors */
      bn.lid x23, 32(x11)

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w6,  w6.0, w16.0, 192 /* a*bq' */
      bn.add          w6,  w22,  w6 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w6,  w6.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w6 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w6, w4, w20
      bn.addm w4, w4, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w7,  w7.0, w16.0, 192 /* a*bq' */
      bn.add          w7,  w22,  w7 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w7,  w7.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w7 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w7, w5, w20
      bn.addm w5, w5, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w10, w10.0, w16.1, 192 /* a*bq' */
      bn.add          w10, w22,  w10 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w10, w10.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w10 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w10, w8, w20
      bn.addm w8,  w8, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w11, w11.0, w16.1, 192 /* a*bq' */
      bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w11 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w11, w9, w20
      bn.addm w9,  w9, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w14, w14.0, w16.2, 192 /* a*bq' */
      bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w14 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w14, w12, w20
      bn.addm w12, w12, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
      bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w15 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w15, w13, w20
      bn.addm w13, w13, w20

      /* Layer 4 */

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w1, w1.0, w16.3, 192 /* a*bq' */
      bn.add          w1, w22,  w1 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w1, w1.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22, w1 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w1, w0, w20
      bn.addm w0, w0, w20

      bn.lid x23, 64(x11)

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w3,  w3.0, w16.0, 192 /* a*bq' */
      bn.add          w3,  w22,  w3 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w3,  w3.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w3 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w3, w2, w20
      bn.addm w2, w2, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w5,  w5.0, w16.1, 192 /* a*bq' */
      bn.add          w5,  w22,  w5 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w5,  w5.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w5 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w5, w4, w20
      bn.addm w4, w4, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w7,  w7.0, w16.2, 192 /* a*bq' */
      bn.add          w7,  w22,  w7 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w7,  w7.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w7 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w7, w6, w20
      bn.addm w6, w6, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w9,  w9.0, w16.3, 192 /* a*bq' */
      bn.add          w9,  w22,  w9 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w9,  w9.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,  w9 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w9, w8, w20
      bn.addm w8, w8, w20

      bn.lid x23, 96(x11)

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w11, w11.0, w16.0, 192 /* a*bq' */
      bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w11 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w11, w10, w20
      bn.addm w10, w10, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w13, w13.0, w16.1, 192 /* a*bq' */
      bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w13 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w13, w12, w20
      bn.addm w12, w12, w20

      /* Plantard multiplication: Twiddle * coeff */
      bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
      bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
      bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
      bn.rshi         w20, w22,   w15 >> 32 /* >> l */
      /* Butterfly */
      bn.subm w15, w14, w20
      bn.addm w14, w14, w20

      /* Shift result values into the top of buffer registers */
      /* implicitly removes the old value */
      bn.rshi w31, w0,  w31 >> 32
      bn.rshi w30, w1,  w30 >> 32
      bn.rshi w29, w2,  w29 >> 32
      bn.rshi w28, w3,  w28 >> 32
      bn.rshi w27, w4,  w27 >> 32
      bn.rshi w26, w5,  w26 >> 32
      bn.rshi w25, w6,  w25 >> 32
      bn.rshi w24, w7,  w24 >> 32
      bn.rshi w17, w8,  w17 >> 32
      bn.rshi w18, w9,  w18 >> 32
      bn.rshi w19, w10, w19 >> 32
      bn.rshi w21, w11, w21 >> 32
      bn.rshi w23, w12, w23 >> 32

      /* Store unbuffered values */
      /* Coeff13 */
      bn.sid x20, -32(x3)
      lw     x27, -32(x3)
      sw     x27, 832(x12)
      /* Coeff14 */
      bn.sid x21, -32(x3)
      lw     x27, -32(x3)
      sw     x27, 896(x12)
      /* Coeff15 */
      bn.sid x22, -32(x3)
      lw     x27, -32(x3)
      sw     x27, 960(x12)
      
      /* Go to next coefficient for the unbuffered loads/stores */
      addi x10, x10, 4
      addi x12, x12, 4
      /* Inner Loop End */

    /* Subtract 32 from offset to account for the increment inside the LOOP 8 */
    bn.sid x4,  -32(x12)
    bn.sid x5,   32(x12)
    bn.sid x6,   96(x12)
    bn.sid x7,  160(x12)
    bn.sid x8,  224(x12)
    bn.sid x9,  288(x12)
    bn.sid x13, 352(x12)
    bn.sid x14, 416(x12)
    bn.sid x24, 480(x12)
    bn.sid x25, 544(x12)
    bn.sid x26, 608(x12)
    bn.sid x29, 672(x12)
    bn.sid x30, 736(x12)
    /* x10 is now offset with 32. This way we load the 8-15, 32-47 values/
    /* Outer Loop End */
  
  /* Now comes the layer merge of layers 5 to 8 */

  /* Restore input pointer */
  addi x10, x10, -64
  /* Restore output pointer */
  addi x12, x12, -64

  /* Set the twiddle pointer for layer 5 */
  addi x11, x11, 128

  /* Set up constants for input/twiddle factors */
  li x23, 16

  bn.xor  w18, w18, w18
  bn.addi w17, w18, 1
  bn.rshi w17, w17, w18 >> 224
  bn.subi w17, w17, 1 

  LOOPI 16, 232
    /* Load layer 5 + 2 layer 6 + 1 layer 7 twiddle */
    bn.lid x23, 0(x11++)

    /* Load Data */
    bn.lid x4, 0(x12)
    bn.and  w0, w17, w31 >> 0
    bn.and  w1, w17, w31 >> 32
    bn.and  w2, w17, w31 >> 64
    bn.and  w3, w17, w31 >> 96
    bn.and  w4, w17, w31 >> 128
    bn.and  w5, w17, w31 >> 160
    bn.and  w6, w17, w31 >> 192
    bn.and  w7, w17, w31 >> 224

    bn.lid x4, 32(x12)
    bn.and  w8,  w17, w31 >> 0
    bn.and  w9,  w17, w31 >> 32
    bn.and  w10, w17, w31 >> 64
    bn.and  w11, w17, w31 >> 96
    bn.and  w12, w17, w31 >> 128
    bn.and  w13, w17, w31 >> 160
    bn.and  w14, w17, w31 >> 192
    bn.and  w15, w17, w31 >> 224

    /* Layer 5 */

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w8, w8.0, w16.0, 192 /* a*bq' */
    bn.add          w8, w22,  w8 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w8, w8.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22, w8 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w8, w0, w20
    bn.addm w0, w0, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w9, w9.0, w16.0, 192 /* a*bq' */
    bn.add          w9, w22,  w9 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w9, w9.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22, w9 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w9, w1, w20
    bn.addm w1, w1, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w10, w10.0, w16.0, 192 /* a*bq' */
    bn.add          w10, w22,   w10 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w10, w10.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w10 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w10, w2, w20
    bn.addm w2,  w2, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w11, w11.0, w16.0, 192 /* a*bq' */
    bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w11 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w11, w3, w20
    bn.addm w3,  w3, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w12, w12.0, w16.0, 192 /* a*bq' */
    bn.add          w12, w22,   w12 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w12, w12.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w12 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w12, w4, w20
    bn.addm w4,  w4, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w13, w13.0, w16.0, 192 /* a*bq' */
    bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w13 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w13, w5, w20
    bn.addm w5,  w5, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w14, w14.0, w16.0, 192 /* a*bq' */
    bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w14 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w14, w6, w20
    bn.addm w6,  w6, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w15, w15.0, w16.0, 192 /* a*bq' */
    bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w15 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w15, w7, w20
    bn.addm w7,  w7, w20

    /* Layer 6 */

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w4,  w4.0, w16.1, 192 /* a*bq' */
    bn.add          w4,  w22,  w4 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w4,  w4.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w4 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w4, w0, w20
    bn.addm w0, w0, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w5,  w5.0, w16.1, 192 /* a*bq' */
    bn.add          w5,  w22,  w5 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w5,  w5.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w5 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w5, w1, w20
    bn.addm w1, w1, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w6,  w6.0, w16.1, 192 /* a*bq' */
    bn.add          w6,  w22,  w6 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w6,  w6.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w6 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w6, w2, w20
    bn.addm w2, w2, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w7,  w7.0, w16.1, 192 /* a*bq' */
    bn.add          w7,  w22,  w7 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w7,  w7.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w7 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w7, w3, w20
    bn.addm w3, w3, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w12, w12.0, w16.2, 192 /* a*bq' */
    bn.add          w12, w22,   w12 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w12, w12.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w12 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w12, w8, w20
    bn.addm w8,  w8, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w13, w13.0, w16.2, 192 /* a*bq' */
    bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w13 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w13, w9, w20
    bn.addm w9,  w9, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w14, w14.0, w16.2, 192 /* a*bq' */
    bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w14 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w14, w10, w20
    bn.addm w10, w10, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
    bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w15 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w15, w11, w20
    bn.addm w11, w11, w20

    /* Layer 7 */

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w2,  w2.0, w16.3, 192 /* a*bq' */
    bn.add          w2,  w22,  w2 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w2,  w2.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w2 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w2, w0, w20
    bn.addm w0, w0, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w3,  w3.0, w16.3, 192 /* a*bq' */
    bn.add          w3,  w22,  w3 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w3,  w3.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w3 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w3, w1, w20
    bn.addm w1, w1, w20

    /* Load 3 layer 7, 1 layer 8 */
    bn.lid x23, 0(x11++)

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w6, w6.0, w16.0, 192 /* a*bq' */
    bn.add          w6, w22,  w6 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w6, w6.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22, w6 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w6, w4, w20
    bn.addm w4, w4, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w7,  w7.0, w16.0, 192 /* a*bq' */
    bn.add          w7,  w22,  w7 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w7,  w7.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w7 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w7, w5, w20
    bn.addm w5, w5, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w10, w10.0, w16.1, 192 /* a*bq' */
    bn.add          w10, w22,   w10 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w10, w10.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w10 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w10, w8, w20
    bn.addm w8,  w8, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w11, w11.0, w16.1, 192 /* a*bq' */
    bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w11 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w11, w9, w20
    bn.addm w9,  w9, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w14, w14.0, w16.2, 192 /* a*bq' */
    bn.add          w14, w22,   w14 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w14, w14.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w14 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w14, w12, w20
    bn.addm w12, w12, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
    bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w15 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w15, w13, w20
    bn.addm w13, w13, w20

    /* Layer 8 */

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w1,  w1.0, w16.3, 192 /* a*bq' */
    bn.add          w1,  w22,  w1 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w1,  w1.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w1 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w1, w0, w20
    bn.addm w0, w0, w20

    /* Load layer 4 layer 8 */
    bn.lid x23, 0(x11++)

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w3,  w3.0, w16.0, 192 /* a*bq' */
    bn.add          w3,  w22,  w3 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w3,  w3.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w3 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w3, w2, w20
    bn.addm w2, w2, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w5,  w5.0, w16.1, 192 /* a*bq' */
    bn.add          w5,  w22,  w5 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w5,  w5.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w5 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w5, w4, w20
    bn.addm w4, w4, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w7,  w7.0, w16.2, 192 /* a*bq' */
    bn.add          w7,  w22,  w7 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w7,  w7.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w7 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w7, w6, w20
    bn.addm w6, w6, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w9,  w9.0, w16.3, 192 /* a*bq' */
    bn.add          w9,  w22,  w9 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w9,  w9.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,  w9 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w9, w8, w20
    bn.addm w8, w8, w20

    /* Load layer 4 layer 8 + padding */
    bn.lid x23, 0(x11++)

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w11, w11.0, w16.0, 192 /* a*bq' */
    bn.add          w11, w22,   w11 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w11, w11.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w11 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w11, w10, w20
    bn.addm w10, w10, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w13, w13.0, w16.1, 192 /* a*bq' */
    bn.add          w13, w22,   w13 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w13, w13.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w13 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w13, w12, w20
    bn.addm w12, w12, w20

    /* Plantard multiplication: Twiddle * coeff */
    bn.mulqacc.wo.z w15, w15.0, w16.2, 192 /* a*bq' */
    bn.add          w15, w22,   w15 >> 160 /* + 2^alpha = 2^8 */
    bn.mulqacc.wo.z w15, w15.1, w22.2, 0 /* *q */
    bn.rshi         w20, w22,   w15 >> 32 /* >> l */
    /* Butterfly */
    bn.subm w15, w14, w20
    bn.addm w14, w14, w20

    /* Reassemble WDRs and store */
    bn.rshi w31, w0, w31 >> 32
    bn.rshi w31, w1, w31 >> 32
    bn.rshi w31, w2, w31 >> 32
    bn.rshi w31, w3, w31 >> 32
    bn.rshi w31, w4, w31 >> 32
    bn.rshi w31, w5, w31 >> 32
    bn.rshi w31, w6, w31 >> 32
    bn.rshi w31, w7, w31 >> 32
    bn.sid  x4,  0(x12++)
    
    bn.rshi w31, w8, w31 >> 32
    bn.rshi w31, w9, w31 >> 32
    bn.rshi w31, w10, w31 >> 32
    bn.rshi w31, w11, w31 >> 32
    bn.rshi w31, w12, w31 >> 32
    bn.rshi w31, w13, w31 >> 32
    bn.rshi w31, w14, w31 >> 32
    bn.rshi w31, w15, w31 >> 32
    bn.sid x4, 0(x12++)

  /* Zero w31 again */
  bn.xor w31, w31, w31

  ret
