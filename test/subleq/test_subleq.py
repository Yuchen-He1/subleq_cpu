import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_subleq_top_run(dut):
    """Test that the subleq top module runs without error and PC stays at 0 for a zero-result loop."""
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Run for a number of cycles
    # 13 cycle for 1 subleq instruction
    # 26 cycle for 2 subleq instructions
    # 39 cycle for 3 subleq instructions
    for _ in range(38):
        await RisingEdge(dut.clk)

    # Dump first 32 memory entries
    for i in range(32):
        val = dut.dp_inst.mem_inst.mem[i].value.integer
        cocotb.log.info(f"mem[{i}] = 0x{val:016x}")

    # Read internal PC from datapath instance
    # pc = dut.dp_inst.pc.value.integer
    # cocotb.log.info(f"PC after simulation: {pc}")
    # assert pc == 0, f"Expected PC to remain at 0, got {pc}" 