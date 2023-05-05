##################### Define Working Library Directory ######################                                      
define_design_lib work -path ./work

########################### Formality Setup file ############################
set_svf Digital_System.svf

set top_module SYS_TOP

lappend search_path "../std_cells/libs"
lappend search_path "../rtl ../rtl/TOP ../rtl/ALU_RF ../rtl/UART_TX ../rtl/UART_RX ../rtl/SYS_CTRL ../rtl/CDC_Power"

set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"
set target_library [list $TTLIB $FFLIB $SSLIB]  
#to specify standard cells timing libraries
set link_library [list * $TTLIB $FFLIB $SSLIB]  
#to specify standard cells timing libraries and hard macros

source ./RTL_Files.tcl

analyze -format verilog $RTL_Files
elaborate -lib work $top_module

check_design

source ./cons.tcl
###################################################################
compile
#output files
write_file -format  verilog -hierarchy -output syn_netlist.v
write_sdc  -nosplit constraints.sdc
write_sdf           Timing.sdf
################# Reporting #######################
report_area   -hierarchy > area.rpt
report_power  -hierarchy > power.rpt
report_timing -max_paths 100 -delay_type min > hold.rpt
report_timing -max_paths 100 -delay_type max > setup.rpt
report_clock  -attributes > clocks.rpt
report_constraint -all_violators > constraints.rpt
report_port > ports.rpt

set_svf -off

