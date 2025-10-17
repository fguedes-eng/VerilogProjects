`timescale 1ns/1ns
module RISC_V_tb ();

logic clk;
logic rst;
logic [31:0] instr_input [0:255];

RISC_V processor (
    .clk(clk),
    .rst(rst),
    .mem_input(instr_input)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, RISC_V_tb);
        // 0: ADDI x2, x0, 10       → x2 = 10
    mem_input[0] = 32'b000000001010_00000_000_00010_0010011;

    // 1: ADDI x3, x0, 20       → x3 = 20
    mem_input[1] = 32'b000000010100_00000_000_00011_0010011;

    // 2: ADD  x4, x2, x3       → x4 = x2 + x3
    mem_input[2] = 32'b0000000_00011_00010_000_00100_0110011;

    // 3: SUB  x5, x3, x2       → x5 = x3 - x2
    mem_input[3] = 32'b0100000_00010_00011_000_00101_0110011;

    // 4: AND  x6, x2, x3
    mem_input[4] = 32'b0000000_00011_00010_111_00110_0110011;

    // 5: OR   x7, x2, x3
    mem_input[5] = 32'b0000000_00011_00010_110_00111_0110011;

    // 6: XOR  x8, x2, x3
    mem_input[6] = 32'b0000000_00011_00010_100_01000_0110011;

    // 7: SLL  x9, x2, x3        → x9 = x2 << (x3 & 0x1F)
    mem_input[7] = 32'b0000000_00011_00010_001_01001_0110011;

    // 8: SRL  x10, x3, x2       → lógico
    mem_input[8] = 32'b0000000_00010_00011_101_01010_0110011;

    // 9: SRA  x11, x3, x2       → aritmético
    mem_input[9] = 32'b0100000_00010_00011_101_01011_0110011;

    // 10: SLT x12, x2, x3       → x12 = (x2 < x3) signed
    mem_input[10] = 32'b0000000_00011_00010_010_01100_0110011;

    // 11: BEQ x2, x3, +8        → salta 2 instruções se x2 == x3
    mem_input[11] = 32'b0000000_00011_00010_000_00100_1100011;

    // 12: JAL x1, +8            → x1 = PC+4, PC = PC+8
    mem_input[12] = 32'b000000000100_00000000_00001_1101111;

    // 13: LUI x13, 0x12345      → x13 = 0x12345000
    mem_input[13] = 32'b00010010001101000101_01101_0110111;

    // 14: AUIPC x14, 0x10       → x14 = PC + 0x10000
    mem_input[14] = 32'b00000000000100000000_01110_0010111;

    // 15: JALR x0, x1, 0        → PC = x1 + 0
    mem_input[15] = 32'b000000000000_00001_000_00010_1100111;

    // 16: SW x4, 0(x0)          → mem[0] = x4
    mem_input[16] = 32'b0000000_00100_00000_010_00000_0100011;

    // 17: LW x15, 0(x0)         → x15 = mem[0]
    mem_input[17] = 32'b000000000000_00000_010_01111_0000011;

    // 18: HALT (NOP)
    mem_input[18] = 32'b000000000000_00000_000_00000_0010011;
    rst = 1'b1;
    #100
    rst = 1'b0;
    #10000
    $finish;
end

endmodule
