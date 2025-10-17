module Program_Counter (
    input clk,
    input rst,
    input [31:0] addr_in,
    output logic [31:0] addr_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr_out <= 32'h00;
    end else begin
        addr_out <= addr_in;
    end
end

endmodule
