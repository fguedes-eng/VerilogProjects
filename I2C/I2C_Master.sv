module I2C_Master (
    input clk,
    input data_in,
    inout sda,
    output scl
);

localparam bit IDLE     = 3'b100;
localparam bit START    = 3'b00;
localparam bit ADDRESS  = 3'b01;
localparam bit DATA     = 3'b10;
localparam bit STOP     = 3'b11;

logic [2:0] counter;

always @(posedge clk) begin
    counter <= counter + 1;
    state <= next_state;
end

always @(posedge clk) begin
    if (state == START) begin
        scl <= counter[2];
    end

    if (state == ADDRESS) begin
        addrCount <= addrCount + 1;
    end
end

always_comb begin
    case (state)
        IDLE: begin
            if (data_in) begin
                next_state = START;
            end
        end

        START: begin
            if (scl == 1'b1) begin
                sda = 1'b0;
                next_state = ADDRESS;
            end
        end

        ADDRESS: begin
            if (addrCount < 8) begin
                sda = addr[addrCount];
            end else begin
                next_state = DATA;
            end
        end

        DATA: begin
            if (data_in) begin
                if (scl == 1'b0) begin
                    sda = data_in[dataCount];
                end
            end else begin
                next_state = STOP;
            end
        end

        STOP: begin
            if (scl == 1'b1) begin
                sda = 
            end
        end

        default:
            next_state = IDLE;
    endcase
end

endmodule

