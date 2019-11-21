module frameBuffer(	input logic Clk, VGACLK, DrawEn,
					input logic DRAWX, DRAWY,
					input logic [1:0] playerDir,
					output R, G, B
					)

	logic [] frame;

endmodule










module direction( input logic clk,                // 50 MHz clock
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [7:0]	 keycode,			 // keyboard input
               output logic  playerDir             // current player direction
              );
			
logic frame_clk_delayed, frame_clk_rising_edge;

    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	 
always_comb begin
	 if (frame_clk_rising_edge)	 begin
		if(keycode == 	W) begin
			playerDir = 2'b00;
		end
		if (keycode == A ) begin
			playerDir = 2'b01;
		end
		if (keycode == S ) begin
			playerDir = 2'b10;
		end
		
		if (keycode == D ) begin
			playerDir = 2'b11;
		end
end 
	 
end




			
endmodule 