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
  input  logic [WLEN-1:0] mod_i,
  input  elen_bignum_e    elen_i,

  output logic [WLEN-1:0] mod_replicated_o
);
  logic [WLEN-1:0] mod; // from MOD WSR
  logic [WLEN-1:0] mod_rep;

  assign mod = mod_i;

  always_comb begin
    unique case(elen_i)
    VecElen16:  mod_rep = {16{mod[ 15:0]}};
    VecElen32:  mod_rep = { 8{mod[ 31:0]}};
    VecElen64:  mod_rep = { 4{mod[ 63:0]}};
    VecElen128: mod_rep = { 2{mod[127:0]}};
    default: mod_rep = mod;
    endcase
  end

assign mod_replicated_o = mod_rep;

endmodule
