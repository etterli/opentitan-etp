/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
  NOTE:
  The result are nonsense (in terms of values) because both inputs are in the Montgomery space.
  If one input would be in original space the result would make sense.
  However, the RTL only implements a montgomery multiplication and no extra reduction afterwards.
  Nonetheless, the implementation can be tested this way.
*/

.section .text.start
/*
  Testing each lane results in 30 results.
  Thus only load one size vector pair at a time into w0 and w1
  MOD is loaded via w0 before loading the vectors
  Results are ordered (increasing lane):
  16b:  w2 to w17 --> reserved, not implemented
  32b:  w18 to w25
  64b:  w26 to w29 --> reserved, not implemented
  128b: w30 and w31 --> reserved, not implemented
*/

/* load the modulus into w0 and then into MOD*/
/* MOD <= dmem[modulus] = p */
addi x2, x0, 0
la           x3, mod32
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec32a
bn.lid x2++, 0(x3)
la     x3, vec32b
bn.lid x2++, 0(x3)
bn.mulvml.8S  w18, w0, w1, 0
bn.mulvml.8S  w19, w0, w1, 1
bn.mulvml.8S  w20, w0, w1, 2
bn.mulvml.8S  w21, w0, w1, 3
bn.mulvml.8S  w22, w0, w1, 4
bn.mulvml.8S  w23, w0, w1, 5
bn.mulvml.8S  w24, w0, w1, 6
bn.mulvml.8S  w25, w0, w1, 7

addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  32bit vector mod32 for instruction mulvml. Combined [R, q]
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
  32bit vector vec32a for instruction mulvlm
  vec32a = [4386494, 351607, 6259716, 5199533, 2908764, 4819738, 3847752, 1371499]
  vec32a = 0x0042eebe00055d77005f8404004f56ad002c625c00498b1a003ab6480014ed6b
*/
vec32a:
  .word 0x0014ed6b
  .word 0x003ab648
  .word 0x00498b1a
  .word 0x002c625c
  .word 0x004f56ad
  .word 0x005f8404
  .word 0x00055d77
  .word 0x0042eebe

/*
  32bit vector vec32b for instruction mulvlm
  vec32b = [5579227, 5963489, 3458491, 7380290, 3431077, 8342412, 2134462, 7944091]
  vec32b = 0x005521db005afee10034c5bb00709d4200345aa5007f4b8c002091be0079379b
*/
vec32b:
  .word 0x0079379b
  .word 0x002091be
  .word 0x007f4b8c
  .word 0x00345aa5
  .word 0x00709d42
  .word 0x0034c5bb
  .word 0x005afee1
  .word 0x005521db

/*
  Result of 32bit mulvlm index 0
  res = [515442, 718185, 5498530, 8237924, 2044754, 1726077, 6572625, 3330118]
  res = 0x0007dd72000af5690053e6a2007db364001f3352001a567d00644a510032d046
*/

/*
  Result of 32bit mulvlm index 1
  res = [5419054, 1425467, 3766569, 6818953, 4725646, 2800241, 4192112, 6140848]
  res = 0x0052b02e0015c03b0039792900680c8900481b8e002aba71003ff770005db3b0
*/

/*
  Result of 32bit mulvlm index 2
  res = [3018797, 4432770, 8337926, 4779507, 5619268, 5774263, 722707, 754865]
  res = 0x002e102d0043a382007f3a060048edf30055be4400581bb7000b0713000b84b1
*/

/*
  Result of 32bit mulvlm index 3
  res = [7198082, 4470350, 1294493, 652760, 6695655, 6942087, 1374687, 3415932]
  res = 0x006dd5820044364e0013c09d0009f5d800662ae70069ed870014f9df00341f7c
*/

/*
  Result of 32bit mulvlm index 4
  res = [4028494, 3561434, 1255813, 1531198, 1806146, 7587267, 4810729, 2052119]
  res = 0x003d784e003657da0013298500175d3e001b8f420073c5c3004967e9001f5017
*/

/*
  Result of 32bit mulvlm index 5
  res = [3946449, 1256339, 5192417, 7420002, 7942467, 4331764, 4009735, 7997143]
  res = 0x003c37d100132b93004f3ae10071386200793143004218f4003d2f07007a06d7
*/

/*
  Result of 32bit mulvlm index 6
  res = [7645843, 696628, 2618429, 6339788, 59635, 120462, 2282714, 5805869]
  res = 0x0074aa93000aa1340027f43d0060bccc0000e8f30001d68e0022d4da0058972d
*/

/*
  Result of 32bit mulvlm index 7
  res = [1268083, 1404023, 6310330, 5756485, 6378028, 3750173, 8235518, 7687323]
  res = 0x0013597300156c77006049ba0057d6450061522c0039391d007da9fe00754c9b
*/
