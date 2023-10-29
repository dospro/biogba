module arm_assembler

import biogba {
	BOpcode,
	Opcode,
	OpcodeCondition,
	opcode_condition_from_string,
}

pub struct BranchOpcodeBuilder {
mut:
	opcode_name    string
	condition      OpcodeCondition = OpcodeCondition.al
	l_flag         bool = false
	target_address u32
}

pub fn BranchOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := BranchOpcodeBuilder{
		opcode_name: opcode_name
	}
	mut state := 1
	for state != -1 && state != 100 {
		token := tokenizer.next() or {
			state = -1
			break
		}
		match state {
			1 {
				state = match token.token_type {
					.condition {
						value := opcode_condition_from_string(token.lexeme) or {
							return error('Invalud condition')
						}
						builder.set_condition(value)
						2
					}
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or { return err })
						if (value & 3) != 0 {
							return error('Target address for B opcode must have lower 2 bits set to 0')
						}
						builder.set_target_address(value)
						100
					}
					else {
						-1
					}
				}
			}
			2 {
				state = match token.token_type {
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or { return err })
						if (value & 3) != 0 {
							return error('Target address for B opcode must have lower 2 bits set to 0')
						}
						builder.set_target_address(value)
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

pub fn (mut self BranchOpcodeBuilder) set_condition(condition OpcodeCondition) BranchOpcodeBuilder {
	self.condition = condition
	return self
}

pub fn (mut self BranchOpcodeBuilder) set_target_address(value u32) BranchOpcodeBuilder {
	self.target_address = value
	return self
}

pub fn (mut self BranchOpcodeBuilder) build() !Opcode {
	match self.opcode_name {
		'B' {
			return BOpcode{
				condition: self.condition
				l_flag: false
				target_address: self.target_address >> 2
			}
		}
		'BL' {
			return BOpcode{
				condition: self.condition
				l_flag: true
				target_address: self.target_address >> 2
			}
		}
		else {
			return error('Opcode ${self.opcode_name} not implemented')
		}
	}
}
