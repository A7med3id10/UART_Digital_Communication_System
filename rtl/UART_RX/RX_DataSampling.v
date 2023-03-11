module RX_DataSampling (
 input  wire       RX_IN,
 input  wire [4:0] PRESCALE,
 input  wire       CLK,RST,
 input  wire [4:0] EDGE_COUNT,
 input  wire       SAMPLE_EN,
 output reg        S_BIT,
 output reg        sample_done
 );
 /* PRESCALE can be 4, 8, 16, or 32 */
 
 reg [2:0] sampled_bits;
 
 /* Oversampling */
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
     sampled_bits <= 0 ;
	 sample_done  <= 0 ;
	end
   else if(SAMPLE_EN)
    begin
	 case(EDGE_COUNT)
	  (PRESCALE/2)-1 :
	   begin
	    sampled_bits[0] <= RX_IN ;
		sample_done     <= 0 ;
	   end
	  (PRESCALE/2) :
	   begin
	    sampled_bits[1] <= RX_IN ;
		sample_done     <= 0 ;
	   end
	  (PRESCALE/2)+1 : 
	   begin
	    sampled_bits[2] <= RX_IN ;
		sample_done     <= 1 ;
	   end
	  default: sample_done <= 0 ;
	 endcase
	end
  end
  
  /* Sample bit is the mojor bit */
 always @ (*)
  begin
   case(sampled_bits)
	3'b000 : S_BIT = 0 ;
	3'b001 : S_BIT = 0 ;
	3'b010 : S_BIT = 0 ;
	3'b011 : S_BIT = 1 ;
	3'b100 : S_BIT = 0 ;
	3'b101 : S_BIT = 1 ;
	3'b110 : S_BIT = 1 ;
	3'b111 : S_BIT = 1 ;
   endcase
  end

endmodule