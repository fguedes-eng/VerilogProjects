module Counter_ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input ld_count,
    output reg [2:0] count
);
    wire [2:0] nextCount;

    always @(posedge clk or posedge rst) begin
        if (rst) count <= 0;
        else count <= nextCount;
    end

    assign nextCount = (ld_count == 1) ? (count + 1) : count;


endmodule