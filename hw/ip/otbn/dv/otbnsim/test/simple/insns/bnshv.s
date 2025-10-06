/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start

addi x2, x0, 8

/* 32bit left */
la     x3, vec32orig
bn.lid x2++, 0(x3)
bn.shv.8S w8, w8 << 11
bn.lid x2++, 0(x3)
bn.shv.8S w9, w9 << 22
bn.lid x2++, 0(x3)
bn.shv.8S w10, w10 << 3
bn.lid x2++, 0(x3)
bn.shv.8S w11, w11 << 19
bn.lid x2++, 0(x3)

/* 32bit right */
bn.shv.8S w12, w12 >> 5
bn.lid x2++, 0(x3)
bn.shv.8S w13, w13 >> 30
bn.lid x2++, 0(x3)
bn.shv.8S w14, w14 >> 3
bn.lid x2++, 0(x3)
bn.shv.8S w15, w15 >> 16

ecall

.section .data
/*
  32bit vector vec32orig for instruction shv
  vec32orig = n/a
  vec32orig = 0x9397271b502c41d6cf2538cfa72bf6800d250f06252fff02a626711a3a60e2eb
*/
vec32orig:
  .word 0x3a60e2eb
  .word 0xa626711a
  .word 0x252fff02
  .word 0x0d250f06
  .word 0xa72bf680
  .word 0xcf2538cf
  .word 0x502c41d6
  .word 0x9397271b

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [11]
  res = 0xb938d800620eb00029c678005fb40000287830007ff810003388d00007175800
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [22]
  res = 0xc6c000007580000033c00000a0000000c1800000c080000046800000bac00000
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [3]
  res = 0x9cb938d881620eb07929c678395fb40069287830297ff810313388d0d3071758
*/

/*
  Result of 32bit shv left (res = [bitshift in decimals])
  res = [19]
  res = 0x38d800000eb00000c6780000b400000078300000f810000088d0000017580000
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [5]
  res = 0x049cb9380281620e067929c605395fb40069287801297ff80531338801d30717
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [30]
  res = 0x0000000200000001000000030000000200000000000000000000000200000000
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [3]
  res = 0x1272e4e30a05883a19e4a71914e57ed001a4a1e004a5ffe014c4ce23074c1c5d
*/

/*
  Result of 32bit shv right (res = [bitshift in decimals])
  res = [16]
  res = 0x000093970000502c0000cf250000a72b00000d250000252f0000a62600003a60
*/
