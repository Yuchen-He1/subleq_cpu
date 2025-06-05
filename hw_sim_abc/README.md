# SUBLEQ Processor with 3-Memory Architecture

这是一个优化的SUBLEQ处理器设计，使用三个独立的内存来存储A、B、C操作数，以提高性能。

## 主要改进

### 性能提升
- **原始设计**: 13个时钟周期完成一条指令
- **新设计**: 5个时钟周期完成一条指令
- **性能提升**: ~2.6倍加速

### 架构变化

#### 状态机简化
原始的13状态FSM简化为5状态FSM：
```
原始: FETCH_A -> LOAD_A -> FETCH_B -> LOAD_B -> FETCH_C -> LOAD_C -> 
      FETCH_MEM_A -> LOAD_MEM_A -> FETCH_MEM_B -> LOAD_MEM_B -> 
      EXECUTE -> WRITEBACK -> UPDATE_PC

新设计: FETCH_ABC -> LOAD_ABC -> FETCH_MEM_AB -> EXECUTE -> WRITEBACK_UPDATE_PC
```

#### 内存结构
- **原始**: 单一内存存储所有数据
- **新设计**: 三个独立内存分别存储A、B、C操作数

#### 并行操作
- 同时读取A、B、C操作数（FETCH_ABC状态）
- 同时访问mem[A]和mem[B]（FETCH_MEM_AB状态）

## 文件结构

### 硬件模块
- `subleq.v` - 顶层模块，包含简化的5状态FSM
- `control_abc.v` - 控制单元，生成简化的控制信号
- `datapath_abc.v` - 数据通路，使用三内存架构
- `memory_abc.v` - 三内存模块，支持并行读取
- `pc_incre_abc.v` - 程序计数器增量器，适配新状态机
- `alu.v` - ALU模块（与原始设计相同）

### 程序文件
- `program_a.hex` - A操作数内存初始化文件
- `program_b.hex` - B操作数内存初始化文件  
- `program_c.hex` - C操作数内存初始化文件
- `fib_8_a.hex`, `fib_8_b.hex`, `fib_8_c.hex` - 斐波那契程序的分割版本

### 工具
- `split_program.py` - 将原始程序分割为三个操作数文件的工具

## 使用方法

### 测试
```bash
cd test/subleq_abc
make
```

### 更换程序
1. 修改原始程序文件（如program.hex）
2. 运行分割工具：`python3 ../../hw_sim_abc/split_program.py`
3. 重新运行测试

## 设计要点

1. **内存初始化**: 三个内存从各自的hex文件初始化
2. **并行读取**: FETCH_ABC状态同时读取三个操作数
3. **状态优化**: 合并了读取和执行操作
4. **兼容性**: 保持与原始SUBLEQ指令集的兼容性

## 性能分析

新设计通过以下方式实现性能提升：
1. 减少状态数量（13 -> 5）
2. 并行内存访问
3. 优化的控制流水线

这使得每条指令的执行时间从13个时钟周期减少到5个时钟周期，实现了显著的性能提升。 