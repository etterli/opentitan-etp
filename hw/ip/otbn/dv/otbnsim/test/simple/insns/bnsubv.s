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

bn.subv.8S  w11, w2, w3

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  32bit vector vec32a0 for instruction subv
  vec32a0 = [0, 0, 2147483647, 2147483647, 0, 4294967295, 1684, 0]
  vec32a0 = 0x00000000000000007fffffff7fffffff00000000ffffffff0000069400000000
*/
vec32a0:
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
vec32b0:
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
