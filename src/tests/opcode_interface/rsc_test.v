import biogba {
	RSCOpcode,
	OpcodeCondition,
	ShiftOperandRegister,
	ShiftType,
}

/*
RSC is a data processing opcode, so all the variation
of this interface have already been tested.
*/

/*
Test RSC opcode interface with default values
*/
fn test_orr_default() {
	opcode := RSCOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2E0_0000
}

/*
Test RSC opcode interface with no default values
Use specific values for all options
*/
fn test_orr_no_default() {
	opcode := RSCOpcode{
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
	assert hex_value == 0x10FA_EF18
}
