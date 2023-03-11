`include "rtl/macros.v"
module LOGIC
 (
 input  wire [`OPERAND_WIDTH-1:0] A,B,
 input  wire [1:0]                ALU_FUN,
 input  wire                      CLK,RST,
 input  wire                      Logic_Enable,
 output reg                       Logic_Flag,
 output reg  [`OPERAND_WIDTH-1:0] Logic_OUT
 );
 
 always @(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 Logic_OUT  <=  'b0 ;
	 Logic_Flag <= 1'b0 ;
    end
   else
    begin
	 Logic_Flag <= Logic_Enable ;
	 if(Logic_Enable)
      begin
       case(ALU_FUN)
        2'b00 : Logic_OUT <=   A & B  ;
        2'b01 : Logic_OUT <=   A | B  ;
	    2'b10 : Logic_OUT <= ~(A & B) ;
	    2'b11 : Logic_OUT <= ~(A | B) ;
       endcase
      end
    end
  end 
 		
endmodule
