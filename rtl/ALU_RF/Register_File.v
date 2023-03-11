`include "rtl/macros.v"
module Register_File (
 input  wire [`OPERAND_WIDTH-1:0] WrData,
 input  wire [`RF_Addr_WIDTH-1:0] Address,
 input  wire                      WrEn,RdEn,
 input  wire                      CLK,RST,
 output reg  [`OPERAND_WIDTH-1:0] RdData,
 output wire [`OPERAND_WIDTH-1:0] REG0,REG1,REG2,REG3,
 output reg                       RdData_Valid
 );
 
 reg [`OPERAND_WIDTH-1:0] Reg_File [`RF_DEPTH-1:0] ;
 integer i ;
 
 assign REG0 = Reg_File[`ALU_Op_A_Addr];  
 assign REG1 = Reg_File[`ALU_Op_B_Addr];
 assign REG2 = Reg_File[`UART_Config_Addr];
 assign REG3 = Reg_File[`Div_Ratio_Addr];
		
 always @(posedge CLK, negedge RST)
  begin
   if(!RST)
    begin
	 Reg_File[`ALU_Op_A_Addr]         <= 0 ;  
	 Reg_File[`ALU_Op_B_Addr]         <= 0 ;
	 Reg_File[`UART_Config_Addr][0]   <= `UART_Parity_Enable;
	 Reg_File[`UART_Config_Addr][1]   <= `UART_Parity_Type;
	 Reg_File[`UART_Config_Addr][6:2] <= `UART_RX_Prescale;
	 Reg_File[`Div_Ratio_Addr]        <= `Division_ratio ;
	 RdData_Valid <= 0 ;
	 for(i=4;i<`RF_DEPTH;i=i+1)
	  begin
	   Reg_File[i] <= 0 ;
	  end
	end
   else if(WrEn & !RdEn)
    begin
	 Reg_File[Address] <= WrData ;
	 RdData_Valid <= 0 ;
    end
   else if(RdEn & !WrEn)
    begin
	 RdData       <= Reg_File[Address] ;
	 RdData_Valid <= 1 ;
    end
   else
    RdData_Valid <= 0 ;
  end

endmodule
