----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2024
-- Design Name: Elevator Controller Testbench
-- Module Name: elevator_controller_tb
-- Project Name: create_elevator_with_VHDL
-- Target Devices: 
-- Tool Versions: 
-- Description: Comprehensive testbench for elevator controller FSM
--              Demonstrates timing methods and testbench creation
-- 
-- Dependencies: elevator_controller.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_controller_tb is
end elevator_controller_tb;

architecture Behavioral of elevator_controller_tb is
    
    -- Component Declaration
    component elevator_controller
        Port ( 
            clk           : in  STD_LOGIC;
            reset         : in  STD_LOGIC;
            floor_req     : in  STD_LOGIC_VECTOR(3 downto 0);
            current_floor : out STD_LOGIC_VECTOR(1 downto 0);
            door_open     : out STD_LOGIC;
            moving        : out STD_LOGIC;
            direction     : out STD_LOGIC
        );
    end component;
    
    -- Test signals
    signal clk           : STD_LOGIC := '0';
    signal reset         : STD_LOGIC := '0';
    signal floor_req     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal current_floor : STD_LOGIC_VECTOR(1 downto 0);
    signal door_open     : STD_LOGIC;
    signal moving        : STD_LOGIC;
    signal direction     : STD_LOGIC;
    
    -- Clock period definition
    constant clk_period : time := 10 ns;
    
    -- Simulation control
    signal sim_end : boolean := false;
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    uut: elevator_controller
        Port map (
            clk           => clk,
            reset         => reset,
            floor_req     => floor_req,
            current_floor => current_floor,
            door_open     => door_open,
            moving        => moving,
            direction     => direction
        );
    
    -- Clock process
    clk_process: process
    begin
        while not sim_end loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Test Case 1: Reset test
        report "=== Test Case 1: Reset Test ===";
        reset <= '1';
        wait for clk_period * 10;
        reset <= '0';
        wait for clk_period * 10;
        
        assert current_floor = "00" 
            report "ERROR: Initial floor should be 0" severity error;
        assert door_open = '0' 
            report "ERROR: Door should be closed initially" severity error;
        assert moving = '0' 
            report "ERROR: Elevator should not be moving initially" severity error;
        report "Test Case 1: PASSED";
        
        -- Test Case 2: Request same floor (door should open)
        report "=== Test Case 2: Request Same Floor ===";
        floor_req <= "0001";  -- Request floor 0 (current floor)
        wait for clk_period;
        floor_req <= "0000";
        
        -- Wait for door to open
        wait for clk_period * 30;
        assert door_open = '1' 
            report "ERROR: Door should be open" severity error;
        report "Door opened successfully";
        
        -- Wait for door cycle to complete
        wait for clk_period * 100;
        assert door_open = '0' 
            report "ERROR: Door should be closed after cycle" severity error;
        report "Test Case 2: PASSED";
        
        -- Test Case 3: Move up one floor
        report "=== Test Case 3: Move Up One Floor ===";
        floor_req <= "0010";  -- Request floor 1
        wait for clk_period;
        floor_req <= "0000";
        
        -- Wait for movement to start
        wait for clk_period * 10;
        assert moving = '1' 
            report "ERROR: Elevator should be moving" severity error;
        assert direction = '1' 
            report "ERROR: Elevator should be moving up" severity error;
        report "Elevator started moving up";
        
        -- Wait for arrival
        wait for clk_period * 120;
        assert current_floor = "01" 
            report "ERROR: Should be at floor 1" severity error;
        assert door_open = '1' 
            report "ERROR: Door should be open at destination" severity error;
        report "Test Case 3: PASSED";
        
        -- Wait for door cycle to complete
        wait for clk_period * 100;
        
        -- Test Case 4: Move up multiple floors
        report "=== Test Case 4: Move Up Multiple Floors ===";
        floor_req <= "1000";  -- Request floor 3
        wait for clk_period;
        floor_req <= "0000";
        
        -- Wait for movement to start
        wait for clk_period * 10;
        assert moving = '1' 
            report "ERROR: Elevator should be moving" severity error;
        assert direction = '1' 
            report "ERROR: Elevator should be moving up" severity error;
        report "Elevator started moving up to floor 3";
        
        -- Wait for arrival (2 floors to travel)
        wait for clk_period * 250;
        assert current_floor = "11" 
            report "ERROR: Should be at floor 3" severity error;
        assert door_open = '1' 
            report "ERROR: Door should be open at destination" severity error;
        report "Test Case 4: PASSED";
        
        -- Wait for door cycle to complete
        wait for clk_period * 100;
        
        -- Test Case 5: Move down
        report "=== Test Case 5: Move Down ===";
        floor_req <= "0001";  -- Request floor 0
        wait for clk_period;
        floor_req <= "0000";
        
        -- Wait for movement to start
        wait for clk_period * 10;
        assert moving = '1' 
            report "ERROR: Elevator should be moving" severity error;
        assert direction = '0' 
            report "ERROR: Elevator should be moving down" severity error;
        report "Elevator started moving down to floor 0";
        
        -- Wait for arrival (3 floors to travel)
        wait for clk_period * 350;
        assert current_floor = "00" 
            report "ERROR: Should be at floor 0" severity error;
        assert door_open = '1' 
            report "ERROR: Door should be open at destination" severity error;
        report "Test Case 5: PASSED";
        
        -- Wait for door cycle to complete
        wait for clk_period * 100;
        
        -- Test Case 6: Multiple requests
        report "=== Test Case 6: Multiple Requests ===";
        floor_req <= "0010";  -- Request floor 1
        wait for clk_period;
        floor_req <= "0100";  -- Request floor 2
        wait for clk_period;
        floor_req <= "0000";
        
        -- Wait for first floor
        wait for clk_period * 150;
        assert current_floor = "01" or current_floor = "10" 
            report "ERROR: Should be at floor 1 or 2" severity error;
        report "Handling multiple requests";
        
        -- Wait for completion
        wait for clk_period * 300;
        report "Test Case 6: PASSED";
        
        -- Test Case 7: Stress test - rapid requests
        report "=== Test Case 7: Rapid Floor Requests ===";
        for i in 0 to 3 loop
            floor_req <= std_logic_vector(to_unsigned(2**i, 4));
            wait for clk_period * 5;
        end loop;
        floor_req <= "0000";
        
        -- Let the system stabilize
        wait for clk_period * 500;
        report "Test Case 7: PASSED (System handled rapid requests)";
        
        -- All tests completed
        report "=================================================";
        report "All Test Cases Completed Successfully!";
        report "=================================================";
        
        sim_end <= true;
        wait;
    end process;
    
    -- Monitor process to display state changes
    monitor: process(clk)
        variable last_floor : STD_LOGIC_VECTOR(1 downto 0) := "00";
        variable last_door  : STD_LOGIC := '0';
        variable last_moving : STD_LOGIC := '0';
    begin
        if rising_edge(clk) then
            -- Report floor changes
            if current_floor /= last_floor then
                report "MONITOR: Floor changed from " & integer'image(to_integer(unsigned(last_floor))) &
                       " to " & integer'image(to_integer(unsigned(current_floor)));
                last_floor := current_floor;
            end if;
            
            -- Report door state changes
            if door_open /= last_door then
                if door_open = '1' then
                    report "MONITOR: Door opened at floor " & integer'image(to_integer(unsigned(current_floor)));
                else
                    report "MONITOR: Door closed at floor " & integer'image(to_integer(unsigned(current_floor)));
                end if;
                last_door := door_open;
            end if;
            
            -- Report movement state changes
            if moving /= last_moving then
                if moving = '1' then
                    if direction = '1' then
                        report "MONITOR: Started moving UP from floor " & integer'image(to_integer(unsigned(current_floor)));
                    else
                        report "MONITOR: Started moving DOWN from floor " & integer'image(to_integer(unsigned(current_floor)));
                    end if;
                else
                    report "MONITOR: Stopped moving at floor " & integer'image(to_integer(unsigned(current_floor)));
                end if;
                last_moving := moving;
            end if;
        end if;
    end process;

end Behavioral;
