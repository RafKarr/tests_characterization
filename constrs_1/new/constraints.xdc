# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
#	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]

##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports serial_rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports serial_rx]
set_property PACKAGE_PIN A18 [get_ports serial_tx]						
	set_property IOSTANDARD LVCMOS33 [get_ports serial_tx]


#Pin indicators
set_property PACKAGE_PIN U16 [get_ports done]						
	set_property IOSTANDARD LVCMOS33 [get_ports done]
