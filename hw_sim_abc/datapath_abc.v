module datapath_abc(
    input wire clk,
    input wire rst,
    // Control signals
    input wire abc_ld,          // Load enable for a, b, c registers
    input wire mem_ab_ld,       // Load enable for mem_a, mem_b registers
    input wire result_ld,       // Load enable for result register
    input wire read_en_abc,     // Read enable for ABC instruction fetch
    input wire read_en_ab,      // Read enable for memory data fetch
    input wire write_en_b,      // Write enable for memory B
    input wire pc_ld,           // Program counter load enable
    input wire [2:0] state,     // Current 3-bit state from control
    // Outputs
    output wire zero,           // Zero flag to control
    output wire negative        // Negative flag to control
);

    // State codes (3-bit FSM)
    localparam FETCH_ABC           = 3'd0;
    localparam LOAD_ABC            = 3'd1;  
    localparam FETCH_MEM_AB        = 3'd2;
    localparam LOAD_MEM_AB         = 3'd3;
    localparam EXECUTE             = 3'd4;
    localparam WRITEBACK_UPDATE_PC = 3'd5;

    // Internal registers
    reg [63:0] pc;              // Program counter
    reg [63:0] a_reg;           // Register for a
    reg [63:0] b_reg;           // Register for b
    reg [63:0] c_reg;           // Register for c
    reg [63:0] mem_a_reg;       // Register for mem[a]
    reg [63:0] mem_b_reg;       // Register for mem[b]
    reg [63:0] result_reg;      // Register for ALU result

    // Memory interface wires
    wire [63:0] data_out_a, data_out_b, data_out_c;
    wire [63:0] data_out_mem_a, data_out_mem_b;

    // Instantiate three-memory module
    memory_abc mem_inst (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .addr_a(a_reg),
        .addr_b(b_reg),
        .data_in(result_reg),
        .write_en_b(write_en_b),
        .read_en_abc(read_en_abc),
        .read_en_a(read_en_ab),     // Read memory A when reading data
        .read_en_b(read_en_ab),     // Read memory B when reading data
        .data_out_a(data_out_a),
        .data_out_b(data_out_b),
        .data_out_c(data_out_c),
        .data_out_mem_a(data_out_mem_a),
        .data_out_mem_b(data_out_mem_b)
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
    pc_incre_abc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .c(c_reg),
        .pc_ld(pc_ld),
        .state(state),
        .next_pc(next_pc)
    );

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
            pc <= next_pc;
            $display("PC updated to: %d", next_pc);

            // Register updates
            if (abc_ld) begin
                a_reg <= data_out_a;
                b_reg <= data_out_b;
                c_reg <= data_out_c;
                $display("ABC registers updated: A=%d, B=%d, C=%d", data_out_a, data_out_b, data_out_c);
            end
            
            if (mem_ab_ld) begin
                mem_a_reg <= data_out_mem_a;
                mem_b_reg <= data_out_mem_b;
                $display("mem_a_reg=%d, mem_b_reg=%d", data_out_mem_a, data_out_mem_b);
            end
            
            if (result_ld) begin
                result_reg <= alu_result;
                $display("result_reg updated to: %d", alu_result);
            end
        end
    end

endmodule 