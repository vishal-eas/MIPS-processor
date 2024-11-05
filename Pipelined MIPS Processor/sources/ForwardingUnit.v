`timescale 1ns / 1ps

module ForwardingUnit( UseShamt,
						UseImmed,
						ID_Rs,
						ID_Rt,
						EX_Rw,
						MEM_Rw,
						EX_RegWrite,
						MEM_RegWrite,
						AluOpCtrlA,
						AluOpCtrlB,
						DataMemForwardCtrl_EX,
						DataMemForwardCtrl_MEM);

	// Inputs
	input UseShamt, UseImmed;
	input [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
	input EX_RegWrite, MEM_RegWrite;
	
	// Outputs
	output reg [1:0] AluOpCtrlA, AluOpCtrlB;
	output reg DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;

	always @(*) begin

		if( UseShamt == 1 )				// Shift values used in current instruction
			AluOpCtrlA <= 2'b00;		// Shift value data -> BusA
		
		else if( UseShamt == 0 ) begin		// Shift values not used in current instruction
			
			// Check priority of pipeline stage for previous instructions
			if( (ID_Rs == MEM_Rw) && ~(MEM_Rw==EX_Rw && EX_RegWrite) && (MEM_RegWrite == 1) && (MEM_Rw != 0) )
				AluOpCtrlA <= 2'b01;	// Memory stage data -> BusA
			else if ( (ID_Rs == EX_Rw) && (EX_RegWrite == 1) && (EX_Rw != 0) )
				AluOpCtrlA <= 2'b10;	// Execute stage data -> BusA
			else
				AluOpCtrlA <= 2'b11;	// Register read data -> BusA
			end
		
		else
			AluOpCtrlA <= 2'b11;		// Register read data -> BusA


		if( UseImmed == 1 )				// Immediate values used in current instruction
			AluOpCtrlB <= 2'b00;		// Immediate value data -> BusB
		
		else if( UseImmed == 0 ) begin	// Immediate values not used in current instruction
			
			// Check priority of pipeline stage for previous instructions
			if( (ID_Rt == MEM_Rw) && ~(MEM_Rw==EX_Rw && EX_RegWrite) && (MEM_RegWrite == 1) && (MEM_Rw != 0) )
				AluOpCtrlB <= 2'b01;	// Memory stage data -> BusB
			else if( (ID_Rt == EX_Rw) && (EX_RegWrite == 1) && (EX_Rw != 0) )
				AluOpCtrlB <= 2'b10;	// Execute stage data -> BusB
			else
				AluOpCtrlB <= 2'b11;	// Register read data -> BusB
			end
		
		else
			AluOpCtrlB <= 2'b11;		// Register read data -> BusB
		
		
		// Select Lines for Muxes for Memory Write data in EX and MEM stages
		if( (MEM_RegWrite == 1) && (ID_Rt == MEM_Rw) && (MEM_Rw != 0) ) begin
			DataMemForwardCtrl_EX = 1'b1;
			DataMemForwardCtrl_MEM = 1'b0;
		
		end else if( (EX_RegWrite == 1) && (ID_Rt == EX_Rw) && (EX_Rw != 0) ) begin
			DataMemForwardCtrl_EX = 1'b0;
			DataMemForwardCtrl_MEM = 1'b1;
		
		end else begin
			DataMemForwardCtrl_EX = 1'b0;
			DataMemForwardCtrl_MEM = 1'b0;
		end

	end

endmodule
