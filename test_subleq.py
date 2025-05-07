import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

# State definitions
FETCH_A = 0
FETCH_B = 1
FETCH_C = 2
FETCH_MEM_A = 3
FETCH_MEM_B = 4
EXECUTE = 5
WRITEBACK = 6
UPDATE_PC = 7
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
    states = [FETCH_A, FETCH_B, FETCH_C, FETCH_MEM_A, FETCH_MEM_B, EXECUTE, WRITEBACK, UPDATE_PC]
    for _ in range(3):
        for st in states:
            # Drive the state and control signals
            dut.state.value = st
            dut.a_ld.value = 1 if st == FETCH_A else 0
            dut.b_ld.value = 1 if st == FETCH_B else 0
            dut.c_ld.value = 1 if st == FETCH_C else 0
            dut.mem_a_ld.value = 1 if st == FETCH_MEM_A else 0
            dut.mem_b_ld.value = 1 if st == FETCH_MEM_B else 0
            dut.result_ld.value = 1 if st == EXECUTE else 0
            dut.mem_read.value = 1 if st in (FETCH_A, FETCH_B, FETCH_C, FETCH_MEM_A, FETCH_MEM_B) else 0
            dut.mem_write.value = 1 if st == WRITEBACK else 0
            # For UPDATE_PC, load PC only on branch condition
            if st == UPDATE_PC:
                dut.pc_ld.value = 1 if (dut.zero.value or dut.negative.value) else 0
            else:
                dut.pc_ld.value = 0
            # One cycle per state
            await RisingEdge(dut.clk)
    print("Program execution completed")
    
    print("\nFinal memory contents:")
    for addr in range(9):  # Print first 9 locations
        # Force fetch state to read from PC
        dut.state.value = FETCH_A
        dut.mem_read.value = 0  # ensure read_en is low before setting PC
        dut.pc_ld.value = 1
        dut.pc.value = addr
        await RisingEdge(dut.clk)
        dut.pc_ld.value = 0
        
        dut.mem_read.value = 1  # enable memory read
        await RisingEdge(dut.clk)
        dut.mem_read.value = 0
        await Timer(10, units="ns")
        print(f"mem[{addr}] = {dut.mem_data_out.value}")
    
    # Verify final memory contents
    # Expected values:
    # mem[4] should be -28 (after 5 iterations of subtraction)
    # mem[7] should be 0 (after self-subtraction)
    
    # Read mem[4]
    dut.pc_ld.value = 1
    dut.pc.value = 4
    await RisingEdge(dut.clk)
    dut.pc_ld.value = 0
    
    dut.mem_read.value = 1
    await RisingEdge(dut.clk)
    dut.mem_read.value = 0
    await Timer(10, units="ns")
    
    # Verify mem[4] value
    assert dut.mem_data_out.value == -28, \
        f"Expected mem[4] to be -28, got {dut.mem_data_out.value}"
    
    # Read mem[7]
    dut.pc_ld.value = 1
    dut.pc.value = 7
    await RisingEdge(dut.clk)
    dut.pc_ld.value = 0
    
    dut.mem_read.value = 1
    await RisingEdge(dut.clk)
    dut.mem_read.value = 0
    await Timer(10, units="ns")
    
    # Verify mem[7] value
    assert dut.mem_data_out.value == 0, \
        f"Expected mem[7] to be 0, got {dut.mem_data_out.value}"

