# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:otbn.bzl", "otbn_sim_test")

package(default_visibility = ["//visibility:public"])

otbn_sim_test(
    name = "ntt_base_dilithium_test",
    srcs = [
        "ntt_base_dilithium_test.s",
    ],
    exp = "ntt_base_dilithium_test.exp",
    deps = ["//sw/otbn/ntt:ntt_base_dilithium"],
)

otbn_sim_test(
    name = "intt_base_dilithium_test",
    srcs = [
        "intt_base_dilithium_test.s",
    ],
    exp = "intt_base_dilithium_test.exp",
    deps = ["//sw/otbn/ntt:intt_base_dilithium"],
)

otbn_sim_test(
    name = "ntt_mldsa_test",
    srcs = [
        "ntt_mldsa_test.s",
    ],
    exp = "ntt_mldsa_test.exp",
    deps = ["//sw/otbn/ntt:ntt_mldsa"],
)

otbn_sim_test(
    name = "intt_mldsa_test",
    srcs = [
        "intt_mldsa_test.s",
    ],
    exp = "intt_mldsa_test.exp",
    deps = ["//sw/otbn/ntt:intt_mldsa"],
)

