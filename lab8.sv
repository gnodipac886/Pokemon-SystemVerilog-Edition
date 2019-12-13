//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
             input logic 		 AUD_ADCDAT,
			 output logic		 AUD_XCK,
								 AUD_DACDAT,
								 I2C_SDAT,
								 I2C_SCLK,
			 inout wire 		 AUD_BCLK,
								 AUD_ADCLRCK,
								 AUD_DACLRCK
                    );
    
    logic Reset_h, Reset_ball, Clk;
    logic 	[7:0] 	keycode;
    logic 	[9:0] 	DrawX, DrawY;
    logic 	[9:0]	charxcurrpos, charycurrpos;

    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
   VGA_controller vga_controller_instance(  .Clk(Clk),
											.Reset(Reset_h),
											.VGA_HS(VGA_HS),
											.VGA_VS(VGA_VS),
											.VGA_CLK(VGA_CLK),
											.VGA_BLANK_N(VGA_BLANK_N),
											.VGA_SYNC_N(VGA_SYNC_N),
											.DrawX(DrawX),
											.DrawY(DrawY)
											);

	logic 			charIsMoving;
	logic 	[1:0]  	direction, charMoveFrame;
	logic 	[3:0]	state_num;

	logic 	[3:0]	testState;
	assign 	testState = (~KEY[2]) 	?	4'd3 	: 	4'd0;

	logic 	atTile;
   frameDrawer fdinstance(  .Clk(Clk), 
							.VGA_CLK(VGA_CLK), 
							.VGA_VS(VGA_VS),
							.DrawEn(1'b1),
							.Reset(Reset_h),
							.charIsMoving(charIsMoving), 
							.charIsRunning(~KEY[1]), //change back!
							.direction(direction),
							.charMoveFrame(charMoveFrame),
							.state_num(state_num),
							.DRAWX(DrawX), 
							.DRAWY(DrawY),
							.keycode(keycode),
							.R(VGA_R), 
							.G(VGA_G), 
							.B(VGA_B),
							.charxcurrpos(charxcurrpos),
							.charycurrpos(charycurrpos),
							.atTile(atTile)
							);

   gameFSM gameInstance(    .Clk(Clk),
							.VGACLK(VGACLK),
							.VGA_VS(VGA_VS),
							.Reset(Reset_h),
							.keycode(keycode),
							.DRAWX(DrawX),
							.DRAWY(DrawY),
							.charIsMoving(charIsMoving),
							.PLAY(PLAY),
							.charIsRunning(~KEY[2]),
							.direction(direction),
							.charMoveFrame(charMoveFrame),
							.state_num(state_num)
							);    

 //   Audio_Controller testaud(
	// // Inputs
	// .CLOCK_50(Clk),
	// .reset(Reset_h),
	// .left_channel_audio_out(LC),
	// .right_channel_audio_out(RC),
	// .write_audio_out(audio_out_allowed),
	// .AUD_ADCDAT(AUD_ADCDAT),
	// // Bidirectionals
	// .AUD_BCLK(AUD_BCLK),
	// .AUD_ADCLRCK(AUD_ADCLRCK),
	// .AUD_DACLRCK(AUD_DACLRCK),
	// .audio_out_allowed(audio_out_allowed),
	// .AUD_XCK(AUD_XCK),
	// .AUD_DACDAT(AUD_DACDAT)
	// );

 //   logic 	[15:0]	LC, RC;
 //   logic 	[31:0]	test;
 //   logic 			PLAY, audio_out_allowed;
 //   tenseAudioRam tenseInst(.*);
/*
   logic 			INIT_FINISH, data_over, INIT;
   logic 			RUN = 1'b1;
   logic 	[15:0] 	LDATA, RDATA;
   state_audio 	audiostateinst(.*, .LC(test), .RC(test));

   audio_interface audio(LDATA, RDATA,	//:      IN std_logic_vector(15 downto 0); -- parallel external data inputs
						Clk, Reset, INIT, //: IN std_logic; 
						INIT_FINISH, //:				OUT std_logic;
						adc_full, //:			OUT std_logic;
						data_over, //:          OUT std_logic; -- sample sync pulse
						AUD_XCK, //:             OUT std_logic; -- Codec master clock OUTPUT
						AUD_BCLK, //:             IN std_logic; -- Digital Audio bit clock
						AUD_ADCDAT, //:			IN std_logic;
						AUD_DACDAT, //:           OUT std_logic; -- DAC data line
						AUD_DACLRCK, AUD_ADCLRCK, //:          IN std_logic; -- DAC data left/right select
						I2C_SDAT, //:             OUT std_logic; -- serial interface data line
						I2C_SCLK, //:             OUT std_logic;  -- serial interface clock
						ADCDATA); //: 				OUT std_logic_vector(31 downto 0))
*/
    // Display keycode on hex display
    HexDriver hex_inst_0 ((charycurrpos % 10), HEX0);
    HexDriver hex_inst_1 (((charycurrpos % 100) / 10), HEX1);
    HexDriver hex_inst_2 ((charycurrpos / 100), HEX2);
    HexDriver hex_inst_3 ((charxcurrpos % 10), HEX3);
    HexDriver hex_inst_4 (((charxcurrpos % 100) / 10), HEX4);
    HexDriver hex_inst_5 ((charxcurrpos / 100), HEX5);
    HexDriver hex_inst_6 (atTile, HEX6);
    HexDriver hex_inst_7 (keycode[7:4], HEX7);
endmodule
