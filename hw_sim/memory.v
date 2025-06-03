module memory(
    input wire clk,
    input wire rst,
    input wire [63:0] addr,      // Memory address
    input wire [63:0] data_in,   // Data to write
    input wire write_en,         // Write enable
    input wire read_en,          // Read enable
    output reg [63:0] data_out   // Data read from memory
);

    // Memory array
    reg [63:0] mem [0:1023];  // 1K words of 64-bit memory
    
    // Initialize memory with program
    initial begin
        $readmemh("fib_8_loop_new.hex", mem);
        // Debug print
        $display("Memory initialized:");
        for (integer i = 0; i < 62; i = i + 1) begin
            $display("mem[%0d] = %h", i, mem[i]);
        end
    end

    // Memory operations
    always @(posedge clk) begin
        if (rst) begin
            data_out <= 64'h0;
        end else begin
            if (write_en) begin
                mem[addr[9:0]] <= data_in;
                $display("Write: mem[%0d] = %h", addr[9:0], data_in);
            end
            if (read_en) begin
                data_out <= mem[addr[9:0]];
                $display("Read: mem[%0d] = %h", addr[9:0], mem[addr[9:0]]);
            end
        end
    end

endmodule 