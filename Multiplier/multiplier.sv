module multiplier_csa #(parameter WIDTH = 4) (
    input [WIDTH - 1:0] multiplicand,
    input [WIDTH - 1:0] multiplier,
    output [2 * WIDTH - 1:0] result
);

wire [2 * WIDTH - 1:0] partial_product [3:0];
wire [2 * WIDTH - 1:0] partial_sum [1:0];
wire [2 * WIDTH - 1:0] partial_cout [1:0];

genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : PARTIAL
assign partial_product[i] = multiplier[i] ? (multiplicand << i) : 0;
        end
    endgenerate

parameterized_csa #(2 * WIDTH) nivel1(.A(partial_product[0]), .B(partial_product[1]), .Cin(partial_product[2]), .Sum(partial_sum[0]), .Cout(partial_cout[0]));
parameterized_csa #(2 * WIDTH) nivel2(.A(partial_product[3]), .B(partial_sum[0]), .Cin(partial_cout[0]), .Sum(partial_sum[1]), .Cout(partial_cout[1]));
assign result = partial_sum[1] + (partial_cout[1] << 1);


endmodule