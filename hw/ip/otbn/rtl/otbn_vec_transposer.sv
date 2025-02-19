// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Vectorized Transposer
 *
 * This module transposes the elements of two input vectors in two different ways.
 * It only supports 16b, 32b, 64b, 128b. The 256b value is not supported!
 *
 * If we have two vectors with 4 elements the transpositions are as follows:
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
  input  logic[VLEN-1:0]   operand_a_i,
  input  logic[VLEN-1:0]   operand_b_i,
  input  logic             is_trn1_i,
  input  logic [NELEN-1:0] elen_onehot_i,
  output logic[VLEN-1:0]   result_o
);
  typedef struct packed {
    logic [15:0] chunk;
  } vector_chunk_t;

  logic [VLEN-1:0] res_trn1;
  logic [VLEN-1:0] res_trn2;
  logic [VLEN-1:0] res_trn1_all [NELEN];
  logic [VLEN-1:0] res_trn2_all [NELEN];

  vector_chunk_t [15:0] vec_a;
  vector_chunk_t [15:0] vec_b;

  assign vec_a = operand_a_i;
  assign vec_b = operand_b_i;

  assign res_trn1_all[VecElen16]  = {vec_b[14], vec_a[14], vec_b[12], vec_a[12],
                                     vec_b[10], vec_a[10], vec_b[ 8], vec_a[ 8],
                                     vec_b[ 6], vec_a[ 6], vec_b[ 4], vec_a[ 4],
                                     vec_b[ 2], vec_a[ 2], vec_b[ 0], vec_a[ 0]};
  assign res_trn2_all[VecElen16]  = {vec_b[15], vec_a[15], vec_b[13], vec_a[13],
                                     vec_b[11], vec_a[11], vec_b[ 9], vec_a[ 9],
                                     vec_b[ 7], vec_a[ 7], vec_b[ 5], vec_a[ 5],
                                     vec_b[ 3], vec_a[ 3], vec_b[ 1], vec_a[ 1]};

  assign res_trn1_all[VecElen32]  = {vec_b[13], vec_b[12], vec_a[13], vec_a[12],
                                     vec_b[ 9], vec_b[ 8], vec_a[ 9], vec_a[ 8],
                                     vec_b[ 5], vec_b[ 4], vec_a[ 5], vec_a[ 4],
                                     vec_b[ 1], vec_b[ 0], vec_a[ 1], vec_a[ 0]};
  assign res_trn2_all[VecElen32]  = {vec_b[15], vec_b[14], vec_a[15], vec_a[14],
                                     vec_b[11], vec_b[10], vec_a[11], vec_a[10],
                                     vec_b[ 7], vec_b[ 6], vec_a[ 7], vec_a[ 6],
                                     vec_b[ 3], vec_b[ 2], vec_a[ 3], vec_a[ 2]};

  assign res_trn1_all[VecElen64]  = {vec_b[11], vec_b[10], vec_b[ 9], vec_b[ 8],
                                     vec_a[11], vec_a[10], vec_a[ 9], vec_a[ 8],
                                     vec_b[ 3], vec_b[ 2], vec_b[ 1], vec_b[ 0],
                                     vec_a[ 3], vec_a[ 2], vec_a[ 1], vec_a[ 0]};
  assign res_trn2_all[VecElen64]  = {vec_b[15], vec_b[14], vec_b[13], vec_b[12],
                                     vec_a[15], vec_a[14], vec_a[13], vec_a[12],
                                     vec_b[ 7], vec_b[ 6], vec_b[ 5], vec_b[ 4],
                                     vec_a[ 7], vec_a[ 6], vec_a[ 5], vec_a[ 4]};

  assign res_trn1_all[VecElen128] = {vec_b[ 7], vec_b[ 6], vec_b[ 5], vec_b[ 4],
                                     vec_b[ 3], vec_b[ 2], vec_b[ 1], vec_b[ 0],
                                     vec_a[ 7], vec_a[ 6], vec_a[ 5], vec_a[ 4],
                                     vec_a[ 3], vec_a[ 2], vec_a[ 1], vec_a[ 0]};
  assign res_trn2_all[VecElen128] = {vec_b[15], vec_b[14], vec_b[13], vec_b[12],
                                     vec_b[11], vec_b[10], vec_b[ 9], vec_b[ 8],
                                     vec_a[15], vec_a[14], vec_a[13], vec_a[12],
                                     vec_a[11], vec_a[10], vec_a[ 9], vec_a[ 8]};

  // This ELEN is not supported. We simply return operand a. TODO: abort with assertion
  assign res_trn1_all[VecElen256] = operand_a_i;
  assign res_trn2_all[VecElen256] = operand_a_i;

  prim_onehot_mux #(
    .Width(VLEN),
    .Inputs(NELEN)
  ) u_vec_transposer_elen_trn1_mux (
    .clk_i (),
    .rst_ni(),
    .in_i  (res_trn1_all),
    .sel_i (elen_onehot_i),
    .out_o (res_trn1)
  );

  prim_onehot_mux #(
    .Width(VLEN),
    .Inputs(NELEN)
  ) u_vec_transposer_elen_trn2_mux (
    .clk_i (),
    .rst_ni(),
    .in_i  (res_trn2_all),
    .sel_i (elen_onehot_i),
    .out_o (res_trn2)
  );

  always_comb begin : g_mux_res_sel
    result_o = is_trn1_i ? res_trn1 : res_trn2;
  end

  /* // Alternative solution with loops but not onehot encoded
  logic [VLEN-1:0] result_trn1_16b;
  logic [VLEN-1:0] result_trn1_32b;
  logic [VLEN-1:0] result_trn1_64b;
  logic [VLEN-1:0] result_trn1_128b;
  logic [VLEN-1:0] result_trn2_16b;
  logic [VLEN-1:0] result_trn2_32b;
  logic [VLEN-1:0] result_trn2_64b;
  logic [VLEN-1:0] result_trn2_128b;

  always_comb begin
    result_trn1_16b  = 'b0;
    result_trn1_32b  = 'b0;
    result_trn1_64b  = 'b0;
    result_trn1_128b = 'b0;
    result_trn2_16b  = 'b0;
    result_trn2_32b  = 'b0;
    result_trn2_64b  = 'b0;
    result_trn2_128b = 'b0;

    result_o = 'b0;

    // This is not nice. We specify the same loop for each ELEN type.
    // There is certainly a nicer solution..
    // Idea: A giant MUX structure which handles each 16b chunk separately?
    unique case (elen_i)
      VecElen16: begin
        localparam int Elen = 16;
        localparam int NumElem = 16;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_16b
          result_trn1_16b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_16b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_16b
          result_trn2_16b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_16b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_16b : result_trn2_16b;
      end
      VecElen32: begin
        localparam int Elen = 32;
        localparam int NumElem = 8;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_32b
          result_trn1_32b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_32b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_32b
          result_trn2_32b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_32b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_32b : result_trn2_32b;
      end
      VecElen64: begin
        localparam int Elen = 64;
        localparam int NumElem = 4;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_64b
          result_trn1_64b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_64b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_64b
          result_trn2_64b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_64b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_64b : result_trn2_64b;
      end
      VecElen128: begin
        localparam int Elen = 128;
        localparam int NumElem = 2;
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn1_128b
          result_trn1_128b[i_elem*Elen+:Elen]     = operand_a_i[i_elem*Elen+:Elen];
          result_trn1_128b[(i_elem+1)*Elen+:Elen] = operand_b_i[i_elem*Elen+:Elen];
        end
        for (int i_elem = 0; i_elem < NumElem; i_elem+=2) begin : g_trn2_128b
          result_trn2_128b[i_elem*Elen+:Elen]     = operand_a_i[(i_elem+1)*Elen+:Elen];
          result_trn2_128b[(i_elem+1)*Elen+:Elen] = operand_b_i[(i_elem+1)*Elen+:Elen];
        end
        result_o = is_trn1_i ? result_trn1_128b : result_trn2_128b;
      end
      default: result_o = 'b0;// We do not support the 256b case -> TODO: Crash with assertion?
    endcase
  end
  */
endmodule
