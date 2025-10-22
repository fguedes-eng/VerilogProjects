`timescale 1ns/1ns
module RISC_V_tb ();

logic clk;
logic rst;
logic [31:0] instr_input [0:255];
wire [31:0] x7;
wire [31:0] x8;
wire [31:0] x9;
string str;

RISC_V processor (
    .clk(clk),
    .rst(rst),
    .mem_input(instr_input),
    .x7(x7),
    .x8(x8),
    .x9(x9)
);

initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    $dumpfile("out/dump.vcd");
    $dumpvars(0, RISC_V_tb);
    /* INSTRUÇÕES */

    /* Carrega caracteres "'H', 'e', 'l', 'l'" em x1 */
    instr_input[0] = 32'b01001000_01100101_0111_00001_0110111; //Carrega 20 bits superiores do reg x1  //LUI x1, imm
    instr_input[1] = 32'b1100_01101100_00001_000_00001_0010011; //Carrega 12 bits inferiores do reg x1 //ADDI x1, x1, imm
    /*************************************************/
    /* Carrega caracteres "'o', ' ', 'w', 'o'" em x2 */
    instr_input[2] = 32'b01101111_00100000_0111_00010_0110111; //Carrega 20 bits superiores do reg x2  //LUI x2, imm
    instr_input[3] = 32'b0111_01101111_00010_000_00010_0010011; //Carrega 12 bits inferiores do reg x2 //ADDI x2, x2, imm
    /*************************************************/
    /* Carrega caracteres "'r', 'l', 'd', '!'" em x3 */
    instr_input[4] = 32'b01110010_01101100_0110_00011_0110111; //Carrega 20 bits superiores do reg x3  //LUI x3, imm
    instr_input[5] = 32'b0100_00100001_00011_000_00011_0010011; //Carrega 12 bits inferiores do reg x3 //ADDI x3, x3, imm
    /*************************************************/
    /* Carrega caracteres "'B', 'y', 'e', ','" em x4 */
    instr_input[6] = 32'b01000010_01111001_0110_00100_0110111; //Carrega 20 bits superiores do reg x4  //LUI x4, imm
    instr_input[7] = 32'b0101_00100000_00100_000_00100_0010011; //Carrega 12 bits inferiores do reg x4 //ADDI x4, x4, imm
    /*************************************************/
    /* Carrega "Hello World!" e "Bye " na memória */
    instr_input[8] = 32'b0000000_00001_00000_010_00000_0100011; //Carrega x1 sem offset         //SW x1, 0(x0)
    instr_input[9] = 32'b0000000_00010_00000_010_00100_0100011; //Carrega x2 com offset +4      //SW x2, 4(x0)
    instr_input[10] = 32'b0000000_00011_00000_010_01000_0100011; //Carrega x3 com offset +8     //SW x3, 8(x0)
    instr_input[11] = 32'b0000000_00100_00000_010_01100_0100011; //Carrega x4 com offset +12    //SW x4, 12(x0)
    /*************************************/
    /* Carrega x5 e x6 com valor comparativo */
    instr_input[12] = 32'b000000000010_00000_000_00101_0010011; //ADDI x5, x0, 2
    instr_input[13] = 32'b000000000010_00000_000_00110_0010011; //ADDI x6, x0, 6
    /*****************************************/
    /* Se valores de x5 e x6 forem iguais, pula para instrução do Hello World! */
    instr_input[14] = 32'b0000000_00110_00101_000_10100_1100011; //BEQ x5, x6, 20
    /***************************************************************************/
    /* Se não, instrução do Bye World! */
    instr_input[15] = 32'b000000001100_00000_010_00111_0000011; //LW x7, 12(x0)
    instr_input[16] = 32'b000000000110_00000_010_01000_0000011; //LW x8, 6(x0)
    instr_input[17] = 32'b000000001010_00000_101_01001_0000011; //LHU x9, 10(x0)
    instr_input[18] = 32'b0_0000001000_000000000_00000_1101111; //JAL x0, 16
    /* Instrução Hello World! */
    instr_input[19] = 32'b000000000000_00000_010_00111_0000011; //LW x7, 0(x0)
    instr_input[20] = 32'b000000000100_00000_010_01000_0000011; //LW x8, 4(x0)
    instr_input[21] = 32'b000000001000_00000_010_01001_0000011; //LW x9, 8(x0)
    /**************/ 
    rst = 1'b1;
    #100
    rst = 1'b0;
    #500
    str = {x7, x8, x9, 8'h00};
    $display("string: %s", str);
    $finish;
end

endmodule
