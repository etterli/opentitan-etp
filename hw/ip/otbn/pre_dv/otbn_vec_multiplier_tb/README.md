# OTBN Vectorized Multiplier Testbench

One can use the `otbn/dv/otbnsim/test/bn_simd_testvec_gen.py` generator from the simulator testing to generate the test vectors.

## Test descriptions

### 001: Simple vectorized multiplication
This testcase should cover the following questions:
- Multiplication works for all ELENs

Inputs:
- `operand_a`: a random vector spanning the full bit width with 4x 16b, 2x 32b or 1x 64b element(s)
- `operand_b`: a random vector spanning the full bit width with 4x 16b, 2x 32b or 1x 64b element(s)
- `elen`: 16, 32 or 64

Expected output:
- `result`: the expected vectorized result

### 002: Max value overflow
This testcase should cover the following questions:
- The whole range works correct

Inputs:
- `operand_a`: a vector with `0xFFFFFFFFFFFFFFFF`
- `operand_b`: a vector with `0xFFFFFFFFFFFFFFFF`
- `elen`: 16, 32 or 64

Expected output:
- `result`: the expected vectorized result

### 003: Zero is zero, operator a
This testcase should cover the following questions:
- Multiply by zero is zero

Inputs:
- `operand_a`: a random vector
- `operand_b`: the zero vector
- `elen`: 16, 32 or 64

Expected output:
- `result`: all results should be zero

### 003: Zero is zero, operator b
This testcase should cover the following questions:
- Multiply by zero is zero

Inputs:
- `operand_a`: the zero vector
- `operand_b`: a random vector
- `elen`: 16, 32 or 64

Expected output:
- `result`: all results should be zero

### 004: One is one, operator a
This testcase should cover the following questions:
- Multiply by one is correct

Inputs:
- `operand_a`: a random vector
- `operand_b`: all elements are = 1
- `elen`: 16, 32 or 64

Expected output:
- `result`: all results should be the `operand_a` vector

### 004: One is one, operator b
This testcase should cover the following questions:
- Multiply by one is correct

Inputs:
- `operand_a`: all elements are = 1
- `operand_b`: a random vector
- `elen`: 16, 32 or 64

Expected output:
- `result`: all results should be the `operand_b` vector

## Golden Vector file
All testcases inputs and outputs are defined in the `otbn_vec_multiplier_tb.golden` file.
Each line of the file has the following format and represents a testcase.
```
<elen>, 0x<operand_a>, 0x<operand_b>, 0x<result>
```
where
- `<elen>`: one of `16, 32, 64`. The ELENs `128, 256` are not supported.
- `<operand_a>`: operand a (vector) as `64'hxx...` (0x is expected)
- `<operand_b>`: operand b (vector) as `64'hxx...` (0x is expected)
- `<result>`: the expected result as `128'hxx...` (0x is expected)
