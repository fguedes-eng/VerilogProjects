module Mux2x1  #(parameter WIDTH = 8) (
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    input [3:0] sel,
    output [WIDTH - 1:0] out
);

assign out = ^(sel) ? B : A;

endmodule
