module DATA_SYNC 
 #(parameter BUS_WIDTH  = 8 ,
   parameter NUM_STAGES = 2 )
 (
 input  wire [BUS_WIDTH-1:0] UNSYNC_BUS,
 input  wire                 BUS_ENABLE,
 input  wire                 CLK,
 input  wire                 RST,
 output reg  [BUS_WIDTH-1:0] SYNC_BUS,
 output reg                  ENABLE_PULSE
 );
 
 /* Internal Signals */
 wire sync_enable, pulse;
 reg  Qpulse;
 
 /* Multi FF */
 BIT_SYNC 
 #(.BUS_WIDTH(1),.NUM_STAGES(NUM_STAGES))
 Multi_FF ( 
 .ASYNC(BUS_ENABLE), 
 .CLK(CLK), 
 .RST(RST),
 .SYNC(sync_enable) 
 );
 
 /* Pulse Gen */
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    Qpulse <= 0 ;
   else
    Qpulse <= sync_enable ;
  end
  
 assign pulse = sync_enable & ~Qpulse ;
 
 
 /* SYNC_BUS , ENABLE_PULSE */
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 SYNC_BUS     <= 0 ;
	 ENABLE_PULSE <= 0 ;
	end
   else
    begin
	 SYNC_BUS     <= (pulse)? UNSYNC_BUS : SYNC_BUS ;
	 ENABLE_PULSE <=  pulse ;
	end
  end

endmodule
