#!/usr/bin/env python3

# Read the original program
with open('program.hex', 'r') as f:
    lines = f.readlines()

# Remove empty lines and strip whitespace
data = [line.strip() for line in lines if line.strip()]

# Split into A, B, C operands (every 3 consecutive values)
a_data = []
b_data = []
c_data = []

for i in range(0, len(data), 3):
    if i < len(data):
        a_data.append(data[i])
    if i+1 < len(data):
        b_data.append(data[i+1])
    if i+2 < len(data):
        c_data.append(data[i+2])

# Write to separate files
with open('program_a.hex', 'w') as f:
    for item in a_data:
        f.write(item + '\n')

with open('program_b.hex', 'w') as f:
    for item in b_data:
        f.write(item + '\n')

with open('program_c.hex', 'w') as f:
    for item in c_data:
        f.write(item + '\n')

print('Program split into A, B, C files:')
print(f'A operands: {len(a_data)} values')
print(f'B operands: {len(b_data)} values')  
print(f'C operands: {len(c_data)} values')

# Also split the fib_8.hex file
print('\nSplitting fib_8.hex...')
with open('fib_8.hex', 'r') as f:
    lines = f.readlines()

data = [line.strip() for line in lines if line.strip()]

a_data = []
b_data = []
c_data = []

for i in range(0, len(data), 3):
    if i < len(data):
        a_data.append(data[i])
    if i+1 < len(data):
        b_data.append(data[i+1])
    if i+2 < len(data):
        c_data.append(data[i+2])

with open('fib_8_a.hex', 'w') as f:
    for item in a_data:
        f.write(item + '\n')

with open('fib_8_b.hex', 'w') as f:
    for item in b_data:
        f.write(item + '\n')

with open('fib_8_c.hex', 'w') as f:
    for item in c_data:
        f.write(item + '\n')

print(f'Fib A operands: {len(a_data)} values')
print(f'Fib B operands: {len(b_data)} values')  
print(f'Fib C operands: {len(c_data)} values') 