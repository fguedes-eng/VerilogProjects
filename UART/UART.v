module UART #(parameter WIDTH = 8)
(
	
//-------------------------------------------
//Entradas:
//-------------------------------------------

    input [WIDTH - 1:0] Data_In,
    input clk,
    input rst,
    input In_rdy,
    input [1:0] baud_select,
    input parity_sel,
	input Rx,

//-------------------------------------------
//Saídas:
//-------------------------------------------

    output [WIDTH - 1:0] Data_Out,
    //output Send_TX,
    output Overflow,
    output Tx,
    output Parity,
    output ParityError,
    output StopBitError,
    output Out_rdy,
    output [WIDTH - 1:0] Data_Out_FPGA

);

//-------------------------------------------
//Flags internas:
//-------------------------------------------

    wire BaudRate;
    wire Send_TX;
    wire FIFO_send;
    wire FIFO_full;
    wire Tx_Busy;
    wire selected_parity;

//-------------------------------------------
//Instâncias:
//-------------------------------------------
    UART_Reg_FPGA Reg_FPGA (
    .Out_rdy                (Out_rdy),
    .clk                    (BaudRate),
    .Data_Out               (Data_Out),
    .Data_Out_FPGA          (Data_Out_FPGA)    
);


    Baud_Rate Baud_Rate(
        //Entradas ao dut:
        .clk		        (clk), 
        .baud_sel	        (baud_select),
        .rst                (rst),

        //Saídas ao dut:
        .BaudRate	        (BaudRate)
        );
        
    UART_Tx uTx(
        //Entradas ao dut:
		.clk			    (BaudRate),
        .Data_In            (Data_In),
        .rst                (rst),
        .Parity		        (Parity),
        .Send_TX            (Send_TX),
        .FIFO_send          (FIFO_send),

        //Saídas ao dut:
        .Tx		            (Tx),
        .Tx_Busy            (Tx_Busy),
        .FIFO_full          (FIFO_full)
        );

    UART_Rx uRx(
        //Entradas ao dut:
        .Rx		         (Rx), 
		.clk			 (BaudRate),
        .rst             (rst),
        .selected_parity (selected_parity),

        //Saídas ao dut:
        .Data_Out	        (Data_Out),
        .ParityError        (ParityError),
        .StopBitError       (StopBitError),
        .Out_rdy            (Out_rdy)
        );

    UART_Parity uParity(
        //Entradas ao dut:
        .parity_sel	        (parity_sel), 
        .Data_In            (Data_In),

       //Saídas ao dut:
        .Parity		        (Parity),
        .selected_parity    (selected_parity)
        );
        
    UART_Reg_cntrl Reg_cntrl(
        //Entradas ao dut:
    	.clk			    (BaudRate),
        .rst                (rst),
        .In_rdy             (In_rdy),
        .FIFO_full          (FIFO_full),
        .Tx_Busy            (Tx_Busy),

       //Saídas ao dut:
        .Send_TX            (Send_TX),
        .FIFO_send          (FIFO_send),
        .Overflow           (Overflow)
    );

endmodule
