module RX_Deserializer (
 input  wire       S_BIT,DISER_EN,
 input  wire [3:0] BIT_COUNT,
 input  wire       CLK,RST,
 output reg  [7:0] P_DATA
 );
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST) 
    P_DATA <= 0 ;
   else if(DISER_EN)
    P_DATA[BIT_COUNT-2] <= S_BIT ;
  end
 
endmodule