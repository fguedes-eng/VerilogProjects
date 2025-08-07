module multiplier_csa_tb;
    reg [4 - 1:0] multiplicand;
    reg [4 - 1:0] multiplier;
    wire [2 * 4 - 1:0] result;

  multiplier_csa uut (
    .multiplicand(multiplicand),
    .multiplier(multiplier),
    .result(result)
  );

  initial begin
    $display("A    B    | Result");
    $monitor("%b %b | %b", multiplicand, multiplier, result);

    // Test cases
    multiplicand = 0010;
    multiplier   = 0110;
    #10;
    $finish;
  end
endmodule