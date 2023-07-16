import biogba

/*
Test add opcode in immediate mode
*/
fn test_assembler_add_immediate_mode() {
	opcode_string := 'ADD R0, R1, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADDOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ADDOpcode
	if opcode is biogba.ADDOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test add opcode in register immediate mode
*/
fn test_assembler_add_register_immediate_mode() {
	opcode_string := 'ADD R0, R1, R2, ASR, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADDOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0x10
		}
	}

	assert opcode is biogba.ADDOpcode
	if opcode is biogba.ADDOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test add opcode in register rrx mode
*/
fn test_assembler_add_rrx() {
	opcode_string := 'ADD R0, R1, R2, RRX'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADDOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 2
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0
		}
	}

	assert opcode is biogba.ADDOpcode
	if opcode is biogba.ADDOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test add opcode in register-register mode
*/
fn test_assembler_add_register_register_mode() {
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
