module control(
    input wire clk,
    input wire rst,
    input wire [3:0] state,    // Current state from datapath (4-bit FSM)
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
            4'd0: begin  // FETCH_A
                mem_read = 1'b1;
            end
            4'd1: begin  // LOAD_A
                a_ld = 1'b1;
            end

            4'd2: begin  // FETCH_B
                mem_read = 1'b1;
            end
            4'd3: begin  // LOAD_B
                b_ld = 1'b1;
            end

            4'd4: begin  // FETCH_C
                mem_read = 1'b1;
            end
            4'd5: begin  // LOAD_C
                c_ld = 1'b1;
            end

            4'd6: begin  // FETCH_MEM_A
                mem_read = 1'b1;
            end
            4'd7: begin  // LOAD_MEM_A
                mem_a_ld = 1'b1;
            end

            4'd8: begin  // FETCH_MEM_B
                mem_read = 1'b1;
            end
            4'd9: begin  // LOAD_MEM_B
                mem_b_ld = 1'b1;
            end

            4'd10: begin  // EXECUTE
                result_ld = 1'b1;
            end

            4'd11: begin  // WRITEBACK
                mem_write = 1'b1;
            end

            4'd12: begin  // UPDATE_PC
                pc_ld = (zero | negative) ? 1'b1 : 1'b0;
            end
        endcase
    end

endmodule
