`include "rtl/macros.v"
module SYS_TOP_tb();
 reg  REF_CLK_tb;
 reg  UART_CLK_tb;
 reg  RST_tb;
 reg  RX_IN_tb;
 wire TX_OUT_tb;
 wire TX_Busy_tb;
 
 integer u,i,j,t ;
 reg [10:0] RX_FRAMES [3:0] ;
 reg [10:0] TX_FRAME ;
 parameter IDLE_FRAME = 11'h7ff ;
 
 initial
  begin
  $dumpfile("Digital_System.vcd");     
  $dumpvars; 
  initialize();
  reset();           
  
  $display("Testing ALU (OR) Operation command with operand");
  Receive_Frames(UART_ep(8'hcc),UART_ep(8'd16),UART_ep(8'd14),UART_ep(4'b0101));
  wait(TX_Busy_tb);
  wait(!TX_Busy_tb);
  if ( TX_FRAME==UART_ep(14|16) )
   $display("ALU (OR) Operation with operand PASSED");
  else
   $display("ALU (OR) Operation with operand FAILED");
  
  $display("Testing Register File Write command");
  Receive_Frames(UART_ep(8'haa),UART_ep(4'he),UART_ep(8'h9),IDLE_FRAME);
  $display("Testing Register File Read command");
  Receive_Frames(UART_ep(8'hbb),UART_ep(4'he),IDLE_FRAME,IDLE_FRAME);
  wait(TX_Busy_tb);
  wait(!TX_Busy_tb);
  if ( TX_FRAME==UART_ep(8'h9) )
   $display("Register File Write-Read Operation PASSED");
  else
   $display("Register File Write-Read Operation FAILED");
  
  $display("Testing ALU (-) Operation command with No operand");
  Receive_Frames(UART_ep(8'hdd),UART_ep(4'b0001),IDLE_FRAME,IDLE_FRAME);
  wait(TX_Busy_tb);
  wait(!TX_Busy_tb);
  if ( TX_FRAME==UART_ep(16-14) )
   $display("ALU (-) Operation with No operand PASSED");
  else
   $display("ALU (-) Operation with No operand FAILED");
  
  #10 $finish;
  end 
  
 task initialize;
  begin
   REF_CLK_tb  = 0 ;
   UART_CLK_tb = 0 ;
   RX_IN_tb    = 0 ;
   RST_tb      = 1 ;
  end
 endtask
  
 task reset;
  begin
   RST_tb = 0 ;
   #(`UART_CLK_PERIOD);
   RST_tb = 1 ;
   #(`UART_CLK_PERIOD*4);
  end
 endtask
 
 function [10:0] UART_ep;
  input [7:0] Data ;
  reg   [7:0] data ;
  begin
   for(u=7 ; u>-1 ; u=u-1)
    begin
	 data[u] = Data[7-u]; 
	end
   UART_ep = {1'b0,data,~^(Data),1'b1};
  end
 endfunction
 
 task Receive_Frames;
  input [10:0] Frame0,Frame1,Frame2,Frame3;
  begin
   RX_FRAMES[0] = Frame0 ;
   RX_FRAMES[1] = Frame1 ;
   RX_FRAMES[2] = Frame2 ;
   RX_FRAMES[3] = Frame3 ;
   for (j=0 ; j<4 ; j=j+1)
    begin
	 for (i=10 ; i>-1 ; i=i-1)
      begin
	   if(RX_FRAMES[j]==IDLE_FRAME)
	    i=0;  //RX_IN_tb = 1 ;  // j=j+1 ; i=11; //
	   else
	    begin
		 RX_IN_tb = RX_FRAMES[j][i]   ;
	     #(`UART_CLK_PERIOD*`Division_ratio) ; 
		end
      end
	end
  end
 endtask
  
 always @ (posedge TX_Busy_tb)
  begin
   $display("Test_TX_Frame");
   for (t=10 ; t>-1 ; t=t-1)
    begin
	 #(`UART_CLK_PERIOD*`Division_ratio) ;
     TX_FRAME[t] = TX_OUT_tb ;
    end
  end
 
 always #(`REF_CLK_PERIOD/2)  REF_CLK_tb  = ~ REF_CLK_tb  ;
 always #(`UART_CLK_PERIOD/2) UART_CLK_tb = ~ UART_CLK_tb ;
 
 SYS_TOP DUT (
 .REF_CLK(REF_CLK_tb),
 .UART_CLK(UART_CLK_tb),
 .RST(RST_tb),
 .RX_IN(RX_IN_tb),
 .TX_OUT(TX_OUT_tb),
 .TX_Busy(TX_Busy_tb)
 );

endmodule
