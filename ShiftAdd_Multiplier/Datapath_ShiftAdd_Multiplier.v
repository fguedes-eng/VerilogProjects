module DataPath_ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input [WIDTH - 1:0] multiplier,
    input [WIDTH - 1:0] multiplicand,
    input load,
    input shift,
    input add,
    output lsb,
    output reg [WIDTH * 2:0] product
);

    reg [WIDTH * 2:0] nextProduct;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product <= 0;
            nextProduct <= 0;
        end else begin
            product <= nextProduct;
        end
    end

    always @(*) begin
        if (load)
            nextProduct[WIDTH - 1:0] = multiplier;
        else if (shift)
            nextProduct = product >> 1;
        else if (add)
            nextProduct[WIDTH * 2:WIDTH] = {1'b0, product [(WIDTH * 2) - 1:WIDTH]} + {1'b0, multiplicand};
        else 
            nextProduct = product;
    end

    assign lsb = product[0];
endmodule