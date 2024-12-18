/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for ntt_base_dilithium_test
 * From https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/crypto/tests/ntt_base_dilithium_test.s
*/

.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  li      x2,  2
  la      x3,  modulus
  bn.lid  x2,  0(x3)
  bn.wsrw 0x0, w2

  /* Load stack pointer */
  la x2, stack_end

  /* dmem[data] <= NTT(dmem[input]) */
  la  x10, input
  la  x11, twiddles
  la  x12, input /* compute in-place */
  jal  x1, ntt_base_dilithium

  ecall

.data
.balign 32
/* First input */
input:
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

/* Modulus for reduction */
.global modulus
modulus:
  .word 0x007fe001
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

/* Second input */
twiddles:
    /* Layers 1-4 */
    .word 0x00ca2087, 0x92e0bb09
    .word 0xb04e1826, 0x73078efd
    .word 0xf0260fa4, 0x72e78afc
    .word 0x073e5788, 0x9e33e1bc
    .word 0xe83c3f40, 0xa7e8dee7
    .word 0xe53b9f1e, 0x9fe85ed7
    .word 0x0e3fd7da, 0x9e3461dc
    .word 0x37ca4823, 0xed9ec1d5
    .word 0x47e44e84, 0x6c36b6d5
    .word 0xf5069bbd, 0x51efdb52
    .word 0xc01904c1, 0x41100b80
    .word 0x5f4cbc71, 0x7301c58b
    .word 0xa7e00ab3, 0xe14ae4f6
    .word 0x5f0c5457, 0x110765b7
    .word 0x51dec50e, 0xdab23ad9
    /* Padding */
    .word 0x00000000
    .word 0 /* Padding */
    /* Layer 5 - 1 */
    .word 0x53417fba, 0x990b69a8
    /* Layer 6 - 1 */
    .word 0x52a977b9, 0x6e09d599
    .word 0x02ecfb39, 0x613a89e0
    /* Layer 7 - 1 */
    .word 0x87efc6e2, 0x5ddf591a
    .word 0xd14d55b3, 0x2707337e
    .word 0x8fa788c3, 0xaf7e3e30
    .word 0xa318f8f9, 0x75ab47e6
    /* Layer 8 - 1 */
    .word 0x3fe51ec8, 0x000db56d
    .word 0x6818b95f, 0xc4e0c0a6
    .word 0x46c35849, 0xaec2272c
    .word 0x74a1175d, 0xd386be08
    .word 0x99e55e24, 0x5144c08d
    .word 0x448d18be, 0xc99e6205
    .word 0xb5448fba, 0xfe317460
    .word 0x932d101e, 0x54b21bdd
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 2 */
    .word 0x1f48b1ee, 0x83e25f90
    /* Layer 6 - 2 */
    .word 0x5e01198b, 0x53b76b33
    .word 0x6bd87f49, 0x9271813b
    /* Layer 7 - 2 */
    .word 0xd3a1a2c2, 0x7fca89a2
    .word 0x6a2e66c6, 0x9d8d3612
    .word 0x427c2c87, 0xa0a5ea39
    .word 0xcf935b38, 0xf7a0d044
    /* Layer 8 - 2 */
    .word 0x0827f3ed, 0x241d4d0b
    .word 0x4a5da4d5, 0x02a9fa79
    .word 0xda407068, 0x1374db0f
    .word 0x6b518d8d, 0x86dec4a3
    .word 0x94765e6f, 0x8721b75f
    .word 0x8d294337, 0xb9d9dd03
    .word 0xdb6d87ac, 0x9ba784a9
    .word 0x9e73599a, 0x8e74fa21
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 3 */
    .word 0xdf030905, 0x515bfa5b
    /* Layer 6 - 3 */
    .word 0xcd3d55bb, 0xa0f8fafc
    .word 0x9244ea16, 0x40314fd3
    /* Layer 7 - 3 */
    .word 0xd9954fa1, 0x4ca4908a
    .word 0x3b3db2f7, 0x3df4288e
    .word 0x8341b567, 0x3b300f8d
    .word 0xe17248d0, 0x8b708309
    /* Layer 8 - 3 */
    .word 0x1b839cb1, 0xff2681a2
    .word 0x38ca6628, 0x192061e6
    .word 0x1bc8bdf8, 0x1ed55f1a
    .word 0x1904f50c, 0xb50840a6
    .word 0x0f22ce96, 0xc388107d
    .word 0xceb8c294, 0x30c75d75
    .word 0xfeadb370, 0x872028fb
    .word 0xf009fa9f, 0x8d287903
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 4 */
    .word 0x6d8a71c2, 0xccd84878
    /* Layer 6 - 4 */
    .word 0xb27c47ad, 0x712c382b
    .word 0x779b43e2, 0x236e6151
    /* Layer 7 - 4 */
    .word 0x9e8ca3ec, 0x55e0ad7f
    .word 0x9f8d4011, 0xa4da6d51
    .word 0x9106025f, 0xde1b6f1f
    .word 0x03e08c1c, 0x7f04d036
    /* Layer 8 - 4 */
    .word 0xebfb40f9, 0xcc85dfde
    .word 0xa09e1444, 0x97d0e509
    .word 0x3e108ba7, 0x51d07f7c
    .word 0x61f7891f, 0x8cde507a
    .word 0x9357d0ce, 0x9386a682
    .word 0xeff5a98b, 0x136d4329
    .word 0xe8854581, 0xf8597a6d
    .word 0x92280ee0, 0xb4fe9e3d
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 5 */
    .word 0xef36edde, 0x9456626f
    /* Layer 6 - 5 */
    .word 0x8a0d8e50, 0x0c0a4a7a
    .word 0xa305ba29, 0x1c5ef183
    /* Layer 7 - 5 */
    .word 0x683bf22d, 0x2eadaf0e
    .word 0xe1f5879e, 0x0ebe617a
    .word 0x419cd6b3, 0x231839c8
    .word 0x52f1f9d9, 0xa582b161
    /* Layer 8 - 5 */
    .word 0x0a74cf1f, 0x8157a6e7
    .word 0x08c44901, 0xc9da1ef4
    .word 0xb587e48f, 0x42fd12be
    .word 0x7d7f94eb, 0xcb3defe5
    .word 0x69000d32, 0x48eead19
    .word 0x99e6f089, 0x91ab9fc4
    .word 0x3506cf4a, 0xf7cca339
    .word 0x0633d4e9, 0x9ed866dc
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 6 */
    .word 0xddccb372, 0xf2bd155f
    /* Layer 6 - 6 */
    .word 0x6d307744, 0x2176b56a
    .word 0xa8669c57, 0x94e3a1be
    /* Layer 7 - 6 */
    .word 0xa5589cdd, 0xeeb8e85c
    .word 0x8f2c61fb, 0x052efbb4
    .word 0xf371b687, 0x4b38a592
    .word 0xb45527e2, 0x9a24abf6
    /* Layer 8 - 6 */
    .word 0x56d37e32, 0x7278011b
    .word 0x5237bf4c, 0x4623ce67
    .word 0xb0e0acca, 0x25e045c5
    .word 0x26a48ad6, 0x8abe928f
    .word 0x7be12f55, 0x619e9ee4
    .word 0x261c8ed8, 0x50bc767c
    .word 0x4bf39e50, 0x264fefaf
    .word 0x30c0bbce, 0xff9ee5ba
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 7 */
    .word 0x5006d115, 0x14ab0698
    /* Layer 6 - 7 */
    .word 0x6c2307ea, 0x3f49fc00
    .word 0xf6d24ea7, 0x853af5b2
    /* Layer 7 - 7 */
    .word 0xeb7fe423, 0x80b9fd7d
    .word 0xda78c47d, 0x95705eec
    .word 0xff4c4914, 0x3cb8f9c4
    .word 0xd809f0cd, 0x9e551608
    /* Layer 8 - 7 */
    .word 0x8ced6c42, 0x5b967ae7
    .word 0x26330876, 0x04552b42
    .word 0x508542b0, 0xfd45a76f
    .word 0x939c07db, 0x4cc4246f
    .word 0xa48a3545, 0xd69c8f76
    .word 0x3918c3bf, 0x12bb9ac1
    .word 0x3a251ed4, 0xd7f994b5
    .word 0xdfe54592, 0xbc3b4959
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 8 */
    .word 0xbf96dc38, 0xd730cc84
    /* Layer 6 - 8 */
    .word 0x47bf273b, 0x6308a964
    .word 0xef869bc8, 0x41dc9aa2
    /* Layer 7 - 8 */
    .word 0xf454cf4c, 0x350a3422
    .word 0x2935f52b, 0x0730ea2c
    .word 0x3898ebca, 0x9cb75a9d
    .word 0xd44dd7ce, 0x6389939d
    /* Layer 8 - 8 */
    .word 0xd7474e25, 0xf1fc9741
    .word 0x25cba89f, 0xc549bee5
    .word 0x9aa32595, 0x7b6ae1c1
    .word 0xd44f7234, 0x95eff2d0
    .word 0xf2385632, 0x3e4a621b
    .word 0x28179395, 0xc6931939
    .word 0x64fe44c8, 0xe6fd2d7d
    .word 0xc40bdf70, 0xbd703291
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 9 */
    .word 0xbf4b7f62, 0x9d659229
    /* Layer 6 - 9 */
    .word 0xcc178048, 0x68524dc2
    .word 0xcdc91ead, 0x35be5529
    /* Layer 7 - 9 */
    .word 0x99de4a5f, 0xb135e416
    .word 0x0817e5ea, 0x369df510
    .word 0x0f8c10e6, 0xb6f55be9
    .word 0x5ea2b7f1, 0xbb1fba78
    /* Layer 8 - 9 */
    .word 0xd8e8e087, 0xce6926ac
    .word 0x3a8fd581, 0x404f9f67
    .word 0xb2377e7c, 0xb777da87
    .word 0xd600da8b, 0xc1df5a52
    .word 0x2dd37e84, 0x11e87bfb
    .word 0x17bdbd40, 0xdbf74419
    .word 0x444ce2b1, 0x1020e218
    .word 0x680ba018, 0xac322731
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 10 */
    .word 0x8a185502, 0x345e0518
    /* Layer 6 - 10 */
    .word 0x6b1700eb, 0xe706c1e2
    .word 0x8b41834b, 0x92cf30a6
    /* Layer 7 - 10 */
    .word 0x015a5693, 0x6a5f5300
    .word 0xde651589, 0x80390941
    .word 0x1ba17025, 0xd849b2bc
    .word 0x78ecee4a, 0xb7d858a6
    /* Layer 8 - 10 */
    .word 0xef6e43b3, 0xd2e1c6cb
    .word 0xa97e784c, 0x3ce9b5f3
    .word 0xccf32d32, 0x4c1a8007
    .word 0xc7949396, 0xd5714ea8
    .word 0xb10e7a3d, 0x0f840ee4
    .word 0x8e3bb3d1, 0xdbb693ed
    .word 0x1226396b, 0xe9dbef28
    .word 0x8c9f66c1, 0xc7f5c1e0
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 11 */
    .word 0xd53f3e26, 0x4af67b08
    /* Layer 6 - 11 */
    .word 0x6b2345fc, 0x72c29bc1
    .word 0xbe9bd579, 0xc4ddc9e8
    /* Layer 7 - 11 */
    .word 0x8e3b23ad, 0xd7bf9435
    .word 0xffbceb3c, 0x4b306181
    .word 0x327f2f67, 0x5cbdc6b8
    .word 0x9cbaaf73, 0x12f9963f
    /* Layer 8 - 11 */
    .word 0xc27d4fcf, 0xa353b9a7
    .word 0x4a4da8d6, 0xf5a98275
    .word 0x4afa2bf6, 0x50e3ac49
    .word 0xfaf7dc02, 0x5bf0a370
    .word 0x3bca2211, 0xb02f2268
    .word 0x66eae9ed, 0x7eb99768
    .word 0x05aae0ad, 0x16e5cb45
    .word 0xdb1e15d0, 0x851d8c58
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 12 */
    .word 0x9be028d3, 0x2c9f0367
    /* Layer 6 - 12 */
    .word 0xcf1c7f82, 0xcb8ceba3
    .word 0x710357f4, 0x87560c74
    /* Layer 7 - 12 */
    .word 0x48fd16b4, 0x772e0a94
    .word 0xf98e2196, 0xda875820
    .word 0x17370f96, 0x5960475f
    .word 0xd7c601d1, 0x671317f7
    /* Layer 8 - 12 */
    .word 0x9ec12d0e, 0x7998d341
    .word 0x04f97654, 0x4e7a03e4
    .word 0x316067b8, 0xcea655f8
    .word 0x5c11e5c2, 0x34a3e28f
    .word 0x18bf79ad, 0x32df035b
    .word 0x327bd290, 0x3df38866
    .word 0x8f269888, 0x238b7e98
    .word 0xc90abd1e, 0x9913d3c2
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 13 */
    .word 0x35add50a, 0xec5e8fcb
    /* Layer 6 - 13 */
    .word 0x18cd8330, 0xa77e9c58
    .word 0x103b42b1, 0x6184a466
    /* Layer 7 - 13 */
    .word 0x05ca4a88, 0x296f9b94
    .word 0x9374ee15, 0xab3537f7
    .word 0x6085a4a9, 0x51f7893e
    .word 0xc771c8e4, 0xab1d8009
    /* Layer 8 - 13 */
    .word 0xa32b438b, 0x7a06dec3
    .word 0x6ba55a80, 0xffa31ac7
    .word 0x761fb101, 0xd6225eeb
    .word 0x083d8f54, 0x5c43e240
    .word 0x439ad42e, 0x66bf5b09
    .word 0xe2307459, 0x0690640b
    .word 0x3478ebd3, 0x10a8ea19
    .word 0x0e6bb6d1, 0xe8770bf2
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 14 */
    .word 0xff681e09, 0x927c0bdd
    /* Layer 6 - 14 */
    .word 0x1d263554, 0x1102b08a
    .word 0x768e48a6, 0x763a67ad
    /* Layer 7 - 14 */
    .word 0xb666c044, 0x9612636c
    .word 0xfa946525, 0x46a6b51f
    .word 0x283015b6, 0xec0b4cfb
    .word 0x28f96207, 0xf1f9486e
    /* Layer 8 - 14 */
    .word 0xf2f747ed, 0x5edde2ba
    .word 0x34a6c94a, 0xde4bb330
    .word 0xc8eb9754, 0x0f85c351
    .word 0x3a5b6665, 0xef15d998
    .word 0xcd107483, 0x1a467167
    .word 0xde43f742, 0x68ca79cc
    .word 0xf809b67e, 0x0448ba25
    .word 0x8ae26f87, 0xd1bf2024
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 15 */
    .word 0x7a82a1b4, 0x5602adff
    /* Layer 6 - 15 */
    .word 0x7728311e, 0x591dfacc
    .word 0xb1e4d9d3, 0x38a103cf
    /* Layer 7 - 15 */
    .word 0x27461b39, 0x0aa7c1db
    .word 0xcf95a5cb, 0xf5fc2f1f
    .word 0xe72c5347, 0x1ee3e6bb
    .word 0xd405059a, 0xb815b7fd
    /* Layer 8 - 15 */
    .word 0xa63856ca, 0xbd40589b
    .word 0xbbb24b1c, 0x5f6c3e50
    .word 0xf324833b, 0x480acc22
    .word 0xba289cb3, 0xbd01c2f6
    .word 0x059a8c98, 0xa3ead36d
    .word 0xe2289461, 0xcb8e47fa
    .word 0x3144a4c7, 0x596223d6
    .word 0x93b03ee9, 0xf400fa56
    /* Padding */
    .word 0x00000000, 0x00000000
    /* Layer 5 - 16 */
    .word 0x088dad5b, 0x45c31a3b
    /* Layer 6 - 16 */
    .word 0x3f4a7a20, 0x6635e2ac
    .word 0xaa88fceb, 0x38c510d2
    /* Layer 7 - 16 */
    .word 0xa3c63647, 0x8b59d15d
    .word 0x89719553, 0xc547b863
    .word 0x9124f81c, 0xbbac7fa8
    .word 0x754d0457, 0x354a4827
    /* Layer 8 - 16 */
    .word 0xef10643b, 0xf6be75af
    .word 0x77bc4623, 0x6bdeb0d4
    .word 0xfe863d93, 0x8696fcb1
    .word 0xd663572a, 0x8cb8e920
    .word 0x7849a579, 0x3a0aaa36
    .word 0x2ac7818b, 0xe81da198
    .word 0xe626f5f2, 0x20362949
    .word 0x3c62b435, 0xe9a81632
/* Padding */
.word 0x00000000
.zero 512
stack_end:
.zero 1