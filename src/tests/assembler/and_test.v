import biogba
import biogba.arm_assembler { opcode_from_string }

/*
Test and opcode in immediate mode
*/
fn test_assembler_and_immediate_mode() {
	opcode_string := 'AND R0, R1, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ANDOpcode{
		condition:     biogba.OpcodeCondition.al
		rd:            0
		rn:            1
		s_bit:         false
		shift_operand: biogba.ShiftOperandImmediate{
			value:  1
			rotate: 14
		}
	}

	assert opcode is biogba.ANDOpcode
	if opcode is biogba.ANDOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test and opcode in register immediate mode
*/
fn test_assembler_and_register_immediate_mode() {
	opcode_string := 'ANDEQS R0, R1, R2, ASR, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ANDOpcode{
		condition:     biogba.OpcodeCondition.eq
		rd:            0
		rn:            1
		s_bit:         true
		shift_operand: biogba.ShiftOperandRegister{
			rm:             2
			register_shift: false
			shift_type:     biogba.ShiftType.asr
			shift_value:    0x10
		}
	}

	assert opcode is biogba.ANDOpcode
	if opcode is biogba.ANDOpcode {
		assert opcode == expected_opcode
	}
}

// Note: All other mode are not directly tested as they are covered as a general case for all data processing opcodes
