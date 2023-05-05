
set top_module SYS_TOP_dft                                                  
define_design_lib work -path ./work
set_svf Digital_System_dft.svf

lappend search_path "../std_cells/libs"
lappend search_path "../rtl ../rtl/TOP ../rtl/ALU_RF ../rtl/UART_TX ../rtl/UART_RX ../rtl/SYS_CTRL ../rtl/CDC_Power"

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"
set target_library [list $SSLIB $TTLIB $FFLIB]
set link_library [list * $SSLIB $TTLIB $FFLIB]

source ./RTL_Files.tcl

analyze -format verilog $RTL_Files
elaborate -lib work $top_module

check_design

source ./cons.tcl

# DFT Constrains
# Configure scan chains
set_scan_configuration -clock_mixing no_mix  -style multiplexed_flip_flop -replace true -max_length 100  
#-clock_mixing in case of more than one scan clock, mix or not different clock flops in the same chain

# Mapping and optimization 
compile -scan

# Setting Test Timing Variables  # Preclock Measure Protocol (default protocol)
set test_default_period 100
# Defines the length of a test vector cycle. (determine ATE freq)
set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 20
set test_default_strobe_width 0

set scan_clk_PER 100

# Define DFT Signals
set_dft_signal -port [get_ports SE]        -type ScanEnable  -view spec          -active_state 1   -usage scan
set_dft_signal -port [get_ports SI]        -type ScanDataIn  -view spec 
set_dft_signal -port [get_ports SO]        -type ScanDataOut -view spec
set_dft_signal -port [get_ports test_mode] -type TestMode    -view spec          -active_state 1
set_dft_signal -port [get_ports test_mode] -type Constant    -view existing_dft  -active_state 1 
set_dft_signal -port [get_ports scan_clk]  -type ScanClock   -view existing_dft  -timing "[expr $scan_clk_PER/2] $scan_clk_PER"
set_dft_signal -port [get_ports scan_rst]  -type Reset       -view existing_dft  -active_state 0

create_test_protocol
                            
dft_drc -verbose
# We see violations after this command, Massages here are more clear than the last 

preview_dft -show scan_summary

insert_dft

# Gate-Level Optimization
compile -scan -incremental

dft_drc -verbose -coverage_estimate
# Massages here are not clear

set_svf -off 
#Avoid Writing assign statements in the netlist
#change_name -hier -rule verilog
write_file -format verilog -hierarchy -output netlist_dft.v

#write_sdf  sdf/$top_module.sdf
write_sdc  -nosplit $top_module.sdc
# reporting 
report_area   -hierarchy > area_dft.rpt
report_power  -hierarchy > power_dft.rpt
report_timing -delay_type min > hold_dft.rpt
report_timing -delay_type max > setup_dft.rpt
report_clock  -attributes > clocks_dft.rpt
report_constraint -all_violators > constraints_dft.rpt
