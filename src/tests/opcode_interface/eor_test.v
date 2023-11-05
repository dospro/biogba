import biogba {
	EOROpcode,
	OpcodeCondition,
	ShiftOperandImmediate,
}
// EOR Bit wise exclusive OR

fn test_eor_default() {
	opcode := EOROpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE220_0000
}

fn test_eor() {
	opcode := EOROpcode{
		condition: OpcodeCondition.eq
		rd: 0xA
		rn: 0xB
		shift_operand: ShiftOperandImmediate{
			rotate: 2
			value: 2
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x022B_A202
}
