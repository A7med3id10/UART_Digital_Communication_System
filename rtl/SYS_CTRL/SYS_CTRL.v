`include "rtl/macros.v"
module SYS_CTRL (
 input  wire                      CLK, 
 input  wire                      RST, 
 
 input  wire [`RESULT_WIDTH-1:0]  ALU_OUT, 
 input  wire                      ALU_OUT_Valid,
 input  wire                      ALU_extra_bits, 
 
 output reg  [3:0]                ALU_FUN, 
 output reg                       ALU_EN, 
 output reg                       CLK_GATE_EN, 
 
 input  wire [`OPERAND_WIDTH-1:0] RF_RdData, 
 input  wire                      RF_RdData_Valid,
 
 output reg  [`RF_Addr_WIDTH-1:0] RF_Addr, 
 output reg                       RF_WrEn,   
 output reg                       RF_RdEn,   
 output reg  [`OPERAND_WIDTH-1:0] RF_WrData, 
 
 input  wire [7:0]                RX_P_DATA, 
 input  wire                      RX_D_Valid,  
 
 input  wire                      TX_Busy, TX_DATA_OK, 
 
 output reg  [7:0]                TX_P_DATA, 
 output reg                       TX_D_Valid
 );
 reg [7:0] CMD;
 //reg [`OPERAND_WIDTH-1:0] Op_A,Op_B;
 reg [`RESULT_WIDTH:0]  ALU_result;
 reg [`OPERAND_WIDTH-1:0] reg_read;
 reg start_transmission,end_transmission;
  
 /* Moore Finite State Machine RX Mode */
 reg [3:0] RX_current_state, RX_next_state ;
 /* Moore Finite State Machine TX Mode */
 reg [1:0] TX_current_state, TX_next_state ;
 /* Gray Encoding */
 localparam IDLE_RX         =  4'b0000 ,
            What_is_CMD     =  4'b0001 ,
            ALU_OPS_CMD     =  4'b0011 ,
			Wr_A            =  4'b0010 ,
			Wr_B            =  4'b0110 ,
			Operate_ALU     =  4'b0111 ,
			Result_ALU      =  4'b0101 ,     
            RF_Wr_CMD       =  4'b0100 ,
			Check_Address   =  4'b1100 ,
			Wr_DATA_TO_RF   =  4'b1101 ,
			RF_Rd_CMD       =  4'b1111 ,
			Rd_DATA_FROM_RF =  4'b1110 ,
			ALU_NO_OPS_CMD  =  4'b1010 ,
			Start_TX        =  4'b1011 ;
			
 localparam IDLE_TX           =  2'b00 ,
            Send_ALU_LSresult =  2'b01 ,
			Send_ALU_MSresult =  2'b11 ,
			Send_RegRead      =  2'b10 ;
	
 /* Current State Block */
 always @ (posedge CLK, negedge RST)
  begin
   if (!RST)
    begin
     RX_current_state <= IDLE_RX ;
	 TX_current_state <= IDLE_TX ;
	end
   else
    begin
     RX_current_state <= RX_next_state ;
	 TX_current_state <= TX_next_state ;
	end
  end
  
 /* Next State Block */
 always@(*)
  begin
   RX_next_state = IDLE_RX ;
   TX_next_state = IDLE_TX ;
   case(RX_current_state)
    IDLE_RX: 
     begin
      RX_next_state = (RX_D_Valid)? What_is_CMD : IDLE_RX ;
     end
	 
	What_is_CMD:
	 begin
	  case(RX_P_DATA)
 	   8'hAA:   RX_next_state = RF_Wr_CMD ;
 	   8'hBB:   RX_next_state = RF_Rd_CMD ;
 	   8'hCC:   RX_next_state = ALU_OPS_CMD ;
 	   8'hDD:   RX_next_state = ALU_NO_OPS_CMD ;
 	   default: RX_next_state = IDLE_RX ;
 	  endcase
	 end
 	   
    RF_Wr_CMD:      RX_next_state = (RX_D_Valid)? Check_Address : RF_Wr_CMD ;
				  	 		   
	RF_Rd_CMD:      RX_next_state = (RX_D_Valid)? Check_Address : RF_Rd_CMD ;
				    
	ALU_OPS_CMD: RX_next_state = Wr_A ; 
	
	ALU_NO_OPS_CMD: RX_next_state = Operate_ALU  ;
	
	Check_Address:
	 begin
	  if( (RX_P_DATA > 'h3) && (RX_P_DATA < `RF_DEPTH) )
	   begin
	    case(CMD)
		 8'hAA: RX_next_state   = Wr_DATA_TO_RF   ;
		 8'hBB: RX_next_state   = Rd_DATA_FROM_RF ;
		 default: RX_next_state = IDLE_RX ;
		endcase
	   end
	  else
	   RX_next_state = IDLE_RX ;
	 end
	 
	Wr_DATA_TO_RF:   RX_next_state = (RX_D_Valid)? IDLE_RX : Wr_DATA_TO_RF ;
      
	Rd_DATA_FROM_RF: RX_next_state = (RF_RdData_Valid)? Start_TX : Rd_DATA_FROM_RF ;
	
	Wr_A: RX_next_state = (RX_D_Valid)? Wr_B        : Wr_A ;
		  
	Wr_B: RX_next_state = (RX_D_Valid)? Operate_ALU : Wr_B ;
	
	Operate_ALU: RX_next_state = (RX_D_Valid)? Result_ALU : Operate_ALU ;
	
	Result_ALU: RX_next_state = (ALU_OUT_Valid)? Start_TX : Result_ALU ;
	
	Start_TX:
	 begin
	  case({RX_D_Valid,end_transmission})
	   2'b00:   RX_next_state = Start_TX ;
	   2'b01:   RX_next_state = IDLE_RX  ;
	   default: RX_next_state = What_is_CMD ;
	  endcase
	 end
    
   endcase
   
   case(TX_current_state)
   IDLE_TX: 
    begin
	 case({RF_RdData_Valid,start_transmission})
	  2'b01:   TX_next_state = Send_ALU_LSresult ;
	  2'b10:   TX_next_state = Send_RegRead ;
	  default: TX_next_state = IDLE_TX ;
	 endcase
    end	
   Send_ALU_LSresult: TX_next_state = (!TX_DATA_OK || TX_Busy)? Send_ALU_LSresult :
                                      (ALU_result[`RESULT_WIDTH])? Send_ALU_MSresult : IDLE_TX ;
   Send_ALU_MSresult: TX_next_state = (!TX_DATA_OK || TX_Busy)? Send_ALU_MSresult : IDLE_TX ;
   Send_RegRead:      TX_next_state = (!TX_DATA_OK || TX_Busy)? Send_RegRead : IDLE_TX ;
   endcase
   
  end
  
 /* Outputs Block */
 always@(posedge CLK)
  begin
   case(RX_current_state)
    RF_Wr_CMD: CMD <= 8'hAA ;
	RF_Rd_CMD: CMD <= 8'hBB ;
	ALU_OPS_CMD:
	 begin
      CMD <= 8'hCC ;
	 end
	ALU_NO_OPS_CMD: CMD <= 8'hDD ;
	Wr_A: 
	 begin
 	 RF_Addr <= `ALU_Op_A_Addr ;
	 //Op_A    <=  RX_P_DATA     ;
	 end
	Wr_B: 
	 begin
	  RF_Addr <= `ALU_Op_B_Addr ;
	  //Op_B    <=  RX_P_DATA     ;
	 end
	Check_Address:  RF_Addr <= RX_P_DATA  ;
	Start_TX: ALU_result <= {ALU_extra_bits,ALU_OUT} ;
	Rd_DATA_FROM_RF: reg_read <= RF_RdData;
   endcase
  end
 
 always@(*)
  begin
   ALU_FUN     = 4'b1000 ; 
   ALU_EN      = 0 ;  
   CLK_GATE_EN = 0 ;   
   RF_WrEn     = 0 ;   
   RF_RdEn     = 0 ;   
   RF_WrData   = 0 ; 
   TX_P_DATA   = 0 ;
   TX_D_Valid  = 0 ;
   start_transmission = 0 ;
   end_transmission   = 0 ;
   case(RX_current_state)
    IDLE_RX: 
	 begin
	  ALU_FUN     = 4'b1000 ; 
      ALU_EN      = 0 ;  
      CLK_GATE_EN = 0 ;  
      RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ;   
      RF_WrData   = 0 ;
	 end
	 
    Wr_A:
     begin     
      RF_WrEn     = 1 ;   
      RF_RdEn     = 0 ;   
      RF_WrData   = RX_P_DATA ;
	 end
	 	
    Wr_B:  
     begin   
      RF_WrEn     = 1 ;   
      RF_RdEn     = 0 ;   
      RF_WrData   = RX_P_DATA ;
	  CLK_GATE_EN = 1 ; 
	 end
	 	
    Operate_ALU:  
	 begin
	  //ALU_FUN     = RX_P_DATA[3:0] ; 
      ALU_EN      = 1 ;  
      CLK_GATE_EN = 1 ; 
	  RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ; 
	 end
	 
	Result_ALU:
	 begin
	  ALU_FUN   = RX_P_DATA[3:0] ; 
      ALU_EN      = 1 ;  
      CLK_GATE_EN = 1 ; 
	  RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ; 
	 end
	
    Check_Address:
	 begin
      RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ;	  
	 end
	
    Wr_DATA_TO_RF:
	 begin   
      RF_WrEn     = 1 ;   
      RF_RdEn     = 0 ;   
      RF_WrData   = RX_P_DATA ;
	 end
	
    Rd_DATA_FROM_RF:
	 begin   
      RF_WrEn     = 0 ;   
      RF_RdEn     = 1 ;   
	 end
	 
	Start_TX:
	 begin
	  ALU_FUN     = RX_P_DATA[3:0] ; 
      ALU_EN      = 0 ;  
      CLK_GATE_EN = 1 ;  
      RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ;  
      start_transmission = 1 ;	  
	 end
	 
	default:
	 begin
	  ALU_FUN     = 4'b1000 ; 
      ALU_EN      = 0 ;  
      CLK_GATE_EN = 0 ;  
      RF_WrEn     = 0 ;   
      RF_RdEn     = 0 ;   
      RF_WrData   = 0 ;
	  start_transmission = 0 ;
	 end
	
   endcase
   
   case(TX_current_state)
    IDLE_TX:  
     begin
	  TX_P_DATA   = 0 ;
      TX_D_Valid  = 0 ;
	  end_transmission = 0 ;
     end	 
    Send_ALU_LSresult:
	 begin
	  TX_P_DATA   = ALU_result[`OPERAND_WIDTH-1:0] ;
      TX_D_Valid  = 1 ;
	  end_transmission = 1 ;
     end
    Send_ALU_MSresult:
	 begin
	  TX_P_DATA   = ALU_result[`RESULT_WIDTH-1:`OPERAND_WIDTH] ;
      TX_D_Valid  = 1 ;
	  end_transmission = 1 ;
     end
    Send_RegRead:
     begin
	  TX_P_DATA   = reg_read ;
      TX_D_Valid  = 1 ;
	  end_transmission = 1 ;
     end 	
   endcase
   
  end

endmodule
