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
	mut memory := mocks.MemoryFake {}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu_state := CPUState {}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0 // Offset
	
	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba. LDMOpcode {
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
*/
fn test_ldm_multiple_register() {
	mut memory := mocks.MemoryFake {}
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
	mut cpu_state := CPUState {}
	
	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba. LDMOpcode {
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
The test will fill all even registers, but this time the offset will start
from the top so it can decrement
*/
fn test_ldm_decrement() {
	mut memory := mocks.MemoryFake {}
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
	mut cpu_state := CPUState {}
	cpu_state.r[1] = 0x1C // Upper offset
	
	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba. LDMOpcode {
		rn: 1
		p_bit: false
		u_bit: false
		w_bit: false
		register_list: [.r0, .r2, .r4, .r6, .r8, .r10, .r12, .r14]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x8888_8888
	assert result.r[2] == 0x7777_7777
	assert result.r[4] == 0x6666_6666
	assert result.r[6] == 0x5555_5555
	assert result.r[8] == 0x4444_4444
	assert result.r[10] == 0x3333_3333
	assert result.r[12] == 0x2222_2222
	assert result.r[14] == 0x1111_1111
}
