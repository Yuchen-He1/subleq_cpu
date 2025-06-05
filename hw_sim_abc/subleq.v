module subleq(
    input wire clk,
    input wire rst
);

    // State register (3-bit is sufficient for 6 states)
    reg [2:0] state;
    
    // State definitions (3-bit) - Simplified FSM
    localparam FETCH_ABC           = 3'd0;  // Fetch A, B, C operands simultaneously
    localparam LOAD_ABC            = 3'd1;  // Load A, B, C operands simultaneously  
    localparam FETCH_MEM_AB        = 3'd2;  // Fetch mem[A] and mem[B] simultaneously
    localparam LOAD_MEM_AB         = 3'd3;  // Load mem[A] and mem[B] into registers
    localparam EXECUTE             = 3'd4;  // Execute ALU operation
    localparam WRITEBACK_UPDATE_PC = 3'd5;  // Writeback result and update PC

    // Control signals
    wire abc_ld;        // Load enable for a, b, c registers
    wire mem_ab_ld;     // Load enable for mem_a, mem_b registers
    wire result_ld;     // Load enable for result register
    wire read_en_abc;   // Read enable for ABC instruction fetch
    wire read_en_ab;    // Read enable for memory data fetch
    wire write_en_b;    // Write enable for memory B
    wire pc_ld;         // PC load enable

    // Datapath signals
    wire zero;
    wire negative;

    // Simplified FSM with parallel operations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= FETCH_ABC;
        end else begin
            case (state)
                FETCH_ABC:           state <= LOAD_ABC;
                LOAD_ABC:            state <= FETCH_MEM_AB;
                FETCH_MEM_AB:        state <= LOAD_MEM_AB;
                LOAD_MEM_AB:         state <= EXECUTE;
                EXECUTE:             state <= WRITEBACK_UPDATE_PC;
                WRITEBACK_UPDATE_PC: state <= FETCH_ABC;
                default:             state <= FETCH_ABC;
            endcase
        end
    end

    // Instantiate control
    control_abc ctrl_inst (
        .clk(clk),
        .rst(rst),
        .state(state),
        .zero(zero),
        .negative(negative),
        .abc_ld(abc_ld),
        .mem_ab_ld(mem_ab_ld),
        .result_ld(result_ld),
        .read_en_abc(read_en_abc),
        .read_en_ab(read_en_ab),
        .write_en_b(write_en_b),
        .pc_ld(pc_ld)
    );

    // Instantiate datapath
    datapath_abc dp_inst (
        .clk(clk),
        .rst(rst),
        .abc_ld(abc_ld),
        .mem_ab_ld(mem_ab_ld),
        .result_ld(result_ld),
        .read_en_abc(read_en_abc),
        .read_en_ab(read_en_ab),
        .write_en_b(write_en_b),
        .pc_ld(pc_ld),
        .state(state),
        .zero(zero),
        .negative(negative)
    );

endmodule
