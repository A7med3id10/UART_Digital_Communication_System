module TX_serializer (
 input  wire [7:0] P_DATA,
 input  wire       DATA_VALID,
 input  wire       Busy,
 input  wire       SER_EN,
 input  wire       CLK,RST,
 output reg        SER_DONE,
 output reg        SER_DATA
 );
 
 reg [7:0] shift_register ;
 reg [7:0] done_register  ;
 localparam done = 8'b1000_0000 ;
 
 always @ (posedge CLK , negedge RST)
  begin
   if(!RST)
    begin
	 SER_DONE <= 0 ;
	 SER_DATA <= 0 ;
	 shift_register <= 0 ;
	 done_register  <= 0 ;
	end
   else if(DATA_VALID && !Busy)
    begin
	 shift_register <= P_DATA ;
	 done_register  <= done   ;
	end
   else if(SER_EN && Busy)
    begin
	 {shift_register[6:0], SER_DATA} <= shift_register;
	 {done_register[6:0], SER_DONE}  <= done_register ;
	end
  end

endmodule