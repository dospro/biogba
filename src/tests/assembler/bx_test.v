import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test BX opcode
*/
fn test_assembler_bx() {
	opcode_string := 'BXEQ R5'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BXOpcode{
		condition: biogba.OpcodeCondition.eq
		rm: 5
	}

	assert opcode is biogba.BXOpcode
	if opcode is biogba.BXOpcode {
		assert opcode == expected_opcode
	}
}