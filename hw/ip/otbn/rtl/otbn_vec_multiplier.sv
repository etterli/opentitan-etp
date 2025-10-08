// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

/**
 * Vectorized Multiplier
 *
 * This module implements a vectorized multiplier which can compute either one 64-bit or two 32-bit
 * multiplications. The input operands are interpreted as vectors with either one or two elements,
 * respectively. The multiplication is split into its 32-bit partial products
 * and finally shifted and summed accordingly ("schoolbook" algorithm). Consider the following
 * operand splitting:
 *
 * Operand a: [a1, a0], where a is split into two 32-bit chunks
 * Operand b: [b1, b0], where b is split into two 32-bit chunks
 * Radix: R = 2^Radix (= 2^32)
 *
 * The result for the 64-bit multiplication a * b can then be split using
 * a = a0 + R*a1
 *
 * into
 *
 * a * b = a0*b0 + R * (a0*b1 + a1*b0) + R^2 * (a1*b1)
 *
 * To compute vectorized 32-bit multiplications a subset of the partial products can
 * directly be used, i.e.:
 * c0 = a0 * b0
 * c1 = a1 * b1
 *
 * The 32-bit results c0, c1 can be reused for he 64-bit multiplication. Rearrange the
 * original a*b to:
 * a * b =          c0
 *         + R   * (a0*b1 + a1*b0)
 *         + R^2 * c1
 *
 * The element length is selected with the three 3b signal elen_ctrl_i which must be predecoded as
 * each bit controls a blanker. The encoding is:
 * - 3'b111: 64b multiplication
 * - 3'b011: 32b multiplication
 * - 3'b001: 16b multiplication - not working
 * - 3'b000: all blankers are disabled. Result is all zero and no leakage is generated.
 * - All other cases are invalid. These produce an invalid result and GENERATE LEAKAGE.
 *
 * The 3'b000 case blankes all inputs before any computation is performed. Therefore, this module
 * does not require external blankers for the operands.
 */
module otbn_vec_multiplier
  import otbn_pkg::*;
#(
  localparam int Width      = 64, // Must be power of 2
  localparam int RadixPower = 32, // Must be power of 2
  localparam int NumChunks = Width / RadixPower
) (
    input  logic [Width-1:0]   operand_a_i,
    input  logic [Width-1:0]   operand_b_i,
    input  logic [1:0]         elen_ctrl_i,
    output logic [2*Width-1:0] result_o
);

  typedef struct packed {
    logic [RadixPower-1:0] chunk;
  } multiplication_chunk_t;

  multiplication_chunk_t [NumChunks-1:0] op_a_chunks, op_b_chunks;
  assign op_a_chunks = operand_a_i;
  assign op_b_chunks = operand_b_i;

  // Blanker control signals
  logic enable_32b, enable_64b;
  assign enable_32b = elen_ctrl_i[0];
  assign enable_64b = elen_ctrl_i[1];

  ////////////////////////////////
  // Partial product generation //
  ////////////////////////////////
  // Compute all 32b * 32b partial results but only if the selected ELEN requires the result.
  // For 64b we need all partial products.
  // For 32b we only need two partial products.
  // PP used in all cases:
  // a0*b0, a1*b1
  // PP used only in 64b:
  // a0*b1, a1*b0

  // The first unpacked dimension indexes operand a, the 2nd operand b
  logic [(2*RadixPower)-1:0] part_prods [NumChunks][NumChunks];

  for (genvar i_op_a = 0; i_op_a < NumChunks; i_op_a++ ) begin : g_op_a_outer
    for (genvar i_op_b = 0; i_op_b < NumChunks; i_op_b++ ) begin : g_op_b_inner
      if (i_op_a == i_op_b) begin : g_pp_32b
        // These variables are declared in each if context to be absolutely sure separate signals are generated.
        logic [RadixPower-1:0] chunk_a_blanked, chunk_b_blanked;
        prim_blanker #(.Width(RadixPower)) i_part_prod_32b_a_blanker (
          .in_i (op_a_chunks[i_op_a]),
          .en_i (enable_32b),
          .out_o(chunk_a_blanked)
        );
        prim_blanker #(.Width(RadixPower)) i_part_prod_32b_b_blanker (
          .in_i (op_b_chunks[i_op_b]),
          .en_i (enable_32b),
          .out_o(chunk_b_blanked)
        );
        assign part_prods[i_op_a][i_op_b] = chunk_a_blanked * chunk_b_blanked;
      end else begin : g_pp_64b
        // These variables are declared in each if context to be absolutely sure separate signals are generated.
        logic [RadixPower-1:0] chunk_a_blanked, chunk_b_blanked;
        // All additionally required partial products for 64b multiplication (i.e. the remaining)
        prim_blanker #(.Width(RadixPower)) i_part_prod_64b_a_blanker (
          .in_i (op_a_chunks[i_op_a]),
          .en_i (enable_64b),
          .out_o(chunk_a_blanked)
        );
        prim_blanker #(.Width(RadixPower)) i_part_prod_64b_b_blanker (
          .in_i (op_b_chunks[i_op_b]),
          .en_i (enable_64b),
          .out_o(chunk_b_blanked)
        );
        assign part_prods[i_op_a][i_op_b] = chunk_a_blanked * chunk_b_blanked;
      end
    end
  end


  ///////////////////////////////
  // Partial product summation //
  ///////////////////////////////
  // Compute the results by summing the partial products (PP) depending on ELEN.
  // - In the 32b case there is no summation required, just output the two partial products.
  // - In the 64b case sum up the four partial products each.
  //
  // The summation part is designed as shown here:
  //
  // +------------------------------+
  // |  Partial Product Generation  |
  // +------------------------------+
  //   |             |
  //   |             b
  //   |             |
  //   |     +---------------+
  //   |     | 64b summation |
  //   |     +---------------+
  //   |             |
  //   |             |
  //   +-------+     |
  //           |     |
  //         \---------/
  //          \-------/
  //              |
  //           result
  //
  // The partial product generation ensures that unused products are blanked. We therefore must
  // only ensure that we do not propagate used partial products into inactive summation circuits.
  // In the 16b case the four PPs used to compute the 16b multiplications may not be fed into the
  // 32b and 64b summation. This requires a blanker for these four PPs before the 32b summation.
  // The 64b summation circuit does not use these partial products directly (only via 32b results)
  // and thus does not require blanking. In the 32b case we may not propagate the results into the
  // 64b summation. This requires a blanker between the 32b result and the 64b summation circuit.
  // In the 64b case no blanking is required as all PPs are used.
  // The result MUX does not require to be onehot predecoded as the inputs are either zero or
  // the data is already entangled in computations.

  ////////////////
  // ELEN = 32b //
  ////////////////
  logic [2*Width-1:0] res_32b;

  // For 16b we don't need any summation. Order the used partial products such that we can directly
  // output the result.
  assign res_32b = {part_prods[1][1], part_prods[0][0]};

  ////////////////
  // ELEN = 64b //
  ////////////////
  logic [Width-1:0] res_c0, res_c1;

  assign res_c0 = part_prods[0][0];
  assign res_c1 = part_prods[1][1];

  logic [2*Width-1:0] res_64b;

  // We must blank the signal from the 32b summation
  logic [2*Width-1:0] res_32b_to_64b;
  logic [2*Width-1:0] res_32b_to_64b_blanked;
  logic [Width-1:0] res_c0_blanked, res_c1_blanked;

  assign res_32b_to_64b = {res_c1, res_c0};
  prim_blanker #(.Width(2*Width)) u_res_32b_blanker (
    .in_i (res_32b_to_64b),
    .en_i (enable_64b),
    .out_o(res_32b_to_64b_blanked)
  );

  assign res_c0_blanked = res_32b_to_64b_blanked[0*Width+:Width];
  assign res_c1_blanked = res_32b_to_64b_blanked[1*Width+:Width];

  assign res_64b =
      128'(res_c0_blanked) +
    ((128'(part_prods[0][1]) + 128'(part_prods[1][0])) << RadixPower) +
    ((128'(res_c1_blanked)) << 2*RadixPower);

  //////////////////////
  // Result selection //
  //////////////////////
  // As we only generate the used partial products we don't need a prim_onehot_mux.
  // We use a unique case instead of a MUX because to avoid priority encoding and its possible
  // timing effects.
  // The default case is the 16b case as it generates the least amount of leakage.
  // Specifying a separate case with all zeros is costly in terms of area and an invalid control
  // signal should be caught by verification and FI is covered by the decoded and predecoded signal
  // comparison.
  always_comb begin
    unique case (elen_ctrl_i)
      2'b01:  result_o = res_32b;
      2'b11:  result_o = res_64b;
      default: result_o = res_32b;
    endcase
  end

endmodule
