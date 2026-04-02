# create clocks and constraints
#----------------------------------------------
set PERIOD 5.000 


create_clock -name "clk" -period ${PERIOD} [get_ports {clk}]

#add clock groups 1 clk per group
set_clock_groups -name main -logically_exclusive\
	 -group {clk}

#setup set at 10% clock cycle and hod to 2% until max 230ps (200ps for setup and 30 ps for hold)
set_clock_uncertainty -setup 0.200 [get_clocks {clk}]
set_clock_uncertainty -hold  0.030 [get_clocks {clk}]

#set clk transition
#max 10% clk period
set_clock_transition -max [expr 0.1*${PERIOD}]  [get_clocks {clk}]
set_clock_transition -min 0.005                 [get_clocks {clk}]




