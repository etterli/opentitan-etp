# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:otbn.bzl", "otbn_binary", "otbn_sim_test")

package(default_visibility = ["//visibility:public"])

# TODO: generate expectations with hw/ip/otbn/dv/otbnsim/test/bn_simd_testvec_gen.py or similar

otbn_sim_test(
    name = "addv_test",
    srcs = [
        "addv_test.s",
    ],
    exp = "addv_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "addvm_test",
    srcs = [
        "addvm_test.s",
    ],
    exp = "addvm_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "shv_test",
    srcs = [
        "shv_test.s",
    ],
    exp = "shv_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "subv_test",
    srcs = [
        "subv_test.s",
    ],
    exp = "subv_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "subvm_test",
    srcs = [
        "subvm_test.s",
    ],
    exp = "subvm_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "trn1_test",
    srcs = [
        "trn1_test.s",
    ],
    exp = "trn1_test.exp",
    deps = [],
)

otbn_sim_test(
    name = "trn2_test",
    srcs = [
        "trn2_test.s",
    ],
    exp = "trn2_test.exp",
    deps = [],
)

otbn_binary(
    name = "bnmulv_simple",
    srcs = [
        "bnmulv_simple.s",
    ],
    deps = [],
)

otbn_sim_test(
    name = "bnmulv_simple_test",
    srcs = [
        "bnmulv_simple.s",
    ],
    exp = "bnmulv_simple.exp",
    deps = [],
)

otbn_binary(
    name = "bnmulvm_simple",
    srcs = [
        "bnmulvm_simple.s",
    ],
    deps = [],
)

otbn_sim_test(
    name = "bnmulvm_simple_test",
    srcs = [
        "bnmulvm_simple.s",
    ],
    exp = "bnmulvm_simple.exp",
    deps = [],
)

otbn_binary(
    name = "bnmulvml_simple",
    srcs = [
        "bnmulvml_simple.s",
    ],
    deps = [],
)

otbn_sim_test(
    name = "bnmulvml_simple_test",
    srcs = [
        "bnmulvml_simple.s",
    ],
    exp = "bnmulvml_simple.exp",
    deps = [],
)
