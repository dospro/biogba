import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test BX but with no change to Thumb mode

The test start with PC=0 and makes a jump to FFFE
T flag should not be set
Final address is FFFE
*/
fn test_bx_no_change_state() {
	mut cpu_state := CPUState{}
	cpu_state.r[5] = 0xFFFE
	cpu_state.r[15] = 0

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.BXOpcode{
		condition: biogba.OpcodeCondition.al
		rm: 0x5
	}

	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	assert result.r[15] == 0xFFFE
	assert !result.cpsr.t
}

/*
Test BX changing to thumb mode

When bit 0 of rm is 1 then cpu changes to thumb mode
This is done by setting cpsr flag t
Also, the final address will have bit0 set to 0
*/
fn test_bx_change_to_thumb() {
	mut cpu_state := CPUState{}
	cpu_state.r[5] = 0x7001
	cpu_state.r[15] = 0

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.BXOpcode{
		condition: biogba.OpcodeCondition.al
		rm: 0x5
	}

	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	assert result.r[15] == 0x7000
	assert result.cpsr.t
}
