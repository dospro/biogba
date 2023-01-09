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
		p_bit: false
		u_bit: true
		w_bit: false
		address: u16(0x50)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0xFFFF_1010
}

/*
Test LDR Opcode with decrement bit set

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
		p_bit: false
		u_bit: false
		w_bit: false
		address: u16(0x70)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0xFFFF_1010
}

// fn test_ldr_immediate_preindex() {}
// fn test_ldr_immediate_postindex() {}
// fn test_ldr_immediate_preindex() {}
// fn test_ldr_immediate_preindex() {}
// fn test_ldr_immediate_preindex() {}

/*
Test LDR Opcode with immediate address but not word aligned.

In this test the address is misaligned by 1 so the operation
should results in the following:
rd = [address] >> 8
*/
fn test_ldr_immediate_unaligned_1() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0x0, [u32(0x1111_2222), 0x3333_4444])
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
		w_bit: false
		address: u16(0x0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x0011_2222
}

/*
Test LDR Opcode with immediate address but not word aligned by 2.

In this test the address is misaligned by 2 so the operation
should results in the following:
rd = [address] >> 8x2
*/
// fn test_ldr_immediate_unaligned_2() {}

/*
Test LDR Opcode with immediate address but not word aligned by 3.

In this test the address is misaligned by 3 so the operation
should results in the following:
rd = [address] >> 8x3
*/
// fn test_ldr_immediate_unaligned_3() {}

// fn test_ldr_shift_lsl() {}
// fn test_ldr_shift_lsr() {}
// fn test_ldr_shift_asr() {}
// fn test_ldr_shift_ror() {}
// fn test_ldr_shift_lsr32() {}
// fn test_ldr_shift_asr32() {}
// fn test_ldr_shift_rxx() {}
