# Clocks
create_clock -add -name CLK_12M -period 83.33 -waveform {0 41.66} [get_ports {Clk12M}];

# Input delay
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Rst]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Rst]
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Run]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Run]

# Output delay
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Busy]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Busy]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Trap]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Trap]
