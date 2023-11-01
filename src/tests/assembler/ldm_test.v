import biogba {Register}
import biogba.arm_assembler {opcode_from_string}

/*
LDM opcodes has different multiple modes
LDM{<cond>}<addressing_mode>, <Rn>{!}, <registers>

There are 8 different notation for addressing modes
but 4 categories:
- IB → ED
- IA → FD
- DB → EA
- DA → FA
 If ! is present after register Rn it means writeback is
 enabled
 <registers> examples: 
	{R0,R2-R7,R10}
{^} If present, set bit S
*/

/*
Test LDM most simple form

Addressing mode must be set so we will use IA
Register list only contains one register
*/
fn test_assembler_ldm_simple() {
	opcode_string := 'LDMIA R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: false
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with a condition
*/
fn test_assembler_ldm_condition() {
	opcode_string := 'LDMHIIA R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.hi
		rn: 0
		p_bit: false
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with IB addressing mode

This mode sets p bit and u bit

*/
fn test_assembler_ldm_addressing_mode_ib() {
	opcode_string := 'LDMEQIB R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.eq
		rn: 0
		p_bit: true
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with ED addressing mode
which is equivalent to IB
*/
fn test_assembler_ldm_addressing_mode_ed() {
	opcode_string := 'LDMED R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: true
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with DB addressing mode

This mode sets p bit
and resets u_bit

*/
fn test_assembler_ldm_addressing_mode_db() {
	opcode_string := 'LDMDB R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: true
		u_bit: false
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with EA addressing mode
which is equivalent to DB

*/
fn test_assembler_ldm_addressing_mode_ea() {
	opcode_string := 'LDMEA R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: true
		u_bit: false
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with DB addressing mode

This mode sets p bit
and resets u_bit

*/
fn test_assembler_ldm_addressing_mode_da() {
	opcode_string := 'LDMDA R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: false
		u_bit: false
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with FA addressing mode
which is equivalent to DA
*/
fn test_assembler_ldm_addressing_mode_fa() {
	opcode_string := 'LDMFA R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: false
		u_bit: false
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with FD addressing mode
which is equivalent to IA
*/
fn test_assembler_ldm_addressing_mode_fd() {
	opcode_string := 'LDMFD R0, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0
		p_bit: false
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with a different Rn register

The test uses R13 as the register for Rn
*/
fn test_assembler_ldm_rn() {
	opcode_string := 'LDMLTIA R13, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.lt
		rn: 13
		p_bit: false
		u_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with ! which means writeback enabled

*/
fn test_assembler_ldm_writeback() {
	opcode_string := 'LDMIA R9!, {R1}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 9
		p_bit: false
		u_bit: true
		w_bit: true
		register_list: [biogba.Register.r1]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with different register in register list

*/
fn test_assembler_ldm_register_list() {
	opcode_string := 'LDMIA R1, {R14}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [biogba.Register.r14]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode multiple registers in register list

*/
fn test_assembler_ldm_register_list_multiple() {
	opcode_string := 'LDMIA R1, {R2,R3,R5}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [Register.r2, Register.r3, Register.r5]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDM Opcode with a simple range of registers 
*/
fn test_assembler_ldm_register_range() {
	opcode_string := 'LDMIA R1, {R2-R8}'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [
			Register.r2, 
			Register.r3, 
			Register.r4, 
			Register.r5, 
			Register.r6, 
			Register.r7, 
			Register.r8
		]
	}

	assert opcode is biogba.LDMOpcode
	if opcode is biogba.LDMOpcode {
		assert opcode == expected_opcode
	}
}