module RST_SYNC 
 #(parameter NUM_STAGES = 2 )
 ( 
 input  wire RST,
 input  wire CLK,
 output wire SYNC_RST
 );
 
 wire [NUM_STAGES-2:0] connection  ;
 
 genvar i ;
 
 generate
  for (i=0 ; i<NUM_STAGES ; i=i+1)
   begin
    if(i==0)
	 DFF #(.BUS_WIDTH(1)) Ui ( .D(1'b1),               .CLK(CLK), .RST(RST), .Q(connection[i]) );
	else if(i==NUM_STAGES-1)
	 DFF #(.BUS_WIDTH(1)) Ui ( .D(connection[i-1]), .CLK(CLK), .RST(RST), .Q(SYNC_RST)       );
	else 
	 DFF #(.BUS_WIDTH(1)) Ui ( .D(connection[i-1]), .CLK(CLK), .RST(RST), .Q(connection[i]) );
	 
   end
 endgenerate
 
endmodule