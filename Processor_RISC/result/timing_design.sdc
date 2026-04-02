# ####################################################################

#  Created by Genus(TM) Synthesis Solution 22.16-s078_1 on Wed Mar 18 19:52:15 -03 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design RISC_V

create_clock -name "clk" -period 5.0 -waveform {0.0 2.5} [get_ports clk]
set_clock_transition -min 0.005 [get_clocks clk]
set_clock_transition -max 0.5 [get_clocks clk]
set_clock_groups -name "main" -logically_exclusive -group [get_clocks clk]
set_clock_gating_check -setup 0.0 
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.2 [get_clocks clk]
set_clock_uncertainty -hold 0.03 [get_clocks clk]
