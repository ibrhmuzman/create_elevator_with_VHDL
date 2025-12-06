----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2024
-- Design Name: Elevator Controller
-- Module Name: elevator_controller - Behavioral
-- Project Name: create_elevator_with_VHDL
-- Target Devices: 
-- Tool Versions: 
-- Description: FSM-based elevator controller for educational purposes
--              Demonstrates sequential circuit design with state machines
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Elevator Controller Entity
entity elevator_controller is
    Port ( 
        clk           : in  STD_LOGIC;                      -- System clock
        reset         : in  STD_LOGIC;                      -- Asynchronous reset
        floor_req     : in  STD_LOGIC_VECTOR(3 downto 0);  -- Floor request buttons (0-3)
        current_floor : out STD_LOGIC_VECTOR(1 downto 0);  -- Current floor position
        door_open     : out STD_LOGIC;                      -- Door status (1=open, 0=closed)
        moving        : out STD_LOGIC;                      -- Moving status
        direction     : out STD_LOGIC                       -- Direction (1=up, 0=down)
    );
end elevator_controller;

architecture Behavioral of elevator_controller is
    
    -- FSM State Definition
    type state_type is (
        IDLE,           -- Elevator is idle with doors closed
        DOOR_OPENING,   -- Doors are opening
        DOOR_OPEN_WAIT, -- Doors are open, waiting
        DOOR_CLOSING,   -- Doors are closing
        MOVING_UP,      -- Elevator is moving up
        MOVING_DOWN     -- Elevator is moving down
    );
    
    signal current_state, next_state : state_type;
    
    -- Internal signals
    signal current_floor_reg : unsigned(1 downto 0) := "00";  -- Current floor (0-3)
    signal target_floor      : unsigned(1 downto 0);           -- Target floor
    signal timer_count       : unsigned(7 downto 0) := (others => '0');  -- Timer for door operations
    signal floor_requests    : STD_LOGIC_VECTOR(3 downto 0);  -- Registered floor requests
    
    -- Constants for timing (in clock cycles)
    constant DOOR_WAIT_TIME  : unsigned(7 downto 0) := to_unsigned(50, 8);   -- Door open time
    constant DOOR_MOVE_TIME  : unsigned(7 downto 0) := to_unsigned(20, 8);   -- Door opening/closing time
    constant FLOOR_MOVE_TIME : unsigned(7 downto 0) := to_unsigned(100, 8);  -- Time to move one floor
    
begin
    
    -- Output current floor
    current_floor <= std_logic_vector(current_floor_reg);
    
    -- State Register Process (Sequential Logic)
    state_register: process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            current_floor_reg <= "00";  -- Start at floor 0
            floor_requests <= (others => '0');
            timer_count <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- Register floor requests
            floor_requests <= floor_requests or floor_req;
            
            -- Clear current floor request when reached
            if current_state = DOOR_OPEN_WAIT then
                floor_requests(to_integer(current_floor_reg)) <= '0';
            end if;
            
            -- Update floor position when moving
            if current_state = MOVING_UP and timer_count = FLOOR_MOVE_TIME then
                current_floor_reg <= current_floor_reg + 1;
                timer_count <= (others => '0');
            elsif current_state = MOVING_DOWN and timer_count = FLOOR_MOVE_TIME then
                current_floor_reg <= current_floor_reg - 1;
                timer_count <= (others => '0');
            elsif current_state = MOVING_UP or current_state = MOVING_DOWN then
                timer_count <= timer_count + 1;
            elsif current_state = DOOR_OPENING or current_state = DOOR_CLOSING or current_state = DOOR_OPEN_WAIT then
                timer_count <= timer_count + 1;
            else
                timer_count <= (others => '0');
            end if;
        end if;
    end process state_register;
    
    -- Next State Logic and Target Floor Calculation
    next_state_logic: process(current_state, floor_requests, current_floor_reg, timer_count)
    begin
        -- Default assignment
        next_state <= current_state;
        target_floor <= current_floor_reg;
        
        -- Find target floor (nearest request)
        for i in 0 to 3 loop
            if floor_requests(i) = '1' then
                target_floor <= to_unsigned(i, 2);
                exit;
            end if;
        end loop;
        
        -- State machine transitions
        case current_state is
            
            when IDLE =>
                if floor_requests /= "0000" then
                    if target_floor = current_floor_reg then
                        next_state <= DOOR_OPENING;
                    elsif target_floor > current_floor_reg then
                        next_state <= MOVING_UP;
                    else
                        next_state <= MOVING_DOWN;
                    end if;
                end if;
            
            when DOOR_OPENING =>
                if timer_count >= DOOR_MOVE_TIME then
                    next_state <= DOOR_OPEN_WAIT;
                end if;
            
            when DOOR_OPEN_WAIT =>
                if timer_count >= DOOR_WAIT_TIME then
                    next_state <= DOOR_CLOSING;
                end if;
            
            when DOOR_CLOSING =>
                if timer_count >= DOOR_MOVE_TIME then
                    next_state <= IDLE;
                end if;
            
            when MOVING_UP =>
                if current_floor_reg = target_floor then
                    next_state <= DOOR_OPENING;
                elsif timer_count >= FLOOR_MOVE_TIME then
                    -- Stay in MOVING_UP, floor will be updated
                    next_state <= MOVING_UP;
                end if;
            
            when MOVING_DOWN =>
                if current_floor_reg = target_floor then
                    next_state <= DOOR_OPENING;
                elsif timer_count >= FLOOR_MOVE_TIME then
                    -- Stay in MOVING_DOWN, floor will be updated
                    next_state <= MOVING_DOWN;
                end if;
            
            when others =>
                next_state <= IDLE;
                
        end case;
    end process next_state_logic;
    
    -- Output Logic
    output_logic: process(current_state)
    begin
        -- Default outputs
        door_open <= '0';
        moving <= '0';
        direction <= '0';
        
        case current_state is
            when IDLE =>
                door_open <= '0';
                moving <= '0';
                
            when DOOR_OPENING | DOOR_OPEN_WAIT =>
                door_open <= '1';
                moving <= '0';
                
            when DOOR_CLOSING =>
                door_open <= '0';
                moving <= '0';
                
            when MOVING_UP =>
                door_open <= '0';
                moving <= '1';
                direction <= '1';
                
            when MOVING_DOWN =>
                door_open <= '0';
                moving <= '1';
                direction <= '0';
                
            when others =>
                door_open <= '0';
                moving <= '0';
                
        end case;
    end process output_logic;

end Behavioral;
