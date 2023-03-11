module RX_StopCheck (
 input  wire S_BIT,
 input  wire STP_Chk_EN,
 input  wire CLK,RST,
 output reg  STP_ERR
 );
 localparam STOP_BIT  = 1'b1 ;
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    STP_ERR <= 0 ;
   else if(STP_Chk_EN)
    STP_ERR <= (S_BIT==STOP_BIT)? 0 : 1 ;
  end 

endmodule