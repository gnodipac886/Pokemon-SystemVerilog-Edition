/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 * Editor: Eric Dong
 */

module  CharacterRam
(
		input [23:0] data_In,
		input [18:0] write_address, read_address,
		input we, Clk,

		output logic [23:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [23:0] mem [0:54599];

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
