import src.biogba
import src.tests.mocks

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test LDR Opcode which loads a word from memory into a register

Tests a simple case where we load the value 0x1234_1234 from memory
into register 0
*/
fn test_ldr_simple_case() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test LDR Opcode with immediate address

In this test we use a different base register plus immediate address
*/
fn test_ldr_immediate() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x150, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[14] = 0x100 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 14
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x50)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0xFFFF_1010
}

/*
Test LDR Opcode with decrement bit unset

The test sets a value in address 0x90
then it will use the base register rn = 0x100
and an offset of 0x70 which should get substracted
so it can read the value at address 0x90
*/
fn test_ldr_immediate_decrement() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x90, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // Dest register
	cpu_state.r[10] = 0x100 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 10
		rd: 2
		p_bit: true
		u_bit: false
		b_bit: false
		w_bit: false
		address: u16(0x70)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
}

/*
Test LDR Opcode with preindex bit unset (post-index)

In this test the addition is done after loading the value
so the real address is what we have in rd only
*/
fn test_ldr_immediate_postindex() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // Dest register
	cpu_state.r[3] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 3
		rd: 2
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x10)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
}

/*
Test LDR Opcode in preindex without writeback

In preindex mode write back can be enable or diabled.
The test verifies that rn is not updated after the opcode
*/
fn test_ldr_immediate_preindex_no_writeback() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x20, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // Dest register
	cpu_state.r[3] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 3
		rd: 2
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x10)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
	assert result.r[3] == 0x10
}

/*
Test LDR Opcode in preindex mode with writeback

In this case Rn should contain the last address used rn+offset
*/
fn test_ldr_immediate_preindex_with_writeback() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x20, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // Dest register
	cpu_state.r[3] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 3
		rd: 2
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: true
		address: u16(0x10)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
	assert result.r[3] == 0x20
}

/*
Test LDR Opcode in postindex mode with writeback disabled

When using postindex, writeback is always executed
and w should be unset. Setting w will produce other behaviors
*/
fn test_ldr_immediate_postindex_writeback() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0xFFFF_1010)])
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // Dest register
	cpu_state.r[3] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 3
		rd: 2
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x10)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
	assert result.r[3] == 0x20
}

/*
Test LDR Opcode with immediate address but not word aligned.

In this test the address is misaligned by 1 so the operation
should results in the following:
rd = [address] >> 8
*/
fn test_ldr_immediate_unaligned_1() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x0, [u32(0x1111_2222), 0x3333_4444]) // [22, 22, 11, 11, 44, 44, 33, 33]
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0x1 // Offset misaligned by 1

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x2211_1122
}

/*
Test LDR Opcode with immediate address but not word aligned by 2.

In this test the address is misaligned by 2 so the operation
should results in the following:
rd = [address] >> 8x2
*/
fn test_ldr_immediate_unaligned_2() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x0, [u32(0x1111_2222), 0x3333_4444]) // [22, 22, 11, 11, 44, 44, 33, 33]
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0x0

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x2) // Offset misaligned by 2
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x2222_1111
}

/*
Test LDR Opcode with immediate address but not word aligned by 3.

In this test the address is misaligned by 3 so the operation
should results in the following:
rd = [address] >> 8x3
*/
fn test_ldr_immediate_unaligned_3() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x0, [u32(0x1111_2222), 0x3333_4444]) // [22, 22, 11, 11, 44, 44, 33, 33]
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // Dest register
	cpu_state.r[1] = 0x0

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x3) // Offset misaligned by 3
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1122_2211
}

/*
Test LDR Opcode in register mode with LSL shift

The test will have I set indicating that the offset
will be calculated based on a register and a shift value
And the type of shift will be LSL

First we specify R2 with value and in the shift operand
we specify a LSL with a shift of 4 which will produce
an offset of 0x10 which is where the expected value is.
*/
fn test_ldr_register_lsl() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x0 // Dest register
	cpu_state.r[1] = 0x0 // Base register
	cpu_state.r[2] = 0x1 // Register offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: biogba.RegisterOffset{
			rm: 0x2
			shift_type: biogba.ShiftType.lsl
			shift_value: 4
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test LDR Opcode in register mode with LSR shift

First we specify R2 with value and in the shift operand
we specify a LSR with a shift of 1 which will produce
an offset of 0x10 which is where the expected value is.
*/
fn test_ldr_register_lsr() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x10, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x0 // Dest register
	cpu_state.r[1] = 0x0 // Base register
	cpu_state.r[2] = 0x20 // Register offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: biogba.RegisterOffset{
			rm: 0x2
			shift_type: biogba.ShiftType.lsr
			shift_value: 1
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test LDR Opcode in register mode with ASR shift

The test starts with Rn=0x200(base) and Rm=0xFFFF_0000(offset)
An arithmetic shift is applied to Rm whic will get 0xFFFF_FF00
When adding 0x200 + 0xFFFF_FF00 we get 0x1_0000_0100
Since the address bus is 32 bits, then only 0x100 is taken in
consideration resulting in a a final address of 0x100
*/
fn test_ldr_register_asr() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x100, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x0 // Dest register
	cpu_state.r[1] = 0x200 // Base register
	cpu_state.r[2] = 0xFFFF_0000 // Register offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: biogba.RegisterOffset{
			rm: 0x2
			shift_type: biogba.ShiftType.asr
			shift_value: 8
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test LDR Opcode in register mode with ROR shift

In this test we start with R2 containing a value of
0x0000_FFFF which will be rotated right 8 bits to produce
a value of 0xFF00_00FF which will then be subtracted to
the base R1 which is preloaded with a value of 0xFF00_01FF
producing an address of 0x100 where the actual value is.
*/
fn test_ldr_register_ror() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x100, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x0 // Dest register
	cpu_state.r[1] = 0xFF00_01FF // Base register
	cpu_state.r[2] = 0x0000_FFFF // Register offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: false
		b_bit: false
		w_bit: false
		address: biogba.RegisterOffset{
			rm: 0x2
			shift_type: biogba.ShiftType.ror
			shift_value: 8
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x1234_4321
}

/*
Test LDRB opcode which is LDR but with B bit set

The test starts setting a word in memory address 0x100 with
the value 0x1234_4321.
The base address is 0xB0 and the offset address is 0x50 which
when added will result in a final address of 0x100

Considering tha little-endianess, the value at 0x100 should be the LSB
byte 0x21 of the word
*/
fn test_ldr_byte() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x100, [u32(0x1234_4321)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x0 // Dest register
	cpu_state.r[1] = 0xB0 // Base register

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.LDROpcode{
		rn: 1
		rd: 0
		p_bit: true
		u_bit: true
		b_bit: true
		w_bit: false
		address: u16(0x50)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x21
}
