module TX_mux (
 input  wire [1:0] MUX_SEL,
 input  wire       Busy,
 input  wire       START_BIT,
 input  wire       SER_DATA,
 input  wire       PAR_BIT,
 input  wire       STOP_BIT,
 input  wire       CLK,RST,
 output reg        TX_OUT,BUSY
 );
 
 /* st b0->b7 pt sp */
 
 always @ (posedge CLK , negedge RST)
  begin
   if(!RST)
    begin
	 TX_OUT <= 1 ;
	 BUSY   <= 0 ;
    end
   else if(Busy) 
    begin
	 BUSY   <= 1 ;
     case(MUX_SEL)
	  2'b00:   TX_OUT <= START_BIT;
	  2'b01:   TX_OUT <= SER_DATA ;
	  2'b10:   TX_OUT <= PAR_BIT  ;
	  2'b11:   TX_OUT <= STOP_BIT ;
	 endcase
    end
   else
    begin
	 TX_OUT <= 1 ;
	 BUSY   <= 0 ;
	end
  end

endmodule
