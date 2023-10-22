module arm_assembler

import datatypes

pub fn (mut self datatypes.Stack[int]) clear() {
	for !self.is_empty() {
		self.pop() or {}
	}
}

pub const (
	final_states     = [2, 3, 4, 5, 6, 7, 8, 10, 11, 12]
	opcode_names     = ['ADC', 'ADD', 'AND', 'BIC', 'BL', 'BX', 'B', 'CMN', 'CMP', 'EOR', 'LDM']
	conditions       = ['EQ', 'NE', 'CS', 'CC', 'MI', 'PL', 'VS', 'VC', 'HI', 'LS', 'GE', 'LT',
		'GT', 'LE', 'AL']
	addressing_modes = ['IB', 'IA', 'DB', 'DA', 'ED', 'FD', 'EA', 'FA']
	shift_names = ['LSL', 'LSR', 'ASR', 'ROR', 'RRX']
)

pub enum OpcodeTokenType {
	opcode_name
	condition
	s_bit
	addressing_mode
	register
	shift_name
	expression
	register_list
	write_back
}

pub struct Token {
	token_type OpcodeTokenType
	lexeme     string
}

pub struct Tokenizer {
	text string
mut:
	text_position int = 0
}

pub fn (mut self Tokenizer) next() ?Token {
	mut stack := datatypes.Stack[int]{}
	mut lexeme := ''
	mut state := 0
	for state != -1 {
		if self.text_position >= self.text.len {
			if state in arm_assembler.final_states {
				stack.clear()
			}
			break
		}
		next_character := self.text[self.text_position]
		self.text_position += 1
		lexeme += next_character.ascii_str()
		if state in arm_assembler.final_states {
			stack.clear()
		}
		stack.push(state)
		match state {
			0 {
				if is_opcode_name(lexeme) {
					state = 2
				} else if lexeme == 'S' {
					state = 4
				} else if lexeme == '!' {
					state = 11
				} else if lexeme == '^' {
					state = 12
				} else if next_character.is_letter() {
					state = 1
				} else if next_character.is_space() || next_character.ascii_str() == ',' {
					stack.clear()
					lexeme = ''
					state = 0
				} else if lexeme == '#' {
					state = 8
				} else if lexeme == '{' {
					state = 9
				} else {
					state = -1
				}
			}
			1 {
				if is_opcode_name(lexeme) {
					state = 2
				} else if is_condition(lexeme) {
					state = 3
				} else if lexeme == 'S' {
					state = 4
				} else if is_address_mode(lexeme) {
					state = 5
				} else if is_shift_name(lexeme) {
					state = 7
				} else if next_character.is_letter() {
					state = 1
				} else if next_character.is_digit() {
					state = 6
				} else if next_character.is_space() {
					state = -1
				} else {
					state = -1
				}
			}
			2, 3, 4, 5, 7 {
				if is_opcode_name(lexeme) {
					state = 2
				} else if is_condition(lexeme) {
					state = 3
				} else if lexeme == 'S' {
					state = 4
				} else if is_address_mode(lexeme) {
					state = 5
				} else if is_shift_name(lexeme) {
					state = 7
				} else if next_character.is_letter() {
					state = 1
				} else {
					state = -1
				}
			}
			6 {
				if next_character.is_digit() {
					state = 6
				} else {
					state = -1
				}
			}
			8 {
				if !next_character.is_hex_digit() {
					state = -1
				}
			}
			9 {
				if next_character.ascii_str() == '}' {
					state = 10
				}
			}
			else {
				state = -1
			}
		}
	}

	for state !in arm_assembler.final_states && state != -2 {
		state = stack.pop() or { -2 }
		self.text_position -= 1
		if lexeme.len == 0 {
			break
		}
		lexeme = lexeme.limit(lexeme.len - 1)
	}
	return match state {
		2 {	Token{OpcodeTokenType.opcode_name, lexeme} }
		3 {	Token{OpcodeTokenType.condition, lexeme} }
		4 { Token{OpcodeTokenType.s_bit, lexeme} }
		5 { Token{OpcodeTokenType.addressing_mode, lexeme} }
		6 { Token{OpcodeTokenType.register, lexeme} }
		7 { Token{OpcodeTokenType.shift_name, lexeme} }
		8 { Token{OpcodeTokenType.expression, lexeme} }
		10 { Token{OpcodeTokenType.register_list, lexeme} }
		11 { Token{OpcodeTokenType.write_back, lexeme} }
		12 { Token{OpcodeTokenType.s_bit, lexeme} }
		else { none	}
	}
}

pub fn (mut self Tokenizer) parse() []Token {
	mut tokens := []Token{}
	for token in self {
		tokens << token
	}
	return tokens
}

fn is_opcode_name(lexeme string) bool {
	return lexeme in opcode_names
}

fn is_condition(lexeme string) bool {
	return lexeme in conditions
}

fn is_address_mode(lexeme string) bool {
	return lexeme in addressing_modes
}

fn is_shift_name(lexeme string) bool {
	return lexeme in shift_names
}
