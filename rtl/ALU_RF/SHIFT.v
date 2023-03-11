`include "rtl/macros.v"
module SHIFT
 (
 input  wire [`OPERAND_WIDTH-1:0] A,B,
 input  wire [1:0]                ALU_FUN,
 input  wire                      CLK,RST,
 input  wire                      Shift_Enable,
 output reg                       SHIFT_Flag,
 output reg  [`OPERAND_WIDTH-1:0] SHIFT_OUT
 );
  	
 always @(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 SHIFT_OUT  <=  'b0 ;
	 SHIFT_Flag <= 1'b0 ;
    end
   else
    begin
	 SHIFT_Flag <= Shift_Enable ;
	 if(Shift_Enable)
      begin
       case(ALU_FUN)
        2'b00 : SHIFT_OUT <= A >> 1 ;
        2'b01 : SHIFT_OUT <= A << 1 ;
	    2'b10 : SHIFT_OUT <= B >> 1 ;
	    2'b11 : SHIFT_OUT <= B << 1 ;
       endcase
      end
    end
  end 

endmodule
