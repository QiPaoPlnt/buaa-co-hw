`timescale 1ns / 1ps

`include "defines.v"

module mips_tb #(
	parameter FORMAT_BUILD = 0
);

	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;

		if(FORMAT_BUILD) begin
			$display("%0d", `_BUILD_ID);
		end

		#5
		reset = 1;
		
		#100
		reset = 0;
        
		// Add stimulus here

	end
	
	always #5 clk = ~clk;
      
endmodule

