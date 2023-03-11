module Clock_Divider (
 input  wire       I_ref_clk,
 input  wire       I_rst_n,
 input  wire       I_clk_en,
 input  wire [3:0] I_div_ratio,
 output wire       O_div_clk
 );
 wire odd, enable, e_toggle, o_toggle;
 reg  div_clock;
 reg  tog1, tog2; //Toogle flags for odd dividing 
 reg  [3:0] edge_counter;
 
 assign odd  =  I_div_ratio[0] ;                         // To determine odd or even dividing ratio
 assign enable   = I_clk_en && (|I_div_ratio[3:1])    ;  // Enable if not divided by 0 or 1
 assign e_toggle = (I_div_ratio>>1)   == edge_counter ;  
 assign o_toggle = (I_div_ratio>>1)+1 == edge_counter ; 
 
 assign O_div_clk = (enable)? div_clock : I_ref_clk ;
  
 always@(posedge I_ref_clk, negedge I_rst_n)
  begin
   if(!I_rst_n)
    begin
     edge_counter <= 0 ;
	 tog1 <= 0 ;
	 tog2 <= 0 ;
	 div_clock <= 0 ;
	end
   else if(enable)
    begin
	 div_clock <= (~|edge_counter)? I_ref_clk : div_clock ;
	 case(odd)
      0: begin
          edge_counter <= edge_counter + 1 ;
      	  if(e_toggle)
      	   begin
      	    div_clock <= !div_clock;
      	    edge_counter <= 1 ;
      	   end 
         end
      1: begin
          edge_counter <= edge_counter + 1 ;
      	  if(o_toggle)
      	   begin
      	    div_clock <= !div_clock;
      	    edge_counter <= 1 ;
      	    tog1 <= 1 ;
            tog2 <= 0 ;
           end
          if( e_toggle && tog1 && !tog2 )
           begin
            div_clock <= !div_clock;
            edge_counter <= 1 ;
            tog1 <= 0 ;
            tog2 <= 1 ;
           end
         end
     endcase
	end
  end 
 
endmodule
