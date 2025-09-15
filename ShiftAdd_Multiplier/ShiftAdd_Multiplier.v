module ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input [3:0] multiplier,
    input [3:0] multiplicand,
    input start,
    output [8:0] product,
    output done
);

reg shift;
reg [2:0] count;
reg load;
reg add;
reg lsb;

Counter_ShiftAdd_Multiplier Counter(.clk(clk), .rst(rst), .ld_count(shift), .count(count)); 
DataPath_ShiftAdd_Multiplier Datapath(.clk(clk), .rst(rst), .multiplier(multiplier), .multiplicand(multiplicand), .load(load), .shift(shift), .add(add), .lsb(lsb), .product(product));
FSM_ShiftAdd_Multiplier Controller(.clk(clk), .rst(rst), .start(start), .lsb(lsb), .count(count), .load(load), .shift(shift), .add(add), .done(done));
    

endmodule