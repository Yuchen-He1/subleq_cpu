module pc_incre(
    input wire clk,
    input wire rst,
    input wire [63:0] pc,         // Current PC value
    input wire [63:0] c,          // Branch target address
    input wire pc_ld,             // PC load enable from control
    input wire [3:0] state,       // Current 4-bit state
    output reg [63:0] next_pc     // Next PC value
);

    // State code for UPDATE_PC
    localparam UPDATE_PC = 4'd12;

    // Calculate next PC value
    wire [63:0] pc_plus_24;
    assign pc_plus_24 = pc + 64'd24;

    // Select next PC value based on pc_ld and state
    always @(*) begin
        if (state == UPDATE_PC && pc_ld) begin
            next_pc = c;  // Branch target
        end else if (state == UPDATE_PC) begin
            next_pc = pc_plus_24;  // Next instruction
        end else begin
            next_pc = pc;  // Keep current PC
        end
    end

endmodule
