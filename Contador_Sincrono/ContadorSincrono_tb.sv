`timescale 1ns/1ns

module cnt_asc_mod7_tb ();

reg clk;
reg reset;
wire [2:0] led;


cnt_asc_mod7 DUT (clk, reset, led);

initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    $monitor("at %t: led = %d", $realtime, led);
    reset = 0;
    #100;
    reset = 1;
    #100;
    reset = 0;
    #100;
    $stop;
end
endmodule