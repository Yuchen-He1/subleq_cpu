# use verilator as simulator
SIM ?= verilator

# use verilog as language
TOPLEVEL_LANG ?= verilog

# suppress warnings
VERILATOR_ARGS += -Wno-WIDTHTRUNC

# source code list
VERILOG_SOURCES = ../../datapath.v \
                  ../../alu.v \
                  ../../pc_incre.v \
                  ../../control.v \
                  ../../memory.v

# top level module
TOPLEVEL = datapath

# module to test
MODULE = test_datapath

# include the common Makefile
include $(shell cocotb-config --makefiles)/Makefile.sim 