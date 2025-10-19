module RISC_V (
    input clk,
    input rst,
    input [31:0] mem_input [0:255],
    /* Output debug */
    output wire [31:0] x7,
    output wire [31:0] x8,
    output wire [31:0] x9
);

logic [31:0] instruction;
logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [2:0] funct3;
logic [6:0] funct7;
logic [31:0] imm;
logic [31:0] pc;
logic [31:0] alu_in1;
logic [31:0] alu_in2;

logic regWrite;
logic [3:0] ALUop;
logic memWrite;
logic [1:0] WBSel;
logic ALUReg1PCSel;
logic ALUReg2ImmSel;
logic [1:0] PCSel;
logic [2:0] memRWSize;
logic [31:0] rd1;
logic [31:0] rd2;
logic [31:0] ALUout;
logic [31:0] wb_in;
logic [31:0] pc_in;
logic [31:0] out_data_mem;

ALU alu (
    /* INPUTS */
    .in1(alu_in1), //Entrada 1 da ALU
    .in2(alu_in2), //Entrada 2 da ALU
    .opcode(ALUop), //Operação a ser executada
    /* OUTPUTS */
    .out(ALUout)
);

Control_unit control_unit (
    /* INPUTS */
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm),
    .ALUcomp(ALUout[0]),
    /* OUTPUTS */
    .regWrite(regWrite),
    .ALUop(ALUop),
    .memWrite(memWrite),
    .WBSel(WBSel),
    .ALUReg1PCSel(ALUReg1PCSel),
    .ALUReg2ImmSel(ALUReg2ImmSel),
    .PCSel(PCSel),
    .memRWSize(memRWSize)
);

Data_memory data_memory (
    /* INPUTS */
    .clk(clk),
    .rst(rst),
    .mem_addr(ALUout[11:0]),
    .wr_data(rd2),
    .we(memWrite),
    .read_size(memRWSize),
    /* OUTPUTS */
    .rd_data(out_data_mem)
);

Instruction_decoder instruction_decoder (
    /* INPUTS */
    .instruction(instruction),
    /* OUTPUTS */
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm(imm)
);

Instruction_memory instruction_memory (
    /* INPUTS */
    .addr(pc[9:0]),
    .mem_input(mem_input),
    /* OUTPUTS */
    .rd(instruction)
);

Multiplexers multiplexers (
    /* INPUTS */
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
    /* OUTPUTS */
    .wb_out(wb_in),
    .alu1_out(alu_in1),
    .alu2_out(alu_in2),
    .pc_out(pc_in)
);

Program_Counter program_counter (
    /* INPUTS */
    .clk(clk),
    .rst(rst),
    .addr_in(pc_in),
    /* OUTPUTS */
    .addr_out(pc)
);

Registers registers (
    /* INPUTS */
    .clk(clk),
    .rst(rst),
    .rs1(rs1),
    .rs2(rs2),
    .ws(rd),        //registrador de destino vindo da instrução
    .wd(wb_in),
    .we(regWrite),
    .wb_ctrl(WBSel),
    /* OUTPUTS */
    .rd1(rd1),      //read data 1
    .rd2(rd2),      //read data 2
    /* Output Debug */
    .x7(x7),
    .x8(x8),
    .x9(x9)
);

endmodule
