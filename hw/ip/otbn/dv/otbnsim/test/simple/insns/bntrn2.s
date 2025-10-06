/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
*/
addi x2, x0, 2

la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)

bn.trn2.8S  w11, w2, w3

ecall

.section .data
/*
  32bit vector vec32a for instruction trn2
  vec32a = n/a
  vec32a = 0x1000000a00300008001000080090000600050008070000040500000400030002
*/
vec32a:
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
vec32b:
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
