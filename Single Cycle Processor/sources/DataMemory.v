`timescale 1ns / 1ps

module DataMemory( output reg [31:0] ReadData, input [5:0] Address, input [31:0] WriteData, input MemoryRead, input MemoryWrite, input Clock );
 
 // ReadData - Data output
 // Addresss - Address bus for read/write
 // WriteData - Data input
 // MemoryRead - Read signal
 // MemoryWrite - Write signal
 // Clock - Clock signal
 
 // Each word is 32 bits
 // Hence, we need 64 words for 256 bytes storage
 // 64 x 32 bits = 2048 bits = 256 bytes
 
reg [31:0] data_memory[63:0]; // 64 elements x 32 bit wide element

// Writes are synchronous on negative edge of clock
always @(negedge Clock) begin
    // Check if write signal is high
    if ( MemoryWrite == 1'b1 ) begin
        data_memory[Address] <= WriteData;
    end
end

// Reads are synchronous on positive edge of clock
always @(posedge Clock) begin
    // Check if read signal is high
    if ( MemoryRead == 1'b1 ) begin
        ReadData <= data_memory[Address];
    end
end

endmodule

