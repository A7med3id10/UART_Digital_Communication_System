module CLK_GATE (
 input  wire CLK_EN,
 input  wire CLK,
 output wire GATED_CLK
 );

//internal connections
reg     Latch_Out ;

//latch (Level Sensitive Device)
always @(CLK or CLK_EN)
 begin
  if(!CLK)      // active low
   begin
    Latch_Out <= CLK_EN ;
   end
 end
 
 
// ANDING
assign  GATED_CLK = CLK && Latch_Out ;

endmodule