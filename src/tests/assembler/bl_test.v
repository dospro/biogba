import biogba
import biogba.arm_assembler { opcode_from_string }

/*
Test B opcode with simple small address

The assembler must be able to calculate the real shifted value correctly
*/
fn test_assembler_b_opcode() {
	opcode_string := 'B #400'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		target_address: 0x100
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
	opcode_string := 'BEQ #4000'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		condition: .eq
		target_address: 0x1000
	}

	assert opcode is biogba.BOpcode
	if opcode is biogba.BOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test B opcode with wrong address

Target address must have lower 2 bits set to 0
 */
fn test_assembler_b_wrong_address() {
	opcode_string := 'B #123'
	opcode_from_string(opcode_string) or { return }
	assert false
}

/*
Test BL opcode
*/
fn test_assembler_bl() {
	opcode_string := 'BLHI #80000000'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		condition: .hi
		l_flag: true
		target_address: 0x2000_0000
	}

	assert opcode is biogba.BOpcode
	if opcode is biogba.BOpcode {
		assert opcode == expected_opcode
	}
}
