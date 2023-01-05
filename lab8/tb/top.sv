
module top;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import alu_pkg::*;
	
	alu_bfm class_bfm();
	
	vdic_dut_2022 class_DUT (
		.clk       (class_bfm.clk),
		.din       (class_bfm.din),
		.dout      (class_bfm.dout),
		.dout_valid(class_bfm.dout_valid),
		.enable_n  (class_bfm.enable_n),
		.rst_n     (class_bfm.rst_n)
		);
	
	alu_bfm module_bfm();
	
	vdic_dut_2022 module_DUT (
		.clk       (module_bfm.clk),
		.din       (module_bfm.din),
		.dout      (module_bfm.dout),
		.dout_valid(module_bfm.dout_valid),
		.enable_n  (module_bfm.enable_n),
		.rst_n     (module_bfm.rst_n)
		);
	
	alu_tester_module stim_module(module_bfm);
	
	initial begin
	    uvm_config_db #(virtual alu_bfm)::set(null, "*", "class_bfm", class_bfm);
    	uvm_config_db #(virtual alu_bfm)::set(null, "*", "module_bfm", module_bfm);
	    run_test("dual_test");
	end
	
endmodule : top
