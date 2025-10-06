/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  check that all ELENs work as expected
  16bit  .16H --> reserved, not implemented
  32bit  .8S
  64bit  .4D --> reserved, not implemented
  128bit .2Q --> reserved, not implemented
*/

/*
  Load the vectors
*/
addi x2, x0, 2

la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)

addi x2, x0, 0 /* reset x2 */
addi x3, x0, 0 /* reset x3 */

bn.addv.8S  w11, w2, w3

ecall

.section .data
/*
  32bit vector vec32a for instruction addv
  vec32a = [-2147483648 -2147483648  2147483647  2147483647  2147483647 -2147483648
 -2147483648  2147483647]
  vec32a = 0x80000000800000007fffffff7fffffff7fffffff80000000800000007fffffff
*/
vec32a:
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
vec32b:
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
