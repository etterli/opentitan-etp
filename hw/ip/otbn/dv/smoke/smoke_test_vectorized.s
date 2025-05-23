/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


# OTBN Smoke test, runs various vectorized instructions which are expected to produce the
# final register state see in smoke_vectorized_expected.txt

.section .text.start
/*****************************************
 * BN.ADDV - Load the vectors into w0-w7 *
 *****************************************/
addi x2, x0, 0
la     x3, vec16a_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec16b_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec32a_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec32b_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec64a_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec64b_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec128a_bnaddv
bn.lid x2++, 0(x3)
la     x3, vec128b_bnaddv
bn.lid x2++, 0(x3)

bn.addv.16H w10, w0, w1
bn.addv.8S  w11, w2, w3
bn.addv.4D  w12, w4, w5
bn.addv.2Q  w13, w6, w7

/******************************************************
 * BN.ADDVM - Load the vectors into w0-w9, MOD is w20 *
 ******************************************************/
addi x2, x0, 0
la     x3, vec16a0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec16b0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec32a0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec32b0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec64a0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec64b0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec128a0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec128b0_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec128a1_bnaddvm
bn.lid x2++, 0(x3)
la     x3, vec128b1_bnaddvm
bn.lid x2++, 0(x3)

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.addvm.16H w10, w0, w1

li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.addvm.8S  w11, w2, w3

li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.addvm.4D  w12, w4, w5

li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.addvm.2Q   w13, w6, w7
bn.addvm.2Q   w14, w8, w9

/********************************
 * BN.SHV - Only each ELEN once *
 ********************************/
addi x2, x0, 0

la     x3, vecorig_bnshv
bn.lid x2, 0(x3)

bn.shv.16H w1, w0 << 9
bn.shv.16H w1, w0 >> 9
bn.shv.8S  w1, w0 << 11
bn.shv.8S  w1, w0 >> 30
bn.shv.4D  w1, w0 << 44
bn.shv.4D  w1, w0 >> 56
bn.shv.2Q  w1, w0 << 67
bn.shv.2Q  w1, w0 >> 120

/***********
 * BN.SUBV *
 ***********/
addi x2, x0, 0
la     x3, vec16a0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec16b0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec32a0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec32b0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec64a0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec64b0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec128a0_bnsubv
bn.lid x2++, 0(x3)
la     x3, vec128b0_bnsubv
bn.lid x2++, 0(x3)

bn.subv.16H w10, w0, w1
bn.subv.8S  w11, w2, w3
bn.subv.4D  w12, w4, w5
bn.subv.2Q  w13, w6, w7

/************
 * BN.SUBVM *
 ************/
addi x2, x0, 0
la     x3, vec16a0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec16b0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec32a0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec32b0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec64a0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec64b0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec128a0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec128b0_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec128a1_bnsubvm
bn.lid x2++, 0(x3)
la     x3, vec128b1_bnsubvm
bn.lid x2++, 0(x3)

li           x2, 20
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.16H w10, w0, w1

li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.8S  w11, w2, w3

li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.subvm.4D  w12, w4, w5

li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.subvm.2Q   w13, w6, w7
bn.subvm.2Q   w14, w8, w9

/***********
 * BN.TRN1 *
 ***********/
addi x2, x0, 0
la     x3, vec16a_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec16b_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec32a_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec32b_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec64a_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec64b_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec128a_bntrn1
bn.lid x2++, 0(x3)
la     x3, vec128b_bntrn1
bn.lid x2++, 0(x3)

bn.trn1.16H w10, w0, w1
bn.trn1.8S  w11, w2, w3
bn.trn1.4D  w12, w4, w5
bn.trn1.2Q  w13, w6, w7

/***********
 * BN.TRN2 *
 ***********/
addi x2, x0, 0
la     x3, vec16a_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec16b_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec32a_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec32b_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec64a_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec64b_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec128a_bntrn2
bn.lid x2++, 0(x3)
la     x3, vec128b_bntrn2
bn.lid x2++, 0(x3)

bn.trn2.16H w10, w0, w1
bn.trn2.8S  w11, w2, w3
bn.trn2.4D  w12, w4, w5
bn.trn2.2Q  w13, w6, w7

/************************
 * BN.MULV and BN.MULVL *
 ************************/
addi x2, x0, 0
la     x3, vec32a0_bnmulv
bn.lid x2++, 0(x3)
la     x3, vec32b0_bnmulv
bn.lid x2++, 0(x3)

bn.mulv.8S   w11, w2, w3
bn.mulvl.8S  w13, w2, w3, 7

/************
 * BN.MULVM *
 ************/
addi x2, x0, 0
la     x3, vec32a0_bnmulvm
bn.lid x2++, 0(x3)
la     x3, vec32b0_bnmulvm
bn.lid x2++, 0(x3)
/* load the modulus into w20 and then into MOD*/
li           x2, 20
la           x3, mod32_bnmulvm
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.8S  w11, w2, w3

/*************
 * BN.MULVML *
 *************/
addi x2, x0, 0
la           x3, mod32_bnmulvml
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0
addi x2, x0, 0
la     x3, vec32a_bnmulvml
bn.lid x2++, 0(x3)
la     x3, vec32b_bnmulvml
bn.lid x2++, 0(x3)
bn.mulvml.8S  w18, w0, w1, 0
bn.mulvml.8S  w19, w0, w1, 1
bn.mulvml.8S  w20, w0, w1, 2
bn.mulvml.8S  w21, w0, w1, 3
bn.mulvml.8S  w22, w0, w1, 4
bn.mulvml.8S  w23, w0, w1, 5
bn.mulvml.8S  w24, w0, w1, 6
bn.mulvml.8S  w25, w0, w1, 7
ecall

.section .data
/*
  16bit vector vec16a for instruction addv
  vec16a = [-32768 -32768  32767  32767  32767 -32768  32767 -32768 -32768 -32768
  32767  32767  32767 -32768 -32768  32767]
  vec16a = 0x800080007fff7fff7fff80007fff8000800080007fff7fff7fff800080007fff
*/
vec16a_bnaddv:
  .word 0x80007fff
  .word 0x7fff8000
  .word 0x7fff7fff
  .word 0x80008000
  .word 0x7fff8000
  .word 0x7fff8000
  .word 0x7fff7fff
  .word 0x80008000

/*
  16bit vector vec16b for instruction addv
  vec16b = [  16  -16    1  -16    6  -16  564 -546  -32   -1   32    1    1   -1
   -1    1]
  vec16b = 0x0010fff00001fff00006fff00234fddeffe0ffff002000010001ffffffff0001
*/
vec16b_bnaddv:
  .word 0xffff0001
  .word 0x0001ffff
  .word 0x00200001
  .word 0xffe0ffff
  .word 0x0234fdde
  .word 0x0006fff0
  .word 0x0001fff0
  .word 0x0010fff0

/*
  Result of 16bit addv
  res = [-32752, 32752, -32768, 32751, -32763, 32752, -32205, 32222, 32736, 32767, -32737, -32768, -32768, 32767, 32767, -32768]
  res = 0x80107ff080007fef80057ff082337dde7fe07fff801f800080007fff7fff8000
*/

/*
  32bit vector vec32a for instruction addv
  vec32a = [-2147483648 -2147483648  2147483647  2147483647  2147483647 -2147483648
 -2147483648  2147483647]
  vec32a = 0x80000000800000007fffffff7fffffff7fffffff80000000800000007fffffff
*/
vec32a_bnaddv:
  .word 0x7fffffff
  .word 0x80000000
  .word 0x80000000
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x80000000
  .word 0x80000000

/*
  32bit vector vec32b for instruction addv
  vec32b = [-32  -1  32   1   1  -1  -1   1]
  vec32b = 0xffffffe0ffffffff000000200000000100000001ffffffffffffffff00000001
*/
vec32b_bnaddv:
  .word 0x00000001
  .word 0xffffffff
  .word 0xffffffff
  .word 0x00000001
  .word 0x00000001
  .word 0x00000020
  .word 0xffffffff
  .word 0xffffffe0

/*
  Result of 32bit addv
  res = [2147483616, 2147483647, -2147483617, -2147483648, -2147483648, 2147483647, 2147483647, -2147483648]
  res = 0x7fffffe07fffffff8000001f80000000800000007fffffff7fffffff80000000
*/

/*
  64bit vector vec64a for instruction addv
  vec64a = [ 9223372036854775807 -9223372036854775808 -9223372036854775808
  9223372036854775807]
  vec64a = 0x7fffffffffffffff800000000000000080000000000000007fffffffffffffff
*/
vec64a_bnaddv:
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x80000000
  .word 0x00000000
  .word 0x80000000
  .word 0xffffffff
  .word 0x7fffffff

/*
  64bit vector vec64b for instruction addv
  vec64b = [ 1 -1 -1  1]
  vec64b = 0x0000000000000001ffffffffffffffffffffffffffffffff0000000000000001
*/
vec64b_bnaddv:
  .word 0x00000001
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0x00000001
  .word 0x00000000

/*
  Result of 64bit addv
  res = [-9223372036854775808, 9223372036854775807, 9223372036854775807, -9223372036854775808]
  res = 0x80000000000000007fffffffffffffff7fffffffffffffff8000000000000000
*/

/*
  128bit vector vec128a for instruction addv
  vec128a = [-170141183460469231731687303715884105728
 170141183460469231731687303715884105727]
  vec128a = 0x800000000000000000000000000000007fffffffffffffffffffffffffffffff
*/
vec128a_bnaddv:
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x80000000

/*
  128bit vector vec128b for instruction addv
  vec128b = [-1  1]
  vec128b = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000001
*/
vec128b_bnaddv:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  Result of 128bit addv
  res = [170141183460469231731687303715884105727, -170141183460469231731687303715884105728]
  res = 0x7fffffffffffffffffffffffffffffff80000000000000000000000000000000
*/

/*
  16bit vector mod16 for instruction addvm
  mod16 = [7583]
  mod16 = 0x0000000000000000000000000000000000000000000000000000000000001d9f
*/
mod16:
  .word 0x00001d9f
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a0 for instruction addvm
  vec16a0 = [65535, 65535, 3791, 7582, 65535, 0, 3791, 7582, 65535, 65535, 3791, 7582, 65535, 65535, 3791, 7582]
  vec16a0 = 0xffffffff0ecf1d9effff00000ecf1d9effffffff0ecf1d9effffffff0ecf1d9e
*/
vec16a0_bnaddvm:
  .word 0x0ecf1d9e
  .word 0xffffffff
  .word 0x0ecf1d9e
  .word 0xffffffff
  .word 0x0ecf1d9e
  .word 0xffff0000
  .word 0x0ecf1d9e
  .word 0xffffffff

/*
  16bit vector vec16b0 for instruction addvm
  vec16b0 = [2024, 1, 2527, 7580, 2024, 32767, 2527, 7580, 2024, 1, 2527, 7580, 2024, 1, 2527, 7580]
  vec16b0 = 0x07e8000109df1d9c07e87fff09df1d9c07e8000109df1d9c07e8000109df1d9c
*/
vec16b0_bnaddvm:
  .word 0x09df1d9c
  .word 0x07e80001
  .word 0x09df1d9c
  .word 0x07e80001
  .word 0x09df1d9c
  .word 0x07e87fff
  .word 0x09df1d9c
  .word 0x07e80001

/*
  Result of 16bit addvm
  res = [59976, 57953, 6318, 7579, 59976, 25184, 6318, 7579, 59976, 57953, 6318, 7579, 59976, 57953, 6318, 7579]
  res = 0xea48e26118ae1d9bea48626018ae1d9bea48e26118ae1d9bea48e26118ae1d9b
*/

/*
  32bit vector mod32 for instruction addvm
  mod32 = [8380417]
  mod32 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod32:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a0 for instruction addvm
  vec32a0 = [4294967295, 4294967295, 4190208, 8380416, 4294967295, 0, 4190208, 8380416]
  vec32a0 = 0xffffffffffffffff003ff000007fe000ffffffff00000000003ff000007fe000
*/
vec32a0_bnaddvm:
  .word 0x007fe000
  .word 0x003ff000
  .word 0x00000000
  .word 0xffffffff
  .word 0x007fe000
  .word 0x003ff000
  .word 0xffffffff
  .word 0xffffffff

/*
  32bit vector vec32b0 for instruction addvm
  vec32b0 = [2024, 1, 2793472, 8380414, 2024, 2147483647, 2793472, 8380414]
  vec32b0 = 0x000007e800000001002aa000007fdffe000007e87fffffff002aa000007fdffe
*/
vec32b0_bnaddvm:
  .word 0x007fdffe
  .word 0x002aa000
  .word 0x7fffffff
  .word 0x000007e8
  .word 0x007fdffe
  .word 0x002aa000
  .word 0x00000001
  .word 0x000007e8

/*
  Result of 32bit addvm
  res = [4286588902, 4286586879, 6983680, 8380413, 4286588902, 2139103230, 6983680, 8380413]
  res = 0xff8027e6ff801fff006a9000007fdffdff8027e67f801ffe006a9000007fdffd
*/

/*
  64bit vector mod64 for instruction addvm
  mod64 = [8380417]
  mod64 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod64:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64a0 for instruction addvm
  vec64a0 = [18446744073709551615, 18446744073709551615, 4190208, 8380416]
  vec64a0 = 0xffffffffffffffffffffffffffffffff00000000003ff00000000000007fe000
*/
vec64a0_bnaddvm:
  .word 0x007fe000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  64bit vector vec64b0 for instruction addvm
  vec64b0 = [2024, 1, 2793472, 8380414]
  vec64b0 = 0x00000000000007e8000000000000000100000000002aa00000000000007fdffe
*/
vec64b0_bnaddvm:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x000007e8
  .word 0x00000000

/*
  Result of 64bit addvm
  res = [18446744073701173222, 18446744073701171199, 6983680, 8380413]
  res = 0xffffffffff8027e6ffffffffff801fff00000000006a900000000000007fdffd
*/

/*
  128bit vector mod128 for instruction addvm
  mod128 = [8380417]
  mod128 = 0x00000000000000000000000000000000000000000000000000000000007fe001
*/
mod128:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a0 for instruction addvm
  vec128a0 = [340282366920938463463374607431768211455, 340282366920938463463374607431768211455]
  vec128a0 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
*/
vec128a0_bnaddvm:
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff
  .word 0xffffffff

/*
  128bit vector vec128a1 for instruction addvm
  vec128a1 = [4190208, 8380416]
  vec128a1 = 0x000000000000000000000000003ff000000000000000000000000000007fe000
*/
vec128a1_bnaddvm:
  .word 0x007fe000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction addvm
  vec128b0 = [2024, 1]
  vec128b0 = 0x000000000000000000000000000007e800000000000000000000000000000001
*/
vec128b0_bnaddvm:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x000007e8
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction addvm
  vec128b1 = [2793472, 8380414]
  vec128b1 = 0x000000000000000000000000002aa000000000000000000000000000007fdffe
*/
vec128b1_bnaddvm:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit addvm
  res = [340282366920938463463374607431759833062, 340282366920938463463374607431759831039]
  res = 0xffffffffffffffffffffffffff8027e6ffffffffffffffffffffffffff801fff
*/

/*
  Result of 128bit addvm
  res = [6983680, 8380413]
  res = 0x000000000000000000000000006a9000000000000000000000000000007fdffd
*/

/*
  vector for instruction shv
  vec16orig = n/a
  vec16orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vecorig_bnshv:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 16bit shv left (res = [bitshift in decimals])
  res = [9]
  res = 0x2e0036005800ac004a009e00560000004a000c005e0004004c003400c000d600
*/
/*
  Result of 16bit shv right (res = [bitshift in decimals])
  res = [9]
  res = 0x00490013002800200067001c0053007b000600070012007f00530038001d0071
*/
/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [11]
  res = 0xb938d800620eb00029c678005fb40000287830007ff810003388d00007175800
*/
/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [30]
  res = 0x0000000200000001000000030000000200000000000000000000000200000000
*/
/*
  Result of 64bit shv left (res = [bitshift in decimals])
  res = [44]
  res = 0xc41d600000000000bf68000000000000fff02000000000000e2eb00000000000
*/
/*
  Result of 64bit shv right (res = [bitshift in decimals])
  res = [56]
  res = 0x000000000000009300000000000000cf000000000000000d00000000000000a6
*/
/*
  Result of 128bit shv left (res = [bitshift in decimals])
  res = [67]
  res = 0x7929c67d395fb4000000000000000000313388d1d30717580000000000000000
*/
/*
  Result of 128bit shv right (res = [bitshift in decimals])
  res = [120]
  res = 0x000000000000000000000000000000930000000000000000000000000000000d
*/

/*
  16bit vector vec16a0 for instruction subv
  vec16a0 = [0, 0, 32767, 32767, 0, 65535, 1684, 0, 0, 0, 65523, 65535, 0, 0, 32767, 65535]
  vec16a0 = 0x000000007fff7fff0000ffff0694000000000000fff3ffff000000007fffffff
*/
vec16a0_bnsubv:
  .word 0x7fffffff
  .word 0x00000000
  .word 0xfff3ffff
  .word 0x00000000
  .word 0x06940000
  .word 0x0000ffff
  .word 0x7fff7fff
  .word 0x00000000

/*
  16bit vector vec16b0 for instruction subv
  vec16b0 = [2048, 1, 32767, 0, 2048, 1, 437, 1, 2048, 1, 1568, 9362, 2048, 1, 32767, 12]
  vec16b0 = 0x080000017fff00000800000101b500010800000106202492080000017fff000c
*/
vec16b0_bnsubv:
  .word 0x7fff000c
  .word 0x08000001
  .word 0x06202492
  .word 0x08000001
  .word 0x01b50001
  .word 0x08000001
  .word 0x7fff0000
  .word 0x08000001

/*
  Result of 16bit subv
  res = [63488, 65535, 0, 32767, 63488, 65534, 1247, 65535, 63488, 65535, 63955, 56173, 63488, 65535, 0, 65523]
  res = 0xf800ffff00007ffff800fffe04dffffff800fffff9d3db6df800ffff0000fff3
*/

/*
  32bit vector vec32a0 for instruction subv
  vec32a0 = [0, 0, 2147483647, 2147483647, 0, 4294967295, 1684, 0]
  vec32a0 = 0x00000000000000007fffffff7fffffff00000000ffffffff0000069400000000
*/
vec32a0_bnsubv:
  .word 0x00000000
  .word 0x00000694
  .word 0xffffffff
  .word 0x00000000
  .word 0x7fffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction subv
  vec32b0 = [2048, 1, 2147483647, 0, 2048, 1, 437, 1]
  vec32b0 = 0x00000800000000017fffffff000000000000080000000001000001b500000001
*/
vec32b0_bnsubv:
  .word 0x00000001
  .word 0x000001b5
  .word 0x00000001
  .word 0x00000800
  .word 0x00000000
  .word 0x7fffffff
  .word 0x00000001
  .word 0x00000800

/*
  Result of 32bit subv
  res = [4294965248, 4294967295, 0, 2147483647, 4294965248, 4294967294, 1247, 4294967295]
  res = 0xfffff800ffffffff000000007ffffffffffff800fffffffe000004dfffffffff
*/

/*
  64bit vector vec64a0 for instruction subv
  vec64a0 = [0, 0, 9223372036854775807, 9223372036854775807]
  vec64a0 = 0x000000000000000000000000000000007fffffffffffffff7fffffffffffffff
*/
vec64a0_bnsubv:
  .word 0xffffffff
  .word 0x7fffffff
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction subv
  vec64b0 = [2048, 1, 9223372036854775807, 0]
  vec64b0 = 0x000000000000080000000000000000017fffffffffffffff0000000000000000
*/
vec64b0_bnsubv:
  .word 0x00000000
  .word 0x00000000
  .word 0xffffffff
  .word 0x7fffffff
  .word 0x00000001
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000

/*
  Result of 64bit subv
  res = [18446744073709549568, 18446744073709551615, 0, 9223372036854775807]
  res = 0xfffffffffffff800ffffffffffffffff00000000000000007fffffffffffffff
*/

/*
  128bit vector vec128a0 for instruction subv
  vec128a0 = [0, 0]
  vec128a0 = 0x0000000000000000000000000000000000000000000000000000000000000000
*/
vec128a0_bnsubv:
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction subv
  vec128b0 = [2048, 1]
  vec128b0 = 0x0000000000000000000000000000080000000000000000000000000000000001
*/
vec128b0_bnsubv:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit subv
  res = [340282366920938463463374607431768209408, 340282366920938463463374607431768211455]
  res = 0xfffffffffffffffffffffffffffff800ffffffffffffffffffffffffffffffff
*/

/*
  16bit vector vec16a0 for instruction subvm
  vec16a0 = [0, 0, 3791, 7580, 0, 65535, 3791, 7580, 0, 0, 3791, 7580, 0, 0, 3791, 7580]
  vec16a0 = 0x000000000ecf1d9c0000ffff0ecf1d9c000000000ecf1d9c000000000ecf1d9c
*/
vec16a0_bnsubvm:
  .word 0x0ecf1d9c
  .word 0x00000000
  .word 0x0ecf1d9c
  .word 0x00000000
  .word 0x0ecf1d9c
  .word 0x0000ffff
  .word 0x0ecf1d9c
  .word 0x00000000

/*
  16bit vector vec16b0 for instruction subvm
  vec16b0 = [2048, 1, 2527, 7582, 2048, 32767, 2527, 7582, 2048, 1, 2527, 7582, 2048, 1, 2527, 7582]
  vec16b0 = 0x0800000109df1d9e08007fff09df1d9e0800000109df1d9e0800000109df1d9e
*/
vec16b0_bnsubvm:
  .word 0x09df1d9e
  .word 0x08000001
  .word 0x09df1d9e
  .word 0x08000001
  .word 0x09df1d9e
  .word 0x08007fff
  .word 0x09df1d9e
  .word 0x08000001

/*
  Result of 16bit subvm
  res = [5535, 7582, 1264, 7581, 5535, 32768, 1264, 7581, 5535, 7582, 1264, 7581, 5535, 7582, 1264, 7581]
  res = 0x159f1d9e04f01d9d159f800004f01d9d159f1d9e04f01d9d159f1d9e04f01d9d
*/

/*
  32bit vector vec32a0 for instruction subvm
  vec32a0 = [0, 0, 4190208, 8380414, 0, 4294967295, 4190208, 8380414]
  vec32a0 = 0x0000000000000000003ff000007fdffe00000000ffffffff003ff000007fdffe
*/
vec32a0_bnsubvm:
  .word 0x007fdffe
  .word 0x003ff000
  .word 0xffffffff
  .word 0x00000000
  .word 0x007fdffe
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction subvm
  vec32b0 = [2048, 1, 2793472, 8380416, 2048, 2147483647, 2793472, 8380416]
  vec32b0 = 0x0000080000000001002aa000007fe000000008007fffffff002aa000007fe000
*/
vec32b0_bnsubvm:
  .word 0x007fe000
  .word 0x002aa000
  .word 0x7fffffff
  .word 0x00000800
  .word 0x007fe000
  .word 0x002aa000
  .word 0x00000001
  .word 0x00000800

/*
  Result of 32bit subvm
  res = [8378369, 8380416, 1396736, 8380415, 8378369, 2147483648, 1396736, 8380415]
  res = 0x007fd801007fe00000155000007fdfff007fd8018000000000155000007fdfff
*/

/*
  64bit vector vec64a0 for instruction subvm
  vec64a0 = [0, 0, 4190208, 8380414]
  vec64a0 = 0x0000000000000000000000000000000000000000003ff00000000000007fdffe
*/
vec64a0_bnsubvm:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction subvm
  vec64b0 = [2048, 1, 2793472, 8380416]
  vec64b0 = 0x0000000000000800000000000000000100000000002aa00000000000007fe000
*/
vec64b0_bnsubvm:
  .word 0x007fe000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000

/*
  Result of 64bit subvm
  res = [8378369, 8380416, 1396736, 8380415]
  res = 0x00000000007fd80100000000007fe000000000000015500000000000007fdfff
*/

/*
  128bit vector vec128a0 for instruction subvm
  vec128a0 = [0, 0]
  vec128a0 = 0x0000000000000000000000000000000000000000000000000000000000000000
*/
vec128a0_bnsubvm:
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a1 for instruction subvm
  vec128a1 = [4190208, 8380414]
  vec128a1 = 0x000000000000000000000000003ff000000000000000000000000000007fdffe
*/
vec128a1_bnsubvm:
  .word 0x007fdffe
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x003ff000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction subvm
  vec128b0 = [2048, 1]
  vec128b0 = 0x0000000000000000000000000000080000000000000000000000000000000001
*/
vec128b0_bnsubvm:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000800
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction subvm
  vec128b1 = [2793472, 8380416]
  vec128b1 = 0x000000000000000000000000002aa000000000000000000000000000007fe000
*/
vec128b1_bnsubvm:
  .word 0x007fe000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x002aa000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit subvm
  res = [8378369, 8380416]
  res = 0x000000000000000000000000007fd801000000000000000000000000007fe000
*/

/*
  Result of 128bit subvm
  res = [1396736, 8380415]
  res = 0x00000000000000000000000000155000000000000000000000000000007fdfff
*/

/*
  16bit vector vec16a for instruction trn1
  vec16a = n/a
  vec16a = 0x21caff82bc486be36aaecc11ccdd1e5621164f9c456fec1611a7c626ee821bdb
*/
vec16a_bntrn1:
  .word 0xee821bdb
  .word 0x11a7c626
  .word 0x456fec16
  .word 0x21164f9c
  .word 0xccdd1e56
  .word 0x6aaecc11
  .word 0xbc486be3
  .word 0x21caff82

/*
  16bit vector vec16b for instruction trn1
  vec16b = n/a
  vec16b = 0x489bc5561f6b6e6b99c19e9f26795d6dbd9a16d9ff11c45542568d446c0130d1
*/
vec16b_bntrn1:
  .word 0x6c0130d1
  .word 0x42568d44
  .word 0xff11c455
  .word 0xbd9a16d9
  .word 0x26795d6d
  .word 0x99c19e9f
  .word 0x1f6b6e6b
  .word 0x489bc556

/*
  Result of 16bit trn1
  res = n/a
  res = 0xc556ff826e6b6be39e9fcc115d6d1e5616d94f9cc455ec168d44c62630d11bdb
*/

/*
  32bit vector vec32a for instruction trn1
  vec32a = n/a
  vec32a = 0x21caff82bc486be36aaecc11ccdd1e5621164f9c456fec1611a7c626ee821bdb
*/
vec32a_bntrn1:
  .word 0xee821bdb
  .word 0x11a7c626
  .word 0x456fec16
  .word 0x21164f9c
  .word 0xccdd1e56
  .word 0x6aaecc11
  .word 0xbc486be3
  .word 0x21caff82

/*
  32bit vector vec32b for instruction trn1
  vec32b = n/a
  vec32b = 0x489bc5561f6b6e6b99c19e9f26795d6dbd9a16d9ff11c45542568d446c0130d1
*/
vec32b_bntrn1:
  .word 0x6c0130d1
  .word 0x42568d44
  .word 0xff11c455
  .word 0xbd9a16d9
  .word 0x26795d6d
  .word 0x99c19e9f
  .word 0x1f6b6e6b
  .word 0x489bc556

/*
  Result of 32bit trn1
  res = n/a
  res = 0x1f6b6e6bbc486be326795d6dccdd1e56ff11c455456fec166c0130d1ee821bdb
*/

/*
  64bit vector vec64a for instruction trn1
  vec64a = n/a
  vec64a = 0x21caff82bc486be36aaecc11ccdd1e5621164f9c456fec1611a7c626ee821bdb
*/
vec64a_bntrn1:
  .word 0xee821bdb
  .word 0x11a7c626
  .word 0x456fec16
  .word 0x21164f9c
  .word 0xccdd1e56
  .word 0x6aaecc11
  .word 0xbc486be3
  .word 0x21caff82

/*
  64bit vector vec64b for instruction trn1
  vec64b = n/a
  vec64b = 0x489bc5561f6b6e6b99c19e9f26795d6dbd9a16d9ff11c45542568d446c0130d1
*/
vec64b_bntrn1:
  .word 0x6c0130d1
  .word 0x42568d44
  .word 0xff11c455
  .word 0xbd9a16d9
  .word 0x26795d6d
  .word 0x99c19e9f
  .word 0x1f6b6e6b
  .word 0x489bc556

/*
  Result of 64bit trn1
  res = n/a
  res = 0x99c19e9f26795d6d6aaecc11ccdd1e5642568d446c0130d111a7c626ee821bdb
*/

/*
  128bit vector vec128a for instruction trn1
  vec128a = n/a
  vec128a = 0x21caff82bc486be36aaecc11ccdd1e5621164f9c456fec1611a7c626ee821bdb
*/
vec128a_bntrn1:
  .word 0xee821bdb
  .word 0x11a7c626
  .word 0x456fec16
  .word 0x21164f9c
  .word 0xccdd1e56
  .word 0x6aaecc11
  .word 0xbc486be3
  .word 0x21caff82

/*
  128bit vector vec128b for instruction trn1
  vec128b = n/a
  vec128b = 0x489bc5561f6b6e6b99c19e9f26795d6dbd9a16d9ff11c45542568d446c0130d1
*/
vec128b_bntrn1:
  .word 0x6c0130d1
  .word 0x42568d44
  .word 0xff11c455
  .word 0xbd9a16d9
  .word 0x26795d6d
  .word 0x99c19e9f
  .word 0x1f6b6e6b
  .word 0x489bc556

/*
  Result of 128bit trn1
  res = n/a
  res = 0xbd9a16d9ff11c45542568d446c0130d121164f9c456fec1611a7c626ee821bdb
*/

/*
  16bit vector vec16a for instruction trn2
  vec16a = n/a
  vec16a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec16a_bntrn2:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  16bit vector vec16b for instruction trn2
  vec16b = n/a
  vec16b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec16b_bntrn2:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 16bit trn2
  res = n/a
  res = 0x0100100003000030000100109000009050000005700007000050050000300003
*/

/*
  32bit vector vec32a for instruction trn2
  vec32a = n/a
  vec32a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec32a_bntrn2:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  32bit vector vec32b for instruction trn2
  vec32b = n/a
  vec32b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec32b_bntrn2:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 32bit trn2
  res = n/a
  res = 0x0100a0001000000a000100800010000850000800000500080050004005000004
*/

/*
  64bit vector vec64a for instruction trn2
  vec64a = n/a
  vec64a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec64a_bntrn2:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  64bit vector vec64b for instruction trn2
  vec64b = n/a
  vec64b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec64b_bntrn2:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 64bit trn2
  res = n/a
  res = 0x0100a000030000801000000a0030000850000800700000400005000807000004
*/

/*
  128bit vector vec128a for instruction trn2
  vec128a = n/a
  vec128a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec128a_bntrn2:
  .word 0x00030002
  .word 0x05000004
  .word 0x07000004
  .word 0x00050008
  .word 0x00900006
  .word 0x00100008
  .word 0x00300008
  .word 0x1000000a

/*
  128bit vector vec128b for instruction trn2
  vec128b = n/a
  vec128b = 0x0100a00003000080000100809000060050000800700000400050004000300020
*/
vec128b_bntrn2:
  .word 0x00300020
  .word 0x00500040
  .word 0x70000040
  .word 0x50000800
  .word 0x90000600
  .word 0x00010080
  .word 0x03000080
  .word 0x0100a000

/*
  Result of 128bit trn2
  res = n/a
  res = 0x0100a0000300008000010080900006001000000a003000080010000800900006
*/

/*
  16bit vector vec16a0 for instruction mulv
  vec16a0 = [0, 1, 34, 58, 157, 23, 221, 159, 148, 62, 33, 129, 15, 158, 36, 137]
  vec16a0 = 0x000000010022003a009d001700dd009f0094003e00210081000f009e00240089
*/
vec16a0_bnmulv:
  .word 0x00240089
  .word 0x000f009e
  .word 0x00210081
  .word 0x0094003e
  .word 0x00dd009f
  .word 0x009d0017
  .word 0x0022003a
  .word 0x00000001

/*
  16bit vector vec16b0 for instruction mulv
  vec16b0 = [63206, 58121, 923, 588, 208, 223, 204, 180, 10, 1, 100, 192, 42, 161, 92, 47]
  vec16b0 = 0xf6e6e309039b024c00d000df00cc00b4000a0001006400c0002a00a1005c002f
*/
vec16b0_bnmulv:
  .word 0x005c002f
  .word 0x002a00a1
  .word 0x006400c0
  .word 0x000a0001
  .word 0x00cc00b4
  .word 0x00d000df
  .word 0x039b024c
  .word 0xf6e6e309

/*
  Result of 16bit mulv
  res = [0, 58121, 31382, 34104, 32656, 5129, 45084, 28620, 1480, 62, 3300, 24768, 630, 25438, 3312, 6439]
  res = 0x0000e3097a9685387f901409b01c6fcc05c8003e0ce460c00276635e0cf01927
*/

/*
  32bit vector vec32a0 for instruction mulv
  vec32a0 = [0, 1, 44913, 9734, 23276, 65251, 13010, 40903]
  vec32a0 = 0x00000000000000010000af710000260600005aec0000fee3000032d200009fc7
*/
vec32a0_bnmulv:
  .word 0x00009fc7
  .word 0x000032d2
  .word 0x0000fee3
  .word 0x00005aec
  .word 0x00002606
  .word 0x0000af71
  .word 0x00000001
  .word 0x00000000

/*
  32bit vector vec32b0 for instruction mulv
  vec32b0 = [4140082361, 1869666356, 636760, 207841, 59661, 52504, 947, 30691]
  vec32b0 = 0xf6c4a4b96f70d8340009b75800032be10000e90d0000cd18000003b3000077e3
*/
vec32b0_bnmulv:
  .word 0x000077e3
  .word 0x000003b3
  .word 0x0000cd18
  .word 0x0000e90d
  .word 0x00032be1
  .word 0x0009b758
  .word 0x6f70d834
  .word 0xf6c4a4b9

/*
  Result of 32bit mulv
  res = [0, 1869666356, 2828998104, 2023124294, 1388669436, 3425938504, 12320470, 1255353973]
  res = 0x000000006f70d834a89f15d878966d4652c569fccc33ac4800bbfed64ad32e75
*/

/*
  16bit vector mod16 for instruction mulvm. Combined [R, q]
  mod16 = [16801, 7583]
  mod16 = 0x000000000000000000000000000000000000000000000000000041a100001d9f
*/
mod16_bnmulvm:
  .word 0x00001d9f
  .word 0x000041a1
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a0 for instruction mulvm
  vec16a0 = [74, 4067, 3784, 5909, 314, 6006, 839, 3194, 6718, 3314, 6912, 734, 4636, 5106, 4760, 6536]
  vec16a0 = 0x004a0fe30ec81715013a177603470c7a1a3e0cf21b0002de121c13f212981988
*/
vec16a0_bnmulvm:
  .word 0x12981988
  .word 0x121c13f2
  .word 0x1b0002de
  .word 0x1a3e0cf2
  .word 0x03470c7a
  .word 0x013a1776
  .word 0x0ec81715
  .word 0x004a0fe3

/*
  16bit vector vec16b0 for instruction mulvm
  vec16b0 = [3603, 1967, 4388, 2100, 909, 457, 6860, 7308, 3102, 6214, 4357, 7324, 5348, 5501, 1850, 4385]
  vec16b0 = 0x0e1307af11240834038d01c91acc1c8c0c1e184611051c9c14e4157d073a1121
*/
vec16b0_bnmulvm:
  .word 0x073a1121
  .word 0x14e4157d
  .word 0x11051c9c
  .word 0x0c1e1846
  .word 0x1acc1c8c
  .word 0x038d01c9
  .word 0x11240834
  .word 0x0e1307af

/*
  Result of 16bit mulvm
  res = [7535, 1849, 731, 6077, 4868, 498, 179, 4791, 2503, 6051, 7302, 6607, 6745, 5980, 6427, 3741]
  res = 0x1d6f073902db17bd130401f200b312b709c717a31c8619cf1a59175c191b0e9d
*/

/*
  Result of 16bit mulvm without conditional subtraction
  res = [7535, 1849, 731, 6077, 4868, 498, 179, 4791, 2503, 6051, 7302, 6607, 6745, 5980, 6427, 3741]
  res = 0x1d6f073902db17bd130401f200b312b709c717a31c8619cf1a59175c191b0e9d
*/


/*
  32bit vector mod32 for instruction mulvm. Combined [R, q]
  mod32 = [4236238847, 8380417]
  mod32 = 0x000000000000000000000000000000000000000000000000fc7fdfff007fe001
*/
mod32_bnmulvm:
  .word 0x007fe001
  .word 0xfc7fdfff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a0 for instruction mulvm
  vec32a0 = [140140, 2179652, 4415585, 3591344, 6089560, 5367875, 2289882, 4817594]
  vec32a0 = 0x0002236c00214244004360610036ccb0005ceb580051e8430022f0da004982ba
*/
vec32a0_bnmulvm:
  .word 0x004982ba
  .word 0x0022f0da
  .word 0x0051e843
  .word 0x005ceb58
  .word 0x0036ccb0
  .word 0x00436061
  .word 0x00214244
  .word 0x0002236c

/*
  32bit vector vec32b0 for instruction mulvm
  vec32b0 = [7268407, 3661137, 7621524, 6778366, 6274350, 2059156, 3886783, 2027657]
  vec32b0 = 0x006ee8370037dd5100744b9400676dfe005fbd2e001f6b94003b4ebf001ef089
*/
vec32b0_bnmulvm:
  .word 0x001ef089
  .word 0x003b4ebf
  .word 0x001f6b94
  .word 0x005fbd2e
  .word 0x00676dfe
  .word 0x00744b94
  .word 0x0037dd51
  .word 0x006ee837

/*
  Result of 32bit mulvm
  res = [1620927, 7309254, 1234587, 1342470, 3140778, 8169851, 1752570, 480708]
  res = 0x0018bbbf006f87c60012d69b00147c06002fecaa007ca97b001abdfa000755c4
*/

/*
  Result of 32bit mulvm without conditional subtraction
  res = [1620927, 7309254, 1234587, 1342470, 3140778, 8169851, 1752570, 480708]
  res = 0x0018bbbf006f87c60012d69b00147c06002fecaa007ca97b001abdfa000755c4
*/

/*
  16bit vector mod16 for instruction mulvml. Combined [R, q]
  mod16 = [16801, 7583]
  mod16 = 0x000000000000000000000000000000000000000000000000000041a100001d9f
*/
mod16_bnmulvml:
  .word 0x00001d9f
  .word 0x000041a1
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a for instruction mulvlm
  vec16a = [3112, 1175, 5700, 1065, 2288, 2734, 4377, 3511, 2799, 3372, 6575, 5433, 1061, 6708, 4622, 631]
  vec16a = 0x0c2804971644042908f00aae11190db70aef0d2c19af153904251a34120e0277
*/
vec16a_bnmulvml:
  .word 0x120e0277
  .word 0x04251a34
  .word 0x19af1539
  .word 0x0aef0d2c
  .word 0x11190db7
  .word 0x08f00aae
  .word 0x16440429
  .word 0x0c280497

/*
  16bit vector vec16b for instruction mulvlm
  vec16b = [5896, 2974, 3532, 7345, 4227, 6159, 6439, 5196, 7398, 4938, 3163, 1023, 6077, 3487, 184, 3476]
  vec16b = 0x17080b9e0dcc1cb11083180f1927144c1ce6134a0c5b03ff17bd0d9f00b80d94
*/
vec16b_bnmulvml:
  .word 0x00b80d94
  .word 0x17bd0d9f
  .word 0x0c5b03ff
  .word 0x1ce6134a
  .word 0x1927144c
  .word 0x1083180f
  .word 0x0dcc1cb1
  .word 0x17080b9e

/*
  Result of 16bit mulvlm index 0
  res = [4997, 471, 5673, 1040, 6364, 1851, 2245, 4105, 6685, 1584, 4249, 2849, 5059, 1424, 633, 1079]
  res = 0x138501d71629041018dc073b08c510091a1d063010990b2113c3059002790437

  Result of 16bit mulvlm index 1
  res = [3467, 5025, 3241, 6652, 5590, 6852, 3714, 4528, 31, 6515, 6499, 6294, 1472, 4325, 2503, 5764]
  res = 0x0d8b13a10ca919fc15d61ac40e8211b0001f19731963189605c010e509c71684

  Result of 16bit mulvlm index 2
  res = [3597, 4192, 5331, 3251, 7440, 777, 3044, 4046, 299, 1685, 7646, 2978, 5147, 5268, 659, 4226]
  res = 0x0e0d106014d30cb31d1003090be40fce012b06951dde0ba2141b149402931082

  Result of 16bit mulvlm index 3
  res = [719, 7584, 3393, 614, 899, 2274, 5044, 1184, 7082, 4785, 1619, 3709, 3118, 1774, 3334, 6893]
  res = 0x02cf1da00d410266038308e213b404a01baa12b106530e7d0c2e06ee0d061aed

  Result of 16bit mulvlm index 4
  res = [6294, 4818, 6109, 882, 1489, 6280, 6060, 2096, 5159, 1810, 5018, 4414, 601, 1091, 2418, 4517]
  res = 0x189612d217dd037205d1188817ac083014270712139a113e02590443097211a5

  Result of 16bit mulvlm index 5
  res = [6229, 1443, 5064, 6374, 564, 5526, 6395, 2337, 5025, 4225, 653, 6072, 2555, 4411, 3340, 5286]
  res = 0x185505a313c818e60234159618fb092113a11081028d17b809fb113b0d0c14a6

  Result of 16bit mulvlm index 6
  res = [2295, 752, 3648, 6748, 1161, 3873, 1588, 3157, 2398, 3978, 4208, 6207, 1589, 7023, 4778, 4347]
  res = 0x08f702f00e401a5c04890f2106340c55095e0f8a1070183f06351b6f12aa10fb

  Result of 16bit mulvlm index 7
  res = [5622, 841, 2305, 730, 5342, 1518, 3107, 2371, 3307, 5195, 4222, 2656, 6103, 5666, 5767, 3601]
  res = 0x15f60349090102da14de05ee0c2309430ceb144b107e0a6017d7162216870e11

  Result of 16bit mulvlm index 8
  res = [480, 3924, 5967, 5525, 1581, 5568, 1026, 5220, 5656, 832, 5985, 2339, 3653, 7565, 1941, 7154]
  res = 0x01e00f54174f1595062d15c00402146416180340176109230e451d8d07951bf2

  Result of 16bit mulvlm index 9
  res = [1523, 7332, 5236, 5129, 1841, 5534, 7900, 6136, 4423, 4662, 3113, 1750, 6014, 2123, 4879, 6364]
  res = 0x05f31ca4147414090731159e1edc17f8114712360c2906d6177e084b130f18dc

  Result of 16bit mulvlm index 10
  res = [6138, 4301, 3601, 1930, 6852, 5987, 6864, 4191, 6354, 7606, 2125, 5360, 3774, 1476, 7664, 4846]
  res = 0x17fa10cd0e11078a1ac417631ad0105f18d21db6084d14f00ebe05c41df012ee

  Result of 16bit mulvlm index 11
  res = [3858, 828, 3694, 331, 1238, 2288, 5782, 2145, 2237, 3654, 5924, 7520, 3484, 5353, 340, 4988]
  res = 0x0f12033c0e6e014b04d608f01696086108bd0e4617241d600d9c14e90154137c

  Result of 16bit mulvlm index 12
  res = [2027, 836, 8089, 5243, 847, 5314, 636, 4034, 5812, 4019, 3710, 6860, 5679, 4379, 4263, 7051]
  res = 0x07eb03441f99147b034f14c2027c0fc216b40fb30e7e1acc162f111b10a71b8b

  Result of 16bit mulvlm index 13
  res = [4074, 5627, 6000, 4713, 812, 3277, 7002, 4494, 1749, 5545, 2930, 2127, 5507, 3070, 7659, 7449]
  res = 0x0fea15fb17701269032c0ccd1b5a118e06d515a90b72084f15830bfe1deb1d19

  Result of 16bit mulvlm index 14
  res = [2709, 2999, 6804, 6300, 4136, 2609, 6454, 1972, 6518, 3179, 2261, 6613, 1043, 4543, 4272, 849]
  res = 0x0a950bb71a94189c10280a31193607b419760c6b08d519d5041311bf10b00351

  Result of 16bit mulvlm index 15
  res = [317, 127, 6263, 2148, 428, 644, 3616, 6291, 4620, 1055, 872, 897, 1670, 5391, 6353, 3366]
  res = 0x013d007f1877086401ac02840e201893120c041f036803810686150f18d10d26
*/

/*
  32bit vector mod32 for instruction mulvml. Combined [R, q]
  mod32 = [4236238847, 8380417]
  mod32 = 0x000000000000000000000000000000000000000000000000fc7fdfff007fe001
*/
mod32_bnmulvml:
  .word 0x007fe001
  .word 0xfc7fdfff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a for instruction mulvlm
  vec32a = [4386494, 351607, 6259716, 5199533, 2908764, 4819738, 3847752, 1371499]
  vec32a = 0x0042eebe00055d77005f8404004f56ad002c625c00498b1a003ab6480014ed6b
*/
vec32a_bnmulvml:
  .word 0x0014ed6b
  .word 0x003ab648
  .word 0x00498b1a
  .word 0x002c625c
  .word 0x004f56ad
  .word 0x005f8404
  .word 0x00055d77
  .word 0x0042eebe

/*
  32bit vector vec32b for instruction mulvlm
  vec32b = [5579227, 5963489, 3458491, 7380290, 3431077, 8342412, 2134462, 7944091]
  vec32b = 0x005521db005afee10034c5bb00709d4200345aa5007f4b8c002091be0079379b
*/
vec32b_bnmulvml:
  .word 0x0079379b
  .word 0x002091be
  .word 0x007f4b8c
  .word 0x00345aa5
  .word 0x00709d42
  .word 0x0034c5bb
  .word 0x005afee1
  .word 0x005521db
/*
  Result of 32bit mulvlm index 0
  res = [515442, 718185, 5498530, 8237924, 2044754, 1726077, 6572625, 3330118]
  res = 0x0007dd72000af5690053e6a2007db364001f3352001a567d00644a510032d046

  Result of 32bit mulvlm index 1
  res = [5419054, 1425467, 3766569, 6818953, 4725646, 2800241, 4192112, 6140848]
  res = 0x0052b02e0015c03b0039792900680c8900481b8e002aba71003ff770005db3b0

  Result of 32bit mulvlm index 2
  res = [3018797, 4432770, 8337926, 4779507, 5619268, 5774263, 722707, 754865]
  res = 0x002e102d0043a382007f3a060048edf30055be4400581bb7000b0713000b84b1

  Result of 32bit mulvlm index 3
  res = [7198082, 4470350, 1294493, 652760, 6695655, 6942087, 1374687, 3415932]
  res = 0x006dd5820044364e0013c09d0009f5d800662ae70069ed870014f9df00341f7c

  Result of 32bit mulvlm index 4
  res = [4028494, 3561434, 1255813, 1531198, 1806146, 7587267, 4810729, 2052119]
  res = 0x003d784e003657da0013298500175d3e001b8f420073c5c3004967e9001f5017

  Result of 32bit mulvlm index 5
  res = [3946449, 1256339, 5192417, 7420002, 7942467, 4331764, 4009735, 7997143]
  res = 0x003c37d100132b93004f3ae10071386200793143004218f4003d2f07007a06d7

  Result of 32bit mulvlm index 6
  res = [7645843, 696628, 2618429, 6339788, 59635, 120462, 2282714, 5805869]
  res = 0x0074aa93000aa1340027f43d0060bccc0000e8f30001d68e0022d4da0058972d

  Result of 32bit mulvlm index 7
  res = [1268083, 1404023, 6310330, 5756485, 6378028, 3750173, 8235518, 7687323]
  res = 0x0013597300156c77006049ba0057d6450061522c0039391d007da9fe00754c9b
*/
