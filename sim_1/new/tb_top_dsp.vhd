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
            serial_tx : out std_logic;
            trigger   : out std_logic
        );
    end component;

    -- Clock period
    constant clk_period   : time                          := 10 ns;
    constant c_BIT_PERIOD : time                          := 8680 ns;
    constant a            : std_logic_vector(16 downto 0) := "1" & x"182C";
    constant b            : std_logic_vector(16 downto 0) := "0" & x"46F9";

    -- Generics

    -- Ports
    signal clk             : std_logic;
    signal serial_rx       : std_logic                    := '1';
    signal byte_to_send    : std_logic_vector(7 downto 0) := (others => '0');
    signal serial_tx       : std_logic;
    signal byte_received   : std_logic_vector(7 downto 0);
    signal result          : std_logic_vector(47 downto 0);
    signal simulation_done : boolean := false;
    signal s_trigger       : std_logic;

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

    procedure UART_RECEIVE_RESULT (
        signal i_data_serial : in std_logic;
        signal o_result      : out std_logic_vector(47 downto 0);
        signal byte_received : inout std_logic_vector(7 downto 0)) is

    begin
        for byte_count in 0 to 5 loop
            wait until i_data_serial = '0';
            wait for c_BIT_PERIOD;
            byte_received <= (others => '0');
            wait for c_BIT_PERIOD/2;
            for bit_count in 0 to 7 loop
                byte_received(bit_count) <= i_data_serial;
                wait for c_BIT_PERIOD;
            end loop;
            o_result(47 - byte_count * 8 downto 40 - byte_count * 8) <= byte_received;
        end loop;
    end procedure;

begin

    top_dsp_inst : entity work.top_dsp
    port map(
        clk       => clk,
        serial_rx => serial_rx,
        serial_tx => serial_tx,
        trigger   => s_trigger,
        reset => '0'
    );

    clk_process : process
    begin
        if (simulation_done /= true) then
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        else 
            wait;
        end if;
    end process clk_process;

    tb_proc : process
        variable treating_position : integer;
    begin
        wait for clk_period * 10000;
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
        wait;
    end process tb_proc;

    receive_proc : process
    begin
        UART_RECEIVE_RESULT(serial_tx, result, byte_received);
        simulation_done <= true;
        wait;
    end process receive_proc;
end;