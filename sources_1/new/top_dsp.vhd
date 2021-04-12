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
        serial_tx : out std_logic;
        trigger   : out std_logic
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
            g_CLKS_PER_BIT : integer
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
            g_CLKS_PER_BIT : integer
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

    component receive_buffer
        port (
            i_byte      : in std_logic_vector (7 downto 0);
            i_rx_DV     : in std_logic;
            i_ack       : in std_logic;
            clk         : in std_logic;
            o_a         : out std_logic_vector (16 downto 0);
            o_b         : out std_logic_vector (16 downto 0);
            o_available : out std_logic
        );
    end component;

    --Constant declaration
    constant multiplication_word_length : integer := 17;
    constant accumulation_word_length   : integer := 44;

    --Signal declaration 

    --DSP related
    signal s_a       : std_logic_vector((multiplication_word_length - 1) downto 0) := (others => '0');
    signal s_a_en    : std_logic                                                   := '0';
    signal s_a_rst   : std_logic                                                   := '1';
    signal s_b       : std_logic_vector((multiplication_word_length - 1) downto 0) := (others => '0');
    signal s_b_en    : std_logic                                                   := '0';
    signal s_b_rst   : std_logic                                                   := '1';
    signal s_p_en    : std_logic                                                   := '0';
    signal s_p_rst   : std_logic                                                   := '1';
    signal s_product : std_logic_vector((accumulation_word_length - 1) downto 0)   := (others => '0');

    --UART RX related
    signal s_RX_DV   : std_logic                    := '0';
    signal s_RX_Byte : std_logic_vector(7 downto 0) := (others => '0');

    --Buffer related 
    signal s_ack       : std_logic := '0';
    signal s_available : std_logic := '0';

    --UART TX related
    signal s_TX_DV          : std_logic                    := '0'; --For starting transmission
    signal s_TX_Byte        : std_logic_vector(7 downto 0) := (others => '0');
    signal s_TX_Byte_mux_en : std_logic                    := '0';
    signal s_TX_Active      : std_logic                    := '0';

    --Functioning related
    type state is (
        cleanup,
        idle,
        mult,
        send
    );

    signal r_state            : state                := cleanup;
    signal s_next_state       : state                := cleanup;
    signal r_byte_count       : integer range 0 to 6 := 0;
    signal s_byte_count_reset : std_logic            := '0';
    signal s_byte_count_en    : std_logic            := '1';
    signal r_clk_count        : integer range 0 to 2 := 0;
    signal s_clk_count_en     : std_logic            := '0';
    signal s_trigger          : std_logic            := '0';

begin

    --Component instantiation 
    dsp : generic_dsp
    generic map(
        multiplication_word_length => multiplication_word_length,
        accumulation_word_length   => accumulation_word_length
    )
    port map(
        a                             => s_a,
        a_bypass                      => '0',
        a_en                          => s_a_en,
        a_rst                         => s_a_rst,
        b                             => s_b,
        b_bypass                      => '0',
        b_en                          => s_b_en,
        b_rst                         => s_b_rst,
        c => (others => '0'),
        c_bypass                      => '0',
        c_en                          => '1',
        c_rst                         => '0',
        external_carry_in => (others => '0'),
        add_sub_mode                  => '0',
        reg_add_sub_mode_ce           => '1',
        accumulation_mode             => '0',
        reg_accumulation_mode_ce      => '1',
        external_carry_in_mode        => '0',
        reg_external_carry_in_mode_ce => '0',
        arshift_mode                  => '0',
        reg_arshift_mode_ce           => '0',
        reg_mode_rst                  => '0',
        clk                           => clk,
        p_en                          => s_p_en,
        p_rst                         => s_p_rst,
        product                       => s_product
    );

    tx : uart_tx
    generic map(
        g_CLKS_PER_BIT => 868 -- 100 MHz / 115200 Baud rate
    )
    port map(
        i_Clk       => clk,
        i_TX_DV     => s_TX_DV,
        i_TX_Byte   => s_TX_Byte,
        o_TX_Active => s_TX_Active,
        o_TX_Serial => serial_tx,
        o_TX_Done   => open
    );

    rx : uart_rx
    generic map(
        g_CLKS_PER_BIT => 868 -- 100 MHz / 115200 Baud rate
    )
    port map(
        i_Clk       => clk,
        i_RX_Serial => serial_rx,
        o_RX_DV     => s_RX_DV,
        o_RX_Byte   => s_RX_Byte
    );

    receive_buffer_inst : receive_buffer
    port map(
        i_byte      => s_RX_Byte,
        i_rx_DV     => s_RX_DV,
        i_ack       => s_ack,
        clk         => clk,
        o_a         => s_a,
        o_b         => s_b,
        o_available => s_available
    );
    --Assignments

    trigger <= s_trigger;

    --Processes

    reg_byte_count : process (clk)
    begin
        if rising_edge(clk) then
            if s_byte_count_reset = '1' then
                r_byte_count <= 0;
            else
                if (s_byte_count_en = '1') then
                    r_byte_count <= r_byte_count + 1;
                end if;
            end if;
        end if;
    end process;

    reg_clk_count : process (clk)
    begin
        if rising_edge(clk) then
            if s_clk_count_en = '0' then
                r_clk_count <= 0;
            else
                r_clk_count <= r_clk_count + 1;
            end if;
        end if;
    end process;

    mux_byte_tx : process (s_TX_Byte_mux_en, r_byte_count)
        variable treating_position : integer;
    begin
        if (s_TX_Byte_mux_en = '1') then
            case r_byte_count is
                when 0 =>
                    s_TX_Byte <= "0000" & s_product(accumulation_word_length - 1 downto accumulation_word_length - 4);
                when 6               =>
                    s_TX_Byte <= (others => '0');
                when others          =>
                    treating_position := accumulation_word_length - 5 - (r_byte_count - 1) * 8;
                    s_TX_Byte <= s_product(treating_position downto treating_position - 7);
            end case;
        else
            s_TX_Byte <= (others => '0');
        end if;
    end process;

    combinatorial : process (r_state, r_clk_count, s_available, r_byte_count)
    begin
        case r_state is
            when cleanup => --Reset registers and continue
                s_ack              <= '0';
                s_a_en             <= '1';
                s_a_rst            <= '0';
                s_b_en             <= '1';
                s_b_rst            <= '0';
                s_p_en             <= '1';
                s_p_rst            <= '0';
                s_TX_DV            <= '0';
                s_TX_Byte_mux_en   <= '0';
                s_byte_count_reset <= '1';
                s_byte_count_en    <= '0';
                s_clk_count_en     <= '0';
                s_trigger          <= '0';
                s_next_state       <= idle;

            when idle =>

                s_a_rst            <= '1';
                s_b_rst            <= '1';
                s_p_rst            <= '1';
                s_TX_DV            <= '0';
                s_TX_Byte_mux_en   <= '0';
                s_byte_count_reset <= '0';
                s_byte_count_en    <= '0';

                if (s_available = '1') then
                    s_ack          <= '1';
                    s_a_en         <= '1';
                    s_b_en         <= '1';
                    s_p_en         <= '1';
                    s_clk_count_en <= '0';
                    s_trigger      <= '1';
                    s_next_state   <= mult;
                else
                    s_ack          <= '0';
                    s_a_en         <= '0';
                    s_b_en         <= '0';
                    s_p_en         <= '0';
                    s_clk_count_en <= '1';
                    s_trigger      <= '0';
                    s_next_state   <= idle;
                end if;

            when mult =>

                s_ack              <= '0';
                s_a_en             <= '0';
                s_a_rst            <= '1';
                s_b_en             <= '0';
                s_b_rst            <= '1';
                s_p_rst            <= '1';
                s_TX_DV            <= '0';
                s_byte_count_reset <= '0';
                s_byte_count_en    <= '0';
                s_trigger          <= '1';

                if (r_clk_count = 2) then
                    s_p_en           <= '0';
                    s_TX_Byte_mux_en <= '1';
                    s_clk_count_en   <= '0';
                    s_next_state     <= send;
                else
                    s_p_en           <= '1';
                    s_TX_Byte_mux_en <= '0';
                    s_clk_count_en   <= '1';
                    s_next_state     <= mult;
                end if;

            when send =>

                s_ack     <= '0';
                s_a_en    <= '0';
                s_a_rst   <= '1';
                s_b_en    <= '0';
                s_b_rst   <= '1';
                s_p_en    <= '0';
                s_p_rst   <= '1';
                s_trigger <= '0';

                if (r_byte_count < 6) then

                    s_TX_Byte_mux_en   <= '1';
                    s_byte_count_reset <= '0';
                    s_next_state       <= send;

                    if (s_TX_Active = '0' and r_clk_count = 0) then

                        s_TX_DV         <= '1';
                        s_byte_count_en <= '1';
                        s_clk_count_en  <= '1';

                    else
                        s_TX_DV         <= '0';
                        s_byte_count_en <= '0';

                        if (r_clk_count = 2) then
                            s_clk_count_en <= '0';
                        else
                            s_clk_count_en <= '1';
                        end if;

                    end if;
                else
                    s_TX_Byte_mux_en   <= '0';
                    s_TX_DV            <= '0';
                    s_clk_count_en     <= '0';
                    s_byte_count_reset <= '1';
                    s_byte_count_en    <= '0';
                    s_next_state       <= cleanup;

                end if;
        end case;
    end process;

    sequential : process (clk)
    begin
        if rising_edge(clk) then
            r_state <= s_next_state;
        end if;
    end process;

end rtl;