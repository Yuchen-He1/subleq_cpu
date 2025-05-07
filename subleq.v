module subleq(
    input wire clk,
    input wire rst
);

    // State register
    reg [2:0] state;
    
    // State definitions
    localparam FETCH_A = 3'b000;
    localparam FETCH_B = 3'b001;
    localparam FETCH_C = 3'b010;
    localparam FETCH_MEM_A = 3'b011;
    localparam FETCH_MEM_B = 3'b100;
    localparam EXECUTE = 3'b101;
    localparam WRITEBACK = 3'b110;
    localparam UPDATE_PC = 3'b111;

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

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= FETCH_A;
        end else begin
            case (state)
                FETCH_A: state <= FETCH_B;
                FETCH_B: state <= FETCH_C;
                FETCH_C: state <= FETCH_MEM_A;
                FETCH_MEM_A: state <= FETCH_MEM_B;
                FETCH_MEM_B: state <= EXECUTE;
                EXECUTE: state <= WRITEBACK;
                WRITEBACK: state <= UPDATE_PC;
                UPDATE_PC: state <= FETCH_A;
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

    // Instantiate datapath
    datapath dp_inst (
        .clk(clk),
        .rst(rst),
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
        .mem_data_out(mem_data_out)
    );

endmodule
