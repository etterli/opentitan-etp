/* Copyright lowRISC contributors (OpenTitan project). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
  NOTE!
  The result are nonsense because both inputs are in the Montgomery space.
  If one input would be in original space the result would make sense.
  However, the RTL only implements a montgomery multiplication and no extra
  reduction afterwards. Nonetheless, the implementation can be tested this way.
*/

.section .text.start
/*
  Testing each lane results in 30 results.
  Thus only load one size vector pair at a time into w0 and w1
  MOD is loaded via w0 before loading the vectors
  Results are ordered (increasing lane):
  16b:  w2 to w17
  32b:  w18 to w25
  64b:  w26 to w29
  128b: w30 and w31
*/

/* load the modulus into w0 and then into MOD*/
/* MOD <= dmem[modulus] = p */
addi x2, x0, 0
li           x2, 0
la           x3, mod16
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec16a
bn.lid x2++, 0(x3)
la     x3, vec16b
bn.lid x2++, 0(x3)

bn.mulvml.16H  w2, w0, w1, 0
bn.mulvml.16H  w3, w0, w1, 1
bn.mulvml.16H  w4, w0, w1, 2
bn.mulvml.16H  w5, w0, w1, 3
bn.mulvml.16H  w6, w0, w1, 4
bn.mulvml.16H  w7, w0, w1, 5
bn.mulvml.16H  w8, w0, w1, 6
bn.mulvml.16H  w9, w0, w1, 7
bn.mulvml.16H w10, w0, w1, 8
bn.mulvml.16H w11, w0, w1, 9
bn.mulvml.16H w12, w0, w1, 10
bn.mulvml.16H w13, w0, w1, 11
bn.mulvml.16H w14, w0, w1, 12
bn.mulvml.16H w15, w0, w1, 13
bn.mulvml.16H w16, w0, w1, 14
bn.mulvml.16H w17, w0, w1, 15

/* 32bit */
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

/* 64bit */
addi x2, x0, 0
la           x3, mod64
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec64a
bn.lid x2++, 0(x3)
la     x3, vec64b
bn.lid x2++, 0(x3)
bn.mulvml.4D  w26, w0, w1, 0
bn.mulvml.4D  w27, w0, w1, 1
bn.mulvml.4D  w28, w0, w1, 2
bn.mulvml.4D  w29, w0, w1, 3

/* 128bit */
addi x2, x0, 0
la           x3, mod128
bn.lid       x2, 0(x3)
bn.wsrw      MOD, w0

addi x2, x0, 0
la     x3, vec128a
bn.lid x2++, 0(x3)
la     x3, vec128b
bn.lid x2++, 0(x3)
bn.mulvml.2Q  w30, w0, w1, 0
bn.mulvml.2Q  w31, w0, w1, 1


addi x2, x0, 0 /* reset x2*/
addi x3, x0, 0 /* reset x3*/

ecall

.section .data
/*
  16bit vector mod16 for instruction mulvml. Combined [R, q]
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
  16bit vector vec16a for instruction mulvlm
  vec16a = [3112, 1175, 5700, 1065, 2288, 2734, 4377, 3511, 2799, 3372, 6575, 5433, 1061, 6708, 4622, 631]
  vec16a = 0x0c2804971644042908f00aae11190db70aef0d2c19af153904251a34120e0277
*/
vec16a:
  .word 0x120e0277
  .word 0x04251a34
  .word 0x19af1539
  .word 0x0aef0d2c
  .word 0x11190db7
  .word 0x08f00aae
  .word 0x16440429
  .word 0x0c280497

/*
  16bit vector vec16b for instruction mulvlm
  vec16b = [5896, 2974, 3532, 7345, 4227, 6159, 6439, 5196, 7398, 4938, 3163, 1023, 6077, 3487, 184, 3476]
  vec16b = 0x17080b9e0dcc1cb11083180f1927144c1ce6134a0c5b03ff17bd0d9f00b80d94
*/
vec16b:
  .word 0x00b80d94
  .word 0x17bd0d9f
  .word 0x0c5b03ff
  .word 0x1ce6134a
  .word 0x1927144c
  .word 0x1083180f
  .word 0x0dcc1cb1
  .word 0x17080b9e

/*
  Result of 16bit mulvlm index 0
  res = [4997, 471, 5673, 1040, 6364, 1851, 2245, 4105, 6685, 1584, 4249, 2849, 5059, 1424, 633, 1079]
  res = 0x138501d71629041018dc073b08c510091a1d063010990b2113c3059002790437
*/

/*
  Result of 16bit mulvlm index 1
  res = [3467, 5025, 3241, 6652, 5590, 6852, 3714, 4528, 31, 6515, 6499, 6294, 1472, 4325, 2503, 5764]
  res = 0x0d8b13a10ca919fc15d61ac40e8211b0001f19731963189605c010e509c71684
*/

/*
  Result of 16bit mulvlm index 2
  res = [3597, 4192, 5331, 3251, 7440, 777, 3044, 4046, 299, 1685, 7646, 2978, 5147, 5268, 659, 4226]
  res = 0x0e0d106014d30cb31d1003090be40fce012b06951dde0ba2141b149402931082
*/

/*
  Result of 16bit mulvlm index 3
  res = [719, 7584, 3393, 614, 899, 2274, 5044, 1184, 7082, 4785, 1619, 3709, 3118, 1774, 3334, 6893]
  res = 0x02cf1da00d410266038308e213b404a01baa12b106530e7d0c2e06ee0d061aed
*/

/*
  Result of 16bit mulvlm index 4
  res = [6294, 4818, 6109, 882, 1489, 6280, 6060, 2096, 5159, 1810, 5018, 4414, 601, 1091, 2418, 4517]
  res = 0x189612d217dd037205d1188817ac083014270712139a113e02590443097211a5
*/

/*
  Result of 16bit mulvlm index 5
  res = [6229, 1443, 5064, 6374, 564, 5526, 6395, 2337, 5025, 4225, 653, 6072, 2555, 4411, 3340, 5286]
  res = 0x185505a313c818e60234159618fb092113a11081028d17b809fb113b0d0c14a6
*/

/*
  Result of 16bit mulvlm index 6
  res = [2295, 752, 3648, 6748, 1161, 3873, 1588, 3157, 2398, 3978, 4208, 6207, 1589, 7023, 4778, 4347]
  res = 0x08f702f00e401a5c04890f2106340c55095e0f8a1070183f06351b6f12aa10fb
*/

/*
  Result of 16bit mulvlm index 7
  res = [5622, 841, 2305, 730, 5342, 1518, 3107, 2371, 3307, 5195, 4222, 2656, 6103, 5666, 5767, 3601]
  res = 0x15f60349090102da14de05ee0c2309430ceb144b107e0a6017d7162216870e11
*/

/*
  Result of 16bit mulvlm index 8
  res = [480, 3924, 5967, 5525, 1581, 5568, 1026, 5220, 5656, 832, 5985, 2339, 3653, 7565, 1941, 7154]
  res = 0x01e00f54174f1595062d15c00402146416180340176109230e451d8d07951bf2
*/

/*
  Result of 16bit mulvlm index 9
  res = [1523, 7332, 5236, 5129, 1841, 5534, 7900, 6136, 4423, 4662, 3113, 1750, 6014, 2123, 4879, 6364]
  res = 0x05f31ca4147414090731159e1edc17f8114712360c2906d6177e084b130f18dc
*/

/*
  Result of 16bit mulvlm index 10
  res = [6138, 4301, 3601, 1930, 6852, 5987, 6864, 4191, 6354, 7606, 2125, 5360, 3774, 1476, 7664, 4846]
  res = 0x17fa10cd0e11078a1ac417631ad0105f18d21db6084d14f00ebe05c41df012ee
*/

/*
  Result of 16bit mulvlm index 11
  res = [3858, 828, 3694, 331, 1238, 2288, 5782, 2145, 2237, 3654, 5924, 7520, 3484, 5353, 340, 4988]
  res = 0x0f12033c0e6e014b04d608f01696086108bd0e4617241d600d9c14e90154137c
*/

/*
  Result of 16bit mulvlm index 12
  res = [2027, 836, 8089, 5243, 847, 5314, 636, 4034, 5812, 4019, 3710, 6860, 5679, 4379, 4263, 7051]
  res = 0x07eb03441f99147b034f14c2027c0fc216b40fb30e7e1acc162f111b10a71b8b
*/

/*
  Result of 16bit mulvlm index 13
  res = [4074, 5627, 6000, 4713, 812, 3277, 7002, 4494, 1749, 5545, 2930, 2127, 5507, 3070, 7659, 7449]
  res = 0x0fea15fb17701269032c0ccd1b5a118e06d515a90b72084f15830bfe1deb1d19
*/

/*
  Result of 16bit mulvlm index 14
  res = [2709, 2999, 6804, 6300, 4136, 2609, 6454, 1972, 6518, 3179, 2261, 6613, 1043, 4543, 4272, 849]
  res = 0x0a950bb71a94189c10280a31193607b419760c6b08d519d5041311bf10b00351
*/

/*
  Result of 16bit mulvlm index 15
  res = [317, 127, 6263, 2148, 428, 644, 3616, 6291, 4620, 1055, 872, 897, 1670, 5391, 6353, 3366]
  res = 0x013d007f1877086401ac02840e201893120c041f036803810686150f18d10d26
*/

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

/*
  64bit vector mod64 for instruction mulvml. Combined [R, q]
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
  64bit vector vec64a for instruction mulvlm
  vec64a = [5596551, 6378155, 4819839, 6544528]
  vec64a = 0x000000000055658700000000006152ab0000000000498b7f000000000063dc90
*/
vec64a:
  .word 0x0063dc90
  .word 0x00000000
  .word 0x00498b7f
  .word 0x00000000
  .word 0x006152ab
  .word 0x00000000
  .word 0x00556587
  .word 0x00000000

/*
  64bit vector vec64b for instruction mulvlm
  vec64b = [7630996, 3072188, 2115071, 3538687]
  vec64b = 0x000000000074709400000000002ee0bc00000000002045ff000000000035feff
*/
vec64b:
  .word 0x0035feff
  .word 0x00000000
  .word 0x002045ff
  .word 0x00000000
  .word 0x002ee0bc
  .word 0x00000000
  .word 0x00747094
  .word 0x00000000

/*
  Result of 64bit mulvlm index 0
  res = [2478650, 1623070, 5591576, 2678621]
  res = 0x000000000025d23a000000000018c41e0000000000555218000000000028df5d
*/

/*
  Result of 64bit mulvlm index 1
  res = [4635401, 6497168, 3685169, 3758513]
  res = 0x000000000046bb0900000000006323900000000000383b3100000000003959b1
*/

/*
  Result of 64bit mulvlm index 2
  res = [1640449, 3059242, 4887691, 5556732]
  res = 0x000000000019080100000000002eae2a00000000004a948b000000000054c9fc
*/

/*
  Result of 64bit mulvlm index 3
  res = [2342258, 9145, 6113009, 7907912]
  res = 0x000000000023bd7200000000000023b900000000005d46f1000000000078aa48
*/

/*
  128bit vector mod128 for instruction mulvml. Combined [R, q]
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
  128bit vector vec128a for instruction mulvlm
  vec128a = [7840844, 404563]
  vec128a = 0x0000000000000000000000000077a44c00000000000000000000000000062c53
*/
vec128a:
  .word 0x00062c53
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x0077a44c
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  128bit vector vec128b for instruction mulvlm
  vec128b = [7978137, 3485446]
  vec128b = 0x0000000000000000000000000079bc9900000000000000000000000000352f06
*/
vec128b:
  .word 0x00352f06
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x0079bc99
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/*
  Result of 128bit mulvlm index 0
  res = [714908, 2157490]
  res = 0x000000000000000000000000000ae89c0000000000000000000000000020ebb2
*/

/*
  Result of 128bit mulvlm index 1
  res = [764121, 5914224]
  res = 0x000000000000000000000000000ba8d9000000000000000000000000005a3e70
*/
