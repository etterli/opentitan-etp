// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * OTBN vectorized shifter
 * 
 * This shifter is capable of shifting vectors elementwise as well as concatenate and shift 256
 * bit registers.
 * The shifter takes a 512-bit input (to implement BN.RSHI, concatenate and right shift) and shifts
 * right by up to 256-bits. The lower (256-bit) half of the input and output can be reversed to
 * allow left shift implementation. There is no concatenate and left shift instruction so reversing
 * isn't required over the full width. If there is no concatenate, the upper input must be
 * all-zero.
 *
 * Shifting vectors elementwise is enabled by adding a masking step after the shifting.
 * For this an ELEN dependent mask must be provided which then will clear the bits overflowing
 * into the neighboring element.
 * Example:
 * Assume there is a vector with 2 4-bit elements:
 *   |0101 1010|
 * This should be shifted >> by 2. The expected result is:
 *   |0001 0010|
 * The regular shifting process would give:
 *   |0001 0110|
 * so the lower 2 bits of the upper element are shifted into the lower element. To correct this,
 * the mask 8'b00110011 must be provided. This mask is then applied with an & and clears the
 * overflowing bits.
 *    |0001 0110|
 *  & |0001 0011|
 *  = |0001 0010|
 * This approach natively supports 256-bit elements by setting the mask to all-ones.
 *
 * in_upper    in_lower
 *    |           |
 *    |       +---+---+
 *    |       |       |
 *    |       |    +-----+
 *    |       |    | rev |  reverse the input
 *    |       |    +-----+
 *    |       |       |
 *    |       |   +---+
 *    |       |   |
 *    |     \-------/ <-- shift_right
 *    |         |
 *    |   +-----+
 *    |   |
 *  +-------+
 *  |  >>   | <-- shift_amount
 *  +-------+
 *      |
 * +---------+
 * | [255:0] |
 * +---------+
 *      |
 * +---------+
 * | mask &  | <-- vector_mask
 * +---------+
 *   |     |
 *   |     |
 *   |  +-----+
 *   |  | rev | reverse the input back
 *   |  +-----+
 *   |     |
 *   |   +-+
 *   |   |
 * \-------/ <-- shift_right
 *     |
 * shift_result
 *
 */

module otbn_vec_shifter
  import otbn_pkg::*;
(
  input  logic [WLEN-1:0]         shifter_in_upper_i,
  input  logic [WLEN-1:0]         shifter_in_lower_i,
  input  logic                    shift_right_i,
  input  logic [$clog2(WLEN)-1:0] shift_amt_i,
  input  logic [WLEN-1:0]         vector_mask_i,
  output logic [WLEN-1:0]         shifter_res_o
);
  logic [WLEN*2-1:0] shifter_in;
  logic [WLEN*2-1:0] shifter_out;
  logic [WLEN-1:0]   shifter_in_lower_reverse, shifter_out_lower, shifter_out_lower_reverse,
                     shifter_masked, unused_shifter_out_upper;

  for (genvar i = 0; i < WLEN; i++) begin : g_shifter_in_lower_reverse
    assign shifter_in_lower_reverse[i] = shifter_in_lower_i[WLEN-i-1];
  end

  assign shifter_in = {shifter_in_upper_i, shift_right_i ? shifter_in_lower_i
                                                         : shifter_in_lower_reverse};

  assign shifter_out = shifter_in >> shift_amt_i;

  // Mask out overflowing bits of the adjacent vector elements
  assign shifter_masked = shifter_out[WLEN-1:0] & vector_mask_i;

  assign shifter_out_lower = shifter_masked;

  for (genvar i = 0; i < WLEN; i++) begin : g_shifter_out_lower_reverse
    assign shifter_out_lower_reverse[i] = shifter_out_lower[WLEN-i-1];
  end

  assign shifter_res_o = shift_right_i ? shifter_out_lower : shifter_out_lower_reverse;

  // Only the lower WLEN bits of the shift result are returned.
  assign unused_shifter_out_upper = shifter_out[WLEN*2-1:WLEN];
endmodule
