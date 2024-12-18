/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Test for ntt_base_dilithium_test
 * From https://github.com/dop-amin/opentitan/blob/43ff969b418e36f4e977e0d722a176e35238fea9/sw/otbn/crypto/tests/ntt_dilithium_test.s
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
  /* dmem[data] <= NTT(dmem[input]) */
  la  x10, input
  la  x11, twiddles
  la  x12, output
  jal  x1, ntt_dilithium

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
output:
  .zero 1024
/* Modulus for reduction */
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

/* Second input */
twiddles:
    /* Layers 1-4 */
    .word 0x00495e02
    .word 0x00397567
    .word 0x00396569
    .word 0x004f062b
    .word 0x0053df73
    .word 0x004fe033
    .word 0x004f066b
    .word 0x0076b1ae
    .word 0x00360dd5
    .word 0x0028edb0
    .word 0x00207fe4
    .word 0x00397283
    .word 0x0070894a
    .word 0x00088192
    .word 0x006d3dc8
    /* Padding */
    .word 0x00000000
    /* Layer 5 - 1*/
    .word 0x004c7294
    .word 0x0041e0b4
    .word 0x0028a3d2
    .word 0x0066528a
    .word 0x004a18a7
    .word 0x00794034
    .word 0x000a52ee
    .word 0x006b7d81
    /* Layer 6 - 1 */
    .word 0x0036f72a
    .word 0x0030911e
    .word 0x0029d13f
    .word 0x00492673
    .word 0x0050685f
    .word 0x002010a2
    .word 0x003887f7
    .word 0x0011b2c3
    .word 0x000603a4
    .word 0x000e2bed
    .word 0x0010b72c
    .word 0x004a5f35
    .word 0x001f9d15
    .word 0x00428cd4
    .word 0x003177f4
    .word 0x0020e612
    /* Layer 7 - 1 */
    .word 0x002ee3f1
    .word 0x0057a930
    .word 0x003fd54c
    .word 0x00503ee1
    .word 0x002648b4
    .word 0x001d90a2
    .word 0x002ae59b
    .word 0x006ef1f5
    .word 0x00137eb9
    .word 0x003ac6ef
    .word 0x004eb2ea
    .word 0x007bb175
    .word 0x001ef256
    .word 0x0045a6d4
    .word 0x0052589c
    .word 0x003f7288
    .word 0x00175102
    .word 0x001187ba
    .word 0x00773e9e
    .word 0x002592ec
    .word 0x00404ce8
    .word 0x001e54e6
    .word 0x001a7e79
    .word 0x004e4817
    .word 0x00075d59
    .word 0x0052aca9
    .word 0x000296d8
    .word 0x004cff12
    .word 0x004aa582
    .word 0x004f16c1
    .word 0x0003978f
    .word 0x0031b859
    /* Layer 8 - 1 */
    .word 0x000006d9
    .word 0x00289838
    .word 0x00120a23
    .word 0x00437ff8
    .word 0x007f735d
    .word 0x0061ab98
    .word 0x00662960
    .word 0x0049b0e3
    .word 0x006257c5
    .word 0x0064b5fe
    .word 0x000154a8
    .word 0x005cd5b4
    .word 0x000c8d0d
    .word 0x00185d96
    .word 0x004bd579
    .word 0x0009b434
    .word 0x00574b3c
    .word 0x007ef8f5
    .word 0x0009b7ff
    .word 0x004dc04e
    .word 0x000f66d5
    .word 0x00437f31
    .word 0x0028de06
    .word 0x007c0db3
    .word 0x0069a8ef
    .word 0x002a4e78
    .word 0x00435e87
    .word 0x004728af
    .word 0x005a6d80
    .word 0x00468298
    .word 0x00465d8d
    .word 0x005a68b0
    .word 0x00409ba9
    .word 0x00246e39
    .word 0x00392db2
    .word 0x0030c31c
    .word 0x002dbfcb
    .word 0x006b3375
    .word 0x0078e00d
    .word 0x001f1d68
    .word 0x0064d3d5
    .word 0x0048c39b
    .word 0x00230923
    .word 0x00285424
    .word 0x00022a0b
    .word 0x00095b76
    .word 0x00628c37
    .word 0x006330bb
    .word 0x0021762a
    .word 0x007bc759
    .word 0x0012eb67
    .word 0x0013232e
    .word 0x007e832c
    .word 0x006be1cc
    .word 0x003da604
    .word 0x007361b8
    .word 0x00658591
    .word 0x004f5859
    .word 0x00454df2
    .word 0x007faf80
    .word 0x0026587a
    .word 0x005e061e
    .word 0x004ae53c
    .word 0x005ea06c
    /* Layer 5 - 2*/
    .word 0x004e9f1d
    .word 0x001a2877
    .word 0x002571df
    .word 0x001649ee
    .word 0x007611bd
    .word 0x00492bb7
    .word 0x002af697
    .word 0x0022d8d5
    /* Layer 6 - 2 */
    .word 0x00341c1d
    .word 0x001ad873
    .word 0x00736681
    .word 0x0049553f
    .word 0x003952f6
    .word 0x0062564a
    .word 0x0065ad05
    .word 0x00439a1c
    .word 0x0053aa5f
    .word 0x0030b622
    .word 0x00087f38
    .word 0x003b0e6d
    .word 0x002c83da
    .word 0x001c496e
    .word 0x00330e2b
    .word 0x001c5b70
    /* Layer 7 - 2 */
    .word 0x005884cc
    .word 0x005b63d0
    .word 0x0035225e
    .word 0x006c09d1
    .word 0x006bc4d3
    .word 0x002e534c
    .word 0x003b8820
    .word 0x002ca4f8
    .word 0x001b4827
    .word 0x005d787a
    .word 0x00400c7e
    .word 0x005bd532
    .word 0x00258ecb
    .word 0x00097a6c
    .word 0x006d285c
    .word 0x00337caa
    .word 0x0014b2a0
    .word 0x0028f186
    .word 0x004af670
    .word 0x0075e826
    .word 0x0005528c
    .word 0x000f6e17
    .word 0x00459b7e
    .word 0x005dbecb
    .word 0x00558536
    .word 0x0055795d
    .word 0x00234a86
    .word 0x0078de66
    .word 0x007adf59
    .word 0x005bf3da
    .word 0x00628b34
    .word 0x001a9e7b
    /* Layer 8 - 2 */
    .word 0x00671ac7
    .word 0x0008f201
    .word 0x00695688
    .word 0x0007c017
    .word 0x00519573
    .word 0x0058018c
    .word 0x003cbd37
    .word 0x00196926
    .word 0x00201fc6
    .word 0x006de024
    .word 0x001e6d3e
    .word 0x006dbfd4
    .word 0x007ab60d
    .word 0x003f4cf5
    .word 0x00273333
    .word 0x001ef206
    .word 0x005ba4ff
    .word 0x00080e6d
    .word 0x002603bd
    .word 0x0074d0bd
    .word 0x002867ba
    .word 0x000b7009
    .word 0x00673957
    .word 0x0011c14e
    .word 0x0060d772
    .word 0x0056038e
    .word 0x006a9dfa
    .word 0x0063e1e3
    .word 0x002decd4
    .word 0x00427e23
    .word 0x001a4b5d
    .word 0x004c76c8
    .word 0x003cf42f
    .word 0x003352d6
    .word 0x002f6316
    .word 0x000d1ff0
    .word 0x005e8885
    .word 0x0051e0ed
    .word 0x007b4064
    .word 0x001cfe14
    .word 0x007fb19a
    .word 0x00034760
    .word 0x006f0a11
    .word 0x00345824
    .word 0x002faa32
    .word 0x0065adb3
    .word 0x0035e1dd
    .word 0x0073f1ce
    .word 0x006af66c
    .word 0x00085260
    .word 0x0007c0f1
    .word 0x000223d4
    .word 0x0023fc65
    .word 0x002ca5e6
    .word 0x00433aac
    .word 0x0010170e
    .word 0x002e1669
    .word 0x00741e78
    .word 0x00776d0b
    .word 0x0068c559
    .word 0x005e6942
    .word 0x0079e1fe
    .word 0x00464ade
    .word 0x0074b6d7

  .zero 512
stack_end:
  .zero 1
































































































































































































































































