module Baud_Rate (
    input clk,
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

always @(posedge clk) begin
    counter <= nextCounter;
end

always @(*) begin
    case (baud_sel)
        BAUD_RATE_9600: begin
            if (counter == 5208) begin
                BaudRate = 1;
                nextCounter = 0;
            end else begin
                BaudRate = 0;
                nextCounter = counter + 1;
            end
        end

        BAUD_RATE_19200: begin
            if (counter == 2604) begin
                BaudRate = 1;
                nextCounter = 0;
            end else begin
                BaudRate = 0;
                nextCounter = counter + 1;
            end
        end
        
        BAUD_RATE_38400: begin
            if (counter == 1302) begin
                BaudRate = 1;
                nextCounter = 0;
            end else begin
                BaudRate = 0;
                nextCounter = counter + 1;
            end
        end
        
        BAUD_RATE_57600: begin
            if (counter == 868) begin
                BaudRate = 1;
                nextCounter = 0;
            end else begin
                BaudRate = 0;
                nextCounter = counter + 1;
            end
        end

        default:
            if (counter == 5208) begin
                BaudRate = 1;
                nextCounter = 0;
            end else begin
                BaudRate = 0;
                nextCounter = counter + 1;
            end
    endcase
end

endmodule