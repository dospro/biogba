import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test the BIC operation with 2 values

BIC opcode is used to clear bits of Rn and then assign the result to rd
The test will start with Rn=0xFFFF_FFFF and resets bits
0x0011_0000 resulting in 0xFFEE_FFFF
*/
fn test_bic_operation() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0
	cpu_state.r[1] = 0xFFFF_FFFF

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.BICOpcode{
		rd: 0x0
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 8
			value: 0x11
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	obtained := result.r[0]
	assert obtained == 0xFFEE_FFFF
}
