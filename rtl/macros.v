`timescale 1ns / 1ps            
`define    OPERAND_WIDTH        8
`define    RESULT_WIDTH         2*(`OPERAND_WIDTH)
`define    RF_DEPTH             16
`define    RF_Addr_WIDTH        $clog2(`RF_DEPTH)
`define    REF_CLK_PERIOD       20
`define    UART_CLK_PERIOD      104166
`define    ALU_Op_A_Addr        0
`define    ALU_Op_B_Addr        1
`define    UART_Config_Addr     2
`define    Div_Ratio_Addr       3
`define    Division_ratio       8
`define    Even_Parity          0
`define    Odd_Parity           1
`define    UART_Parity_Enable   1
`define    UART_Parity_Type     `Even_Parity
`define    UART_RX_Prescale     `Division_ratio
