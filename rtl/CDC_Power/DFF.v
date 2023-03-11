module DFF 
#(parameter BUS_WIDTH  = 1)
(
 input  wire [BUS_WIDTH-1:0] D,
 input  wire                 CLK,
 input  wire                 RST,
 output reg  [BUS_WIDTH-1:0] Q
 );
 
 always @ (posedge CLK, negedge RST)
  begin
   if(!RST)
    Q <= 0 ;
   else
    Q <= D ;
  end

endmodule