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
 * original a*b to:
 * a * b =          c0
 *         + R^2 * (a0*b2 + a2*b0)
 *         + R^3 * (a0*b3 + a1*b2 + a2*b1 + a3*b0)
 *         + R^4 * (a1*b3 + a3*b1)
 *         + R^4 *  c1
 *
 * The element length is selected with the three 3b signal elen_ctrl_i which must be predecoded as
 * each bit controls a blanker. The encoding is:
 * - 3'b111: 64b multiplication
 * - 3'b011: 32b multiplication
 * - 3'b001: 16b multiplication
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
  localparam int RadixPower = 16, // Must be power of 2
  localparam int NumChunks = Width / RadixPower
) (
    input  logic [Width-1:0]   operand_a_i,
    input  logic [Width-1:0]   operand_b_i,
    input  logic [2:0]         elen_ctrl_i,
    output logic [2*Width-1:0] result_o
);

  typedef struct packed {
    logic [RadixPower-1:0] chunk;
  } multiplication_chunk_t;

  multiplication_chunk_t [NumChunks-1:0] op_a_chunks, op_b_chunks;
  assign op_a_chunks = operand_a_i;
  assign op_b_chunks = operand_b_i;

  // Blanker control signals
  logic enable_16b, enable_32b, enable_64b;
  assign enable_16b = elen_ctrl_i[0];
  assign enable_32b = elen_ctrl_i[1];
  assign enable_64b = elen_ctrl_i[2];

  ////////////////////////////////
  // Partial product generation //
  ////////////////////////////////
  // Compute all 16b * 16b partial results but only if the selected ELEN requires the result as we
  // otherwise generate leakage. This requires a blanker for each 16b chunk which is controlled by
  // the corresponding enable bit. The blanker enable signal may not be selected with logic as this
  // would disregard the predecoding and thus the blanking. Therefore, we must generate each
  // partial product computation and its blanking explicitly.
  // We can split the generation in three cases.
  // - Partial products used for all three ELENs. These are all ai*bi products (ie same index)
  // - Additional PP used for 32b multiplication. These are all ai*bj products where either
  //     - i < 2 && j < 2: a0*b1, a1*b0
  //     - i > 1 && j > 1: a2*b3, a3*b2
  // - All other PPs are used only in the 64b case
  //
  // Each case has its own enable bit provided via the elen_ctrl_i signal.

  // The first unpacked dimension indexes operand a, the 2nd operand b
  logic [(2*RadixPower)-1:0] part_prods [NumChunks][NumChunks];

  for (genvar i_op_a = 0; i_op_a < NumChunks; i_op_a++ ) begin : g_op_a_outer
    for (genvar i_op_b = 0; i_op_b < NumChunks; i_op_b++ ) begin : g_op_b_inner
      if(i_op_a == i_op_b) begin : g_part_prod_16b
        // These variables are declared in each if context to be absolutely sure separate signals are generated.
        logic [RadixPower-1:0] chunk_a_blanked, chunk_b_blanked;
        // All these partial products are used for all ELENs
        prim_blanker #(.Width(RadixPower)) i_part_prod_16b_a_blanker (
          .in_i (op_a_chunks[i_op_a]),
          .en_i (enable_16b),
          .out_o(chunk_a_blanked)
        );
        prim_blanker #(.Width(RadixPower)) i_part_prod_16b_b_blanker (
          .in_i (op_b_chunks[i_op_b]),
          .en_i (enable_16b),
          .out_o(chunk_b_blanked)
        );
        assign part_prods[i_op_a][i_op_b] = chunk_a_blanked * chunk_b_blanked;
      end else if (((i_op_a < 2) && (i_op_b < 2)) ||
                   ((i_op_a > 1) && (i_op_b > 1))) begin : g_part_prod_32b
        // These variables are declared in each if context to be absolutely sure separate signals are generated.
        logic [RadixPower-1:0] chunk_a_blanked, chunk_b_blanked;
        // All additionally required partial products for 32b multiplication
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
      end else begin : g_part_prod_64b
        // These variables are declared in each if context to be absolutely sure separate signals are generated.
        logic [RadixPower-1:0] chunk_a_blanked, chunk_b_blanked;
        // All additionally required partial products for 64b multiplication (i.e. the remaining)
        prim_blanker #(.Width(RadixPower)) i_part_prod_32b_a_blanker (
          .in_i (op_a_chunks[i_op_a]),
          .en_i (enable_64b),
          .out_o(chunk_a_blanked)
        );
        prim_blanker #(.Width(RadixPower)) i_part_prod_32b_b_blanker (
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
  // - In the 16b case there is no summation required, just output the four partial products.
  // - In the 32b case sum up the four partial products each.
  // - The 64b case can reuse the 32b results.
  //
  // The summation part is designed as shown here:
  //
  // +------------------------------+
  // |  Partial Product Generation  |
  // +------------------------------+
  //   |          |               |
  //   |          b               |
  //   |          |               |
  //   |  +---------------+       |
  //   |  | 32b summation |       |
  //   |  +---------------+       |
  //   |          |               |
  //   |          +----b----+     |
  //   |          |         |     |
  //   |          |    +---------------+
  //   |          |    | 64b summation |
  //   |          |    +---------------+
  //   |          |            |
  //   +-------+  |  +---------+
  //           |  |  |
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
  // ELEN = 16b //
  ////////////////
  logic [2*Width-1:0] res_16b;

  // For 16b we don't need any summation. Order the used partial products such that we can directly
  // output the result.
  assign res_16b = {part_prods[3][3], part_prods[2][2],
                    part_prods[1][1], part_prods[0][0]};

  ////////////////
  // ELEN = 32b //
  ////////////////
  logic [Width-1:0] res_c0, res_c1;
  logic [2*Width-1:0] res_32b;

  // We must only blank the four partial products used by the 16b case.
  logic [4*(2*RadixPower)-1:0] partial_products_32b_and_16b, partial_products_32b_and_16b_blanked;

  assign partial_products_32b_and_16b =
    {part_prods[3][3], part_prods[2][2], part_prods[1][1], part_prods[0][0]};

  prim_blanker #(.Width(4*(2*RadixPower))) u_part_prod_32b_blanker (
    .in_i (partial_products_32b_and_16b),
    .en_i (enable_32b),
    .out_o(partial_products_32b_and_16b_blanked)
  );

  // Assign to new variables such that blanked and unblanked partial products have the same naming
  logic [(2*RadixPower)-1:0] pp_32b_00, pp_32b_01, pp_32b_10, pp_32b_11,
                             pp_32b_22, pp_32b_23, pp_32b_32, pp_32b_33;

  assign pp_32b_00 = partial_products_32b_and_16b_blanked[0*(2*RadixPower)+:(2*RadixPower)];
  assign pp_32b_01 = part_prods[0][1];
  assign pp_32b_10 = part_prods[1][0];
  assign pp_32b_11 = partial_products_32b_and_16b_blanked[1*(2*RadixPower)+:(2*RadixPower)];
  assign pp_32b_22 = partial_products_32b_and_16b_blanked[2*(2*RadixPower)+:(2*RadixPower)];
  assign pp_32b_23 = part_prods[2][3];
  assign pp_32b_32 = part_prods[3][2];
  assign pp_32b_33 = partial_products_32b_and_16b_blanked[3*(2*RadixPower)+:(2*RadixPower)];

  // Compute the sums
  always_comb begin : g_32b_summation
    res_c0 =   64'(pp_32b_00) +
             ((64'(pp_32b_01) + 64'(pp_32b_10)) << RadixPower) +
             (64'(pp_32b_11)                   << 2*RadixPower);

    res_c1 =   64'(pp_32b_22) +
             ((64'(pp_32b_23) + 64'(pp_32b_32)) << RadixPower) +
             (64'(pp_32b_33)                   << 2*RadixPower);

    res_32b = {res_c1, res_c0};
  end

  ////////////////
  // ELEN = 64b //
  ////////////////
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

  always_comb begin : g_64b_summation
    res_64b =
        128'(res_c0_blanked) +
      ((128'(part_prods[0][2]) + 128'(part_prods[2][0])) << 2*RadixPower) +
      ((128'(part_prods[0][3]) + 128'(part_prods[1][2])                   +
        128'(part_prods[2][1]) + 128'(part_prods[3][0])) << 3*RadixPower) +
      ((128'(part_prods[1][3]) + 128'(part_prods[3][1]) + 128'(res_c1_blanked)) << 4*RadixPower);
  end

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
  always_comb begin : g_res_sel
    unique case (elen_ctrl_i)
      3'b111:  result_o = res_64b;
      3'b011:  result_o = res_32b;
      3'b001:  result_o = res_16b;
      default: result_o = res_16b;
    endcase
  end

endmodule
