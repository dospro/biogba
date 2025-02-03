import biogba {
	MRSOpcode,
	OpcodeCondition,
}

/*
Test MRS opcode interface with default values

In this case P is 0 meaning we use CPSR
Rd is also 0 by default
*/
fn test_mrs_default() {
	opcode := MRSOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE10F_0000
}

/*
Test MRS ocpode interface with a different condition
*/
fn test_mrs_condition() {
	opcode := MRSOpcode{
		condition: OpcodeCondition.gt
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xC10F_0000
}

/*
Test MRS opcode interface with a specific Rd
*/
fn test_mrs_rd() {
	opcode := MRSOpcode{
		rd: 4
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE10F_4000
}

/*
Test MRS opcode interface with a p bit set
This means it will use SPSR instead of CPSR
*/
fn test_mrs_p() {
	opcode := MRSOpcode{
		p_bit: true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE14F_0000
}