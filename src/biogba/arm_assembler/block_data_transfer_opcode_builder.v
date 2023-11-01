module arm_assembler

import biogba {
	LDMOpcode,
	Opcode,
	OpcodeCondition,
	Register,
	opcode_condition_from_string,
	register_from_string,
}

pub struct BlockDataTransferOpcodeBuilder {
mut:
	opcode_name   string
	condition     OpcodeCondition = OpcodeCondition.al
	rn            u8
	p_bit         bool
	u_bit         bool
	w_bit         bool
	register_list []Register
}

pub fn BlockDataTransferOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := BlockDataTransferOpcodeBuilder{
		opcode_name: opcode_name
	}
	mut state := 1
	for state != -1 && state != 100 {
		token := tokenizer.next() or {
			if state == 6 {
				state = 100
			} else {
				state = -1
			}
			break
		}
		// println('State: ${state} = Token: ${token.lexeme}')
		match state {
			1 {
				state = match token.token_type {
					.condition {
						value := opcode_condition_from_string(token.lexeme) or {
							return error('Invalid condition')
						}
						builder.set_condition(value)
						2
					}
					.addressing_mode {
						builder.set_addressing_mode(token.lexeme)
						3
					}
					else {
						-1
					}
				}
			}
			2 {
				state = match token.token_type {
					.addressing_mode {
						builder.set_addressing_mode(token.lexeme)
						3
					}
					else {
						-1
					}
				}
			}
			3 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rn(value)
						4
					}
					else {
						-1
					}
				}
			}
			4 {
				state = match token.token_type {
					.write_back {
						builder.set_w_bit(true)
						5
					}
					.register_list {
						value := parse_register_list(token.lexeme) or {
							return error('Cannot parse register list')
						}
						builder.set_register_list(value)
						6
					}
					else {
						-1
					}
				}
			}
			5 {
				state = match token.token_type {
					.register_list {
						value := parse_register_list(token.lexeme) or {
							return error('Cannot parse register list')
						}
						builder.set_register_list(value)
						6
					}
					else {
						-1
					}
				}
			}
			6 {
				println(token)
				state = match token.token_type {
					.s_bit {
						println('Unimplemented')
						100
					}
					else {
						-1
					}
				}
			}
			else {
				state = -1
			}
		}
	}
	if state != 100 {
		return error('Opcode is not valid')
	}

	if next_token := tokenizer.next() {
		return error('Unexpected token ${next_token}')
	} else {
		return builder.build()!
	}
}

pub fn (mut self BlockDataTransferOpcodeBuilder) set_condition(condition OpcodeCondition) BlockDataTransferOpcodeBuilder {
	self.condition = condition
	return self
}

pub fn (mut self BlockDataTransferOpcodeBuilder) set_rn(value u8) BlockDataTransferOpcodeBuilder {
	self.rn = value
	return self
}

pub fn (mut self BlockDataTransferOpcodeBuilder) set_addressing_mode(value string) BlockDataTransferOpcodeBuilder {
	match value {
		'IB', 'ED' {
			self.u_bit = true
			self.p_bit = true
		}
		'IA', 'FD' {
			self.u_bit = true
			self.p_bit = false
		}
		'DB', 'EA' {
			self.u_bit = false
			self.p_bit = true
		}
		'DA', 'FA' {
			self.u_bit = false
			self.p_bit = false
		}
		else {}
	}
	return self
}

pub fn (mut self BlockDataTransferOpcodeBuilder) set_w_bit(value bool) BlockDataTransferOpcodeBuilder {
	self.w_bit = value
	return self
}

pub fn (mut self BlockDataTransferOpcodeBuilder) set_register_list(value []Register) BlockDataTransferOpcodeBuilder {
	self.register_list = value.clone()
	return self
}

pub fn (mut self BlockDataTransferOpcodeBuilder) build() !Opcode {
	match self.opcode_name {
		'LDM' {
			return LDMOpcode{
				condition: self.condition
				rn: self.rn
				p_bit: self.p_bit
				u_bit: self.u_bit
				w_bit: self.w_bit
				register_list: self.register_list.clone()
			}
		}
		else {
			return error('Opcode ${self.opcode_name} not implemented')
		}
	}
}

fn parse_register_list(lexeme string) ![]Register {
	println(lexeme)
	mut state := 0
	mut register_list := []Register{}
	mut position := 0
	mut register_string := ''
	mut register_range_start := 0
	mut register_range_end := 0
	for state != -1 && state != 100{
		if position >= lexeme.len {
			break
		}
		next_character := lexeme[position]
		position += 1
		match state {
			0 {
				// It must start with a curly bracket. No space or anything
				state = match next_character.ascii_str() {
					'{' { 1 }
					else { - 1 }
				}
			}
			1 {
				// Ignore any space. Look for an R
				if next_character.is_space() {
					state = 1
				} else if next_character.ascii_str() == 'R' {
					register_string += 'R'
					state = 2
				} else {
					state = -1
				}
			}
			2 {
				if next_character.is_digit() {
					register_string += next_character.ascii_str()
					state = 3
				} else {
					state = -1
				}
			}
			3 {
				if next_character.is_digit() {
					register_string += next_character.ascii_str()
					state = 3
				} else if next_character.is_space() {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_list << Register.from_int(value) or {return err}
					register_string = ''
					state = 4
				} else if next_character.ascii_str() == ',' {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_list << Register.from_int(value) or {return err}
					register_string = ''
					state = 1
				} else if next_character.ascii_str() == '-' {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_range_start = value
					register_string = ''
					state = 5
				} else if next_character.ascii_str() == '}' {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_list << Register.from_int(value) or {return err}
					register_string = ''
					state = 100
				} else {
					state = -1
				}
			}
			4 {
				if next_character.is_space() {
					state = 4
				} else if next_character.ascii_str() == '}' {
					state = 100
				} else {
					state = -1
				}
			}
			5 {
				if next_character.ascii_str() == 'R' {
					register_string += 'R'
					state = 6
				} else {
					state = -1
				}
			}
			6 {
				if next_character.is_digit() {
					register_string += next_character.ascii_str()
					state = 7
				} else {
					state = -1
				}
			}
			7 {
				if next_character.is_digit() {
					register_string += next_character.ascii_str()
					state = 7
				} else if next_character.is_space() {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_range_end = value
					mut i := register_range_start
					for i <= register_range_end {
						register_list << Register.from_int(i) or {return err}
						i += 1
					}
					register_string = ''
					state = 4
				} else if next_character.ascii_str() == ',' {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_range_end = value
					mut i := register_range_start
					for i <= register_range_end {
						register_list << Register.from_int(i) or {return err}
						i += 1
					}
					register_string = ''
					state = 1
				} else if next_character.ascii_str() == '}' {
					value := register_from_string(register_string) or {
						return error('Invalid register')
					}
					register_range_end = value
					mut i := register_range_start
					for i <= register_range_end {
						register_list << Register.from_int(i) or {return err}
						i += 1
					}
					register_string = ''
					state = 100
				} else {
					state = -1
				}
			}
			else {
				state = -1
			}
		}
	}
	if state != 100 {
		return error('Unable to parse register list ${lexeme}')
	}
	return register_list.clone()
}