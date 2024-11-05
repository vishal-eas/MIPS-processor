`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:23:34 03/10/2009 
// Design Name: 
// Module Name:    SingleCycleControl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define RTYPEOPCODE		6'b000000
`define LWOPCODE		6'b100011
`define SWOPCODE        6'b101011
`define BEQOPCODE       6'b000100
`define JOPCODE			6'b000010
`define ORIOPCODE		6'b001101
`define ADDIOPCODE		6'b001000
`define ADDIUOPCODE		6'b001001
`define ANDIOPCODE		6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE		6'b001010
`define SLTIUOPCODE		6'b001011
`define XORIOPCODE		6'b001110

`define AND     		4'b0000
`define OR      		4'b0001
`define ADD     		4'b0010
`define SLL     		4'b0011
`define SRL     		4'b0100
`define SUB     		4'b0110
`define SLT     		4'b0111
`define ADDU    		4'b1000
`define SUBU    		4'b1001
`define XOR     		4'b1010
`define SLTU    		4'b1011
`define NOR     		4'b1100
`define SRA     		4'b1101
`define LUI     		4'b1110
`define FUNC    		4'b1111

module SingleCycleControl(RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, ALUOp, Opcode);
	
	// Inputs
	input [5:0] Opcode;

	// Outputs
	output RegDst;         // For dest register : 0-> 20-16 or  1-> 15-11 
	output ALUSrc;         // 0 - Logical operations - register values, 1 - Immediate / Arithmetic values
	output MemToReg;       // 0 -> ALU output written back to register, 1-> data memory written to register eg. Load
	output RegWrite;       // Write enable for register
	output MemRead;        // Read enable for data memory
	output MemWrite;       // Write enable for data memory
	output Branch;         // Branch instruction or not
	output Jump;           // Jump instruction or not
	output SignExtend;     // Sign extend enable flag
	output [3:0] ALUOp;    // ALUopcode into ALU control to decide ALU operation
     
	reg RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend;
	reg  [3:0] ALUOp;
	always @ (Opcode) begin
		case(Opcode)
			`RTYPEOPCODE: begin			// R-type instructions: RegDst and Regwrite is 1
				RegDst <= #2 1'b1;		// dest register address = Instruction[15:11]
				ALUSrc <= #2 1'b0;
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// Write to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'bx;
				ALUOp <= #2 `FUNC;
			end
			
			`LWOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// effective address calculation using offset
				MemToReg <= #2 1'b1;	// load data from memory to register
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b1;		// read from memory
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b1;	// sign extended offset 
				ALUOp <= #2 `ADD;		// effective address calculation using ADD
			end
			
			`SWOPCODE: begin
				RegDst <= #2 1'bx;		// No register writes
				ALUSrc <= #2 1'b1;		// effective address calculation using offset
				MemToReg <= #2 1'bx;	// No loading of data from memory to register
				RegWrite <= #2 1'b0;
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b1;	// Write data into memory
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b1;	// sign extended offset 
				ALUOp <= #2 `ADD;		// effective address calculation using ADD
			end
			
			`BEQOPCODE: begin
				RegDst <= #2 1'bx;		// No register writes	
				ALUSrc <= #2 1'b0;		// Operands are read from registers
				MemToReg <= #2 1'b0;	// No loading of data from memory to register
				RegWrite <= #2 1'b0;
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b1;		// Branch instruction
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b1;
				ALUOp <= #2 `SUB;		// BEQ subtraction result used to decide branch taken / not taken
			end
			
			`JOPCODE: begin
				RegDst <= #2 1'bx;		// No register writes
				ALUSrc <= #2 1'bx;		// No ALU operations
				MemToReg <= #2 1'bx;	// No loading of data from memory to register
				RegWrite <= #2 1'b0;
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b1;		// Jump instruction
				SignExtend <= #2 1'b0;	// Sign extension not used for JUMP
				ALUOp <= #2 4'bxxxx;
			end
			
			`ORIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;	// Not required for logical operations
				ALUOp <= #2 `OR;		// Logical OR operation
			end
			
			`ADDIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b1;	// Sign extended for immediate values
				ALUOp <= #2 `ADD;		// ADD operation
			end
			
			`ADDIUOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;
				ALUOp <= #2 `ADDU;		// ADDU operation
			end
			
			`ANDIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;
				ALUOp <= #2 `AND;		// Logical AND operation
			end
			
			`LUIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;
				ALUOp <= #2 `LUI;		// LUI operation
			end
			
			`SLTIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b1;	// Sign extended for immediate values
				ALUOp <= #2 `SLT;		// SLT operation
			end
			
			`SLTIUOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;
				ALUOp <= #2 `SLTU;		// SLTU operation
			end
			
			`XORIOPCODE: begin
				RegDst <= #2 1'b0;		// dest register address = Instruction[20:16]
				ALUSrc <= #2 1'b1;		// Immediate value
				MemToReg <= #2 1'b0;
				RegWrite <= #2 1'b1;	// write data to register
				MemRead <= #2 1'b0;
				MemWrite <= #2 1'b0;
				Branch <= #2 1'b0;
				Jump <= #2 1'b0;
				SignExtend <= #2 1'b0;
				ALUOp <= #2 `XOR;		// Logical XOR operation
			end
			
			default: begin
				RegDst <= #2 1'bx;
				ALUSrc <= #2 1'bx;
				MemToReg <= #2 1'bx;
				RegWrite <= #2 1'bx;
				MemRead <= #2 1'bx;
				MemWrite <= #2 1'bx;
				Branch <= #2 1'bx;
				Jump <= #2 1'bx;
				SignExtend <= #2 1'bx;
				ALUOp <= #2 4'bxxxx;
			end
		endcase
	end
endmodule
