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
		println('State: ${state} = Token: ${token.lexeme}')
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
						// value := parse_register_list(token_type.lexeme) or {
						// 	return error('Cannot parse register list')
						// }
						value := [Register.r1]
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
						// value := parse_register_list(token_type.lexeme) or {
						// 	return error('Cannot parse register list')
						// }
						value := [Register.r1]
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
