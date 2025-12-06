# Makefile for Elevator Controller VHDL Project
# This makefile provides convenient commands for simulation and synthesis

# Variables
DESIGN = elevator_controller
TB = elevator_controller_tb
VIVADO = vivado
XVLOG = xvlog
XELAB = xelab
XSIM = xsim

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Elevator Controller VHDL Project - Available Commands:"
	@echo ""
	@echo "  make simulate     - Run simulation using TCL script"
	@echo "  make synthesize   - Run synthesis using TCL script"
	@echo "  make clean        - Remove generated files"
	@echo "  make view-wave    - Open waveform viewer (after simulation)"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Xilinx Vivado must be installed and in PATH"
	@echo ""

# Simulate the design
.PHONY: simulate
simulate:
	@echo "Starting simulation..."
	$(VIVADO) -mode batch -source simulate.tcl
	@echo "Simulation completed. Check the waveform viewer."

# Synthesize the design
.PHONY: synthesize
synthesize:
	@echo "Starting synthesis..."
	$(VIVADO) -mode batch -source synthesize.tcl
	@echo "Synthesis completed. Check the report files."

# View waveform (requires previous simulation)
.PHONY: view-wave
view-wave:
	@if [ -d "elevator_project" ]; then \
		echo "Opening waveform viewer..."; \
		$(VIVADO) elevator_project/elevator_project.xpr; \
	else \
		echo "Error: No simulation found. Run 'make simulate' first."; \
	fi

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -rf elevator_project/
	rm -rf elevator_synth/
	rm -rf .Xil/
	rm -rf xsim.dir/
	rm -f *.jou
	rm -f *.log
	rm -f *.pb
	rm -f *.wdb
	rm -f *.rpt
	rm -f *.str
	@echo "Clean completed."

# Quick simulation (command-line based, no GUI)
.PHONY: sim-quick
sim-quick:
	@echo "Running quick command-line simulation..."
	@echo "This is an advanced option - use 'make simulate' for full GUI simulation"
	@echo "Not implemented - use Vivado GUI or 'make simulate'"

# Check if Vivado is in PATH
.PHONY: check-vivado
check-vivado:
	@which $(VIVADO) > /dev/null || \
		(echo "Error: Vivado not found in PATH. Please install Xilinx Vivado." && exit 1)
	@echo "Vivado found: $$(which $(VIVADO))"

# Display project information
.PHONY: info
info:
	@echo "Project Information:"
	@echo "  Design:      $(DESIGN).vhd"
	@echo "  Testbench:   $(TB).vhd"
	@echo "  Constraints: constraints.xdc"
	@echo ""
	@echo "Documentation:"
	@echo "  README.md - Main documentation"
	@echo "  QUICK_START.md - Quick start guide"
	@echo "  FSM_DIAGRAM.md - FSM detailed documentation"
	@echo ""
	@ls -lh *.vhd *.xdc *.tcl 2>/dev/null || echo "  (Source files not found in current directory)"
