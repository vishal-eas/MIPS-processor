module ForwardingUnit_tb();

    reg [5:0] tests_passed;
	reg UseShamt, UseImmed ;
    reg [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
    reg EX_RegWrite, MEM_RegWrite ;
    wire [1:0] AluOpCtrlA, AluOpCtrlB ;
    wire DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM ;

    ForwardingUnit fu(UseShamt, UseImmed, ID_Rs, ID_Rt ,EX_Rw, MEM_Rw, EX_RegWrite, MEM_RegWrite, AluOpCtrlA, AluOpCtrlB, DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM);
    initial begin
    UseShamt    = 0;
    UseImmed    = 0;
    ID_Rs       = 4'b0000;
    ID_Rt       = 4'b0000;
    EX_Rw       = 4'b0000;
    MEM_Rw      = 4'b0000;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
	tests_passed= 0;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlB != 2'b11)
		$display("1 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlB != 2'b11)
		$display("2 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h5;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlB != 2'b11)
		$display("3 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlB != 2'b10)
		$display("4 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h5;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlB != 2'b01)
		$display("5 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h0;
    EX_Rw       = 4'h0;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlB != 2'b11)
		$display("6 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h0;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h0;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlB != 2'b11)
		$display("7 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 1;
    ID_Rt       = 4'h5;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h0;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlB != 2'b00)
		$display("8 error");
	else
		tests_passed = tests_passed + 1;


    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h5;
    UseImmed    = 0;
    ID_Rt       = 4'h2;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlA != 2'b11)
		$display("9 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h5;
    UseImmed    = 0;
    ID_Rt       = 4'h3;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlA != 2'b11)
		$display("10 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h5;
    UseImmed    = 0;
    ID_Rt       = 4'h4;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h5;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlA != 2'b11)
		$display("11 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h5;
    UseImmed    = 0;
    ID_Rt       = 4'h3;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlA != 2'b10)
		$display("12 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h5;
    UseImmed    = 0;
    ID_Rt       = 4'h3;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h5;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlA != 2'b01)
		$display("13 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h0;
    EX_Rw       = 4'h0;
    MEM_Rw      = 4'h2;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b0;
    #1;
	if(AluOpCtrlA != 2'b11)
		$display("14 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 0;
    ID_Rs       = 4'h0;
    UseImmed    = 0;
    ID_Rt       = 4'h0;
    EX_Rw       = 4'h1;
    MEM_Rw      = 4'h0;
    EX_RegWrite = 1'b0;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlA != 2'b11)
		$display("15 error");
	else
		tests_passed = tests_passed + 1;

    #5;
    UseShamt    = 1;
    ID_Rs       = 4'h5;
    UseImmed    = 1;
    ID_Rt       = 4'h4;
    EX_Rw       = 4'h5;
    MEM_Rw      = 4'h0;
    EX_RegWrite = 1'b1;
    MEM_RegWrite= 1'b1;
    #1;
	if(AluOpCtrlA != 2'b00)
		$display("16 error");
	else
		tests_passed = tests_passed + 1;

	if( tests_passed == 16 )
		$display("All tests passed");
	
	$display("TEST DONE");

    end
endmodule