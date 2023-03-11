module RX_ParityCheck (
 input  wire       S_BIT,
 input  wire       PAR_Chk_EN,
 input  wire       PAR_TYP,
 input  wire [7:0] P_DATA,
 input  wire       CLK,RST,
 output reg        PAR_ERR
 );
 reg        PAR_BIT ;
 localparam even = 0;
 localparam odd  = 1;
 
 always @ (*)
  begin
   if(PAR_Chk_EN)
    begin
     case(PAR_TYP)
      even: PAR_BIT = ~^(P_DATA) ;
      odd : PAR_BIT =  ^(P_DATA) ;
     endcase
    end
   else
    PAR_BIT = 0 ;
  end
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    PAR_ERR <= 0 ;
   else if(PAR_Chk_EN)
    PAR_ERR <= (S_BIT==PAR_BIT)? 0 : 1 ;
  end 

endmodule