module top_nexys_a7(
    input wire CLK100MHZ,    // 100MHz board clock
    input wire CPU_RESETN,   // Active low reset button
    input wire BTNC,         // Center button for manual reset
    output wire [6:0] SEG,   // 7-segment display segments (active low)
    output wire [7:0] AN,    // 7-segment display anodes (active low)
    output wire [15:0] LED   // LEDs for debugging
);

    // Clock and reset signals
    wire clk;
    wire rst;
    
    // Clock divider for CPU clk_enable
    reg [26:0] clk_div_counter; 
    reg clk_enable;
    reg clk_enable_visible; // For LED[3]
    
    always @(posedge CLK100MHZ) begin
        if (~CPU_RESETN) begin 
            clk_div_counter <= 0;
            clk_enable <= 0;
            clk_enable_visible <= 0;
        end else begin
            if (clk_div_counter == 100000000) begin 
                clk_div_counter <= 0;
                clk_enable <= 1;
                clk_enable_visible <= ~clk_enable_visible;
            end else begin
                clk_div_counter <= clk_div_counter + 1;
                clk_enable <= 0;
            end
        end
    end
    
    assign clk = CLK100MHZ;
    assign rst = ~CPU_RESETN | BTNC; 
    
    // CPU signals
    wire [63:0] result_reg; 
    wire [3:0] cpu_state;   
    
    subleq_with_output cpu_inst (
        .clk(clk),
        .rst(rst),
        .clk_enable(clk_enable),
        .result_out(result_reg),
        .state_out(cpu_state)
    );
    
    // Instantiate single-digit 7-segment display for cpu_state
    seven_seg_display_single state_display_inst (
        .clk(CLK100MHZ), // Can use fast clock as it's combinational after reg
        .rst(rst),
        .digit_value(cpu_state),
        .seg(SEG)       // Connect directly to top-level SEG
    );

    // Drive anodes: only AN0 (rightmost) is active (low)
    assign AN[0] = 1'b0; // Active AN0
    assign AN[7:1] = 7'b1111111; // Deactivate AN7-AN1
    
    // LED assignments
    assign LED[15:0] = result_reg[15:0]; // result_reg lower 16 bits
    // LED[3] was clk_enable_visible. Let's keep it.
    // assign LED[2:0] were for debug, now unused explicitly here but part of LED[15:0]

endmodule 