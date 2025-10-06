/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors
*/
addi x2, x0, 2

la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)

bn.trn1.8S  w11, w2, w3

ecall

.section .data
/*
  32bit vector vec32a for instruction trn1
  vec32a = n/a
  vec32a = 0x21caff82bc486be36aaecc11ccdd1e5621164f9c456fec1611a7c626ee821bdb
*/
vec32a:
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
vec32b:
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
