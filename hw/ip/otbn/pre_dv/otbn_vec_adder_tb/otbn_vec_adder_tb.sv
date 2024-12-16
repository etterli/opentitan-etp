// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// We test the default vectorized adder configured by otbn_pkg.sv and a 128b version at the same
// time. This leads to quite unclean code duplication. TODO: clean up / merge the responses

module otbn_vec_adder_tb
  import otbn_pkg::*;
  ();

  timeunit 1ns;
  timeprecision 1ps;
  localparam time CLK_PERIOD         = 50ns;
  localparam time ACQ_DELAY          = 30ns;
  localparam time APPL_DELAY         = 10ns;
  localparam time EVAL_DELAY         = ACQ_DELAY + 5ns;
  localparam unsigned RST_CLK_CYCLES = 10;

  logic  clk, rst_n;

  clk_rst_gen #(
      .ClkPeriod   (CLK_PERIOD),
      .RstClkCycles(RST_CLK_CYCLES)
  ) i_clk_rst_gen (
      .clk_o (clk),
      .rst_no(rst_n)
  );

  // Signals to the dut
  logic [VLEN-1:0]     operand_a;
  logic [VLEN-1:0]     operand_b;
  logic                operand_b_invert;
  logic [NVecProc-1:0] carries_in;
  logic [NVecProc-1:0] use_ext_carry;

  // We duplicate everything for the 128b test
  localparam int VLEN_128b      = 128;
  localparam int VChunkLEN_128b = VChunkLEN;
  localparam int NVecProc_128b  = VLEN_128b / VChunkLEN;

  logic [VLEN_128b-1:0]     operand_a_128b;
  logic [VLEN_128b-1:0]     operand_b_128b;
  logic                     operand_b_invert_128b;
  logic [NVecProc_128b-1:0] carries_in_128b;
  logic [NVecProc_128b-1:0] use_ext_carry_128b;

  // Signals from the dut
  logic [VLEN-1:0]     sum;
  logic [NVecProc-1:0] carries_out;

  logic [VLEN_128b-1:0]     sum_128b;
  logic [NVecProc_128b-1:0] carries_out_128b;

  ///////////////
  // DUT       //
  ///////////////
  // The tested module must be named "dut" (see run.tcl)
  otbn_vec_adder #(
    .LVLEN(VLEN),
    .LVChunkLEN(VChunkLEN)
    ) dut (
    .operand_a_i       (operand_a),
    .operand_b_i       (operand_b),
    .operand_b_invert_i(operand_b_invert),
    .carries_in_i      (carries_in),
    .use_ext_carry_i   (use_ext_carry),
    .sum_o             (sum),
    .carries_out_o     (carries_out)
  );

  // We also test the 128b version.
  // As it is not named "dut" the waves won't be captured by Questa.
  // Edit runsim.tcl if coverage is required
  otbn_vec_adder #(
    .LVLEN(VLEN_128b),
    .LVChunkLEN(VChunkLEN_128b)
    ) dut_128b (
    .operand_a_i       (operand_a_128b),
    .operand_b_i       (operand_b_128b),
    .operand_b_invert_i(operand_b_invert_128b),
    .carries_in_i      (carries_in_128b),
    .use_ext_carry_i   (use_ext_carry_128b),
    .sum_o             (sum_128b),
    .carries_out_o     (carries_out_128b)
  );

  ///////////////
  // Testbench //
  ///////////////

  // packed result to pass to queue
  typedef struct packed {
    logic [VLEN-1:0]     sum;
    logic [NVecProc-1:0] carries_out;
    logic                valid;
  } response_t;

    typedef struct packed {
    logic [VLEN_128b-1:0]     sum;
    logic [NVecProc_128b-1:0] carries_out;
    logic                     valid;
  } response_128b_t;

  // Response queues to pass results to checker
  response_t      acq_response_queue[$],
                  exp_response_queue[$];
  response_128b_t acq_response_queue_128b[$],
                  exp_response_queue_128b[$];

  integer n_errs, n_checks, all_stim_applied;

  initial begin : application_block
    response_t      gold_response;
    response_128b_t gold_response_128b;

    integer stim_fd;
    integer ret_code;
    integer vlen;
    integer elen_size;
    logic [VLEN-1:0] op_a, op_b, sum;
    logic [NVecProc-1:0] car_in, car_out;
    logic op_b_inv;

    all_stim_applied = 0;
    // Testbench is started from parent directory
    stim_fd = $fopen("./otbn_vec_adder_tb/otbn_vec_adder.golden", "r");
    if (stim_fd == 0) begin
      $fatal(1, "Could not open stimuli file!");
    end

    wait (rst_n);
    while (!$feof(stim_fd)) begin
      @(posedge clk);
      #(APPL_DELAY);
      // Set inputs
      ret_code = $fscanf(stim_fd, "%d, %d, 0x%h, 0x%h, 0x%h, %d, 0x%h, 0x%h\n",
                        vlen, elen_size, op_a, op_b, car_in, op_b_inv, sum, car_out);
      if (ret_code == 0) begin
        $error("Could not parse line of golden vector");
      end

      // assign parsed values
      operand_a             = op_a;
      operand_a_128b        = op_a[VLEN_128b-1:0];
      operand_b             = op_b;
      operand_b_128b        = op_b[VLEN_128b-1:0];
      carries_in            = car_in;
      carries_in_128b       = car_in[NVecProc_128b-1:0];
      operand_b_invert      = op_b_inv;
      operand_b_invert_128b = op_b_inv;

      gold_response.sum              = sum;
      gold_response_128b.sum         = sum[VLEN_128b-1:0];
      gold_response.carries_out      = car_out;
      gold_response_128b.carries_out = car_out[NVecProc_128b-1:0];

      // generate carry MUX control signals
      unique case (elen_size) // TODO: Make dynamic depending on VLEN, NVecProc, VChunkLEN
        16: begin
          use_ext_carry      = {16{1'b1}};
          use_ext_carry_128b = {8{1'b1}};
        end
        32: begin
          use_ext_carry      = {8{2'b01}};
          use_ext_carry_128b = {4{2'b01}};
        end
        64: begin
          use_ext_carry = {4{4'b0001}};
          use_ext_carry_128b = {2{4'b0001}};
        end
        128: begin
          use_ext_carry      = {2{8'b0000_0001}};
          use_ext_carry_128b = 8'b0000_0001;
        end
        256: begin
          use_ext_carry = 16'd1;
          use_ext_carry_128b = 8'd1; // This is invalid
        end
        default: $error("Invalid ELEN in golden vector");
      endcase

      if ((vlen == 128) && (elen_size == 256)) begin
        $error("ELEN 256 is not supported for 128 VLEN");
      end

      // Set valid flag to only one DUT
      gold_response.valid      = 1'b0;
      gold_response_128b.valid = 1'b0;
      unique case (vlen)
        128: gold_response_128b.valid = 1'b1;
        256: gold_response.valid      = 1'b1;
        default: $error("Invalid VLEN in golden vector");
      endcase

      $display("Testing VLEN = %d ", vlen,
               "ELEN = %d ", elen_size,
               "a = 0x%h ", op_a,
               "b = 0x%h ", op_b,
               "cin = 0x%h ", car_in,
               "invert = %d ", op_b_inv,
               "s = 0x%h ", sum,
               "cou = 0x%h", car_out);

      // Publish the expected values
      exp_response_queue.push_back(gold_response);
      exp_response_queue_128b.push_back(gold_response_128b);
    end
    $fclose(stim_fd);
    all_stim_applied = 1; // Signal finish
  end

  initial begin : acquire_block
    response_t      response;
    response_128b_t response_128b;
    wait (rst_n);

    while (1) begin
      @(posedge clk);
      #(ACQ_DELAY);
      // Capture output
      response.sum              = sum;
      response_128b.sum         = sum_128b;
      response.carries_out      = carries_out;
      response_128b.carries_out = carries_out_128b;
      acq_response_queue.push_back(response);
      acq_response_queue_128b.push_back(response_128b);
    end
  end

  initial begin : checker_block
    response_t acq_resp, exp_resp;
    response_128b_t acq_resp_128b, exp_resp_128b;
    n_errs = 0;
    n_checks = 0;

    wait (rst_n);
    while (!all_stim_applied) begin
      @(posedge clk);
      #(EVAL_DELAY);
      if ((acq_response_queue.size() > 0)      && (exp_response_queue.size() > 0) &&
          (acq_response_queue_128b.size() > 0) && (exp_response_queue_128b.size() > 0)) begin
        n_checks += 1;
        acq_resp      = acq_response_queue.pop_front();
        acq_resp_128b = acq_response_queue_128b.pop_front();
        exp_resp      = exp_response_queue.pop_front();
        exp_resp_128b = exp_response_queue_128b.pop_front();

        // copy the valid flag for simpler comparison
        acq_resp.valid      = exp_resp.valid;
        acq_resp_128b.valid = exp_resp_128b.valid;

        if (((acq_resp !== exp_resp) && exp_resp.valid)) begin
            n_errs = n_errs + 1;
            $display("Mismatch occurred at %dns, check %d!\n ", $time, n_checks,
                    "Acquired (sum, carries): %x, %x\n ", acq_resp.sum, acq_resp.carries_out,
                    "Expected (sum, carries): %x, %x\n ", exp_resp.sum, exp_resp.carries_out);
        end
        if (((acq_resp_128b !== exp_resp_128b) && exp_resp_128b.valid)) begin
            n_errs = n_errs + 1;
            $display("Mismatch occurred at %dns, check %d! 128b\n ", $time, n_checks,
              "Acquired (sum, carries): %x, %x\n ", acq_resp_128b.sum, acq_resp_128b.carries_out,
              "Expected (sum, carries): %x, %x\n ", exp_resp_128b.sum, exp_resp_128b.carries_out);
        end
      end
    end
    if (n_errs > 0) begin
      $display("Test ***FAILED*** with ", n_errs, " mismatches out of ", n_checks, " checks.");
    end else begin
      $display("Test ***PASSED*** with ", n_errs, " mismatches out of ", n_checks, " checks.");
    end
    $finish();
  end

endmodule
