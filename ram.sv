/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 * Editor: Eric Dong
 */

// module  CharacterRam
// (
// 		input [23:0] data_In,
// 		input [18:0] write_address, read_address,
// 		input we, Clk,

// 		output logic [23:0] data_Out
// );
// 
// mem has width of 3 bits and a total of 400 addresses
// logic [7:0] mem [0:30351];
// logic [23:0] decoded;

// initial
// begin
// 	 $readmemh("Sprites/Hex_Version/Characters-savedmem.txt", mem);
// end


// always_ff @ (posedge Clk) begin
// 	if (we)
// 		mem[write_address] <= data_In;
// 	data_Out	<=	decoded;
// end

// always_comb begin
// 	unique case(mem[read_address])
// 		8'h00 	: 	decoded	=	24'h000000; 8'h01 	: 	decoded	=	24'h101010;
// 		8'h02 	: 	decoded	=	24'hFFD8CF; 8'h03 	: 	decoded	=	24'hE8E8F8;
// 		8'h04 	: 	decoded	=	24'hFFD8CF; 8'h05 	: 	decoded	=	24'hFFF8FF;
// 		8'h06 	: 	decoded	=	24'hD0D0D8; 8'h07 	: 	decoded	=	24'h8F8890;
// 		8'h08 	: 	decoded	=	24'hCFC8CF; 8'h09 	: 	decoded	=	24'h4F3030;
// 		8'h0A 	: 	decoded	=	24'h784040; 8'h0B 	: 	decoded	=	24'h7F4040;
// 		8'h0C 	: 	decoded	=	24'h682828; 8'h0D 	: 	decoded	=	24'h7F5850;
// 		8'h0E 	: 	decoded	=	24'h90382F; 8'h0F 	: 	decoded	=	24'hAF403F;
// 		8'h10 	: 	decoded	=	24'hC04040; 8'h11 	: 	decoded	=	24'hC03838;
// 		8'h12 	: 	decoded	=	24'hEFA09F; 8'h13 	: 	decoded	=	24'h785850;
// 		8'h14 	: 	decoded	=	24'hC86048; 8'h15 	: 	decoded	=	24'hCF6860;
// 		8'h16 	: 	decoded	=	24'hF86058; 8'h17 	: 	decoded	=	24'hC89070;
// 		8'h18 	: 	decoded	=	24'h501000; 8'h19 	: 	decoded	=	24'hE0B898;
// 		8'h1A 	: 	decoded	=	24'hDF9070; 8'h1B 	: 	decoded	=	24'hE0684F;
// 		8'h1C 	: 	decoded	=	24'hEF7040; 8'h1D 	: 	decoded	=	24'hF86848;
// 		8'h1E 	: 	decoded	=	24'hF87058; 8'h1F 	: 	decoded	=	24'h584028;
// 		8'h20 	: 	decoded	=	24'h886048; 8'h21 	: 	decoded	=	24'hD89070;
// 		8'h22 	: 	decoded	=	24'hA87840; 8'h23 	: 	decoded	=	24'hD8B898;
// 		8'h24 	: 	decoded	=	24'hEFB090; 8'h25 	: 	decoded	=	24'hF0B890;
// 		8'h26 	: 	decoded	=	24'hF8C090; 8'h27 	: 	decoded	=	24'hFFD0B0;
// 		8'h28 	: 	decoded	=	24'h3F381F; 8'h29 	: 	decoded	=	24'hB89858;
// 		8'h2A 	: 	decoded	=	24'hB89838; 8'h2B 	: 	decoded	=	24'hD0B080;
// 		8'h2C 	: 	decoded	=	24'hD8B068; 8'h2D 	: 	decoded	=	24'hF8C058;
// 		8'h2E 	: 	decoded	=	24'hFFD84F; 8'h2F 	: 	decoded	=	24'hFFC86A;
// 		8'h30 	: 	decoded	=	24'hF8D858; 8'h31 	: 	decoded	=	24'hF8D868;
// 		8'h32 	: 	decoded	=	24'hF8E0B0; 8'h33 	: 	decoded	=	24'hFFE080;
// 		8'h34 	: 	decoded	=	24'h306888; 8'h35 	: 	decoded	=	24'h5088B0;
// 		8'h36 	: 	decoded	=	24'h70A0C0; 8'h37 	: 	decoded	=	24'h78B8D8;
// 		8'h38 	: 	decoded	=	24'h50608F; 8'h39 	: 	decoded	=	24'h182850;
// 		8'h3A 	: 	decoded	=	24'h9FB0CF; 8'h3B 	: 	decoded	=	24'h7F88B0;
// 		8'h3C 	: 	decoded	=	24'h383878; 8'h3D 	: 	decoded	=	24'hC0C0D0;
// 		8'h3E 	: 	decoded	=	24'h5860B8; 8'h3F 	: 	decoded	=	24'hB0B0D0;
// 		8'h40 	: 	decoded	=	24'hC0C0D8; 8'h41 	: 	decoded	=	24'h4F485F;
// 		8'h42 	: 	decoded	=	24'h403860; 8'h43 	: 	decoded	=	24'h6F50BF;
// 		8'h44 	: 	decoded	=	24'hA088EF; 8'h45 	: 	decoded	=	24'hFF00FF;
// 		default	: 	decoded	= 	24'hFF00FF;
// 	endcase 
// end 
// endmodule

module  FramebufferRam
(
		input [23:0] data_In,
		input [18:0] write_address, read_address,
		input we, Clk,

		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
	logic [23:0] mem [0:38399];

	initial
	begin
		 $readmemh("Sprites/Hex_Version/start_frame.txt", mem);
	end

	always_ff @ (posedge Clk) begin
		if (we)
			mem[write_address] <= data_In;
		data_Out	<=	mem[read_address];
	end

endmodule


module  GymMapRam
(
		input [23:0] data_In,
		input [18:0] write_address, read_address,
		input we, Clk,

		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [7:0] mem [0:180031];
logic [23:0] decoded;

initial
begin
	 $readmemh("Sprites/Hex_Version/gym_map_whole.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out	<=	decoded;
end

always_comb begin
	unique case(mem[read_address])
		8'h00 	: 	decoded	= 	24'h000000;	8'h01 	: 	decoded	= 	24'hCFF0FF;
		8'h02 	: 	decoded	= 	24'hFFD8FF;	8'h03 	: 	decoded	= 	24'hFFF8FF;
		8'h04 	: 	decoded	= 	24'hB0B0A0;	8'h05 	: 	decoded	= 	24'hDFE0E0;
		8'h06 	: 	decoded	= 	24'h90909F;	8'h07 	: 	decoded	= 	24'h7F7880;
		8'h08 	: 	decoded	= 	24'h7F787F;	8'h09 	: 	decoded	= 	24'hF0A070;
		8'h0A 	: 	decoded	= 	24'hFFE090;	8'h0B  	: 	decoded	= 	24'h40C850;
		8'h0C	: 	decoded	= 	24'hB0F8C0;	8'h0D 	: 	decoded	= 	24'h5090C0;
		8'h0E 	: 	decoded	= 	24'h60C0EF;	8'h0F 	: 	decoded	= 	24'h9FD0FF;
		8'h10 	: 	decoded	= 	24'h8090C0;	8'h11 	: 	decoded	= 	24'h50506F;
		8'h12 	: 	decoded	= 	24'h6F78AF;	8'h13 	: 	decoded	= 	24'h9FA8E0;
		8'h14 	: 	decoded	= 	24'hC0B8D0;	8'h15 	: 	decoded	= 	24'hB088DF;
		8'h16 	: 	decoded	= 	24'hCFA8F0;	8'h17 	: 	decoded	= 	24'hDFC8FF;
		8'h18 	: 	decoded	= 	24'hE088E0;	8'h19 	: 	decoded	= 	24'hB07890;
		default	: 	decoded	= 	24'hFF00FF;
	endcase 
end 

endmodule

module  CharacterRam
(
		input [23:0] data_In,
		input [18:0] write_address, read_address,
		input we, Clk,

		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [23:0] mem [0:30351];

initial
begin
	 $readmemh("Sprites/Hex_Version/Characters.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
