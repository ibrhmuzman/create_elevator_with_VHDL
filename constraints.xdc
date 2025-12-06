## Elevator Controller Constraints File
## Example constraints for Basys3 board (Artix-7)
## Modify pin locations according to your FPGA board

## Clock signal (100 MHz on Basys3)
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset button (BTNC on Basys3)
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports reset]

## Floor request buttons (4 buttons: BTNU, BTND, BTNL, BTNR)
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports {floor_req[0]}]  ;# Floor 0 - BTN UP
set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVCMOS33 } [get_ports {floor_req[1]}]  ;# Floor 1 - BTN LEFT
set_property -dict { PACKAGE_PIN W19  IOSTANDARD LVCMOS33 } [get_ports {floor_req[2]}]  ;# Floor 2 - BTN RIGHT
set_property -dict { PACKAGE_PIN T17  IOSTANDARD LVCMOS33 } [get_ports {floor_req[3]}]  ;# Floor 3 - BTN DOWN

## Current floor display (2 LEDs - binary representation)
set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {current_floor[0]}]  ;# LD0
set_property -dict { PACKAGE_PIN E19  IOSTANDARD LVCMOS33 } [get_ports {current_floor[1]}]  ;# LD1

## Door open indicator (LED)
set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS33 } [get_ports door_open]  ;# LD2

## Moving indicator (LED)
set_property -dict { PACKAGE_PIN V19  IOSTANDARD LVCMOS33 } [get_ports moving]     ;# LD3

## Direction indicator (LED - 1=up, 0=down)
set_property -dict { PACKAGE_PIN W18  IOSTANDARD LVCMOS33 } [get_ports direction]  ;# LD4

## Configuration settings
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Timing constraints
## Set input delay for buttons (assuming 5ns delay)
set_input_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports {floor_req[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports {floor_req[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports reset]
set_input_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports reset]

## Set output delay for LEDs (assuming 5ns delay)
set_output_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports {current_floor[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports {current_floor[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports door_open]
set_output_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports door_open]
set_output_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports moving]
set_output_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports moving]
set_output_delay -clock [get_clocks sys_clk_pin] -min 2 [get_ports direction]
set_output_delay -clock [get_clocks sys_clk_pin] -max 5 [get_ports direction]

## False path for reset (asynchronous)
set_false_path -from [get_ports reset]

## Notes for students:
## 1. These constraints are for Basys3 board - modify for your board
## 2. Check your board's manual for correct pin assignments
## 3. IOSTANDARD should match your board's voltage levels
## 4. Clock frequency should match your board's clock oscillator
## 5. Button debouncing may be needed for physical implementation
