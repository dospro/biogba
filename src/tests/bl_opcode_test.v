import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type BOpcode = biogba.BOpcode

fn test_branch() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xF] = 0

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := BOpcode{
		target_address: 0x10_FFFF
	}

	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	assert result.r[15] == 0x43_FFFC
}

fn test_b_with_negative_offest() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xF] = 0xF000_0000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := BOpcode{
		target_address: 0x80_FFFF
	}

	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	// 32 bits negative number: 0xFF80_FFFF = -0x7F0001
	// shifted left twice: 0xFE03_FFFC = -0x1FC0004
	// -0x7F0001 == -0x1FC0004 >> 2

	assert result.r[15] == 0xF000_0000 + 0xFE03_FFFC
	assert result.r[15] == 0xF000_0000 - 0x1FC_0004
}

fn test_bl() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xF] = 0x100

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := BOpcode{
		target_address: 0x10
		l_flag: true
	}

	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	assert result.r[15] == 0x140
	assert result.r[14] == 0x104
}