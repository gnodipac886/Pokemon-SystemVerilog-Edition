module gymTileLogic (	input 	logic 			Clk, 		Reset,		VGA_VS,//should be VGA_VS
						input	logic	[9:0] 	xright, 	ybottom,
						output 	logic 			atTile,
						output 	logic 	[1:0] 	spin_direction,
						output 	logic 	[9:0]	xleft_next_out,	ytop_next_out
						);
	//need a FSM here to make sure player doesn't glitch on tiles forever

	/*
		direction map:
			0: 	down
			1:	up
			2:	left
			3:	right
	*/
	enum 	logic [2:0] {notTile, prespin, teleport, postspin, latch, hold} state, next_state;

	logic 			isOnTile;
	logic 	[9:0]	xleft, 	ytop, 	xleft_next,		ytop_next;
	logic 	[5:0] 	spinCounter, next_spinCounter; 

	logic 	[9:0]	X 	[5:0];	//	= 	{10'd15, 10'd143, 10'd207, 10'd271, 10'd335, 10'd463};
	logic 	[9:0]	Y 	[5:0];	//	= 	{10'd79, 10'd127, 10'd207, 10'd255, 10'd335, 10'd383};
	logic 	[9:0]	X35				=	10'd303;
	// logic 	[1:0]	[9:0]	AX, BX, CX, DX, EX, FX, GX, HX, IX, JX, KX, LX, MX;
	// logic 	[1:0]	[9:0]	AY, BY, CY, DY, EY, FY, GY, HY, IY, JY, KY, LY, MY;
	logic 	[19:0]			A1, A2, B1, B2, C1, C2, D1, D2, E1, E2, F1, F2, G1, 
							G2, H1, H2, I1, I2, J1, J2, K1, K2, L1, L2, M1, M2, currxy;

	always_ff @ (posedge VGA_VS) begin
		if(Reset) begin
			state 		<= 	notTile;
			spinCounter <= 	5'd0;
			xleft 		<= 	10'd0;
			ytop 		<= 	10'd0;
		end 
		else begin
			state 		<= 	next_state;
			spinCounter <= 	next_spinCounter;
			xleft 		<= 	xleft_next;
			ytop 		<= 	ytop_next;
		end 
	end 

	always_comb begin
		currxy 	= 	{xright, ybottom};
		X[0] 	= 	10'd15;
		X[1] 	= 	10'd143;
		X[2] 	= 	10'd207;
		X[3] 	= 	10'd271;
		X[4] 	= 	10'd335;
		X[5] 	= 	10'd463;
		Y[0]	=	10'd79;
		Y[1]	=	10'd127;
		Y[2]	=	10'd207;
		Y[3]	=	10'd255;
		Y[4]	=	10'd335;
		Y[5]	=	10'd383;
		A1 	= 	{X35 , Y[4]};	//room 8	START
		A2 	= 	{X[5], Y[5]};	//room 9 
		B1 	= 	{X[5], Y[2]};	//room 6
		B2 	= 	{X[5], Y[4]};	//room 9 
		C1 	= 	{X[5], Y[0]};	//room 3
		C2 	= 	{X[4], Y[4]};	//room 9 
		D1 	= 	{X[1], Y[4]};	//room 7
		D2 	= 	{X[4], Y[5]};	//room 9 
		E1 	= 	{X[0], Y[2]};	//room 4
		E2 	= 	{X[5], Y[3]};	//room 6 
		F1 	= 	{X[4], Y[0]};	//room 3
		F2 	= 	{X[4], Y[2]};	//room 6 
		G1 	= 	{X[2], Y[0]};	//room 2
		G2 	= 	{X[4], Y[3]};	//room 6 
		H1 	= 	{X[5], Y[1]};	//room 3
		H2 	= 	{X[0], Y[4]};	//room 7 
		I1 	= 	{X[0], Y[0]};	//room 1
		I2 	= 	{X[4], Y[1]};	//room 3 
		J1 	= 	{X[1], Y[0]};	//room 1
		J2 	= 	{X[3], Y[0]};	//room 2 
		K1 	= 	{X[3], Y[1]};	//room 2
		K2 	= 	{X[0], Y[5]};	//room 7 
		L1 	= 	{X[2], Y[1]};	//room 2
		L2 	= 	{X[1], Y[2]};	//room 4 
		M1 	= 	{X[0], Y[1]};	//room 1
		M2 	= 	{X35 , Y[3]};	//room 5	FINISH 
		next_state 	= 	state;
		isOnTile 	= 	1'b0;
		if(	{xright, ybottom} == A1 || {xright, ybottom} == A2 || {xright, ybottom} == B1 || 
			{xright, ybottom} == B2 || {xright, ybottom} == C1 || {xright, ybottom} == C2 || 
			{xright, ybottom} == D1 || {xright, ybottom} == D2 || {xright, ybottom} == E1 || 
			{xright, ybottom} == E2 || {xright, ybottom} == F1 || {xright, ybottom} == F2 || 
			{xright, ybottom} == G1 || {xright, ybottom} == G2 || {xright, ybottom} == H1 || 
			{xright, ybottom} == H2 || {xright, ybottom} == I1 || {xright, ybottom} == I2 || 
			{xright, ybottom} == J1 || {xright, ybottom} == J2 || {xright, ybottom} == K1 || 
			{xright, ybottom} == K2 || {xright, ybottom} == L1 || {xright, ybottom} == L2 || 
			{xright, ybottom} == M1 || {xright, ybottom} == M2) begin
			isOnTile 	= 	1'b1;
		end 
		
		unique case (state)
			notTile	: 	begin
							if(isOnTile) begin		//if it is on a tile  @@IMPLEMENT
								next_state 	= 	prespin;
							end 
						end 

			prespin	: 	begin
							if(spinCounter == 5'd39) begin
								next_state 		= 	teleport;
							end
						end 

			teleport: 	begin
							next_state 	= 	postspin;
						end 

			postspin: 	begin
							if(spinCounter == 5'd39) begin
								next_state 		= 	latch;
							end
						end 

			latch 	: 	begin
							if(~VGA_VS) begin		//IMPLEMENT WHEN CHARACTER LEAVES TILE
								next_state 	= 	hold;
							end 
						end

			hold 	: 	begin
							if(~isOnTile) begin
								next_state 	=	notTile;
							end 
						end  


			default : 	;
		endcase

	end 

	always_comb begin
		xleft_next 			= 	xleft;
		ytop_next 			= 	ytop;
		atTile 				= 	1'b0;
		next_spinCounter 	= 	spinCounter;
		spin_direction 		= 	2'd0;
		unique case (state)
			notTile	: 	begin
							xleft_next 	= 	xright;
							ytop_next 	= 	ybottom;
						end 

			prespin	: 	begin
							atTile 	= 	1'b1;
							xleft_next 	= 	xright;
							ytop_next 	= 	ybottom;
							if(spinCounter 	< 	5'd10) begin
								spin_direction 	= 	2'd0;
							end 
							else if(spinCounter	< 	5'd20) begin
								spin_direction 	= 	2'd1;
							end 
							else if(spinCounter	< 	5'd30) begin
								spin_direction 	= 	2'd2;
							end 
							else if(spinCounter	< 	5'd40) begin
								spin_direction 	= 	2'd3; 
							end 
							if(spinCounter == 5'd39) begin
								next_spinCounter= 	5'd0;
							end
							else begin
								next_spinCounter= 	spinCounter + 5'd1;
							end 
						end 

			teleport: 	begin
							atTile 	= 	1'b1;
							unique case(currxy)
								A1	:	begin
											xleft_next 	= 	A2[19:10];
											ytop_next 	= 	A2[9:0];
										end
								A2	:	begin
											xleft_next 	= 	A1[19:10];
											ytop_next 	= 	A1[9:0];
										end
								B1	:	begin
											xleft_next 	= 	B2[19:10];
											ytop_next 	= 	B2[9:0];
										end
								B2	:	begin
											xleft_next 	= 	B1[19:10];
											ytop_next 	= 	B1[9:0];
										end
								C1	:	begin
											xleft_next 	= 	C2[19:10];
											ytop_next 	= 	C2[9:0];
										end
								C2	:	begin
											xleft_next 	= 	C1[19:10];
											ytop_next 	= 	C1[9:0];
										end
								D1	:	begin
											xleft_next 	= 	D2[19:10];
											ytop_next 	= 	D2[9:0];
										end
								D2	:	begin
											xleft_next 	= 	D1[19:10];
											ytop_next 	= 	D1[9:0];
										end
								E1	:	begin
											xleft_next 	= 	E2[19:10];
											ytop_next 	= 	E2[9:0];
										end
								E2	:	begin
											xleft_next 	= 	E1[19:10];
											ytop_next 	= 	E1[9:0];
										end
								F1	:	begin
											xleft_next 	= 	F2[19:10];
											ytop_next 	= 	F2[9:0];
										end
								F2	:	begin
											xleft_next 	= 	F1[19:10];
											ytop_next 	= 	F1[9:0];
										end
								G1	:	begin
											xleft_next 	= 	G2[19:10];
											ytop_next 	= 	G2[9:0];
										end
								G2	:	begin
											xleft_next 	= 	G1[19:10];
											ytop_next 	= 	G1[9:0];
										end
								H1	:	begin
											xleft_next 	= 	H2[19:10];
											ytop_next 	= 	H2[9:0];
										end
								H2	:	begin
											xleft_next 	= 	H1[19:10];
											ytop_next 	= 	H1[9:0];
										end
								I1	:	begin
											xleft_next 	= 	I2[19:10];
											ytop_next 	= 	I2[9:0];
										end
								I2	:	begin
											xleft_next 	= 	I1[19:10];
											ytop_next 	= 	I1[9:0];
										end
								J1	:	begin
											xleft_next 	= 	J2[19:10];
											ytop_next 	= 	J2[9:0];
										end
								J2	:	begin
											xleft_next 	= 	J1[19:10];
											ytop_next 	= 	J1[9:0];
										end
								K1	:	begin
											xleft_next 	= 	K2[19:10];
											ytop_next 	= 	K2[9:0];
										end
								K2	:	begin
											xleft_next 	= 	K1[19:10];
											ytop_next 	= 	K1[9:0];
										end
								L1	:	begin
											xleft_next 	= 	L2[19:10];
											ytop_next 	= 	L2[9:0];
										end
								L2	:	begin
											xleft_next 	= 	L1[19:10];
											ytop_next 	= 	L1[9:0];
										end
								M1	:	begin
											xleft_next 	= 	M2[19:10];
											ytop_next 	= 	M2[9:0];
										end
								M2	:	begin
											xleft_next 	= 	M1[19:10];
											ytop_next 	= 	M1[9:0];
										end
								default :	begin
												xleft_next 	= 	0;
												ytop_next 	= 	0;
											end 
							endcase
						end 

			postspin: 	begin
							atTile 	= 	1'b1;
							if(spinCounter 	< 	5'd4) begin
								spin_direction 	= 	2'd0;
							end 
							else if(spinCounter	< 	5'd8) begin
								spin_direction 	= 	2'd1;
							end 
							else if(spinCounter	< 	5'd12) begin
								spin_direction 	= 	2'd2;
							end 
							else if(spinCounter	< 	5'd20) begin
								spin_direction 	= 	2'd3; 
							end 
							if(spinCounter == 5'd19) begin
								next_spinCounter= 	5'd0;
							end
							else begin
								next_spinCounter= 	spinCounter + 5'd1;
							end 
						end 

			latch	: 	begin
							atTile 	= 	1'b1;
						end 

			hold 	: 	begin
							atTile 	= 	1'b0;
						end 

			default : 	;
		endcase

		xleft_next_out	= 	xleft 	- 	10'd15;
		ytop_next_out 	= 	ytop 	- 	10'd20;
	end 

endmodule

/*
	 AX 	= 	{X35, X[5]};	//rooms 8, 9 
	 AY 	= 	{Y[4], Y[5]};	//rooms 8, 9 
	 BX 	= 	{X[5], X[5]};	//rooms 6, 9 
	 BY 	= 	{Y[2], Y[4]};	//rooms 6, 9 
	 CX 	= 	{X[5], X[4]};	//rooms 3, 9 
	 CY 	= 	{Y[0], Y[4]};	//rooms 3, 9 
	 DX 	= 	{X[1], X[4]};	//rooms 7, 9 
	 DY 	= 	{Y[4], Y[5]};	//rooms 7, 9 
	 EX 	= 	{X[0], X[5]};	//rooms 4, 6 
	 EY 	= 	{Y[2], Y[3]};	//rooms 4, 6 
	 FX 	= 	{X[4], X[4]};	//rooms 3, 6 
	 FY 	= 	{Y[0], Y[2]};	//rooms 3, 6 
	 GX 	= 	{X[2], X[4]};	//rooms 2, 6 
	 GY 	= 	{Y[0], Y[3]};	//rooms 2, 6 
	 HX 	= 	{X[5], X[0]};	//rooms 3, 7 
	 HY 	= 	{Y[1], Y[4]};	//rooms 3, 7 
	 IX 	= 	{X[0], X[4]};	//rooms 1, 3 
	 IY 	= 	{Y[0], Y[1]};	//rooms 1, 3 
	 JX 	= 	{X[1], X[3]};	//rooms 1, 2 
	 JY 	= 	{Y[0], Y[0]};	//rooms 1, 2 
	 KX 	= 	{X[3], X[0]};	//rooms 2, 7 
	 KY 	= 	{Y[1], Y[5]};	//rooms 2, 7 
	 LX 	= 	{X[2], X[1]};	//rooms 2, 4 
	 LY 	= 	{Y[1], Y[2]};	//rooms 2, 4 
	 MX 	= 	{X[0], X35};	//rooms 1, 5 
	 MY 	= 	{Y[1], Y[3]};	//rooms 1, 5 
*/
