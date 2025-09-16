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

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product <= 0;
        end else begin
            if (load)
                product[WIDTH - 1:0] <= multiplier;
            else if (shift)
                product <= product >> 1;
            else if (add)
                product[WIDTH * 2:WIDTH] = {1'b0, product [(WIDTH * 2) - 1:WIDTH]} + {1'b0, multiplicand};
            else 
                product <= product;
        end
    end

    assign lsb = product[0];
endmodule