import biogba

/*
Test add opcode

Note: All addressing modes are covered in ADC opcode
*/
fn test_assembler_add() {
	opcode_string := 'ADDCCS R0, R1, R2, LSL R3'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADDOpcode{
		condition: biogba.OpcodeCondition.cc
		rd: 0
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: true
			shift_type: biogba.ShiftType.lsl
			shift_value: 3
		}
	}

	assert opcode is biogba.ADDOpcode
	if opcode is biogba.ADDOpcode {
		assert opcode == expected_opcode
	}
}
