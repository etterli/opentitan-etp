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

la     x3, vec64a0
bn.lid x2++, 0(x3)
la     x3, vec64b0
bn.lid x2++, 0(x3)

la     x3, vec128a0
bn.lid x2++, 0(x3)
la     x3, vec128b0
bn.lid x2++, 0(x3)

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.16H w10, w0, w1

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.8S  w11, w2, w3

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.4D  w12, w4, w5

/* load the modulus into w20 and then into MOD*/
/* MOD <= dmem[modulus] = p */
li           x2, 20
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w20
bn.mulvm.2Q  w13, w6, w7

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction mulvm. Combined [R, q]
  mod16 = [16801, 7583]
  mod16 = 0x000000000000000000000000000000000000000000000000000041a100001d9f
*/
mod16:
  .word 0x00001d9f
  .word 0x000041a1
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  16bit vector vec16a0 for instruction mulvm
  vec16a0 = [74, 4067, 3784, 5909, 314, 6006, 839, 3194, 6718, 3314, 6912, 734, 4636, 5106, 4760, 6536]
  vec16a0 = 0x004a0fe30ec81715013a177603470c7a1a3e0cf21b0002de121c13f212981988
*/
vec16a0:
  .word 0x12981988
  .word 0x121c13f2
  .word 0x1b0002de
  .word 0x1a3e0cf2
  .word 0x03470c7a
  .word 0x013a1776
  .word 0x0ec81715
  .word 0x004a0fe3

/*
  16bit vector vec16b0 for instruction mulvm
  vec16b0 = [3603, 1967, 4388, 2100, 909, 457, 6860, 7308, 3102, 6214, 4357, 7324, 5348, 5501, 1850, 4385]
  vec16b0 = 0x0e1307af11240834038d01c91acc1c8c0c1e184611051c9c14e4157d073a1121
*/
vec16b0:
  .word 0x073a1121
  .word 0x14e4157d
  .word 0x11051c9c
  .word 0x0c1e1846
  .word 0x1acc1c8c
  .word 0x038d01c9
  .word 0x11240834
  .word 0x0e1307af

/*
  Result of 16bit mulvm
  res = [7535, 1849, 731, 6077, 4868, 498, 179, 4791, 2503, 6051, 7302, 6607, 6745, 5980, 6427, 3741]
  res = 0x1d6f073902db17bd130401f200b312b709c717a31c8619cf1a59175c191b0e9d
*/

/*
  32bit vector mod32 for instruction mulvm. Combined [R, q]
  mod32 = [4236238847, 8380417]
  mod32 = 0x000000000000000000000000000000000000000000000000fc7fdfff007fe001
*/
mod32:
  .word 0x007fe001
  .word 0xfc7fdfff
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  32bit vector vec32a0 for instruction mulvm
  vec32a0 = [140140, 2179652, 4415585, 3591344, 6089560, 5367875, 2289882, 4817594]
  vec32a0 = 0x0002236c00214244004360610036ccb0005ceb580051e8430022f0da004982ba
*/
vec32a0:
  .word 0x004982ba
  .word 0x0022f0da
  .word 0x0051e843
  .word 0x005ceb58
  .word 0x0036ccb0
  .word 0x00436061
  .word 0x00214244
  .word 0x0002236c

/*
  32bit vector vec32b0 for instruction mulvm
  vec32b0 = [7268407, 3661137, 7621524, 6778366, 6274350, 2059156, 3886783, 2027657]
  vec32b0 = 0x006ee8370037dd5100744b9400676dfe005fbd2e001f6b94003b4ebf001ef089
*/
vec32b0:
  .word 0x001ef089
  .word 0x003b4ebf
  .word 0x001f6b94
  .word 0x005fbd2e
  .word 0x00676dfe
  .word 0x00744b94
  .word 0x0037dd51
  .word 0x006ee837

/*
  Result of 32bit mulvm
  res = [1620927, 7309254, 1234587, 1342470, 3140778, 8169851, 1752570, 480708]
  res = 0x0018bbbf006f87c60012d69b00147c06002fecaa007ca97b001abdfa000755c4
*/

/*
  64bit vector mod64 for instruction mulvm. Combined [R, q]
  mod64 = [16714476285912408063, 8380417]
  mod64 = 0x00000000000000000000000000000000e7f5bf9ffc7fdfff00000000007fe001
*/
mod64:
  .word 0x007fe001
  .word 0x00000000
  .word 0xfc7fdfff
  .word 0xe7f5bf9f
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  64bit vector vec64a0 for instruction mulvm
  vec64a0 = [2248495, 1695942, 278193, 4877353]
  vec64a0 = 0x0000000000224f2f000000000019e0c60000000000043eb100000000004a6c29
*/
vec64a0:
  .word 0x004a6c29
  .word 0x00000000
  .word 0x00043eb1
  .word 0x00000000
  .word 0x0019e0c6
  .word 0x00000000
  .word 0x00224f2f
  .word 0x00000000

/*
  64bit vector vec64b0 for instruction mulvm
  vec64b0 = [6223873, 72682, 3356712, 7780225]
  vec64b0 = 0x00000000005ef8010000000000011bea0000000000333828000000000076b781
*/
vec64b0:
  .word 0x0076b781
  .word 0x00000000
  .word 0x00333828
  .word 0x00000000
  .word 0x00011bea
  .word 0x00000000
  .word 0x005ef801
  .word 0x00000000

/*
  Result of 64bit mulvm
  res = [1145487, 6909576, 7467992, 7432138]
  res = 0x0000000000117a8f0000000000696e88000000000071f3d800000000007167ca
*/

/*
  128bit vector mod128 for instruction mulvm. Combined [R, q]
  mod128 = [2984062896558332194971546556068519935, 8380417]
  mod128 = 0x023eb5a8eccfe21ee7f5bf9ffc7fdfff000000000000000000000000007fe001
*/
mod128:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0xfc7fdfff
  .word 0xe7f5bf9f
  .word 0xeccfe21e
  .word 0x023eb5a8

/*
  128bit vector vec128a0 for instruction mulvm
  vec128a0 = [5777958, 4965419]
  vec128a0 = 0x00000000000000000000000000582a26000000000000000000000000004bc42b
*/
vec128a0:
  .word 0x004bc42b
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00582a26
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b0 for instruction mulvm
  vec128b0 = [6544850, 3614229]
  vec128b0 = 0x0000000000000000000000000063ddd200000000000000000000000000372615
*/
vec128b0:
  .word 0x00372615
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x0063ddd2
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit mulvm
  res = [1229093, 1834768]
  res = 0x0000000000000000000000000012c125000000000000000000000000001bff10
*/
