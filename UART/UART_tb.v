`timescale 1ns/1ns

module UART_tb ();

reg [8 - 1:0] DataIn;
reg [8 - 1:0] DataOut;
reg clk;
reg rst;
reg StopBit;
reg In_rdy;
reg RW;
reg [1:0] baud_select;
reg baud_clock;
reg parity_sel;
wire selected_parity;
wire FIFO_full;
wire Tx_busy;
wire Send_TX;
wire FIFO_send;
wire Overflow;
wire Tx;
wire Parity;
wire ParityError;
wire StopBitError;
wire Out_rdy;

parameter BAUD_RATE_9600  = 2'b00;
parameter BAUD_RATE_19200 = 2'b01;
parameter BAUD_RATE_38400 = 2'b10;
parameter BAUD_RATE_57600 = 2'b11;

parameter BAUD_CYCLE = 104160;
parameter WAIT = 1041600;

parameter PAR = 0;
parameter IMPAR = 1;

Baud_Rate BaudRate_tb(clk, rst, baud_select, baud_clock);
/*
input [8 - 1:0] Data_In, //dado no barramento
    input clk, //clock
    input rst,
    input Parity, //bit de paridade
    input StopBit, //bit de Stop
    input Send_TX, //ativo manda a entrada para os registradores de buffer
    input FIFO_send,
    output reg Tx, //bit único sendo enviado Tx
    output reg Tx_busy,
    output reg FIFO_full
    */
Tx Tx_tb(DataIn, baud_clock, rst, Parity, StopBit, Send_TX, FIFO_send, Tx, TX_busy, FIFO_full);

/*
input Rx,                  // entrada Rx de um bit serial
    input clk,                 // clk
    input rst,                 // reset assíncrono
    input selected_parity,
    output reg [7:0] DataOut,  // saída no barramento
    output reg ParityError,
    output reg StopBitError,
    output reg Out_rdy          // indica que DataOut está válido
    */
Rx Rx_tb(Tx, baud_clock, rst, selected_parity, DataOut, ParityError, StopBitError, Out_rdy);
/* input parity_sel,
    input [8 - 1:0] dataIn,
    output parity,
    output selected_parity
    */
Parity Parity_tb(parity_sel, DataIn, Parity, selected_parity);

/*
input clk,
    input rst,
    input In_rdy,
    input FIFO_full,
    input TX_busy,
    output reg Send_TX,
    output reg FIFO_send,
    output reg Overflow
    */
Reg_cntrl Reg_ctrl_tb(baud_clock, rst, In_rdy, FIFO_full, TX_busy, Send_TX, FIFO_send, Overflow);



initial begin
    clk = 0;
    forever #20 clk = ~clk; //50MHz
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, UART_tb);
    baud_select = BAUD_RATE_9600;
    rst = 1;
    #1;
    rst = 0;
    In_rdy = 0;
    RW = 0;
    StopBit = 1;
    parity_sel = PAR;
    DataIn = 8'b0100_1101;
    #BAUD_CYCLE;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;
    DataIn = 8'b1011_0011;
    #WAIT;
    In_rdy = 1;
    #BAUD_CYCLE;
    In_rdy = 0;
    #20000000;
    $finish;
end

endmodule