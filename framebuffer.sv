module frameBuffer(	input 	logic 	Clk, VGACLK, DrawEn,
					input 	logic 	[9:0] DRAWX, DRAWY,
					input 	logic 	[1:0] playerDir,
					output 	logic 	[7:0] R, G, B
					);

	logic [23:0] FBdata_In, FBdata_Out;
	logic [23:0] Chardata_Out;
	logic [18:0] FBwrite_address, FBread_address;
	logic [18:0] Charread_address;
	logic FBwe, Charwe;

	always_comb begin
		FBread_address = (DRAWY / 2) * 240 + (DRAWX / 2);
		if(DRAWX < 9'd480 && DRAWY < 9'd320) begin
			R 	= 	FBdata_Out[23:16];
			G 	= 	FBdata_Out[15:8];
			B 	= 	FBdata_Out[7:0];
		end 
		else begin
			R 	= 	8'h00;
			G 	= 	8'h00;
			B 	= 	8'hff;
		end 

		/*color test
		R 	= 	8'hff;
		G 	= 	8'hff;
		B 	= 	8'h00;
		*/
	end 

	FramebufferRam FBRam(
							.data_In(FBdata_In),
							.write_address(FBwrite_address),
							.read_address(FBread_address),
							.we(FBwe),
							.Clk(Clk),
							.data_Out(FBdata_Out)
						);

	CharacterRam CharRam(
							.data_In(24'd0),
							.write_address(19'd0),
							.read_address(Charread_address),
							.we(1'b0),
							.Clk(Clk),
							.data_Out(Chardata_Out)
						);

endmodule