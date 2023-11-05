import biogba {
	BOpcode,
}

// B, BL

fn test_b() {
	opcode := BOpcode{
		target_address: 0xFF_FFFF
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xEAFF_FFFF
}

fn test_bl() {
	opcode := BOpcode{
		l_flag: true
		target_address: 0x80_0000
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xEB80_0000
}
