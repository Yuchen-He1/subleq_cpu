module subleq_with_output(
    input wire clk,
    input wire rst,
    input wire clk_enable,
    output wire [63:0] result_out,
    output wire [3:0] state_out
);

    // State register
    reg [3:0] state;
    
    // State definitions (4-bit)
    localparam FETCH_A     = 4'd0;
    localparam LOAD_A      = 4'd1;
    localparam FETCH_B     = 4'd2;
    localparam LOAD_B      = 4'd3;
    localparam FETCH_C     = 4'd4;
    localparam LOAD_C      = 4'd5;
    localparam FETCH_MEM_A = 4'd6;
    localparam LOAD_MEM_A  = 4'd7;
    localparam FETCH_MEM_B = 4'd8;
    localparam LOAD_MEM_B  = 4'd9;
    localparam EXECUTE     = 4'd10;
    localparam WRITEBACK   = 4'd11;
    localparam UPDATE_PC   = 4'd12;

    // Control signals
    wire a_ld;
    wire b_ld;
    wire c_ld;
    wire mem_a_ld;
    wire mem_b_ld;
    wire result_ld;
    wire mem_read;
    wire mem_write;
    wire pc_ld;

    // Datapath signals
    wire zero;
    wire negative;
    wire [63:0] mem_data_out;

    // Expanded FSM with read/load separation and clock enable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= FETCH_A;
        end else if (clk_enable) begin
            case (state)
                FETCH_A:     state <= LOAD_A;
                LOAD_A:      state <= FETCH_B;
                FETCH_B:     state <= LOAD_B;
                LOAD_B:      state <= FETCH_C;
                FETCH_C:     state <= LOAD_C;
                LOAD_C:      state <= FETCH_MEM_A;
                FETCH_MEM_A: state <= LOAD_MEM_A;
                LOAD_MEM_A:  state <= FETCH_MEM_B;
                FETCH_MEM_B: state <= LOAD_MEM_B;
                LOAD_MEM_B:  state <= EXECUTE;
                EXECUTE:     state <= WRITEBACK;
                WRITEBACK:   state <= UPDATE_PC;
                UPDATE_PC:   state <= FETCH_A;
                default:     state <= FETCH_A;
            endcase
        end
    end

    // Instantiate control
    control ctrl_inst (
        .clk(clk),
        .rst(rst),
        .state(state),
        .zero(zero),
        .negative(negative),
        .a_ld(a_ld),
        .b_ld(b_ld),
        .c_ld(c_ld),
        .mem_a_ld(mem_a_ld),
        .mem_b_ld(mem_b_ld),
        .result_ld(result_ld),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .pc_ld(pc_ld)
    );

    // Instantiate datapath with result output
    datapath_with_output dp_inst (
        .clk(clk),
        .rst(rst),
        .clk_enable(clk_enable),
        .a_ld(a_ld),
        .b_ld(b_ld),
        .c_ld(c_ld),
        .mem_a_ld(mem_a_ld),
        .mem_b_ld(mem_b_ld),
        .result_ld(result_ld),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .pc_ld(pc_ld),
        .state(state),
        .zero(zero),
        .negative(negative),
        .mem_data_out(mem_data_out),
        .result_out(result_out)
    );

    // Output state for debugging
    assign state_out = state;

endmodule 