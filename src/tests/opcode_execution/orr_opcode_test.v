import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
The ORR opcode is a Dataprocessing Opcode which is already tested.
*/

/*
Test ORR opcode performs Rd = Rn or operand
The test makes the operation 0x0101_8811 or 0x1010_77EE
which will result in 0x1111_FFFF
*/
fn test_orr() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rd
	cpu_state.r[5] = 0x0101_8811 // rn
	cpu_state.r[7] = 0x1010_77EE // rm

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.ORROpcode{
		rd:            0x3
		rn:            0x5
		shift_operand: biogba.ShiftOperandRegister{
			rm:             7
			register_shift: false
			shift_type:     biogba.ShiftType.lsl
			shift_value:    0
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0x1111_FFFF
}
