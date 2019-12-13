module state_audio (input logic Clk, Reset_h, INIT_FINISH, RUN, data_over,
					input logic [15:0] LC, RC,
					output logic INIT,
					output logic [15:0] LDATA, RDATA
                    );

	enum logic [2:0] {HOLD,START, WRITE, DONE } state, next_state;

	always_ff @ (posedge Clk) begin
		
		if (Reset_h) begin
			state <= START;
		end
		
		else begin
			state <= next_state;
		end
		
	end
							  
	always_comb begin
		
		next_state = state;
		unique case (state)
				HOLD:
						if (RUN) begin
							next_state = START;
						end
						else begin
							next_state = HOLD;
						end
				
				START:
						if (INIT_FINISH) begin
							next_state = WRITE;
						end
						else begin
							next_state = START;
						end
				WRITE:
						if (data_over) begin
							next_state = DONE;
						end
						else begin
							next_state = WRITE;
						end
				
				DONE:
						if (~data_over) begin
							next_state = WRITE;
						end
						else begin
							next_state = DONE;
						end
		endcase
						
	end					  
							  
	always_comb begin 
			INIT = 1'b0;
			LDATA = 16'd0;
			RDATA = 16'd0;
			case(state) 
				HOLD: ;
				
				START: INIT = 1'b1;
				
				WRITE:begin
						 LDATA = LC;
						 RDATA = RC;
						 end
				DONE: ;
			endcase
	end			  
						  
endmodule 