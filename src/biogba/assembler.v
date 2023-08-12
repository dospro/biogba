module biogba

import regex

type TokenValue = OpcodeCondition | ShiftType | bool | string | u32 | u8

enum TokenType {
	opcode_name
	s_bit
	condition
	register
	expression
	shift_name
}

enum OpcodeType {
	data_processing
	branch
}

pub struct OpcodeToken {
	token_value TokenValue
	token_type  TokenType
}

enum OpcodeFinalState {
	immediate = 11
	register_immediate = 9
	register_register = 8
	rrx = 10
}

fn OpcodeFinalState.from_int(value int) !OpcodeFinalState {
	return match value {
		8 { .register_register }
		9 { .register_immediate }
		10 { .rrx }
		11 { .immediate }
		else { error('Unknown final state') }
	}
}

/*
Builds a regex query that recognizes the opcode name format.

The opcode name format can be represented as:
{opcode_name}{<condition>}{<S>}

The function uses a list of all possible names and conditions to build a long regex
*/
fn build_opcode_name_regex() string {
	opcode_names := ['ADC', 'ADD', 'AND', 'BL', 'B']
	conditions := ['EQ', 'NE', 'CS', 'CC', 'MI', 'PL', 'VS', 'VC', 'HI', 'LS', 'GE', 'LT', 'GT',
		'LE', 'AL']
	mut regex_string := r'^(?P<name>'
	regex_string += '(${opcode_names[0]})'
	for op_name in opcode_names[1..] {
		regex_string += '|(${op_name})'
	}
	regex_string += ')(?P<cond>(${conditions[0]})'
	for cond in conditions[1..] {
		regex_string += '|(${cond})'
	}
	regex_string += r')?(?P<S>S)?$'
	return regex_string
}

/*
Receives a string with the format
{opcode_name}{<condition>}{<S>}
and returns a map with the parts of the opcode:
{
    name
    cond
    S
}
*/
fn get_parts(text string) !map[string]string {
	query := build_opcode_name_regex()
	mut re := regex.regex_opt(query)!
	matches := re.matches_string(text)
	mut final_map := map[string]string{}
	if matches {
		for name in re.group_map.keys() {
			final_map[name] = re.get_group_by_name(text, name)
		}
		return final_map
	}
	return error('Unable to parse opcode name')
}

struct OpcodeParser {
mut:
	opcode_name_parts map[string]string
	errors            []IError
	fields            []string
	state             int
}

fn OpcodeParser.new(opcode_text string) !OpcodeParser {
	// Remove commas
	cleaned_opcode_text := opcode_text.replace(',', ' ')

	// Separate tokens
	fields := cleaned_opcode_text.fields()
	parts := get_parts(fields[0])!

	return OpcodeParser{
		opcode_name_parts: parts
		fields: fields
		state: 0
	}
}

fn (mut iter OpcodeParser) next() ?OpcodeToken {
	match iter.state {
		0 {
			token := iter.opcode_name_parts['name']
			if token in ['ADC', 'ADD', 'AND'] {
				iter.state = 1
			} else if token in ['B', 'BL'] {
				iter.state = 12
			} else {
				return none
			}
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

			if !iter.opcode_name_parts['cond'].is_blank() {
				iter.state = 2
				return OpcodeToken{
					token_value: OpcodeCondition.from_string(iter.opcode_name_parts['cond'] or {
						''
					}) or { OpcodeCondition.al }
					token_type: TokenType.condition
				}
			} else if !iter.opcode_name_parts['S'].is_blank() {
				iter.state = 3
				return OpcodeToken{
					token_value: true
					token_type: TokenType.s_bit
				}
			} else {
				iter.state = 4
				return OpcodeToken{
					token_value: Register.from_string(iter.fields[1]) or {
						iter.errors << err
						return none
					}
					token_type: TokenType.register
				}
			}
		}
		2 {
			// After a condition we can have
			// 1. An S flag
			// 2. A register

			if !iter.opcode_name_parts['S'].is_blank() {
				iter.state = 3
				return OpcodeToken{
					token_value: true
					token_type: TokenType.s_bit
				}
			} else {
				iter.state = 4
				return OpcodeToken{
					token_value: Register.from_string(iter.fields[1]) or {
						iter.errors << err
						return none
					}
					token_type: TokenType.register
				}
			}
		}
		3 {
			// After an S flag we can only have a register
			iter.state = 4
			return OpcodeToken{
				token_value: Register.from_string(iter.fields[1]) or {
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
				token_value: Register.from_string(iter.fields[2]) or {
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
					token_value: Register.from_string(iter.fields[3]) or {
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
			// So we either hace RRX or shiftname
			if iter.fields[4].to_lower() == 'rrx' {
				if iter.fields.len > 5 {
					iter.errors << error('Too many parameters')
					return none
				}
				iter.state = 10
				return OpcodeToken{
					token_value: ShiftType.from_string('ror') or {
						iter.errors << err
						return none
					}
					token_type: TokenType.shift_name
				}
			} else {
				iter.state = 7
				return OpcodeToken{
					token_value: ShiftType.from_string(iter.fields[4]) or {
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
					token_value: Register.from_string(iter.fields[5]) or {
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
		12 {
			// We have a branch Opcode. So we either have
			// condition
			// expression
			if !iter.opcode_name_parts['cond'].is_blank() {
				iter.state = 13
				return OpcodeToken{
					token_value: OpcodeCondition.from_string(iter.opcode_name_parts['cond'] or {
						''
					}) or {OpcodeCondition.al}
					token_type: TokenType.condition
				}
			} else {
				expression_value := u32(iter.fields[1][1..].parse_uint(16, 32) or {
					iter.errors << err
					return none
				})
				iter.state = 14 // Final state
				return OpcodeToken{
					token_value: expression_value
					token_type: .expression
				}
			}
		}
		13 {
			iter.state = 14
			return OpcodeToken {
				token_value: u32(iter.fields[1][1..].parse_uint(16, 32) or {
					iter.errors << err
					return none
				})
				token_type: .expression
			}
		}
		else {
			iter.errors << error('Invalid state in general parser')
			return none
		}
	}
}

fn (self OpcodeParser) get_final_state() !int {
	final_states := [8, 9, 10, 11, 14]
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
	mut opcode_parser := OpcodeParser.new(opcode_text)!
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

fn build_data_processing_opcode(general_state int, tokens_list []OpcodeToken) !Opcode {
	opcode_name := tokens_list[0].token_value as string
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

	state_name := OpcodeFinalState.from_int(general_state)!

	opcode := match state_name {
		.register_register {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			rs := tokens_list[current_token].token_value as u8

			ArithmeticOpcode{
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
		.register_immediate {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			expression := tokens_list[current_token].token_value as u8
			if expression > 0x1F {
				return error('Shift expression too big')
			}
			ArithmeticOpcode{
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
		.rrx {
			// In final state 10 we are parsing an RRX which
			// is build as a ROR #0
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			ArithmeticOpcode{
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
		.immediate {
			if tokens_list[current_token].token_type == TokenType.expression {
				immediate_value = tokens_list[current_token].token_value as u32
				println('Immediate value ${immediate_value}')
			} else {
				return error('Invalid expression ${tokens_list[current_token].token_value}')
			}
			shift_operand := get_immediate_value(immediate_value)!
			ArithmeticOpcode{
				condition: condition
				shift_operand: shift_operand
				rn: rn
				rd: rd
				s_bit: s_bit
			}
		}
	}
	match opcode_name {
		'ADC' {
			return ADCOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		'ADD' {
			return ADDOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		'AND' {
			return ANDOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		else {
			return error('Data Processing Opcode ${opcode_name} is not implemented')
		}
	}
}
fn build_branch_opcode(general_state int, tokens_list []OpcodeToken) !Opcode {
	mut condition := OpcodeCondition.al
	mut current_token := 1
	if tokens_list[current_token].token_type == TokenType.condition {
		condition = tokens_list[1].token_value as OpcodeCondition
		current_token += 1
	}
	target_address := tokens_list[current_token].token_value as u32
	return BOpcode{
		condition: condition
		target_address: target_address << 2
	}
}

fn get_opcode_type_from_name(opcode_name string) ?OpcodeType {
	data_processing := ['ADC', 'ADD', 'AND']
	branch := ['B', 'BL']
	if data_processing.contains(opcode_name) {
		return .data_processing
	} else if branch.contains(opcode_name) {
		return .branch
	} else {
		return none
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
	opcode_name := tokens_list[0].token_value as string
	opcode_type := get_opcode_type_from_name(opcode_name)
	match opcode_type {
		.data_processing {
			return build_data_processing_opcode(general_state, tokens_list)!
		}
		.branch {
			return build_branch_opcode(general_state, tokens_list)!
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
