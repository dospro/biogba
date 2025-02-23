import biogba {
	SBCOpcode,
	OpcodeCondition,
	ShiftOperandRegister,
	ShiftType,
}

/*
SBC is a data processing opcode, so all the variation
of this interface have already been tested.
*/

/*
Test SBC opcode interface with default values
*/
fn test_sbc_default() {
	opcode := SBCOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2C0_0000
}

/*
Test SBC opcode interface with no default values
Use specific values for all options
*/
fn test_sbc_no_default() {
	opcode := SBCOpcode{
		condition:     OpcodeCondition.ne
		rd:            14
		rn:            10
		s_bit:         true
		shift_operand: ShiftOperandRegister{
			rm:             8
			register_shift: true
			shift_type:     ShiftType.lsl
			shift_value:    0xF
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x10DA_EF18
}
