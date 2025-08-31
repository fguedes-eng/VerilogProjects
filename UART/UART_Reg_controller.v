module UART_Reg_cntrl(
    input clk,
    input rst,
    input In_rdy,
    input FIFO_full,
    input Tx_Busy,
    output reg Send_TX,
    output reg FIFO_send,
    output reg Overflow
);

reg nextFIFO_send;
reg nextSend_TX;
reg nextOverflow;
reg In_rdy_sync1;
reg In_rdy_sync2;
reg In_rdy_prev;
wire In_rdy_edge;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        In_rdy_sync1 <= 0;
        In_rdy_sync2 <= 0;
        In_rdy_prev <= 0;
        Send_TX <= 0;
        FIFO_send <= 0;
        Overflow <= 0;
    end else begin
        FIFO_send <= nextFIFO_send;
        Send_TX <= nextSend_TX;
        In_rdy_sync1 <= In_rdy;
        In_rdy_sync2 <= In_rdy_sync1;
        In_rdy_prev <= In_rdy_sync2;
        Overflow <= nextOverflow;
    end
end

always @(*) begin
    if (!FIFO_full && In_rdy_edge) begin
        nextFIFO_send = 1;
        nextOverflow = 0;
    end
    else if (FIFO_full && In_rdy_edge) begin
        nextFIFO_send = 0;
        nextOverflow = 1;
    end
    else begin 
        nextFIFO_send = 0;
        nextOverflow = 0;
    end
    if (Tx_Busy)
        nextSend_TX = 0;
    else 
        nextSend_TX = 1;
end

assign In_rdy_edge = In_rdy_sync2 & ~In_rdy_prev;

endmodule