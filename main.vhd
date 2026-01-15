library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
    generic (
        CLK_FREQ_HZ      : integer := 50_000_000;
        FLOOR_TRAVEL_SEC : integer := 2;
        DOOR_OPEN_SEC    : integer := 3;
        DOOR_MOVE_SEC    : integer := 1;
        QUEUE_DEPTH      : integer := 8
    );
    port (
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        call_btn      : in  std_logic_vector(3 downto 0);
        cab_btn       : in  std_logic_vector(3 downto 0);
        overload      : in  std_logic;
        emergency     : in  std_logic;

        current_floor : out std_logic_vector(1 downto 0);
        motor_up      : out std_logic;
        motor_down    : out std_logic;
        door_open     : out std_logic;
        door_close    : out std_logic
    );
end main;

architecture Behavioral of main is

    ----------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------
    type state_type is (
        ST_IDLE,
        ST_MOVE_UP,
        ST_MOVE_DOWN,
        ST_DOOR_OPEN,
        ST_DOOR_CLOSE
    );
    signal state : state_type := ST_IDLE;

    ----------------------------------------------------------------
    -- ZAMAN SABİTLERİ (simülasyon)
    ----------------------------------------------------------------
    constant T_FLOOR        : integer := 10;
    constant DOOR_OPEN_CLK : integer := DOOR_OPEN_SEC * 10;
    constant DOOR_MOVE_CLK : integer := DOOR_MOVE_SEC * 10;

    ----------------------------------------------------------------
    -- REGISTERLAR
    ----------------------------------------------------------------
    signal floor_reg    : integer range 0 to 3 := 0;
    signal target_floor : integer range 0 to 3 := 0;
    signal timer        : integer range 0 to T_FLOOR := 0;
    signal door_timer   : integer := 0;

    ----------------------------------------------------------------
    -- FCFS KUYRUK
    ----------------------------------------------------------------
    type queue_type is array (0 to QUEUE_DEPTH-1) of integer range 0 to 3;
    signal queue   : queue_type := (others => 0);
    signal q_head  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal q_tail  : integer range 0 to QUEUE_DEPTH-1 := 0;
    signal q_count : integer range 0 to QUEUE_DEPTH := 0;

    ----------------------------------------------------------------
    -- Buton edge
    ----------------------------------------------------------------
    signal call_btn_d : std_logic_vector(3 downto 0) := (others => '0');
    signal cab_btn_d  : std_logic_vector(3 downto 0) := (others => '0');

    ----------------------------------------------------------------
    -- ÇIKIŞ İÇ SİNYALLERİ
    ----------------------------------------------------------------
    signal s_motor_up   : std_logic := '0';
    signal s_motor_down : std_logic := '0';
    signal s_door_open  : std_logic := '0';
    signal s_door_close : std_logic := '0';

begin

    ----------------------------------------------------------------
    -- PORT BAĞLANTILARI
    ----------------------------------------------------------------
    current_floor <= std_logic_vector(to_unsigned(floor_reg, 2));
    motor_up      <= s_motor_up;
    motor_down    <= s_motor_down;
    door_open     <= s_door_open;
    door_close    <= s_door_close;

    ----------------------------------------------------------------
    -- ANA FSM + KUYRUK
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            call_btn_d <= call_btn;
            cab_btn_d  <= cab_btn;

            ----------------------------------------------------------
            -- RESET
            ----------------------------------------------------------
            if reset_n = '0' then
                state      <= ST_IDLE;
                floor_reg <= 0;
                timer      <= 0;
                door_timer <= 0;
                q_head     <= 0;
                q_tail     <= 0;
                q_count    <= 0;

            ----------------------------------------------------------
            -- NORMAL ÇALIŞMA (FSM emergency içinde kilitlenmez)
            ----------------------------------------------------------
            else

                ------------------------------------------------------
                -- FCFS ENQUEUE (her zaman aktif)
                ------------------------------------------------------
                for i in 0 to 3 loop
                    if call_btn(i) = '1' and call_btn_d(i) = '0' then
                        if q_count < QUEUE_DEPTH then
                            queue(q_tail) <= i;
                            q_tail <= (q_tail + 1) mod QUEUE_DEPTH;
                            q_count <= q_count + 1;
                        end if;
                    end if;

                    if cab_btn(i) = '1' and cab_btn_d(i) = '0' then
                        if q_count < QUEUE_DEPTH then
                            queue(q_tail) <= i;
                            q_tail <= (q_tail + 1) mod QUEUE_DEPTH;
                            q_count <= q_count + 1;
                        end if;
                    end if;
                end loop;

                ------------------------------------------------------
                -- FSM
                ------------------------------------------------------
                case state is

                    ---------------- IDLE ----------------
                    when ST_IDLE =>
                        timer <= 0;
                        door_timer <= 0;

                        if q_count > 0 then
                            target_floor <= queue(q_head);

                            if queue(q_head) > floor_reg then
                                state <= ST_MOVE_UP;
                            elsif queue(q_head) < floor_reg then
                                state <= ST_MOVE_DOWN;
                            else
                                state <= ST_DOOR_OPEN;
                            end if;

                            q_head  <= (q_head + 1) mod QUEUE_DEPTH;
                            q_count <= q_count - 1;
                        end if;

                    ---------------- MOVE UP ----------------
                    when ST_MOVE_UP =>
                        if emergency = '1' or overload = '1' then
                            timer <= timer; -- hareket DURUR
                        elsif timer = T_FLOOR then
                            timer <= 0;
                            floor_reg <= floor_reg + 1;
                            if floor_reg + 1 = target_floor then
                                state <= ST_DOOR_OPEN;
                            end if;
                        else
                            timer <= timer + 1;
                        end if;

                    ---------------- MOVE DOWN ----------------
                    when ST_MOVE_DOWN =>
                        if emergency = '1' or overload = '1' then
                            timer <= timer;
                        elsif timer = T_FLOOR then
                            timer <= 0;
                            floor_reg <= floor_reg - 1;
                            if floor_reg - 1 = target_floor then
                                state <= ST_DOOR_OPEN;
                            end if;
                        else
                            timer <= timer + 1;
                        end if;

                    ---------------- DOOR OPEN ----------------
                    when ST_DOOR_OPEN =>
                        if emergency = '1' or overload = '1' then
                            door_timer <= door_timer; -- ⛔ DONDU
                            state <= ST_DOOR_OPEN;
                        elsif door_timer >= DOOR_OPEN_CLK then
                            door_timer <= 0;
                            state <= ST_DOOR_CLOSE;
                        else
                            door_timer <= door_timer + 1;
                        end if;

                    ---------------- DOOR CLOSE ----------------
                    when ST_DOOR_CLOSE =>
                        if emergency = '1' or overload = '1' then
                            door_timer <= 0;
                            state <= ST_DOOR_OPEN;
                        elsif door_timer < DOOR_MOVE_CLK then
                            door_timer <= door_timer + 1;
                        else
                            door_timer <= 0;
                            state <= ST_IDLE;
                        end if;

                end case;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- ÇIKIŞ DEKODERİ
    ----------------------------------------------------------------
    process(state, emergency, overload)
    begin
        s_motor_up   <= '0';
        s_motor_down <= '0';
        s_door_open  <= '0';
        s_door_close <= '0';

        if emergency = '1' or overload = '1' then
            s_door_open <= '1';   -- kapı ZORLA açık
        else
            case state is
                when ST_MOVE_UP    => s_motor_up   <= '1';
                when ST_MOVE_DOWN  => s_motor_down <= '1';
                when ST_DOOR_OPEN  => s_door_open  <= '1';
                when ST_DOOR_CLOSE => s_door_close <= '1';
                when others        => null;
            end case;
        end if;
    end process;

end Behavioral;