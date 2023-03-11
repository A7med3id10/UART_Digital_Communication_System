module UART_TX_TOP (
 input  wire [7:0] P_DATA,
 input  wire       DATA_VALID,
 input  wire       PAR_EN,PAR_TYP,
 input  wire       CLK,RST,
 output wire       TX_OUT, 
 output wire       BUSY,DATA_OK
 );
 
 /* Internal Signals */
 wire Busy;
 wire START_BIT,SER_DATA,PAR_BIT,STOP_BIT;
 wire SER_EN,SER_DONE;
 wire [1:0] MUX_SEL;
 
 assign START_BIT = 1'b0 ;
 assign STOP_BIT  = 1'b1 ;
 
 /* Modules Instantiation */
 TX_parity U0_parity(
 .P_DATA(P_DATA),
 .DATA_VALID(DATA_VALID),
 .PAR_EN(PAR_EN),
 .PAR_TYP(PAR_TYP),
 .CLK(CLK),
 .RST(RST),
 .PAR_BIT(PAR_BIT)
 );
 
 TX_serializer U0_serializer (
 .P_DATA(P_DATA),
 .DATA_VALID(DATA_VALID),
 .Busy(Busy),
 .SER_EN(SER_EN),
 .CLK(CLK),
 .RST(RST),
 .SER_DONE(SER_DONE),
 .SER_DATA(SER_DATA)
 );
 
 TX_FSM U0_FSM(
 .DATA_VALID(DATA_VALID),
 .PAR_EN(PAR_EN),
 .SER_DONE(SER_DONE),
 .CLK(CLK),
 .RST(RST),
 .Busy(Busy),
 .DATA_OK(DATA_OK),
 .MUX_SEL(MUX_SEL),
 .SER_EN(SER_EN)
 );
 
 TX_mux U0_mux (
 .MUX_SEL(MUX_SEL),
 .Busy(Busy),
 .START_BIT(START_BIT),
 .STOP_BIT(STOP_BIT),
 .SER_DATA(SER_DATA),
 .PAR_BIT(PAR_BIT),
 .CLK(CLK),
 .RST(RST),
 .TX_OUT(TX_OUT),
 .BUSY(BUSY)
 );
 
endmodule
