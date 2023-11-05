import biogba {
	BICOpcode,
	OpcodeCondition,
	ShiftType,
	ShiftOperandRegister,
}
// BIC

fn test_bic_default() {
	opcode := BICOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE3C0_0000
}

fn test_bix_complex() {
	opcode := BICOpcode{
		condition: OpcodeCondition.gt
		rd: 0x7
		rn: 0xC
		s_bit: true
		shift_operand: ShiftOperandRegister{
			rm: 0xA
			register_shift: true
			shift_type: ShiftType.lsr
			shift_value: 0xE
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xC1DC_7E3A
}
