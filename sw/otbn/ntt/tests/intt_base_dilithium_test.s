/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for intt_base_dilithium. From
 * https://github.com/dop-amin/dilithium-on-opentitan-thesis
*/
.section .text.start

/* Entry point. */
.globl main
main:
  /* Init all-zero register. */
  bn.xor  w31, w31, w31

  /* MOD <= dmem[modulus] = DILITHIUM_Q */
  li      x2, 2
  la      x3, modulus
  bn.lid  x2, 0(x3)
  bn.wsrw 0x0, w2

  /* Load stack pointer */
  la x2, stack_end

  /* dmem[data] <= INTT(dmem[input]) */
  la  x10, input
  la  x11, twiddles
  jal  x1, intt_base_dilithium

  ecall

.data
.balign 32
/* First input */
input:
    .word 0x005d48ec
    .word 0x0021a486
    .word 0x007fd956
    .word 0x00513803
    .word 0x0020d597
    .word 0x000b753a
    .word 0x0051e05a
    .word 0x000eba0b
    .word 0x0070ab95
    .word 0x006a124d
    .word 0x003aa1cf
    .word 0x00509b8c
    .word 0x005d6ef6
    .word 0x00581b11
    .word 0x00416724
    .word 0x002928ca
    .word 0x0067fd57
    .word 0x00612635
    .word 0x001f0f39
    .word 0x0069694c
    .word 0x004f6e0f
    .word 0x00494bfe
    .word 0x0053dab9
    .word 0x0046eb19
    .word 0x001966c5
    .word 0x0026bb1d
    .word 0x000e0ae2
    .word 0x004f5513
    .word 0x0041e2be
    .word 0x00212792
    .word 0x000d3cd0
    .word 0x007ec2f2
    .word 0x005fa78b
    .word 0x00485194
    .word 0x0074f732
    .word 0x002e3b91
    .word 0x001c4ea8
    .word 0x0073e91f
    .word 0x002c1d03
    .word 0x0003733e
    .word 0x001f21a0
    .word 0x000f6d7c
    .word 0x0077587a
    .word 0x003eab0c
    .word 0x0008059b
    .word 0x0017bd4c
    .word 0x007bc5c1
    .word 0x001f8091
    .word 0x007a067b
    .word 0x0013d4ae
    .word 0x006e2d11
    .word 0x00265723
    .word 0x002213e5
    .word 0x004ee844
    .word 0x0004af11
    .word 0x000773d5
    .word 0x0063c820
    .word 0x0073929d
    .word 0x0023cadd
    .word 0x004dd2a3
    .word 0x005ce3e1
    .word 0x00214b4b
    .word 0x003cecc9
    .word 0x00704e4c
    .word 0x007c621f
    .word 0x003f51e8
    .word 0x005847e5
    .word 0x005fe291
    .word 0x006afdba
    .word 0x002bbb42
    .word 0x006007fe
    .word 0x003a24b5
    .word 0x003370d5
    .word 0x002382e5
    .word 0x005ad74f
    .word 0x007f60d5
    .word 0x006dcb02
    .word 0x0053a1ec
    .word 0x0005d6de
    .word 0x0000da27
    .word 0x00596dd6
    .word 0x007371e0
    .word 0x000bb138
    .word 0x0064e269
    .word 0x00621ec6
    .word 0x007fb198
    .word 0x0035b40c
    .word 0x00688879
    .word 0x004c1445
    .word 0x001535a1
    .word 0x0079aad2
    .word 0x005ff0ca
    .word 0x0063f79d
    .word 0x00449161
    .word 0x000018d1
    .word 0x007b2af4
    .word 0x007264b1
    .word 0x003594f9
    .word 0x001b8372
    .word 0x005edffc
    .word 0x001a7e2f
    .word 0x00445a3f
    .word 0x003d61c7
    .word 0x002f6231
    .word 0x00658b45
    .word 0x001d9560
    .word 0x001f9db8
    .word 0x00237f25
    .word 0x0061b8c8
    .word 0x0050a704
    .word 0x00052369
    .word 0x00399e7f
    .word 0x007950b6
    .word 0x00053f15
    .word 0x000c980c
    .word 0x007b7d0f
    .word 0x002451b1
    .word 0x003d8d33
    .word 0x00632a03
    .word 0x005e8ac4
    .word 0x0012ac7f
    .word 0x00686a84
    .word 0x00210f63
    .word 0x002fb7dd
    .word 0x00787387
    .word 0x0038fec8
    .word 0x00506c1a
    .word 0x007007d4
    .word 0x0064055d
    .word 0x004be313
    .word 0x00517c33
    .word 0x0041493e
    .word 0x004b56a9
    .word 0x00224b4e
    .word 0x005de278
    .word 0x007acb3a
    .word 0x002c6d1b
    .word 0x00407c70
    .word 0x00012caa
    .word 0x003a6c07
    .word 0x0006ad43
    .word 0x000da6e6
    .word 0x0038a26a
    .word 0x0039c794
    .word 0x00670aa4
    .word 0x0051be16
    .word 0x00169deb
    .word 0x007dee58
    .word 0x00731ed6
    .word 0x00268e06
    .word 0x0054eb97
    .word 0x004d54a4
    .word 0x004f1ab6
    .word 0x005da4b3
    .word 0x00189581
    .word 0x0057aa0f
    .word 0x003df4bb
    .word 0x00057dbf
    .word 0x001981fe
    .word 0x00014e3d
    .word 0x0050f1f0
    .word 0x0052eb8c
    .word 0x0032fe6f
    .word 0x0055391c
    .word 0x005767a2
    .word 0x0005cc0b
    .word 0x007fc8b2
    .word 0x00361987
    .word 0x00055595
    .word 0x006f261a
    .word 0x002eb8e3
    .word 0x00061ed4
    .word 0x0024f7dd
    .word 0x006a749e
    .word 0x004a0230
    .word 0x00593b36
    .word 0x0058d9bb
    .word 0x0047480a
    .word 0x00288503
    .word 0x0015a3af
    .word 0x00329308
    .word 0x004a242c
    .word 0x005a80aa
    .word 0x00180e0f
    .word 0x00683d44
    .word 0x003fbced
    .word 0x0039b459
    .word 0x001a66ab
    .word 0x0002d6f3
    .word 0x007d8b9d
    .word 0x00290e47
    .word 0x006699a0
    .word 0x0041415a
    .word 0x00514709
    .word 0x000c9ca3
    .word 0x0025287e
    .word 0x00780b0e
    .word 0x006a2ba9
    .word 0x007baad1
    .word 0x00346a9a
    .word 0x002d5ede
    .word 0x007ea727
    .word 0x000ae53d
    .word 0x001912cf
    .word 0x0036b4c7
    .word 0x001b31d4
    .word 0x005332eb
    .word 0x00118338
    .word 0x0002da94
    .word 0x00030772
    .word 0x0064ee68
    .word 0x0037ef2b
    .word 0x00054aca
    .word 0x0036f311
    .word 0x00416fe8
    .word 0x0010b58a
    .word 0x000cfc47
    .word 0x00055418
    .word 0x005e3fb4
    .word 0x007a8656
    .word 0x003eb1e1
    .word 0x00090563
    .word 0x005965c3
    .word 0x001a8f47
    .word 0x0022ca59
    .word 0x00468c90
    .word 0x00175e1e
    .word 0x000fd95a
    .word 0x003ffdff
    .word 0x000c9ea7
    .word 0x00517eb8
    .word 0x004d75a8
    .word 0x002b7935
    .word 0x0006c396
    .word 0x0011731c
    .word 0x0026ca35
    .word 0x000d66e2
    .word 0x00691ae6
    .word 0x00399ac0
    .word 0x0069925b
    .word 0x007fa251
    .word 0x0051cc4d
    .word 0x00648959
    .word 0x00170675
    .word 0x0011fc7f
    .word 0x00577336
    .word 0x0068c888
    .word 0x00658613
    .word 0x0079b4b4
    .word 0x006cfeb6
    .word 0x007f9072
    .word 0x004e234b
    .word 0x002aa3d6
    .word 0x00353929
    .word 0x0020c26a
    .word 0x005478ce

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
  /* Inv Layer 8 - 1 */
  .word 0xc39d4bcc, 0x1657e9cd
  .word 0x19d90a0f, 0xdfc9d6b6
  .word 0xd5387e76, 0x17e25e67
  .word 0x87b65a88, 0xc5f555c9
  .word 0x299ca8d7, 0x734716df
  .word 0x0179c26e, 0x7969034e
  .word 0x8843b9de, 0x94214f2b
  .word 0x10ef9bc6, 0x09418a50
  /* Inv Layer 7 - 1 */
  .word 0x8ab2fbaa, 0xcab5b7d8
  .word 0x6edb07e5, 0x44538057
  .word 0x768e6aae, 0x3ab8479c
  .word 0x5c39c9ba, 0x74a62ea2
  /* Inv Layer 6 - 1 */
  .word 0x55770316, 0xc73aef2d
  .word 0xc0b585e1, 0x99ca1d53
  /* Inv Layer 5 - 1 */
  .word 0xf77252a6, 0xba3ce5c4
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 2 */
  .word 0x6c4fc118, 0x0bff05a9
  .word 0xcebb5b3a, 0xa69ddc29
  .word 0x1dd76ba0, 0x3471b805
  .word 0xfa657369, 0x5c152c92
  .word 0x45d7634e, 0x42fe3d09
  .word 0x0cdb7cc6, 0xb7f533dd
  .word 0x444db4e5, 0xa093c1af
  .word 0x59c7a937, 0x42bfa764
  /* Inv Layer 7 - 2 */
  .word 0x2bfafa67, 0x47ea4802
  .word 0x18d3acba, 0xe11c1944
  .word 0x306a5a36, 0x0a03d0e0
  .word 0xd8b9e4c8, 0xf5583e24
  /* Inv Layer 6 - 2 */
  .word 0x4e1b262e, 0xc75efc30
  .word 0x88d7cee3, 0xa6e20533
  /* Inv Layer 5 - 2 */
  .word 0x857d5e4d, 0xa9fd5200
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 3 */
  .word 0x751d907a, 0x2e40dfdb
  .word 0x07f64983, 0xfbb745da
  .word 0x21bc08bf, 0x97358633
  .word 0x32ef8b7e, 0xe5b98e98
  .word 0xc5a4999c, 0x10ea2667
  .word 0x371468ad, 0xf07a3cae
  .word 0xcb5936b7, 0x21b44ccf
  .word 0x0d08b814, 0xa1221d45
  /* Inv Layer 7 - 3 */
  .word 0xd7069dfa, 0x0e06b791
  .word 0xd7cfea4b, 0x13f4b304
  .word 0x056b9adc, 0xb9594ae0
  .word 0x49993fbd, 0x69ed9c93
  /* Inv Layer 6 - 3 */
  .word 0x8971b75b, 0x89c59852
  .word 0xe2d9caad, 0xeefd4f75
  /* Inv Layer 5 - 3 */
  .word 0x0097e1f8, 0x6d83f422
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 4 */
  .word 0xf1944930, 0x1788f40d
  .word 0xcb87142e, 0xef5715e6
  .word 0x1dcf8ba8, 0xf96f9bf4
  .word 0xbc652bd3, 0x9940a4f6
  .word 0xf7c270ad, 0xa3bc1dbf
  .word 0x89e04f00, 0x29dda114
  .word 0x945aa581, 0x005ce538
  .word 0x5cd4bc76, 0x85f9213c
  /* Inv Layer 7 - 4 */
  .word 0x388e371d, 0x54e27ff6
  .word 0x9f7a5b58, 0xae0876c1
  .word 0x6c8b11ec, 0x54cac808
  .word 0xfa35b579, 0xd690646b
  /* Inv Layer 6 - 4 */
  .word 0xefc4bd50, 0x9e7b5b99
  .word 0xe7327cd1, 0x588163a7
  /* Inv Layer 5 - 4 */
  .word 0xca522af7, 0x13a17034
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 5 */
  .word 0x36f542e3, 0x66ec2c3d
  .word 0x70d96779, 0xdc748167
  .word 0xcd842d71, 0xc20c7799
  .word 0xe7408654, 0xcd20fca4
  .word 0xa3ee1a3f, 0xcb5c1d70
  .word 0xce9f9849, 0x3159aa07
  .word 0xfb0689ad, 0xb185fc1b
  .word 0x613ed2f3, 0x86672cbe
  /* Inv Layer 7 - 5 */
  .word 0x2839fe30, 0x98ece808
  .word 0xe8c8f06b, 0xa69fb8a0
  .word 0x0671de6b, 0x2578a7df
  .word 0xb702e94d, 0x88d1f56b
  /* Inv Layer 6 - 5 */
  .word 0x8efca80d, 0x78a9f38b
  .word 0x30e3807f, 0x3473145c
  /* Inv Layer 5 - 5 */
  .word 0x641fd72e, 0xd360fc98
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 6 */
  .word 0x24e1ea31, 0x7ae273a7
  .word 0xfa551f54, 0xe91a34ba
  .word 0x99151614, 0x81466897
  .word 0xc435ddf0, 0x4fd0dd97
  .word 0x050823ff, 0xa40f5c8f
  .word 0xb505d40b, 0xaf1c53b6
  .word 0xb5b2572b, 0x0a567d8a
  .word 0x3d82b032, 0x5cac4658
  /* Inv Layer 7 - 6 */
  .word 0x6345508e, 0xed0669c0
  .word 0xcd80d09a, 0xa3423947
  .word 0x004314c5, 0xb4cf9e7e
  .word 0x71c4dc54, 0x28406bca
  /* Inv Layer 6 - 6 */
  .word 0x41642a88, 0x3b223617
  .word 0x94dcba05, 0x8d3d643e
  /* Inv Layer 5 - 6 */
  .word 0x2ac0c1db, 0xb50984f7
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 7 */
  .word 0x73609940, 0x380a3e1f
  .word 0xedd9c696, 0x162410d7
  .word 0x71c44c30, 0x24496c12
  .word 0x4ef185c4, 0xf07bf11b
  .word 0x386b6c6b, 0x2a8eb157
  .word 0x330cd2cf, 0xb3e57ff8
  .word 0x568187b5, 0xc3164a0c
  .word 0x1091bc4e, 0x2d1e3934
  /* Inv Layer 7 - 7 */
  .word 0x871311b7, 0x4827a759
  .word 0xe45e8fdc, 0x27b64d43
  .word 0x219aea78, 0x7fc6f6be
  .word 0xfea5a96e, 0x95a0acff
  /* Inv Layer 6 - 7 */
  .word 0x74be7cb6, 0x6d30cf59
  .word 0x94e8ff16, 0x18f93e1d
  /* Inv Layer 5 - 7 */
  .word 0x75e7aaff, 0xcba1fae7
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 8 */
  .word 0x97f45fe9, 0x53cdd8ce
  .word 0xbbb31d50, 0xefdf1de7
  .word 0xe84242c1, 0x2408bbe6
  .word 0xd22c817d, 0xee178404
  .word 0x29ff2576, 0x3e20a5ad
  .word 0x4dc88185, 0x48882578
  .word 0xc5702a80, 0xbfb06098
  .word 0x27171f7a, 0x3196d953
  /* Inv Layer 7 - 8 */
  .word 0xa15d4810, 0x44e04587
  .word 0xf073ef1b, 0x490aa416
  .word 0xf7e81a17, 0xc9620aef
  .word 0x6621b5a2, 0x4eca1be9
  /* Inv Layer 6 - 8 */
  .word 0x3236e154, 0xca41aad6
  .word 0x33e87fb9, 0x97adb23d
  /* Inv Layer 5 - 8 */
  .word 0x40b4809f, 0x629a6dd6
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 9 */
  .word 0x3bf42091, 0x428fcd6e
  .word 0x9b01bb39, 0x1902d282
  .word 0xd7e86c6c, 0x396ce6c6
  .word 0x0dc7a9cf, 0xc1b59de4
  .word 0x2bb08dcd, 0x6a100d2f
  .word 0x655cda6c, 0x84951e3e
  .word 0xda345762, 0x3ab6411a
  .word 0x28b8b1dc, 0x0e0368be
  /* Inv Layer 7 - 9 */
  .word 0x2bb22833, 0x9c766c62
  .word 0xc7671437, 0x6348a562
  .word 0xd6ca0ad6, 0xf8cf15d3
  .word 0x0bab30b5, 0xcaf5cbdd
  /* Inv Layer 6 - 9 */
  .word 0x10796439, 0xbe23655d
  .word 0xb840d8c6, 0x9cf7569b
  /* Inv Layer 5 - 9 */
  .word 0x406923c9, 0x28cf337b
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 10 */
  .word 0x201aba6f, 0x43c4b6a6
  .word 0xc5dae12d, 0x28066b4a
  .word 0xc6e73c42, 0xed44653e
  .word 0x5b75cabc, 0x29637089
  .word 0x6c63f826, 0xb33bdb90
  .word 0xaf7abd51, 0x02ba5890
  .word 0xd9ccf78b, 0xfbaad4bd
  .word 0x731293bf, 0xa4698518
  /* Inv Layer 7 - 10 */
  .word 0x27f60f34, 0x61aae9f7
  .word 0x00b3b6ed, 0xc347063b
  .word 0x25873b84, 0x6a8fa113
  .word 0x14801bde, 0x7f460282
  /* Inv Layer 6 - 10 */
  .word 0x092db15a, 0x7ac50a4d
  .word 0x93dcf817, 0xc0b603ff
  /* Inv Layer 5 - 10 */
  .word 0xaff92eec, 0xeb54f967
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 11 */
  .word 0xcf3f4433, 0x00611a45
  .word 0xb40c61b1, 0xd9b01050
  .word 0xd9e37129, 0xaf438983
  .word 0x841ed0ac, 0x9e61611b
  .word 0xd95b752b, 0x75416d70
  .word 0x4f1f5337, 0xda1fba3a
  .word 0xadc840b5, 0xb9dc3198
  .word 0xa92c81cf, 0x8d87fee4
  /* Inv Layer 7 - 11 */
  .word 0x4baad81f, 0x65db5409
  .word 0x0c8e497a, 0xb4c75a6d
  .word 0x70d39e06, 0xfad1044b
  .word 0x5aa76324, 0x114717a3
  /* Inv Layer 6 - 11 */
  .word 0x579963aa, 0x6b1c5e41
  .word 0x92cf88bd, 0xde894a95
  /* Inv Layer 5 - 11 */
  .word 0x22334c8f, 0x0d42eaa0
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 12 */
  .word 0xf9cc2b18, 0x61279923
  .word 0xcaf930b7, 0x08335cc6
  .word 0x66190f78, 0x6e54603b
  .word 0x96fff2cf, 0xb71152e6
  .word 0x82806b16, 0x34c2101a
  .word 0x4a781b72, 0xbd02ed41
  .word 0xf73bb700, 0x3625e10b
  .word 0xf58b30e2, 0x7ea85918
  /* Inv Layer 7 - 12 */
  .word 0xad0e0628, 0x5a7d4e9e
  .word 0xbe63294e, 0xdce7c637
  .word 0x1e0a7863, 0xf1419e85
  .word 0x97c40dd4, 0xd15250f1
  /* Inv Layer 6 - 12 */
  .word 0x5cfa45d8, 0xe3a10e7c
  .word 0x75f271b1, 0xf3f5b585
  /* Inv Layer 5 - 12 */
  .word 0x10c91223, 0x6ba99d90
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 13 */
  .word 0x6dd7f121, 0x4b0161c2
  .word 0x177aba80, 0x07a68592
  .word 0x100a5676, 0xec92bcd6
  .word 0x6ca82f33, 0x6c79597d
  .word 0x9e0876e2, 0x7321af85
  .word 0xc1ef745a, 0xae2f8083
  .word 0x5f61ebbd, 0x682f1af6
  .word 0x1404bf08, 0x337a2021
  /* Inv Layer 7 - 13 */
  .word 0xfc1f73e5, 0x80fb2fc9
  .word 0x6ef9fda2, 0x21e490e0
  .word 0x6072bff0, 0x5b2592ae
  .word 0x61735c15, 0xaa1f5280
  /* Inv Layer 6 - 13 */
  .word 0x8864bc1f, 0xdc919eae
  .word 0x4d83b854, 0x8ed3c7d4
  /* Inv Layer 5 - 13 */
  .word 0x92758e3f, 0x3327b787
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 14 */
  .word 0x0ff60562, 0x72d786fc
  .word 0x01524c91, 0x78dfd704
  .word 0x31473d6d, 0xcf38a28a
  .word 0xf0dd316b, 0x3c77ef82
  .word 0xe6fb0af5, 0x4af7bf59
  .word 0xe4374209, 0xe12aa0e5
  .word 0xc73599d9, 0xe6df9e19
  .word 0xe47c6350, 0x00d97e5d
  /* Inv Layer 7 - 14 */
  .word 0x1e8db731, 0x748f7cf6
  .word 0x7cbe4a9a, 0xc4cff072
  .word 0xc4c24d0a, 0xc20bd771
  .word 0x266ab060, 0xb35b6f75
  /* Inv Layer 6 - 14 */
  .word 0x6dbb15eb, 0xbfceb02c
  .word 0x32c2aa46, 0x5f070503
  /* Inv Layer 5 - 14 */
  .word 0x20fcf6fc, 0xaea405a4
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 15 */
  .word 0x618ca667, 0x718b05de
  .word 0x24927855, 0x64587b56
  .word 0x72d6bcca, 0x462622fc
  .word 0x6b89a192, 0x78de48a0
  .word 0x94ae7274, 0x79213b5c
  .word 0x25bf8f99, 0xec8b24f0
  .word 0xb5a25b2c, 0xfd560586
  .word 0xf7d80c14, 0xdbe2b2f4
  /* Inv Layer 7 - 15 */
  .word 0x306ca4c9, 0x085f2fbb
  .word 0xbd83d37a, 0x5f5a15c6
  .word 0x95d1993b, 0x6272c9ed
  .word 0x2c5e5d3f, 0x8035765d
  /* Inv Layer 6 - 15 */
  .word 0x942780b8, 0x6d8e7ec4
  .word 0xa1fee676, 0xac4894cc
  /* Inv Layer 5 - 15 */
  .word 0xe0b74e13, 0x7c1da06f
  /* Padding */
  .word 0x00000000, 0x00000000
  /* Inv Layer 8 - 16 */
  .word 0x6cd2efe3, 0xab4de422
  .word 0x4abb7047, 0x01ce8b9f
  .word 0xbb72e743, 0x36619dfa
  .word 0x661aa1dd, 0xaebb3f72
  .word 0x8b5ee8a4, 0x2c7941f7
  .word 0xb93ca7b8, 0x513dd8d3
  .word 0x97e746a2, 0x3b1f3f59
  .word 0xc01ae139, 0xfff24a92
  /* Inv Layer 7 - 16 */
  .word 0x5ce70708, 0x8a54b819
  .word 0x7058773e, 0x5081c1cf
  .word 0x2eb2aa4e, 0xd8f8cc81
  .word 0x7810391f, 0xa220a6e5
  /* Inv Layer 6 - 16 */
  .word 0xfd1304c8, 0x9ec5761f
  .word 0xad568848, 0x91f62a66
  /* Inv Layer 5 - 16 */
  .word 0xacbe8047, 0x66f49657
  /* Padding */
  .word 0x00000000, 0x00000000
  /* ---------------- */
  /* Inv Layer 4 */
  .word 0xae213af3, 0x254dc526
  .word 0xa0f3abaa, 0xeef89a48
  .word 0x581ff54e, 0x1eb51b09
  .word 0xa0b34390, 0x8cfe3a74
  .word 0x3fe6fb40, 0xbeeff47f
  .word 0x0af96444, 0xae1024ad
  .word 0xb81bb17d, 0x93c9492a
  .word 0xc835b7de, 0x12613e2a
  /* Inv Layer 3 */
  .word 0xf1c02827, 0x61cb9e23
  .word 0x1ac460e3, 0x6017a128
  .word 0x17c3c0c1, 0x58172118
  .word 0xf8c1a879, 0x61cc1e43
  /* Inv Layer 2 */
  .word 0x0fd9f05d, 0x8d187503
  .word 0x4fb1e7db, 0x8cf87102
  /* Inv Layer 1 (Including ninv and plant for conversion to normal domain) */
  .word 0x78196f6c, 0x868d624b
  /* ninv * plant**2 * qprime */
  .word 0x0ccf51bb, 0xfeb7b9f1
  /* Padding */
  .word 0x00000000

.zero 512
stack_end:
.zero 1