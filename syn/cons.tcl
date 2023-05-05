# Prevent assign statements in the generated netlist 
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

# Clock definitions
set REF_CLK_NAME     REF_CLK
set UART_CLK_NAME    UART_CLK
set REF_CLK_PERIOD   20
set UART_CLK_PERIOD  104166
set GATED_CLK_NAME   ALU_CLK
set DIVIDED_CLK_NAME TX_CLK
set Division_ratio   8
 
create_clock -name $REF_CLK_NAME  -period $REF_CLK_PERIOD  [get_ports REF_CLK]
create_clock -name $UART_CLK_NAME -period $UART_CLK_PERIOD [get_ports UART_CLK]

create_generated_clock -master_clock $REF_CLK_NAME -source [get_ports REF_CLK]         \
                       -name $GATED_CLK_NAME [get_port U0_CLK_GATE/GATED_CLK]          \
                       -divide_by 1

create_generated_clock -master_clock $UART_CLK_NAME -source [get_ports UART_CLK]        \
                       -name $DIVIDED_CLK_NAME [get_port U0_CLK_Div/O_div_clk]          \
                       -divide_by $Division_ratio

set_clock_groups -asynchronous -group [get_clocks "$REF_CLK_NAME $GATED_CLK_NAME"] -group [get_clocks "$UART_CLK_NAME $DIVIDED_CLK_NAME"]

set Clocks [list $REF_CLK_NAME $UART_CLK_NAME $GATED_CLK_NAME $DIVIDED_CLK_NAME ]

set CLK_SETUP_SKEW 0.2
#setup skew is subtracted from the CLK peiod
set CLK_HOLD_SKEW 0.1
#hold skew is added to the CLK peiod
set CLK_LAT  0
set CLK_RISE 0.05
set CLK_FALL 0.05
set in_delay  [expr 0.2*$UART_CLK_PERIOD]
set out_delay [expr 0.2*$UART_CLK_PERIOD*$Division_ratio]

foreach i $Clocks {
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $i]
set_clock_uncertainty -hold  $CLK_HOLD_SKEW  [get_clocks $i]
set_clock_transition  -rise  $CLK_RISE       [get_clocks $i]
set_clock_transition  -fall  $CLK_FALL       [get_clocks $i]
set_clock_latency            $CLK_LAT        [get_clocks $i]
}

set_dont_touch_network { REF_CLK UART_CLK RST }

set_input_delay  $in_delay  -clock $UART_CLK_NAME    [get_port RX_IN]
set_output_delay $out_delay -clock $DIVIDED_CLK_NAME [get_port {TX_OUT TX_Busy}]
#set_output_delay $out_delay -clock $DIVIDED_CLK_NAME [get_port TX_Busy]

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port RX_IN]

set_load 75 [get_ports {TX_OUT TX_Busy}]

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" \
                         -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

set_max_area 0
set_max_dynamic_power 8  mW
set_max_leakage_power 20 mW

