# Clocks
create_clock -period 83.330 -name CLK_12M -waveform {0.000 41.660} -add [get_ports Clk12M]

# Input delay
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Rst]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Rst]

# Output delay
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Trap]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Trap]

