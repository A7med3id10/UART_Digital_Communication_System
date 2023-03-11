module TX_parity (
 input  wire [7:0] P_DATA,
 input  wire       DATA_VALID,
 input  wire       PAR_EN,PAR_TYP,
 input  wire       CLK,RST,
 output reg        PAR_BIT
 );
 
 localparam even = 0;
 localparam odd  = 1;
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 PAR_BIT <= 0;
	end
   else if(PAR_EN && DATA_VALID) 
    begin
	 case(PAR_TYP)
	  even: PAR_BIT <= ~^(P_DATA) ;
	  odd : PAR_BIT <=  ^(P_DATA) ;
	 endcase
	end
  end
 
endmodule