import src.biogba
import src.tests.mocks

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test LDM Opcode which loads values from memory into registers.

Tests a simple case where we load the value 0x1234_1234 from memory
into register 0
*/
fn test_ldm_single_register() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [.r0]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test ldm with multiple registers
The test will load a value to all pair registers
Configuration
- Post increment with no writeback
*/
fn test_ldm_multiple_register() {
	mut memory := mocks.MemoryFake{}
	values := [
		u32(0x1111_1111),
		0x2222_2222,
		0x3333_3333,
		0x4444_4444,
		0x5555_5555,
		0x6666_6666,
		0x7777_7777,
		0x8888_8888,
	]
	memory.set_values32(0, values)
	mut cpu_state := CPUState{}

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [.r0, .r2, .r4, .r6, .r8, .r10, .r12, .r14]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	for i, value in values {
		assert result.r[i * 2] == value
	}
}

/*
Test LDM with decrement offsets

The test follows the documentation example where Rn starts at 0x1000
and we load R1, R5 and R7.

Note: When using decrement (U=0) the order of the registers is reversed

At the end the result should look like this:
[0x1000] -> R7
[0x0FFC] -> R5
[0x0FF8] -> R1
0x1000 -> Rn

Configuration
- Post Decrement with no writeback
*/
fn test_ldm_decrement() {
	mut memory := mocks.MemoryFake{}
	values := [
		u32(0x1111_1111), // Offset 0x0FF4
		0x2222_2222, // Offset 0x0FF8
		0x3333_3333, // Offset 0x0FFC
		0x4444_4444, // Offset 0x1000
		0x5555_5555
	]
	memory.set_values32(0xFF4, values)
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0x1000 // Upper offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 4
		p_bit: false
		u_bit: false
		w_bit: false
		register_list: [.r1, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[4] == 0x1000
	assert result.r[1] == 0x2222_2222
	assert result.r[5] == 0x3333_3333
	assert result.r[7] == 0x4444_4444
	
}

/*
Test LDM with preindex
The test will load 3 registers but the offset is incremented before fetching
The first value in offset 0 is skipped
*/
fn test_ldm_preindex() {
	mut memory := mocks.MemoryFake{}
	values := [
		u32(0x1111_1111),
		0x2222_2222,
		0x3333_3333,
		0x4444_4444,
	]
	memory.set_values32(0, values)
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0x0

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 4
		p_bit: true
		u_bit: true
		w_bit: false
		register_list: [.r0, .r1, .r2]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x2222_2222
	assert result.r[1] == 0x3333_3333
	assert result.r[2] == 0x4444_4444
}

/*
Test LDM in pre-index with decrement offsets and writeback

The test follows the documentation example where Rn starts at 0xFF4
and we load R1, R5 and R7.

Note: When using decrement (U=0) the order of the registers is reversed

At the end the result should look like this:
[0x0FFC] -> R7
[0x0FF8] -> R5
[0x0FF4] -> R1
0xFF4 -> Rn

Configuration
- Pre Decrement with writeback
*/
fn test_ldm_preindex_decrement_writeback() {
	mut memory := mocks.MemoryFake{}
	values := [
		u32(0x1111_1111),
		0x2222_2222,
		0x3333_3333,
		0x4444_4444,
	]
	memory.set_values32(0xFF4, values)
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0x1000

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 4
		p_bit: true
		u_bit: false
		w_bit: true
		register_list: [.r1, .r3, .r5]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[4] == 0xFF4
	assert result.r[1] == 0x1111_1111
	assert result.r[3] == 0x2222_2222
	assert result.r[5] == 0x3333_3333
}

/*
Test LDM with writeback

The test follow the documentation example.
Rn starts at 0x1000 and will load registers R1, R5 and R7
using pre increment mode.

The result should look like this:

[0x1004] -> R1
[0x1008] -> R3
[0x100C] -> R5
0x100C -> Rn

Configuration
- Pre increment with writeback
*/
fn test_ldm_preindex_inc_writeback() {
	mut memory := mocks.MemoryFake{}
	values := [
		u32(0x1111_1111),
		0x2222_2222,
		0x3333_3333,
		0x4444_4444
	]
	memory.set_values32(0x1000, values)
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0x1000

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDMOpcode{
		rn: 4
		p_bit: true
		u_bit: true
		w_bit: true
		register_list: [.r3, .r1, .r5]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[4] == 0x100C
	assert result.r[1] == 0x2222_2222
	assert result.r[3] == 0x3333_3333
	assert result.r[5] == 0x4444_4444
}
