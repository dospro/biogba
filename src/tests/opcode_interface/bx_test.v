import biogba {
	BXOpcode,
	OpcodeCondition,
}
// BX Branch and Exchange

fn test_bx() {
	opcode := BXOpcode{
		condition: OpcodeCondition.ne
		rm: 0x2
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x112F_FF12
}
