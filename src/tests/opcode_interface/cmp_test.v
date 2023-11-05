import biogba {
	CMPOpcode,
	OpcodeCondition,
	ShiftOperandImmediate,
}
// CMP Compare negative

fn test_cmp() {
	opcode := CMPOpcode{
		condition: OpcodeCondition.al
		rd: 0x1
		rn: 0x2
		shift_operand: ShiftOperandImmediate{
			rotate: 1
			value: 1
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE352_1101
}
