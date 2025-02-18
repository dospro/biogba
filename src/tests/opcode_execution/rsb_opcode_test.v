import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
The RSB opcode is a Dataprocessing Opcode which is already tested.
*/

/*
Test RSB (reverse substract) opcode performs Rd = operand - Rn
The test makes the operation 0x0000_FF00 - 0x0000_EE00
which will result in 0x0000_1100
*/
fn test_rsb() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rd
	cpu_state.r[5] = 0x0000_EE00 // rn

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.RSBOpcode{
		rd:            0x3
		rn:            0x5
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xFF
			rotate: 12
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0x0000_1100
}
