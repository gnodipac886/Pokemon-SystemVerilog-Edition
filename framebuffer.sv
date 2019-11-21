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

		state map:
			0: 	start_screen
			1: 	flash_press_enter
			2: 	fade
			3: 	draw_main_game
			4: 	hold
	*/

	logic [23:0] FBdata_In, FBdata_Out, next_pixel;
	logic [23:0] Chardata_Out;
	logic [18:0] FBwrite_address, FBread_address;
	logic [18:0] Charread_address;
	logic FBwe, Charwe;

	always_ff @ (posedge Clk) begin
		//if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
		if(DRAWX > 10'd0 && DRAWX < 10'd320 && DRAWY > 10'd0 && DRAWY < 10'd240) begin
			R 	<= 	FBdata_Out[23:16];
			G 	<= 	FBdata_Out[15:8];
			B 	<= 	FBdata_Out[7:0];
		end 
		else begin
			R 	<= 	8'h00;
			G 	<= 	8'h00;
			B 	<= 	8'h00;
		end 
	end 

	// always_comb begin
	// 	if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
	// 		R 	= 	FBdata_Out[23:16];
	// 		G 	= 	FBdata_Out[15:8];
	// 		B 	= 	FBdata_Out[7:0];
	// 	end 
	// 	else begin
	// 		R 	= 	8'h00;
	// 		G 	= 	8'h00;
	// 		B 	= 	8'h00;
	// 	end 
	// end 

	always_comb begin
		//FBread_address = ((DRAWY - 80) / 2) * 240 + ((DRAWX - 80) / 2);
		FBread_address = ((DRAWY - 80)) * 240 + ((DRAWX - 80));
		FBwrite_address = FBread_address;
	end 

	/*-------------------next pixel logic--------------------*/
	always_ff @ (posedge Clk) begin
		//if(DRAWX > 10'd79 && DRAWX < 10'd560 && DRAWY > 10'd79 && DRAWY < 10'd400) begin
		if(DRAWX > 10'd0 && DRAWX < 10'd320 && DRAWY > 10'd0 && DRAWY < 10'd240) begin
			FBwe 		<= 	1'b1;
			FBdata_In 	<= 	next_pixel;
		end 
		else begin
			FBwe 		<= 	1'b0;
		end 
	end 

	always_comb begin
		next_pixel 			= 	FBdata_Out;
		Charread_address	= 	19'd0;
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
							next_pixel 	= 	24'h000000;
							/*-------------draw character--------------*/	
							//if(DRAWX >= 10'd319 && DRAWX < 10'd336 && DRAWY >= 10'd239 && DRAWY < 10'd261) begin	//if within the character box
							if(DRAWX >= 10'd119 && DRAWX < 10'd136 && DRAWY >= 10'd79 && DRAWY < 10'd96) begin
								if(~charIsMoving) begin		//character is not moving
									//Charread_address = ((DRAWY - 229) + direction * 21) * 271 + ((DRAWX - 319) + 16);
									Charread_address = ((DRAWY - 79) + direction * 21) * 271 + ((DRAWX - 119) + 16);
									if(Chardata_Out != 24'hFF00FF) begin	//if not transparent color, draw
										next_pixel 	= 	Chardata_Out;
									end 
									else begin
										next_pixel 	=	FBdata_Out;
									end 
								end 
								else begin
									// Charread_address = ((DRAWY - 229) + direction * 21) * 271 + ((DRAWX - 319) + charMoveFrame * 16 + charIsRunning * 48);
									Charread_address = ((DRAWY - 79) + direction * 21) * 271 + ((DRAWX - 119) + charMoveFrame * 16 + charIsRunning * 48);
									if(Chardata_Out != 24'hFF00FF) begin	
										next_pixel 	= 	Chardata_Out;
									end
									else begin
										next_pixel 	= 	24'h000000;	//CHANGE THIS LATER
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

endmodule


module gameFSM(	input 	logic 			Clk, VGACLK, VGA_VS, Reset,
				input 	logic 	[7:0] 	keycode,
				input 	logic 	[9:0] 	DRAWX, 	DRAWY,
				output 	logic 			charIsMoving, charIsRunning,
				output	logic 	[1:0]	direction, charMoveFrame,
				output 	logic 	[3:0]	state_num
				);

	/*
		direction map:
			0: 	down
			1:	up
			2:	left
			3:	right

		charMoveFrame:
			0, 1, 2 for movement.

		state map:
			0: 	start_screen
			1: 	flash_press_enter
			2: 	fade
			3: 	draw_main_game
			4: 	hold
	*/

	logic 	[1:0]	next_direction;
	logic 	[1:0]	charFrameCounter, next_charFrameCounter;
	logic 	[5:0] 	fade_counter, fade_counter_next;
	logic 	[7:0] 	W 	= 	8'h1A;
    logic 	[7:0] 	A 	= 	8'h04;
    logic 	[7:0] 	S 	= 	8'h16;
    logic 	[7:0] 	D 	= 	8'h07;

	enum logic [3:0] {start_screen, flash_press_enter, fade, draw_main_game, hold} state, next_state;

	always_ff @ (posedge VGA_VS) begin
		if(Reset) begin
			state 			<= 	start_screen;
			fade_counter 	<= 	6'd0;
			direction 		<= 	2'd0;
			charFrameCounter<= 	2'd0; 	
		end 
		else begin
			state 			<= 	next_state;
			fade_counter 	<= 	fade_counter_next;
			direction 		<= 	next_direction;
			charFrameCounter<= 	next_charFrameCounter;
		end 
	end 

	always_comb begin
		next_state 			= 	state;
		unique case (state)
			start_screen 		:	
				if(keycode == 8'h0a) begin
					next_state	= 	fade;
				end 
				else begin
					next_state 	=	flash_press_enter;
				end 
			flash_press_enter 	: 
				if(keycode == 8'h0a) begin
					next_state	= 	fade;
				end 
				else begin
					next_state 	=	start_screen;
				end 
			fade 				:
				if(fade_counter == 6'd50) begin
					next_state 	= 	draw_main_game;
				end 
			draw_main_game 		:
				if(keycode == 8'h1B) begin
					next_state 	=	start_screen;
				end
			hold 				: 	;
		endcase // state
	end 

	always_comb begin
		fade_counter_next 		= 	fade_counter;
		next_charFrameCounter 	= 	charFrameCounter;
		next_direction			= 	direction;
		charIsMoving 			= 	1'b0;
		charIsRunning			= 	1'b0;
		charMoveFrame			= 	2'b00;
		state_num 				= 	4'b0000;
		
		case (state) 
			start_screen		: 	;

			flash_press_enter	:
				begin
					state_num 	= 	4'd1;
				end 

			fade 				:
				begin
					if(fade_counter == 6'd50) begin
						fade_counter_next = 6'd0;
					end 
					else begin
						fade_counter_next = fade_counter + 6'd1;
					end 
					state_num 	= 	4'd2;
				end
			draw_main_game 		: //NEED TO IMPLEMENT RUNNING
				begin
					state_num 	= 	4'd3;
					if(charFrameCounter == 2'd2) begin
						next_charFrameCounter 	= 	2'd0;
					end 
					if(keycode == S) begin
						next_direction 			= 	2'd0;
						charIsMoving 			= 	1'b1;
						charIsRunning			= 	1'b0;
						next_charFrameCounter 	= 	charFrameCounter + 2'd1;
					end 
					else if(keycode == W) begin
						next_direction 			= 	2'd1;
						charIsMoving 			= 	1'b1;
						charIsRunning			= 	1'b0;
						next_charFrameCounter 	= 	charFrameCounter + 2'd1;
					end 
					else if(keycode == A) begin
						next_direction 			= 	2'd2;
						charIsMoving 			= 	1'b1;
						charIsRunning			= 	1'b0;
						next_charFrameCounter 	= 	charFrameCounter + 2'd1;
					end 
					else if(keycode == D) begin
						next_direction 			= 	2'd3;
						charIsMoving 			= 	1'b1;
						charIsRunning			= 	1'b0;
						next_charFrameCounter 	= 	charFrameCounter + 2'd1;
					end 
				end		

			hold 				:	;
		endcase 
	end 
endmodule