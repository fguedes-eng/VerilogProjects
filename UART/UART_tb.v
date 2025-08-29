`timescale 1ns/1ns

module UART_tb ();

reg [8 - 1:0] ByteIn;
reg [8 - 1:0] ByteOut;
reg clk;
reg StopBit;
reg bit_send;
reg RW;
reg baud_select;
reg baud_clock;
reg parity_sel;
wire Tx;
wire Parity;

parameter BAUD_RATE_9600  = 2'b00;
parameter BAUD_RATE_19200 = 2'b01;
parameter BAUD_RATE_38400 = 2'b10;
parameter BAUD_RATE_57600 = 2'b11;

Baud_Rate DUT(clk, baud_select, baud_clock);
Tx DUT2(ByteIn, baud_clock, Parity, StopBit, bit_send, RW, Tx);
Rx DUT3(Tx, baud_clock, ByteOut);
Parity DUT4(parity_sel, ByteIn, Parity);


initial begin
    clk = 0;
    forever #20 clk = ~clk; //50MHz
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, UART_tb);
    baud_select = BAUD_RATE_9600;
    bit_send = 0;
    RW = 0;
    StopBit = 1;
    ByteIn = 8'b0100_1101;
    #32;
    bit_send = 1;
    #2;
    bit_send = 0;
    #20;
    //ByteIn = 8'b1011_0011;
    //#1;
    //bit_send = 1;
    //#2;
    //bit_send = 0;
    #160;
    $finish;
end

endmodule