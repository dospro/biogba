import src.biogba
import src.tests.mocks

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test LDRH Opcode which loads a half-word from memory into a register

Tests a simple case where we load the value 0x4321 from memory
into register 0

Only 16 bits are loaded for opcode LDRH

The words 0x1234_4321 is stored in memory in the following form
A+0: 0x21 lsb
A+1: 0x43
A+2: 0x34
A+3: 0x12 msb
The data bus loads the value 0x0000_4321
Since the address is word aligned then the valid data is 0x4321
So the result is 0x4321 in the register
*/
fn test_ldrh_simple_case() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rn: 1
		rd: 0
		p_bit: false
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x4321
}

/*
Test LDRH Opcode loads into a specific register Rd

The test loads the value at address to register R10
*/
fn test_ldrh_rd() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[10] = 0 // Dest register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 10
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[10] == 0x4321
}

/*
Test LDRH Opcode loads from an address specified in Rn
*/
fn test_ldrh_rn() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x50, [u32(0xFFEE_DDCC)])
	mut cpu_state := CPUState{}
	cpu_state.r[5] = 0 // Dest register
	cpu_state.r[2] = 0x50 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 5
		rn: 2
		p_bit: false
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[5] == 0xDDCC
}

/*
Test LDRH Opcode loads from an offset plus an immediate address

Rn is 0x10 and address is 0x50

*/
fn test_ldrh_immediate() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x60, [u32(0xFFEE_DDCC)])
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0 // Dest register
	cpu_state.r[3] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 4
		rn: 3
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x50)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[4] == 0xDDCC
}

/*
Test LDRH Opcode loads a half-word from half aligned address

When address is half-word aligned:
We have the following words in memory:

0x1122_3344 and 0x5566_7788
These are saved in the form
A+0: 0x44 
A+1: 0x33 
A+2: 0x22 
A+3: 0x11 
A+4: 0x88 
A+5: 0x77 
A+6: 0x66 
A+7: 0x55
Using LDRH from a half-word aligned address will fill
the data bus with the value 0x1122_0000 and because of 
the algnment, bits 16-31 are considered valid so the 
result is 0x1122
*/
fn test_ldrh_half_aligned_address() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x60, [u32(0x1122_3344), u32(0x5566_7788)])
	mut cpu_state := CPUState{}
	cpu_state.r[6] = 0 // Dest register
	cpu_state.r[5] = 0x30 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 6
		rn: 5
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x32)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[6] == 0x1122
}

/*
Test LDRH Opcode with register offset

The test uses rn and base an rm as the offset
*/
fn test_ldrh_rm() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x60, [u32(0x1122_3344)])
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // Dest register
	cpu_state.r[2] = 0x40 // Offset
	cpu_state.r[3] = 0x20 // Rm

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 1
		rn: 2
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: biogba.Register.r3
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x3344
}

/*
Test LDRH opcode with negative offset

When bit u is unset, the offset is substracted from the base.
*/
fn test_ldrh_immediate_negative() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0xFFEE_DDCC)])
	mut cpu_state := CPUState{}
	cpu_state.r[7] = 0 // Dest register
	cpu_state.r[8] = 0x50 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 7
		rn: 8
		p_bit: true
		u_bit: false
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x40)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[7] == 0xDDCC
}

/*
Test LDRH Opcode preindex updates Rn

When in preindex mode, Rn is updated before reading
with the content of the base plus the offset. 
An autoincrement
*/
fn test_ldrh_preindex() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0xFFEE_DDCC)])
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // Dest register
	cpu_state.r[2] = 0xB // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 1
		rn: 2
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x5)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0xDDCC
	assert result.r[2] == 0x10
}

/*
Test LDRH Opcode with preindex bit unset (post-index)

In this test the addition is done after loading the value
so the real address is what we have in rn only.
*/
fn test_ldrh_postindex() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0xFFEE_DDCC)])
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // Dest register
	cpu_state.r[2] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDRSBHOpcode{
		rd: 1
		rn: 2
		p_bit: false
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x40)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0xDDCC
	assert result.r[2] == 0x50
}

/*
Test LDRH Opcode with preindex and no writeback
*/

/*
Test LDRH Opcode with preindex and writeback
*/

/*
Test LDRH Opcode with postindex and no writeback

When using postindex, writeback is always executed
and w should be unset. Setting w will produce other behaviors
*/