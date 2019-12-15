/*module testbench_pokemon();
	timeunit 10ns;

	timeprecision 1ns;

	logic Clk = 0;
	logic VGA_CLK = 0;

	logic 			Reset;
 	logic 			VGA_VS, VGA_HS, DrawEn, VGA_BLANK_N, VGA_SYNC_N;
	logic 			charIsMoving, charIsRunning;
	logic 	[1:0]	direction, charMoveFrame;
	logic 	[3:0]	state_num;
	logic 	[9:0] 	DRAWX, DRAWY;
	logic 	[7:0] 	keycode;
	logic 	[7:0] 	R, G, B;
	logic 			atTile;
	logic 	[9:0]	charxcurrpos, charycurrpos;

	testmodule testint(.*);

	always begin : CLOCK_GENERATION

		Clk = #1 ~Clk;
	end

	always begin : VGA_gen

		VGA_CLK = #2 ~VGA_CLK;
	end	

	initial begin : CLOCK_INITIALIZATION

   		Clk = 0;
   		VGA_VS 	= 1;
   		VGA_CLK = 0;
		charIsMoving = 0;
		charIsRunning = 0;
		direction = 0;
		charMoveFrame = 0;
		state_num = 4'd0;
	end
	
	initial begin : TEST_VECTORS
		Reset 		= 	0;
		#2	Reset 	=	1;
		#2	Reset 	= 	0;
		#1 	VGA_VS 	= 	0;
		#1 	VGA_VS 	= 	1;
		#5 state_num = 4'd3;
	end 

endmodule*/
module testbench_pokemon();
	timeunit 10ns;

	timeprecision 1ns;

	logic Clk = 0;
	logic VGA_CLK = 0;

	logic 			Reset;
	logic	[9:0] 	xright, 	ybottom;
	logic 			atTile;
	logic 	[1:0] 	spin_direction;
	logic 	[9:0]	xleft_next_out,	ytop_next_out;

	gymTileLogic tileinstatnce(.*);

	always begin : CLOCK_GENERATION

		Clk = #1 ~Clk;
	end

	always begin : VGA_gen

		VGA_CLK = #2 ~VGA_CLK;
	end	

	initial begin : CLOCK_INITIALIZATION

   		Clk = 0;
   		VGA_CLK = 0;
	
	end
	
	initial begin : TEST_VECTORS
		Reset 		= 	0;
		#2	Reset 	=	1;
		#2	Reset 	= 	0;
		#1 	xright 	= 	0;
			ybottom =	0;
		#3	xright 	= 	10'd463;
			ybottom = 	10'd383;
		#100	xright 	= 	10'd0;
			ybottom = 	10'd0;
		#3 	xright 	= 	10'd15;
			ybottom = 	10'd79;
	end 

endmodule