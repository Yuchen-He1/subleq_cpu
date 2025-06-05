module pc_incre_abc(
    input wire clk,
    input wire rst,
    input wire [63:0] pc,       // Current program counter
    input wire [63:0] c,        // C operand (jump address)
    input wire pc_ld,           // PC load enable from control
    input wire [2:0] state,     // Current state (3-bit)
    output reg [63:0] next_pc   // Next program counter value
);

    // State definitions
    localparam FETCH_ABC           = 3'd0;
    localparam LOAD_ABC            = 3'd1;  
    localparam FETCH_MEM_AB        = 3'd2;
    localparam LOAD_MEM_AB         = 3'd3;
    localparam EXECUTE             = 3'd4;
    localparam WRITEBACK_UPDATE_PC = 3'd5;

    always @(*) begin
        case (state)
            WRITEBACK_UPDATE_PC: begin
                if (pc_ld) begin
                    // Conditional jump: if ALU result <= 0, jump to address C
                    next_pc = c;
                    $display("PC jump to: %d", c);
                end else begin
                    // No jump: increment PC by 1 (each PC points to a group of 3 operands)
                    next_pc = pc + 64'd3;
                    $display("PC increment to: %d", pc + 64'd3);
                end
            end
            default: begin
                // Keep current PC value during other states
                next_pc = pc;
            end
        endcase
    end

endmodule 