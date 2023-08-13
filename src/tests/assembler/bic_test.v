import biogba
import biogba.arm_assembler { opcode_from_string }

/*
Test assembler BIC opcode simple case
*/
fn test_assembler_bic_opcode() {
	opcode_string := 'BICNES R0, R1, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BICOpcode{
		condition: biogba.OpcodeCondition.ne
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.BICOpcode
	if opcode is biogba.BICOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test assembler BIC register register mode

All addressing modes are covered from ADC opcode
*/
fn test_assembler_bic_register_register() {
	opcode_string := 'BIC R0, R1, R2, ASR, R3'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BICOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x0
		rn: 0x1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: true
			shift_type: biogba.ShiftType.asr
			shift_value: 3
		}
	}

	assert opcode is biogba.BICOpcode
	if opcode is biogba.BICOpcode {
		assert opcode == expected_opcode
	}
}
