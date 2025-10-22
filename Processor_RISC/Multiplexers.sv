import Instructions::*;

module Multiplexers (
    //seletores
    input [1:0] WBSel,
    input ALUReg1PCSel,
    input ALUReg2ImmSel,
    input [1:0] PCSel,

    //entradas do WB
    input [31:0] wb_mem,
    input [31:0] wb_alu,
    input [31:0] wb_imm,
    input [31:0] wb_pc,

    //entradas da ALU1
    input [31:0] alu1_reg,
    input [31:0] alu1_pc,

    //entradas da ALU2
    input [31:0] alu2_reg,
    input [31:0] alu2_imm,

    //entradas do PC
    input [31:0] pc_pc,
    input [31:0] pc_alu,
    input [31:0] pc_imm,

    //saídas
    output logic [31:0] wb_out,
    output logic [31:0] alu1_out,
    output logic [31:0] alu2_out,
    output logic [31:0] pc_out
);

logic [31:0] pc_plus4;
logic [31:0] pc_plusImm;
logic [31:0] wb_plus4;

assign pc_plus4 = pc_pc + (1 << 2);
assign wb_plus4 = wb_pc + (1 << 2);
assign pc_plusImm = pc_pc + pc_imm;

always @(*) begin : WB_mux
    case (WBSel)
        WB_DATA_MEM:
            wb_out = wb_mem;
        WB_ALU:
            wb_out = wb_alu;
        WB_IMM:
            wb_out = wb_imm;
        WB_PC:
            wb_out = wb_plus4;
    endcase
end

always @(*) begin : ALU1_mux
    case (ALUReg1PCSel)
        1'b0:
            alu1_out = alu1_reg;
        1'b1:
            alu1_out = alu1_pc;
    endcase
end

always @(*) begin : ALU2_mux
    case (ALUReg2ImmSel)
        1'b0:
            alu2_out = alu2_reg;
        1'b1:
            alu2_out = alu2_imm;
    endcase
end

always @(*) begin : PC_mux
    case (PCSel)
        PC_PLUS4:
            pc_out = pc_plus4;
        PC_ALU:
            pc_out = pc_alu & ~1;
        PC_IMM:
            pc_out = pc_plusImm;
    endcase
end

endmodule
