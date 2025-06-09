/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for intt_mldsa
 * Inspired from
 * https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/crypto/tests/intt_dilithium_test.s
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
  jal  x1, intt_mldsa

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

twiddles: /* multiplied with -1 and in Montgomery space */
  /* Layer 8 - 1 */
  .word 0x0061b633 /* zeta index 255, original -zeta = 0x000b292a */
  .word 0x0014c921 /* zeta index 251, original -zeta = 0x00399523 */
  .word 0x00361a57 /* zeta index 247, original -zeta = 0x0005fe03 */
  .word 0x0022e2f7 /* zeta index 243, original -zeta = 0x002176bf */
  .word 0x003a8025 /* zeta index 239, original -zeta = 0x00171aa8 */
  .word 0x0062b999 /* zeta index 235, original -zeta = 0x000872f6 */
  .word 0x0078abf3 /* zeta index 231, original -zeta = 0x000bc189 */
  .word 0x007bc241 /* zeta index 227, original -zeta = 0x0051c998 */
  .word 0x000ce94a /* zeta index 254, original -zeta = 0x006fc8f3 */
  .word 0x0000bcb2 /* zeta index 250, original -zeta = 0x003ca555 */
  .word 0x006743d7 /* zeta index 246, original -zeta = 0x00533a1b */
  .word 0x00066c23 /* zeta index 242, original -zeta = 0x005be39c */
  .word 0x0003fa26 /* zeta index 238, original -zeta = 0x007dbc2d */
  .word 0x001b8352 /* zeta index 234, original -zeta = 0x00781f10 */
  .word 0x0065aa1a /* zeta index 230, original -zeta = 0x00778da1 */
  .word 0x0044deec /* zeta index 226, original -zeta = 0x0014e995 */
  .word 0x006a8199 /* zeta index 253, original -zeta = 0x000bee33 */
  .word 0x004410d5 /* zeta index 249, original -zeta = 0x0049fe24 */
  .word 0x000ee7fb /* zeta index 245, original -zeta = 0x001a324e */
  .word 0x00221e51 /* zeta index 241, original -zeta = 0x005035cf */
  .word 0x0010d9cd /* zeta index 237, original -zeta = 0x004b87dd */
  .word 0x00659331 /* zeta index 233, original -zeta = 0x0010d5f0 */
  .word 0x000ee40c /* zeta index 229, original -zeta = 0x007c98a1 */
  .word 0x004a1ac8 /* zeta index 225, original -zeta = 0x00002e67 */
  .word 0x0043ca37 /* zeta index 252, original -zeta = 0x0062e1ed */
  .word 0x000875b0 /* zeta index 248, original -zeta = 0x00049f9d */
  .word 0x007d136e /* zeta index 244, original -zeta = 0x002dff14 */
  .word 0x002cd89c /* zeta index 240, original -zeta = 0x0021577c */
  .word 0x00197168 /* zeta index 236, original -zeta = 0x0072c011 */
  .word 0x000682bb /* zeta index 232, original -zeta = 0x00507ceb */
  .word 0x005e1b0a /* zeta index 228, original -zeta = 0x004c8d2b */
  .word 0x002e5ec4 /* zeta index 224, original -zeta = 0x0042ebd2 */
  .word 0x001b73c3 /* zeta index 223, original -zeta = 0x00336939 */
  .word 0x0051e290 /* zeta index 219, original -zeta = 0x006594a4 */
  .word 0x00126c59 /* zeta index 215, original -zeta = 0x003d61de */
  .word 0x00028371 /* zeta index 211, original -zeta = 0x0051f32d */
  .word 0x0039a1e1 /* zeta index 207, original -zeta = 0x001bfe1e */
  .word 0x001c2ea9 /* zeta index 203, original -zeta = 0x00154207 */
  .word 0x004be732 /* zeta index 199, original -zeta = 0x0029dc73 */
  .word 0x0014fa53 /* zeta index 195, original -zeta = 0x001f088f */
  .word 0x00385e99 /* zeta index 222, original -zeta = 0x006e1eb3 */
  .word 0x006735f9 /* zeta index 218, original -zeta = 0x0018a6aa */
  .word 0x007d0b46 /* zeta index 214, original -zeta = 0x00746ff8 */
  .word 0x005a6c4a /* zeta index 210, original -zeta = 0x00577847 */
  .word 0x0076cf29 /* zeta index 206, original -zeta = 0x000b0f44 */
  .word 0x00198008 /* zeta index 202, original -zeta = 0x0059dc44 */
  .word 0x005dc219 /* zeta index 198, original -zeta = 0x0077d194 */
  .word 0x0026da88 /* zeta index 194, original -zeta = 0x00243b02 */
  .word 0x0066a867 /* zeta index 221, original -zeta = 0x0060edfb */
  .word 0x007d63e5 /* zeta index 217, original -zeta = 0x0058acce */
  .word 0x004c7769 /* zeta index 213, original -zeta = 0x0040930c */
  .word 0x005ac276 /* zeta index 209, original -zeta = 0x000529f4 */
  .word 0x0038d3ee /* zeta index 205, original -zeta = 0x0012202d */
  .word 0x002b35f4 /* zeta index 201, original -zeta = 0x006172c3 */
  .word 0x0074041a /* zeta index 197, original -zeta = 0x0011ffdd */
  .word 0x00629f68 /* zeta index 193, original -zeta = 0x005fc03b */
  .word 0x0073835c /* zeta index 220, original -zeta = 0x006676db */
  .word 0x00309342 /* zeta index 216, original -zeta = 0x004322ca */
  .word 0x00620269 /* zeta index 212, original -zeta = 0x0027de75 */
  .word 0x001eb9a8 /* zeta index 208, original -zeta = 0x002e4a8e */
  .word 0x00276ee5 /* zeta index 204, original -zeta = 0x00781fea */
  .word 0x000846cc /* zeta index 200, original -zeta = 0x00168979 */
  .word 0x0068fbfc /* zeta index 196, original -zeta = 0x0076ee00 */
  .word 0x001386ad /* zeta index 192, original -zeta = 0x0018c53a */
  /* Layer 7 - 1 */
  .word 0x00454828 /* zeta index 127, original -zeta = 0x00654186 */
  .word 0x003b3864 /* zeta index 125, original -zeta = 0x001d54cd */
  .word 0x0015f7fe /* zeta index 123, original -zeta = 0x0023ec27 */
  .word 0x00182f20 /* zeta index 121, original -zeta = 0x000500a8 */
  .word 0x006b686f /* zeta index 119, original -zeta = 0x0007019b */
  .word 0x0002b520 /* zeta index 117, original -zeta = 0x005c957b */
  .word 0x001c400a /* zeta index 115, original -zeta = 0x002a66a4 */
  .word 0x003637f8 /* zeta index 113, original -zeta = 0x002a5acb */
  .word 0x00375fa9 /* zeta index 126, original -zeta = 0x00222136 */
  .word 0x002e115e /* zeta index 124, original -zeta = 0x003a4483 */
  .word 0x000c66bc /* zeta index 122, original -zeta = 0x007071ea */
  .word 0x006c41dc /* zeta index 120, original -zeta = 0x007a8d75 */
  .word 0x006bccfc /* zeta index 118, original -zeta = 0x0009f7db */
  .word 0x0024c36d /* zeta index 116, original -zeta = 0x0034e991 */
  .word 0x004fa93f /* zeta index 114, original -zeta = 0x0056ee7b */
  .word 0x007cfb95 /* zeta index 112, original -zeta = 0x006b2d61 */
  .word 0x001417f8 /* zeta index 111, original -zeta = 0x004c6357 */
  .word 0x00033821 /* zeta index 109, original -zeta = 0x0012b7a5 */
  .word 0x00319640 /* zeta index 107, original -zeta = 0x00766595 */
  .word 0x00002182 /* zeta index 105, original -zeta = 0x005a5136 */
  .word 0x004378a7 /* zeta index 103, original -zeta = 0x00240acf */
  .word 0x0010c942 /* zeta index 101, original -zeta = 0x003fd383 */
  .word 0x00509a79 /* zeta index  99, original -zeta = 0x00226787 */
  .word 0x007bd511 /* zeta index  97, original -zeta = 0x006497da */
  .word 0x00744760 /* zeta index 110, original -zeta = 0x00533b09 */
  .word 0x005b6a95 /* zeta index 108, original -zeta = 0x004457e1 */
  .word 0x0066a6b9 /* zeta index 106, original -zeta = 0x00518cb5 */
  .word 0x0038d436 /* zeta index 104, original -zeta = 0x00141b2e */
  .word 0x007212bd /* zeta index 102, original -zeta = 0x0013d630 */
  .word 0x007f3301 /* zeta index 100, original -zeta = 0x004abda3 */
  .word 0x00781bea /* zeta index  98, original -zeta = 0x00247c31 */
  .word 0x00330417 /* zeta index  96, original -zeta = 0x00275b35 */
  /* Layer 6 - 1 */
  .word 0x002ab0d3 /* zeta index  63, original -zeta = 0x00638491 */
  .word 0x006042ad /* zeta index  62, original -zeta = 0x004cd1d6 */
  .word 0x002703d0 /* zeta index  61, original -zeta = 0x00639693 */
  .word 0x00445acd /* zeta index  60, original -zeta = 0x00535c27 */
  .word 0x0044a7ae /* zeta index  59, original -zeta = 0x0044d194 */
  .word 0x0071508b /* zeta index  58, original -zeta = 0x007760c9 */
  .word 0x0077c467 /* zeta index  57, original -zeta = 0x004f29df */
  .word 0x00737c59 /* zeta index  56, original -zeta = 0x002c35a2 */
  .word 0x00476c75 /* zeta index  55, original -zeta = 0x003c45e5 */
  .word 0x00186ba4 /* zeta index  54, original -zeta = 0x001a32fc */
  .word 0x0020a9e9 /* zeta index  53, original -zeta = 0x001d89b7 */
  .word 0x004a5bc2 /* zeta index  52, original -zeta = 0x00468d0b */
  .word 0x003a50a7 /* zeta index  51, original -zeta = 0x00368ac2 */
  .word 0x004a61e3 /* zeta index  50, original -zeta = 0x000c7980 */
  .word 0x0019152a /* zeta index  49, original -zeta = 0x0065078e */
  .word 0x0019edc3 /* zeta index  48, original -zeta = 0x004bc3e4 */
  /* Layer 5 - 1 */
  .word 0x007b9a3c /* zeta index  31, original -zeta = 0x005d072c */
  .word 0x0042ae00 /* zeta index  30, original -zeta = 0x0054e96a */
  .word 0x00004bde /* zeta index  29, original -zeta = 0x0036b44a */
  .word 0x00650fcc /* zeta index  28, original -zeta = 0x0009ce44 */
  .word 0x00320368 /* zeta index  27, original -zeta = 0x00699613 */
  .word 0x00155b09 /* zeta index  26, original -zeta = 0x005a6e22 */
  .word 0x003ae519 /* zeta index  25, original -zeta = 0x0065b78a */
  .word 0x0020522a /* zeta index  24, original -zeta = 0x003140e4 */
  /* Layer 8 - 2 */
  .word 0x001df292 /* zeta index 191, original -zeta = 0x00213f95 */
  .word 0x0015d2d1 /* zeta index 187, original -zeta = 0x0034fac5 */
  .word 0x0010095a /* zeta index 183, original -zeta = 0x0021d9e3 */
  .word 0x00362470 /* zeta index 179, original -zeta = 0x00598787 */
  .word 0x006785bb /* zeta index 175, original -zeta = 0x00003081 */
  .word 0x006c9290 /* zeta index 171, original -zeta = 0x003a920f */
  .word 0x007cc6dd /* zeta index 167, original -zeta = 0x003087a8 */
  .word 0x00412fe6 /* zeta index 163, original -zeta = 0x001a5a70 */
  .word 0x004d6d7e /* zeta index 190, original -zeta = 0x000c7e49 */
  .word 0x0032a1c2 /* zeta index 186, original -zeta = 0x004239fd */
  .word 0x0062d4b6 /* zeta index 182, original -zeta = 0x0013fe35 */
  .word 0x0057a770 /* zeta index 178, original -zeta = 0x00015cd5 */
  .word 0x0059efb0 /* zeta index 174, original -zeta = 0x006cbcd3 */
  .word 0x002785c6 /* zeta index 170, original -zeta = 0x006cf49a */
  .word 0x0065633a /* zeta index 166, original -zeta = 0x000418a8 */
  .word 0x002532bf /* zeta index 162, original -zeta = 0x005e69d7 */
  .word 0x006bd93a /* zeta index 189, original -zeta = 0x001caf46 */
  .word 0x006cfee6 /* zeta index 185, original -zeta = 0x001d53ca */
  .word 0x00635ac2 /* zeta index 181, original -zeta = 0x0076848b */
  .word 0x006ccb43 /* zeta index 177, original -zeta = 0x007db5f6 */
  .word 0x006cd67d /* zeta index 173, original -zeta = 0x00578bdd */
  .word 0x0056ce68 /* zeta index 169, original -zeta = 0x005cd6de */
  .word 0x0032ffc5 /* zeta index 165, original -zeta = 0x00371c66 */
  .word 0x007b7ef5 /* zeta index 161, original -zeta = 0x001b0c2c */
  .word 0x0006e21c /* zeta index 188, original -zeta = 0x0060c299 */
  .word 0x00145742 /* zeta index 184, original -zeta = 0x0006fff4 */
  .word 0x002daf77 /* zeta index 180, original -zeta = 0x0014ac8c */
  .word 0x00397ae8 /* zeta index 176, original -zeta = 0x00522036 */
  .word 0x0041fee5 /* zeta index 172, original -zeta = 0x004f1ce5 */
  .word 0x0054811c /* zeta index 168, original -zeta = 0x0046b24f */
  .word 0x004b6d1a /* zeta index 164, original -zeta = 0x005b71c8 */
  .word 0x007aa6e8 /* zeta index 160, original -zeta = 0x003f4458 */
  .word 0x0036de3e /* zeta index 159, original -zeta = 0x00257751 */
  .word 0x004ef07b /* zeta index 155, original -zeta = 0x00398274 */
  .word 0x0007f904 /* zeta index 151, original -zeta = 0x00395d69 */
  .word 0x007360a7 /* zeta index 147, original -zeta = 0x00257281 */
  .word 0x0030ba22 /* zeta index 143, original -zeta = 0x0038b752 */
  .word 0x004a44a4 /* zeta index 139, original -zeta = 0x003c817a */
  .word 0x00365bde /* zeta index 135, original -zeta = 0x00559189 */
  .word 0x00459e09 /* zeta index 131, original -zeta = 0x00163712 */
  .word 0x000bba6e /* zeta index 158, original -zeta = 0x0003d24e */
  .word 0x0060df7d /* zeta index 154, original -zeta = 0x005701fb */
  .word 0x0000a8fc /* zeta index 150, original -zeta = 0x003c60d0 */
  .word 0x0071ff1b /* zeta index 146, original -zeta = 0x0070792c */
  .word 0x001244aa /* zeta index 142, original -zeta = 0x00321fb3 */
  .word 0x0012db10 /* zeta index 138, original -zeta = 0x00762802 */
  .word 0x00255461 /* zeta index 134, original -zeta = 0x0000e70c */
  .word 0x005c872d /* zeta index 130, original -zeta = 0x002894c5 */
  .word 0x0008032a /* zeta index 157, original -zeta = 0x00762bcd */
  .word 0x002fa50a /* zeta index 153, original -zeta = 0x00340a88 */
  .word 0x00189d76 /* zeta index 149, original -zeta = 0x0067826b */
  .word 0x006381e7 /* zeta index 145, original -zeta = 0x007352f4 */
  .word 0x00395d04 /* zeta index 141, original -zeta = 0x00230a4d */
  .word 0x005aba7a /* zeta index 137, original -zeta = 0x007e8b59 */
  .word 0x005da206 /* zeta index 133, original -zeta = 0x001b2a03 */
  .word 0x004be0a7 /* zeta index 129, original -zeta = 0x001d883c */
  .word 0x00364683 /* zeta index 156, original -zeta = 0x00362f1e */
  .word 0x0009ffdf /* zeta index 152, original -zeta = 0x0019b6a1 */
  .word 0x0078507e /* zeta index 148, original -zeta = 0x001e3469 */
  .word 0x007221a3 /* zeta index 144, original -zeta = 0x00006ca4 */
  .word 0x0035b760 /* zeta index 140, original -zeta = 0x003c6009 */
  .word 0x007bcd0c /* zeta index 136, original -zeta = 0x006dd5de */
  .word 0x0033008e /* zeta index 132, original -zeta = 0x005747c9 */
  .word 0x005ff56e /* zeta index 128, original -zeta = 0x007fd928 */
  /* Layer 7 - 2 */
  .word 0x0015d39e /* zeta index  95, original -zeta = 0x004e27a8 */
  .word 0x006b4a2d /* zeta index  93, original -zeta = 0x007c4872 */
  .word 0x0013f609 /* zeta index  91, original -zeta = 0x0030c940 */
  .word 0x0012beed /* zeta index  89, original -zeta = 0x00353a7f */
  .word 0x0025cbf7 /* zeta index  87, original -zeta = 0x0032e0ef */
  .word 0x00385bb5 /* zeta index  85, original -zeta = 0x007d4929 */
  .word 0x00567162 /* zeta index  83, original -zeta = 0x002d3358 */
  .word 0x000f017b /* zeta index  81, original -zeta = 0x007882a8 */
  .word 0x00639a9e /* zeta index  94, original -zeta = 0x003197ea */
  .word 0x0005d423 /* zeta index  92, original -zeta = 0x00656188 */
  .word 0x000059c5 /* zeta index  90, original -zeta = 0x00618b1b */
  .word 0x000a3d7e /* zeta index  88, original -zeta = 0x003f9319 */
  .word 0x00064593 /* zeta index  86, original -zeta = 0x005a4d15 */
  .word 0x002d485d /* zeta index  84, original -zeta = 0x0008a163 */
  .word 0x005f19c9 /* zeta index  82, original -zeta = 0x006e5847 */
  .word 0x004bcf0f /* zeta index  80, original -zeta = 0x00688eff */
  .word 0x007df037 /* zeta index  79, original -zeta = 0x00406d79 */
  .word 0x00302d52 /* zeta index  77, original -zeta = 0x002d8765 */
  .word 0x000f430a /* zeta index  75, original -zeta = 0x003a392d */
  .word 0x0062488f /* zeta index  73, original -zeta = 0x0060edab */
  .word 0x00183045 /* zeta index  71, original -zeta = 0x00042e8c */
  .word 0x004ad613 /* zeta index  69, original -zeta = 0x00312d17 */
  .word 0x002e67e7 /* zeta index  67, original -zeta = 0x00451912 */
  .word 0x0017537f /* zeta index  65, original -zeta = 0x006c6148 */
  .word 0x00376f20 /* zeta index  78, original -zeta = 0x0010ee0c */
  .word 0x0030ad80 /* zeta index  76, original -zeta = 0x0054fa66 */
  .word 0x003e4f8e /* zeta index  74, original -zeta = 0x00624f5f */
  .word 0x0013308b /* zeta index  72, original -zeta = 0x0059974d */
  .word 0x005eaa3a /* zeta index  70, original -zeta = 0x002fa120 */
  .word 0x001629a3 /* zeta index  68, original -zeta = 0x00400ab5 */
  .word 0x00381e31 /* zeta index  66, original -zeta = 0x002836d1 */
  .word 0x003bf91b /* zeta index  64, original -zeta = 0x0050fc10 */
  /* Layer 6 - 2 */
  .word 0x00083aa3 /* zeta index  47, original -zeta = 0x005ef9ef */
  .word 0x005c0965 /* zeta index  46, original -zeta = 0x004e680d */
  .word 0x000495b3 /* zeta index  45, original -zeta = 0x003d532d */
  .word 0x0049dc01 /* zeta index  44, original -zeta = 0x006042ec */
  .word 0x002bc1bf /* zeta index  43, original -zeta = 0x003580cc */
  .word 0x0049556b /* zeta index  42, original -zeta = 0x006f28d5 */
  .word 0x002e7184 /* zeta index  41, original -zeta = 0x0071b414 */
  .word 0x003aea7b /* zeta index  40, original -zeta = 0x0079dc5d */
  .word 0x00442152 /* zeta index  39, original -zeta = 0x006e2d3e */
  .word 0x0026b82c /* zeta index  38, original -zeta = 0x0047580a */
  .word 0x0036cfd4 /* zeta index  37, original -zeta = 0x005fcf5f */
  .word 0x00195afd /* zeta index  36, original -zeta = 0x002f77a2 */
  .word 0x004a013c /* zeta index  35, original -zeta = 0x0036b98e */
  .word 0x0050eb34 /* zeta index  34, original -zeta = 0x00560ec2 */
  .word 0x007e69e1 /* zeta index  33, original -zeta = 0x004f4ee3 */
  .word 0x0056959a /* zeta index  32, original -zeta = 0x0048e8d7 */
  /* Layer 5 - 2 */
  .word 0x00202c85 /* zeta index  23, original -zeta = 0x00146280 */
  .word 0x0057e699 /* zeta index  22, original -zeta = 0x00758d13 */
  .word 0x00111560 /* zeta index  21, original -zeta = 0x00069fcd */
  .word 0x00086270 /* zeta index  20, original -zeta = 0x0035c75a */
  .word 0x00492879 /* zeta index  19, original -zeta = 0x00198d77 */
  .word 0x00107a5c /* zeta index  18, original -zeta = 0x00573c2f */
  .word 0x00703f91 /* zeta index  17, original -zeta = 0x003dff4d */
  .word 0x005649a9 /* zeta index  16, original -zeta = 0x00336d6d */
  /* Layer 1--4 */
  .word 0x0056fada /* zeta index  15, original -zeta = 0x0012a239 */
  .word 0x005065b8 /* zeta index  14, original -zeta = 0x00775e6f */
  .word 0x002c04f7 /* zeta index  13, original -zeta = 0x000f56b7 */
  .word 0x0050458c /* zeta index  12, original -zeta = 0x00466d7e */
  .word 0x001feb81 /* zeta index  11, original -zeta = 0x005f601d */
  .word 0x00057b53 /* zeta index  10, original -zeta = 0x0056f251 */
  .word 0x005bf6d6 /* zeta index   9, original -zeta = 0x0049d22c */
  .word 0x006401d6 /* zeta index   8, original -zeta = 0x00092e53 */
  .word 0x0078c1dd /* zeta index   7, original -zeta = 0x0030d996 */
  .word 0x000d5ed8 /* zeta index   6, original -zeta = 0x002fffce */
  .word 0x000bdee8 /* zeta index   5, original -zeta = 0x002c008e */
  .word 0x007c41bd /* zeta index   4, original -zeta = 0x0030d9d6 */
  .word 0x0007eafd /* zeta index   3, original -zeta = 0x00467a98 */
  .word 0x0027cefe /* zeta index   2, original -zeta = 0x00466a9a */
  /* -zeta[1] * ninv (including ninv to optimize half of ninv multiplications) */
  .word 0x007b60bc /* zeta index   1, original -zeta = 0x003681ff */
  .word 0x00003ffe /* ninv */
