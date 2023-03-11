module Decoder (
 input  wire [1:0] ALU_FUN,
 input  wire       Enable,
 output reg  [3:0] Flags
 );
 
 always @(*)
  begin
   Flags = 4'b0000;
   if(Enable)
    begin
	 case(ALU_FUN)
      2'b00: Flags = 4'b1000;
	  2'b01: Flags = 4'b0100;
	  2'b10: Flags = 4'b0010;
	  2'b11: Flags = 4'b0001;
     endcase
	end
   else
    Flags = 4'b0000;
  end
 
endmodule
