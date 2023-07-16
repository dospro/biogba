import biogba

/*
Test and opcode in immediate mode
*/
fn test_assembler_and_immediate_mode() {
	opcode_string := 'AND R0, R1, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ANDOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ANDOpcode
	if opcode is biogba.ANDOpcode {
		assert opcode == expected_opcode
	}
}
