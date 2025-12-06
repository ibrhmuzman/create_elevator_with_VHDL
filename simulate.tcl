# Vivado Simulation Script for Elevator Controller
# This script automates the simulation process in Vivado

# Create project
create_project -force elevator_project ./elevator_project -part xc7a35tcpg236-1

# Add VHDL source files
add_files -norecurse ./elevator_controller.vhd
add_files -fileset sim_1 -norecurse ./elevator_controller_tb.vhd

# Set testbench as top module
set_property top elevator_controller_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch simulation
launch_simulation

# Run simulation for sufficient time
run 50000 ns

# Add signals to waveform
add_wave {{/elevator_controller_tb/uut/clk}}
add_wave {{/elevator_controller_tb/uut/reset}}
add_wave {{/elevator_controller_tb/uut/floor_req}}
add_wave {{/elevator_controller_tb/uut/current_floor}}
add_wave {{/elevator_controller_tb/uut/door_open}}
add_wave {{/elevator_controller_tb/uut/moving}}
add_wave {{/elevator_controller_tb/uut/direction}}
add_wave {{/elevator_controller_tb/uut/current_state}}
add_wave {{/elevator_controller_tb/uut/next_state}}
add_wave {{/elevator_controller_tb/uut/current_floor_reg}}
add_wave {{/elevator_controller_tb/uut/target_floor}}
add_wave {{/elevator_controller_tb/uut/floor_requests}}
add_wave {{/elevator_controller_tb/uut/timer_count}}

# Zoom to fit
wave zoom full

puts "Simulation completed successfully!"
puts "You can now view the waveform and analyze the FSM behavior."
