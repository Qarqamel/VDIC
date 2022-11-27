
module top;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
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
	
	initial begin
	    uvm_config_db #(virtual alu_bfm)::set(null, "*", "bfm", bfm);
	    run_test();
	end
	
endmodule
