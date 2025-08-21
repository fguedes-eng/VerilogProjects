`timescale 1ns/1ns

module cnt_random_seq_tb ();

reg clk;
reg reset;
wire [2:0] led;


cnt_random_seq DUT (clk, reset, led);

initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, cnt_random_seq_tb);
    $monitor("at %t: led = %d", $realtime, led);
    reset = 1;
    #1;
    reset = 0;
    #100;
    reset = 1;
    #100;
    reset = 0;
    #100;
    $finish;
end
endmodule