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
  Results are stored in WDRS:
  16b:  w10 --> reserved, not implemented
  32b:  w11
  64b:  w12 --> reserved, not implemented
  128b: w13 --> reserved, not implemented
*/

/* load the modulus into w20 and then into MOD */
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20

bn.subvm.8S  w11, w2, w3

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  32bit vector mod32 for instruction subvm
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
  32bit vector vec32a0 for instruction subvm
  vec32a0 = [0, 0, 4190208, 8380414, 0, 4294967295, 4190208, 8380414]
  vec32a0 = 0x0000000000000000003ff000007fdffe00000000ffffffff003ff000007fdffe
*/
vec32a0:
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
vec32b0:
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
