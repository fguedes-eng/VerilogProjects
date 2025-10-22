import ALUInstr::*;

module ALU (
    input [31:0] in1,
    input [31:0] in2,
    input [3:0] opcode,
    output logic [31:0] out
);

logic signed [31:0] u_in1;
logic signed [31:0] u_in2;

assign signed_in1 = in1;
assign signed_in2 = in2;

always @(*) begin
    case (opcode)
        ADD:
            out = in1 + in2;
        SUB:
            out = in1 - in2;
        SLL:
            out = in1 << in2[4:0];
        SRL:
            out = in1 >> in2[4:0];
        SRA:
            out = in1 >>> in2[4:0];
        OR:
            out = in1 | in2;
        AND:
            out = in1 & in2;
        XOR:
            out = in1 ^ in2;
        SLT:
            out = (signed_in1 < signed_in2) ? 32'd1 : 32'd0;
        ULT:
            out = (in1 < in2) ? 32'd1 : 32'd0;
        UGTE:
            out = (in1 >= in2) ? 32'd1 : 32'd0;
        EQ:
            out = (in1 == in2) ? 32'd1 : 32'd0;
        SGTE:
            out = (signed_in1 >= signed_in2) ? 32'd1 : 32'd0;
        NEQ:
            out = (in1 != in2) ? 32'd1 : 32'd0;

        default:
            out = 32'd0;
    endcase
end

endmodule
