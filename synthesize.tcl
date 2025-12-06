# Vivado Synthesis Script for Elevator Controller
# This script performs synthesis and generates reports

# Create project
create_project -force elevator_synth ./elevator_synth -part xc7a35tcpg236-1

# Add VHDL source file (only design, not testbench)
add_files -norecurse ./elevator_controller.vhd

# Set top module
set_property top elevator_controller [get_filesets sources_1]

# Update compile order
update_compile_order -fileset sources_1

# Run synthesis
launch_runs synth_1
wait_on_run synth_1

# Open synthesized design
open_run synth_1

# Generate reports
report_utilization -file elevator_utilization.rpt
report_timing_summary -file elevator_timing.rpt

puts "Synthesis completed successfully!"
puts "Check elevator_utilization.rpt and elevator_timing.rpt for details."
