import biogba {
	ANDOpcode,
}

fn test_and_default() {
	opcode := ANDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE200_0000
}
