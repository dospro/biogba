import biogba {
	CMNOpcode,
	OpcodeCondition,
	ShiftOperandImmediate,
}
// CMN Compare negative

fn test_cmn() {
	opcode := CMNOpcode{
		condition: OpcodeCondition.lt
		rd: 0x1
		rn: 0x2
		shift_operand: ShiftOperandImmediate{
			rotate: 1
			value: 1
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xB372_1101
}
