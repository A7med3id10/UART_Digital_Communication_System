`include "rtl/macros.v"
module ARITHMETIC
 (
 input  wire [`OPERAND_WIDTH-1:0] A,B,
 input  wire [1:0]                ALU_FUN,
 input  wire                      CLK,RST,
 input  wire                      Arith_Enable,
 output reg                       Arith_Flag,
 output reg  [`RESULT_WIDTH-1:0]  Arith_OUT,
 output wire                      extra_bits
 );
    
 assign extra_bits = (Arith_Enable)? |(Arith_OUT[`RESULT_WIDTH-1:`OPERAND_WIDTH]) : 0 ;
 
 always @(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 Arith_OUT  <= 0 ;
	 Arith_Flag <= 0 ;
    end
   else   
    begin
	 Arith_Flag <= Arith_Enable ;
     if(Arith_Enable)
      begin
       case(ALU_FUN)
        2'b00 : Arith_OUT <= A + B ;
        2'b01 : Arith_OUT <= A - B ;
	    2'b10 : Arith_OUT <= A * B ;
	    2'b11 : Arith_OUT <= A / B ;
       endcase 
      end
	end
  end 
 		
endmodule
