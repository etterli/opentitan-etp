// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module otbn_vec_multiplier_tb
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
  logic [63:0]      operand_a, operand_b;
  elen_bignum_e     elen;
  logic [NELEN-1:0] elen_onehot;

  // Signals from the dut
  logic [127:0] result;

  ///////////////
  // DUT       //
  ///////////////
  // The tested module must be named "dut" (see run.tcl)
  otbn_vec_multiplier dut (
    .clk_i        (clk),
    .rst_ni       (rst_n),
    .operand_a_i  (operand_a),
    .operand_b_i  (operand_b),
    .elen_onehot_i(elen_onehot),
    .result_o     (result)
  );

  ///////////////
  // Testbench //
  ///////////////

  // packed result to pass to queue
  typedef struct packed {
    logic [127:0] result;
  } response_t;

  // Response queues to pass results to checker
  response_t acq_response_queue[$],
             exp_response_queue[$];

  integer n_errs, n_checks, all_stim_applied;

  prim_onehot_enc #(
    .OneHotWidth (NELEN)
  ) u_elen_onehot (
    .in_i (elen),
    .en_i ('1), // always enable
    .out_o(elen_onehot)
  );

  initial begin : application_block
    response_t gold_response;
    integer stim_fd;
    integer ret_code;
    integer elen_size;

    // assign default value
    elen = VecElen16;

    all_stim_applied = 0;
    // Testbench is started from parent directory
    stim_fd = $fopen("./otbn_vec_multiplier_tb/otbn_vec_multiplier.golden", "r");
    if (stim_fd == 0) begin
      $fatal(1, "Could not open stimuli file!");
    end

    wait (rst_n);
    while (!$feof(stim_fd)) begin
      @(posedge clk);
      #(APPL_DELAY);
      // Set inputs
      ret_code = $fscanf(stim_fd, "%d, 0x%h, 0x%h, 0x%h\n",
                         elen_size, operand_a, operand_b, gold_response.result);
      if (ret_code == 0) begin
        $error("Could not parse line of golden vector. Error %d", ret_code);
        $fatal("Abort due to corrupted golden vector.");
      end

      unique case (elen_size)
        16: elen = VecElen16;
        32: elen = VecElen32;
        64: elen = VecElen64;
        128: $error("ELEN 128b is not supported");
        256: $error("ELEN 256b is not supported");
        default: $error("Invalid ELEN in golden vector");
      endcase

      $display("Elen %d, ", elen_size,
               "operand a 0x%h, ", operand_a,
               "operand b 0x%h, ", operand_b,
               "res 0x%h", gold_response.result);

      // Publish the expected values
      exp_response_queue.push_back(gold_response);
    end
    $fclose(stim_fd);
    all_stim_applied = 1; // Signal finish
  end

  initial begin : acquire_block
    response_t response;
    wait (rst_n);

    while (1) begin
      @(posedge clk);
      #(ACQ_DELAY);
      // Capture output
      response.result = result;
      acq_response_queue.push_back(response);
    end
  end

  initial begin : checker_block
    response_t acq_resp, exp_resp;
    n_errs = 0;
    n_checks = 0;

    wait (rst_n);
    while (!all_stim_applied) begin
      @(posedge clk);
      #(EVAL_DELAY);
      if (acq_response_queue.size() > 0 && exp_response_queue.size() > 0) begin
        n_checks += 1;
        acq_resp = acq_response_queue.pop_front();
        exp_resp = exp_response_queue.pop_front();
        if (acq_resp !== exp_resp) begin
            n_errs = n_errs + 1;
            $display("Mismatch occurred at %dns, check %d!\n ", $time, n_checks,
                    "Acquired (result): %x\n ", acq_resp.result,
                    "Expected (result): %x\n ", exp_resp.result);
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
