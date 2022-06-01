import biogba

fn test_adc_opcode_default() {
	opcode := biogba.ADCOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0A0_0000
}

fn test_adc_eq_condition() {
	opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.eq
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x00A0_0000
}