library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity kat_buton_testi is
end kat_buton_testi;

architecture Behavioral of kat_buton_testi is

    ----------------------------------------------------------------
    -- DUT sinyalleri
    ----------------------------------------------------------------
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

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz

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
    -- DUT instantiation
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
            overload      => overload,
            emergency     => emergency,
            current_floor => current_floor,
            motor_up      => motor_up,
            motor_down    => motor_down,
            door_open     => door_open,
            door_close    => door_close
        );

    ----------------------------------------------------------------
    -- FCFS TEST SENARYOSU
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
        -- 1) 3. kat çağrısı
        ------------------------------------------------------------
        call_btn <= "1000";
        wait for CLK_PERIOD;
        call_btn <= "0000";

        wait for 200 ns;

        ------------------------------------------------------------
        -- 2) 0. kat çağrısı
        ------------------------------------------------------------
        call_btn <= "0001";
        wait for CLK_PERIOD;
        call_btn <= "0000";

        wait for 200 ns;

        ------------------------------------------------------------
        -- 3) 2. kat çağrısı
        ------------------------------------------------------------
        call_btn <= "0100";
        wait for CLK_PERIOD;
        call_btn <= "0000";

        ------------------------------------------------------------
        -- Asansörün tüm rotayı tamamlaması için bekle
        ------------------------------------------------------------
        wait for 5 us;

        wait; -- simülasyon sonu
    end process;

end Behavioral;