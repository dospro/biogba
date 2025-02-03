import biogba {
	MOVOpcode,
	OpcodeCondition,
	ShiftOperandRegister,
	ShiftType,
}

/*
MOV is a data processing opcode, so all the variation
of this interface have already been tested.

The following tests only verifies that the opcode part
is correct and that variations are considered
*/

/*
Test MOV opcode interface with default values
*/
fn test_mov_default() {
	opcode := MOVOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE3A0_0000
}

/*
Test MOV opcode interface with no default values
Use specific values for all options
*/
fn test_mov_no_default() {
	opcode := MOVOpcode{
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
	assert hex_value == 0x11BA_EF18
}
