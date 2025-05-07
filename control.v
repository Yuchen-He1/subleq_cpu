module control(
    input wire clk,
    input wire rst,
    input wire [2:0] state,    // Current state from datapath
    input wire zero,           // Zero flag from ALU
    input wire negative,       // Negative flag from ALU
    output reg a_ld,           // Load enable for a register
    output reg b_ld,           // Load enable for b register
    output reg c_ld,           // Load enable for c register
    output reg mem_a_ld,       // Load enable for mem[a] register
    output reg mem_b_ld,       // Load enable for mem[b] register
    output reg result_ld,      // Load enable for result register
    output reg mem_read,       // Memory read enable
    output reg mem_write,      // Memory write enable
    output reg pc_ld           // Program counter load enable
);

    // State definitions (for reference)
    // 3'b000: FETCH_A
    // 3'b001: FETCH_B
    // 3'b010: FETCH_C
    // 3'b011: FETCH_MEM_A
    // 3'b100: FETCH_MEM_B
    // 3'b101: EXECUTE
    // 3'b110: WRITEBACK
    // 3'b111: UPDATE_PC

    // Control signal generation based on state
    always @(*) begin
        // Default values
        a_ld = 1'b0;
        b_ld = 1'b0;
        c_ld = 1'b0;
        mem_a_ld = 1'b0;
        mem_b_ld = 1'b0;
        result_ld = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        pc_ld = 1'b0;

        case (state)
            3'b000: begin  // FETCH_A
                mem_read = 1'b1;
                a_ld = 1'b1;
            end

            3'b001: begin  // FETCH_B
                mem_read = 1'b1;
                b_ld = 1'b1;
            end

            3'b010: begin  // FETCH_C
                mem_read = 1'b1;
                c_ld = 1'b1;
            end

            3'b011: begin  // FETCH_MEM_A
                mem_read = 1'b1;
                mem_a_ld = 1'b1;
            end

            3'b100: begin  // FETCH_MEM_B
                mem_read = 1'b1;
                mem_b_ld = 1'b1;
            end

            3'b101: begin  // EXECUTE
                result_ld = 1'b1;
            end

            3'b110: begin  // WRITEBACK
                mem_write = 1'b1;
            end

            3'b111: begin  // UPDATE_PC
                pc_ld = (zero | negative) ? 1'b1 : 1'b0;
            end
        endcase
    end

endmodule
