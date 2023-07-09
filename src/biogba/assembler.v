module biogba

// Parses a string into a OpcodeCondition
fn condition_from_string(condition_string string) ?OpcodeCondition {
	return match condition_string.to_lower() {
		'eq' { OpcodeCondition.eq }
		'ne' { OpcodeCondition.ne }
		'cs' { OpcodeCondition.cs }
		'cc' { OpcodeCondition.cc }
		'mi' { OpcodeCondition.mi }
		'pl' { OpcodeCondition.pl }
		'vs' { OpcodeCondition.vs }
		'vc' { OpcodeCondition.vc }
		'hi' { OpcodeCondition.hi }
		'ls' { OpcodeCondition.ls }
		'ge' { OpcodeCondition.ge }
		'lt' { OpcodeCondition.lt }
		'gt' { OpcodeCondition.gt }
		'le' { OpcodeCondition.le }
		'al' { OpcodeCondition.al }
		else { none }
	}
}

/*
Returns a ShiftType value from a string
*/
fn shift_type_from_string(value string) !ShiftType {
	return match value.to_lower() {
		'lsl' {.lsl}
		'lsr' {.lsr}
		'asr' {.asr}
		'ror' {.ror}
		else {
			error('Invalid opcode shift operand string ${value}')
		}
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

type TokenValue = OpcodeCondition | ShiftType | bool | string | u32 | u8

enum TokenType {
	opcode_name
	s_bit
	condition
	register
	expression
	shift_name
}

pub struct OpcodeToken {
	token_value TokenValue
	token_type  TokenType
}

pub struct OpcodeNameParser {
	opcode_string      string
	name_final_states  []int = [3, 4, 5]
	transitions_matrix map[int]map[string]int = {
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

struct OpcodeParser {
mut:
	scanner OpcodeNameParser
	errors  []IError
	fields  []string
	state   int
}

fn new_opcode_parser(opcode_text string) !OpcodeParser {
	// Remove commas
	cleaned_opcode_text := opcode_text.replace(',', ' ')

	// Separate tokens
	fields := cleaned_opcode_text.fields()
	my_scanner := OpcodeNameParser{
		opcode_string: fields[0]
	}

	return OpcodeParser{
		scanner: my_scanner
		fields: fields
		state: 0
	}
}

fn (mut iter OpcodeParser) next() ?OpcodeToken {
	match iter.state {
		0 {
			token := iter.scanner.next() or {
				iter.errors << error('Invalid Opcode name')
				return none
			}
			iter.state = 1
			return OpcodeToken{
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
			token := iter.scanner.next()

			match token {
				none {
					iter.state = 4
					return OpcodeToken{
						token_value: register_number_from_string(iter.fields[1]) or {
							iter.errors << err
							return none
						}
						token_type: TokenType.register
					}
				}
				'S' {
					iter.state = 3
					return OpcodeToken{
						token_value: true
						token_type: TokenType.s_bit
					}
				}
				else {
					iter.state = 2
					return OpcodeToken{
						token_value: condition_from_string(token or { '' }) or {
							OpcodeCondition.al
						}
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
			token := iter.scanner.next()

			match token {
				none {
					iter.state = 4
					return OpcodeToken{
						token_value: register_number_from_string(iter.fields[1]) or {
							iter.errors << err
							return none
						}
						token_type: TokenType.register
					}
				}
				'S' {
					iter.state = 3
					return OpcodeToken{
						token_value: true
						token_type: TokenType.s_bit
					}
				}
				else {
					iter.errors << error('After opcode name there was no S, register or condition. Mal formed opcode')
					return none
				}
			}
		}
		3 {
			// After an S flag we can only have a register
			iter.state = 4
			return OpcodeToken{
				token_value: register_number_from_string(iter.fields[1]) or {
					iter.errors << err
					return none
				}
				token_type: TokenType.register
			}
		}
		4 {
			// After the first register we can only have a second register
			iter.state = 5
			return OpcodeToken{
				token_value: register_number_from_string(iter.fields[2]) or {
					iter.errors << err
					return none
				}
				token_type: TokenType.register
			}
		}
		5 {
			// After the second register we can have:
			// 1. An expression
			// 2. A register

			// If the token starts with R, then it is a register
			if iter.fields[3].substr(0, 1) == 'R' {
				iter.state = 6
				return OpcodeToken{
					token_value: register_number_from_string(iter.fields[3]) or {
						iter.errors << err
						return none
					}
					token_type: TokenType.register
				}
			} else {
				// Otherwise, it is an expression
				if iter.fields.len > 4 {
					iter.errors << error('Too many parameters')
					return none
				}
				expression_value := u32(iter.fields[3][1..].parse_uint(16, 32) or {
					iter.errors << err
					return none
				})
				iter.state = 11
				return OpcodeToken{
					token_value: expression_value
					token_type: TokenType.expression
				}
			}
		}
		6 {
			// After a 3th register we are now in register mode.
			// So we either hace RXX or shiftname
			if iter.fields[4].to_lower() == 'rxx' {
				if iter.fields.len > 5 {
					iter.errors << error('Too many parameters')
					return none
				}
				iter.state = 10
				return OpcodeToken{
					token_value: shift_type_from_string('ror') or {
						iter.errors << err
						return none
					}
					token_type: TokenType.shift_name
				}
			} else {
				iter.state = 7
				return OpcodeToken{
					token_value: shift_type_from_string(iter.fields[4]) or {
						iter.errors << err
						return none
					}
					token_type: TokenType.shift_name
				}
			}
		}
		7 {
			// After the shift name we can have:
			// 1. Expression (Shift value)
			// 2. Register
			if iter.fields[5].substr(0, 1).to_lower() == 'r' {
				if iter.fields.len > 6 {
					iter.errors << error('Too many parameters')
					return none
				}
				iter.state = 8
				return OpcodeToken{
					token_value: register_number_from_string(iter.fields[5]) or {
						iter.errors << err
						return none
					}
					token_type: TokenType.register
				}
			} else {
				if iter.fields.len > 6 {
					iter.errors << error('Too many parameters')
					return none
				}
				iter.state = 9
				return OpcodeToken{
					token_value: u8(iter.fields[5][1..].parse_uint(16, 8) or {
						iter.errors << err
						return none
					})
					token_type: TokenType.expression
				}
			}
		}
		else {
			iter.errors << error('Invalid state in general parser')
			return none
		}
	}
}

fn (self OpcodeParser) get_final_state() !int {
	final_states := [8, 9, 10, 11]
	if final_states.contains(self.state) {
		return self.state
	}
	return error('State ${self.state} is not final. Something went wrong')
}

struct TokensList {
	state  int
	tokens []OpcodeToken
}

/*
Takes the initial text representation of an opcode and returns a
TokensList struct with the final state (which identifies the actual opcode)
together with the list of validated tokens that builds the opcode.
*/
fn tokens_from_string(opcode_text string) !TokensList {
	mut opcode_parser := new_opcode_parser(opcode_text)!
	mut tokens_list := []OpcodeToken{}

	for {
		token := opcode_parser.next() or { break }
		tokens_list << token
	}
	if state := opcode_parser.get_final_state() {
		return TokensList{
			state: state
			tokens: tokens_list
		}
	} else {
		return err
	}
}

/*
Returns a Result type with either an Opcode struct from a string
representation or an error in case something goes wrong
*/
fn opcode_from_string(opcode_text string) !Opcode {
	parsed_tokens := tokens_from_string(opcode_text)!
	tokens_list := parsed_tokens.tokens
	general_state := parsed_tokens.state

	mut condition := OpcodeCondition.al
	mut s_bit := false
	mut rd := u8(0x0)
	mut rn := u8(0x0)
	mut rm := u8(0x0)
	mut immediate_value := u32(0x0)

	mut current_token := 1
	if tokens_list[current_token].token_type == TokenType.condition {
		condition = tokens_list[1].token_value as OpcodeCondition
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
		rd = tokens_list[current_token].token_value as u8
		current_token += 1
		println('Rd ${rd}')
	} else {
		return error('Expected register Rd')
	}
	if tokens_list[current_token].token_type == TokenType.register {
		rn = tokens_list[current_token].token_value as u8
		println('Rn ${rn}')
		current_token += 1
	} else {
		error('Expected register Rn')
	}

	match general_state {
		8 {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			rs := tokens_list[current_token].token_value as u8

			opcode_name := tokens_list[0].token_value as string

			if opcode_name == 'ADD' {
				return ADDOpcode{
					condition: condition
					rd: rd
					rn: rn
					s_bit: s_bit
					shift_operand: ShiftOperandRegister{
						rm: rm
						register_shift: true
						shift_type: shift_type
						shift_value: rs
					}
				}
			} else {
				return ADCOpcode{
					condition: condition
					rd: rd
					rn: rn
					s_bit: s_bit
					shift_operand: ShiftOperandRegister{
						rm: rm
						register_shift: true
						shift_type: shift_type
						shift_value: rs
					}
				}
			}
		}
		9 {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			expression := tokens_list[current_token].token_value as u8
			if expression > 0x1F {
				return error('Shift expression too big')
			}
			return ADCOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandRegister{
					rm: rm
					register_shift: false
					shift_type: shift_type
					shift_value: expression
				}
			}
		}
		10 {
			// In final state 10 we are parsing an RXX which
			// is build as a ROR #0
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			return ADCOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandRegister{
					rm: rm
					register_shift: false
					shift_type: ShiftType.ror
					shift_value: 0
				}
			}
		}
		11 {
			if tokens_list[current_token].token_type == TokenType.expression {
				immediate_value = tokens_list[current_token].token_value as u32
				println('Immediate value ${immediate_value}')
			} else {
				return error('Invalid expression ${tokens_list[current_token].token_value}')
			}
			shift_operand := get_immediate_value(immediate_value)!
			return ADCOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: shift_operand
			}
		}
		else {
			return error('Not implemented')
		}
	}

	return error('Invalid opcode')
}

/*
From a 32 bits value generates a value/rotation pair that represents
the value given in the parameter.
Returns a ShiftOperandImmediate struct with the values
*/
fn get_immediate_value(immediate u32) !ShiftOperandImmediate {
	mut immediate_value := immediate
	mut shift_counter := 0

	for (immediate_value & 1) == 0 {
		immediate_value >>= 1
		shift_counter += 1
	}

	// If the number of shifts is odd, make it even
	if (shift_counter & 1) == 1 {
		immediate_value <<= 1
		shift_counter -= 1
	}

	if immediate_value > 0xFF {
		return error('Value ${immediate} cannot be represented as immediate value')
	}

	return ShiftOperandImmediate{
		value: u8(immediate_value)
		rotate: u8(((32 - shift_counter) / 2) & 0xF)
	}
}
