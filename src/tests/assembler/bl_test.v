import biogba

/*
Test B opcode with simple small address
*/
fn test_assembler_and_immediate_mode() {
	opcode_string := 'B #100'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BOpcode{
		target_address: 0x400
	}

	assert opcode is biogba.BOpcode
	if opcode is biogba.BOpcode {
		assert opcode == expected_opcode
	}
}
