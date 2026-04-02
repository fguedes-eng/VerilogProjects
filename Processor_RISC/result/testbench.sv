// ======================================================
// TESTBENCH TOP  tb_uvm_top.sv
// ======================================================
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "design.sv"
`include "AA_mnemonics_pkg.sv"
`include "ALU.sv"
`include "Control_unit.sv"
`include "Data_memory.sv"
`include "Instruction_decoder.sv"
`include "Instruction_memory.sv"
`include "Multiplexers.sv"
`include "Program_Counter.sv"
`include "Registers.sv"
`include "riscv_if.sv"
`include "riscv_assertions.sv"
`include "riscv_uvm_pkg.sv"

import riscv_uvm_pkg::*;

// ======================================================
// Bind das assertions no escopo global
// (fora de qualquer module  única forma correta)
//
// Adapte os nomes dos sinais internos do RISC_V conforme
// seu design:
//   pc_in  ? nome interno do próximo PC antes do registrador
//   wb_in  ? dado a ser escrito no regfile
//   PCSel  ? seletor de próximo PC (2 bits)
// ======================================================
bind RISC_V riscv_assertions u_assertions (
    .clk     (clk),
    .rst     (rst),
    .pc      (out_pc),        // sinal de saída do registrador de PC
    .pc_in   (pc_in),         // entrada do registrador de PC (pc_next)
    .regWrite(regWrite),
    .rd      (rd),
    .wb_in   (wb_in),         // dado entrando no regfile
    .PCSel   (PCSel)
);

// ======================================================
module tb_uvm_top;

    // --------------------------------------------------
    // Interface e clock
    // --------------------------------------------------
    riscv_if vif ();

    initial begin
        vif.clk = 1'b0;
        forever #5 vif.clk = ~vif.clk; // clock de 100 MHz
    end

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    RISC_V dut (
        .clk          (vif.clk),
        .rst          (vif.rst),
        .mem_input    (vif.mem_input),
        .out_pc       (vif.pc),
        .out_instruction (vif.instruction),
        .out_regWrite (vif.regWrite),
        .out_rd       (vif.rd),
        .out_wb_data  (vif.wb_data),
        .out_memWrite (vif.memWrite),
        .out_ALUout   (vif.ALUout)
    );

    // --------------------------------------------------
    // Config DB e disparo do teste
    // --------------------------------------------------
    initial begin
        // Disponibiliza a interface para todos os componentes UVM
        uvm_config_db #(virtual riscv_if)::set(null, "*", "vif", vif);

        // Habilita time-out global (evita simulação travada)
        uvm_top.set_timeout(500us, 1);

        run_test("riscv_test");
    end

    // --------------------------------------------------
    // Dump de formas de onda (opcional  comente se não
    // precisar)
    // --------------------------------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uvm_top);
    end

endmodule
