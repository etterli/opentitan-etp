/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for ntt_mldsa_exp_reduction
 * Inspired from
 * https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/crypto/tests/ntt_dilithium_test.s
*/

.section .text.start

.globl main
main:
  /* Prepare modulus for MAC module
   * We need the modulus and the Montgomery constant. The values are expected like
   * modulus @ MOD[0:31]  = 8380417
   * R       @ MOD[32:64] = 4236238847 = (-q)^(-1) mod 2^d, d bitwidth of numbers
   */

  li      x2, 2
  la      x3, modulus
  bn.lid  x2, 0(x3)
  bn.wsrw 0x0, w2

  la  x10, inputs
  la  x11, twiddles
  la  x12, inputs
  jal  x1, ntt_mldsa_exp_reduction

  ecall

.data
.balign 32
modulus:
  .word 0x007FE001 /* q */
  .word 0xFC7FDFFF /* R = (-q)^(-1) */
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/* in regular space */
inputs:
  .word 0x00000000
  .word 0x00000001
  .word 0x00000010
  .word 0x00000051
  .word 0x00000100
  .word 0x00000271
  .word 0x00000510
  .word 0x00000961
  .word 0x00001000
  .word 0x000019a1
  .word 0x00002710
  .word 0x00003931
  .word 0x00005100
  .word 0x00006f91
  .word 0x00009610
  .word 0x0000c5c1
  .word 0x00010000
  .word 0x00014641
  .word 0x00019a10
  .word 0x0001fd11
  .word 0x00027100
  .word 0x0002f7b1
  .word 0x00039310
  .word 0x00044521
  .word 0x00051000
  .word 0x0005f5e1
  .word 0x0006f910
  .word 0x00081bf1
  .word 0x00096100
  .word 0x000acad1
  .word 0x000c5c10
  .word 0x000e1781
  .word 0x00100000
  .word 0x00121881
  .word 0x00146410
  .word 0x0016e5d1
  .word 0x0019a100
  .word 0x001c98f1
  .word 0x001fd110
  .word 0x00234ce1
  .word 0x00271000
  .word 0x002b1e21
  .word 0x002f7b10
  .word 0x00342ab1
  .word 0x00393100
  .word 0x003e9211
  .word 0x00445210
  .word 0x004a7541
  .word 0x00510000
  .word 0x0057f6c1
  .word 0x005f5e10
  .word 0x00673a91
  .word 0x006f9100
  .word 0x00786631
  .word 0x0001df0f
  .word 0x000bc0a0
  .word 0x00162fff
  .word 0x00213260
  .word 0x002ccd0f
  .word 0x00390570
  .word 0x0045e0ff
  .word 0x00536550
  .word 0x0061980f
  .word 0x00707f00
  .word 0x00003ffe
  .word 0x0010a0ff
  .word 0x0021c80e
  .word 0x0033bb4f
  .word 0x004680fe
  .word 0x005a1f6f
  .word 0x006e9d0e
  .word 0x0004205e
  .word 0x001a6ffd
  .word 0x0031b29e
  .word 0x0049ef0d
  .word 0x00632c2e
  .word 0x007d70fd
  .word 0x0018e48d
  .word 0x00354e0c
  .word 0x0052d4bd
  .word 0x00717ffc
  .word 0x0011773c
  .word 0x0032820b
  .word 0x0054c80c
  .word 0x007850fb
  .word 0x001d44ab
  .word 0x00436b0a
  .word 0x006aec1b
  .word 0x0013eff9
  .word 0x003e3eda
  .word 0x006a0109
  .word 0x00175ee9
  .word 0x004620f8
  .word 0x00766fc9
  .word 0x00287407
  .word 0x005bf678
  .word 0x00113ff6
  .word 0x00481977
  .word 0x0000cc05
  .word 0x003b20c6
  .word 0x007740f5
  .word 0x003555e5
  .word 0x00752904
  .word 0x003703d4
  .word 0x007aaff3
  .word 0x00407713
  .word 0x00084301
  .word 0x0051fda2
  .word 0x001df0f0
  .word 0x006be701
  .word 0x003c29ff
  .word 0x000ea42f
  .word 0x00633fee
  .word 0x003a47ae
  .word 0x0013a5fc
  .word 0x006f457d
  .word 0x004d70eb
  .word 0x002e131b
  .word 0x001136f9
  .word 0x0076c78a
  .word 0x005f0fe8
  .word 0x0049fb48
  .word 0x003794f6
  .word 0x0027e856
  .word 0x001b00e4
  .word 0x0010ea34
  .word 0x0009aff2
  .word 0x00055de2
  .word 0x0003ffe0
  .word 0x0005a1e0
  .word 0x000a4fee
  .word 0x0012162e
  .word 0x001d00dc
  .word 0x002b1c4c
  .word 0x003c74ea
  .word 0x0051173a
  .word 0x00690fd8
  .word 0x00048b77
  .word 0x002356e5
  .word 0x00459f05
  .word 0x006b70d3
  .word 0x0014f962
  .word 0x004205e0
  .word 0x0072c390
  .word 0x00275fcd
  .word 0x005fa80d
  .word 0x001be9da
  .word 0x005bf2da
  .word 0x002010c7
  .word 0x00681177
  .word 0x003442d4
  .word 0x000492e3
  .word 0x0058efc1
  .word 0x0031a7a0
  .word 0x000ea8cd
  .word 0x006fe1ad
  .word 0x0055a0ba
  .word 0x003fd489
  .word 0x002e8bc6
  .word 0x0021d535
  .word 0x0019bfb2
  .word 0x00165a31
  .word 0x0017b3be
  .word 0x001ddb7d
  .word 0x0028e0aa
  .word 0x0038d299
  .word 0x004dc0b6
  .word 0x0067ba85
  .word 0x0006efa1
  .word 0x002b2fc0
  .word 0x0054aaad
  .word 0x0003904b
  .word 0x0037b098
  .word 0x00713ba7
  .word 0x003061a3
  .word 0x0074f2d2
  .word 0x003f3f8e
  .word 0x000f384c
  .word 0x0064cd99
  .word 0x00405017
  .word 0x0021b083
  .word 0x0008ffb1
  .word 0x00762e8e
  .word 0x00698e1c
  .word 0x00630f78
  .word 0x0062c3d6
  .word 0x0068bc82
  .word 0x00750ae0
  .word 0x0007e06b
  .word 0x00210eb9
  .word 0x0040c775
  .word 0x00671c63
  .word 0x00143f5e
  .word 0x0048025c
  .word 0x0002b767
  .word 0x004430a5
  .word 0x000cc050
  .word 0x005c38be
  .word 0x0032ec59
  .word 0x0010cda6
  .word 0x0075cf42
  .word 0x006243df
  .word 0x00561e4a
  .word 0x00517167
  .word 0x00545032
  .word 0x005ecdbf
  .word 0x0070fd3a
  .word 0x000b11e6
  .word 0x002cdf21
  .word 0x0056985e
  .word 0x00087128
  .word 0x00423d25
  .word 0x0004500f
  .word 0x004e7dbc
  .word 0x00211a16
  .word 0x007bf923
  .word 0x005f6efd
  .word 0x004b6fd9
  .word 0x00401003
  .word 0x003d63df
  .word 0x00437fe9
  .word 0x005278b5
  .word 0x006a62ef
  .word 0x000b735a
  .word 0x00357ed4
  .word 0x0068ba50
  .word 0x00255ad9
  .word 0x006b3595
  .word 0x003a9fbe
  .word 0x00138ea9
  .word 0x0075f7c3
  .word 0x0062308e
  .word 0x00582ea7
  .word 0x005807c2
  .word 0x0061d1ab
  .word 0x0075a246
  .word 0x0013af8e
  .word 0x003bcf99
  .word 0x006e3892
  .word 0x002b20bc
  .word 0x00725e75
  .word 0x0044482f
  .word 0x0020d477
  .word 0x000819f1
  .word 0x007a0f5a
  .word 0x00770b84
  .word 0x007f055c
  .word 0x001233e5
  .word 0x00306e3d
  .word 0x0059eb97
  .word 0x000ee33e
  .word 0x004f2c98
  .word 0x001b1f1f
  .word 0x00729269
  .word 0x0055de20
  .word 0x0044fa09

twiddles:
  /* Special order for implementation and in montgomery space.
   * Index is index in FIPS 204 Standard array. */
  /* Layers 1-4 */
  .word 0x000064f7 /* zeta index 1, original zeta 0x00495e02 */
  .word 0x00581103 /* zeta index 2, original zeta 0x00397567 */
  .word 0x0077f504 /* zeta index 3, original zeta 0x00396569 */
  .word 0x00039e44 /* zeta index 4, original zeta 0x004f062b */
  .word 0x00740119 /* zeta index 5, original zeta 0x0053df73 */
  .word 0x00728129 /* zeta index 6, original zeta 0x004fe033 */
  .word 0x00071e24 /* zeta index 7, original zeta 0x004f066b */
  .word 0x001bde2b /* zeta index 8, original zeta 0x0076b1ae */
  .word 0x0023e92b /* zeta index 9, original zeta 0x00360dd5 */
  .word 0x007a64ae /* zeta index 10, original zeta 0x0028edb0 */
  .word 0x005ff480 /* zeta index 11, original zeta 0x00207fe4 */
  .word 0x002f9a75 /* zeta index 12, original zeta 0x00397283 */
  .word 0x0053db0a /* zeta index 13, original zeta 0x0070894a */
  .word 0x002f7a49 /* zeta index 14, original zeta 0x00088192 */
  .word 0x0028e527 /* zeta index 15, original zeta 0x006d3dc8 */
  .word 0x00000000 /* Padding */
  /* Layer 5 - iteration 1 */
  .word 0x00299658 /* zeta index 16, original zeta 0x004c7294 */
  .word 0x000fa070 /* zeta index 17, original zeta 0x0041e0b4 */
  .word 0x006f65a5 /* zeta index 18, original zeta 0x0028a3d2 */
  .word 0x0036b788 /* zeta index 19, original zeta 0x0066528a */
  .word 0x00777d91 /* zeta index 20, original zeta 0x004a18a7 */
  .word 0x006ecaa1 /* zeta index 21, original zeta 0x00794034 */
  .word 0x0027f968 /* zeta index 22, original zeta 0x000a52ee */
  .word 0x005fb37c /* zeta index 23, original zeta 0x006b7d81 */
  /* Layer 6 - iteration 1 */
  .word 0x00294a67 /* zeta index 32, original zeta 0x0036f72a */
  .word 0x00017620 /* zeta index 33, original zeta 0x0030911e */
  .word 0x002ef4cd /* zeta index 34, original zeta 0x0029d13f */
  .word 0x0035dec5 /* zeta index 35, original zeta 0x00492673 */
  .word 0x00668504 /* zeta index 36, original zeta 0x0050685f */
  .word 0x0049102d /* zeta index 37, original zeta 0x002010a2 */
  .word 0x005927d5 /* zeta index 38, original zeta 0x003887f7 */
  .word 0x003bbeaf /* zeta index 39, original zeta 0x0011b2c3 */
  .word 0x0044f586 /* zeta index 40, original zeta 0x000603a4 */
  .word 0x00516e7d /* zeta index 41, original zeta 0x000e2bed */
  .word 0x00368a96 /* zeta index 42, original zeta 0x0010b72c */
  .word 0x00541e42 /* zeta index 43, original zeta 0x004a5f35 */
  .word 0x00360400 /* zeta index 44, original zeta 0x001f9d15 */
  .word 0x007b4a4e /* zeta index 45, original zeta 0x00428cd4 */
  .word 0x0023d69c /* zeta index 46, original zeta 0x003177f4 */
  .word 0x0077a55e /* zeta index 47, original zeta 0x0020e612 */
  /* Layer 7 - iteration 1 */
  .word 0x0043e6e6 /* zeta index 64, original zeta 0x002ee3f1 */
  .word 0x0047c1d0 /* zeta index 66, original zeta 0x0057a930 */
  .word 0x0069b65e /* zeta index 68, original zeta 0x003fd54c */
  .word 0x002135c7 /* zeta index 70, original zeta 0x00503ee1 */
  .word 0x006caf76 /* zeta index 72, original zeta 0x002648b4 */
  .word 0x00419073 /* zeta index 74, original zeta 0x001d90a2 */
  .word 0x004f3281 /* zeta index 76, original zeta 0x002ae59b */
  .word 0x004870e1 /* zeta index 78, original zeta 0x006ef1f5 */
  .word 0x00688c82 /* zeta index 65, original zeta 0x00137eb9 */
  .word 0x0051781a /* zeta index 67, original zeta 0x003ac6ef */
  .word 0x003509ee /* zeta index 69, original zeta 0x004eb2ea */
  .word 0x0067afbc /* zeta index 71, original zeta 0x007bb175 */
  .word 0x001d9772 /* zeta index 73, original zeta 0x001ef256 */
  .word 0x00709cf7 /* zeta index 75, original zeta 0x0045a6d4 */
  .word 0x004fb2af /* zeta index 77, original zeta 0x0052589c */
  .word 0x0001efca /* zeta index 79, original zeta 0x003f7288 */
  .word 0x003410f2 /* zeta index 80, original zeta 0x00175102 */
  .word 0x0020c638 /* zeta index 82, original zeta 0x001187ba */
  .word 0x005297a4 /* zeta index 84, original zeta 0x00773e9e */
  .word 0x00799a6e /* zeta index 86, original zeta 0x002592ec */
  .word 0x0075a283 /* zeta index 88, original zeta 0x00404ce8 */
  .word 0x007f863c /* zeta index 90, original zeta 0x001e54e6 */
  .word 0x007a0bde /* zeta index 92, original zeta 0x001a7e79 */
  .word 0x001c4563 /* zeta index 94, original zeta 0x004e4817 */
  .word 0x0070de86 /* zeta index 81, original zeta 0x00075d59 */
  .word 0x00296e9f /* zeta index 83, original zeta 0x0052aca9 */
  .word 0x0047844c /* zeta index 85, original zeta 0x000296d8 */
  .word 0x005a140a /* zeta index 87, original zeta 0x004cff12 */
  .word 0x006d2114 /* zeta index 89, original zeta 0x004aa582 */
  .word 0x006be9f8 /* zeta index 91, original zeta 0x004f16c1 */
  .word 0x001495d4 /* zeta index 93, original zeta 0x0003978f */
  .word 0x006a0c63 /* zeta index 95, original zeta 0x0031b859 */
  /* Layer 8 - iteration 1 */
  .word 0x001fea93 /* zeta index 128, original zeta 0x000006d9 */
  .word 0x004cdf73 /* zeta index 132, original zeta 0x00289838 */
  .word 0x000412f5 /* zeta index 136, original zeta 0x00120a23 */
  .word 0x004a28a1 /* zeta index 140, original zeta 0x00437ff8 */
  .word 0x000dbe5e /* zeta index 144, original zeta 0x007f735d */
  .word 0x00078f83 /* zeta index 148, original zeta 0x0061ab98 */
  .word 0x0075e022 /* zeta index 152, original zeta 0x00662960 */
  .word 0x0049997e /* zeta index 156, original zeta 0x0049b0e3 */
  .word 0x0033ff5a /* zeta index 129, original zeta 0x006257c5 */
  .word 0x00223dfb /* zeta index 133, original zeta 0x0064b5fe */
  .word 0x00252587 /* zeta index 137, original zeta 0x000154a8 */
  .word 0x004682fd /* zeta index 141, original zeta 0x005cd5b4 */
  .word 0x001c5e1a /* zeta index 145, original zeta 0x000c8d0d */
  .word 0x0067428b /* zeta index 149, original zeta 0x00185d96 */
  .word 0x00503af7 /* zeta index 153, original zeta 0x004bd579 */
  .word 0x0077dcd7 /* zeta index 157, original zeta 0x0009b434 */
  .word 0x002358d4 /* zeta index 130, original zeta 0x00574b3c */
  .word 0x005a8ba0 /* zeta index 134, original zeta 0x007ef8f5 */
  .word 0x006d04f1 /* zeta index 138, original zeta 0x0009b7ff */
  .word 0x006d9b57 /* zeta index 142, original zeta 0x004dc04e */
  .word 0x000de0e6 /* zeta index 146, original zeta 0x000f66d5 */
  .word 0x007f3705 /* zeta index 150, original zeta 0x00437f31 */
  .word 0x001f0084 /* zeta index 154, original zeta 0x0028de06 */
  .word 0x00742593 /* zeta index 158, original zeta 0x007c0db3 */
  .word 0x003a41f8 /* zeta index 131, original zeta 0x0069a8ef */
  .word 0x00498423 /* zeta index 135, original zeta 0x002a4e78 */
  .word 0x00359b5d /* zeta index 139, original zeta 0x00435e87 */
  .word 0x004f25df /* zeta index 143, original zeta 0x004728af */
  .word 0x000c7f5a /* zeta index 147, original zeta 0x005a6d80 */
  .word 0x0077e6fd /* zeta index 151, original zeta 0x00468298 */
  .word 0x0030ef86 /* zeta index 155, original zeta 0x00465d8d */
  .word 0x004901c3 /* zeta index 159, original zeta 0x005a68b0 */
  .word 0x00053919 /* zeta index 160, original zeta 0x00409ba9 */
  .word 0x003472e7 /* zeta index 164, original zeta 0x00246e39 */
  .word 0x002b5ee5 /* zeta index 168, original zeta 0x00392db2 */
  .word 0x003de11c /* zeta index 172, original zeta 0x0030c31c */
  .word 0x00466519 /* zeta index 176, original zeta 0x002dbfcb */
  .word 0x0052308a /* zeta index 180, original zeta 0x006b3375 */
  .word 0x006b88bf /* zeta index 184, original zeta 0x0078e00d */
  .word 0x0078fde5 /* zeta index 188, original zeta 0x001f1d68 */
  .word 0x0004610c /* zeta index 161, original zeta 0x0064d3d5 */
  .word 0x004ce03c /* zeta index 165, original zeta 0x0048c39b */
  .word 0x00291199 /* zeta index 169, original zeta 0x00230923 */
  .word 0x00130984 /* zeta index 173, original zeta 0x00285424 */
  .word 0x001314be /* zeta index 177, original zeta 0x00022a0b */
  .word 0x001c853f /* zeta index 181, original zeta 0x00095b76 */
  .word 0x0012e11b /* zeta index 185, original zeta 0x00628c37 */
  .word 0x001406c7 /* zeta index 189, original zeta 0x006330bb */
  .word 0x005aad42 /* zeta index 162, original zeta 0x0021762a */
  .word 0x001a7cc7 /* zeta index 166, original zeta 0x007bc759 */
  .word 0x00585a3b /* zeta index 170, original zeta 0x0012eb67 */
  .word 0x0025f051 /* zeta index 174, original zeta 0x0013232e */
  .word 0x00283891 /* zeta index 178, original zeta 0x007e832c */
  .word 0x001d0b4b /* zeta index 182, original zeta 0x006be1cc */
  .word 0x004d3e3f /* zeta index 186, original zeta 0x003da604 */
  .word 0x00327283 /* zeta index 190, original zeta 0x007361b8 */
  .word 0x003eb01b /* zeta index 163, original zeta 0x00658591 */
  .word 0x00031924 /* zeta index 167, original zeta 0x004f5859 */
  .word 0x00134d71 /* zeta index 171, original zeta 0x00454df2 */
  .word 0x00185a46 /* zeta index 175, original zeta 0x007faf80 */
  .word 0x0049bb91 /* zeta index 179, original zeta 0x0026587a */
  .word 0x006fd6a7 /* zeta index 183, original zeta 0x005e061e */
  .word 0x006a0d30 /* zeta index 187, original zeta 0x004ae53c */
  .word 0x0061ed6f /* zeta index 191, original zeta 0x005ea06c */
  /* Layer 5 - iteration 2 */
  .word 0x005f8dd7 /* zeta index 24, original zeta 0x004e9f1d */
  .word 0x0044fae8 /* zeta index 25, original zeta 0x001a2877 */
  .word 0x006a84f8 /* zeta index 26, original zeta 0x002571df */
  .word 0x004ddc99 /* zeta index 27, original zeta 0x001649ee */
  .word 0x001ad035 /* zeta index 28, original zeta 0x007611bd */
  .word 0x007f9423 /* zeta index 29, original zeta 0x00492bb7 */
  .word 0x003d3201 /* zeta index 30, original zeta 0x002af697 */
  .word 0x000445c5 /* zeta index 31, original zeta 0x0022d8d5 */
  /* Layer 6 - iteration 2 */
  .word 0x0065f23e /* zeta index 48, original zeta 0x00341c1d */
  .word 0x0066cad7 /* zeta index 49, original zeta 0x001ad873 */
  .word 0x00357e1e /* zeta index 50, original zeta 0x00736681 */
  .word 0x00458f5a /* zeta index 51, original zeta 0x0049553f */
  .word 0x0035843f /* zeta index 52, original zeta 0x003952f6 */
  .word 0x005f3618 /* zeta index 53, original zeta 0x0062564a */
  .word 0x0067745d /* zeta index 54, original zeta 0x0065ad05 */
  .word 0x0038738c /* zeta index 55, original zeta 0x00439a1c */
  .word 0x000c63a8 /* zeta index 56, original zeta 0x0053aa5f */
  .word 0x00081b9a /* zeta index 57, original zeta 0x0030b622 */
  .word 0x000e8f76 /* zeta index 58, original zeta 0x00087f38 */
  .word 0x003b3853 /* zeta index 59, original zeta 0x003b0e6d */
  .word 0x003b8534 /* zeta index 60, original zeta 0x002c83da */
  .word 0x0058dc31 /* zeta index 61, original zeta 0x001c496e */
  .word 0x001f9d54 /* zeta index 62, original zeta 0x00330e2b */
  .word 0x00552f2e /* zeta index 63, original zeta 0x001c5b70 */
  /* Layer 7 - iteration 2 */
  .word 0x004cdbea /* zeta index 96, original zeta 0x005884cc */
  .word 0x0007c417 /* zeta index 98, original zeta 0x005b63d0 */
  .word 0x0000ad00 /* zeta index 100, original zeta 0x0035225e */
  .word 0x000dcd44 /* zeta index 102, original zeta 0x006c09d1 */
  .word 0x00470bcb /* zeta index 104, original zeta 0x006bc4d3 */
  .word 0x00193948 /* zeta index 106, original zeta 0x002e534c */
  .word 0x0024756c /* zeta index 108, original zeta 0x003b8820 */
  .word 0x000b98a1 /* zeta index 110, original zeta 0x002ca4f8 */
  .word 0x00040af0 /* zeta index 97, original zeta 0x001b4827 */
  .word 0x002f4588 /* zeta index 99, original zeta 0x005d787a */
  .word 0x006f16bf /* zeta index 101, original zeta 0x00400c7e */
  .word 0x003c675a /* zeta index 103, original zeta 0x005bd532 */
  .word 0x007fbe7f /* zeta index 105, original zeta 0x00258ecb */
  .word 0x004e49c1 /* zeta index 107, original zeta 0x00097a6c */
  .word 0x007ca7e0 /* zeta index 109, original zeta 0x006d285c */
  .word 0x006bc809 /* zeta index 111, original zeta 0x00337caa */
  .word 0x0002e46c /* zeta index 112, original zeta 0x0014b2a0 */
  .word 0x003036c2 /* zeta index 114, original zeta 0x0028f186 */
  .word 0x005b1c94 /* zeta index 116, original zeta 0x004af670 */
  .word 0x00141305 /* zeta index 118, original zeta 0x0075e826 */
  .word 0x00139e25 /* zeta index 120, original zeta 0x0005528c */
  .word 0x00737945 /* zeta index 122, original zeta 0x000f6e17 */
  .word 0x0051cea3 /* zeta index 124, original zeta 0x00459b7e */
  .word 0x00488058 /* zeta index 126, original zeta 0x005dbecb */
  .word 0x0049a809 /* zeta index 113, original zeta 0x00558536 */
  .word 0x00639ff7 /* zeta index 115, original zeta 0x0055795d */
  .word 0x007d2ae1 /* zeta index 117, original zeta 0x00234a86 */
  .word 0x00147792 /* zeta index 119, original zeta 0x0078de66 */
  .word 0x0067b0e1 /* zeta index 121, original zeta 0x007adf59 */
  .word 0x0069e803 /* zeta index 123, original zeta 0x005bf3da */
  .word 0x0044a79d /* zeta index 125, original zeta 0x00628b34 */
  .word 0x003a97d9 /* zeta index 127, original zeta 0x001a9e7b */
  /* Layer 8 - iteration 2 */
  .word 0x006c5954 /* zeta index 192, original zeta 0x00671ac7 */
  .word 0x0016e405 /* zeta index 196, original zeta 0x0008f201 */
  .word 0x00779935 /* zeta index 200, original zeta 0x00695688 */
  .word 0x0058711c /* zeta index 204, original zeta 0x0007c017 */
  .word 0x00612659 /* zeta index 208, original zeta 0x00519573 */
  .word 0x001ddd98 /* zeta index 212, original zeta 0x0058018c */
  .word 0x004f4cbf /* zeta index 216, original zeta 0x003cbd37 */
  .word 0x000c5ca5 /* zeta index 220, original zeta 0x00196926 */
  .word 0x001d4099 /* zeta index 193, original zeta 0x00201fc6 */
  .word 0x000bdbe7 /* zeta index 197, original zeta 0x006de024 */
  .word 0x0054aa0d /* zeta index 201, original zeta 0x001e6d3e */
  .word 0x00470c13 /* zeta index 205, original zeta 0x006dbfd4 */
  .word 0x00251d8b /* zeta index 209, original zeta 0x007ab60d */
  .word 0x00336898 /* zeta index 213, original zeta 0x003f4cf5 */
  .word 0x00027c1c /* zeta index 217, original zeta 0x00273333 */
  .word 0x0019379a /* zeta index 221, original zeta 0x001ef206 */
  .word 0x00590579 /* zeta index 194, original zeta 0x005ba4ff */
  .word 0x00221de8 /* zeta index 198, original zeta 0x00080e6d */
  .word 0x00665ff9 /* zeta index 202, original zeta 0x002603bd */
  .word 0x000910d8 /* zeta index 206, original zeta 0x0074d0bd */
  .word 0x002573b7 /* zeta index 210, original zeta 0x002867ba */
  .word 0x0002d4bb /* zeta index 214, original zeta 0x000b7009 */
  .word 0x0018aa08 /* zeta index 218, original zeta 0x00673957 */
  .word 0x00478168 /* zeta index 222, original zeta 0x0011c14e */
  .word 0x006ae5ae /* zeta index 195, original zeta 0x0060d772 */
  .word 0x0033f8cf /* zeta index 199, original zeta 0x0056038e */
  .word 0x0063b158 /* zeta index 203, original zeta 0x006a9dfa */
  .word 0x00463e20 /* zeta index 207, original zeta 0x0063e1e3 */
  .word 0x007d5c90 /* zeta index 211, original zeta 0x002decd4 */
  .word 0x006d73a8 /* zeta index 215, original zeta 0x00427e23 */
  .word 0x002dfd71 /* zeta index 219, original zeta 0x001a4b5d */
  .word 0x00646c3e /* zeta index 223, original zeta 0x004c76c8 */
  .word 0x0051813d /* zeta index 224, original zeta 0x003cf42f */
  .word 0x0021c4f7 /* zeta index 228, original zeta 0x003352d6 */
  .word 0x00795d46 /* zeta index 232, original zeta 0x002f6316 */
  .word 0x00666e99 /* zeta index 236, original zeta 0x000d1ff0 */
  .word 0x00530765 /* zeta index 240, original zeta 0x005e8885 */
  .word 0x0002cc93 /* zeta index 244, original zeta 0x0051e0ed */
  .word 0x00776a51 /* zeta index 248, original zeta 0x007b4064 */
  .word 0x003c15ca /* zeta index 252, original zeta 0x001cfe14 */
  .word 0x0035c539 /* zeta index 225, original zeta 0x007fb19a */
  .word 0x0070fbf5 /* zeta index 229, original zeta 0x00034760 */
  .word 0x001a4cd0 /* zeta index 233, original zeta 0x006f0a11 */
  .word 0x006f0634 /* zeta index 237, original zeta 0x00345824 */
  .word 0x005dc1b0 /* zeta index 241, original zeta 0x002faa32 */
  .word 0x0070f806 /* zeta index 245, original zeta 0x0065adb3 */
  .word 0x003bcf2c /* zeta index 249, original zeta 0x0035e1dd */
  .word 0x00155e68 /* zeta index 253, original zeta 0x0073f1ce */
  .word 0x003b0115 /* zeta index 226, original zeta 0x006af66c */
  .word 0x001a35e7 /* zeta index 230, original zeta 0x00085260 */
  .word 0x00645caf /* zeta index 234, original zeta 0x0007c0f1 */
  .word 0x007be5db /* zeta index 238, original zeta 0x000223d4 */
  .word 0x007973de /* zeta index 242, original zeta 0x0023fc65 */
  .word 0x00189c2a /* zeta index 246, original zeta 0x002ca5e6 */
  .word 0x007f234f /* zeta index 250, original zeta 0x00433aac */
  .word 0x0072f6b7 /* zeta index 254, original zeta 0x0010170e */
  .word 0x00041dc0 /* zeta index 227, original zeta 0x002e1669 */
  .word 0x0007340e /* zeta index 231, original zeta 0x00741e78 */
  .word 0x001d2668 /* zeta index 235, original zeta 0x00776d0b */
  .word 0x00455fdc /* zeta index 239, original zeta 0x0068c559 */
  .word 0x005cfd0a /* zeta index 243, original zeta 0x005e6942 */
  .word 0x0049c5aa /* zeta index 247, original zeta 0x0079e1fe */
  .word 0x006b16e0 /* zeta index 251, original zeta 0x00464ade */
  .word 0x001e29ce /* zeta index 255, original zeta 0x0074b6d7 */
