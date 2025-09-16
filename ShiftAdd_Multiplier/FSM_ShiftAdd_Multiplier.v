`include "log2_func.vh"

module FSM_ShiftAdd_Multiplier #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input start,
    input lsb,
    input [COUNT_DEPTH:0] count,
    output reg load,
    output reg shift,
    output reg add,
    output reg done,
    output reg ld_count
);

localparam MULT_LENGTH = WIDTH;
localparam COUNT_DEPTH = log2(WIDTH); 

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
reg nextLd_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ld_count <= 0;
            load <= 0;
            shift <= 0;
            add <= 0;
            done <= 0;
            state <= S0;
            nextLd_count <= 0;
            nextLoad <= 0;
            nextShift <= 0;
            nextAdd <= 0;
            nextDone <= 0;
            nextState <= S0;
        end else begin
            ld_count <= nextLd_count;
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
                    nextState = S0;
                    nextLoad = 1;
                end else if (load) begin
                    nextState = S1;
                    nextLoad = 0;
                end else begin
                    nextState = state;
                    nextLoad = 0;
                end
            end

            S1: begin
                /* Enquanto ainda não deu shift, não pode determinar a condição de soma (lsb ainda não atualizou) */
                if (shift) begin
                    nextState = state;
                    nextShift = 0;
                end else begin
                    /* Conta número de iterações necessárias */
                    if (count < MULT_LENGTH) begin
                        /* Lê bit menos significativo e determina se soma ou não */
                        if (lsb == 1) begin
                            nextAdd = 1;
                        end else begin 
                            nextAdd = 0;
                        end
                        /* Vai pra fase de shift e manda contador incrementar */
                        nextState = S2;
                        nextShift = 0;
                        nextLd_count = 1;
                    end else begin
                        nextState = S3;
                        nextShift = 0;
                        nextAdd = 0;
                        nextLd_count = 0;
                    end
                end
            end

            S2: begin
                /* Envia sinal de shift */
                nextLd_count = 0;
                nextAdd = 0;
                nextShift = 1;
                nextState = S1;
            end

            S3: begin 
                /* Finaliza e volta ao primeiro estado */
                nextDone = 1;
                nextState = S0;
            end

            default:
                nextState = S0;
        endcase
    end

endmodule