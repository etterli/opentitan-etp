/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/********************************
 * BN.SHV - Only each ELEN once *
 ********************************/
addi x2, x0, 0

la     x3, vecorig_bnshv
bn.lid x2, 0(x3)

bn.shv.16H w1, w0 << 9
bn.shv.16H w2, w0 >> 9
bn.shv.8S  w3, w0 << 11
bn.shv.8S  w4, w0 >> 30
bn.shv.4D  w5, w0 << 44
bn.shv.4D  w6, w0 >> 56
bn.shv.2Q  w7, w0 << 67
bn.shv.2Q  w8, w0 >> 120

ecall

.section .data
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