# Information about VHDL folder

This folder contains the RTL and simulation files for the implementation that was analyzed: DSP interfaced with a UART module and a buffer. 

- bitstreams: Contains a bitstream to program the VHDL card. However, it is highly recommended to re do the compilation according to the setting used.
- constrs_1 : Constraints for the BASYS 3 card with Artix-7 chip.
- sim_1: Testbenches.
    - tb_generic_dsp: A testbench just for checking the functioning of the generic dsp.
    - tb_top_dsp: Testbench that checks the full functioning of the implementation.
- sources_1: Contains the sources for the implementation
    - generic_dsp: The DSP
    - register_rst_nbits: Register of nbits with reset
    - uart_rx: UART module for reception
    - uart_tx: UART module for transmission
    - receive_buffer: Buffer for saving the operands coming from the computer
    - dsp_sans_dsp: Dummy dsp just for testing purposes
    - dsp_uart_interface_*: Interface of the dsp with the uart modules. The variation in the names (x_p_y_c) follows to x DSP in parallel doing y multiplications consecutively (the same multiplication).
    - configurations: Configuration file for choosing setting and real or dummy dsp.
    - top_dsp: Top module for choosing the configuration

- Recommendations for compilation: As "needless" parallel multipliers are added, it is recommended to change attributes to the synthesis tool that prevent optimization, so that the parallel multipliers remain. This can be inspected after synthesis. 