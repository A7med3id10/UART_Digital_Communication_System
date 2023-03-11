`include "rtl/macros.v"
module ALU_TOP 
 (
 input  wire [`OPERAND_WIDTH-1:0] A,B,
 input  wire [3:0]                ALU_FUN,
 input  wire                      CLK,RST,
 input  wire                      Enable,
 output reg  [`RESULT_WIDTH-1:0]  ALU_OUT,
 output wire                      ALU_OUT_Valid,extra_bits
 );
 /* internal signals */
 wire Arith_Enable,Logic_Enable,CMP_Enable,Shift_Enable;
 wire Arith_Flag,Logic_Flag,CMP_Flag,Shift_Flag;
 wire [`RESULT_WIDTH-1:0]  Arith_OUT;
 wire [`OPERAND_WIDTH-1:0] Logic_OUT;
 wire [1:0]                CMP_OUT;
 wire [`OPERAND_WIDTH-1:0] SHIFT_OUT;
 
 assign ALU_OUT_Valid = | {Arith_Flag,Logic_Flag,CMP_Flag,Shift_Flag} ;
 
 always@(posedge CLK)
  begin
   case(ALU_FUN[3:2])
      2'b00: ALU_OUT <= Arith_OUT;
	  2'b01: ALU_OUT <= Logic_OUT;
	  2'b10: ALU_OUT <= CMP_OUT;
	  2'b11: ALU_OUT <= SHIFT_OUT;
   endcase
  end
 
 /* Decoder instantiation */
 Decoder Decoder_U (
 .Enable(Enable),
 .ALU_FUN(ALU_FUN[3:2]),
 .Flags({Arith_Enable,Logic_Enable,CMP_Enable,Shift_Enable})
 );
 
 /* Arithmetic unit instantiation */
 ARITHMETIC ARITHMETIC_U (
 .A(A),
 .B(B),
 .ALU_FUN(ALU_FUN[1:0]),
 .CLK(CLK),
 .RST(RST),
 .Arith_Enable(Arith_Enable),
 .Arith_Flag(Arith_Flag),
 .Arith_OUT(Arith_OUT),
 .extra_bits(extra_bits)
 );
 
 /* Logic unit instantiation */
 LOGIC LOGIC_U (
 .A(A),
 .B(B),
 .ALU_FUN(ALU_FUN[1:0]),
 .CLK(CLK),
 .RST(RST),
 .Logic_Enable(Logic_Enable),
 .Logic_Flag(Logic_Flag),
 .Logic_OUT(Logic_OUT)
 );
 
 /* Compare unit instantiation */
 CMP CMP_U (
 .A(A),
 .B(B),
 .ALU_FUN(ALU_FUN[1:0]),
 .CLK(CLK),
 .RST(RST),
 .CMP_Enable(CMP_Enable),
 .CMP_Flag(CMP_Flag),
 .CMP_OUT(CMP_OUT)
 );
 
 /* Shift unit instantiation */
 SHIFT SHIFT_U (
 .A(A),
 .B(B),
 .ALU_FUN(ALU_FUN[1:0]),
 .CLK(CLK),
 .RST(RST),
 .Shift_Enable(Shift_Enable),
 .SHIFT_Flag(Shift_Flag),
 .SHIFT_OUT(SHIFT_OUT)
 );
 
endmodule                
