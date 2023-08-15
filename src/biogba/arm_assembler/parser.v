module arm_assembler

import biogba {
	OpcodeCondition,
	opcode_condition_from_string,
	register_from_string,
	shift_type_from_string,
	ShiftType,
}
import regex

pub const (
	opcode_names = ['ADC', 'ADD', 'AND', 'BIC', 'BL', 'BX', 'B']
	conditions   = ['EQ', 'NE', 'CS', 'CC', 'MI', 'PL', 'VS', 'VC', 'HI', 'LS', 'GE', 'LT', 'GT',
		'LE', 'AL']
	data_processing_opcodes = ['ADC', 'ADD', 'AND', 'BIC']
	branch_opcodes = ['B', 'BL']
	branch_and_exchange_opcodes = ['BX']
)

/*
Builds a regex query that recognizes the opcode name format.

The opcode name format can be represented as:
{opcode_name}{<condition>}{<S>}

The function uses a list of all possible names and conditions to build a long regex
*/
fn build_opcode_name_regex() string {
	mut regex_string := r'^(?P<name>'
	regex_string += '(${arm_assembler.opcode_names[0]})'
	for op_name in arm_assembler.opcode_names[1..] {
		regex_string += '|(${op_name})'
	}
	regex_string += ')(?P<cond>(${arm_assembler.conditions[0]})'
	for cond in arm_assembler.conditions[1..] {
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
			if token in data_processing_opcodes{
				iter.state = 1
			} else if token in branch_opcodes {
				iter.state = 12
			} else if token in branch_and_exchange_opcodes {
				iter.state = 15
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
					token_value: opcode_condition_from_string(iter.opcode_name_parts['cond'] or {
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
					token_value: register_from_string(iter.fields[1]) or {
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
					token_value: register_from_string(iter.fields[1]) or {
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
				token_value: register_from_string(iter.fields[1]) or {
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
				token_value: register_from_string(iter.fields[2]) or {
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
					token_value: register_from_string(iter.fields[3]) or {
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
					token_value: register_from_string(iter.fields[5]) or {
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
					token_value: opcode_condition_from_string(iter.opcode_name_parts['cond'] or {
						''
					}) or { OpcodeCondition.al }
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
			return OpcodeToken{
				token_value: u32(iter.fields[1][1..].parse_uint(16, 32) or {
					iter.errors << err
					return none
				})
				token_type: .expression
			}
		}
		15 {
			iter.state = 16
			return OpcodeToken{
				token_value: opcode_condition_from_string(iter.opcode_name_parts['cond'] or {
					''
				}) or { OpcodeCondition.al }
				token_type: TokenType.condition
			}
		}
		16 {
			iter.state = 17
			return OpcodeToken{
				token_value: register_from_string(iter.fields[1]) or {
					iter.errors << err
					return none
				}
				token_type: TokenType.register
			}
		}
		else {
			iter.errors << error('Invalid state in general parser')
			return none
		}
	}
}

fn (self OpcodeParser) get_final_state() !int {
	final_states := [8, 9, 10, 11, 14, 17]
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
pub fn tokens_from_string(opcode_text string) !TokensList {
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
