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
        serial_tx : out std_logic
    );
end top_dsp;

architecture rtl of top_dsp is

    --Component declaration

    component generic_dsp is
        generic (
            multiplication_word_length : integer;
            accumulation_word_length   : integer
        );
        port (
            a                             : in std_logic_vector((multiplication_word_length - 1) downto 0);
            a_bypass                      : in std_logic;
            a_en                          : in std_logic;
            a_rst                         : in std_logic;
            b                             : in std_logic_vector((multiplication_word_length - 1) downto 0);
            b_bypass                      : in std_logic;
            b_en                          : in std_logic;
            b_rst                         : in std_logic;
            c                             : in std_logic_vector((accumulation_word_length - 1) downto 0);
            c_bypass                      : in std_logic;
            c_en                          : in std_logic;
            c_rst                         : in std_logic;
            external_carry_in             : in std_logic_vector((accumulation_word_length - 1) downto 0);
            add_sub_mode                  : in std_logic;
            reg_add_sub_mode_ce           : in std_logic;
            accumulation_mode             : in std_logic;
            reg_accumulation_mode_ce      : in std_logic;
            external_carry_in_mode        : in std_logic;
            reg_external_carry_in_mode_ce : in std_logic;
            arshift_mode                  : in std_logic;
            reg_arshift_mode_ce           : in std_logic;
            reg_mode_rst                  : in std_logic;
            clk                           : in std_logic;
            p_en                          : in std_logic;
            p_rst                         : in std_logic;
            product                       : out std_logic_vector((accumulation_word_length - 1) downto 0)
        );
    end component;

    component uart_rx is
        generic (
            g_CLKS_PER_BIT : integer-- TODO Needs to be set correctly 
        );
        port (
            i_Clk       : in std_logic;
            i_RX_Serial : in std_logic;
            o_RX_DV     : out std_logic;
            o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component;

    component uart_tx is
        generic (
            g_CLKS_PER_BIT : integer -- TODO Needs to be set correctly
        );
        port (
            i_Clk       : in std_logic;
            i_TX_DV     : in std_logic;
            i_TX_Byte   : in std_logic_vector(7 downto 0);
            o_TX_Active : out std_logic;
            o_TX_Serial : out std_logic;
            o_TX_Done   : out std_logic
        );
    end component;

    --Register for the Done Signal from UART RX
    component register_rst_nbits is
        generic (size : integer);
        port (
            d         : in std_logic_vector ((size - 1) downto 0);
            clk       : in std_logic;
            ce        : in std_logic;
            rst       : in std_logic;
            rst_value : in std_logic_vector ((size - 1) downto 0);
            q         : out std_logic_vector ((size - 1) downto 0)
        );
    end component;

    --Constant declaration
    constant multiplication_word_length : integer := 17;
    constant accumulation_word_length   : integer := 44;

    --Signal declaration 

    --DSP related
    signal a                             : std_logic_vector((multiplication_word_length - 1) downto 0) := (others => '0');
    signal a_bypass                      : std_logic                                                   := '0';
    signal a_en                          : std_logic                                                   := '0';
    signal a_rst                         : std_logic                                                   := '1';
    signal b                             : std_logic_vector((multiplication_word_length - 1) downto 0) := (others => '0');
    signal b_bypass                      : std_logic                                                   := '0';
    signal b_en                          : std_logic                                                   := '0';
    signal b_rst                         : std_logic                                                   := '1';
    signal c                             : std_logic_vector((accumulation_word_length - 1) downto 0)   := (others => '0');
    signal c_bypass                      : std_logic                                                   := '0';
    signal c_en                          : std_logic                                                   := '1';
    signal c_rst                         : std_logic                                                   := '0'; --Not using c, then it is reset
    signal external_carry_in             : std_logic_vector((accumulation_word_length - 1) downto 0)   := (others => '0');
    signal add_sub_mode                  : std_logic                                                   := '0';
    signal reg_add_sub_mode_ce           : std_logic                                                   := '1';
    signal accumulation_mode             : std_logic                                                   := '0';
    signal reg_accumulation_mode_ce      : std_logic                                                   := '1';
    signal external_carry_in_mode        : std_logic                                                   := '0';
    signal reg_external_carry_in_mode_ce : std_logic                                                   := '0';
    signal arshift_mode                  : std_logic                                                   := '0';
    signal reg_arshift_mode_ce           : std_logic                                                   := '0';
    signal reg_mode_rst                  : std_logic                                                   := '0';
    signal p_en                          : std_logic                                                   := '0';
    signal p_rst                         : std_logic                                                   := '1';
    signal product                       : std_logic_vector((accumulation_word_length - 1) downto 0)   := (others => '0');

    --UART RX related
    signal o_RX_DV   : std_logic                    := '0';
    signal o_RX_Byte : std_logic_vector(7 downto 0) := (others => '0');

    --UART TX related
    signal i_TX_DV     : std_logic                    := '0'; --For starting transmission
    signal i_TX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
    signal o_TX_Active : std_logic                    := '0';
    signal o_TX_Done   : std_logic                    := '0';

    --Register for Done signal related
    signal rst_dv_reg : std_logic := '1';
    signal q_dv_reg   : std_logic := '0';

    --Functioning related
    type state is (
        start,
        receive,
        mult,
        send,
        delay
    );

    signal r_state    : state   := start;
    signal byte_count : integer := 0;
    signal clk_count  : integer := 0;

begin

    --Component instantiation 
    dsp : generic_dsp
    generic map(
        multiplication_word_length => multiplication_word_length,
        accumulation_word_length   => accumulation_word_length
    )
    port map(
        a                             => a,
        a_bypass                      => a_bypass,
        a_en                          => a_en,
        a_rst                         => a_rst,
        b                             => b,
        b_bypass                      => b_bypass,
        b_en                          => b_en,
        b_rst                         => b_rst,
        c                             => c,
        c_bypass                      => c_bypass,
        c_en                          => c_en,
        c_rst                         => c_rst,
        external_carry_in             => external_carry_in,
        add_sub_mode                  => add_sub_mode,
        reg_add_sub_mode_ce           => reg_add_sub_mode_ce,
        accumulation_mode             => accumulation_mode,
        reg_accumulation_mode_ce      => reg_add_sub_mode_ce,
        external_carry_in_mode        => external_carry_in_mode,
        reg_external_carry_in_mode_ce => reg_external_carry_in_mode_ce,
        arshift_mode                  => arshift_mode,
        reg_arshift_mode_ce           => reg_arshift_mode_ce,
        reg_mode_rst                  => reg_mode_rst,
        clk                           => clk,
        p_en                          => p_en,
        p_rst                         => p_rst,
        product                       => product
    );

    tx : uart_tx
    generic map(
        g_CLKS_PER_BIT => 868 -- 100 MHz / 115200 Baud rate
    )
    port map(
        i_Clk       => clk,
        i_TX_DV     => i_TX_DV,
        i_TX_Byte   => i_TX_Byte,
        o_TX_Active => o_TX_Active,
        o_TX_Serial => serial_tx,
        o_TX_Done   => o_TX_Done
    );

    rx : uart_rx
    generic map(
        g_CLKS_PER_BIT => 868 -- 100 MHz / 115200 Baud rate
    )
    port map(
        i_Clk       => clk,
        i_RX_Serial => serial_rx,
        o_RX_DV     => o_RX_DV,
        o_RX_Byte   => o_RX_Byte
    );

    --Processes

    dv_reg : process (clk, rst_dv_reg)
    begin
        if rst_dv_reg = '0' then
            q_dv_reg <= '0';
        elsif rising_edge(clk) then
            q_dv_reg <= o_RX_DV;
        end if;
    end process;

    state_machine : process (clk)

        variable treating_position : integer;

    begin

        case r_state is

            when start =>

                --Reset registers and continue
                if (clk_count = 0) then
                    a_en       <= '1';
                    b_en       <= '1';
                    p_en       <= '1';
                    a_rst      <= '0';
                    b_rst      <= '0';
                    p_rst      <= '0';
                    rst_dv_reg <= '0';
                    clk_count  <= clk_count + 1;
                    r_state    <= start;
                else
                    a_en       <= '0';
                    b_en       <= '0';
                    p_en       <= '0';
                    a_rst      <= '1';
                    b_rst      <= '1';
                    p_rst      <= '1';
                    rst_dv_reg <= '1';
                    clk_count  <= 0;
                    r_state    <= receive;
                end if;

            when receive =>

                if (q_dv_reg = '1') then -- If values available, then
                    rst_dv_reg <= '0'; -- Reset register
                    if (byte_count < 3) then -- If byte_count < 3, we are dealing with a
                        if (byte_count = 0) then -- If first byte, then we only have one bit
                            a(multiplication_word_length - 1) <= o_RX_Byte(0);
                        else -- Else a full byte
                            treating_position := multiplication_word_length - 2 - (byte_count - 1) * 8;
                            a(treating_position downto treating_position - 7) <= o_RX_Byte;
                        end if;
                    else -- Else with b
                        if (byte_count = 3) then -- If first byte, then we only have one bit
                            b(multiplication_word_length - 1) <= o_RX_Byte(0);
                        else -- Else a full byte
                            treating_position := multiplication_word_length - 2 - (byte_count - 4) * 8;
                            b(treating_position downto treating_position - 7) <= o_RX_Byte;
                        end if;
                    end if;
                    byte_count <= byte_count + 1; --Increment byte count
                else --Else, be ready to receive
                    rst_dv_reg <= '1'; -- Don't reset DV register                
                end if;

                --State change condition
                if (byte_count = 6) then
                    byte_count <= 0;
                    r_state    <= mult;
                else
                    r_state <= receive;
                end if;

            when mult =>

                if (clk_count = 3) then
                    --Disable registers and change state
                    a_en      <= '0';
                    b_en      <= '0';
                    p_en      <= '0';
                    clk_count <= 0;
                    r_state   <= send;
                else
                    --Enable registers
                    a_en      <= '1';
                    b_en      <= '1';
                    p_en      <= '1';
                    clk_count <= clk_count + 1;
                    r_state   <= mult;
                end if;

            when send =>

                if (byte_count /= 6) then
                    if (o_TX_Active = '0') then -- If not currently sending 
                        if (byte_count = 0) then --If treating first byte
                            i_TX_Byte <= "0000" & product(accumulation_word_length - 1 downto accumulation_word_length - 4);
                        else
                            treating_position := accumulation_word_length - 5 - (byte_count - 1) * 8;
                            i_TX_Byte <= product(treating_position downto treating_position - 7);
                        end if;
                        i_TX_DV             <= '1';
                        byte_count          <= byte_count + 1;
                        r_state             <= delay; --Do a 3 clk cycle delay
                    else -- Else don't start transmission
                        r_state <= send;
                        i_TX_DV <= '0';
                    end if;
                else -- Sending is over 
                    byte_count <= 0;
                    r_state    <= receive;
                end if;

            when delay =>

                if clk_count /= 3 then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    r_state   <= send;
                end if;
        end case;
    end process;

end rtl;