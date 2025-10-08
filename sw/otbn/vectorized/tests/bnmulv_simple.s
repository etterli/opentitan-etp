/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
*/
addi x2, x0, 0

la     x3, vec16a0
bn.lid x2++, 0(x3)
la     x3, vec16b0
bn.lid x2++, 0(x3)

la     x3, vec32a0
bn.lid x2++, 0(x3)
la     x3, vec32b0
bn.lid x2++, 0(x3)

bn.mulv.16H  w10, w0, w1
bn.mulv.8S   w11, w2, w3
bn.mulvl.16H w12, w0, w1, 15
bn.mulvl.8S  w13, w2, w3, 7

ecall

.section .data
/*
  16bit vector vec16a0 for instruction mulv
  vec16a0 = [0, 1, 34, 58, 157, 23, 221, 159, 148, 62, 33, 129, 15, 158, 36, 137]
  vec16a0 = 0x000000010022003a009d001700dd009f0094003e00210081000f009e00240089
*/
vec16a0:
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
vec16b0:
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
vec32a0:
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
vec32b0:
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
