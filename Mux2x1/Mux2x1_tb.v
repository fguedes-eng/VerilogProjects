module Mux2x1_tb #(parameter WIDTH = 8) ();

reg [WIDTH - 1:0] A;
reg [WIDTH - 1:0] B;
reg [3:0] sel;
wire [WIDTH - 1:0] out;

Mux2x1 #(WIDTH) DUT (.A(A), .B(B), .sel(sel), .out(out));

initial begin
    A = 8'b0001_1010;
    B = 8'b1001_1100;
    sel = 4'b1011; //Ímpar seleciona B
    #10;
    $display("sel = %b, out = %b", sel, out);
    sel = 4'b1100; //Par seleciona A
    #10;
    $display("sel = %b, out = %b", sel, out);
    $finish;
end

endmodule
