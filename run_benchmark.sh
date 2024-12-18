# Benchmark
## build it
./bazelisk.sh build sw/otbn/ntt/tests:ntt_base_dilithium_test
./bazelisk.sh build sw/otbn/ntt/tests:ntt_mldsa_test

./bazelisk.sh build sw/otbn/ntt/tests:intt_base_dilithium_test
./bazelisk.sh build sw/otbn/ntt/tests:intt_mldsa_test

./bazelisk.sh build sw/otbn/ntt/tests:ntt_mldsa_exp_reduction_test
./bazelisk.sh build sw/otbn/ntt/tests:intt_mldsa_exp_reduction_test

## let it run
hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_ntt_base_dilithium_test  --dump-dmem dmem_ntt_base_dilithium_test --dump-regs regs_ntt_base_dilithium_test bazel-bin/sw/otbn/ntt/tests/ntt_base_dilithium_test.elf
hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_ntt_mldsa_test           --dump-dmem dmem_ntt_mldsa_test          --dump-regs regs_ntt_mldsa_test          bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_test.elf

hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_intt_base_dilithium_test  --dump-dmem dmem_intt_base_dilithium_test --dump-regs regs_intt_base_dilithium_test bazel-bin/sw/otbn/ntt/tests/intt_base_dilithium_test.elf
hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_intt_mldsa_test           --dump-dmem dmem_intt_mldsa_test          --dump-regs regs_intt_mldsa_test          bazel-bin/sw/otbn/ntt/tests/intt_mldsa_test.elf

hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_ntt_mldsa_exp_reduction_test  --dump-dmem dmem_ntt_mldsa_exp_reduction_test  --dump-regs regs_ntt_mldsa_exp_reduction_test  bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_exp_reduction_test.elf
hw/ip/otbn/dv/otbnsim/standalone.py --dump-stats stats_intt_mldsa_exp_reduction_test --dump-dmem dmem_intt_mldsa_exp_reduction_test --dump-regs regs_intt_mldsa_exp_reduction_test bazel-bin/sw/otbn/ntt/tests/intt_mldsa_exp_reduction_test.elf

## obj dump
hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/ntt_base_dilithium_test.elf > obj_ntt_base_dilithium_test
hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_test.elf          > obj_ntt_mldsa_test

hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/intt_base_dilithium_test.elf > obj_intt_base_dilithium_test
hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/intt_mldsa_test.elf          > obj_intt_mldsa_test

hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_exp_reduction_test.elf  > obj_ntt_mldsa_exp_reduction_test
hw/ip/otbn/util/otbn_objdump.py -s -j .data  bazel-bin/sw/otbn/ntt/tests/intt_mldsa_exp_reduction_test.elf > obj_intt_mldsa_exp_reduction_test

## dmem
python sw/otbn/ntt/parse_dmem_dump.py dmem_ntt_base_dilithium_test -o dmem_ntt_base_dilithium_test_parsed
python sw/otbn/ntt/parse_dmem_dump.py dmem_ntt_mldsa_test          -o dmem_ntt_mldsa_test_parsed

python sw/otbn/ntt/parse_dmem_dump.py dmem_intt_base_dilithium_test -o dmem_intt_base_dilithium_test_parsed
python sw/otbn/ntt/parse_dmem_dump.py dmem_intt_mldsa_test          -o dmem_intt_mldsa_test_parsed

python sw/otbn/ntt/parse_dmem_dump.py dmem_ntt_mldsa_exp_reduction_test  -o dmem_ntt_mldsa_exp_reduction_test_parsed
python sw/otbn/ntt/parse_dmem_dump.py dmem_intt_mldsa_exp_reduction_test -o dmem_intt_mldsa_exp_reduction_test_parsed

## size
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/ntt_base_dilithium_test.elf > size_ntt_base_dilithium_test
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_test.elf > size_ntt_mldsa_test
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/intt_base_dilithium_test.elf > size_intt_base_dilithium_test
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/intt_mldsa_test.elf > size_intt_mldsa_test
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/ntt_mldsa_exp_reduction_test.elf > size_ntt_mldsa_exp_reduction_test
/tools/riscv/bin/riscv32-unknown-elf-size bazel-bin/sw/otbn/ntt/tests/intt_mldsa_exp_reduction_test.elf > size_intt_mldsa_exp_reduction_test
