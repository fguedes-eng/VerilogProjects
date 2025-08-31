module UART_Reg_FPGA #(parameter WIDTH = 8) (
    input Out_rdy,
    input clk,
    input [WIDTH - 1:0] Data_Out,
    output reg [WIDTH - 1:0] Data_Out_FPGA
);

reg [WIDTH - 1:0] nextData_Out_FPGA;

    always @(posedge clk) begin
        Data_Out_FPGA <= nextData_Out_FPGA;
    end

    always @(*) begin
        if (Out_rdy) 
            nextData_Out_FPGA = Data_Out;
        else
            nextData_Out_FPGA = Data_Out_FPGA;
    end

endmodule