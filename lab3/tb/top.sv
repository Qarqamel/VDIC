
module top;
	alu_bfm bfm();
	tester tester_i (bfm);
	coverage coverage_i (bfm);
	scoreboard scoreboard_i(bfm);
	
	vdic_dut_2022 DUT (
		.clk       (bfm.clk),
		.din       (bfm.din),
		.dout      (bfm.dout),
		.dout_valid(bfm.dout_valid),
		.enable_n  (bfm.enable_n),
		.rst_n     (bfm.rst_n)
		);

endmodule
