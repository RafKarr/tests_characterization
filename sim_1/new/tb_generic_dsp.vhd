----------------------------------------------------------------------------------
-- Engineer: Rafael Carrera Rodriguez
-- 
-- Create Date: 04/02/2021 09:46:18 AM
-- Design Name: 
-- Module Name: tb_generic_dsp - Behavioral
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_generic_dsp is
    --  Port ( );
end tb_generic_dsp;

architecture Behavioral of tb_generic_dsp is

    --------------------------------------------------------------
    --------------Component declaration---------------------------
    --------------------------------------------------------------

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

    ----------------------------------------------------------------
    --------------------Constant declaration -----------------------
    ----------------------------------------------------------------

    constant multiplication_word_length : integer := 17;
    constant accumulation_word_length   : integer := 44;
    constant clk_period                 : time    := 20 ns;
    --------------------------------------------------------------
    --------------Signal declaration------------------------------
    --------------------------------------------------------------

    signal a                             : std_logic_vector((multiplication_word_length - 1) downto 0);
    signal a_bypass                      : std_logic;
    signal a_en                          : std_logic;
    signal a_rst                         : std_logic;
    signal b                             : std_logic_vector((multiplication_word_length - 1) downto 0);
    signal b_bypass                      : std_logic;
    signal b_en                          : std_logic;
    signal b_rst                         : std_logic;
    signal c                             : std_logic_vector((accumulation_word_length - 1) downto 0);
    signal c_bypass                      : std_logic;
    signal c_en                          : std_logic;
    signal c_rst                         : std_logic;
    signal external_carry_in             : std_logic_vector((accumulation_word_length - 1) downto 0);
    signal add_sub_mode                  : std_logic;
    signal reg_add_sub_mode_ce           : std_logic;
    signal accumulation_mode             : std_logic;
    signal reg_accumulation_mode_ce      : std_logic;
    signal external_carry_in_mode        : std_logic;
    signal reg_external_carry_in_mode_ce : std_logic;
    signal arshift_mode                  : std_logic;
    signal reg_arshift_mode_ce           : std_logic;
    signal reg_mode_rst                  : std_logic;
    signal clk                           : std_logic := '1';
    signal p_en                          : std_logic;
    signal p_rst                         : std_logic;
    signal product                       : std_logic_vector((accumulation_word_length - 1) downto 0);
    signal tb_finish                     : boolean := false;

begin

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

    clk_proc : process
    begin
        while (not tb_finish) loop
            wait for clk_period/2;
            clk <= not clk;
        end loop;
        wait;
    end process;

    tb_proc : process
    begin

        --Setting
        a_bypass                      <= '1';
        a_en                          <= '1';
        a_rst                         <= '1';
        b_bypass                      <= '1';
        b_en                          <= '1';
        b_rst                         <= '1';
        c                             <= (others => '0');
        c_bypass                      <= '0';
        c_en                          <= '1'; --Initially don't initialize c, just doing some tests on the multiplier
        c_rst                         <= '0';
        external_carry_in             <= (others => '0');
        add_sub_mode                  <= '0';
        reg_add_sub_mode_ce           <= '1';
        accumulation_mode             <= '0'; --Initially don't accumulate
        reg_accumulation_mode_ce      <= '1';
        external_carry_in             <= (others => '0');
        external_carry_in_mode        <= '0';
        reg_external_carry_in_mode_ce <= '0';
        arshift_mode                  <= '0';
        reg_arshift_mode_ce           <= '0';
        reg_mode_rst                  <= '0';
        reg_mode_rst                  <= '1';
        p_en                          <= '1';
        p_rst                         <= '1';

        wait for clk_period;

        -- Normal multiplication
        a <= std_logic_vector(to_unsigned(4173, multiplication_word_length));
        b <= std_logic_vector(to_unsigned(36297, multiplication_word_length));
        wait for clk_period;
        --Result = 151467381
        p_rst <= '0';

        wait for clk_period;
        p_rst <= '1';
        --Start accumulation
        b                 <= std_logic_vector(to_unsigned(6052, multiplication_word_length));
        accumulation_mode <= '1';
        -- res = 25254996
        wait for clk_period;

        b <= std_logic_vector(to_unsigned(12732, multiplication_word_length));
        -- res = 78385632
        wait for clk_period;

        b <= std_logic_vector(to_unsigned(107932, multiplication_word_length));
        -- Res = 528785868
        wait for clk_period;

        p_en <= '0';

        --Finish test bench
        tb_finish <= true;
        wait;

    end process;

end Behavioral;