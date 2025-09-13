module DataPath_ShiftAdd_Multiplier (
    input clk,
    input rst,
    input [3:0] multiplier,
    input [3:0] multiplicand,
    input load,
    input shift,
    input add,
    output lsb,
    output reg [8:0] product
);

    always @(posedge clk) begin
        if (load) begin
            product[3:0] <= multiplier;
        end
        if (shift) begin
            product <= product >> 1;
        end
        if (add) begin
            product [8:4] <= {0, product [7:4]} + {0, multiplicand};
        end
    end

    assign lsb = product[0];
endmodule