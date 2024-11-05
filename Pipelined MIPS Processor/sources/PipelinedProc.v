`timescale 1ns / 1ps


module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
    
input CLK,Reset_L;
input [31:0] startPC;
output [31:0] dMemOut;

wire [31:0] Data;
wire [31:0] Address;
reg [31:0] updated_PC_Address;

// Output of Hazard Unit 
wire [1:0] addrSel; // Mux select for PC
wire IF_write; 
wire PC_write;
wire bubble;

// Pipelined Control wires 
wire RegDst; // Selecting the actual bits of register file. If ==1 register file = 15 to 11 else  20 to 16. 
wire MemToReg; // Data of memory is written if =1 or data of alu is written if =0
wire RegWrite; // To write to the registers in the register file
wire MemRead; // To read from the memory
wire MemWrite; // To write into the memory unit. Data to be written comes from bus B 
wire Branch; // To activate branch control 
wire Jump; // Activate jump controll 
wire SignExtend; // Extend the sign of the immedieate value 
wire UseShamt; // To change the source registers in case of shift operations
wire UseImmed;// Indicate a immedieate type of instruction.
wire [3:0]ALUOp_IF_ID;// Type of operation to tbe performed. 


// Forwarding Unit 
wire [1:0] AluOpCtrlA_ID;
wire [1:0] AluOpCtrlB_ID;
wire DataMemForwardCtrl_EX_IF_ID;
wire DataMemForwardCtrl_MEM_IF_ID;


// Sign extended data 
wire[31:0] sign_extension_data;

// Register wires Fetch-Decode stage 
wire [31:0] Register_file_A_IF_ID, Register_file_B_IF_ID;
wire [31:0] BusW_WB;
wire [4:0] RA_IF_ID, RB_IF_ID, RW_WB;
wire[4:0] write_register_select_IF_ID;
wire [31:0] write_register_data_IF_ID;
wire [5:0] Opcode_IF_ID;
wire [4:0] RS_IF_ID;
wire [4:0] RT_IF_ID;
wire [4:0] RD_IF_ID;
wire [5:0] FUNC_IF_ID;
reg [31:0] IM_IF_ID;
wire [25:0] Jump_IF_ID;
wire [15:0] Immedi_IF_ID;
reg  [31:0] Normal_PC_IF_ID;
wire RegWr_WB;
wire Clk;


// Stage 3 ID -> Execute
reg RegDst_ID_EX;
reg MemToReg_ID_EX;
reg RegWrite_ID_EX;
reg MemRead_ID_EX;
reg MemWrite_ID_EX;
reg [3:0]ALUOp_ID_EX;
reg [1:0] AluOpCtrlA_ID_EX;
reg [1:0] AluOpCtrlB_ID_EX;
reg DataMemForwardCtrl_EX_ID_EX;
reg DataMemForwardCtrl_MEM_ID_EX;
reg [20:0] IM_20_0_ID_EX;
(* keep = "true"*)reg [31:0] Sign_Extended_ID_EX;
reg [31:0] Registers_A_ID_EX;
reg [31:0] Registers_B_ID_EX;

wire [5:0] Funccode_ID_EX;
wire [4:0] RT_ID_EX;
wire [4:0] RD_ID_EX;
wire [4:0] Shamt_ID_EX;
wire [4:0] RW_ID_EX;
wire [31:0] Data_Memory_Input_ID_EX;


// ALU Control wires
wire [31:0] ALU_OUT;
reg [31:0] ALU_IN1;
reg [31:0] ALU_IN2;
wire ALU_Zero;
wire [3:0] ALU_control;


// Stage 4
// Data Memory 
wire [31:0] Data_memory_out;
reg [31:0] Data_Memory_Input_EX_MEM;
reg [31:0] ALU_OUT_EX_MEM;
reg [4:0] RW_EX_MEM; 
wire [31:0] Data_Memory_actual_in;

reg MemToReg_EX_MEM;
reg RegWrite_EX_MEM;
reg MemRead_EX_MEM;
reg MemWrite_EX_MEM;

reg DataMemForwardCtrl_MEM_EX_MEM;

// Stage 5
// Writeback stage 
reg MemToReg_MEM_WB;
reg RegWrite_MEM_WB;
reg [4:0] RW_MEM_WB;
reg [31:0] DataOut_MEM_WB;
reg [31:0] ALU_OUT_MEM_WB;
wire [31:0] Register_W_MEM_WB;

// Instruction Memory
InstructionMemory IM1(.Data(Data), .Address(updated_PC_Address));

// Pipelined Control
PipelinedControl PCC1 (.RegDst(RegDst), .MemToReg(MemToReg), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Jump(Jump), .SignExtend(SignExtend), .ALUOp(ALUOp_IF_ID), .Opcode(Opcode_IF_ID), .Func_code(FUNC_IF_ID), .Bubble(bubble), .UseShamt(UseShamt), .UseImmed(UseImmed) );


// Hazard Unit 
HazardUnit Hazard (.IF_write(IF_write), .PC_write(PC_write), .bubble(bubble), .addrSel(addrSel), .Jump(Jump), .Branch(Branch), .ALUZero(ALU_Zero), .memReadEX(MemRead_ID_EX), .currRs(RS_IF_ID), .currRt(RT_IF_ID), .prevRt(RT_ID_EX), .UseShamt(UseShamt), .UseImmed(UseImmed), .Clk(CLK), .Rst(Reset_L));

// Register File
RegisterFile RF1 ( .RA(RS_IF_ID), .RB(RT_IF_ID), .RW( RW_MEM_WB ), .BusW(Register_W_MEM_WB), .RegWr(RegWrite_MEM_WB), .Clk(CLK), .BusA(Register_file_A_IF_ID), .BusB(Register_file_B_IF_ID) );

// Forwarding Unit 
ForwardingUnit Forward ( .UseShamt(UseShamt), .UseImmed(UseImmed), .ID_Rs(RS_IF_ID),.ID_Rt(RT_IF_ID), .EX_Rw(RW_ID_EX),.MEM_Rw(RW_EX_MEM), .EX_RegWrite(RegWrite_ID_EX), .MEM_RegWrite(RegWrite_EX_MEM), .AluOpCtrlA(AluOpCtrlA_ID), .AluOpCtrlB(AluOpCtrlB_ID), .DataMemForwardCtrl_EX(DataMemForwardCtrl_EX_IF_ID), .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM_IF_ID) );

// ALU 
ALU ALU1 (.BusW(ALU_OUT), .Zero(ALU_Zero), .BusA(ALU_IN1), .BusB(ALU_IN2), .ALUCtrl(ALU_control));

// ALU Control Unit. 
ALUControl AC1 (.ALUCtrl(ALU_control), .ALUop(ALUOp_ID_EX), .FuncCode(Funccode_ID_EX));

// Data Memory
DataMemory DM1 (.ReadData(Data_memory_out), .Address(ALU_OUT_EX_MEM[7:2]), .WriteData(Data_Memory_actual_in), .MemoryRead(MemRead_EX_MEM), .MemoryWrite(MemWrite_EX_MEM), .Clock(CLK));


// Program Counter Logic 
always @ (negedge CLK or negedge Reset_L)begin 
	if (~Reset_L)
		updated_PC_Address <= startPC;
	else if (PC_write)
		updated_PC_Address <= Address;
end


// Stage 2
// Register File to ID stage
always @ (negedge CLK or negedge Reset_L) begin
	if(~Reset_L) begin
		IM_IF_ID <= 32'b0;
		Normal_PC_IF_ID <= 32'b0;
	end
	else if(IF_write) begin
		IM_IF_ID <= Data;
		Normal_PC_IF_ID <= updated_PC_Address + 4;
	end
end


// STAGE 2
// Instruction Decode -> Execute Stage
always @ (negedge CLK or negedge Reset_L) begin
	if(~Reset_L) begin
		RegDst_ID_EX<=1'b0;
		MemToReg_ID_EX<=1'b0;
		RegWrite_ID_EX<=1'b0;
		MemRead_ID_EX<=1'b0;
		MemWrite_ID_EX<=1'b0;
		ALUOp_ID_EX<=4'b0;
		AluOpCtrlA_ID_EX<=2'b0;
		AluOpCtrlB_ID_EX<=2'b0;
		DataMemForwardCtrl_EX_ID_EX<=1'b0;
		DataMemForwardCtrl_MEM_ID_EX<=1'b0;
		IM_20_0_ID_EX<=21'b0;
		Sign_Extended_ID_EX<=32'b0;
		Registers_A_ID_EX<=32'b0;
		Registers_B_ID_EX<=32'b0;
	end
	
	else if(bubble) begin		// If bubble, then stop execution. 
		RegDst_ID_EX<=1'b0;
		MemToReg_ID_EX<=1'b0;
		RegWrite_ID_EX<=1'b0;
		MemRead_ID_EX<=1'b0;
		MemWrite_ID_EX<=1'b0;
		ALUOp_ID_EX<=4'b0;
		AluOpCtrlA_ID_EX<=2'b0;
		AluOpCtrlB_ID_EX<=2'b0;
		DataMemForwardCtrl_EX_ID_EX<=1'b0;
		DataMemForwardCtrl_MEM_ID_EX<=1'b0;
		IM_20_0_ID_EX<=21'b0;
		Sign_Extended_ID_EX<=32'b0;
		Registers_A_ID_EX<=32'b0;
		Registers_B_ID_EX<=32'b0;
	end
	
	else begin 
		RegDst_ID_EX<=RegDst;
		MemToReg_ID_EX<=MemToReg;
		RegWrite_ID_EX<=RegWrite;
		MemRead_ID_EX<=MemRead;
		MemWrite_ID_EX<=MemWrite;
		ALUOp_ID_EX<=ALUOp_IF_ID;
		AluOpCtrlA_ID_EX<=AluOpCtrlA_ID;
		AluOpCtrlB_ID_EX<=AluOpCtrlB_ID;
		DataMemForwardCtrl_EX_ID_EX<=DataMemForwardCtrl_EX_IF_ID;
		DataMemForwardCtrl_MEM_ID_EX<=DataMemForwardCtrl_MEM_IF_ID;
		IM_20_0_ID_EX<=IM_IF_ID[20:0];
		Sign_Extended_ID_EX<=sign_extension_data;
		Registers_A_ID_EX<=Register_file_A_IF_ID;
		Registers_B_ID_EX<=Register_file_B_IF_ID;
	end 
end 


// STAGE 3
// Execute Stage
// Input 1 
always @(*)begin 
	case (AluOpCtrlA_ID_EX)
		2'b00: ALU_IN1 = {27'b0, Shamt_ID_EX};
		2'b01: ALU_IN1 = Register_W_MEM_WB;
		2'b10: ALU_IN1 = ALU_OUT_EX_MEM;
		2'b11: ALU_IN1 = Registers_A_ID_EX;
	endcase
end

// Input 2 
always @(*)begin 
	case (AluOpCtrlB_ID_EX)
		2'b00: ALU_IN2 = Sign_Extended_ID_EX;
		2'b01: ALU_IN2 = Register_W_MEM_WB;
		2'b10: ALU_IN2 = ALU_OUT_EX_MEM;
		2'b11: ALU_IN2 = Registers_B_ID_EX;
	endcase
end 


// Execute -> Memory Stage
always @ (negedge CLK or negedge Reset_L) begin
	if (~Reset_L)begin 
		Data_Memory_Input_EX_MEM <= 32'b0;
		ALU_OUT_EX_MEM	<=32'b0;
		RW_EX_MEM		<=5'b0;
		MemToReg_EX_MEM	<=1'b0;
		RegWrite_EX_MEM	<=1'b0;
		MemRead_EX_MEM	<=1'b0;
		MemWrite_EX_MEM	<=1'b0;
		DataMemForwardCtrl_MEM_EX_MEM<=1'b0;
	end 

	else begin 
		Data_Memory_Input_EX_MEM<= 	 Data_Memory_Input_ID_EX;
		ALU_OUT_EX_MEM	<=	 ALU_OUT;
		RW_EX_MEM		<=	 RW_ID_EX;
		MemToReg_EX_MEM	<=	 MemToReg_ID_EX;
		RegWrite_EX_MEM	<=	 RegWrite_ID_EX;
		MemRead_EX_MEM	<=	 MemRead_ID_EX;
		MemWrite_EX_MEM	<=	 MemWrite_ID_EX;
		DataMemForwardCtrl_MEM_EX_MEM <=DataMemForwardCtrl_MEM_ID_EX;
	end 
end 


// Memory -> Writeback
always @(negedge CLK or negedge Reset_L)begin 
	if (~Reset_L)begin
		MemToReg_MEM_WB<=1'b0;
		RegWrite_MEM_WB<=1'b0;
		RW_MEM_WB<=5'b0;
		DataOut_MEM_WB<=32'b0;
		ALU_OUT_MEM_WB<=32'b0; 
	end 
	else begin 
		MemToReg_MEM_WB<=MemToReg_EX_MEM;
		RegWrite_MEM_WB<=RegWrite_EX_MEM;
		RW_MEM_WB<=RW_EX_MEM;
		DataOut_MEM_WB<=Data_memory_out;
		ALU_OUT_MEM_WB<=ALU_OUT_EX_MEM; 
	end 
end 


assign Opcode_IF_ID = IM_IF_ID[31:26];
assign FUNC_IF_ID = IM_IF_ID [5:0];
assign RS_IF_ID = IM_IF_ID[25:21];
assign	RT_IF_ID =	IM_IF_ID[20:16];
assign Jump_IF_ID =	IM_IF_ID[25:0];
assign Immedi_IF_ID =	IM_IF_ID[15:0];

// Sign Extension
assign sign_extension_data = SignExtend ? {{16{IM_IF_ID[15]}},IM_IF_ID[15:0]} : {{16{1'b0}},IM_IF_ID[15:0]}  ;

// Jump = 01, else it is 10 
assign Address = (addrSel==2'b00) ? updated_PC_Address+4 :(addrSel == 2'b01) ? 
{Normal_PC_IF_ID [31:28], Jump_IF_ID, 2'b0} : Normal_PC_IF_ID + (Sign_Extended_ID_EX[30:0] << 2);


assign RT_ID_EX = IM_20_0_ID_EX[20:16];
assign RD_ID_EX = IM_20_0_ID_EX[15:11];
assign Shamt_ID_EX = IM_20_0_ID_EX[10:6];
assign Funccode_ID_EX = IM_20_0_ID_EX [5:0];


assign RW_ID_EX = RegDst_ID_EX ? RD_ID_EX : RT_ID_EX;
assign Data_Memory_Input_ID_EX = DataMemForwardCtrl_EX_ID_EX ?  Register_W_MEM_WB : Registers_B_ID_EX;


// Stage 4
// Memory
assign Data_Memory_actual_in = DataMemForwardCtrl_MEM_EX_MEM ? Register_W_MEM_WB :Data_Memory_Input_EX_MEM;

// Stage 5
// Write back
assign Register_W_MEM_WB = MemToReg_MEM_WB ? DataOut_MEM_WB : ALU_OUT_MEM_WB;

// Final Output
assign dMemOut = DataOut_MEM_WB;


endmodule