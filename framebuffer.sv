module frameDrawer(	input 	logic 			Clk, VGACLK, DrawEn, Reset, 
					input 	logic 			charIsMoving, charIsRunning,
					input	logic 	[1:0]	direction, charMoveFrame,
					input 	logic 	[3:0]	state_num,
					input 	logic 	[9:0] 	DRAWX, DRAWY,
					input 	logic 	[7:0] 	keycode,
					output 	logic 	[7:0] 	R, G, B
					);

	/*
		direction map:
			0: 	down
			1:	up
			2:	left
			3:	right

		charMoveFrame:
			0, 1, 2 for movement.

		formula for which character to draw:
			Character picture dimension: 271(x) * 112(y)
			((DRAWY - 229) + direction * 21) * 271 + ((DRAWX - 319) + charMoveFrame * 16)

		we are drawing the next pixels during the blank intervals

		state map:
			0: 	start_screen
			1: 	flash_press_enter
			2: 	fade
			3: 	draw_main_game
			4: 	hold

	*/

	logic [23:0] FBdata_In, FBdata_Out, next_pixel;
	logic [23:0] Chardata_Out, Gymdata_Out;
	logic [18:0] FBwrite_address, FBread_address;
	logic [18:0] Charread_address, Gymread_address;
	logic [9:0] DRAWX_next, DRAWY_next;
	logic FBwe, Charwe;

	// always_ff @ (posedge VGACLK) begin
	// 	if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
	// 	//if(DRAWX >= 10'd0 && DRAWX < 10'd320 && DRAWY >= 10'd0 && DRAWY < 10'd240) begin
	// 		R 	<= 	FBdata_Out[23:16];
	// 		G 	<= 	FBdata_Out[15:8];
	// 		B 	<= 	FBdata_Out[7:0];
	// 	end 
	// 	else begin
	// 		R 	<= 	8'h00;
	// 		G 	<= 	8'h00;
	// 		B 	<= 	8'h00;
	// 	end 
	// end 

	always_comb begin
		if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
			R 	= 	FBdata_Out[23:16];
			G 	= 	FBdata_Out[15:8];
			B 	= 	FBdata_Out[7:0];
		end 
		else begin
			R 	= 	8'h00;
			G 	= 	8'h00;
			B 	= 	8'h00;
		end 
	end 

	always_comb begin
		FBread_address 	= 	((DRAWY - 80) / 2) * 240 + ((DRAWX - 80) / 2);	//MAYBE DURING THE WRITING PROCESS OF THE NEXT PIXEL, WE NEED DIFFERENT ADDRESS
		FBwrite_address	= 	(DRAWY - 80) * 240 + (DRAWX - 560);
		// FBread_address = ((DRAWY - 80)) * 240 + ((DRAWX - 80));
		//FBwrite_address = FBread_address; 
		DRAWX_next 		= 	DRAWX - 560;	//drawing this during blanking
		DRAWY_next 		= 	DRAWY - 80;
	end 

	/*-------------------next pixel logic--------------------*/
	always_ff @ (posedge Clk) begin
		if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
		// if(DRAWX >= 10'd0 && DRAWX < 10'd320 && DRAWY >= 10'd0 && DRAWY < 10'd240) begin
			FBwe 			<= 	1'b0;
		end 
		//if DRAWX is between 560-799 and DRAWY is between 80 and 239 then we can draw the next frame based on inputs
		else if(DRAWX >= 560 && DRAWX <= 799 && DRAWY >= 80 && DRAWY <= 239) begin 
			FBwe 			<= 	1'b1;			//allows us to write to memory
			FBdata_In 		<= 	next_pixel;		//write in the next pixel
		end
		else begin
			FBwe 		<= 	1'b0;			//if anything else, we turn off the write enable
		end 
	end 

	always_comb begin
		next_pixel 			= 	FBdata_Out;
		Charread_address	= 	19'd0;
		Gymread_address = 	DRAWY_next * 471 + DRAWX_next;
		unique case (state_num)
			4'd0 	: 	
						begin 	//start_screen
							next_pixel 	= 	FBdata_Out;  //THIS WILL CHANGE IF WE WANT TO GO BACK AFTER PLAYING GAME
						end 
			4'd1 	: 	begin	//flash_press_enter
							next_pixel 	= 	FBdata_Out;  //THIS WILL CHANGE WHEN WE ACTUALLY DRAW THE ENTER SIGN 
						end 
			4'd2 	: 	begin	//fade
							next_pixel 	= 	(R < 8'd5) ? (next_pixel & 24'h00FFFF) : {next_pixel[23:16] - 8'd5, next_pixel[15:0]};
							next_pixel 	= 	(G < 8'd5) ? (next_pixel & 24'hFF00FF) : {next_pixel[23:16], next_pixel[15:8] - 8'd5, next_pixel[7:0]};
							next_pixel 	= 	(B < 8'd5) ? (next_pixel & 24'hFFFF00) : {next_pixel[23:8], next_pixel[7:0] - 8'd5};
						end 
			4'd3 	: 	begin	//draw_main_game, first draw map, then draw character
							/*-------------draw map--------------*/	
							//@@IMPLEMENT!!!
							next_pixel 	= 	Gymdata_Out;
							//next_pixel 	= 	24'hE8E088;
							/*-------------draw character--------------*/	
							if(DRAWX_next >= 10'd111 && DRAWX_next <= 10'd127 && DRAWY_next >= 10'd69 && DRAWY_next <= 10'd90) begin	//if within the character box
							// if(DRAWX >= 10'd119 && DRAWX < 10'd136 && DRAWY >= 10'd79 && DRAWY < 10'd101) begin
								if(~charIsMoving) begin		//character is not moving
									//Charread_address = ((DRAWY - 239) + direction * 21) * 271 + ((DRAWX - 319) + 16);
									if(direction == 2'd3) begin		//if the character is facing right
										Charread_address = ((DRAWY_next - 69) + 42) * 271 - (DRAWX_next - 10'd111) + 31;
										// Charread_address = ((DRAWY - 79) + 42) * 271 - ((DRAWX - 119) + 31);
									end 
									else begin
										Charread_address = ((DRAWY_next - 69) + direction * 21) * 271 + ((DRAWX_next - 111) + 16);
										// Charread_address = ((DRAWY - 79) + direction * 21) * 271 + ((DRAWX - 119) + 16);
									end 
									if(Chardata_Out != 24'hFF00FF) begin	//if not transparent color, draw
										next_pixel 	= 	Chardata_Out;
									end 
									// else begin
									// 	next_pixel 	=	FBdata_Out;
									// end 
								end 
								else begin
									// Charread_address = ((DRAWY - 219) / 2 + direction * 21) * 271 + ((DRAWX - 319) + charMoveFrame * 16 + charIsRunning * 48);
									if(direction == 2'd3) begin //if the character is facing right
										Charread_address = ((DRAWY_next - 69) + 42) * 271 - (DRAWX_next - 111) + charMoveFrame * 16 + charIsRunning * 48 + 15;
										// Charread_address = ((DRAWY - 79) + 42) * 271 - ((DRAWX - 119) + 15 + charMoveFrame * 16 + charIsRunning * 48);
									end 
									else begin
										Charread_address = ((DRAWY_next - 69) + direction * 21) * 271 + ((DRAWX_next - 111) + charMoveFrame * 16 + charIsRunning * 48);
										// Charread_address = ((DRAWY - 79) + direction * 21) * 271 + ((DRAWX - 119) + charMoveFrame * 16 + charIsRunning * 48);
									end 
									if(Chardata_Out != 24'hFF00FF) begin	
										next_pixel 	= 	Chardata_Out;
									end
									else begin
										next_pixel 	= 	FBdata_Out;	//CHANGE THIS LATER
									end 
								end
							end
						end 
			4'd4 	: 	;

			default : 	;
		endcase
	end 

	FramebufferRam FBRam(	.data_In(FBdata_In),
							.write_address(FBwrite_address),
							.read_address(FBread_address),
							.we(FBwe),
							.Clk(Clk), //if any error CHECK HERE!!!!!!!!!!!!!!!!!!!!!
							.data_Out(FBdata_Out)
						);

	CharacterRam CharRam(	.data_In(24'd0),
							.write_address(19'd0),
							.read_address(Charread_address),
							.we(1'b0),
							.Clk(Clk),
							.data_Out(Chardata_Out)
						);

	GymMapRam 	GymRam(		.data_In(24'd0),
							.write_address(19'd0),
							.read_address(Gymread_address),
							.we(1'b0),
							.Clk(Clk),
							.data_Out(Gymdata_Out)
						);

endmodule


