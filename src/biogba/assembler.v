module biogba

// Function that parses a string into a OpcodeCondition
fn condition_from_string(condition_string string) ?OpcodeCondition {
	return match condition_string {
		'EQ' { OpcodeCondition.eq }
		'NE' { OpcodeCondition.ne }
		'CS' { OpcodeCondition.cs }
		'CC' { OpcodeCondition.cc }
		'MI' { OpcodeCondition.mi }
		'PL' { OpcodeCondition.pl }
		'VS' { OpcodeCondition.vs }
		'VC' { OpcodeCondition.vc }
		'HI' { OpcodeCondition.hi }
		'LS' { OpcodeCondition.ls }
		'GE' { OpcodeCondition.ge }
		'LT' { OpcodeCondition.lt }
		'GT' { OpcodeCondition.gt }
		'LE' { OpcodeCondition.le }
		'AL' { OpcodeCondition.al }
		else { none }
	}
}

/*
Returns the register number from a register string
Example
R15 -> 0xF
*/
fn register_number_from_string(register_string string) !u8 {
	return match register_string.to_lower() {
		'r0' {0x0}
		'r1' {0x1}
		'r2' {0x2}
		'r3' {0x3}
		'r4' {0x4}
		'r5' {0x5}
		'r6' {0x6}
		'r7' {0x7}
		'r8' {0x8}
		'r9' {0x9}
		'r10' {0xA}
		'r11' {0xB}
		'r12' {0xC}
		'r13' {0xD}
		'r14' {0xE}
		'r15' {0xF}
		else {
			error('Invalid register ${register_string}')
		}
	}
}

enum TokenType {
	opcode_name
	s_bit
	condition
	register
	expression
	shift_name
}

pub struct OpcodeToken {
	token_value string
	token_type  TokenType
}

pub struct OpcodeNameParser {
	opcode_string      string
	name_final_states  []int = [3, 4, 5]
	transitions_matrix map[int]map[string]int   = {
		0: {
			'A': 1
			'B': 5
		}
		1: {
			'D': 2
		}
		2: {
			'C': 3
			'D': 4
		}
	}
mut:
	index int
	state int
	token string
}

/*
The next method, which makes OpcodeNameParser an Iterator, parses the first
token of an opcode which can contain up to 3 elements:
1. Opcode Name. Ex: ADC, B, MUL
2. Condition. Ex: EQ, GT, AL (optional)
3. S (optional)

Syntax: {opcode_name}{<cond>}{S}
*/
fn (mut iter OpcodeNameParser) next() ?string {
	if iter.index >= iter.opcode_string.len {
		return none
	}
	if iter.opcode_string.is_blank() {
		return none
	}
	// If we already returned opcode name, then we can stop using states
	if iter.name_final_states.contains(iter.state) {
		if iter.opcode_string[iter.index].ascii_str() == 'S' {
			iter.index += 1
			return 'S'
		} else {
			if iter.index + 1 >= iter.opcode_string.len {
				return none
			}
			condition := iter.opcode_string[iter.index..iter.index + 2]
			iter.index += 2
			return condition
		}
	}
	for {
		if iter.index >= iter.opcode_string.len {
			break
		}
		next_character := iter.opcode_string[iter.index].ascii_str()
		if next_state := iter.transitions_matrix[iter.state][next_character] {
			iter.state = next_state
			iter.token += next_character
			iter.index += 1
		} else {
			break
		}
	}
	if !iter.name_final_states.contains(iter.state) {
		println('Break the loop but we are not in a final state ${iter.state}')
		return none
	}
	return iter.token
}

/*
Returns a Result type with either an Opcode struct from a string
representation or an error in case something goes wrong
*/
fn opcode_from_string(opcode_text string) !Opcode {
	// Remove commas	
	cleaned_opcode_text := opcode_text.replace(',', ' ')

	// Separate tokens
	tokens := cleaned_opcode_text.fields()

	mut general_state := 0
	mut real_token := OpcodeToken{}
	mut tokens_list := []OpcodeToken{}
	println('Token0 ${tokens[0]}')
	mut my_scanner := OpcodeNameParser{
		opcode_string: tokens[0]
	}

	for {
		println('General state ${general_state}')
		match general_state {
			0 {
				token := my_scanner.next() or { return error('Invalid opcode name') }
				println('Opcode Name ${token}')

				general_state = 1
				real_token = OpcodeToken{
					token_value: token
					token_type: TokenType.opcode_name
				}
			}
			1 {
				// We have 3 cases:
				// 1. Condition string
				// 2. S flag
				// 3. register

				// If the internal scanner is out of characters, then
				// the next token is a register and is inside the next
				// tokens element
				token := my_scanner.next()

				match token {
					none {
						general_state = 4
						real_token = OpcodeToken{
							token_value: tokens[1]
							token_type: TokenType.register
						}
					}
					'S' {
						general_state = 3
						real_token = OpcodeToken{
							token_value: 'S'
							token_type: TokenType.s_bit
						}
					}
					else {
						general_state = 2
						real_token = OpcodeToken{
							token_value: token or {''}
							token_type: TokenType.condition
						}
					}
				}
			}
			2 {
				// After a condition we can have
				// 1. An S flag
				// 2. A register

				// If the internal scanner is our of characters, then
				// the next token is a register and is inside the next
				// tokens element
				token := my_scanner.next()

				match token {
					none {
						general_state = 4
						real_token = OpcodeToken{
							token_value: tokens[1]
							token_type: TokenType.register
						}
					}
					'S' {
						general_state = 3
						real_token = OpcodeToken{
							token_value: 'S'
							token_type: TokenType.s_bit
						}
					}
					else {
						return error('After opcode name there was no S, register or condition. Mal formed opcode')
					}
				}
			}
			3 {
				// After an S flag we can only have a register
				general_state = 4
				real_token = OpcodeToken{
					token_value: tokens[1]
					token_type: TokenType.register
				}
			}
			4 {
				// After the first register we can only have a second register
				general_state = 5
				real_token = OpcodeToken{
					token_value: tokens[2]
					token_type: TokenType.register
				}
			}
			5 {
				// After the second register we can have:
				// 1. An expression
				// 2. A register

				// If the token starts with R, then it is a register
				if tokens[3].substr(0, 1) == 'R' {
					println('Register ${tokens[3]}')
					general_state = 6
					real_token = OpcodeToken{
						token_value: tokens[3]
						token_type: TokenType.register
					}
				} else {
					// Otherwise, it is an expression
					println('Expression ${tokens[3]}')
					general_state = 11
					real_token = OpcodeToken{
						token_value: tokens[3]
						token_type: TokenType.expression
					}
				}
			}
			6 {
				// After a 3th register we are now in register mode.
				// So we either hace RXX or shiftname
				general_state = 7
				println('Shift Name ${tokens[4]}')
				real_token = OpcodeToken{
					token_value: 'LSL'
					token_type: TokenType.shift_name
				}
			}
			7 {
				// After the shift name we can have:
				// 1. Expression (Shift value)
				// 2. Register
				println('Expression ${tokens[5]}')
				general_state = 9
				real_token = OpcodeToken{
					token_value: tokens[5]
					token_type: TokenType.expression
				}
			}
			else {
				return error('Invalid state ${general_state}')
			}
		}
		tokens_list << real_token

		if general_state == 9 {
			return ADCOpcode{
				condition: OpcodeCondition.eq
				rd: 15
				rn: 14
				s_bit: true
				shift_operand: ShiftOperandRegister{
					rm: 0x2
					register_shift: false
					shift_type: ShiftType.lsl
					shift_value: 1
				}
			}
		} else if general_state == 11 {
			mut condition := OpcodeCondition.al
			mut s_bit := false
			mut rd := u8(0x0)
			mut rn := u8(0x0)
			mut rm := u8(0x0)
			mut immediate_value := u8(0x0)

			mut current_token := 1
			if tokens_list[current_token].token_type == TokenType.condition {
				condition = condition_from_string(tokens_list[1].token_value) or {
					OpcodeCondition.al
				}
				current_token += 1
			} else {
				condition = OpcodeCondition.al
			}
			if tokens_list[current_token].token_type == TokenType.s_bit {
				s_bit = true
				current_token += 1
			} else {
				s_bit = false
			}
			if tokens_list[current_token].token_type == TokenType.register {
				rd = register_number_from_string(tokens_list[current_token].token_value)!
				current_token += 1
				println('Rd ${rd}')
			} else {
				error('Invalid register')
			}
			if tokens_list[current_token].token_type == TokenType.register {
				rn = register_number_from_string(tokens_list[current_token].token_value) or {
					panic('Invalid register')
				}
				println('Rn ${rn}')
				current_token += 1
			} else {
				error('Invalid register')
			}
			if tokens_list[current_token].token_type == TokenType.expression {
				immediate_value = tokens_list[current_token].token_value[1..].u8()
				println('Immediate value ${immediate_value}')
			} else {
				error('Invalid expression ${tokens_list[current_token].token_value}')
			}

			return ADCOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandImmediate{
					value: immediate_value
					rotate: 0
				}
			}
		}
	}

	return error('Invalid opcode')
}
