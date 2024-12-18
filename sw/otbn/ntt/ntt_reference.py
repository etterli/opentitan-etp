# NTT reference value generator

import copy
from mod_transformations import to_montgomery, montgomery_mul, R_mt  # , plantard_mul, R_pl

# Reference C implementation from https://github.com/pq-crystals/dilithium/blob/master/ref/ntt.c
# input a is in regular space, zetas are in Montgomery
#
# void ntt(int32_t a[N]) {
#   unsigned int len, start, j, k;
#   int32_t zeta, t;
#   k = 0;
#   for(len = 128; len > 0; len >>= 1) {
#     for(start = 0; start < N; start = j + len) {
#       zeta = zetas[++k];
#       for(j = start; j < start + len; ++j) {
#         t = montgomery_reduce((int64_t)zeta * a[j + len]);
#         a[j + len] = a[j] - t;
#         a[j] = a[j] + t;
#       }
#     }
#   }
# }


# Inplace NTT for coeffs in [0,q[ using bit-reversed zetas.
# Zetas are in regular space
def ntt(coeffs, zetas, q, n):
    k = 0
    len = 128
    while len > 0:
        # print(f"len   {len:3}")
        start = 0
        while start < n:
            k += 1
            zeta = zetas[k]
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = (coeffs[j + len] * zeta) % q
                coeffs[j + len] = (coeffs[j] - t) % q
                coeffs[j] = (coeffs[j] + t) % q
            start = j + len + 1  # +1 because range does not increment j
        len >>= 1

    return coeffs


# Only first 4 layers
# Inplace NTT for coeffs in [0,q[ using bit-reversed zetas.
# Zetas are in regular space
def ntt_4layers(coeffs, zetas, q, n):
    k = 0
    len = 128
    while len > 8:
        # print(f"len   {len:3}")
        start = 0
        while start < n:
            k += 1
            zeta = zetas[k]
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = (coeffs[j + len] * zeta) % q
                coeffs[j + len] = (coeffs[j] - t) % q
                coeffs[j] = (coeffs[j] + t) % q
            start = j + len + 1  # +1 because range does not increment j
        len >>= 1

    return coeffs


# Only first 5 layers
# Inplace NTT for coeffs in [0,q[ using bit-reversed zetas.
# Zetas are in regular space
def ntt_5layers(coeffs, zetas, q, n):
    k = 0
    len = 128
    while len > 4:
        # print(f"len   {len:3}")
        start = 0
        while start < n:
            k += 1
            zeta = zetas[k]
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = (coeffs[j + len] * zeta) % q
                coeffs[j + len] = (coeffs[j] - t) % q
                coeffs[j] = (coeffs[j] + t) % q
            start = j + len + 1  # +1 because range does not increment j
        len >>= 1

    return coeffs


# Inplace NTT for coeffs in [0,q[ using bit-reversed zetas.
# Zetas must be pre-transformed to Montgomery space.
def ntt_montgomery(coeffs, zetas, q, n):
    k = 0
    len = 128
    while len > 0:
        start = 0
        while start < n:
            k += 1
            zeta = zetas[k]
            for j in range(start, start + len):
                t = montgomery_mul(coeffs[j + len], zeta, q, R_mt, 32)
                coeffs[j + len] = (coeffs[j] - t) % q
                coeffs[j] = (coeffs[j] + t) % q
            start = j + len + 1
        len >>= 1

    return coeffs


def ntt_montgomery_4layers(coeffs, zetas, q, n):
    k = 0
    len = 128
    while len > 8:
        start = 0
        while start < n:
            k += 1
            zeta = zetas[k]
            for j in range(start, start + len):
                t = montgomery_mul(coeffs[j + len], zeta, q, R_mt, 32)
                coeffs[j + len] = (coeffs[j] - t) % q
                coeffs[j] = (coeffs[j] + t) % q
            start = j + len + 1
        len >>= 1

    return coeffs


def intt(coeffs, zetas, q, n, ninv):
    m = 256
    len = 1
    while len < 256:
        # print(f"len   {len:3}")
        start = 0
        while start < n:
            m -= 1
            zeta = -zetas[m]  # mind the *(-1)
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = coeffs[j]
                coeffs[j] = (t + coeffs[j + len]) % q
                coeffs[j + len] = (t - coeffs[j + len]) % q
                coeffs[j + len] = (zeta * coeffs[j + len]) % q
            start = start + 2 * len
        len = 2 * len

    for j in range(n):
        coeffs[j] = (ninv * coeffs[j]) % q

    return coeffs


def intt_l85(coeffs, zetas, q, n, ninv):
    m = 256
    len = 1
    while len < 8:
        print(f"len   {len:3}")
        start = 0
        while start < n:
            m -= 1
            zeta = -zetas[m]  # mind the *(-1)
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = coeffs[j]
                coeffs[j] = (t + coeffs[j + len]) % q
                coeffs[j + len] = (t - coeffs[j + len]) % q
                coeffs[j + len] = (zeta * coeffs[j + len]) % q
            start = start + 2 * len
        len = 2 * len

    # for j in range(n):
    #     coeffs[j] = (ninv * coeffs[j]) % q

    return coeffs


def intt_montgomery(coeffs, zetas, q, n, ninv):
    m = 256
    len = 1
    while len < 256:
        # print(f"len   {len:3}")
        start = 0
        while start < n:
            m -= 1
            zeta = zetas[m]  # without *(-1)
            # print(f"start {start:3}")
            for j in range(start, start + len):
                # print(f"j     {j:3}")
                # print(f"j+len {(j+len):3}")
                t = coeffs[j]
                coeffs[j] = (t + coeffs[j + len]) % q
                coeffs[j + len] = (t - coeffs[j + len]) % q
                coeffs[j + len] = montgomery_mul(zeta, coeffs[j + len], q, R_mt, 32)
            start = start + 2 * len
        len = 2 * len

    for j in range(n):
        coeffs[j] = (ninv * coeffs[j]) % q

    return coeffs


def format_outputs(outputs):
    # output it in the same way as
    #  hw/ip/otbn/util/otbn_objdump.py -s -j .data <program>.elf
    text = "\nDMEM dump. First column is offset. The other four are the data in 32b little endian chunks.\n"
    # convert the results in a stream of bytes where the first byte is the lowest byte in memory.
    bytestream = []

    for res in outputs:
        for byte in range(4):
            bytestream.append(res & 0xFF)
            res = res >> 8

    for offset in range(0, len(bytestream), 16):
        line = f"{offset:04x}"
        for word in range(4):
            index = offset + word * 4
            line += (f" {bytestream[index+0]:02x}{bytestream[index+1]:02x}{bytestream[index+2]:02x}{bytestream[index+3]:02x}")
            # little endian
            # line += (f" {bytestream[index+3]:02x}{bytestream[index+2]:02x}{bytestream[index+1]:02x}{bytestream[index+0]:02x}")
        text += line + "\n"

    return text


##############################################
# NTT calculation
##############################################
N = 256
q = 8380417
size = 32  # we have 32bit elements

# ninv = N^(-1) % q
ninv = 8347681

# bit-reversed
zetas = [
    0, 4808194, 3765607, 3761513, 5178923, 5496691, 5234739, 5178987,
    7778734, 3542485, 2682288, 2129892, 3764867, 7375178, 557458, 7159240,
    5010068, 4317364, 2663378, 6705802, 4855975, 7946292, 676590, 7044481,
    5152541, 1714295, 2453983, 1460718, 7737789, 4795319, 2815639, 2283733,
    3602218, 3182878, 2740543, 4793971, 5269599, 2101410, 3704823, 1159875,
    394148, 928749, 1095468, 4874037, 2071829, 4361428, 3241972, 2156050,
    3415069, 1759347, 7562881, 4805951, 3756790, 6444618, 6663429, 4430364,
    5483103, 3192354, 556856, 3870317, 2917338, 1853806, 3345963, 1858416,
    3073009, 1277625, 5744944, 3852015, 4183372, 5157610, 5258977, 8106357,
    2508980, 2028118, 1937570, 4564692, 2811291, 5396636, 7270901, 4158088,
    1528066, 482649, 1148858, 5418153, 7814814, 169688, 2462444, 5046034,
    4213992, 4892034, 1987814, 5183169, 1736313, 235407, 5130263, 3258457,
    5801164, 1787943, 5989328, 6125690, 3482206, 4197502, 7080401, 6018354,
    7062739, 2461387, 3035980, 621164, 3901472, 7153756, 2925816, 3374250,
    1356448, 5604662, 2683270, 5601629, 4912752, 2312838, 7727142, 7921254,
    348812, 8052569, 1011223, 6026202, 4561790, 6458164, 6143691, 1744507,
    1753, 6444997, 5720892, 6924527, 2660408, 6600190, 8321269, 2772600,
    1182243, 87208, 636927, 4415111, 4423672, 6084020, 5095502, 4663471,
    8352605, 822541, 1009365, 5926272, 6400920, 1596822, 4423473, 4620952,
    6695264, 4969849, 2678278, 4611469, 4829411, 635956, 8129971, 5925040,
    4234153, 6607829, 2192938, 6653329, 2387513, 4768667, 8111961, 5199961,
    3747250, 2296099, 1239911, 4541938, 3195676, 2642980, 1254190, 8368000,
    2998219, 141835, 8291116, 2513018, 7025525, 613238, 7070156, 6161950,
    7921677, 6458423, 4040196, 4908348, 2039144, 6500539, 7561656, 6201452,
    6757063, 2105286, 6006015, 6346610, 586241, 7200804, 527981, 5637006,
    6903432, 1994046, 2491325, 6987258, 507927, 7192532, 7655613, 6545891,
    5346675, 8041997, 2647994, 3009748, 5767564, 4148469, 749577, 4357667,
    3980599, 2569011, 6764887, 1723229, 1665318, 2028038, 1163598, 5011144,
    3994671, 8368538, 7009900, 3020393, 3363542, 214880, 545376, 7609976,
    3105558, 7277073, 508145, 7826699, 860144, 3430436, 140244, 6866265,
    6195333, 3123762, 2358373, 6187330, 5365997, 6663603, 2926054, 7987710,
    8077412, 3531229, 4405932, 4606686, 1900052, 7598542, 1054478, 7648983]

# NTT order of zetas. The zero is a padding for WDR alignment
order = [
    1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  # noqa: E241 E126
    0,  16,  17,  18,  19,  20,  21,  22,  23,  32,  33,  34,  35,  36,  37,  # noqa: E241 E126
   38,  39,  40,  41,  42,  43,  44,  45,  46,  47,  64,  66,  68,  70,  72,  # noqa: E241 E131
   74,  76,  78,  65,  67,  69,  71,  73,  75,  77,  79,  80,  82,  84,  86,  # noqa: E241 E131
   88,  90,  92,  94,  81,  83,  85,  87,  89,  91,  93,  95, 128, 132, 136,  # noqa: E241 E131
  140, 144, 148, 152, 156, 129, 133, 137, 141, 145, 149, 153, 157, 130, 134,  # noqa: E241 E131
  138, 142, 146, 150, 154, 158, 131, 135, 139, 143, 147, 151, 155, 159, 160,  # noqa: E241 E131
  164, 168, 172, 176, 180, 184, 188, 161, 165, 169, 173, 177, 181, 185, 189,  # noqa: E241 E131
  162, 166, 170, 174, 178, 182, 186, 190, 163, 167, 171, 175, 179, 183, 187,  # noqa: E241 E131
  191,  24,  25,  26,  27,  28,  29,  30,  31,  48,  49,  50,  51,  52,  53,  # noqa: E241 E131
   54,  55,  56,  57,  58,  59,  60,  61,  62,  63,  96,  98, 100, 102, 104,  # noqa: E241 E131
  106, 108, 110,  97,  99, 101, 103, 105, 107, 109, 111, 112, 114, 116, 118,  # noqa: E241 E131
  120, 122, 124, 126, 113, 115, 117, 119, 121, 123, 125, 127, 192, 196, 200,  # noqa: E241 E131
  204, 208, 212, 216, 220, 193, 197, 201, 205, 209, 213, 217, 221, 194, 198,  # noqa: E241 E131
  202, 206, 210, 214, 218, 222, 195, 199, 203, 207, 211, 215, 219, 223, 224,  # noqa: E241 E131
  228, 232, 236, 240, 244, 248, 252, 225, 229, 233, 237, 241, 245, 249, 253,  # noqa: E241 E131
  226, 230, 234, 238, 242, 246, 250, 254, 227, 231, 235, 239, 243, 247, 251, 255  # noqa: E241 E131
]

zetas_montgomery = [to_montgomery(z, q, size) for z in zetas]

zetas_intt = [(-z) % q for z in zetas]
# multiply twiddle coeff[1] with n^-1. This merges the multiplication of ninv for half of the
# coeffs into the last iNTT layer.
zetas_intt_optimized = copy.deepcopy(zetas_intt)
zetas_intt_optimized[1] = (zetas_intt[1] * ninv) % q

zetas_montgomery_intt = [to_montgomery(z, q, size) for z in zetas_intt]
zetas_montgomery_intt_optimized = [to_montgomery(z, q, size) for z in zetas_intt_optimized]

inputs = [
    0x00000000, 0x00000001, 0x00000010, 0x00000051, 0x00000100, 0x00000271, 0x00000510, 0x00000961,
    0x00001000, 0x000019a1, 0x00002710, 0x00003931, 0x00005100, 0x00006f91, 0x00009610, 0x0000c5c1,
    0x00010000, 0x00014641, 0x00019a10, 0x0001fd11, 0x00027100, 0x0002f7b1, 0x00039310, 0x00044521,
    0x00051000, 0x0005f5e1, 0x0006f910, 0x00081bf1, 0x00096100, 0x000acad1, 0x000c5c10, 0x000e1781,
    0x00100000, 0x00121881, 0x00146410, 0x0016e5d1, 0x0019a100, 0x001c98f1, 0x001fd110, 0x00234ce1,
    0x00271000, 0x002b1e21, 0x002f7b10, 0x00342ab1, 0x00393100, 0x003e9211, 0x00445210, 0x004a7541,
    0x00510000, 0x0057f6c1, 0x005f5e10, 0x00673a91, 0x006f9100, 0x00786631, 0x0001df0f, 0x000bc0a0,
    0x00162fff, 0x00213260, 0x002ccd0f, 0x00390570, 0x0045e0ff, 0x00536550, 0x0061980f, 0x00707f00,
    0x00003ffe, 0x0010a0ff, 0x0021c80e, 0x0033bb4f, 0x004680fe, 0x005a1f6f, 0x006e9d0e, 0x0004205e,
    0x001a6ffd, 0x0031b29e, 0x0049ef0d, 0x00632c2e, 0x007d70fd, 0x0018e48d, 0x00354e0c, 0x0052d4bd,
    0x00717ffc, 0x0011773c, 0x0032820b, 0x0054c80c, 0x007850fb, 0x001d44ab, 0x00436b0a, 0x006aec1b,
    0x0013eff9, 0x003e3eda, 0x006a0109, 0x00175ee9, 0x004620f8, 0x00766fc9, 0x00287407, 0x005bf678,
    0x00113ff6, 0x00481977, 0x0000cc05, 0x003b20c6, 0x007740f5, 0x003555e5, 0x00752904, 0x003703d4,
    0x007aaff3, 0x00407713, 0x00084301, 0x0051fda2, 0x001df0f0, 0x006be701, 0x003c29ff, 0x000ea42f,
    0x00633fee, 0x003a47ae, 0x0013a5fc, 0x006f457d, 0x004d70eb, 0x002e131b, 0x001136f9, 0x0076c78a,
    0x005f0fe8, 0x0049fb48, 0x003794f6, 0x0027e856, 0x001b00e4, 0x0010ea34, 0x0009aff2, 0x00055de2,
    0x0003ffe0, 0x0005a1e0, 0x000a4fee, 0x0012162e, 0x001d00dc, 0x002b1c4c, 0x003c74ea, 0x0051173a,
    0x00690fd8, 0x00048b77, 0x002356e5, 0x00459f05, 0x006b70d3, 0x0014f962, 0x004205e0, 0x0072c390,
    0x00275fcd, 0x005fa80d, 0x001be9da, 0x005bf2da, 0x002010c7, 0x00681177, 0x003442d4, 0x000492e3,
    0x0058efc1, 0x0031a7a0, 0x000ea8cd, 0x006fe1ad, 0x0055a0ba, 0x003fd489, 0x002e8bc6, 0x0021d535,
    0x0019bfb2, 0x00165a31, 0x0017b3be, 0x001ddb7d, 0x0028e0aa, 0x0038d299, 0x004dc0b6, 0x0067ba85,
    0x0006efa1, 0x002b2fc0, 0x0054aaad, 0x0003904b, 0x0037b098, 0x00713ba7, 0x003061a3, 0x0074f2d2,
    0x003f3f8e, 0x000f384c, 0x0064cd99, 0x00405017, 0x0021b083, 0x0008ffb1, 0x00762e8e, 0x00698e1c,
    0x00630f78, 0x0062c3d6, 0x0068bc82, 0x00750ae0, 0x0007e06b, 0x00210eb9, 0x0040c775, 0x00671c63,
    0x00143f5e, 0x0048025c, 0x0002b767, 0x004430a5, 0x000cc050, 0x005c38be, 0x0032ec59, 0x0010cda6,
    0x0075cf42, 0x006243df, 0x00561e4a, 0x00517167, 0x00545032, 0x005ecdbf, 0x0070fd3a, 0x000b11e6,
    0x002cdf21, 0x0056985e, 0x00087128, 0x00423d25, 0x0004500f, 0x004e7dbc, 0x00211a16, 0x007bf923,
    0x005f6efd, 0x004b6fd9, 0x00401003, 0x003d63df, 0x00437fe9, 0x005278b5, 0x006a62ef, 0x000b735a,
    0x00357ed4, 0x0068ba50, 0x00255ad9, 0x006b3595, 0x003a9fbe, 0x00138ea9, 0x0075f7c3, 0x0062308e,
    0x00582ea7, 0x005807c2, 0x0061d1ab, 0x0075a246, 0x0013af8e, 0x003bcf99, 0x006e3892, 0x002b20bc,
    0x00725e75, 0x0044482f, 0x0020d477, 0x000819f1, 0x007a0f5a, 0x00770b84, 0x007f055c, 0x001233e5,
    0x00306e3d, 0x0059eb97, 0x000ee33e, 0x004f2c98, 0x001b1f1f, 0x00729269, 0x0055de20, 0x0044fa09]


inputs_intt = [
    0x005d48ec, 0x0021a486, 0x007fd956, 0x00513803, 0x0020d597, 0x000b753a, 0x0051e05a, 0x000eba0b,
    0x0070ab95, 0x006a124d, 0x003aa1cf, 0x00509b8c, 0x005d6ef6, 0x00581b11, 0x00416724, 0x002928ca,
    0x0067fd57, 0x00612635, 0x001f0f39, 0x0069694c, 0x004f6e0f, 0x00494bfe, 0x0053dab9, 0x0046eb19,
    0x001966c5, 0x0026bb1d, 0x000e0ae2, 0x004f5513, 0x0041e2be, 0x00212792, 0x000d3cd0, 0x007ec2f2,
    0x005fa78b, 0x00485194, 0x0074f732, 0x002e3b91, 0x001c4ea8, 0x0073e91f, 0x002c1d03, 0x0003733e,
    0x001f21a0, 0x000f6d7c, 0x0077587a, 0x003eab0c, 0x0008059b, 0x0017bd4c, 0x007bc5c1, 0x001f8091,
    0x007a067b, 0x0013d4ae, 0x006e2d11, 0x00265723, 0x002213e5, 0x004ee844, 0x0004af11, 0x000773d5,
    0x0063c820, 0x0073929d, 0x0023cadd, 0x004dd2a3, 0x005ce3e1, 0x00214b4b, 0x003cecc9, 0x00704e4c,
    0x007c621f, 0x003f51e8, 0x005847e5, 0x005fe291, 0x006afdba, 0x002bbb42, 0x006007fe, 0x003a24b5,
    0x003370d5, 0x002382e5, 0x005ad74f, 0x007f60d5, 0x006dcb02, 0x0053a1ec, 0x0005d6de, 0x0000da27,
    0x00596dd6, 0x007371e0, 0x000bb138, 0x0064e269, 0x00621ec6, 0x007fb198, 0x0035b40c, 0x00688879,
    0x004c1445, 0x001535a1, 0x0079aad2, 0x005ff0ca, 0x0063f79d, 0x00449161, 0x000018d1, 0x007b2af4,
    0x007264b1, 0x003594f9, 0x001b8372, 0x005edffc, 0x001a7e2f, 0x00445a3f, 0x003d61c7, 0x002f6231,
    0x00658b45, 0x001d9560, 0x001f9db8, 0x00237f25, 0x0061b8c8, 0x0050a704, 0x00052369, 0x00399e7f,
    0x007950b6, 0x00053f15, 0x000c980c, 0x007b7d0f, 0x002451b1, 0x003d8d33, 0x00632a03, 0x005e8ac4,
    0x0012ac7f, 0x00686a84, 0x00210f63, 0x002fb7dd, 0x00787387, 0x0038fec8, 0x00506c1a, 0x007007d4,
    0x0064055d, 0x004be313, 0x00517c33, 0x0041493e, 0x004b56a9, 0x00224b4e, 0x005de278, 0x007acb3a,
    0x002c6d1b, 0x00407c70, 0x00012caa, 0x003a6c07, 0x0006ad43, 0x000da6e6, 0x0038a26a, 0x0039c794,
    0x00670aa4, 0x0051be16, 0x00169deb, 0x007dee58, 0x00731ed6, 0x00268e06, 0x0054eb97, 0x004d54a4,
    0x004f1ab6, 0x005da4b3, 0x00189581, 0x0057aa0f, 0x003df4bb, 0x00057dbf, 0x001981fe, 0x00014e3d,
    0x0050f1f0, 0x0052eb8c, 0x0032fe6f, 0x0055391c, 0x005767a2, 0x0005cc0b, 0x007fc8b2, 0x00361987,
    0x00055595, 0x006f261a, 0x002eb8e3, 0x00061ed4, 0x0024f7dd, 0x006a749e, 0x004a0230, 0x00593b36,
    0x0058d9bb, 0x0047480a, 0x00288503, 0x0015a3af, 0x00329308, 0x004a242c, 0x005a80aa, 0x00180e0f,
    0x00683d44, 0x003fbced, 0x0039b459, 0x001a66ab, 0x0002d6f3, 0x007d8b9d, 0x00290e47, 0x006699a0,
    0x0041415a, 0x00514709, 0x000c9ca3, 0x0025287e, 0x00780b0e, 0x006a2ba9, 0x007baad1, 0x00346a9a,
    0x002d5ede, 0x007ea727, 0x000ae53d, 0x001912cf, 0x0036b4c7, 0x001b31d4, 0x005332eb, 0x00118338,
    0x0002da94, 0x00030772, 0x0064ee68, 0x0037ef2b, 0x00054aca, 0x0036f311, 0x00416fe8, 0x0010b58a,
    0x000cfc47, 0x00055418, 0x005e3fb4, 0x007a8656, 0x003eb1e1, 0x00090563, 0x005965c3, 0x001a8f47,
    0x0022ca59, 0x00468c90, 0x00175e1e, 0x000fd95a, 0x003ffdff, 0x000c9ea7, 0x00517eb8, 0x004d75a8,
    0x002b7935, 0x0006c396, 0x0011731c, 0x0026ca35, 0x000d66e2, 0x00691ae6, 0x00399ac0, 0x0069925b,
    0x007fa251, 0x0051cc4d, 0x00648959, 0x00170675, 0x0011fc7f, 0x00577336, 0x0068c888, 0x00658613,
    0x0079b4b4, 0x006cfeb6, 0x007f9072, 0x004e234b, 0x002aa3d6, 0x00353929, 0x0020c26a, 0x005478ce]


inputs_copy = copy.deepcopy(inputs)
inputs_4l = copy.deepcopy(inputs)
inputs_4l_mt = copy.deepcopy(inputs)
inputs_5l = copy.deepcopy(inputs)

outputs = ntt(inputs_copy, zetas, q, N)
outputs_4l = ntt_4layers(inputs_4l, zetas, q, N)
outputs_4l_mt = ntt_montgomery_4layers(inputs_4l_mt, zetas_montgomery, q, N)
outputs_5l = ntt_5layers(inputs_5l, zetas, q, N)

print(outputs)

# print for OTBN assembly
print("\nOTBN asm format:")
print("output:")
for value in outputs:
    print(f"  .word 0x{value:08x}")

text = format_outputs(outputs)

print(text)

print("\nLayer 1-4")
text = format_outputs(outputs_4l)
print(text)

print("\nLayer 1-4 montgomery")
text = format_outputs(outputs_4l_mt)
print(text)

print("\nLayer 1 - 5")
text = format_outputs(outputs_5l)
print(text)

print(order)
order_intt = list(reversed(order))

print(order_intt)

print("iNTT zetas without optimization")
print("twiddles:")
for ind in order_intt:
    if (ind == 0):
        continue  # for NTT use print("  .word 0x00000000 /* padding */")
    else:
        print(f"  .word 0x{zetas_montgomery_intt[ind]:08x} /* zeta index {ind:3}, original -zeta = 0x{zetas_intt[ind]:08x} */")  # noqa: E501
print(f"  .word 0x{to_montgomery(ninv, q, size):08x} /* ninv */")

print("iNTT zetas with ninv optimization")
print("twiddles:")
for ind in order_intt:
    if (ind == 0):
        continue  # for NTT use print("  .word 0x00000000 /* padding */")
    else:
        if (ind == 1):
            print("  /* -zeta[1] * ninv (including ninv to optimize half of ninv multiplications ) */")  # noqa: E501
        print(f"  .word 0x{zetas_montgomery_intt_optimized[ind]:08x} /* zeta index {ind:3}, original -zeta = 0x{zetas_intt[ind]:08x} */")  # noqa: E501
print(f"  .word 0x{to_montgomery(ninv, q, size):08x} /* ninv */")


print("iNTT Reference")

print("\noutputs_intt")
inputs_ntt_copy = copy.deepcopy(inputs_intt)
outputs_intt = intt(inputs_ntt_copy, zetas, q, N, ninv)
text = format_outputs(outputs_intt)
print(text)

print("\noutputs_intt_mt")
inputs_ntt_mt = copy.deepcopy(inputs_intt)
outputs_intt_mt = intt_montgomery(inputs_ntt_mt, zetas_montgomery_intt, q, N, ninv)
text = format_outputs(outputs_intt_mt)
print(text)

print("outputs_back")
outputs_for_intt = copy.deepcopy(outputs)
outputs_back = intt(outputs_for_intt, zetas, q, N, ninv)
text = format_outputs(outputs_back)
print(text)

print("iNTT l8-5")
inputs_intt_l85 = copy.deepcopy(inputs_intt)
outputs_intt_l85 = intt_l85(inputs_intt_l85, zetas, q, N, ninv)
text = format_outputs(outputs_intt_l85)
print(text)


print("inputs == outputs_back")
print(inputs == outputs_back)
print("inputs_intt == outputs")
print(inputs_intt == outputs)
print("inputs_intt -> outputs_intt_mt == outputs_intt")
print(outputs_intt == outputs_intt_mt)
