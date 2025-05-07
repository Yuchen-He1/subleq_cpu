import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

# State definitions
FETCH_A     = 0
LOAD_A      = 1
FETCH_B     = 2
LOAD_B      = 3
FETCH_C     = 4
LOAD_C      = 5
FETCH_MEM_A = 6
LOAD_MEM_A  = 7
FETCH_MEM_B = 8
LOAD_MEM_B  = 9
EXECUTE     = 10
WRITEBACK   = 11
UPDATE_PC   = 12

@cocotb.test()
async def test_memory_init(dut):
    """Test memory initialization"""
    
    # Initialize clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst.value = 1
    await Timer(20, units="ns")
    dut.rst.value = 0
    await Timer(20, units="ns")
    
    # Initialize control signals
    dut.a_ld.value = 0
    dut.b_ld.value = 0
    dut.c_ld.value = 0
    dut.mem_a_ld.value = 0
    dut.mem_b_ld.value = 0
    dut.result_ld.value = 0
    dut.mem_read.value = 0
    dut.mem_write.value = 0
    dut.pc_ld.value = 0
    dut.state.value = 0  # FETCH_A state
    
    print("\nTesting memory initialization...")
    
    # Expected initial values from program.hex
    expected_values = {
        0: 0x3,  # First instruction: A
        1: 0x4,  # First instruction: B
        2: 0x6,  # First instruction: C
        3: 0x7,  # Second instruction: A
        4: 0x7,  # Second instruction: B
        5: 0x7,  # Second instruction: C
        6: 0x3,  # Third instruction: A
        7: 0x4,  # Third instruction: B
        8: 0x0   # Third instruction: C
    }
    
    # Read and verify each memory location
    for addr in range(9):
        # Set PC to current address
        dut.pc.value = addr  # Each instruction is 1 word
        await RisingEdge(dut.clk)
        
        # Enable memory read
        dut.mem_read.value = 1
        await RisingEdge(dut.clk)
        dut.mem_read.value = 0
        await Timer(10, units="ns")
        
        # Get memory value
        mem_value = dut.mem_data_out.value.integer
        expected = expected_values[addr]
        
        print(f"mem[{addr}] = {mem_value} (expected: {expected})")
        
        # Verify value
        assert mem_value == expected, \
            f"Memory location {addr} has incorrect value. Expected {expected}, got {mem_value}"
    
    print("\nMemory initialization test passed!")

@cocotb.test()
async def test_datapath_sequential(dut):
    """Test sequential SUBLEQ operations in datapath"""
    
    # Initialize clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst.value = 1
    await Timer(20, units="ns")
    dut.rst.value = 0
    await Timer(20, units="ns")
    
    # Initialize control signals
    dut.a_ld.value = 0
    dut.b_ld.value = 0
    dut.c_ld.value = 0
    dut.mem_a_ld.value = 0
    dut.mem_b_ld.value = 0
    dut.result_ld.value = 0
    dut.mem_read.value = 0
    dut.mem_write.value = 0
    dut.pc_ld.value = 0
    dut.state.value = FETCH_A
    
    # print("\nInitial memory contents:")
    # for addr in range(9):  # Print first 9 locations
    #     # Set PC to current address and enable PC load
    #     dut.pc_ld.value = 1
    #     dut.pc.value = addr
    #     await RisingEdge(dut.clk)
    #     dut.pc_ld.value = 0
        
    #     dut.mem_read.value = 1
    #     await RisingEdge(dut.clk)
    #     dut.mem_read.value = 0
    #     await Timer(10, units="ns")
    #     print(f"mem[{addr}] = {dut.mem_data_out.value}")
    
    print("Starting program execution...")
    # Manually step through CPU states for 3 SUBLEQ instructions
    states = [
        FETCH_A, LOAD_A,
        FETCH_B, LOAD_B,
        FETCH_C, LOAD_C,
        FETCH_MEM_A, LOAD_MEM_A,
        FETCH_MEM_B, LOAD_MEM_B,
        EXECUTE,
        WRITEBACK,
        UPDATE_PC
    ]
    for _ in range(5):
        for st in states:
            # Drive the state and control signals
            dut.state.value = st
            dut.a_ld.value      = 1 if st == LOAD_A      else 0
            dut.b_ld.value      = 1 if st == LOAD_B      else 0
            dut.c_ld.value      = 1 if st == LOAD_C      else 0
            dut.mem_a_ld.value  = 1 if st == LOAD_MEM_A  else 0
            dut.mem_b_ld.value  = 1 if st == LOAD_MEM_B  else 0
            dut.result_ld.value = 1 if st == EXECUTE     else 0
            dut.mem_read.value  = 1 if st in (
                FETCH_A, FETCH_B, FETCH_C,
                FETCH_MEM_A, FETCH_MEM_B
            ) else 0
            dut.mem_write.value = 1 if st == WRITEBACK   else 0
            if st == UPDATE_PC:
                dut.pc_ld.value = 1 if (dut.zero.value or dut.negative.value) else 0
            else:
                dut.pc_ld.value = 0
            # One cycle per state 
            await RisingEdge(dut.clk)
    print("Program execution completed")
    
