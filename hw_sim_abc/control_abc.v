module control_abc(
    input wire clk,
    input wire rst,
    input wire [2:0] state,     // Current state from FSM (3-bit)
    input wire zero,            // Zero flag from ALU
    input wire negative,        // Negative flag from ALU
    output reg abc_ld,          // Load enable for a, b, c registers
    output reg mem_ab_ld,       // Load enable for mem_a, mem_b registers  
    output reg result_ld,       // Load enable for result register
    output reg read_en_abc,     // Read enable for ABC instruction fetch
    output reg read_en_ab,      // Read enable for memory data fetch
    output reg write_en_b,      // Write enable for memory B
    output reg pc_ld            // Program counter load enable
);

    // State definitions (for reference)
    localparam FETCH_ABC           = 3'd0;  // Fetch A, B, C operands simultaneously
    localparam LOAD_ABC            = 3'd1;  // Load A, B, C operands simultaneously  
    localparam FETCH_MEM_AB        = 3'd2;  // Fetch mem[A] and mem[B] simultaneously
    localparam LOAD_MEM_AB         = 3'd3;  // Load mem[A] and mem[B] into registers
    localparam EXECUTE             = 3'd4;  // Execute ALU operation
    localparam WRITEBACK_UPDATE_PC = 3'd5;  // Writeback result and update PC

    // Control signal generation based on state
    always @(*) begin
        // Default values
        abc_ld = 1'b0;
        mem_ab_ld = 1'b0;
        result_ld = 1'b0;
        read_en_abc = 1'b0;
        read_en_ab = 1'b0;
        write_en_b = 1'b0;
        pc_ld = 1'b0;

        case (state)
            FETCH_ABC: begin  
                read_en_abc = 1'b1;  // Read A, B, C operands from three memories
            end
            
            LOAD_ABC: begin  
                abc_ld = 1'b1;       // Load A, B, C into registers
            end

            FETCH_MEM_AB: begin  
                read_en_ab = 1'b1;   // Read mem[A] and mem[B] simultaneously
            end

            LOAD_MEM_AB: begin  
                mem_ab_ld = 1'b1;    // Load mem[A] and mem[B] into registers
            end
            
            EXECUTE: begin  
                result_ld = 1'b1;    // Execute ALU operation (mem[A] - mem[B])
            end

            WRITEBACK_UPDATE_PC: begin  
                write_en_b = 1'b1;                    // Write back result to mem[B]
                pc_ld = (zero | negative) ? 1'b1 : 1'b0;  // Update PC conditionally
            end

            default: begin  
                // No control signals active
            end
        endcase
    end

endmodule 