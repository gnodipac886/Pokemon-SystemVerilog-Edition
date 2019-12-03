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
	logic 	[4:0]	tilecounter, next_tilecounter;
	logic 	[5:0]	charFrameCounter, next_charFrameCounter;
	logic 	[5:0] 	fade_counter, fade_counter_next;
	logic 	[7:0] 	W 	= 	8'h1A;
    logic 	[7:0] 	A 	= 	8'h04;
    logic 	[7:0] 	S 	= 	8'h16;
    logic 	[7:0] 	D 	= 	8'h07;

	enum logic [3:0] {start_screen, flash_press_enter, fade, draw_main_game, hold} state, next_state;

	always_ff @ (posedge VGA_VS) begin
		if(Reset) begin
			//state 			<= 	start_screen;
			state 			<= 	start_screen;
			fade_counter 	<= 	6'd0;
			direction 		<= 	2'd0;
			charFrameCounter<= 	6'd0; 
			tilecounter 	<= 	5'd0;	
		end 
		else begin
			state 			<= 	next_state;
			fade_counter 	<= 	fade_counter_next;
			direction 		<= 	next_direction;
			charFrameCounter<= 	next_charFrameCounter;
			tilecounter 	<= 	next_tilecounter;
		end 
	end 

	always_comb begin
		next_state 			= 	state;
		unique case (state)
			start_screen 		:	
				if(keycode == 8'h28) begin
					next_state	= 	fade;
				end 
				else begin
					next_state 	=	start_screen;
				end 
			flash_press_enter 	: 
				if(keycode == 8'h28) begin
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
				if(keycode == 8'h29) begin
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
		next_tilecounter 		= 	tilecounter;
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
					if (tilecounter != 5'd31) begin		//doing this for the character to walk in blocks of 16
						next_direction			= 	direction;
						charIsMoving 			= 	1'b1;
						next_charFrameCounter 	= 	charFrameCounter + 6'd1;
						next_tilecounter 		= 	tilecounter + 5'd1;
					end
					else begin
						next_tilecounter 		= 	5'd0;
						unique case (keycode)
							S 		: 	begin
											if(direction == 2'd0) begin
												next_direction 			= 	direction;
												charIsMoving 			= 	1'b1;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	charFrameCounter + 6'd1;
											end 
											else begin
												next_direction 			= 	2'd0;
												charIsMoving 			= 	1'b0;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	6'd0;
												next_tilecounter 		= 	5'd31;
											end 
										end 

							W 		: 	begin
											if(direction == 2'd1) begin
												next_direction 			= 	direction;
												charIsMoving 			= 	1'b1;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	charFrameCounter + 6'd1;
											end 
											else begin
												next_direction 			= 	2'd1;
												charIsMoving 			= 	1'b0;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	6'd0;
												next_tilecounter 		= 	5'd31;
											end 
										end 

							A 		: 	begin
											if(direction == 2'd2) begin
												next_direction 			= 	direction;
												charIsMoving 			= 	1'b1;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	charFrameCounter + 6'd1;
											end 
											else begin
												next_direction 			= 	2'd2;
												charIsMoving 			= 	1'b0;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	6'd0;
												next_tilecounter 		= 	5'd31;
											end 
										end 

							D 		: 	begin
											if(direction == 2'd3) begin
												next_direction 			= 	direction;
												charIsMoving 			= 	1'b1;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	charFrameCounter + 6'd1;
											end 
											else begin
												next_direction 			= 	2'd3;
												charIsMoving 			= 	1'b0;
												charIsRunning			= 	1'b0;
												next_charFrameCounter 	= 	6'd0;
												next_tilecounter 		= 	5'd31;
											end 
										end 

							default : 	;
						endcase // keycode
					end 
					if(charFrameCounter < 6'd10) begin
						charMoveFrame = 2'd0;
					end
					else if(charFrameCounter < 6'd20) begin
						charMoveFrame = 2'd1;
					end 
					else if(charFrameCounter < 6'd30) begin
						charMoveFrame = 2'd2;
					end 
					else if(charFrameCounter < 6'd40) begin
						charMoveFrame = 2'd1;
					end 
					if(charFrameCounter == 6'd39) begin
						next_charFrameCounter 	= 	6'd0;
					end 
				end		

			hold 				:	;
		endcase 
	end 
endmodule

/*
						if(keycode == S) begin
							next_direction 			= 	2'd0;
							charIsMoving 			= 	1'b1;
							charIsRunning			= 	1'b0;
							next_charFrameCounter 	= 	charFrameCounter + 6'd1;
						end 
						else if(keycode == W) begin
							next_direction 			= 	2'd1;
							charIsMoving 			= 	1'b1;
							charIsRunning			= 	1'b0;
							next_charFrameCounter 	= 	charFrameCounter + 6'd1;
						end 
						else if(keycode == A) begin
							next_direction 			= 	2'd2;
							charIsMoving 			= 	1'b1;
							charIsRunning			= 	1'b0;
							next_charFrameCounter 	= 	charFrameCounter + 6'd1;
						end 
						else if(keycode == D) begin
							next_direction 			= 	2'd3;
							charIsMoving 			= 	1'b1;
							charIsRunning			= 	1'b0;
							next_charFrameCounter 	= 	charFrameCounter + 6'd1;
						end */