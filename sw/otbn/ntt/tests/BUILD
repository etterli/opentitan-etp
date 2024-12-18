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
    name = "ntt_mldsa_test",
    srcs = [
        "ntt_mldsa_test.s",
    ],
    exp = "ntt_mldsa_test.exp",
    deps = ["//sw/otbn/ntt:ntt_mldsa"],
)
