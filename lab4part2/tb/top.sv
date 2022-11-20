
module top;
	
	import alu_pkg::*;
	
	alu_bfm bfm();
	
	vdic_dut_2022 DUT (
		.clk       (bfm.clk),
		.din       (bfm.din),
		.dout      (bfm.dout),
		.dout_valid(bfm.dout_valid),
		.enable_n  (bfm.enable_n),
		.rst_n     (bfm.rst_n)
		);
	
	testbench testbench_h;
	
	initial begin
	    testbench_h = new(bfm);
	    testbench_h.execute();
	end
	
endmodule
