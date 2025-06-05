import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# @cocotb.test()
# async def test_subleq_abc_basic(dut):
#     """Test basic functionality of the 3-memory SUBLEQ processor."""
#     # Start clock
#     cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

#     # Apply reset
#     dut.rst.value = 1
#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)
#     dut.rst.value = 0

#     cocotb.log.info("Reset released, starting test...")

#     # Run for a number of cycles
#     # New FSM has 5 states instead of 13, so each instruction takes 5 cycles
#     cycle_count = 0
#     max_cycles = 100  # Prevent infinite loops
    
#     initial_pc = dut.dp_inst.pc.value.integer
#     cocotb.log.info(f"Initial PC: {initial_pc}")
    
#     # Run until we see some state changes or hit max cycles
#     for cycle in range(max_cycles):
#         await RisingEdge(dut.clk)
#         cycle_count += 1
        
#         current_pc = dut.dp_inst.pc.value.integer
#         current_state = dut.state.value.integer
        
#         if cycle % 10 == 0:  # Log every 10 cycles
#             cocotb.log.info(f"Cycle {cycle_count}: PC={current_pc}, State={current_state}")
            
#             # Log register values
#             a_reg = dut.dp_inst.a_reg.value.integer
#             b_reg = dut.dp_inst.b_reg.value.integer
#             c_reg = dut.dp_inst.c_reg.value.integer
#             cocotb.log.info(f"  Registers: A={a_reg}, B={b_reg}, C={c_reg}")

#     # Dump first few memory entries from each memory
#     cocotb.log.info("Memory A contents:")
#     for i in range(5):
#         val = dut.dp_inst.mem_inst.mem_a[i].value.integer
#         cocotb.log.info(f"  mem_a[{i}] = 0x{val:016x}")
        
#     cocotb.log.info("Memory B contents:")
#     for i in range(5):
#         val = dut.dp_inst.mem_inst.mem_b[i].value.integer
#         cocotb.log.info(f"  mem_b[{i}] = 0x{val:016x}")
        
#     cocotb.log.info("Memory C contents:")
#     for i in range(5):
#         val = dut.dp_inst.mem_inst.mem_c[i].value.integer
#         cocotb.log.info(f"  mem_c[{i}] = 0x{val:016x}")

#     final_pc = dut.dp_inst.pc.value.integer
#     cocotb.log.info(f"Final PC after {cycle_count} cycles: {final_pc}")

@cocotb.test()
async def test_subleq_abc_performance(dut):
    """Test to verify the performance improvement with optimized design."""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    cocotb.log.info("Performance test started...")
    
    # Execute a few instructions and count cycles
    instruction_count = 0
    cycle_count = 0
    dut.dp_inst.pc.value= 10
    prev_pc = dut.dp_inst.pc.value.integer
    await RisingEdge(dut.clk)
    while dut.dp_inst.mem_inst.mem[2].value.integer !=21:  # Run for 50 cycles
        await RisingEdge(dut.clk)
        cycle_count += 1
        
    #     current_pc = dut.dp_inst.pc.value.integer
    #     current_state = dut.state.value.integer
        
    
    # if instruction_count > 0:
    #     cycles_per_instruction = cycle_count / instruction_count
    #     cocotb.log.info(f"Performance: {cycles_per_instruction:.1f} cycles per instruction")
    #     cocotb.log.info(f"(Original design: 13 cycles per instruction)")
    #     cocotb.log.info(f"Speed improvement: {13/cycles_per_instruction:.1f}x")
    # else:
    #     cocotb.log.info("No instructions completed in test period") 
    
    # Print memory contents (unified memory now)
    cocotb.log.info("Memory contents:")
    for i in range(10):
        val = dut.dp_inst.mem_inst.mem[i].value.integer
        cocotb.log.info(f"  mem[{i}] = 0x{val:016x}")
    cocotb.log.info(f"cycle count: {cycle_count}")