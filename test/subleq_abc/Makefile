# Makefile for Cocotb subleq ABC (3-memory) test

# use verilator as simulator
SIM ?= verilator

# use verilog as language
TOPLEVEL_LANG ?= verilog

# suppress warnings
VERILATOR_ARGS += -Wno-WIDTHTRUNC

# Verilog source files for subleq ABC design (relative paths)
VERILOG_SOURCES = \
    ../../hw_sim_abc/subleq.v \
    ../../hw_sim_abc/control_abc.v \
    ../../hw_sim_abc/datapath_abc.v \
    ../../hw_sim_abc/memory_abc.v \
    ../../hw_sim_abc/pc_incre_abc.v \
    ../../hw_sim_abc/alu.v

# Top-level module and Python test module
TOPLEVEL    = subleq
MODULE      = test_subleq_abc

# Include Cocotb simulation Makefile (auto-detects simulator and runs tests)
include $(shell cocotb-config --makefiles)/Makefile.sim 