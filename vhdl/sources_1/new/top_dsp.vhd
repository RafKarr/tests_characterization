----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Rafael Carrera
-- 
-- Create Date: 04/06/2021 09:37:54 AM
-- Design Name: 
-- Module Name: top_dsp - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top_dsp is
    port (
        clk       : in std_logic;
        serial_rx : in std_logic;
        reset     : in std_logic;
        serial_tx : out std_logic;
        trigger   : out std_logic
    );
end top_dsp;

architecture rtl of top_dsp is

    --Component

    component dsp_uart_interface
        port (
            clk       : in std_logic;
            serial_rx : in std_logic;
            reset     : in std_logic;
            serial_tx : out std_logic;
            trigger   : out std_logic
        );
    end component;

    --Signals

    signal s_clk       : std_logic;
    signal s_serial_rx : std_logic;
    signal s_reset     : std_logic;
    signal s_serial_tx : std_logic;
    signal s_trigger   : std_logic;

    for dsp_uart_interface_inst : dsp_uart_interface
        
        -- Use the configuration desired
        --use configuration work.rtl_real;
        --use configuration work.rtl_10_p_10_c_real;
        --use configuration work.rtl_10_p_1_c_real;
        --use configuration work.rtl_5_p_1_c_real;
        use configuration work.rtl_3_p_1_c_real;
        
    begin

        --Instances
        dsp_uart_interface_inst : dsp_uart_interface

        port map(
            clk       => s_clk,
            serial_rx => s_serial_rx,
            reset     => s_reset,
            serial_tx => s_serial_tx,
            trigger   => s_trigger
        );

        --Assignments

        s_clk       <= clk;
        s_serial_rx <= serial_rx;
        s_reset     <= reset;
        serial_tx   <= s_serial_tx;
        trigger     <= s_trigger;

    end rtl;