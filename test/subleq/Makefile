# Makefile for Cocotb subleq top-level test

# use verilator as simulator
SIM ?= verilator

# use verilog as language
TOPLEVEL_LANG ?= verilog

# suppress warnings
VERILATOR_ARGS += -Wno-WIDTHTRUNC

# Verilog source files for subleq design (relative paths)
VERILOG_SOURCES = \
    ../../hw_sim/subleq.v \
    ../../hw_sim/control.v \
    ../../hw_sim/datapath.v \
    ../../hw_sim/memory.v \
    ../../hw_sim/pc_incre.v \
    ../../hw_sim/alu.v

# Top-level module and Python test module
TOPLEVEL    = subleq
MODULE      = test_subleq

# Include Cocotb simulation Makefile (auto-detects simulator and runs tests)
include $(shell cocotb-config --makefiles)/Makefile.sim 