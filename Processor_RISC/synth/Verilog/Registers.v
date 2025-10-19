module Registers (
	clk,
	rst,
	rs1,
	rs2,
	ws,
	wd,
	we,
	rd1,
	rd2
);
	input clk;
	input rst;
	input [4:0] rs1;
	input [4:0] rs2;
	input [4:0] ws;
	input [31:0] wd;
	input we;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	wire [31:0] rd_wr;
	reg [31:0] reg_cell [0:31];

	always @(posedge clk or posedge rst)
		if (rst) begin : sv2v_autoblock_1
			integer i;
			for (i = 1; i < 32; i = i + 1)
				reg_cell[i] <= 0;
		end
		else if (we && (ws != 0))
			reg_cell[ws] <= wd;
	assign rd1 = (rs1 == 0 ? 32'b00000000000000000000000000000000 : reg_cell[rs1]);
	assign rd2 = (rs2 == 0 ? 32'b00000000000000000000000000000000 : reg_cell[rs2]);
endmodule
