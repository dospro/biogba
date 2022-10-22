import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ANDOpcode = biogba.ANDOpcode

/*
Test the AND operation with 2 values

In this test we use immediate value
*/
fn test_and_operation() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0
	cpu_state.r[1] = 0x0101_FFFF

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ANDOpcode{
		rd: 0x0
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 10
			value: 0xFF
		}
	}
	print("Executing AND opcode")
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	obtained := result.r[0]
	assert obtained == 0x0001_F000
}
