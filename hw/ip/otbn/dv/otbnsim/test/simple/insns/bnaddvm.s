/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors
*/
addi x2, x0, 2

la     x3, vec32a0
bn.lid x2++, 0(x3)
la     x3, vec32b0
bn.lid x2++, 0(x3)

/*
  Results are stored in WDRs:
  16b:  w10 --> reserved, not implemented
  32b:  w11
  64b:  w12 --> reserved, not implemented
  128b: w13 --> reserved, not implemented
*/

li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.addvm.8S  w11, w2, w3

addi x2, x0, 0 /* reset x2 */
addi x3, x0, 0 /* reset x3 */

ecall

.section .data
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
vec32a0:
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
vec32b0:
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
