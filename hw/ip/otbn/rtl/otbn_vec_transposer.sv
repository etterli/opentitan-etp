// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Vectorized Transposer
 *
 * This module transposes the elements of two input vectors in two different ways.
 * It supports 32b, 64b and 128b element lengths.
 *
 * If there are two vectors with 4 elements the transpositions are as follows:
 * Transposition            TRN1                          TRN2
 *                 +----+----+----+----+         +----+----+----+----+
 * Input A         | A3 | A2 | A1 | A0 |         | A3 | A2 | A1 | A0 |
 *                 +----+----+----+----+         +----+----+----+----+
 *                 +----+----+----+----+         +----+----+----+----+
 * Input B         | B3 | B2 | B1 | B0 |         | B3 | B2 | B1 | B0 |
 *                 +----+----+----+----+         +----+----+----+----+
 *                 +----+----+----+----+         +----+----+----+----+
 * Result          | B2 | A2 | B0 | A0 |         | B3 | A3 | B1 | A1 |
 *                 +----+----+----+----+         +----+----+----+----+
 */

module otbn_vec_transposer
  import otbn_pkg::*;
(
  input  logic [VLEN-1:0]   operand_a_i,
  input  logic [VLEN-1:0]   operand_b_i,
  input  logic              is_trn1_i,
  input  trn_elen_e         elen_i,
  output logic [VLEN-1:0]   result_o
);
  // HACK: This module is based upon 16bit chunks (for future 16bit support).
  //       The transposition logic must be changed manually When the VLEN or ELEN change!

  typedef struct packed {
    logic [15:0] chunk;
  } vector_chunk_t;

  logic [VLEN-1:0] res_trn1;
  logic [VLEN-1:0] res_trn2;

  vector_chunk_t [15:0] vec_a;
  vector_chunk_t [15:0] vec_b;

  assign vec_a = operand_a_i;
  assign vec_b = operand_b_i;

  // TODO, hardening: Add blankers to separate TRN1/2 paths or can this be handled with the
  // onehot MUX as there is no logic in front of the MUX?
  // TODO, hardening: Convert to onehot MUX?

  always_comb begin
    unique case (elen_i)
      TrnElen32: begin
         res_trn1 = {vec_b[13], vec_b[12], vec_a[13], vec_a[12],
                     vec_b[ 9], vec_b[ 8], vec_a[ 9], vec_a[ 8],
                     vec_b[ 5], vec_b[ 4], vec_a[ 5], vec_a[ 4],
                     vec_b[ 1], vec_b[ 0], vec_a[ 1], vec_a[ 0]};
         res_trn2 = {vec_b[15], vec_b[14], vec_a[15], vec_a[14],
                     vec_b[11], vec_b[10], vec_a[11], vec_a[10],
                     vec_b[ 7], vec_b[ 6], vec_a[ 7], vec_a[ 6],
                     vec_b[ 3], vec_b[ 2], vec_a[ 3], vec_a[ 2]};
      end
      TrnElen64: begin
        res_trn1 = {vec_b[11], vec_b[10], vec_b[ 9], vec_b[ 8],
                    vec_a[11], vec_a[10], vec_a[ 9], vec_a[ 8],
                    vec_b[ 3], vec_b[ 2], vec_b[ 1], vec_b[ 0],
                    vec_a[ 3], vec_a[ 2], vec_a[ 1], vec_a[ 0]};
        res_trn2 = {vec_b[15], vec_b[14], vec_b[13], vec_b[12],
                    vec_a[15], vec_a[14], vec_a[13], vec_a[12],
                    vec_b[ 7], vec_b[ 6], vec_b[ 5], vec_b[ 4],
                    vec_a[ 7], vec_a[ 6], vec_a[ 5], vec_a[ 4]};
      end
      TrnElen128: begin
        res_trn1 = {vec_b[ 7], vec_b[ 6], vec_b[ 5], vec_b[ 4],
                    vec_b[ 3], vec_b[ 2], vec_b[ 1], vec_b[ 0],
                    vec_a[ 7], vec_a[ 6], vec_a[ 5], vec_a[ 4],
                    vec_a[ 3], vec_a[ 2], vec_a[ 1], vec_a[ 0]};
        res_trn2 = {vec_b[15], vec_b[14], vec_b[13], vec_b[12],
                    vec_b[11], vec_b[10], vec_b[ 9], vec_b[ 8],
                    vec_a[15], vec_a[14], vec_a[13], vec_a[12],
                    vec_a[11], vec_a[10], vec_a[ 9], vec_a[ 8]};
      end
    endcase
  end

  assign result_o = is_trn1_i ? res_trn1 : res_trn2;

endmodule
