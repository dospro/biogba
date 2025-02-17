import biogba {
	MVNOpcode,
	OpcodeCondition,
	ShiftOperandRegister,
	ShiftType,
}

/*
MVV is a data processing opcode, so all the variation
of this interface have already been tested.

MVN structure is identical to MOV with the only difference
of the opcode pattern to differentiate it from MOV
*/

/*
Test MVN opcode interface with default values
*/
fn test_mvn_default() {
	opcode := MVNOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE3E0_0000
}

/*
Test MVN opcode interface with no default values
Use specific values for all options
*/
fn test_mvn_no_default() {
	opcode := MVNOpcode{
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
	assert hex_value == 0x11FA_EF18
}
