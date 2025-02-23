import biogba {
	MULLOpcode,
	OpcodeCondition,
}

/*
MULL is not an actual opcode. I used this name to represent the following opcodes:
* UMULL - Unsigned Multiply Long
* UMLAL - Unsigned Multiply Long and Accumulate
* SMULL - Signed Multiply Long
* SMLAL - Signed  Multiply Long and Accumulate

The assembler will parse this names and translate them to the MULL struct
*/

/*
Test UMULL opcode interface with default values
Note: Since RdHi, RdLo, Rm and Rs must be all different,
by default we will set
RdHi = 0
RdLo = 1
Rs = 2
Rm = 3
*/
fn test_umull_default() {
	opcode := MULLOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE080_1293
}

fn test_umull_condition() {
	opcode := MULLOpcode{
		condition: OpcodeCondition.vs
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x6080_1293
}

fn test_umull_rm() {
	opcode := MULLOpcode{
		rm: 13
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE080_129D
}

fn test_umull_rs() {
	opcode := MULLOpcode{
		rs: 9
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE080_1993
}

fn test_umull_rdlo() {
	opcode := MULLOpcode{
		rdlo: 5
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE080_5293
}

fn test_umull_rdhi() {
	opcode := MULLOpcode{
		rdhi: 14
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE08E_1293
}

fn test_umull_s() {
	opcode := MULLOpcode{
		s_bit: true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE090_1293
}

fn test_umlal() {
	opcode := MULLOpcode{
		condition: OpcodeCondition.eq
		rm:        8
		rs:        7
		rdlo:      4
		rdhi:      2
		a_bit:     true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x00A2_4798
}

/*
Test Signed Multiply Long opcode interface 
*/
fn test_smull() {
	opcode := MULLOpcode{
		condition: OpcodeCondition.eq
		rm:        8
		rs:        7
		rdlo:      4
		rdhi:      2
		a_bit:     false
		u_bit:     true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x00C2_4798
}

/*
Test Signed Multiply Long and Accumulate opcode interface 
*/
fn test_smlal() {
	opcode := MULLOpcode{
		condition: OpcodeCondition.eq
		rm:        3
		rs:        5
		rdlo:      7
		rdhi:      11
		a_bit:     true
		u_bit:     true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x00EB_7593
}
