# fm_script.tcl

set SSLIB "../std_cells/libs/scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "../std_cells/libs/scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "../std_cells/libs/scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"
set synopsys_auto_setup true
set_svf {../syn/Digital_System.svf}

set top_module SYS_TOP

source ./RTL_Files.tcl

# Read Reference technology libraries
read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

# Read Reference Design Files
read_verilog -container Ref $RTL_Files
# set the top Reference Design 
set_reference_design $top_module
set_top $top_module

# Read Implementation technology libraries
read_db -container Imp [list $SSLIB $TTLIB $FFLIB]
# Read Implementation Design Files
read_verilog -container Imp -netlist "../syn/syn_netlist.v"
# set the top Implementation Design
set_implementation_design $top_module
set_top $top_module

# When verifying after DFT
###############################################
#set_dont_verify_points -type port Ref:/WORK/*/SO
#set_dont_verify_points -type port Imp:/WORK/*/SO
#set_constant Ref:/WORK/*/test_mode 0
#set_constant Imp:/WORK/*/test_mode 0
#set_constant Ref:/WORK/*/SE        0
#set_constant Imp:/WORK/*/SE        0
###############################################

# matching Compare points
match
# verify
set successful [verify]
#it returns 1 or 0 for success or fail 
if {!$successful} {
diagnose
analyze_points -failing
}
# Reports
report_passing_points    > "passing_points.rpt"
report_failing_points    > "failing_points.rpt"
report_aborted_points    > "aborted_points.rpt"
report_unverified_points > "unverified_points.rpt"
# Debug through foramlity GUI
start_gui
