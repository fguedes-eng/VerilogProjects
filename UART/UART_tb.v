`timescale 1ns/1ns

module UART_tb ();

reg [8 - 1:0] ByteIn;
reg [8 - 1:0] ByteOut;
reg clk;
reg rst;
reg StopBit;
reg bit_send;
reg RW;
reg [1:0] baud_select;
reg baud_clock;
reg parity_sel;
wire Tx;
wire Parity;

parameter BAUD_RATE_9600  = 2'b00;
parameter BAUD_RATE_19200 = 2'b01;
parameter BAUD_RATE_38400 = 2'b10;
parameter BAUD_RATE_57600 = 2'b11;

parameter BAUD_CYCLE = 104160;
parameter WAIT = 1041600;

parameter PAR = 0;
parameter IMPAR = 1;

Baud_Rate BaudRate_tb(clk, rst, baud_select, baud_clock);
Tx Tx_tb(ByteIn, baud_clock, rst, Parity, StopBit, bit_send, RW, Tx);
Rx Rx_tb(Tx, baud_clock, ByteOut);
Parity Parity_tb(parity_sel, ByteIn, Parity);



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
    bit_send = 0;
    RW = 0;
    StopBit = 1;
    parity_sel = PAR;
    ByteIn = 8'b0100_1101;
    #BAUD_CYCLE;
    bit_send = 1;
    #BAUD_CYCLE;
    bit_send = 0;
    ByteIn = 8'b1011_0011;
    #WAIT;
    bit_send = 1;
    #BAUD_CYCLE;
    bit_send = 0;
    #20000000;
    $finish;
end

endmodule