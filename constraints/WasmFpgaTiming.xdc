# Clocks
create_clock -period 83.330 -name CLK_12M -waveform {0.000 41.660} -add [get_ports Clk12M]

set_clock_groups -asynchronous \
    -group [get_clocks CLK_12M] \
    -group [get_clocks -of_objects [get_pins SystemClockGenerator_i/inst/mmcm_adv_inst/CLKOUT0]

# Input delay
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Rst]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Rst]
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports MiSo]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports MiSo]
set_input_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports UartRx]
set_input_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports UartRx]

# Output delay
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Loaded]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Trap]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Trap]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports Active]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports Active]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports MoSi]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports MoSi]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports SClk]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports SClk]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports UartTx]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports UartTx]
set_output_delay -clock [get_clocks CLK_12M] -min 1.000 [get_ports nCs]
set_output_delay -clock [get_clocks CLK_12M] -max 3.000 [get_ports nCs]
