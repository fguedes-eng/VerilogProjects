module cnt_asc_mod7_tb ();

reg clk;

`timescale 1ns/1ps;

initial begin
    clk = 0;
    forever begin
        #5;
        clk = ~clk;
    end
end

initial begin

end
