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
