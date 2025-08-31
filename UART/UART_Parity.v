module UART_Parity #(parameter WIDTH = 8)
(
    input parity_sel,
    input [WIDTH - 1:0] Data_In,
    output Parity,
    output selected_parity
);

parameter PAR = 0;
parameter IMPAR = 1;

assign Parity = (parity_sel == PAR ? ^(Data_In) : ~(^(Data_In)));
assign selected_parity = parity_sel;

endmodule
