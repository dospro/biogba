import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test the CMP operation with 2 values

The test makes sure rd is not modified
*/
fn test_cmp() {
	mut cpu_state := CPUState{}
	
	cpu_state.r[1] = 0x1

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.CMPOpcode{
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 0
			value: 1
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	assert result.r[0] == 0
	assert result.cpsr.z
	assert !result.cpsr.v
	assert !result.cpsr.n
}

/*
Test the CMP operation with 2 values

The compares 2 values which updates cpsr.

The test substract 2 to 1 so the result (-1) sets flags v and n
*/
fn test_cmp_flags() {
	mut cpu_state := CPUState{}
	
	cpu_state.r[1] = 0x1

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.CMPOpcode{
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 0
			value: 2
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	assert result.r[0] == 0
	assert !result.cpsr.z
	assert result.cpsr.v
	assert result.cpsr.n
}
