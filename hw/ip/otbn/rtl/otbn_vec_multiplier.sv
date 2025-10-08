// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

/**
 * Vectorized Multiplier
 *
 * This module implements a vectorized multiplier which can compute either one 64-bit, two 32-bit
 * or four 16-bit multiplications. The input operands are interpreted as vectors with either one,
 * two or four elements, respectively. The multiplication is split into its 16-bit partial products
 * and finally shifted and summed accordingly ("schoolbook" algorithm). Consider the following
 * operand splitting:
 *
 * Operand a: [a3, a2, a1, a0], where a is split into four 16-bit chunks
 * Operand b: [b3, b2, b1, b0], where b is split into four 16-bit chunks
 * Radix: R = 2^Radix (= 2^16)
 *
 * The result for the 64-bit multiplication a * b can then be split using
 *
 * a = a0 + R*a1 + R^2*a2 + R^3*a3
 *
 * into
 *
 * a * b =         a0*b0
 *        + R   * (a0*b1 + a1*b0)
 *        + R^2 * (a0*b2 + a1*b1 + a2*b0)
 *        + R^3 * (a0*b3 + a1*b2 + a2*b1 + a3*b0)
 *        + R^4 * (a1*b3 + a2*b2 + a3*b1)
 *        + R^5 * (a2*b3 + a3*b2)
 *        + R^6 * (a3*b3)
 *
 * To compute vectorized 16-bit or 32-bit multiplications a subset of the partial products can
 * directly be used.
 *
 * The results for the four 16-bit multiplications are the ai*bi partial products.
 *
 * For two 32-bit multiplications:
 * c0 = {a1, a0} * {b1, b0} =          a0*b0
 *                            + R   * (a0*b1 + a1*b0)
 *                            + R^2 * (a1*b1)
 * c1 = {a3, a2} * {b3, b2} =          a2*b2
 *                            + R   * (a2*b3 + a3*b2)
 *                            + R^2 * (a3*b3)
 *
 * The 32-bit results c0, c1 can be reused to optimize the 64-bit multiplication. Rearrange the
 * original a*b:
 * a * b = c0 + R^2 * (a0*b2 + a2*b0) + R^3 * ( ..unchanged.. ) + R^4 * (a1*b3 + a3*b1) + R^4 * c1
 */
module otbn_vec_multiplier
  import otbn_pkg::*;
#(
  // DO NOT CHANGE these values! TODO: make it fully dynamic or fix the values?
  parameter int Width      = 64, // Must be power of 2
  parameter int RadixPower = 16  // Must be power of 2
) (
    input  logic               clk_i,
    input  logic               rst_ni,
    input  logic [Width-1:0]   operand_a_i,
    input  logic [Width-1:0]   operand_b_i,
    input  logic [NELEN-1:0]   elen_onehot_i,
    output logic [2*Width-1:0] result_o
);
  localparam int NumChunks = Width / RadixPower;

  typedef struct packed {
    logic [RadixPower-1:0] chunk;
  } multiplication_chunk_t;


  multiplication_chunk_t [NumChunks-1:0] op_a_chunks, op_b_chunks;
  assign op_a_chunks = operand_a_i;
  assign op_b_chunks = operand_b_i;

  // Calculate all partial products
  // The first unpacked dimension indexes operand a, the 2nd operand b
  logic [(2*RadixPower)-1:0] part_prods [NumChunks][NumChunks];

  for (genvar i_op_a = 0; i_op_a < NumChunks; i_op_a++ ) begin : g_op_a_outer
    for (genvar i_op_b = 0; i_op_b < NumChunks; i_op_b++ ) begin : g_op_b_inner
      assign part_prods[i_op_a][i_op_b] = op_a_chunks[i_op_a] * op_b_chunks[i_op_b];
    end
  end

  // Compute the results
  // TODO: make dynamic depending on Width and RadixPower
  logic [2*Width-1:0] res_16b, res_32b, res_64b;
  assign res_16b = {part_prods[3][3], part_prods[2][2],
                    part_prods[1][1], part_prods[0][0]};

  logic [63:0] res_c0, res_c1;

  assign res_c0 =   64'(part_prods[0][0]) +
                  ((64'(part_prods[0][1]) + 64'(part_prods[1][0])) << RadixPower) +
                   (64'(part_prods[1][1])                          << 2*RadixPower);

  assign res_c1 =   64'(part_prods[2][2]) +
                  ((64'(part_prods[2][3]) + 64'(part_prods[3][2])) << RadixPower) +
                   (64'(part_prods[3][3])                          << 2*RadixPower);

  assign res_32b = {res_c1, res_c0};

  assign res_64b = 128'(res_c0) +
    ((128'(part_prods[0][2]) + 128'(part_prods[2][0]))                << 2*RadixPower) +
    ((128'(part_prods[0][3]) + 128'(part_prods[1][2]) +
      128'(part_prods[2][1]) + 128'(part_prods[3][0]))                << 3*RadixPower) +
    ((128'(part_prods[1][3]) + 128'(part_prods[3][1]) + 128'(res_c1)) << 4*RadixPower);

  // Output MUX
  // TODO: Is this clean? Summarize all results into a MUX input.
  //       But we need to check manually that each possible value of ELEN is covered as there is
  //       nothing like a default case. We have an assert below to capture invalid ELEN.
  logic [2*Width-1:0] all_res [NELEN];
  assign all_res[VecElen16]  = res_16b;
  assign all_res[VecElen32]  = res_32b;
  assign all_res[VecElen64]  = res_64b;
  assign all_res[VecElen128] = '0; // invalid ELEN
  assign all_res[VecElen256] = '0; // invalid ELEN

  prim_onehot_mux #(
    .Width(2*Width),
    .Inputs(NELEN)
  ) u_result_mux (
    .clk_i,
    .rst_ni,
    .in_i  (all_res),
    .sel_i (elen_onehot_i),
    .out_o (result_o)
  );

  /* TODO: Fix assert
  // Assert: ELEN can only be 16, 32 or 64
  // TODO: how to generate a onehot encoding in the same way as in predecode but not synthesize it?
  // Is this approach valid / smart?
  logic [NELEN-1:0] elen_onehot_16b, elen_onehot_32b, elen_onehot_64b;

  prim_onehot_enc #(
    .OneHotWidth(NELEN)
  ) u_onehot_16b (
    .in_i(VecElen16),
    .en_i('1), // always enable
    .out_o(elen_onehot_16b)
  );
  prim_onehot_enc #(
    .OneHotWidth(NELEN)
  ) u_onehot_32b (
    .in_i(VecElen32),
    .en_i('1), // always enable
    .out_o(elen_onehot_32b)
  );
  prim_onehot_enc #(
    .OneHotWidth(NELEN)
  ) u_onehot_64b (
    .in_i(VecElen64),
    .en_i('1), // always enable
    .out_o(elen_onehot_64b)
  );

  `ASSERT(InvalidElenForVecMultiplier, ~((elen_onehot_i == elen_onehot_16b) ||
                                         (elen_onehot_i == elen_onehot_32b) ||
                                         (elen_onehot_i == elen_onehot_64b)))
  */

endmodule
