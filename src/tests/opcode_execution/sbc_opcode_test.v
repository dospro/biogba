import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
The SBC opcode is a Dataprocessing Opcode which is already tested.
*/

/*
Test SBC (reverse substract) opcode performs Rd = Rn - operand + c - 1
Actually, we should substract !c, which translates to c - 1
For the test we assume C is 0, so the operation will be

0x0000_FF00 - 0x0000_EE00 + 0 - 1
which will result in 0x0000_10FF
*/
fn test_sbc() {
	mut cpu_state := CPUState{}
	cpu_state.r[13] = 0 // rd
	cpu_state.r[14] = 0x0000_FF00 // rn
	cpu_state.cpsr.c = false //  Make sure it is off

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.SBCOpcode{
		rd:            13
		rn:            14
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xEE
			rotate: 12
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[13] == 0x0000_10FF
}
