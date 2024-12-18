/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Constant Time ML-DSA (Dilithium) NTT
 *
 * Returns: NTT(input)
 *
 * This implements the in-place NTT for ML-DSA (Dilithium), where n=256, q=8380417.
 * 
 * This implementation makes use of vectorized OTBN instructions and uses Montgomery
 * multiplication. The twiddle factors therefore must be pretransformed into Montgomery space.
 * 
 * Inspired by:
 * https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/
 * crypto/handwritten/ntt_dilithium.s
 * and
 * Towards ML-KEM & ML-DSA on OpenTitan: https://eprint.iacr.org/2024/1192
 *
 * Thesis and paper describing the implementation in more details:
 * https://github.com/dop-amin/dilithium-on-opentitan-thesis/tree/main
 * Towards ML-KEM & ML-DSA on OpenTitan: https://eprint.iacr.org/2024/1192
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x10: dptr_input, dmem pointer to first word of input polynomial
 * @param[in]  x11: dptr_tw, dmem pointer to array of twiddle factors
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4-x30, w0-w31
 */
.global ntt_mldsa
ntt_mldsa:
  /* 
   * We perform a 4-4 layer merge.
   *
   * One WDR is 256b = 32B.
   * One WDR can hold 256b/32b = 8 twiddle factors or coefficients.
   * With 16 WDRs we can store 16 * 8 = 128 coefficients. Storing all 256 coeffs in 32 WDRs is not
   * possible as we need some WDRs for twiddle factors and temporary results.
   * We therefore split the NTT in two iterations and select the following input data to work with
   * 1st iteration: 0-7,  16-23, ..., 112-119, 128-135, 144-151, ..., 240-247
   * 2nd iteration: 8-15, 24-31, ..., 120-127, 136-143, 152-159, ..., 248-255
   *
   * This way we can compute half of the butterflies in each iteration as these are independent
   * across these two sets for 4 layers. I.e. the compute pairs for iteration 1 are
   * layer 1, stride 128: 0:128, 1:129, ..., 7:135, 16:144, ..., 119:247
   * layer 2, stride  64: 0:64,  1:65,  ..., 7:71,  16:80,  ..., 119:183, 184:247
   * layer 3, stride  32: 0:32, ...
   * layer 4, stride  16: 0:16, ...
   *
   * We do a 4-4 layer merge. With the split from above we cannot compute more than 4 layers before
   * requiring data from the other split. Is this correct?
   *
   * layer 5, stride   8: 0:8,  ...
   * layer 6, stride   4: 0:4,  ... from now WDRs do conflict, we need shuffling
   * layer 7, stride   2: 0:2,  ...
   * layer 8, stride   1: 0:1,  ...
   *
   * For layer i in [1,8] we need 2^(i-1) twiddle factors. -> 1, 2, 4, 8, .. , 128
   * For layers 1-4 we only require 1 WDR to store the twiddle factors.
   * For higher layers we need more WDRS. At layer 8 this requires 128 / 8 = 16 WDRs which is again no feasible.
   * Therefore we also split these layers in two part. But now we split it in 0-127 and 128-255.
   * Each part can now be computed independently and requires at most 8 WDRs for twiddle factors.
   */

  /* WDR allocation 
   * 
   * working WDRs:     w0 - w15
   * twiddle factors:  w16 - w23
   * temporary value:  w31
   * transpose helper: w24 - w31
  */

  /* setup wdr indexes */
  /* x10, x11, x12 are parameters */
  li  x4,  0
  li  x5,  1
  li  x6,  2
  li  x7,  3
  li  x8,  4
  li  x9,  5
  li  x13, 6
  li  x14, 7
  li  x15, 8
  li  x16, 9
  li  x17, 10
  li  x18, 11
  li  x19, 12
  li  x20, 13
  li  x21, 14
  li  x22, 15
  /* setup twiddle wdr indexes */
  li  x23, 16
  li  x24, 17
  li  x25, 18
  li  x26, 19
  li  x27, 20
  li  x28, 21
  li  x29, 22
  li  x30, 23

  /******************
  * Layers 1 to 4
  *******************/

  /* Load twiddle factors i.j where i is layer and j is twiddle j of layer i*/
  /* wdr layout: 4.0, 3.3, 3.2, 3.1, 3.0, 2.1, 2.0, 1.0 */
  bn.lid x23,  0(x11)
  /* wdr layout: n/a, 4.7, 4.6, 4.5, 4.4, 4.3, 4.2, 4.1 */
  bn.lid x24, 32(x11)

  /* Loop over the split input data.
   * We expect the following instruction count:
   * Butterflies:  4 * 8 * 3 = 96 (layers * Vectorized Butterflies * InsnPerVecButterfly)
   * Data loading:             16
   * Data storing:             16
   * Pointer handling:          2
   * Total:                   130
   */
  loopi 2, 130
    /* Load the input data. Always 8 coeffs per WDR */
    bn.lid x4,    0(x10)
    bn.lid x5,   64(x10)
    bn.lid x6,  128(x10)
    bn.lid x7,  192(x10)
    bn.lid x8,  256(x10)
    bn.lid x9,  320(x10)
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

    /* Layer 1, stride 128 */
    bn.mulvml.8S w31, w8,  w16, 0
    bn.subvm.8S  w8,  w0,  w31
    bn.addvm.8S  w0,  w0,  w31
    bn.mulvml.8S w31, w9,  w16, 0
    bn.subvm.8S  w9,  w1,  w31
    bn.addvm.8S  w1,  w1,  w31
    bn.mulvml.8S w31, w10, w16, 0
    bn.subvm.8S  w10, w2,  w31
    bn.addvm.8S  w2,  w2,  w31
    bn.mulvml.8S w31, w11, w16, 0
    bn.subvm.8S  w11, w3,  w31
    bn.addvm.8S  w3,  w3,  w31
    bn.mulvml.8S w31, w12, w16, 0
    bn.subvm.8S  w12, w4,  w31
    bn.addvm.8S  w4,  w4,  w31
    bn.mulvml.8S w31, w13, w16, 0
    bn.subvm.8S  w13, w5,  w31
    bn.addvm.8S  w5,  w5,  w31
    bn.mulvml.8S w31, w14, w16, 0
    bn.subvm.8S  w14, w6,  w31
    bn.addvm.8S  w6,  w6,  w31
    bn.mulvml.8S w31, w15, w16, 0
    bn.subvm.8S  w15, w7,  w31
    bn.addvm.8S  w7,  w7,  w31

    /* Layer 2, stride 64 */
    bn.mulvml.8S w31, w4, w16, 1
    bn.subvm.8S  w4,  w0, w31
    bn.addvm.8S  w0,  w0, w31
    bn.mulvml.8S w31, w5, w16, 1
    bn.subvm.8S  w5,  w1, w31
    bn.addvm.8S  w1,  w1, w31
    bn.mulvml.8S w31, w6, w16, 1
    bn.subvm.8S  w6,  w2, w31
    bn.addvm.8S  w2,  w2, w31
    bn.mulvml.8S w31, w7, w16, 1
    bn.subvm.8S  w7,  w3, w31
    bn.addvm.8S  w3,  w3, w31
    bn.mulvml.8S w31, w12, w16, 2
    bn.subvm.8S  w12, w8, w31
    bn.addvm.8S  w8,  w8, w31
    bn.mulvml.8S w31, w13, w16, 2
    bn.subvm.8S  w13, w9, w31
    bn.addvm.8S  w9,  w9, w31
    bn.mulvml.8S w31, w14, w16, 2
    bn.subvm.8S  w14, w10, w31
    bn.addvm.8S  w10, w10, w31
    bn.mulvml.8S w31, w15, w16, 2
    bn.subvm.8S  w15, w11, w31
    bn.addvm.8S  w11, w11, w31

    /* Layer 3, stride 32 */
    bn.mulvml.8S w31, w2, w16, 3
    bn.subvm.8S  w2,  w0, w31
    bn.addvm.8S  w0,  w0, w31
    bn.mulvml.8S w31, w3, w16, 3
    bn.subvm.8S  w3,  w1, w31
    bn.addvm.8S  w1,  w1, w31
    bn.mulvml.8S w31, w6, w16, 4
    bn.subvm.8S  w6,  w4, w31
    bn.addvm.8S  w4,  w4, w31
    bn.mulvml.8S w31, w7, w16, 4
    bn.subvm.8S  w7,  w5, w31
    bn.addvm.8S  w5,  w5, w31
    bn.mulvml.8S w31, w10, w16, 5
    bn.subvm.8S  w10, w8, w31
    bn.addvm.8S  w8,  w8, w31
    bn.mulvml.8S w31, w11, w16, 5
    bn.subvm.8S  w11, w9, w31
    bn.addvm.8S  w9,  w9, w31
    bn.mulvml.8S w31, w14, w16, 6
    bn.subvm.8S  w14, w12, w31
    bn.addvm.8S  w12, w12, w31
    bn.mulvml.8S w31, w15, w16, 6
    bn.subvm.8S  w15, w13, w31
    bn.addvm.8S  w13, w13, w31

    /* Layer 4, stride 16 */
    bn.mulvml.8S w31, w1, w16, 7
    bn.subvm.8S  w1,  w0, w31
    bn.addvm.8S  w0,  w0, w31
    bn.mulvml.8S w31, w3, w17, 0
    bn.subvm.8S  w3,  w2, w31
    bn.addvm.8S  w2,  w2, w31
    bn.mulvml.8S w31, w5, w17, 1
    bn.subvm.8S  w5,  w4, w31
    bn.addvm.8S  w4,  w4, w31
    bn.mulvml.8S w31, w7, w17, 2
    bn.subvm.8S  w7,  w6, w31
    bn.addvm.8S  w6,  w6, w31
    bn.mulvml.8S w31, w9, w17, 3
    bn.subvm.8S  w9,  w8, w31
    bn.addvm.8S  w8,  w8, w31
    bn.mulvml.8S w31, w11, w17, 4
    bn.subvm.8S  w11, w10, w31
    bn.addvm.8S  w10, w10, w31
    bn.mulvml.8S w31, w13, w17, 5
    bn.subvm.8S  w13, w12, w31
    bn.addvm.8S  w12, w12, w31
    bn.mulvml.8S w31, w15, w17, 6
    bn.subvm.8S  w15, w14, w31
    bn.addvm.8S  w14, w14, w31

    /* Store output data */
    bn.sid x4,    0(x12)
    bn.sid x5,   64(x12)
    bn.sid x6,  128(x12)
    bn.sid x7,  192(x12)
    bn.sid x8,  256(x12)
    bn.sid x9,  320(x12)
    bn.sid x13, 384(x12)
    bn.sid x14, 448(x12)
    bn.sid x15, 512(x12)
    bn.sid x16, 576(x12)
    bn.sid x17, 640(x12)
    bn.sid x18, 704(x12)
    bn.sid x19, 768(x12)
    bn.sid x20, 832(x12)
    bn.sid x21, 896(x12)
    bn.sid x22, 960(x12)

    /* Progress to next split */
    addi x10, x10, 32
    addi x12, x12, 32

    /* END LOOP Layers 1 to 4 */
  
  /* Restore the pointers (due to the split increment) */
  addi x10, x10, -64
  addi x12, x12, -64

  /******************
  * Layers 5 to 8
  *******************/
  /* All these layers require different twiddle factors during the merging.
   * Set the twiddle pointer for layer 5 to start with
   */
  addi x11, x11, 64

  /* Loop over the split
   * We expect the following instruction count:
   * Butterflies:  4 * 8 * 3   = 96 (layers * Vectorized Butterflies * InsnPerVecButterfly)
   * Transposition: 2 * 2 * 24 = 96 (forward and backward for w0-w7 and w8-w15 each)
   * Data loading:               16
   * Data storing:               16
   * Twiddle pointer handling:   1 + 2 + 4 + 8 = 15
   * Pointer handling:            1
   * Total:                     240
   */
  loopi 2, 240
    /* Load input data */
    bn.lid x4,    0(x12)
    bn.lid x5,   32(x12)
    bn.lid x6,   64(x12)
    bn.lid x7,   96(x12)
    bn.lid x8,  128(x12)
    bn.lid x9,  160(x12)
    bn.lid x13, 192(x12)
    bn.lid x14, 224(x12)
    bn.lid x15, 256(x12)
    bn.lid x16, 288(x12)
    bn.lid x17, 320(x12)
    bn.lid x18, 352(x12)
    bn.lid x19, 384(x12)
    bn.lid x20, 416(x12)
    bn.lid x21, 448(x12)
    bn.lid x22, 480(x12)

    /* Layer 5, stride 8 */
    /* Load twiddle factors */
    bn.lid x23, 0(x11++) /* set twiddle pointer to layer 6 - iteration 1 */
    /* Butterflies */
    bn.mulvml.8S w31, w1,  w16, 0
    bn.subvm.8S  w1,  w0,  w31
    bn.addvm.8S  w0,  w0,  w31
    bn.mulvml.8S w31, w3,  w16, 1
    bn.subvm.8S  w3,  w2,  w31
    bn.addvm.8S  w2,  w2,  w31
    bn.mulvml.8S w31, w5,  w16, 2
    bn.subvm.8S  w5,  w4,  w31
    bn.addvm.8S  w4,  w4,  w31
    bn.mulvml.8S w31, w7,  w16, 3
    bn.subvm.8S  w7,  w6,  w31
    bn.addvm.8S  w6,  w6,  w31
    bn.mulvml.8S w31, w9,  w16, 4
    bn.subvm.8S  w9,  w8,  w31
    bn.addvm.8S  w8,  w8,  w31
    bn.mulvml.8S w31, w11, w16, 5
    bn.subvm.8S  w11, w10, w31
    bn.addvm.8S  w10, w10, w31
    bn.mulvml.8S w31, w13, w16, 6
    bn.subvm.8S  w13, w12, w31
    bn.addvm.8S  w12, w12, w31
    bn.mulvml.8S w31, w15, w16, 7
    bn.subvm.8S  w15, w14, w31
    bn.addvm.8S  w14, w14, w31

    /* Transpose such that the pairs are in different vectors */
    /* In iteration 1 we have
     * w0 = 0-7, w1 = 8-15, ..., w15 = 112-127
     * We want to compute the butterflies for the pairs
     * layer 6: 0:4, 1:5, 2:6, .., 59:63, 64:68, .., 123-127
     * layer 7: 0:2, 1:3, ..
     * layer 8: 0:1, 2:3, ..
     *
     * We have
     * w0  =   7 ..  2   1    0
     * w1  =  15 .. 10   9    8
     * ...
     * w7  =  63 .. 58  57   56
     *
     * w8  =  71 .. 66  65   64
     * ...
     * w15 = 127 .. 122 121 120
     *
     * Thus we need (ordered as in WDR)
     * w0  =  56 .. 16  8  0
     * w1  =  57    ..  9  1
     * w2  =  58    .. 10  2
     * w3  =  59    .. 11  3
     * w4  =  60    .. 12  4
     * w5  =  61    .. 13  5
     * w6  =  62    .. 14  6
     * w7  =  63 .. 23 15  7
     *
     * w8  = 120 .. 80 72 64
     * w9  =        .. 73 65
     * ...
     * w15 = 127 .. 87 79 71
     *
     * Adapted from:
     * Hanno Becker, Vincent Hwang, Matthias J. Kannwischer, Bo-Yin Yang, and
     * Shang-Yi Yang. Neon NTT: Faster Dilithium, Kyber, and Saber on CortexA72 and Apple M1. IACR
     * TCHES, 2022(1):221–244, 2022.
     *
     * Code for transposition with 16 temporary WDRS (we dont have this)
     * w0-w7 input & output, w10-w17, w20-27 temporary
     *
     *  bn.trn1.8S w10, w0, w1
     *  bn.trn2.8S w11, w0, w1
     *  bn.trn1.8S w12, w2, w3
     *  bn.trn2.8S w13, w2, w3
     *  bn.trn1.8S w14, w4, w5
     *  bn.trn2.8S w15, w4, w5
     *  bn.trn1.8S w16, w6, w7
     *  bn.trn2.8S w17, w6, w7
     *  bn.trn1.4D w20, w10, w12
     *  bn.trn2.4D w22, w10, w12
     *  bn.trn1.4D w21, w11, w13
     *  bn.trn2.4D w23, w11, w13
     *  bn.trn1.4D w24, w14, w16
     *  bn.trn2.4D w26, w14, w16
     *  bn.trn1.4D w25, w15, w17
     *  bn.trn2.4D w27, w15, w17
     *  bn.trn1.2Q w0, w20, w24
     *  bn.trn2.2Q w4, w20, w24
     *  bn.trn1.2Q w1, w21, w25
     *  bn.trn2.2Q w5, w21, w25
     *  bn.trn1.2Q w2, w22, w26
     *  bn.trn2.2Q w6, w22, w26
     *  bn.trn1.2Q w3, w23, w27
     *  bn.trn2.2Q w7, w23, w27
     */

    /* Transpose w0 - w7 via w24 - w31 */
    bn.trn1.8S w24, w0, w1
    bn.trn2.8S w25, w0, w1
    bn.trn1.8S w26, w2, w3
    bn.trn2.8S w27, w2, w3
    bn.trn1.8S w28, w4, w5
    bn.trn2.8S w29, w4, w5
    bn.trn1.8S w30, w6, w7
    bn.trn2.8S w31, w6, w7
    bn.trn1.4D w4,  w24, w26
    bn.trn2.4D w24, w24, w26
    bn.trn1.4D w26, w25, w27
    bn.trn2.4D w25, w25, w27
    bn.trn1.4D w27, w28, w30
    bn.trn2.4D w28, w28, w30
    bn.trn1.4D w30, w29, w31
    bn.trn2.4D w29, w29, w31
    bn.trn1.2Q w0, w4,  w27
    bn.trn2.2Q w4, w4,  w27
    bn.trn1.2Q w1, w26, w30
    bn.trn2.2Q w5, w26, w30
    bn.trn1.2Q w2, w24, w28
    bn.trn2.2Q w6, w24, w28
    bn.trn1.2Q w3, w25, w29
    bn.trn2.2Q w7, w25, w29

    /* Transpose w8 - w15 via w24 - w31 */
    bn.trn1.8S w24, w8,  w9
    bn.trn2.8S w25, w8,  w9
    bn.trn1.8S w26, w10, w11
    bn.trn2.8S w27, w10, w11
    bn.trn1.8S w28, w12, w13
    bn.trn2.8S w29, w12, w13
    bn.trn1.8S w30, w14, w15
    bn.trn2.8S w31, w14, w15
    bn.trn1.4D w12, w24, w26
    bn.trn2.4D w24, w24, w26
    bn.trn1.4D w26, w25, w27
    bn.trn2.4D w25, w25, w27
    bn.trn1.4D w27, w28, w30
    bn.trn2.4D w28, w28, w30
    bn.trn1.4D w30, w29, w31
    bn.trn2.4D w29, w29, w31
    bn.trn1.2Q w8,  w12, w27
    bn.trn2.2Q w12, w12, w27
    bn.trn1.2Q w9,  w26, w30
    bn.trn2.2Q w13, w26, w30
    bn.trn1.2Q w10, w24, w28
    bn.trn2.2Q w14, w24, w28
    bn.trn1.2Q w11, w25, w29
    bn.trn2.2Q w15, w25, w29

    /* Layer 6, stride 4 */
    /* Load twiddle factors */
    bn.lid x23, 0(x11++)
    bn.lid x24, 0(x11++) /* twiddle pointer is now by layer 7 - iteration 1 */
    /* Butterflies */
    bn.mulvm.8S w31, w4, w16
    bn.subvm.8S w4,  w0, w31
    bn.addvm.8S w0,  w0, w31
    bn.mulvm.8S w31, w5, w16
    bn.subvm.8S w5,  w1, w31
    bn.addvm.8S w1,  w1, w31
    bn.mulvm.8S w31, w6, w16
    bn.subvm.8S w6,  w2, w31
    bn.addvm.8S w2,  w2, w31
    bn.mulvm.8S w31, w7, w16
    bn.subvm.8S w7,  w3, w31
    bn.addvm.8S w3,  w3, w31

    bn.mulvm.8S w31, w12, w17
    bn.subvm.8S w12, w8,  w31
    bn.addvm.8S w8,  w8,  w31
    bn.mulvm.8S w31, w13, w17
    bn.subvm.8S w13, w9,  w31
    bn.addvm.8S w9,  w9,  w31
    bn.mulvm.8S w31, w14, w17
    bn.subvm.8S w14, w10, w31
    bn.addvm.8S w10, w10, w31
    bn.mulvm.8S w31, w15, w17
    bn.subvm.8S w15, w11, w31
    bn.addvm.8S w11, w11, w31

    /* Layer 7, stride 2 */
    /* Load twiddle factors */
    bn.lid x23, 0(x11++)
    bn.lid x24, 0(x11++)
    bn.lid x25, 0(x11++)
    bn.lid x26, 0(x11++)

    bn.mulvm.8S w31, w2, w16
    bn.subvm.8S w2,  w0, w31
    bn.addvm.8S w0,  w0, w31
    bn.mulvm.8S w31, w3, w16
    bn.subvm.8S w3,  w1, w31
    bn.addvm.8S w1,  w1, w31
    bn.mulvm.8S w31, w6, w17
    bn.subvm.8S w6,  w4, w31
    bn.addvm.8S w4,  w4, w31
    bn.mulvm.8S w31, w7, w17
    bn.subvm.8S w7,  w5, w31
    bn.addvm.8S w5,  w5, w31

    bn.mulvm.8S w31, w10, w18
    bn.subvm.8S w10,  w8, w31
    bn.addvm.8S w8,   w8, w31
    bn.mulvm.8S w31, w11, w18
    bn.subvm.8S w11,  w9, w31
    bn.addvm.8S w9,   w9, w31
    bn.mulvm.8S w31, w14, w19
    bn.subvm.8S w14, w12, w31
    bn.addvm.8S w12, w12, w31
    bn.mulvm.8S w31, w15, w19
    bn.subvm.8S w15, w13, w31
    bn.addvm.8S w13, w13, w31

    /* Layer 8, stride 1 */
    /* Load twiddle factors */
    bn.lid x23, 0(x11++)
    bn.lid x24, 0(x11++)
    bn.lid x25, 0(x11++)
    bn.lid x26, 0(x11++)
    bn.lid x27, 0(x11++)
    bn.lid x28, 0(x11++)
    bn.lid x29, 0(x11++)
    bn.lid x30, 0(x11++)

    bn.mulvm.8S w31, w1,  w16
    bn.subvm.8S w1,  w0,  w31
    bn.addvm.8S w0,  w0,  w31
    bn.mulvm.8S w31, w3,  w17
    bn.subvm.8S w3,  w2,  w31
    bn.addvm.8S w2,  w2,  w31
    bn.mulvm.8S w31, w5,  w18
    bn.subvm.8S w5,  w4,  w31
    bn.addvm.8S w4,  w4,  w31
    bn.mulvm.8S w31, w7,  w19
    bn.subvm.8S w7,  w6,  w31
    bn.addvm.8S w6,  w6,  w31
    bn.mulvm.8S w31, w9,  w20
    bn.subvm.8S w9,  w8,  w31
    bn.addvm.8S w8,  w8,  w31
    bn.mulvm.8S w31, w11, w21
    bn.subvm.8S w11, w10, w31
    bn.addvm.8S w10, w10, w31
    bn.mulvm.8S w31, w13, w22
    bn.subvm.8S w13, w12, w31
    bn.addvm.8S w12, w12, w31
    bn.mulvm.8S w31, w15, w23
    bn.subvm.8S w15, w14, w31
    bn.addvm.8S w14, w14, w31

    /* Transpose back w0 - w7 via w24 - w31 */
    bn.trn1.8S w24, w0, w1
    bn.trn2.8S w25, w0, w1
    bn.trn1.8S w26, w2, w3
    bn.trn2.8S w27, w2, w3
    bn.trn1.8S w28, w4, w5
    bn.trn2.8S w29, w4, w5
    bn.trn1.8S w30, w6, w7
    bn.trn2.8S w31, w6, w7
    bn.trn1.4D w4,  w24, w26
    bn.trn2.4D w24, w24, w26
    bn.trn1.4D w26, w25, w27
    bn.trn2.4D w25, w25, w27
    bn.trn1.4D w27, w28, w30
    bn.trn2.4D w28, w28, w30
    bn.trn1.4D w30, w29, w31
    bn.trn2.4D w29, w29, w31
    bn.trn1.2Q w0, w4,  w27
    bn.trn2.2Q w4, w4,  w27
    bn.trn1.2Q w1, w26, w30
    bn.trn2.2Q w5, w26, w30
    bn.trn1.2Q w2, w24, w28
    bn.trn2.2Q w6, w24, w28
    bn.trn1.2Q w3, w25, w29
    bn.trn2.2Q w7, w25, w29

    /* Transpose back w8 - w15 via w24 - w31 */
    bn.trn1.8S w24, w8,  w9
    bn.trn2.8S w25, w8,  w9
    bn.trn1.8S w26, w10, w11
    bn.trn2.8S w27, w10, w11
    bn.trn1.8S w28, w12, w13
    bn.trn2.8S w29, w12, w13
    bn.trn1.8S w30, w14, w15
    bn.trn2.8S w31, w14, w15
    bn.trn1.4D w12, w24, w26
    bn.trn2.4D w24, w24, w26
    bn.trn1.4D w26, w25, w27
    bn.trn2.4D w25, w25, w27
    bn.trn1.4D w27, w28, w30
    bn.trn2.4D w28, w28, w30
    bn.trn1.4D w30, w29, w31
    bn.trn2.4D w29, w29, w31
    bn.trn1.2Q w8,  w12, w27
    bn.trn2.2Q w12, w12, w27
    bn.trn1.2Q w9,  w26, w30
    bn.trn2.2Q w13, w26, w30
    bn.trn1.2Q w10, w24, w28
    bn.trn2.2Q w14, w24, w28
    bn.trn1.2Q w11, w25, w29
    bn.trn2.2Q w15, w25, w29

    /* Store results */
    bn.sid x4,  0(x12++)
    bn.sid x5,  0(x12++)
    bn.sid x6,  0(x12++)
    bn.sid x7,  0(x12++)
    bn.sid x8,  0(x12++)
    bn.sid x9,  0(x12++)
    bn.sid x13, 0(x12++)
    bn.sid x14, 0(x12++)
    bn.sid x15, 0(x12++)
    bn.sid x16, 0(x12++)
    bn.sid x17, 0(x12++)
    bn.sid x18, 0(x12++)
    bn.sid x19, 0(x12++)
    bn.sid x20, 0(x12++)
    bn.sid x21, 0(x12++)
    bn.sid x22, 0(x12++)

    /* go to next split -> with ++ in store */
    addi x10, x10, 512

    /* END LOOP Layers 5 to 8 */

  ret