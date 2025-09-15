`timescale 1ns/1ns

module ShiftAdd_Multiplier_tb ();

    reg clk;
    reg rst;
    reg [3:0] multiplier;
    reg [3:0] multiplicand;
    reg start;
    wire [8:0] product;
    wire done;

    ShiftAdd_Multiplier Multiplier(.clk(clk), .rst(rst), .multiplier(multiplier), .multiplicand(multiplicand), .start(start), .product(product), .done(done));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, ShiftAdd_Multiplier_tb);
        $monitor("at %t: done = %b, product = %b, start = %b, rst = %b", $realtime, done, product, start, rst);
        multiplier = 4'b1111;
        multiplicand = 4'b1111;
        start = 0;
        rst = 1;
        #5;
        rst = 0;
        #5;
        start = 1;
        #5;
        start = 0;
        $display("start: %b", start);
        //while (!done) begin

        //end
        #10000;
        $display("result of %b x %b = %b (%d x %d = %d)", multiplier, multiplicand, product, multiplier, multiplicand, product);
        $finish;
    end

endmodule