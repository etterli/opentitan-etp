/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.section .text.start
/*
  Load the vectors into w0-w7
*/
addi x2, x0, 2

la     x3, vec32a0
bn.lid x2++, 0(x3)
la     x3, vec32b0
bn.lid x2++, 0(x3)

la     x3, vec64a0
bn.lid x2++, 0(x3)
la     x3, vec64b0
bn.lid x2++, 0(x3)

la     x3, vec128a0
bn.lid x2++, 0(x3)
la     x3, vec128b0
bn.lid x2++, 0(x3)

la     x3, vec128a1
bn.lid x2++, 0(x3)
la     x3, vec128b1
bn.lid x2++, 0(x3)

bn.mulv.8S  w11, w2, w3
bn.mulv.4D  w12, w4, w5
bn.mulv.2Q  w13, w6, w7
bn.mulv.2Q  w14, w8, w9


addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
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

/*
  64bit vector vec64a0 for instruction mulv
  vec64a0 = [0, 1, 2417127611, 30955]
  vec64a0 = 0x0000000000000000000000000000000100000000901270bb00000000000078eb
*/
vec64a0:
  .word 0x000078eb
  .word 0x00000000
  .word 0x901270bb
  .word 0x00000000
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction mulv
  vec64b0 = [17614515565450322005, 5145075550695678108, 45867244350, 328746167066219]
  vec64b0 = 0xf4735494c14160554766faf41dc3609c0000000aade69b3e00012afe2e825e6b
*/
vec64b0:
  .word 0x2e825e6b
  .word 0x00012afe
  .word 0xade69b3e
  .word 0x0000000a
  .word 0x1dc3609c
  .word 0x4766faf4
  .word 0xc1416055
  .word 0xf4735494

/*
  Result of 64bit mulv
  res = [0, 5145075550695678108, 186518316611438154, 10176337601534809145]
  res = 0x00000000000000004766faf41dc3609c0296a56bb5ba864a8d399d21cdeed439
*/

/*
  128bit vector vec128a0 for instruction mulv
  vec128a0 = [0, 1]
  vec128a0 = 0x0000000000000000000000000000000000000000000000000000000000000001
*/
vec128a0:
  .word 0x00000001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128a1 for instruction mulv
  vec128a1 = [15163934324283487979, 59768885155910817024740993528977806]
  vec128a1 = 0x0000000000000000d2711ded0c4536eb000b82d563bae0bc42c1cf008893598e
*/
vec128a1:
  .word 0x8893598e
  .word 0x42c1cf00
  .word 0x63bae0bc
  .word 0x000b82d5
  .word 0x0c4536eb
  .word 0xd2711ded
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction mulv
  vec128b0 = [4475401137670541, 909208951293833190286950213268633]
  vec128b0 = 0x0000000000000000000fe65a8709c98d00002cd3d491451a0e7eac07695eb499
*/
vec128b0:
  .word 0x695eb499
  .word 0x0e7eac07
  .word 0xd491451a
  .word 0x00002cd3
  .word 0x8709c98d
  .word 0x000fe65a
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b1 for instruction mulv
  vec128b1 = [86676785931336461155, 2613]
  vec128b1 = 0x0000000000000004b2e1cd923de2ab6300000000000000000000000000000a35
*/
vec128b1:
  .word 0x00000a35
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x3de2ab63
  .word 0xb2e1cd92
  .word 0x00000004
  .word 0x00000000

/*
  Result of 128bit mulv
  res = [0, 909208951293833190286950213268633]
  res = 0x0000000000000000000000000000000000002cd3d491451a0e7eac07695eb499
*/

/*
  Result of 128bit mulv
  res = [293513988539949706980763568066538321377, 156176096912394964885648216091219007078]
  res = 0xdcd0bceb1d4df195eeebbe1474e935e1757e6c12f277e1956435e07208011666
*/
