module ALU (
	in1,
	in2,
	opcode,
	out
);
	input [31:0] in1;
	input [31:0] in2;
	input [3:0] opcode;
	output reg [31:0] out;
	wire [31:0] u_in1;
	wire [31:0] u_in2;
	assign u_in1 = in1;
	assign u_in2 = in2;
	localparam ALUInstr_ADD = 4'b0000;
	localparam ALUInstr_AND = 4'b0110;
	localparam ALUInstr_EQ = 4'b1011;
	localparam ALUInstr_OR = 4'b0101;
	localparam ALUInstr_SGTE = 4'b1100;
	localparam ALUInstr_SLL = 4'b0010;
	localparam ALUInstr_SLT = 4'b1000;
	localparam ALUInstr_SRA = 4'b0100;
	localparam ALUInstr_SRL = 4'b0011;
	localparam ALUInstr_SUB = 4'b0001;
	localparam ALUInstr_UGTE = 4'b1010;
	localparam ALUInstr_ULT = 4'b1001;
	localparam ALUInstr_XOR = 4'b0111;
	always @(*)
		case (opcode)
			ALUInstr_ADD: out = in1 + in2;
			ALUInstr_SUB: out = in1 - in2;
			ALUInstr_SLL: out = in1 << in2[4:0];
			ALUInstr_SRL: out = in1 >> in2[4:0];
			ALUInstr_SRA: out = in1 >>> in2[4:0];
			ALUInstr_OR: out = in1 | in2;
			ALUInstr_AND: out = in1 & in2;
			ALUInstr_XOR: out = in1 ^ in2;
			ALUInstr_SLT: out = (in1 < in2 ? 32'd1 : 32'd0);
			ALUInstr_ULT: out = (u_in1 < u_in2 ? 32'd1 : 32'd0);
			ALUInstr_UGTE: out = (u_in1 >= u_in2 ? 32'd1 : 32'd0);
			ALUInstr_EQ: out = (in1 == in2 ? 32'd1 : 32'd0);
			ALUInstr_SGTE: out = (in1 >= in2 ? 32'd1 : 32'd0);
			default: out = 32'd0;
		endcase
endmodule
