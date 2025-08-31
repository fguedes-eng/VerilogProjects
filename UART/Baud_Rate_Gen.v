module Baud_Rate (
    input clk,
    input rst,
    input [1:0] baud_sel,
    output reg BaudRate
);

reg [31:0] counter;
reg [31:0] nextCounter;

/* frequência de clk = 50MHz */

parameter BAUD_RATE_9600  = 2'b00;
parameter BAUD_RATE_19200 = 2'b01;
parameter BAUD_RATE_38400 = 2'b10;
parameter BAUD_RATE_57600 = 2'b11;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter = 0;
        BaudRate = 0;
    end 
    else begin
        counter <= nextCounter;
    end
end

always @(*) begin
    case (baud_sel)
        BAUD_RATE_9600: begin
            if (counter == 5208 / 2) begin
                BaudRate = ~BaudRate;
                nextCounter = 0;
            end else begin
                BaudRate = BaudRate;
                nextCounter = counter + 1;
            end
        end

        BAUD_RATE_19200: begin
            if (counter == 2604 / 2) begin
                BaudRate = ~BaudRate;
                nextCounter = 0;
            end else begin
                BaudRate = BaudRate;
                nextCounter = counter + 1;
            end
        end
        
        BAUD_RATE_38400: begin
            if (counter == 1302 / 2) begin
                BaudRate = ~BaudRate;
                nextCounter = 0;
            end else begin
                BaudRate = BaudRate;
                nextCounter = counter + 1;
            end
        end
        
        BAUD_RATE_57600: begin
            if (counter == 868 / 2) begin 
                BaudRate = ~BaudRate;
                nextCounter = 0;
            end else begin
                BaudRate = BaudRate;
                nextCounter = counter + 1;
            end
        end

        default:
            if (counter == 5208) begin
                BaudRate = ~BaudRate;
                nextCounter = 0;
            end else begin
                BaudRate = BaudRate;
                nextCounter = counter + 1;
            end
    endcase
end

endmodule