module RX_FSM (
 input  wire       RX_IN,
 input  wire       PAR_EN,
 input  wire [4:0] PRESCALE,
 input  wire       CLK,RST,
 input  wire [3:0] BIT_COUNT,
 input  wire [4:0] EDGE_COUNT,
 input  wire       sample_done,
 input  wire       STR_ERR   ,PAR_ERR   ,STP_ERR,
 output reg        STR_Chk_EN,PAR_Chk_EN,STP_Chk_EN,
 output reg        DISER_EN, COUNTER_EN, SAMPLE_EN,
 output reg        DATA_VALID
 );
 /* Moore Finite State Machine */
 reg [7:0] current_state, next_state ;
 /* One-Hot Encoding */
 localparam IDLE              = 8'b00000001 ,
            Start_Sampling    = 8'b00000010 ,
			Deserialization   = 8'b00000100 ,
			Continue_Sampling = 8'b00001000 ,
			Finish_Sampling   = 8'b00010000 ,
			Check_Parity      = 8'b00100000 ,
			Check_Stop        = 8'b01000000 ,
			Validate          = 8'b10000000 ;
 
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
   IDLE              : next_state = (RX_IN) ? IDLE : Start_Sampling ;
 
   Start_Sampling    : next_state = (!sample_done) ? Start_Sampling :
                                    (STR_ERR)? IDLE : Continue_Sampling ;
   
   Continue_Sampling : next_state = (!sample_done)? Continue_Sampling :
                                    (BIT_COUNT<=9)? Deserialization   :            	
   									(!sample_done)? Continue_Sampling : Finish_Sampling   ;
  
   Deserialization   : next_state = Continue_Sampling ;
   
   Finish_Sampling   : next_state = (PAR_EN)? Check_Parity : Check_Stop ;
									
   Check_Parity      : next_state = (PAR_ERR)? IDLE : 
                                    (!sample_done)? Check_Parity : Check_Stop ;
                                   
   Check_Stop        : next_state = (STP_ERR) ? IDLE : Validate ;
                                    
   Validate          : next_state = Start_Sampling ;
  endcase
  end
  
 /* Outputs Block */
 always @ (*)
 begin
  STR_Chk_EN = 0 ;
  PAR_Chk_EN = 0 ;
  STP_Chk_EN = 0 ;
  DISER_EN   = 0 ;
  COUNTER_EN = 0 ;
  SAMPLE_EN  = 0 ;
  DATA_VALID = 0 ;
  
   case(current_state)
    IDLE              : begin
	                     STR_Chk_EN = 0 ;
						 PAR_Chk_EN = 0 ;
						 STP_Chk_EN = 0 ;
	                     DISER_EN   = 0 ;
						 COUNTER_EN = 0 ;
						 SAMPLE_EN  = 0 ;
						 DATA_VALID = 0 ;
	                    end
    Start_Sampling    : begin
                         STR_Chk_EN = 1 ;
                         PAR_Chk_EN = 0 ;
                         STP_Chk_EN = 0 ;
                         DISER_EN   = 0 ;
                         COUNTER_EN = 1 ;
                         SAMPLE_EN  = 1 ;
                         DATA_VALID = 0 ;
                        end
	Continue_Sampling : begin
	                     STR_Chk_EN = 0 ;
	                     PAR_Chk_EN = 0 ;
	                     STP_Chk_EN = 0 ;
	                     DISER_EN   = 0 ;
	                     COUNTER_EN = 1 ;
	                     SAMPLE_EN  = 1 ;
	                     DATA_VALID = 0 ;
	                    end
	Deserialization   : begin
	                     STR_Chk_EN = 0 ;
	                     PAR_Chk_EN = 0 ;
	                     STP_Chk_EN = 0 ;
	                     DISER_EN   = 1 ;
	                     COUNTER_EN = 1 ;
	                     SAMPLE_EN  = 1 ;
	                     DATA_VALID = 0 ;
	                    end	
	Finish_Sampling : begin
	                     STR_Chk_EN = 0 ;
	                     PAR_Chk_EN = 1 ;
	                     STP_Chk_EN = 1 ;
	                     DISER_EN   = 0 ;
	                     COUNTER_EN = 1 ;
	                     SAMPLE_EN  = 1 ;
	                     DATA_VALID = 0 ;
	                    end   
	Check_Parity      : begin
                         STR_Chk_EN = 0 ;
                         PAR_Chk_EN = 0 ;
                         STP_Chk_EN = 1 ;
                         DISER_EN   = 0 ;
                         COUNTER_EN = 1 ;
                         SAMPLE_EN  = 1 ;
                         DATA_VALID = 0 ;
                        end
	Check_Stop        : begin
	                     STR_Chk_EN = 0 ;
	                     PAR_Chk_EN = 0 ;
	                     STP_Chk_EN = 1 ;
	                     DISER_EN   = 0 ;
	                     COUNTER_EN = 0 ;
	                     SAMPLE_EN  = 0 ;
	                     DATA_VALID = 0 ;
	                    end
	Validate          : begin
	                     STR_Chk_EN = 0 ;
	                     PAR_Chk_EN = 0 ;
	                     STP_Chk_EN = 0 ;
	                     DISER_EN   = 0 ;
	                     COUNTER_EN = 1 ;
	                     SAMPLE_EN  = 1 ;
	                     DATA_VALID = 1 ;
	                    end
   endcase
  end
  
endmodule
