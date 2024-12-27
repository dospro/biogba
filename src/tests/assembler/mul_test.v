import biogba {
	MULOpcode,
	OpcodeCondition
}
import biogba.arm_assembler { AsmState, Assembler }

/*
Test basic MUL opcode
*/
fn test_assembler_mul() {
	opcode_string := 'MUL R1, R2, R3'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := MULOpcode{
		rd: 1
		rm: 2
		rs: 3
	}

	assert opcode is MULOpcode
	if opcode is MULOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test MUL opcode with no default condition
*/
fn test_assembler_mul_condition() {
	opcode_string := 'MULEQ R1, R2, R3'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := MULOpcode{
		condition: OpcodeCondition.eq
		rd: 1
		rm: 2
		rs: 3
	}
	assert opcode is MULOpcode
	if opcode is MULOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test MUL with S bit set
*/
fn test_assembler_mul_s_bit() {
	opcode_string := 'MULVCS R14, R10, R7'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err)}
	expected_opcode := MULOpcode{
		condition: OpcodeCondition.vc
		rd: 14
		rm: 10
		rs: 7
		s_bit: true
	}
	assert opcode is MULOpcode
	if opcode is MULOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test MLA opcode

MLA opcode is the same as MUL opcode but with the a_bit set
Also, MLA uses Rn register to add it to the result
*/
fn test_assembler_mla() {
	opcode_string := 'MLACC R5, R6, R7, R8'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err)}
	expected_opcode := MULOpcode{
		condition: OpcodeCondition.cc
		rd: 5
		rm: 6
		rs: 7
		rn: 8
		s_bit: false
		a_bit: true
	}
	assert opcode is MULOpcode
	if opcode is MULOpcode {
		assert opcode == expected_opcode
	}
}