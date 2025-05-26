module memory_bram(
    input wire clk,
    input wire rst,
    input wire [63:0] addr,      // Memory address
    input wire [63:0] data_in,   // Data to write
    input wire write_en,         // Write enable
    input wire read_en,          // Read enable
    output reg [63:0] data_out   // Data read from memory
);

    // BRAM parameters
    parameter ADDR_WIDTH = 10;   // 1K words
    parameter DATA_WIDTH = 64;   // 64-bit data
    parameter MEM_SIZE = 1024;   // 1K words

    // BRAM memory array
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
    
    // Initialize memory with program
    initial begin
        $readmemh("program.hex", mem);
    end

    // BRAM read/write operations
    always @(posedge clk) begin
        if (rst) begin
            data_out <= 64'h0;
        end else begin
            // Write operation
            if (write_en) begin
                mem[addr[ADDR_WIDTH-1:0]] <= data_in;
            end
            
            // Read operation (always enabled for BRAM)
            data_out <= mem[addr[ADDR_WIDTH-1:0]];
        end
    end

endmodule 