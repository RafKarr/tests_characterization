# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
#	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]

##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports serial_rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports serial_rx]
set_property PACKAGE_PIN A18 [get_ports serial_tx]						
	set_property IOSTANDARD LVCMOS33 [get_ports serial_tx]


#Trigger
set_property PACKAGE_PIN J1 [get_ports trigger]						
	set_property IOSTANDARD LVCMOS33 [get_ports trigger]

#Reset
set_property PACKAGE_PIN U18 [get_ports reset]
	set_property IOSTANDARD LVCMOS33 [get_ports reset]
