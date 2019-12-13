module testmodule(	input 	logic 			Clk, VGA_CLK, DrawEn, Reset, 
					input 	logic 			charIsMoving, charIsRunning,
					input	logic 	[1:0]	direction, charMoveFrame,
					input 	logic 	[3:0]	state_num,
					input 	logic 	[7:0] 	keycode,
					output 	logic       	VGA_HS, VGA_VS,
					output 	logic 	[9:0] 	DRAWX, DRAWY,
					output 	logic       	VGA_BLANK_N, VGA_SYNC_N,
					output 	logic 	[7:0] 	R, G, B,
					output 	logic 	[9:0]	charxcurrpos, charycurrpos,
					output 	logic 			atTile);
	frameDrawer fbint(.*);
	VGA_controller vgaint(.*, .DrawX(DRAWX), .DrawY(DRAWY));
endmodule