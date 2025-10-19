module Program_Counter (
	clk,
	rst,
	addr_in,
	addr_out
);
	input clk;
	input rst;
	input [31:0] addr_in;
	output reg [31:0] addr_out;
	always @(posedge clk or posedge rst)
		if (rst)
			addr_out <= 32'h00000000;
		else
			addr_out <= addr_in;
endmodule
