`timescale 1ns / 1ps

module RegisterFile( input [4:0] RA, input [4:0] RB, input [4:0] RW, input [31:0] BusW, input RegWr, input Clk, output reg [31:0] BusA, output reg [31:0] BusB );

// RA - Bus A Address
// RB - Bus B Address
// RW - Write Port Address
// BusW - Write Port Data Input
// RegWr - Write enable signal
// Clk - Clock signal
// BusA - Bus A output data register
// BusB - Bus B output data register

reg [31:0] register_file [31:0]; // 32 elements x 32 bit wide element

// 0th register is wired to value 0
initial begin
    register_file[0] = 32'b0;
end

always @(posedge Clk) begin
    // If Write Port address is not zero and Write enable signal is high
    if ( (RW != 5'b0) && (RegWr == 1'b1) ) begin
        // Write data into  register
        register_file[RW] <= BusW;
    end
end

// Read values from registers
always @* begin
    BusA <= register_file[RA];
    BusB <= register_file[RB];
end

endmodule

