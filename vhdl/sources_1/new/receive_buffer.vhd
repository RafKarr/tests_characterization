----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2021 10:33:26 AM
-- Design Name: 
-- Module Name: receive_buffer - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receive_buffer is
    port (
        i_byte      : in std_logic_vector (7 downto 0);
        i_rx_DV     : in std_logic;
        i_ack       : in std_logic;
        i_reset     : in std_logic;
        clk         : in std_logic;
        o_a         : out std_logic_vector (16 downto 0);
        o_b         : out std_logic_vector (16 downto 0);
        o_available : out std_logic
    );

end receive_buffer;

architecture rtl of receive_buffer is

    signal r_a             : std_logic_vector(23 downto 0) := (others => '0');
    signal r_b             : std_logic_vector(23 downto 0) := (others => '0');
    signal r_byte_count    : integer range 0 to 5;
    signal s_reset_counter : std_logic := '0';
    signal s_set_counter   : std_logic := '0';
    signal s_available     : std_logic := '0';
    signal s_reg_a_en      : std_logic := '0';
    signal s_reg_b_en      : std_logic := '0';

    --States
    type state is (ready,
        receiving_byte,
        full
    );

    signal r_state_current : state := ready;
    signal s_state_next    : state := ready;

begin

    o_a         <= r_a(16 downto 0);
    o_b         <= r_b(16 downto 0);
    o_available <= s_available;

    combinatorial : process (r_state_current, i_rx_DV, i_ack, r_byte_count)
    begin
        case r_state_current is
            when ready =>
                s_set_counter   <= '0';
                s_reset_counter <= '0';
                s_available     <= '0';
                s_reg_a_en      <= '0';
                s_reg_b_en      <= '0';
                if (i_rx_DV = '1') then
                    s_state_next <= receiving_byte;
                else
                    s_state_next <= ready;
                end if;

            when receiving_byte =>

                s_available <= '0';

                if (r_byte_count < 3) then
                    s_reg_a_en <= '1';
                    s_reg_b_en <= '0';
                else
                    s_reg_a_en <= '0';
                    s_reg_b_en <= '1';
                end if;

                if (r_byte_count = 5) then
                    s_set_counter   <= '0';
                    s_reset_counter <= '1';
                    s_state_next    <= full;
                else
                    s_set_counter   <= '1';
                    s_reset_counter <= '0';
                    s_state_next    <= ready;
                end if;

            when full =>
                s_available     <= '1';
                s_set_counter   <= '0';
                s_reset_counter <= '0';
                s_reg_a_en      <= '0';
                s_reg_b_en      <= '0';

                if (i_ack = '1') then
                    s_state_next <= ready;
                else
                    s_state_next <= full;
                end if;

        end case;
    end process;

    sequential : process (clk)
    begin
        if rising_edge(clk) then
            if (i_reset = '1') then 
                r_state_current <= ready;
            else
                r_state_current <= s_state_next;
            end if;
        end if;
    end process;

    byte_counter : process (clk)
    begin
        if rising_edge(clk) then
            if s_reset_counter = '1' then
                r_byte_count <= 0;
            else
                if (s_set_counter = '1') then
                    r_byte_count <= r_byte_count + 1;
                end if;
            end if;
        end if;
    end process;

    reg_a : process (clk)
    begin
        if rising_edge(clk) then
            if (s_reg_a_en = '1') then
                r_a(23 - r_byte_count * 8 downto 16 - r_byte_count * 8) <= i_byte;
            end if;
        end if;
    end process;

    reg_b : process (clk)
    begin
        if rising_edge(clk) then
            if (s_reg_b_en = '1') then
                r_b(23 - (r_byte_count - 3) * 8 downto 16 - (r_byte_count - 3) * 8) <= i_byte;
            end if;
        end if;
    end process;

end rtl;