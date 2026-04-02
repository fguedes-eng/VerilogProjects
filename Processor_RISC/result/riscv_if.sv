// ======================================================
// INTERFACE — riscv_if.sv
// ======================================================
interface riscv_if;

    logic        clk;
    logic        rst;

    // Memória de instruções (alimentada pelo driver)
    logic [31:0] mem_input [0:255];

    // Observabilidade arquitetural do DUT
    logic [31:0] pc;
    logic [31:0] instruction;
    logic        regWrite;
    logic [4:0]  rd;
    logic [31:0] wb_data;

    // Observabilidade adicional
    logic        memWrite;
    logic [31:0] ALUout;

endinterface