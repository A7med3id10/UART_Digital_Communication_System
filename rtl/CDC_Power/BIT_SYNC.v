module BIT_SYNC 
 #(parameter BUS_WIDTH  = 1 ,
   parameter NUM_STAGES = 2 )
 (
 input  wire [BUS_WIDTH-1:0]  ASYNC,
 input  wire                  CLK,
 input  wire                  RST,
 output wire [BUS_WIDTH-1:0]  SYNC
 );
 
 wire [BUS_WIDTH-1:0] connection [NUM_STAGES-2:0] ;
 
 genvar i ;
 
 generate
  for (i=0 ; i<NUM_STAGES ; i=i+1)
   begin
    if(i==0)
	 DFF #(.BUS_WIDTH(BUS_WIDTH)) Ui ( .D(ASYNC),           .CLK(CLK), .RST(RST), .Q(connection[i]) );
	else if(i==NUM_STAGES-1)
	 DFF #(.BUS_WIDTH(BUS_WIDTH)) Ui ( .D(connection[i-1]), .CLK(CLK), .RST(RST), .Q(SYNC)          );
	else 
	 DFF #(.BUS_WIDTH(BUS_WIDTH)) Ui ( .D(connection[i-1]), .CLK(CLK), .RST(RST), .Q(connection[i]) );
   end
 endgenerate
 
endmodule
