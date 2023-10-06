import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test CMN opcode
*/
fn test_assembler_cmn() {
	opcode_string := 'CMN R1, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.CMNOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 14
			value: 1
		}
	}

	assert opcode is biogba.CMNOpcode
	if opcode is biogba.CMNOpcode {
		assert opcode == expected_opcode
	}
}


/*
Test CMN opcode using register-immediate mode

The test uses LSL shift
*/
fn test_assembler_cmn_register_immediate_mode() {
	opcode_string := 'CMNHI R1, R3, LSL, #1'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.CMNOpcode{
		condition: biogba.OpcodeCondition.hi
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 3
			register_shift : false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	assert opcode is biogba.CMNOpcode
	if opcode is biogba.CMNOpcode {
		assert opcode == expected_opcode
	}
}


/*
Test CMN opcode using register-immediate mode

The test uses LSL shift
*/
fn test_assembler_cmn_register_register_mode() {
	opcode_string := 'CMNEQ R1, R3, ROR, R8'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.CMNOpcode{
		condition: biogba.OpcodeCondition.eq
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 3
			register_shift : true
			shift_type: biogba.ShiftType.ror
			shift_value: 8
		}
	}

	assert opcode is biogba.CMNOpcode
	if opcode is biogba.CMNOpcode {
		assert opcode == expected_opcode
	}
}
