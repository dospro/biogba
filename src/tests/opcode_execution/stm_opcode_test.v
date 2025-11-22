import src.biogba
import src.tests.mocks

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test STM Opcode which stores values from resgisters into memory.

Tests a simple case where we store register R0 into memory address 0
*/
fn test_stm_single_register() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0x1234_1234 // source register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            1
		register_list: [.r0]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0) == 0x1234_1234
}

/*
Test STM Opcode stores 4 registers
*/
fn test_stm_multiple_registers() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[1] = 0 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            1
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0) == 0x1111_2222
	assert memory.read32(4) == 0x3333_4444
	assert memory.read32(8) == 0x5555_6666
	assert memory.read32(12) == 0x8888_7777
}

/*
Test STM Opcode with different Rn

Uses an offset of 0x24 which is stored in Rn 10
*/
fn test_stm_rn() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[10] = 0x24 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            10
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x24) == 0x1111_2222
	assert memory.read32(0x24 + 4) == 0x3333_4444
	assert memory.read32(0x24 + 8) == 0x5555_6666
	assert memory.read32(0x24 + 12) == 0x8888_7777
}

/*
Test STM Opcode with preindex

Using an offset of 0x10 this time, the infrement occurs before storing
So the first real address is 0x1E
*/
fn test_stm_preindex() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[10] = 0x10 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            10
		p_bit:         true
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x10 + 4) == 0x1111_2222
	assert memory.read32(0x10 + 8) == 0x3333_4444
	assert memory.read32(0x10 + 12) == 0x5555_6666
	assert memory.read32(0x10 + 16) == 0x8888_7777
}

/*
Test STM Opcode with decrement

Using an offset of 0x20, instead of incrementing we decrement in postindex mode
*/
fn test_stm_decrement() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[10] = 0x20 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            10
		u_bit:         false
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x8888_7777
	assert memory.read32(0x20 - 4) == 0x5555_6666
	assert memory.read32(0x20 - 8) == 0x3333_4444
	assert memory.read32(0x20 - 12) == 0x1111_2222
}

/*
Test STM Opcode with writeback

Using an offset of 0x20, Rn should get updated to 0x30
*/
fn test_stm_writeback() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[10] = 0x20 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            10
		w_bit:         true
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x1111_2222
	assert memory.read32(0x20 + 4) == 0x3333_4444
	assert memory.read32(0x20 + 8) == 0x5555_6666
	assert memory.read32(0x20 + 12) == 0x8888_7777
	assert result.r[10] == 0x30
}

/*
Test STM Opcode without writeback

Just make sure Rn is not modified when writeback is disabled
*/
fn test_stm_no_writeback() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x3333_4444 // source register
	cpu_state.r[5] = 0x5555_6666 // source register
	cpu_state.r[7] = 0x8888_7777 // source register
	cpu_state.r[10] = 0x20 // Offset

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn:            10
		w_bit:         false
		register_list: [.r3, .r4, .r5, .r7]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x1111_2222
	assert memory.read32(0x20 + 4) == 0x3333_4444
	assert memory.read32(0x20 + 8) == 0x5555_6666
	assert memory.read32(0x20 + 12) == 0x8888_7777
	assert result.r[10] == 0x20
}

/*
Test STM Opcode when Rn is the first register in register list

This applys only with writeback

In this case the Rn Value is stored unchanged

Note: Registers are always stored in ascending order, so Rn must be 
the lowest number register
*/
fn test_stm_rn_in_register_first() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x20 // Rn
	cpu_state.r[4] = 0x1111_2222 // source register
	cpu_state.r[5] = 0x3333_4444 // source register

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode {
		rn: 3
		w_bit: true
		register_list: [.r3, .r4, .r5]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x20
	assert memory.read32(0x20 + 4) == 0x1111_2222
	assert memory.read32(0x20 + 8) == 0x3333_4444
	assert result.r[3] == 0x2C
}

/*
Test STM Opcode when Rn is the second register in register list

This applys only with writeback

When Rn is included as the second or above element in the list, STM
stores the updated value
*/
fn test_stm_rn_in_register_second() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x20 // Rn
	cpu_state.r[5] = 0x3333_4444 // source register

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode {
		rn: 4
		w_bit: true
		register_list: [.r3, .r4, .r5]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x1111_2222
	assert memory.read32(0x20 + 4) == 0x2C
	assert memory.read32(0x20 + 8) == 0x3333_4444
	assert result.r[4] == 0x2C
}

/*
Test STM Opcode when Rn is the second register in register list
with decrement and postindex.

This applys only with writeback

When Rn is included as the second or above element in the list, STM
stores the updated value
*/
fn test_stm_rn_in_register_second_decrement() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0x1111_2222 // source register
	cpu_state.r[4] = 0x20 // Rn
	cpu_state.r[5] = 0x3333_4444 // source register

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode {
		rn: 4
		u_bit: false
		w_bit: true
		register_list: [.r3, .r4, .r5]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert memory.read32(0x20) == 0x3333_4444
	assert memory.read32(0x20 - 4) == 0x20 - 0xC
	assert memory.read32(0x20 - 8) == 0x1111_2222
	assert result.r[4] == 0x20 - 0xC
}

/*
Test STM Opcode with S bit
When S bit is set, STM stores User bank registers.
For example IRQ mode has its own R13 and R14 banked registers,
so when STM is used with S bit set, the IRQ registers won't be stored
but the user normal registers

S bit should only be used in non-user mode.
In this case, the test start in fiq mode with the s bit set.
The instruction will store the values from the registers from the user bank
and not from the irq bank.
*/
fn test_stm_s_bit_stores_user_bank() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.set_register(8, biogba.CPUMode.fiq, 0x1111_2222)
	cpu_state.set_register(10, biogba.CPUMode.fiq, 0x2222_3333)
	cpu_state.r[0] = 0x0 // Rn
	cpu_state.r[8] = 0x4444_5555
	cpu_state.r[10] = 0x6666_7777
	cpu_state.cpsr.mode = biogba.CPUMode.fiq

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn: 0
		w_bit: false
		s_bit: true
		register_list: [.r8, .r10]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert memory.read32(0) == 0x4444_5555
	assert memory.read32(4) == 0x6666_7777
}

/*
Test STM Opcode without S bit set

Test when in no user mode, the banked registers are stored.
This is a complementary test of the previous one.
*/
fn test_stm_stores_fiq_bank() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.set_register(8, biogba.CPUMode.fiq, 0x1111_2222)
	cpu_state.set_register(10, biogba.CPUMode.fiq, 0x2222_3333)
	cpu_state.r[0] = 0x0 // Rn
	cpu_state.r[8] = 0x4444_5555
	cpu_state.r[10] = 0x6666_7777
	cpu_state.cpsr.mode = biogba.CPUMode.fiq

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn: 0
		w_bit: false
		s_bit: false
		register_list: [.r8, .r10]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert memory.read32(0) == 0x1111_2222
	assert memory.read32(4) == 0x2222_3333
}

/*
Test STM Opcode when S bit is set in user mode
In user mode, there are no banked registers, so S bit should be ignored
resulting in user mode registers being stored.
*/
fn test_stm_s_bit_is_ignored() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.set_register(8, biogba.CPUMode.fiq, 0x1111_2222)
	cpu_state.set_register(10, biogba.CPUMode.fiq, 0x2222_3333)
	cpu_state.r[0] = 0x0 // Rn
	cpu_state.r[8] = 0x4444_5555
	cpu_state.r[10] = 0x6666_7777
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn: 0
		w_bit: false
		s_bit: true
		register_list: [.r8, .r10]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert memory.read32(0) == 0x4444_5555
	assert memory.read32(4) == 0x6666_7777
}

/*
Test STM Opcode when S bit is unset in supervisor mode
In supervisor mode, when S bit is unset, the banked registers are stored.
*/
fn test_stm_without_s_bit_in_supervisor_mode() {
	mut memory := mocks.MemoryFake{}
	memory.set_values32(0, [u32(0)])
	mut cpu_state := CPUState{}
	cpu_state.r14_supervisor = 0x1111_2222
	cpu_state.r[0] = 0x0 // Rn
	cpu_state.r[14] = 0x4444_5555
	cpu_state.cpsr.mode = biogba.CPUMode.supervisor

	mut cpu := ARM7TDMI{
		memory: memory
	}
	cpu.set_state(cpu_state)

	opcode := biogba.STMOpcode{
		rn: 0
		w_bit: false
		s_bit: false
		register_list: [.r14]
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert memory.read32(0) == 0x1111_2222
}

/*
TODO: Test STM Opcode when storing R15 (PC)

When R15 is stored, the value written to memory should be R15+12
due to the ARM7TDMI's instruction prefetch behavior.

This test is currently flagged because the +12 offset should be handled
by proper pipeline implementation, not by STM opcode itself. When the
pipeline is implemented (R15 naturally advancing during fetch/decode/execute),
this test can be enabled and should pass without special handling in STM.
*/
// fn test_stm_stores_r15_plus_12() {
// 	mut memory := mocks.MemoryFake{}
// 	memory.set_values32(0, [u32(0)])
// 	mut cpu_state := CPUState{}
// 	cpu_state.r[15] = 0x1000 // Program counter
// 	cpu_state.r[0] = 0x0 // Base address for storing
// 	cpu_state.r[3] = 0x1111_2222 // Another register to store

// 	mut cpu := ARM7TDMI{
// 		memory: memory
// 	}
// 	cpu.set_state(cpu_state)

// 	opcode := biogba.STMOpcode{
// 		rn: 0
// 		register_list: [.r3, .r15]
// 	}
// 	cpu.execute_opcode(opcode.as_hex())
// 	result := cpu.get_state()

// 	assert memory.read32(0) == 0x1111_2222
// 	assert memory.read32(4) == 0x1000 + 12 // R15 should be stored as R15+12
// }
