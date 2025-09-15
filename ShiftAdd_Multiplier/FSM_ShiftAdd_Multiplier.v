module FSM_ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input start,
    input lsb,
    input [2:0] count,
    output reg load,
    output reg shift,
    output reg add,
    output reg done
);

localparam MULT_LENGTH = 4; 

localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;
localparam S3 = 2'b11;

reg [1:0] state;

reg nextLoad;
reg nextShift;
reg nextAdd;
reg [1:0] nextState;
reg nextDone;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            load <= 0;
            shift <= 0;
            add <= 0;
            done <= 0;
            state <= S0;
            nextLoad <= 0;
            nextShift <= 0;
            nextAdd <= 0;
            nextDone <= 0;
            nextState <= S0;
        end else begin
            load <= nextLoad;
            shift <= nextShift;
            add <= nextAdd;
            state <= nextState;
            done <= nextDone;
        end
    end
    
    always @(*) begin
        case (state)
            S0: begin
                if (start) begin
                    nextState = S1;
                    nextLoad = 1;
                end else begin
                    nextState = state;
                    nextLoad = 0;
                end
            end

            S1: begin
                if (count < MULT_LENGTH) begin
                    if (lsb == 1) begin
                        nextAdd = 1;
                    end else begin 
                        nextAdd = 0;
                    end
                    nextState = S2;
                    nextShift = 0;
                end else begin
                    nextState = S3;
                    nextShift = 0;
                    nextAdd = 0;
                end
            end

            S2: begin
                nextShift = 1;
                nextState = S1;
            end

            S3: begin 
                nextDone = 1;
                nextState = S0;
            end

            default:
                nextState = S0;
        endcase
    end

endmodule