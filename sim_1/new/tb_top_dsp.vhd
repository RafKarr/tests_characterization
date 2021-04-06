library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_dsp_tb is
end;

architecture bench of top_dsp_tb is

    component top_dsp
        port (
            clk       : in std_logic;
            serial_rx : in std_logic;
            serial_tx : out std_logic
        );
    end component;

    component UART_RX is
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

    -- Clock period
    constant clk_period   : time                          := 10 ns;
    constant c_BIT_PERIOD : time                          := 8680 ns;
    constant a            : std_logic_vector(16 downto 0) := std_logic_vector(to_unsigned(4173, 17));
    constant b            : std_logic_vector(16 downto 0) := std_logic_vector(to_unsigned(36297, 17));
    -- Generics

    -- Ports
    signal clk             : std_logic;
    signal serial_rx       : std_logic                    := '1';
    signal byte_to_send    : std_logic_vector(7 downto 0) := (others => '0');
    signal serial_tx       : std_logic;
    signal result          : std_logic_vector(47 downto 0);
    signal o_RX_DV         : std_logic;
    signal o_RX_Byte       : std_logic_vector(7 downto 0);
    signal simulation_done : boolean := false;

    procedure UART_WRITE_BYTE (
        i_data_in       : in std_logic_vector(7 downto 0);
        signal o_serial : out std_logic) is
    begin

        -- Send Start Bit
        o_serial <= '0';
        wait for c_BIT_PERIOD;

        -- Send Data Byte
        for ii in 0 to 7 loop
            o_serial <= i_data_in(ii);
            wait for c_BIT_PERIOD;
        end loop; -- ii

        -- Send Stop Bit
        o_serial <= '1';
        wait for c_BIT_PERIOD;
    end UART_WRITE_BYTE;
begin

    top_dsp_inst : top_dsp
    port map(
        clk       => clk,
        serial_rx => serial_rx,
        serial_tx => serial_tx
    );

    uart_rx_inst : uart_rx
    generic map(
        g_CLKS_PER_BIT => 868
    )
    port map(
        i_Clk       => clk,
        i_RX_Serial => serial_tx,
        o_RX_DV     => o_RX_DV,
        o_RX_Byte   => o_RX_Byte
    );

    clk_process : process
    begin
        if (simulation_done /= true) then
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end if;
    end process clk_process;

    tb_proc : process
        variable treating_position : integer;
    begin

        for i in 0 to 5 loop --Send operands
            if (i < 3) then
                if (i = 0) then
                    byte_to_send <= (
                        0      => a(16),
                        others => '0'
                        );
                else
                    treating_position := 15 - (i - 1) * 8;
                    byte_to_send <= a(treating_position downto treating_position - 7);
                end if;
            else
                if (i = 3) then
                    byte_to_send <= (
                        0      => b(16),
                        others => '0'
                        );
                else
                    treating_position := 15 - (i - 4) * 8;
                    byte_to_send <= b(treating_position downto treating_position - 7);
                end if;
            end if;
            wait for clk_period;
            UART_WRITE_BYTE(byte_to_send, serial_rx);
        end loop;

        --Prepared to receive:
        for i in 0 to 5 loop
            treating_position := 47 - i * 8;
            wait until o_RX_DV = '1';
            result(treating_position downto treating_position - 7) <= o_RX_Byte;
        end loop;
        simulation_done <= true;
        wait;
    end process tb_proc;

end;