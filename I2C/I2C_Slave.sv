module I2C_Slave (
    input scl,
    input data_in,
    inout sda
);

logic sda_pos;

always @(posedge scl) begin
    sda_pos <= sda;
end

always @(negedge scl) begin
    if (sda_pos == sda) begin
        
    end
end

always_comb begin
    case
        ADDRESS: begin
            if (count < 7)
                addr[count] = sda;
            else 
                next_state = RW;
        end

        RW: begin
            rw = sda;
            next_state = ACK;
        end

        ACK: begin
            sda = 1'b0;
            next_state = RW ? DATA_RCV : DATA_SEND;
        end
    endcase
end

endmodule
