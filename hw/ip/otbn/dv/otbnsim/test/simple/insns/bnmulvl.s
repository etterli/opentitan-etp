/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Testing each lane results in 30 results.
  Thus only load one datatype at a time into w0 and w1
  Results are ordered (increasing lane):
  16b:  w2 to w17 --> reserved, not implemented
  32b:  w18 to w25
  64b:  w26 to w29 --> reserved, not implemented
  128b: w30 and w31 --> reserved, not implemented
*/

addi x2, x0, 0
la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)
bn.mulvl.8S  w18, w0, w1, 0
bn.mulvl.8S  w19, w0, w1, 1
bn.mulvl.8S  w20, w0, w1, 2
bn.mulvl.8S  w21, w0, w1, 3
bn.mulvl.8S  w22, w0, w1, 4
bn.mulvl.8S  w23, w0, w1, 5
bn.mulvl.8S  w24, w0, w1, 6
bn.mulvl.8S  w25, w0, w1, 7

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  32bit vector vec32a for instruction mulvl
  vec32a = [0, 1, 44913, 9734, 23276, 65251, 13010, 40903]
  vec32a = 0x00000000000000010000af710000260600005aec0000fee3000032d200009fc7
*/
vec32a:
  .word 0x00009fc7
  .word 0x000032d2
  .word 0x0000fee3
  .word 0x00005aec
  .word 0x00002606
  .word 0x0000af71
  .word 0x00000001
  .word 0x00000000

/*
  32bit vector vec32b for instruction mulvl
  vec32b = [4140082361, 1869666356, 636760, 207841, 59661, 52504, 947, 30691]
  vec32b = 0xf6c4a4b96f70d8340009b75800032be10000e90d0000cd18000003b3000077e3
*/
vec32b:
  .word 0x000077e3
  .word 0x000003b3
  .word 0x0000cd18
  .word 0x0000e90d
  .word 0x00032be1
  .word 0x0009b758
  .word 0x6f70d834
  .word 0xf6c4a4b9

/*
  Result of 32bit mulvl index 0
  res = [0, 30691, 1378424883, 298746194, 714363716, 2002618441, 399289910, 1255353973]
  res = 0x00000000000077e35229183311ce81522a945344775d884917ccae364ad32e75
*/

/*
  Result of 32bit mulvl index 1
  res = [0, 947, 42532611, 9218098, 22042372, 61792697, 12320470, 38735141]
  res = 0x00000000000003b30288ff03008ca8320150570403aee1b900bbfed6024f0d25
*/

/*
  Result of 32bit mulvl index 2
  res = [0, 52504, 2358112152, 511073936, 1222083104, 3425938504, 683077040, 2147571112]
  res = 0x000000000000cd188c8def981e765e9048d78220cc33ac4828b6edb0800155a8
*/

/*
  Result of 32bit mulvl index 3
  res = [0, 59661, 2679554493, 580740174, 1388669436, 3892939911, 776189610, 2440313883]
  res = 0x000000000000e90d9fb6c1bd229d644e52c569fce8098c872e43b6aa91743c1b
*/

/*
  Result of 32bit mulvl index 4
  res = [0, 207841, 744828241, 2023124294, 542739820, 676931203, 2704011410, 4206353127]
  res = 0x0000000000032be12c652d5178966d4620598d6c28592683a12bf092fab7dae7
*/

/*
  Result of 32bit mulvl index 5
  res = [0, 636760, 2828998104, 1903254544, 1936323872, 2894521096, 3989280304, 275590504]
  res = 0x000000000009b758a89f15d871715c107369f520ac86e308edc79630106d2d68
*/

/*
  Result of 32bit mulvl index 6
  res = [0, 1869666356, 1419442932, 1555876152, 1745459184, 3348319772, 1959494312, 3070254188]
  res = 0x000000006f70d834549afaf45cbcc938680997f0c7934e1c74cb82a8b7005c6c
*/

/*
  Result of 32bit mulvl index 7
  res = [0, 4140082361, 1499933865, 4178530902, 2670781580, 3956121099, 3581624770, 4113232591]
  res = 0x00000000f6c4a4b959672ca9f90f52569f30e48cebcd9e0bd57b41c2f52af2cf
*/
