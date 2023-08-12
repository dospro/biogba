import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test B opcode with simple small address
*/
fn test_assembler_b_opcode() {
	opcode_string := 'B #100'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		target_address: 0x400
	}

	assert opcode is biogba.BOpcode
	if opcode is biogba.BOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test B opcode with conditional
*/
fn test_assembler_b_condition() {
	opcode_string := 'BEQ #1000'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		condition: .eq
		target_address: 0x4000
	}

	assert opcode is biogba.BOpcode
	if opcode is biogba.BOpcode {
		assert opcode == expected_opcode
	}
}
