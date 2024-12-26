import biogba {
	MULOpcode,
	OpcodeCondition,
	Register,
}

/*
Test MUL opcode interface with default values
*/
fn test_mul_default() {
	opcode := MULOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE000_0090
}

/*
Test MUL opcode interface with a conditional
*/
fn test_mul_condition() {
	opcode := MULOpcode{
		condition: OpcodeCondition.mi
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x4000_0090
}

/*
Test MUL opcode interface with Rm
*/
fn test_mul_rm() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rm: 0xE
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE000_009E
}

/*
Test MUL opcode interface with Rs
*/
fn test_mul_rs() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rs: 10
		rm: 14
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE000_0A9E
}


/*
Test MUL opcode interface with Rn
*/
fn test_mul_rn() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rn: 8
		rs: 10
		rm: 14
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE000_8A9E
}


/*
Test MUL opcode interface with Rd
*/
fn test_mul_rd() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rd: 5
		rn: 8
		rs: 10
		rm: 14
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE005_8A9E
}


/*
Test MUL opcode interface with s-bit
*/
fn test_mul_s_bit() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rd: 5
		rn: 8
		rs: 10
		rm: 14
		s_bit: true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE015_8A9E
}

/*
Test MLA opcode interface wich is MUL with a-bit
*/
fn test_mla() {
	opcode := MULOpcode{
		condition: OpcodeCondition.al
		rd: 5
		rn: 8
		rs: 10
		rm: 14
		s_bit: true
		a_bit: true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE035_8A9E
}