import biogba.arm_assembler {
	OpcodeTokenType,
	Token,
	Tokenizer,
}

fn test_get_opcode_name() {
	opcode_string := 'ADC'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	// expected := [OpcodeNameToken{'ADC'}]
	expected := [Token{OpcodeTokenType.opcode_name, 'ADC'}]

	assert expected == result
}

fn test_b_opcode_with_condition() {
	opcode_string := 'BEQ'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'B'},
		Token{OpcodeTokenType.condition, 'EQ'},
	]
	assert expected == result
}

fn test_bx_opcode_name() {
	opcode_string := 'BX'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'BX'},
	]
	assert expected == result
}

fn test_cmn_with_condition() {
	opcode_string := 'CMNGT'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'CMN'},
		Token{OpcodeTokenType.condition, 'GT'},
	]
	assert expected == result
}

fn test_bl_with_condition() {
	opcode_string := 'BLHI'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'BL'},
		Token{OpcodeTokenType.condition, 'HI'},
	]
	assert expected == result
}

fn test_s_bit() {
	opcode_string := 'ADDS'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADD'},
		Token{OpcodeTokenType.s_bit, 'S'},
	]
	assert expected == result
}

fn test_opcode_with_condition_and_s_bit() {
	opcode_string := 'ADDPLS'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADD'},
		Token{OpcodeTokenType.condition, 'PL'},
		Token{OpcodeTokenType.s_bit, 'S'},
	]
	assert expected == result
}

fn test_ldm_with_addressing_mode() {
	opcode_string := 'LDMIA'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'IA'},
	]
	assert expected == result
}

fn test_ldm_with_different_addressing_mode() {
	opcode_string := 'LDMEQEA'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.condition, 'EQ'},
		Token{OpcodeTokenType.addressing_mode, 'EA'},
	]
	assert expected == result
}

fn test_second_argument_register() {
	opcode_string := 'ADD R0'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADD'},
		Token{OpcodeTokenType.register, 'R0'},
	]
	assert expected == result
}

fn test_multiple_registers() {
	opcode_string := 'ADDEQS R0, R1, R6, R12'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADD'},
		Token{OpcodeTokenType.condition, 'EQ'},
		Token{OpcodeTokenType.s_bit, 'S'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.register, 'R6'},
		Token{OpcodeTokenType.register, 'R12'},
	]
	assert expected == result
}

fn test_shift_name_lsl() {
	opcode_string := 'CMN R0, R1, R6, LSL'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'CMN'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.register, 'R6'},
		Token{OpcodeTokenType.shift_name, 'LSL'},
	]
	assert expected == result
}

fn test_shift_name_rrx() {
	opcode_string := 'ADC R0, R1, R2, RRX'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADC'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.register, 'R2'},
		Token{OpcodeTokenType.shift_name, 'RRX'},
	]
	assert expected == result
}

fn test_simple_numeric_expression() {
	opcode_string := 'ADC R0, R1, R2, LSR#1F'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADC'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.register, 'R2'},
		Token{OpcodeTokenType.shift_name, 'LSR'},
		Token{OpcodeTokenType.expression, '#1F'},
	]
	assert expected == result
}

fn test_large_numeric_expression() {
	opcode_string := 'ADC R5, R3 #FF00'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'ADC'},
		Token{OpcodeTokenType.register, 'R5'},
		Token{OpcodeTokenType.register, 'R3'},
		Token{OpcodeTokenType.expression, '#FF00'},
	]
	assert expected == result
}

fn test_register_list_single() {
	opcode_string := 'LDMIA R0, {R1}'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'IA'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register_list, '{R1}'},
	]
	assert expected == result
}

fn test_register_list_multiple() {
	opcode_string := 'LDMIA R0, {R1,R2,R14}'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'IA'},
		Token{OpcodeTokenType.register, 'R0'},
		Token{OpcodeTokenType.register_list, '{R1,R2,R14}'},
	]
	assert expected == result
}

fn test_register_list_range() {
	opcode_string := 'LDMDB R1, {R3-R10}'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'DB'},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.register_list, '{R3-R10}'},
	]
	assert expected == result
}

fn test_ldm_with_write_back() {
	opcode_string := 'LDMFA R2!, {R3}'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'FA'},
		Token{OpcodeTokenType.register, 'R2'},
		Token{OpcodeTokenType.write_back, '!'},
		Token{OpcodeTokenType.register_list, '{R3}'},
	]
	assert expected == result
}

fn test_ldm_s_bit_operator() {
	opcode_string := 'LDMIB R11!, {R2-R4}^'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDM'},
		Token{OpcodeTokenType.addressing_mode, 'IB'},
		Token{OpcodeTokenType.register, 'R11'},
		Token{OpcodeTokenType.write_back, '!'},
		Token{OpcodeTokenType.register_list, '{R2-R4}'},
		Token{OpcodeTokenType.s_bit, '^'},
	]
	assert expected == result
}

fn test_separate_register_token() {
	opcode_string := 'R14'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.register, 'R14'},
	]
	assert expected == result
}

/*
Open bracket is used to express and address
We need to tokenize it so the syntactic parser
can know when we are inside an address space
*/
fn test_brackets() {
	opcode_string := '[R1]'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.open_bracket, '['},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.close_bracket, ']'},
	]
	assert expected == result
}

/*
Some expressions can specify a sign
Opcode like LDR can use u bit to specify if
the offset is added or subtracted to the base
*/
fn test_signed_expression() {
	opcode_string := '[R1, #-10]'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.open_bracket, '['},
		Token{OpcodeTokenType.register, 'R1'},
		Token{OpcodeTokenType.expression, '#-10'},
		Token{OpcodeTokenType.close_bracket, ']'},
	]
	assert expected == result
}


/*
Some offsets are specified as registers which can have
a negative sign. In this case the negative sign must be
interpreted as a separate token
*/
fn test_negative_sign() {
	opcode_string := '[R2, -R14]'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.open_bracket, '['}
		Token{OpcodeTokenType.register, 'R2'}
		Token{OpcodeTokenType.sign, '-'}
		Token{OpcodeTokenType.register, 'R14'}
		Token{OpcodeTokenType.close_bracket, ']'}
	]
	assert expected == result
}

/*
For the LDRH opcode the H is considered a separate token
The case tests that the H token is parsed correctly
*/
fn test_h_token() {
	opcode_string := 'LDREQH'
	mut tokenizer := Tokenizer{
		text: opcode_string
	}
	result := tokenizer.parse()
	expected := [
		Token{OpcodeTokenType.opcode_name, 'LDR'}
		Token{OpcodeTokenType.condition, 'EQ'}
		Token{OpcodeTokenType.halfword, 'H'}
	]
	assert expected == result
}