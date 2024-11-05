`timescale 1ns / 1ps

// Program Counter Module
module PC( input clk, input reset, input [31:0 ] startPC, input [31:0] updated_address, output reg [31:0] address );
	
	// PC is sensitive to negative edge of clock
	// Reset (active low) should asynchronously reset the PC
	always @(negedge clk or negedge reset) begin
		if ( reset == 1'b0 )
			address <= startPC;					// Reset PC to starting address
		else
			address <= updated_address;			// Set PC to updated address
	end
endmodule

// Single Cycle Processor Module
module SingleCycleProc( CLK, Reset_L, startPC, dMemOut);

// Inputs
input CLK, Reset_L;
input [31:0] startPC;
output [31:0] dMemOut;

// Instruction Memory
wire [31:0] Data;
wire [31:0] Address;
wire [31:0] New_PC_addr;

// Wires - Register File 
wire [31:0] BusA_wire, BusB_wire;
wire[4:0] write_reg_select_wire;
wire [31:0] write_reg_data_wire;

// Wire - Data Memory output 
wire [31:0] Data_mem_out_wire;

// Wires - Control Unit 
wire RegDst_wire;
wire ALUSrc_wire;
wire MemToReg_wire;
wire RegWrite_wire;
wire MemRead_wire;
wire MemWrite_write;
wire Branch_wire;
wire Jump_wire;
wire SignExtend_wire;
wire [3:0] ALUOp_wire;

// Wire - ALU Control
wire [3:0] ALU_control_wire;

// Wires - MUX before ALU 
wire [31:0] operand_2_ALU_wire;
wire[31:0] sign_ext_data_wire;

// Wires - ALU output 
wire [31:0] ALU_Output_wire;
wire ALU_Zero_wire;

// Wire - shift left 2 bits for branch
wire [31:0] SL_2_branch_wire;

// Wire - branch address
wire [31:0] branch_addr_wire;

// Wire - PC update
wire[31:0] PC_update_wire;

// Wire - Branch AND output
wire [31:0] branch_AND_wire;

// Wire - Branch MUX output
wire [31:0] branch_MUX_wire;

// Wire - Shift left 2 bits 25 to 0
wire [27:0] SL_2_jump_wire;

// Wire - Final jump 
wire [31:0] jump_addr_wire;

// Wire - Register File Final outputs
wire [31:0] Bus_A_output;
wire [31:0] Bus_B_output;


// *** Instantiating modules *** 

// Instruction Memory
InstructionMemory IM_1(.Data(Data), .Address(Address));

// Program Counter
PC PC_1( .clk(CLK) , .reset(Reset_L) , .startPC(startPC), .updated_address(New_PC_addr), .address(Address));

// Single Cycle Control
SingleCycleControl SCC_1 (.RegDst(RegDst_wire), .ALUSrc(ALUSrc_wire), .MemToReg(MemToReg_wire), .RegWrite(RegWrite_wire), .MemRead(MemRead_wire), .MemWrite(MemWrite_write), .Branch(Branch_wire), .Jump(Jump_wire), .SignExtend(SignExtend_wire), .ALUOp(ALUOp_wire), .Opcode(Data[31:26]));


// Register File
RegisterFile RF_1 ( .RA(Data[25:21]), .RB(Data[20:16]), .RW(write_reg_select_wire), .BusW(write_reg_data_wire), .RegWr(RegWrite_wire), .Clk(CLK), .BusA(BusA_wire), .BusB(BusB_wire) );

// ALU Control Unit
ALUControl AC_1 (.ALUCtrl(ALU_control_wire), .ALUop(ALUOp_wire), .FuncCode(Data[5:0]));

// ALU
ALU ALU_1 (.BusW(ALU_Output_wire), .Zero(ALU_Zero_wire), .BusA(Bus_A_output), .BusB(Bus_B_output), .ALUCtrl(ALU_control_wire));

// Data Memory - Word addressable - skip first 2 bits
DataMemory DM_1 (.ReadData(Data_mem_out_wire), .Address(ALU_Output_wire[7:2]), .WriteData(BusB_wire), .MemoryRead(MemRead_wire), .MemoryWrite(MemWrite_write), .Clock(CLK));


// Sign extension
assign sign_ext_data_wire = SignExtend_wire ? {{16{Data[15]}},Data[15:0]} : {{16{1'b0}},Data[15:0]}  ;

// Selecting write register of RF_1
assign write_reg_select_wire = RegDst_wire ? Data[15:11] : Data[20:16];

// Selecting 2nd operand of ALU
assign operand_2_ALU_wire = ALUSrc_wire ? sign_ext_data_wire : BusB_wire;

assign Bus_A_output = BusA_wire;
assign Bus_B_output = operand_2_ALU_wire;

// Data_written in register
assign write_reg_data_wire = MemToReg_wire ? Data_mem_out_wire : ALU_Output_wire;

// Shift left for branch 
assign SL_2_branch_wire = sign_ext_data_wire << 2;
 
// Updating PC -> PC = PC + 4
assign PC_update_wire =  Address + 32'd4 ; 
 
// Branch address
assign branch_addr_wire = SL_2_branch_wire + PC_update_wire;

// Compute Branch AND output
assign branch_AND_wire = Branch_wire & ALU_Zero_wire;

// Compute Branch MUX output
assign branch_MUX_wire = branch_AND_wire ?  branch_addr_wire : PC_update_wire;

// Left shift 26 bits of data by 2 bits for jump instruction - no. of instructions x 4 -> No. of bytes / address location
assign SL_2_jump_wire = ( Data[25:0] << 2 );

// Concatenate PC + 4 (4 bits) + 28 bits offset of JUMP
assign jump_addr_wire = { PC_update_wire[31:28], SL_2_jump_wire };

// Calculate New PC
assign New_PC_addr = Jump_wire ? jump_addr_wire : branch_MUX_wire;

// Data Memory output - Read data output
assign dMemOut = Data_mem_out_wire;

endmodule