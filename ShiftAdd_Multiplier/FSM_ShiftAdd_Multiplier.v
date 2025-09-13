module FSM_ShiftAdd_Multiplier (
    input clk,
    input rst,
    input start,
    input lsb,
    input [2:0] count,
    output load,
    output reg shift,
    output reg add,
    output reg done
);

localparam MULT_LENGTH = 4; 

localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;

reg [1:0] state;

reg nextLoad;
reg nextShift;
reg nextAdd;
reg [1:0] nextState;
reg nextDone;

    always @(posedge clk) begin
        load <= nextLoad;
        shift <= nextShift;
        add <= nextAdd;
        state <= nextState;
        done <= nextDone;
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
                    nextShift = 1;
                    nextState = S1;
                end else begin
                    nextAdd = 0;
                    nextShift = 0;
                    nextState = S2;
                end
            end

            S2: begin 
                nextDone = 1;
                nextState = S0;
            end

            default:
                nextState = S0;
        endcase
    end

endmodule