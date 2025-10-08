// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module otbn_predecode
  import otbn_pkg::*;
#(
  parameter int ImemSizeByte = 4096,

  localparam int ImemAddrWidth = prim_util_pkg::vbits(ImemSizeByte)
) (
  input  logic                   clk_i,
  input  logic                   rst_ni,

  input  logic [31:0]              imem_rdata_i,
  input  logic                     imem_rvalid_i,
  input  logic [ImemAddrWidth-1:0] imem_raddr_i,

  output rf_predec_bignum_t        rf_predec_bignum_o,
  output alu_predec_bignum_t       alu_predec_bignum_o,
  output ispr_predec_bignum_t      ispr_predec_bignum_o,
  output mac_predec_bignum_t       mac_predec_bignum_o,
  output logic                     lsu_addr_en_predec_o,
  output ctrl_flow_predec_t        ctrl_flow_predec_o,
  output logic [ImemAddrWidth-1:0] ctrl_flow_target_predec_o
);
  // The ISA has a fixed 12 bits for loop_bodysize. The maximum possible address for the end of a
  // loop is the maximum address in Imem (2^ImemAddrWidth - 4) plus loop_bodysize instructions
  // (which take 4 * (2^12 - 1) bytes), plus 4 extra bytes. This simplifies to
  //
  //    (1 << ImemAddrWidth) + (1 << 14) - 4
  //
  // which is strictly less than (1 << (max(ImemAddrWidth, 14) + 1)), so can be represented with
  // max(ImemAddrWidth, 14) + 1 bits.
  localparam int unsigned LoopEndAddrWidth = 1 + (ImemAddrWidth < 14 ? 14 : ImemAddrWidth);

  logic rf_ren_a_base;
  logic rf_ren_b_base;
  // Three separate write enables as the indirect register accesses can write back to the a or
  // b source registers. For all other instructions any base register write will be to the
  // d destination register.
  logic rf_we_a_base;
  logic rf_we_b_base;
  logic rf_we_d_base;
  logic rf_ren_a_bignum;
  logic rf_ren_b_bignum;
  logic rf_we_bignum;
  logic alu_bignum_adder_x_en;
  logic alu_bignum_x_res_operand_a_sel;
  logic alu_bignum_adder_y_op_a_en;
  logic alu_bignum_adder_y_op_shifter_en;
  logic alu_bignum_shifter_a_en;
  logic alu_bignum_shifter_b_en;
  logic alu_bignum_shift_right;
  logic [$clog2(WLEN)-1:0] alu_bignum_shift_amt;
  logic alu_bignum_shift_mod_sel;
  logic alu_bignum_logic_a_en;
  logic alu_bignum_logic_shifter_en;
  logic [3:0] alu_bignum_logic_res_sel;

  flag_group_t flag_group;
  logic [NFlagGroups-1:0] flag_group_sel;
  flags_t flag_sel;

  logic [NFlagGroups-1:0] flags_keep;
  logic [NFlagGroups-1:0] flags_adder_update;
  logic [NFlagGroups-1:0] flags_logic_update;
  logic [NFlagGroups-1:0] flags_mac_update;
  logic [NFlagGroups-1:0] flags_ispr_wr;

  // The ISA forsees only 4 types of vector element lengths (16, 32, 64 and 128 bits). However,
  // some regular and vectorized instructions share the hardware and thus we need a 256b type
  // to signal "regular" 256b operation. We thus first extract the ELEN from the instruction and
  // then depending on the instruction convert it correctly. Vectorized instructions for the ALU
  // and MAC have different bits for encoding the ELEN.
  logic [1:0]          alu_bignum_vec_elen_raw;
  elen_bignum_e        alu_bignum_vec_elen; // The parsed vector element length incl. 256b
  logic [NELEN-1:0]    alu_bignum_vec_elen_onehot;
  logic [1:0]          mac_bignum_vec_elen_raw;
  elen_mac_e           mac_bignum_vec_elen; // The parsed vector element length 16b, 32b or 64b
  logic [NELENMAC-1:0] mac_bignum_vec_elen_onehot;

  // Control signal for the vectorized adders to propagate the carry bits depending on the element
  // length. Each bit controls one vector chunk. Is generated from the parsed vector ELEN.
  logic [NVecProc-1:0] alu_bignum_vec_adder_carry_sel;
  logic [NVecProc-1:0] mac_bignum_vec_adder_carry_sel;
  logic [1:0]          mac_bignum_vec_mul_elen_ctrl;

  // Mod output selector control signals
  logic alu_bignum_vec_mod_selector_en;
  logic alu_bignum_vec_mod_is_subtraction;

  // Mask for the vectorized shifter. Must be predecoded to have a stable shifting.
  logic [WLEN-1:0] alu_bignum_vec_shifter_mask;

  // Vector tranposer control signal
  logic alu_bignum_vec_transposer_en;
  logic alu_bignum_vec_transposer_is_trn1;

  // MAC control signals
  logic          mac_bignum_op_en;
  logic          mac_bignum_is_mod;
  logic          mac_bignum_is_vec;
  mac_mul_type_e mac_bignum_mul_type;

  // MAC Blanker control signals
  logic          mac_bignum_mul_shift_en;
  logic          mac_bignum_mul_merger_en;
  logic          mac_bignum_add_res_en;
  logic          mac_bignum_acc_add_en;

  logic ispr_rd_en;
  logic ispr_wr_en;

  logic csr_addr_sel;
  logic [4:0] insn_rs1, insn_rs2, insn_rd;

  logic branch_insn;
  logic jump_insn;
  logic loop_insn;
  logic sel_insn;

  wsr_e  wsr_addr;
  csr_e  csr_addr;
  ispr_e ispr_addr;

  logic [31:0]                 imm_b_type_base;
  logic [31:0]                 imm_j_type_base;
  logic [LoopEndAddrWidth-1:0] loop_end_addr;

  assign csr_addr = csr_e'(imem_rdata_i[31:20]);
  assign wsr_addr = wsr_e'(imem_rdata_i[20 +: WsrNumWidth]);

  assign imm_b_type_base = {{19{imem_rdata_i[31]}}, imem_rdata_i[31], imem_rdata_i[7],
    imem_rdata_i[30:25], imem_rdata_i[11:8], 1'b0};

  assign imm_j_type_base =
    {{12{imem_rdata_i[31]}}, imem_rdata_i[19:12], imem_rdata_i[20], imem_rdata_i[30:21], 1'b0};

  logic unused_imm_b_type_base;
  assign unused_imm_b_type_base = ^imm_b_type_base[31:ImemAddrWidth];

  logic unused_imm_j_type_base;
  assign unused_imm_j_type_base = ^imm_j_type_base[31:ImemAddrWidth];

  assign loop_end_addr = LoopEndAddrWidth'(imem_raddr_i) +
                         LoopEndAddrWidth'({imem_rdata_i[31:20], 2'b00}) + 'd4;

  if (LoopEndAddrWidth > ImemAddrWidth) begin : g_unused_loop_end_addr
    logic unused_loop_end_addr;

    assign unused_loop_end_addr = ^loop_end_addr[LoopEndAddrWidth-1:ImemAddrWidth];
  end

  // Shift amount for ALU instructions other than BN.RSHI
  logic [$clog2(WLEN)-1:0] shift_amt_a_type_bignum;
  // Shift amount for BN.RSHI
  logic [$clog2(WLEN)-1:0] shift_amt_s_type_bignum;
  // Shift amount for BN.SHV
  logic [$clog2(WLEN)-1:0] shift_amt_shv_bignum;

  assign shift_amt_a_type_bignum = {imem_rdata_i[29:25], 3'b0};
  assign shift_amt_s_type_bignum = {imem_rdata_i[31:25], imem_rdata_i[14]};
  assign shift_amt_shv_bignum    = {1'b0, imem_rdata_i[26:25], imem_rdata_i[19:15]};

  assign flag_group     = imem_rdata_i[31];
  assign flag_group_sel = {(flag_group == 1'b1), (flag_group == 1'b0)};
  assign flag_sel.C = flag_e'(imem_rdata_i[26:25]) == FlagC;
  assign flag_sel.M = flag_e'(imem_rdata_i[26:25]) == FlagM;
  assign flag_sel.L = flag_e'(imem_rdata_i[26:25]) == FlagL;
  assign flag_sel.Z = flag_e'(imem_rdata_i[26:25]) == FlagZ;

  assign flags_keep = ~(flags_adder_update | flags_logic_update | flags_mac_update | flags_ispr_wr);

  assign alu_bignum_vec_elen_raw = imem_rdata_i[29:28];
  assign mac_bignum_vec_elen_raw = imem_rdata_i[27:26];

  always_comb begin
    rf_ren_a_base   = 1'b0;
    rf_ren_b_base   = 1'b0;
    rf_we_a_base    = 1'b0;
    rf_we_b_base    = 1'b0;
    rf_we_d_base    = 1'b0;

    rf_ren_a_bignum = 1'b0;
    rf_ren_b_bignum = 1'b0;
    rf_we_bignum    = 1'b0;

    alu_bignum_adder_x_en            = 1'b0;
    alu_bignum_x_res_operand_a_sel   = 1'b0;
    alu_bignum_adder_y_op_a_en       = 1'b0;
    alu_bignum_adder_y_op_shifter_en = 1'b0;
    alu_bignum_shifter_a_en          = 1'b0;
    alu_bignum_shifter_b_en          = 1'b0;
    alu_bignum_shift_right           = 1'b0;
    alu_bignum_shift_amt             = shift_amt_a_type_bignum;
    alu_bignum_shift_mod_sel         = 1'b1;
    alu_bignum_logic_a_en            = 1'b0;
    alu_bignum_logic_shifter_en      = 1'b0;
    alu_bignum_logic_res_sel         = '0;

    flags_adder_update = '0;
    flags_logic_update = '0;
    flags_mac_update   = '0;
    flags_ispr_wr      = '0;

    // Default is 256b vector element length (ELEN)
    alu_bignum_vec_elen               = VecElen256;
    alu_bignum_vec_mod_selector_en    = 1'b0;
    alu_bignum_vec_mod_is_subtraction = 1'b0;
    alu_bignum_vec_transposer_en      = 1'b0;
    alu_bignum_vec_transposer_is_trn1 = 1'b0;

    // Default we multiply two 64b values and add 256b values
    mac_bignum_vec_elen = VecMacElen64;
    mac_bignum_op_en    = 1'b0;
    mac_bignum_is_mod   = 1'b0;
    mac_bignum_is_vec   = 1'b0;
    mac_bignum_mul_type = MacMulRegular;

    // MAC Blanker control signals
    mac_bignum_mul_shift_en = 1'b0;
    mac_bignum_mul_merger_en = 1'b0;
    mac_bignum_add_res_en = 1'b0;
    mac_bignum_acc_add_en = 1'b0;

    ispr_rd_en = 1'b0;
    ispr_wr_en = 1'b0;

    csr_addr_sel = 1'b0;

    lsu_addr_en_predec_o = 1'b0;

    branch_insn = 1'b0;
    jump_insn   = 1'b0;
    loop_insn   = 1'b0;
    sel_insn    = 1'b0;

    ctrl_flow_target_predec_o = '0;

    if (imem_rvalid_i) begin
      unique case (imem_rdata_i[6:0])

        //////////////
        // Base ALU //
        //////////////

        InsnOpcodeBaseLui: begin  // Load Upper Immediate
          rf_we_d_base = 1'b1;
        end

        InsnOpcodeBaseOpImm: begin  // Register-Immediate ALU Operations
          rf_ren_a_base = 1'b1;
          rf_we_d_base  = 1'b1;
        end

        InsnOpcodeBaseOp: begin  // Register-Register ALU operation
          rf_ren_a_base = 1'b1;
          rf_ren_b_base = 1'b1;
          rf_we_d_base  = 1'b1;
        end

        ///////////////////////
        // Base Load / Store //
        ///////////////////////

        InsnOpcodeBaseLoad: begin
          rf_ren_a_base = 1'b1;
          rf_we_d_base  = 1'b1;

          if (imem_rdata_i[14:12] == 3'b010) begin
            lsu_addr_en_predec_o = 1'b1;
          end
        end

        InsnOpcodeBaseStore: begin
          rf_ren_a_base = 1'b1;
          rf_ren_b_base = 1'b1;

          if (imem_rdata_i[14:12] == 3'b010) begin
            lsu_addr_en_predec_o = 1'b1;
          end
        end


        ////////////////////////
        // Base Jump / Branch //
        ////////////////////////

        InsnOpcodeBaseBranch: begin
          rf_ren_a_base             = 1'b1;
          rf_ren_b_base             = 1'b1;
          branch_insn               = 1'b1;
          ctrl_flow_target_predec_o = imem_raddr_i + imm_b_type_base[ImemAddrWidth-1:0];
        end

        InsnOpcodeBaseJal: begin
          rf_we_d_base              = 1'b1;
          jump_insn                 = 1'b1;
          ctrl_flow_target_predec_o = imem_raddr_i + imm_j_type_base[ImemAddrWidth-1:0];
        end

        InsnOpcodeBaseJalr: begin
          rf_ren_a_base = 1'b1;
          rf_we_d_base  = 1'b1;
          jump_insn     = 1'b1;
        end

        //////////////
        // Base CSR //
        //////////////

        InsnOpcodeBaseSystem: begin
          csr_addr_sel = 1'b1;

          if (imem_rdata_i[14:12] != 3'b000) begin
            // Any CSR access
            rf_ren_a_base = 1'b1;
            rf_we_d_base  = 1'b1;
          end

          if (csr_addr == CsrRndPrefetch) begin
            // Prefetch CSR does not access any ISPR
            ispr_rd_en = 1'b0;
            ispr_wr_en = 1'b0;
          end else if (imem_rdata_i[14:12] == 3'b001) begin
            // No read if destination is x0 unless read is to flags CSR. Both flag groups are in
            // a single ISPR so to write one group the other must be read to write it back
            // unchanged.
            ispr_rd_en    = (imem_rdata_i[11:7] != 5'b0) | (csr_addr == CsrFg0) |
                                                           (csr_addr == CsrFg1);
            ispr_wr_en    = 1'b1;
            flags_ispr_wr = {(csr_addr == CsrFg1), (csr_addr == CsrFg0)} |
                            {NFlagGroups{csr_addr == CsrFlags}};
          end else if (imem_rdata_i[14:12] == 3'b010) begin
            // Read and set if source register isn't x0, otherwise read only
            if (imem_rdata_i[19:15] != 5'b0) begin
              ispr_rd_en    = 1'b1;
              ispr_wr_en    = 1'b1;
              flags_ispr_wr = {(csr_addr == CsrFg1), (csr_addr == CsrFg0)} |
                              {NFlagGroups{csr_addr == CsrFlags}};
            end else begin
              ispr_rd_en = 1'b1;
            end
          end
        end

        ////////////////
        // Bignum ALU //
        ////////////////

        InsnOpcodeBignumArith: begin
          unique case (imem_rdata_i[14:12])
            3'b000, 3'b001, 3'b010, 3'b011:  begin
              // BN.ADD/BN.SUB/BN.ADDC/BN.SUBB
              rf_ren_a_bignum                  = 1'b1;
              rf_ren_b_bignum                  = 1'b1;
              rf_we_bignum                     = 1'b1;
              alu_bignum_shifter_b_en          = 1'b1;
              alu_bignum_shift_right           = imem_rdata_i[30];
              alu_bignum_shift_amt             = shift_amt_a_type_bignum;
              alu_bignum_adder_y_op_a_en       = 1'b1;
              alu_bignum_adder_y_op_shifter_en = 1'b1;
              flags_adder_update[flag_group]   = 1'b1;
            end
            3'b100: begin
              // BN.ADDI/BN.SUBI
              rf_ren_a_bignum                  = 1'b1;
              rf_we_bignum                     = 1'b1;
              alu_bignum_shifter_b_en          = 1'b1;
              alu_bignum_shift_right           = imem_rdata_i[30];
              alu_bignum_shift_amt             = '0;
              alu_bignum_adder_y_op_a_en       = 1'b1;
              alu_bignum_adder_y_op_shifter_en = 1'b1;
              flags_adder_update[flag_group]   = 1'b1;
            end
            3'b101: begin
              // BN.ADDM/BN.SUBM
              rf_ren_a_bignum                   = 1'b1;
              rf_ren_b_bignum                   = 1'b1;
              rf_we_bignum                      = 1'b1;
              alu_bignum_shift_amt              = '0;
              alu_bignum_adder_x_en             = 1'b1;
              alu_bignum_x_res_operand_a_sel    = 1'b1;
              alu_bignum_shift_mod_sel          = 1'b0;
              alu_bignum_vec_mod_selector_en    = 1'b1;
              alu_bignum_vec_mod_is_subtraction = imem_rdata_i[30];
            end
            default: ;
          endcase
        end

        ////////////////////////////
        // Bignum vectorized insn //
        ////////////////////////////
        InsnOpcodeBignumVec: begin
          // Some instructions of this opcode are handled in the Bignum MAC.
          // 3'b011 is BN.MULV/BN.MULVL
          // 3'b100 is BN.MULVM/BN.MULVML

          unique case (imem_rdata_i[14:12])
            3'b000:  begin
              // BN.ADDV/BN.ADDVM/BN.SUBV/BN.SUBVM (also forseen for BN.ADDVC/BN.SUBVC)
              rf_ren_a_bignum      = 1'b1;
              rf_we_bignum         = 1'b1;
              alu_bignum_vec_elen  = parse_raw_elen(alu_bignum_vec_elen_raw);
              rf_ren_b_bignum      = 1'b1;
              alu_bignum_shift_amt = '0;

              if (imem_rdata_i[27]) begin // vectorized MOD operation
                alu_bignum_adder_x_en             = 1'b1;
                alu_bignum_x_res_operand_a_sel    = 1'b1;
                alu_bignum_shift_mod_sel          = 1'b0;
                alu_bignum_vec_mod_selector_en    = 1'b1;
                alu_bignum_vec_mod_is_subtraction = imem_rdata_i[30];
              end else begin // vectorized operation
                alu_bignum_adder_y_op_a_en       = 1'b1;
                alu_bignum_adder_y_op_shifter_en = 1'b1;
                alu_bignum_shifter_b_en          = 1'b1;
                alu_bignum_shift_amt             = '0;
              end
            end
            3'b101: begin
              // BN.TRN1/BN.TRN2
              rf_ren_a_bignum                   = 1'b1;
              rf_we_bignum                      = 1'b1;
              alu_bignum_vec_elen               = parse_raw_elen(alu_bignum_vec_elen_raw);
              rf_ren_b_bignum                   = 1'b1;
              alu_bignum_vec_transposer_en      = 1'b1;
              alu_bignum_vec_transposer_is_trn1 = ~imem_rdata_i[30];
              alu_bignum_shift_amt              = '0;
            end
            3'b111: begin
              // BN.SHV
              rf_ren_b_bignum         = 1'b1;
              rf_we_bignum            = 1'b1;
              alu_bignum_vec_elen     = parse_raw_elen(alu_bignum_vec_elen_raw);
              alu_bignum_shifter_b_en = 1'b1;
              alu_bignum_shift_right  = imem_rdata_i[30];
              alu_bignum_shift_amt    = shift_amt_shv_bignum;
            end
            3'b011: begin
              // 3'b011 is BN.MULV/BN.MULVL
              mac_bignum_op_en         = 1'b1;
              mac_bignum_is_vec        = 1'b1;
              mac_bignum_is_mod        = 1'b0;
              mac_bignum_mul_merger_en = 1'b1;
              mac_bignum_vec_elen      = parse_raw_mac_elen(mac_bignum_vec_elen_raw);

              rf_ren_a_bignum  = 1'b1;
              rf_ren_b_bignum  = 1'b1;
              rf_we_bignum     = 1'b1;

              mac_bignum_mul_type = MacMulVec;
              if (imem_rdata_i[25]) begin
                mac_bignum_mul_type = MacMulVecLane;
              end
            end
            3'b100: begin
              // 3'b100 is BN.MULVM/BN.MULVML
              mac_bignum_op_en    = 1'b1;
              mac_bignum_is_vec   = 1'b1;
              mac_bignum_is_mod   = 1'b1;
              mac_bignum_vec_elen = parse_raw_mac_elen(mac_bignum_vec_elen_raw);

              rf_ren_a_bignum  = 1'b1;
              rf_ren_b_bignum  = 1'b1;
              rf_we_bignum     = 1'b1;

              mac_bignum_mul_type = MacMulVecMod;
              if (imem_rdata_i[25]) begin
                mac_bignum_mul_type = MacMulVecModLane;
              end
            end
            default: ;
              // 3'b001 foreseen for BN.ADDVI/BN.SUBVI
              // 3'b010 reserved for future use
              // 3'b110 reserved for future use
          endcase
        end

        ////////////////////////////
        // Bignum logical/BN.RSHI //
        ////////////////////////////

        InsnOpcodeBignumBaseMisc: begin
          unique case (imem_rdata_i[14:12])
            3'b000, 3'b001: begin // BN.LOOP[I]
              rf_ren_a_base             = ~imem_rdata_i[12];
              loop_insn                 = 1'b1;
              ctrl_flow_target_predec_o = loop_end_addr[ImemAddrWidth-1:0];
            end
            3'b010, 3'b100, 3'b110:  begin  // BN.AND/BN.OR/BN.XOR
              rf_we_bignum                            = 1'b1;
              rf_ren_a_bignum                         = 1'b1;
              rf_ren_b_bignum                         = 1'b1;
              alu_bignum_shifter_b_en                 = 1'b1;
              alu_bignum_shift_right                  = imem_rdata_i[30];
              alu_bignum_shift_amt                    = shift_amt_a_type_bignum;
              alu_bignum_logic_a_en                   = 1'b1;
              alu_bignum_logic_shifter_en             = 1'b1;
              alu_bignum_logic_res_sel[AluOpLogicXor] = imem_rdata_i[14:12] == 3'b110;
              alu_bignum_logic_res_sel[AluOpLogicOr]  = imem_rdata_i[14:12] == 3'b100;
              alu_bignum_logic_res_sel[AluOpLogicAnd] = imem_rdata_i[14:12] == 3'b010;
              flags_logic_update[flag_group]          = 1'b1;
            end
            3'b111, 3'b011: begin // BN.RSHI
              rf_we_bignum            = 1'b1;
              rf_ren_a_bignum         = 1'b1;
              rf_ren_b_bignum         = 1'b1;
              alu_bignum_shifter_a_en = 1'b1;
              alu_bignum_shifter_b_en = 1'b1;
              alu_bignum_shift_right  = 1'b1;
              alu_bignum_shift_amt    = shift_amt_s_type_bignum;
            end
            3'b101: begin // BN.NOT
              rf_we_bignum                            = 1'b1;
              rf_ren_b_bignum                         = 1'b1;
              alu_bignum_shifter_b_en                 = 1'b1;
              alu_bignum_shift_right                  = imem_rdata_i[30];
              alu_bignum_shift_amt                    = shift_amt_a_type_bignum;
              alu_bignum_logic_shifter_en             = 1'b1;
              alu_bignum_logic_res_sel[AluOpLogicNot] = 1'b1;
              flags_logic_update[flag_group]          = 1'b1;
            end
            default: ;
          endcase
        end

        ///////////////////////////////////////////////
        // Bignum Misc WSR/LID/SID/MOV[R]/CMP[B]/SEL //
        ///////////////////////////////////////////////

        InsnOpcodeBignumMisc: begin
          unique case (imem_rdata_i[14:12])
            3'b000: begin // BN.SEL
              rf_we_bignum    = 1'b1;
              rf_ren_a_bignum = 1'b1;
              rf_ren_b_bignum = 1'b1;
              sel_insn        = 1'b1;
            end
            3'b011, 3'b001: begin // BN.CMP[B]
              rf_ren_a_bignum                  = 1'b1;
              rf_ren_b_bignum                  = 1'b1;
              alu_bignum_shifter_b_en          = 1'b1;
              alu_bignum_shift_right           = imem_rdata_i[30];
              alu_bignum_shift_amt             = shift_amt_a_type_bignum;
              alu_bignum_adder_y_op_a_en       = 1'b1;
              alu_bignum_adder_y_op_shifter_en = 1'b1;
              flags_adder_update[flag_group]   = 1'b1;
            end
            3'b100, 3'b101: begin  // BN.LID, BN.SID
              rf_ren_a_base        = 1'b1;
              rf_ren_b_base        = 1'b1;
              lsu_addr_en_predec_o = 1'b1;

              if (imem_rdata_i[8]) begin
                rf_we_a_base = 1'b1;
              end

              if (imem_rdata_i[7]) begin
                rf_we_b_base = 1'b1;
              end
            end
            3'b110: begin
              if (imem_rdata_i[31]) begin // BN.MOVR
                // bignum RF read and write occur in the following cycle due to the indirect
                // register access so aren't set here. otbn_controller sets the appropriate read and
                // write enables directly in the instruction fetch stage in the first cycle of the
                // instruction's execution (so they can be used in the second cycle which performs
                // the bignum RF access).
                rf_ren_a_base   = 1'b1;
                rf_ren_b_base   = 1'b1;

                if (imem_rdata_i[9]) begin
                  rf_we_a_base = 1'b1;
                end else if (imem_rdata_i[7]) begin
                  rf_we_b_base = 1'b1;
                end
              end else begin // BN.MOV
                rf_we_bignum    = 1'b1;
                rf_ren_a_bignum = 1'b1;
              end
            end
            3'b111: begin
              if (imem_rdata_i[31]) begin  // BN.WSRW
                rf_ren_a_bignum = 1'b1;
                ispr_wr_en      = 1'b1;
              end else begin  // BN.WSRR
                rf_we_bignum = 1'b1;
                ispr_rd_en   = 1'b1;
              end
            end
            default: ;
          endcase
        end

        ////////////////////////////////////////////
        // BN.MULQACC/BN.MULQACC.WO/BN.MULQACC.SO //
        ////////////////////////////////////////////

        InsnOpcodeBignumMulqacc: begin
          rf_ren_a_bignum         = 1'b1;
          rf_ren_b_bignum         = 1'b1;
          mac_bignum_op_en        = 1'b1;
          mac_bignum_mul_type     = MacMulRegular;
          mac_bignum_mul_shift_en = 1'b1;
          mac_bignum_add_res_en   = 1'b1;

          // BN.MULQACC.WO/BN.MULQACC.SO
          if (imem_rdata_i[30] == 1'b1 || imem_rdata_i[29] == 1'b1) begin
            rf_we_bignum                 = 1'b1;
            flags_mac_update[flag_group] = 1'b1;
          end

          if (imem_rdata_i[12] == 1'b0) begin
            // zero_acc not set
            mac_bignum_acc_add_en = 1'b1;
          end
        end

        default: ;
      endcase
    end

    // Generate stabilized control signals depending on the finally selected ELEN for BN ALU
    //
    // Vectorized adder:
    //   Define the carry handling MUX controls depending on ELEN. A bit for each MUX.
    //   If set: Select carry from previous stage. Else use the external carry.
    //   The adder 0 always takes the external carry.
    // Vectorized shifter
    //   Shift mask depending on the shift_amt and ELEN
    unique case (alu_bignum_vec_elen) // TODO: Make dynamic depending on VLEN, NVecProc, VChunkLEN
      VecElen16: begin
        alu_bignum_vec_adder_carry_sel = {16{1'b1}};
        // we need a 16b mask. The -1 in the () term defaults to value of at least 32b.
        // Thus we need to specify the width explicitly
        alu_bignum_vec_shifter_mask    = { 16{(( 16'd1 << ( 16-alu_bignum_shift_amt)) -  16'd1)}};
      end
      VecElen32: begin
        alu_bignum_vec_adder_carry_sel = {8{2'b01}};
        // for >=32b the -1 in the () term expands to the correct bit width.
        // Nonetheless specify it for clarity
        alu_bignum_vec_shifter_mask    = {  8{(( 32'd1 << ( 32-alu_bignum_shift_amt)) -  32'd1)}};
      end
      VecElen64: begin
        alu_bignum_vec_adder_carry_sel = {4{4'b0001}};
        alu_bignum_vec_shifter_mask    = {  4{(( 64'd1 << ( 64-alu_bignum_shift_amt)) -  64'd1)}};
      end
      VecElen128: begin
        alu_bignum_vec_adder_carry_sel = {2{8'b0000_0001}};
        alu_bignum_vec_shifter_mask    = {  2{((128'd1 << (128-alu_bignum_shift_amt)) - 128'd1)}};
      end
      VecElen256: begin
        alu_bignum_vec_adder_carry_sel = 16'd1;
        alu_bignum_vec_shifter_mask    = {256{1'b1}};
      end
      default: begin // TODO: Throw error -> Use assert
        alu_bignum_vec_adder_carry_sel = '1;
        alu_bignum_vec_shifter_mask    = {256{1'b1}};
      end
    endcase

    // Generate stabilized control signals depending on the finally selected ELEN for BN MAC
    // The ELEN controls the vectorized multiplier and the adder and subtractor in the Modulo
    // reduction path. The adder is 256b wide (128b for modulo case, 256b for ACC handling).
    // The subtractor is 64b and is only used for the modulo case.
    // TODO: assert that ELEN is only 16b, 32b or 256b depending on mulv type
    unique case (mac_bignum_vec_elen)
      VecMacElen32: begin
        // Modulo reduction for 32b elements:
        // - Adder: We operate on two 64b elements in parallel
        //   16 carry sel bits because we have a 256b adder
        // - Subtractor: We operate on two 32b elements in parallel
        mac_bignum_vec_adder_carry_sel = {4{4'b0001}};
        mac_bignum_vec_mul_elen_ctrl   = 2'b01;
      end
      VecMacElen64: begin
        // Regular 64b multiplication with ACC accumulation
        // - Adder: We operate on 256b values
        // - Subtractor: Unused
        mac_bignum_vec_adder_carry_sel = 16'd1;
        mac_bignum_vec_mul_elen_ctrl   = 2'b11;
      end
      default: begin // TODO: Throw error -> Use assert
        mac_bignum_vec_adder_carry_sel = '1;
        mac_bignum_vec_mul_elen_ctrl   = 2'b00;
      end
    endcase

  end

  // ELEN onehot encoded for mod result selection and mod replicator.
  prim_onehot_enc #(
    .OneHotWidth (NELEN)
  ) u_alu_vec_elen_enc (
    .in_i (alu_bignum_vec_elen),
    .en_i ('1), // always enable
    .out_o(alu_bignum_vec_elen_onehot)
  );

  // MAC ELEN onehot encoded for multiplier.
  prim_onehot_enc #(
    .OneHotWidth (NELENMAC)
  ) u_mac_vec_elen_enc (
    .in_i (mac_bignum_vec_elen),
    .en_i ('1), // always enable
    .out_o(mac_bignum_vec_elen_onehot)
  );

  always_comb begin
    ispr_addr = IsprMod;

    if (csr_addr_sel) begin
      unique case (csr_addr)
        CsrFlags, CsrFg0, CsrFg1:           ispr_addr = IsprFlags;
        CsrMod0, CsrMod1, CsrMod2, CsrMod3,
        CsrMod4, CsrMod5, CsrMod6, CsrMod7: ispr_addr = IsprMod;
        CsrRnd:                             ispr_addr = IsprRnd;
        CsrUrnd:                            ispr_addr = IsprUrnd;
        default: ;
      endcase
    end else begin
      unique case (wsr_addr)
        WsrMod:    ispr_addr = IsprMod;
        WsrRnd:    ispr_addr = IsprRnd;
        WsrUrnd:   ispr_addr = IsprUrnd;
        WsrAcc:    ispr_addr = IsprAcc;
        WsrKeyS0L: ispr_addr = IsprKeyS0L;
        WsrKeyS0H: ispr_addr = IsprKeyS0H;
        WsrKeyS1L: ispr_addr = IsprKeyS1L;
        WsrKeyS1H: ispr_addr = IsprKeyS1H;
        default: ;
      endcase
    end
  end

  assign alu_predec_bignum_o.adder_x_en             = alu_bignum_adder_x_en;
  assign alu_predec_bignum_o.x_res_operand_a_sel    = alu_bignum_x_res_operand_a_sel;
  assign alu_predec_bignum_o.adder_y_op_a_en        = alu_bignum_adder_y_op_a_en;
  assign alu_predec_bignum_o.adder_y_op_shifter_en  = alu_bignum_adder_y_op_shifter_en;
  assign alu_predec_bignum_o.shifter_a_en           = alu_bignum_shifter_a_en;
  assign alu_predec_bignum_o.shifter_b_en           = alu_bignum_shifter_b_en;
  assign alu_predec_bignum_o.shift_right            = alu_bignum_shift_right;
  assign alu_predec_bignum_o.shift_amt              = alu_bignum_shift_amt;
  assign alu_predec_bignum_o.shift_mod_sel          = alu_bignum_shift_mod_sel;
  assign alu_predec_bignum_o.logic_a_en             = alu_bignum_logic_a_en;
  assign alu_predec_bignum_o.logic_shifter_en       = alu_bignum_logic_shifter_en;
  assign alu_predec_bignum_o.logic_res_sel          = alu_bignum_logic_res_sel;
  assign alu_predec_bignum_o.flag_group_sel         = flag_group_sel;
  assign alu_predec_bignum_o.flag_sel               = flag_sel;
  assign alu_predec_bignum_o.flags_keep             = flags_keep;
  assign alu_predec_bignum_o.flags_adder_update     = flags_adder_update;
  assign alu_predec_bignum_o.flags_logic_update     = flags_logic_update;
  assign alu_predec_bignum_o.flags_mac_update       = flags_mac_update;
  assign alu_predec_bignum_o.flags_ispr_wr          = flags_ispr_wr;
  assign alu_predec_bignum_o.vec_elen_onehot        = alu_bignum_vec_elen_onehot;
  assign alu_predec_bignum_o.vec_adder_carry_sel    = alu_bignum_vec_adder_carry_sel;
  assign alu_predec_bignum_o.vec_mod_selector_en    = alu_bignum_vec_mod_selector_en;
  assign alu_predec_bignum_o.vec_mod_is_subtraction = alu_bignum_vec_mod_is_subtraction;
  assign alu_predec_bignum_o.vec_shifter_mask       = alu_bignum_vec_shifter_mask;
  assign alu_predec_bignum_o.vec_transposer_en      = alu_bignum_vec_transposer_en;
  assign alu_predec_bignum_o.vec_transposer_is_trn1 = alu_bignum_vec_transposer_is_trn1;

  assign mac_predec_bignum_o.op_en               = mac_bignum_op_en;
  assign mac_predec_bignum_o.vec_elen_onehot     = mac_bignum_vec_elen_onehot;
  assign mac_predec_bignum_o.vec_adder_carry_sel = mac_bignum_vec_adder_carry_sel;
  assign mac_predec_bignum_o.vec_mul_elen_ctrl   = mac_bignum_vec_mul_elen_ctrl;
  assign mac_predec_bignum_o.is_mod              = mac_bignum_is_mod;
  assign mac_predec_bignum_o.is_vec              = mac_bignum_is_vec;
  assign mac_predec_bignum_o.mul_type            = mac_bignum_mul_type;
  assign mac_predec_bignum_o.mul_shift_en        = mac_bignum_mul_shift_en;
  assign mac_predec_bignum_o.mul_merger_en       = mac_bignum_mul_merger_en;
  assign mac_predec_bignum_o.add_res_en          = mac_bignum_add_res_en;
  assign mac_predec_bignum_o.acc_add_en          = mac_bignum_acc_add_en;

  assign insn_rs1 = imem_rdata_i[19:15];
  assign insn_rs2 = imem_rdata_i[24:20];
  assign insn_rd  = imem_rdata_i[11:7];

  prim_onehot_enc #(
    .OneHotWidth(NWdr)
  ) rf_ren_a_bignum_onehot_enc (
    .in_i  (insn_rs1),
    .en_i  (rf_ren_a_bignum),
    .out_o (rf_predec_bignum_o.rf_ren_a)
  );

  prim_onehot_enc #(
    .OneHotWidth(NWdr)
  ) rf_ren_b_bignum_onehot_enc (
    .in_i  (insn_rs2),
    .en_i  (rf_ren_b_bignum),
    .out_o (rf_predec_bignum_o.rf_ren_b)
  );

  prim_onehot_enc #(
    .OneHotWidth(NWdr)
  ) rf_we_bignum_onehot_enc (
    .in_i  (insn_rd),
    .en_i  (rf_we_bignum),
    .out_o (rf_predec_bignum_o.rf_we)
  );

  prim_onehot_enc #(
    .OneHotWidth(NIspr)
  ) ispr_rd_en_onehot_enc (
    .in_i  (ispr_addr),
    .en_i  (ispr_rd_en),
    .out_o (ispr_predec_bignum_o.ispr_rd_en)
  );

  prim_onehot_enc #(
    .OneHotWidth(NIspr)
  ) ispr_wr_en_onehot_enc (
    .in_i  (ispr_addr),
    .en_i  (ispr_wr_en),
    .out_o (ispr_predec_bignum_o.ispr_wr_en)
  );

  assign ctrl_flow_predec_o.call_stack_pop = (rf_ren_a_base & insn_rs1 == 5'd1) |
                                             (rf_ren_b_base & insn_rs2 == 5'd1);

  assign ctrl_flow_predec_o.call_stack_push = (rf_we_a_base & insn_rs1 == 5'd1) |
                                              (rf_we_b_base & insn_rs2 == 5'd1) |
                                              (rf_we_d_base & insn_rd  == 5'd1);

  assign ctrl_flow_predec_o.branch_insn = branch_insn;
  assign ctrl_flow_predec_o.jump_insn   = jump_insn;
  assign ctrl_flow_predec_o.loop_insn   = loop_insn;
  assign ctrl_flow_predec_o.sel_insn    = sel_insn;

  logic unused_clk, unused_rst;

  assign unused_clk = clk_i;
  assign unused_rst = rst_ni;

  `ASSERT(RFRenABignumOnehot, $onehot0(rf_predec_bignum_o.rf_ren_a))
  `ASSERT(RFRenBBignumOnehot, $onehot0(rf_predec_bignum_o.rf_ren_b))
  `ASSERT(RFWeBignumOnehot,   $onehot0(rf_predec_bignum_o.rf_we))
endmodule
