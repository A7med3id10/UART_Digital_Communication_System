module UART_RX_TOP (
 input  wire       RX_IN,
 input  wire [4:0] PRESCALE,
 input  wire       PAR_EN,PAR_TYP,
 input  wire       CLK,RST,
 output wire [7:0] P_DATA,
 output wire       DATA_VALID
 );
 /* Internal Signals */
 wire [3:0] BIT_COUNT;
 wire [4:0] EDGE_COUNT;
 wire       STR_ERR   ,PAR_ERR   ,STP_ERR;
 wire       STR_Chk_EN,PAR_Chk_EN,STP_Chk_EN;
 wire       DISER_EN, COUNTER_EN, SAMPLE_EN;
 wire       S_BIT,sample_done;
 
 /* Modules Instantiation */
 RX_FSM U0_RX_FSM (
 .RX_IN(RX_IN),
 .PAR_EN(PAR_EN),
 .PRESCALE(PRESCALE),
 .CLK(CLK),
 .RST(RST),
 .BIT_COUNT(BIT_COUNT),
 .EDGE_COUNT(EDGE_COUNT),
 .sample_done(sample_done),
 .STR_ERR(STR_ERR),
 .PAR_ERR(PAR_ERR),
 .STP_ERR(STP_ERR),
 .STR_Chk_EN(STR_Chk_EN),
 .PAR_Chk_EN(PAR_Chk_EN),
 .STP_Chk_EN(STP_Chk_EN),
 .DISER_EN(DISER_EN), 
 .COUNTER_EN(COUNTER_EN), 
 .SAMPLE_EN(SAMPLE_EN),
 .DATA_VALID(DATA_VALID)
 );
 
 RX_Deserializer U0_RX_Deserializer (
 .S_BIT(S_BIT),
 .DISER_EN(DISER_EN),
 .BIT_COUNT(BIT_COUNT),
 .CLK(CLK),
 .RST(RST),
 .P_DATA(P_DATA)
 );
 
 RX_DataSampling U0_RX_DataSampling (
 .RX_IN(RX_IN),
 .PRESCALE(PRESCALE),
 .CLK(CLK),
 .RST(RST),
 .EDGE_COUNT(EDGE_COUNT),
 .SAMPLE_EN(SAMPLE_EN),
 .S_BIT(S_BIT),
 .sample_done(sample_done)
 );
 
 RX_EdgeBitCounter U0_RX_EdgeBitCounter (
 .COUNTER_EN(COUNTER_EN),
 .PRESCALE(PRESCALE),
 .CLK(CLK),
 .RST(RST),
 .BIT_COUNT(BIT_COUNT),
 .EDGE_COUNT(EDGE_COUNT)
 );
 
 RX_StartCheck U0_RX_StartCheck (
 .S_BIT(S_BIT),
 .STR_Chk_EN(STR_Chk_EN),
 .CLK(CLK),
 .RST(RST),
 .STR_ERR(STR_ERR)
 );
 
 RX_ParityCheck U0_RX_ParityCheck (
 .S_BIT(S_BIT),
 .PAR_Chk_EN(PAR_Chk_EN),
 .PAR_TYP(PAR_TYP),
 .P_DATA(P_DATA),
 .CLK(CLK),
 .RST(RST),
 .PAR_ERR(PAR_ERR)
 );
 
 RX_StopCheck U0_RX_StopCheck (
 .S_BIT(S_BIT),
 .STP_Chk_EN(STP_Chk_EN),
 .CLK(CLK),
 .RST(RST),
 .STP_ERR(STP_ERR)
 );
 
endmodule