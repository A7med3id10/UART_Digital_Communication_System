module TX_FSM (
 input  wire       DATA_VALID,
 input  wire       PAR_EN,
 input  wire       SER_DONE,
 input  wire       CLK,RST,
 output reg        Busy,
 output reg  [1:0] MUX_SEL,
 output reg        SER_EN,
 output reg        DATA_OK
 );
 
 /* Moore Finite State Machine */
 reg [5:0] current_state, next_state ;
 /* One-Hot Encoding */
 localparam IDLE                = 6'b000001 ,
            Receive_Data        = 6'b000010 ,
			Start_Transmission  = 6'b000100 ,
			Data_Transmission   = 6'b001000 ,
			Parity_Transmission = 6'b010000 ,
			End_Transmission    = 6'b100000 ;

 /* Current State Block */
 always @ (posedge CLK, negedge RST)
  begin
   if (!RST)
    current_state <= IDLE ;
   else
    current_state <= next_state ;
  end
 
 /* Next State Block */
 always @ (*)
  begin
   next_state = IDLE ;
   case(current_state)
    IDLE                : next_state = (DATA_VALID)? Receive_Data : IDLE ;             
	Receive_Data        : next_state = Start_Transmission ;          
	Start_Transmission  : next_state = Data_Transmission  ;   
	Data_Transmission   : begin
	                       if(!SER_DONE)
						    next_state = Data_Transmission  ;
						   else
						    next_state = (PAR_EN)? Parity_Transmission : End_Transmission ;   
                          end	
	Parity_Transmission : next_state = End_Transmission ;   
	End_Transmission    : next_state = IDLE ;
   endcase
  end
 
 /* Output Block */
 always @ (*)
  begin
   Busy    = 0 ;
   MUX_SEL = 0 ;
   SER_EN  = 0 ;
   DATA_OK = 0 ;
   case(current_state)
    IDLE                : begin
	                       Busy    = 0 ;
						   MUX_SEL = 0 ;
						   SER_EN  = 0 ;
	                      end
						  
	Receive_Data        : begin 
	                       Busy    = 0 ;
                           MUX_SEL = 0 ;
                           SER_EN  = 0 ;
						   DATA_OK = 1 ;
                          end
	
	Start_Transmission  : begin
	                       Busy    = 1 ;
	                       MUX_SEL = 2'b00 ;
	                       SER_EN  = 1 ;
	                      end
	
	Data_Transmission   : begin
	                       Busy    = 1 ;
	                       MUX_SEL = 2'b01 ;
	                       SER_EN  = 1 ;
	                      end
	
	Parity_Transmission : begin
	                       Busy    = 1 ;
	                       MUX_SEL = 2'b10 ;
	                       SER_EN  = 0 ;
	                      end
	
	End_Transmission    : begin
	                       Busy    = 1 ;
	                       MUX_SEL = 2'b11 ;
	                       SER_EN  = 0 ;
	                      end
	
   endcase
  end

endmodule
