# SUBLEQ CPU FPGA Deployment Guide (Windows + Vivado)

This project deploys a SUBLEQ CPU to the Nexys A7-100T FPGA development board with the following features:
- BRAM memory with program preloading
- 7-segment display showing result register output
- LED debugging indicators
- Slow CPU clock frequency for visible operation

## File Description

### Core Files
- `top_nexys_a7.v` - Top-level module connecting FPGA pins
- `subleq_with_output.v` - SUBLEQ CPU module with output
- `datapath_with_output.v` - Datapath with output capability
- `memory_bram.v` - BRAM memory module
- `seven_seg_display.v` - 7-segment display controller
- `nexys_a7_100t.xdc` - Pin constraint file
- `program.hex` - Program initialization file

### Existing Modules (Reused)
- `control.v` - Control unit
- `alu.v` - Arithmetic Logic Unit
- `pc_incre.v` - Program counter incrementer

## Windows Deployment Steps

### 1. Prerequisites
Ensure you have installed:
- Xilinx Vivado 2020.1 or newer
- Nexys A7-100T development board drivers

### 2. Create Vivado Project

#### Manual Project Creation
1. Open Vivado, select "Create Project"
2. Project name: `subleq_cpu_nexys_a7`
3. Select device: `xc7a100tcsg324-1`
4. Select development board: `Nexys A7-100T`
5. Add source files:
   - All .v files
   - program.hex (set as Memory Initialization Files)
6. Add constraint file: `nexys_a7_100t.xdc`
7. No Clock Wizard IP needed (uses simple clock divider)

### 3. Synthesis and Implementation

Execute the following steps in Vivado:

1. **Run Synthesis**:
   ```tcl
   launch_runs synth_1 -jobs 4
   wait_on_run synth_1
   ```

2. **Run Implementation**:
   ```tcl
   launch_runs impl_1 -to_step write_bitstream -jobs 4
   wait_on_run impl_1
   ```

Or use GUI:
- Click "Run Synthesis"
- After synthesis completes, click "Run Implementation"
- After implementation completes, click "Generate Bitstream"

### 4. Download to FPGA

1. Connect Nexys A7-100T development board to computer
2. Open Hardware Manager: `Open Hardware Manager`
3. Connect hardware: `Open target` -> `Auto Connect`
4. Download bitstream: `Program device`
5. Select the generated .bit file for download

## Hardware Interface Description

### Inputs
- **CPU_RESETN**: Reset button (on-board reset button, active low)
- **BTNC**: Center button (manual reset)
- **CLK100MHZ**: 100MHz on-board clock

### Outputs
- **SEG[6:0]**: 7-segment display segments (active low)
- **AN[7:0]**: 7-segment display anodes (active low)
- **LED[15:0]**: 16 LED indicators

### LED Function Description
- `LED[15:12]`: CPU state display (4-bit state machine)
- `LED[11:8]`: Result register upper 4 bits
- `LED[7:4]`: Result register lower 4 bits
- `LED[3]`: CPU clock enable indicator (~0.5Hz)
- `LED[2]`: Reset status (inverted)
- `LED[1]`: Heartbeat indicator (~12Hz fast blink)
- `LED[0]`: Result register activity indicator

### 7-Segment Display
- Displays CPU state and result register lower 16 bits
- Left 3 digits: Show `000`
- 5th digit: Show CPU state (0-C hexadecimal)
- Right 4 digits: Show result register lower 16 bits

## 使用说明

1. **上电复位**：按下CPU_RESETN按钮或BTNC按钮进行复位
2. **观察运行**：
   - LED显示CPU状态和result值
   - 7段数码管显示完整的result值
3. **调试**：通过LED状态判断CPU运行情况

## 修改程序

要运行不同的SUBLEQ程序：

1. 修改`program.hex`文件内容
2. 重新运行综合和实现
3. 下载新的比特流到FPGA

## 故障排除

### 常见问题

1. **时钟不锁定**：
   - 检查Clock Wizard配置
   - 确认输入时钟频率设置正确

2. **数码管不显示**：
   - 检查约束文件引脚分配
   - 确认7段数码管控制逻辑

3. **CPU不运行**：
   - 检查复位逻辑
   - 确认program.hex文件格式正确

4. **综合错误**：
   - 检查所有源文件是否添加
   - 确认模块实例化名称匹配

### 调试技巧

1. 使用ILA（Integrated Logic Analyzer）观察内部信号
2. 通过LED状态判断CPU运行状态
3. 检查Timing Report确保时序满足要求

## 性能参数

- **时钟频率**：1MHz（可在Clock Wizard中调整）
- **存储器大小**：1K × 64位 BRAM
- **显示刷新率**：约763Hz（7段数码管）
- **资源使用**：约占用FPGA资源的5-10%

## 扩展功能

可以考虑添加：
- UART串口通信
- 更多调试LED
- 按钮输入控制
- 更大的存储器空间
- 可变时钟频率控制 