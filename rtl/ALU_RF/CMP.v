`include "rtl/macros.v"
module CMP
 (
 input  wire [`OPERAND_WIDTH-1:0] A,B,
 input  wire [1:0]                ALU_FUN,
 input  wire                      CLK,RST,
 input  wire                      CMP_Enable,
 output reg                       CMP_Flag,
 output reg  [1:0]                CMP_OUT
 );
 		
 always @(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 CMP_OUT  <=  'b0 ;
	 CMP_Flag <= 1'b0 ;
    end
   else 
    begin
	 CMP_Flag <= CMP_Enable ;
     if(CMP_Enable)
      begin
       case(ALU_FUN)
        2'b00 :
		 begin
		  CMP_OUT  <= 0 ;
		  CMP_Flag <= 0 ;  // No operation
		 end
        2'b01 : CMP_OUT <= (A==B)? 1 : 0 ;
	    2'b10 : CMP_OUT <= (A>B) ? 2 : 0 ;
	    2'b11 : CMP_OUT <= (A<B) ? 3 : 0 ;
       endcase
      end
	end
  end 
 		
endmodule
