import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
The MOV opcode is a Dataprocessing Opcode
which is already tested.
The following tests only very behavior specific to
the MOV opcode and not the data processing features.
*/


/*
Test MOV opcode loads a value into a register

Note: For MOV opcode, Rn is ignored. The operation is:
Rd = 0xFF ROR 4 (rotate right)
*/
fn test_mov() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rd
	cpu_state.r[5] = 0x0101_FFFF // rn (ignored)

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MOVOpcode{
		rd: 0x3
		rn: 0x5
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 2
			value: 0xFF
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0xF000_000F
}
