module RX_EdgeBitCounter (
 input  wire       COUNTER_EN,
 input  wire [4:0] PRESCALE,
 input  wire       CLK,RST,
 output reg  [3:0] BIT_COUNT,
 output reg  [4:0] EDGE_COUNT
 );
 
 /*Edges Counter*/
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    EDGE_COUNT <= 0 ;
   else if (COUNTER_EN)
    begin
	 if(EDGE_COUNT==PRESCALE)
	  EDGE_COUNT <= 1 ;
	 else
	  EDGE_COUNT <= EDGE_COUNT + 1 ;
	end
   else
    EDGE_COUNT <= 0 ;
  end
  
  /*Bits Counter*/
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    BIT_COUNT <= 0 ;
   else if (COUNTER_EN)
    begin
	 if(EDGE_COUNT==PRESCALE)
	  BIT_COUNT <= BIT_COUNT + 1 ;
	end
   else
    BIT_COUNT <= 1 ;
  end

endmodule