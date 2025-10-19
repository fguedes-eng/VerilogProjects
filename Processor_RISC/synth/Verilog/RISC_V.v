module RISC_V (
	clk,
	rst,
	mem_input,
    instructionMem_o,
    registers_rd1_o,
    registers_rd2_o,
    alu_o,
    dataMem_o
);


    // === Saídas de debug dos módulos principais ===
    output [31:0] instructionMem_o;
    output [31:0] registers_rd1_o;
    output [31:0] registers_rd2_o;
    output [31:0] alu_o;
    output [31:0] dataMem_o;

	input clk;
	input rst;
	input [8191:0] mem_input;
	wire [31:0] instruction;
	wire [6:0] opcode;
	wire [4:0] rd;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [2:0] funct3;
	wire [6:0] funct7;
	wire [31:0] imm;
	wire [31:0] pc;
	wire [31:0] alu_in1;
	wire [31:0] alu_in2;
	wire regWrite;
	wire [3:0] ALUop;
	wire memWrite;
	wire [1:0] WBSel;
	wire ALUReg1PCSel;
	wire ALUReg2ImmSel;
	wire [1:0] PCSel;
	wire [2:0] memRWSize;
	wire [31:0] rd1;
	wire [31:0] rd2;
	wire [31:0] ALUout;
	wire [31:0] wb_in;
	wire [31:0] pc_in;
	wire [31:0] out_data_mem;
	ALU alu(
		.in1(alu_in1),
		.in2(alu_in2),
		.opcode(ALUop),
		.out(ALUout)
	);
	Control_unit control_unit(
		.opcode(opcode),
		.funct3(funct3),
		.funct7(funct7),
		.imm(imm),
		.regWrite(regWrite),
		.ALUop(ALUop),
		.memWrite(memWrite),
		.WBSel(WBSel),
		.ALUReg1PCSel(ALUReg1PCSel),
		.ALUReg2ImmSel(ALUReg2ImmSel),
		.PCSel(PCSel),
		.memRWSize(memRWSize)
	);
	Data_memory data_memory(
		.clk(clk),
		.rst(rst),
		.mem_addr(ALUout[11:0]),
		.wr_data(rd2),
		.we(memWrite),
		.read_size(memRWSize),
		.rd_data(out_data_mem)
	);
	Instruction_decoder instruction_decoder(
		.instruction(instruction),
		.opcode(opcode),
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.funct3(funct3),
		.funct7(funct7),
		.imm(imm)
	);
	Instruction_memory instruction_memory(
		.addr(pc[9:0]),
		.mem_input(mem_input),
		.rd(instruction)
	);
	Multiplexers multiplexers(
		.WBSel(WBSel),
		.ALUReg1PCSel(ALUReg1PCSel),
		.ALUReg2ImmSel(ALUReg2ImmSel),
		.PCSel(PCSel),
		.wb_mem(out_data_mem),
		.wb_alu(ALUout),
		.wb_imm(imm),
		.wb_pc(pc),
		.alu1_reg(rd1),
		.alu1_pc(pc),
		.alu2_reg(rd2),
		.alu2_imm(imm),
		.pc_pc(pc),
		.pc_alu(ALUout),
		.pc_imm(imm),
		.wb_out(wb_in),
		.alu1_out(alu_in1),
		.alu2_out(alu_in2),
		.pc_out(pc_in)
	);
	Program_Counter program_counter(
		.clk(clk),
		.rst(rst),
		.addr_in(pc_in),
		.addr_out(pc)
	);
	Registers registers(
		.clk(clk),
		.rst(rst),
		.rs1(rs1),
		.rs2(rs2),
		.ws(rd),
		.wd(wb_in),
		.we(regWrite),
		.rd1(rd1),
		.rd2(rd2)
	);

	// === Conexões das saídas de debug ===
    assign instructionMem_o   = instruction;
    assign registers_rd1_o    = rd1;
    assign registers_rd2_o    = rd2;
    assign alu_o              = ALUout;
    assign dataMem_o          = out_data_mem;
endmodule
