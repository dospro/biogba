import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ADCOpcode = biogba.ADCOpcode

fn conditional(original_cpu_state CPUState, operation_result u32, skipped bool) {
	mut cpu_state := original_cpu_state
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0xF0F0_F0F0
	cpu_state.r[0x2] = 0x0000_1000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := ADCOpcode{
		condition: biogba.OpcodeCondition.eq
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate {value: 1, rotate: 1}
	}
	cpu.execute_opcode(opcode.as_hex())
	if skipped {
		assert cpu.get_state().r[0] == 0
	} else {
		assert cpu.get_state().r[0] == operation_result
	}
}

fn test_adc_eq_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.z = false
	conditional(cpu_state, 0x30F0_F0F0, true)
	cpu_state.cpsr.z = true
	conditional(cpu_state, 0x30F0_F0F0, false)
}