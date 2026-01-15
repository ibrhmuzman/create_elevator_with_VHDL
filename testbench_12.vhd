library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench_12 is
end testbench_12;

architecture Behavioral of testbench_12 is

    ----------------------------------------------------------------
    -- DUT sinyalleri
    ----------------------------------------------------------------
    signal clk           : std_logic := '0';
    signal reset_n       : std_logic := '0';
    signal call_btn      : std_logic_vector(3 downto 0) := (others => '0');
    signal cab_btn       : std_logic_vector(3 downto 0) := (others => '0');

    signal current_floor : std_logic_vector(1 downto 0);
    signal motor_up      : std_logic;
    signal motor_down    : std_logic;
    signal door_open     : std_logic;
    signal door_close    : std_logic;

    constant CLK_PERIOD : time := 20 ns;

begin

    ----------------------------------------------------------------
    -- Clock üretimi
    ----------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    uut : entity work.main
        generic map (
            CLK_FREQ_HZ      => 50_000_000,
            FLOOR_TRAVEL_SEC => 2,
            DOOR_OPEN_SEC    => 3,
            DOOR_MOVE_SEC    => 1,
            QUEUE_DEPTH      => 8
        )
        port map (
            clk           => clk,
            reset_n       => reset_n,
            call_btn      => call_btn,
            cab_btn       => cab_btn,
            overload      => '0',
            emergency     => '0',
            current_floor => current_floor,
            motor_up      => motor_up,
            motor_down    => motor_down,
            door_open     => door_open,
            door_close    => door_close
        );

    ----------------------------------------------------------------
    -- GERÇEKÇİ TEST SENARYOSU
    ----------------------------------------------------------------
    stim_proc : process
    begin
        ------------------------------------------------------------
        -- RESET
        ------------------------------------------------------------
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

        ------------------------------------------------------------
        -- 1) Dış çağrı: 3. kat
        ------------------------------------------------------------
        call_btn <= "1000";
        wait for CLK_PERIOD;
        call_btn <= "0000";

        ------------------------------------------------------------
        -- 2) Asansör 3. kata gelsin ve kapı açılsın
        ------------------------------------------------------------
        wait until current_floor = "11"; -- 3. kat
        wait until door_open = '1';
        wait for 100 ns; -- içeri girme süresi (mantıksal)

        ------------------------------------------------------------
        -- 3) Kabin içi çağrı: 2. kat
        ------------------------------------------------------------
        cab_btn <= "0100";
        wait for CLK_PERIOD;
        cab_btn <= "0000";

        ------------------------------------------------------------
        -- 4) 2. kata ulaşmasını bekle
        ------------------------------------------------------------
        wait until current_floor = "10"; -- 2. kat
        wait until door_open = '1';

        ------------------------------------------------------------
        -- Simülasyon sonu
        ------------------------------------------------------------
        wait for 500 ns;
        wait;
    end process;

end Behavioral;