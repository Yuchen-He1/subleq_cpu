module alu(
    input wire [63:0] a,      // First operand
    input wire [63:0] b,      // Second operand
    output wire [63:0] result, // Subtraction result
    output wire zero,         // Zero flag
    output wire negative      // Negative flag
);

    // Perform subtraction
    assign result = b - a;
    
    // Generate flags
    assign zero = (result == 64'h0);
    assign negative = result[63];  // MSB indicates negative in two's complement

endmodule
