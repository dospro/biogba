import biogba {
	ADDOpcode,
	ANDOpcode,
}
// ADD

fn test_add_default() {
	opcode := ADDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE280_0000
}

fn test_and_default() {
	opcode := ANDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE200_0000
}
