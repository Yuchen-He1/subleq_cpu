module datapath(
    input wire clk,
    input wire rst,
    // Control signals
    input wire a_ld,           // Load enable for a register
    input wire b_ld,           // Load enable for b register
    input wire c_ld,           // Load enable for c register
    input wire mem_a_ld,       // Load enable for mem[a] register
    input wire mem_b_ld,       // Load enable for mem[b] register
    input wire result_ld,      // Load enable for result register
    input wire mem_read,       // Memory read enable
    input wire mem_write,      // Memory write enable
    input wire pc_ld,          // Program counter load enable
    input wire [2:0] state,    // Current state from control
    // Outputs
    output wire zero,          // Zero flag to control
    output wire negative,      // Negative flag to control
    output wire [63:0] mem_data_out // Data read from memory
);

    // Internal registers
    reg [63:0] pc;            // Program counter
    reg [63:0] a_reg;         // Register for a
    reg [63:0] b_reg;         // Register for b
    reg [63:0] c_reg;         // Register for c
    reg [63:0] mem_a_reg;     // Register for mem[a]
    reg [63:0] mem_b_reg;     // Register for mem[b]
    reg [63:0] result_reg;    // Register for ALU result
    reg [63:0] mem_addr;      // Memory address (internal)

    // Memory interface
    wire [63:0] mem_data_in;
    assign mem_data_in = result_reg;  // Write back result to memory

    // Instantiate memory
    wire [63:0] mem_data;
    memory mem_inst (
        .clk(clk),
        .rst(rst),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .write_en(mem_write),
        .read_en(mem_read),
        .data_out(mem_data)
    );

    // Instantiate ALU
    wire [63:0] alu_result;
    alu alu_inst (
        .a(mem_a_reg),
        .b(mem_b_reg),
        .result(alu_result),
        .zero(zero),
        .negative(negative)
    );

    // Instantiate PC incrementer
    wire [63:0] next_pc;
    pc_incre pc_inst (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .c(c_reg),
        .pc_ld(pc_ld),
        .state(state),
        .next_pc(next_pc)
    );

    // Set memory address based on state
    always @(*) begin
        case (state)
            3'b000: mem_addr = pc;           // FETCH_A: read A from current PC
            3'b001: mem_addr = pc + 64'd1;   // FETCH_B: read B from PC+1
            3'b010: mem_addr = pc + 64'd2;   // FETCH_C: read C from PC+2
            3'b011: mem_addr = a_reg;        // FETCH_MEM_A: read from address A
            3'b100: mem_addr = b_reg;        // FETCH_MEM_B: read from address B
            3'b110: mem_addr = b_reg;        // WRITEBACK: write to address B
            default: mem_addr = 64'h0;
        endcase
        //$display("State: %d, PC: %d, mem_addr: %d", state, pc, mem_addr);
    end

    // Register updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 64'h0;
            a_reg <= 64'h0;
            b_reg <= 64'h0;
            c_reg <= 64'h0;
            mem_a_reg <= 64'h0;
            mem_b_reg <= 64'h0;
            result_reg <= 64'h0;
        end else begin
            // PC update
            if (pc_ld) begin
                pc <= next_pc;
                $display("PC updated to: %d", next_pc);
            end

            // Register updates
            if (a_ld) begin
                a_reg <= mem_data;
                $display("A register updated to: %d", mem_data);
            end
            if (b_ld) begin
                b_reg <= mem_data;
                $display("B register updated to: %d", mem_data);
            end
            if (c_ld) begin
                c_reg <= mem_data;
                $display("C register updated to: %d", mem_data);
            end
            if (mem_a_ld) begin
                mem_a_reg <= mem_data;
                $display("mem_a_reg updated to: %d", mem_data);
            end
            if (mem_b_ld) begin
                mem_b_reg <= mem_data;
                $display("mem_b_reg updated to: %d", mem_data);
            end
            if (result_ld) begin
                result_reg <= alu_result;
                $display("result_reg updated to: %d", alu_result);
            end
        end
    end

    // Output assignment
    assign mem_data_out = mem_data;

endmodule
