module RX_StartCheck (
 input  wire S_BIT,
 input  wire STR_Chk_EN,
 input  wire CLK,RST,
 output reg  STR_ERR
 );
 localparam START_BIT = 1'b0 ;
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    STR_ERR <= 0 ;
   else if(STR_Chk_EN)
    STR_ERR <= (S_BIT==START_BIT)? 0 : 1 ;
  end 

endmodule