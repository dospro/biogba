import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test the EOR operation with 2 values

EOR is actually the XOR operation. The test makes a XOR an asserts the result.
The test applies 0xFFFF_0004 XOR 0x44 which results in 0xFFFF_0040
*/
fn test_and_operation() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0
	cpu_state.r[1] = 0xFFFF_0004

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.EOROpcode{
		rd: 0x0
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 0xF
			value: 0x11
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	obtained := result.r[0]
	assert obtained == 0xFFFF_0040
	assert result.cpsr.n
}
