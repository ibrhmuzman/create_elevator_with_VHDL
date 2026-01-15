library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_11 is
end testbench_11;

architecture Behavioral of testbench_11 is

    signal clk           : std_logic := '0';
    signal reset_n       : std_logic := '0';
    signal call_btn      : std_logic_vector(3 downto 0) := (others => '0');
    signal cab_btn       : std_logic_vector(3 downto 0) := (others => '0');
    signal overload      : std_logic := '0';
    signal emergency     : std_logic := '0';
    signal current_floor : std_logic_vector(1 downto 0);
    signal motor_up      : std_logic;
    signal motor_down    : std_logic;
    signal door_open     : std_logic;
    signal door_close    : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Instantiate DUT
    DUT: entity work.main
        port map (
            clk           => clk,
            reset_n       => reset_n,
            call_btn      => call_btn,
            cab_btn       => cab_btn,
            overload      => overload,
            emergency     => emergency,
            current_floor => current_floor,
            motor_up      => motor_up,
            motor_down    => motor_down,
            door_open     => door_open,
            door_close    => door_close
        );

    -- Test process
    test_process: process
    begin
        -- Reset
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

        -- Kabin içi buton 2. kata bas
        cab_btn <= "0100";  wait for 20 ns;
        cab_btn <= "0000";
        wait for 500 ns; -- asansör hareketi için bekle

        -- Kabin içi buton 3. kata bas
        cab_btn <= "1000";  wait for 20 ns;
        cab_btn <= "0000";
        wait for 1000 ns; -- simülasyon tamam

        wait;
    end process;

end Behavioral;
