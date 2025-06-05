module memory_abc(
    input wire clk,
    input wire rst,
    input wire [63:0] pc,           // Program counter for instruction fetch
    input wire [63:0] addr_a,       // Address for memory A (from a_reg)
    input wire [63:0] addr_b,       // Address for memory B (from b_reg)
    input wire [63:0] data_in,      // Data to write to memory
    input wire write_en_b,          // Write enable for memory
    input wire read_en_abc,         // Read enable for instruction fetch
    input wire read_en_a,           // Read enable for memory A (data fetch)
    input wire read_en_b,           // Read enable for memory B (data fetch)
    output reg [63:0] data_out_a,   // A operand from program memory
    output reg [63:0] data_out_b,   // B operand from program memory  
    output reg [63:0] data_out_c,   // C operand from program memory
    output reg [63:0] data_out_mem_a, // Data from memory at address a_reg
    output reg [63:0] data_out_mem_b  // Data from memory at address b_reg
);

    // Single unified memory array (same as original design)
    reg [63:0] mem [0:1023];  // Unified memory space

    // Initialize memory with complete program
    initial begin
        $readmemh("fib_8_loop_new.hex", mem);
        
        // Debug print
        $display("Memory initialized:");
        for (integer i = 0; i < 10; i = i + 1) begin
            $display("mem[%0d] = %h", i, mem[i]);
        end
    end

    // Memory operations
    always @(posedge clk) begin
        if (rst) begin
            data_out_a <= 64'h0;
            data_out_b <= 64'h0;
            data_out_c <= 64'h0;
            data_out_mem_a <= 64'h0;
            data_out_mem_b <= 64'h0;
        end else begin
            // Write operation to memory
            if (write_en_b) begin
                mem[addr_b[9:0]] <= data_in;
                $display("Write: mem[%0d] = %h", addr_b[9:0], data_in);
            end
            
            // Read instruction operands (A, B, C) simultaneously from consecutive addresses
            if (read_en_abc) begin
                data_out_a <= mem[pc[9:0]];         // A operand at PC*3
                data_out_b <= mem[pc[9:0]+ 1];     // B operand at PC*3+1
                data_out_c <= mem[pc[9:0] + 2];     // C operand at PC*3+2
                $display("Read ABC: pc=%0d=, a=%h, b=%h, c=%h", pc[9:0], mem[pc[9:0]], mem[pc[9:0]+ 1], mem[pc[9:0]+ 2]);
            end
            
            // Read memory data at address stored in a_reg
            if (read_en_a) begin
                data_out_mem_a <= mem[addr_a[9:0]];
                $display("Read mem[%0d] = %h", addr_a[9:0], mem[addr_a[9:0]]);
            end
            
            // Read memory data at address stored in b_reg
            if (read_en_b) begin
                data_out_mem_b <= mem[addr_b[9:0]];
                $display("Read mem[%0d] = %h", addr_b[9:0], mem[addr_b[9:0]]);
            end
        end
    end

endmodule 