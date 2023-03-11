`include "rtl/macros.v"
module SYS_TOP(
 input  wire REF_CLK,
 input  wire UART_CLK,
 input  wire RST,
 input  wire RX_IN,
 output wire TX_OUT,TX_Busy
 );      
 
 wire [`RESULT_WIDTH-1:0]  ALU_OUT;
 wire [3:0]                ALU_FUN;
 wire [`OPERAND_WIDTH-1:0] RF_RdData,RF_WrData;
 wire [`OPERAND_WIDTH-1:0] Op_A,Op_B,UART_Config,Div_Ratio;
 wire [`RF_Addr_WIDTH-1:0] RF_Addr;
 wire [7:0]                RX_P_DATA,TX_P_DATA,RX_P_DATA_SYNC,TX_P_DATA_SYNC;
 wire ALU_OUT_Valid,ALU_extra_bits,ALU_EN,CLK_GATE_EN;
 wire RF_WrEn,RF_RdEn,RF_RdData_Valid;
 wire ALU_CLK,TX_CLK;
 wire RX_D_Valid,RX_D_Valid_SYNC,TX_D_Valid,TX_DATA_OK,TX_DATA_OK_SYNC,TX_D_Valid_SYNC,TX_Busy_SYNC;
 wire REF_RST,UART_RST;
 
 SYS_CTRL U0_SYS_CTRL (
 .CLK(REF_CLK), 
 .RST(REF_RST), 
 .ALU_OUT(ALU_OUT), 
 .ALU_OUT_Valid(ALU_OUT_Valid), 
 .ALU_extra_bits(ALU_extra_bits),
 .ALU_FUN(ALU_FUN), 
 .ALU_EN(ALU_EN), 
 .CLK_GATE_EN(CLK_GATE_EN), 
 .RF_RdData(RF_RdData), 
 .RF_RdData_Valid(RF_RdData_Valid),
 .RF_Addr(RF_Addr), 
 .RF_WrEn(RF_WrEn),   
 .RF_RdEn(RF_RdEn),   
 .RF_WrData(RF_WrData), 
 .RX_P_DATA(RX_P_DATA_SYNC), 
 .RX_D_Valid(RX_D_Valid_SYNC),  
 .TX_Busy(TX_Busy_SYNC),
 .TX_DATA_OK(TX_DATA_OK_SYNC), 
 .TX_P_DATA(TX_P_DATA), 
 .TX_D_Valid(TX_D_Valid) 
 );
 
 UART_RX_TOP U0_RX (
 .RX_IN(RX_IN),
 .PRESCALE(UART_Config[6:2]),
 .PAR_EN(UART_Config[0]),
 .PAR_TYP(UART_Config[1]),
 .CLK(UART_CLK),
 .RST(UART_RST),
 .P_DATA(RX_P_DATA),
 .DATA_VALID(RX_D_Valid)
 );
 
 UART_TX_TOP U0_TX (
 .P_DATA(TX_P_DATA_SYNC),
 .DATA_VALID(TX_D_Valid_SYNC),
 .PAR_EN(UART_Config[0]),
 .PAR_TYP(UART_Config[1]),
 .CLK(TX_CLK),
 .RST(UART_RST),
 .TX_OUT(TX_OUT),
 .DATA_OK(TX_DATA_OK),
 .BUSY(TX_Busy)
 );
 
 Register_File U0_RF (
 .WrData(RF_WrData),
 .Address(RF_Addr),
 .WrEn(RF_WrEn),
 .RdEn(RF_RdEn),
 .CLK(REF_CLK),
 .RST(REF_RST),
 .RdData(RF_RdData),
 .REG0(Op_A),
 .REG1(Op_B),
 .REG2(UART_Config),
 .REG3(Div_Ratio),
 .RdData_Valid(RF_RdData_Valid)
 );
 
 ALU_TOP U0_ALU (
 .A(Op_A),
 .B(Op_B),
 .ALU_FUN(ALU_FUN),
 .CLK(ALU_CLK),
 .RST(REF_RST),
 .Enable(ALU_EN),
 .ALU_OUT(ALU_OUT),
 .extra_bits(ALU_extra_bits),
 .ALU_OUT_Valid(ALU_OUT_Valid)
 );
 
 Clock_Divider U0_CLK_Div (
 .I_ref_clk(UART_CLK),
 .I_rst_n(UART_RST),
 .I_clk_en(1'b1),
 .I_div_ratio(Div_Ratio[3:0]),
 .O_div_clk(TX_CLK) 
 );
 
 CLK_GATE U0_CLK_GATE (
 .CLK_EN(CLK_GATE_EN),
 .CLK(REF_CLK),
 .GATED_CLK(ALU_CLK)
 );
 
 RST_SYNC RST_DOMAIN1 (
 .RST(RST),
 .CLK(REF_CLK),
 .SYNC_RST(REF_RST)
 );
 
 RST_SYNC RST_DOMAIN2 (
 .RST(RST),
 .CLK(UART_CLK),
 .SYNC_RST(UART_RST)
 );
 
 DATA_SYNC RX_TO_CTRL (
 .UNSYNC_BUS(RX_P_DATA),
 .BUS_ENABLE(RX_D_Valid),
 .CLK(REF_CLK),
 .RST(REF_RST),
 .SYNC_BUS(RX_P_DATA_SYNC),
 .ENABLE_PULSE(RX_D_Valid_SYNC)
 );
 
 DATA_SYNC CTRL_TO_TX (
 .UNSYNC_BUS(TX_P_DATA),
 .BUS_ENABLE(TX_D_Valid),
 .CLK(TX_CLK),
 .RST(UART_RST),
 .SYNC_BUS(TX_P_DATA_SYNC),
 .ENABLE_PULSE(TX_D_Valid_SYNC)
 );
 
 BIT_SYNC #(.BUS_WIDTH(2))
 TX_TO_CTRL ( 
 .ASYNC({TX_Busy,TX_DATA_OK}),
 .CLK(REF_CLK),
 .RST(REF_RST),
 .SYNC({TX_Busy_SYNC,TX_DATA_OK_SYNC})
 );
 
endmodule