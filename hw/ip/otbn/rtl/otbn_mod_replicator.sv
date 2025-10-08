// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * This module replicates the ELEN bit long modulus value WLEN/ELEN times.
 * The modulus is stored in a WLEN register.
 */
module otbn_mod_replicator
  import otbn_pkg::*;
(
  input  logic [WLEN-1:0]  mod_i,
  input  logic [NELEN-1:0] elen_onehot_i,
  output logic [WLEN-1:0]  mod_replicated_o
);
  logic [WLEN-1:0] mod; // from MOD WSR
  logic [WLEN-1:0] mod_rep [NELEN];

  assign mod = mod_i;

  assign mod_rep[VecElen16]  = {16{mod[ 15:0]}};
  assign mod_rep[VecElen32]  = { 8{mod[ 31:0]}};
  assign mod_rep[VecElen64]  = { 4{mod[ 63:0]}};
  assign mod_rep[VecElen128] = { 2{mod[127:0]}};
  assign mod_rep[VecElen256] = mod;

  prim_onehot_mux #(
    .Width(WLEN),
    .Inputs(NELEN)
  ) u_vec_mod_sel_elen_mux (
    .clk_i (),
    .rst_ni(),
    .in_i  (mod_rep),
    .sel_i (elen_onehot_i),
    .out_o (mod_replicated_o)
  );
endmodule
