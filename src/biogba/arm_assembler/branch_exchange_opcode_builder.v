module arm_assembler

import biogba {
	Opcode
	BXOpcode
	OpcodeCondition
	opcode_condition_from_string
	register_from_string
}

pub struct BranchExchangeOpcodeBuilder {
mut:
	condition     OpcodeCondition = OpcodeCondition.al
	rm            u8
}

pub fn BranchExchangeOpcodeBuilder.parse(mut tokenizer Tokenizer) !Opcode {
	mut builder := BranchExchangeOpcodeBuilder{}
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
							return error('Invalid condition')
						}
						builder.set_condition(value)
						2
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return err
						}
						builder.set_rm(value)
						100
					}
					else {
						-1
					}
				}
			}
			2 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return err
						}
						builder.set_rm(value)
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

pub fn (mut self BranchExchangeOpcodeBuilder) set_condition(condition OpcodeCondition) BranchExchangeOpcodeBuilder {
	self.condition = condition
	return self
}

pub fn (mut self BranchExchangeOpcodeBuilder) set_rm(value u8) BranchExchangeOpcodeBuilder {
	self.rm = value
	return self
}

pub fn (mut self BranchExchangeOpcodeBuilder) build() !Opcode {
	return BXOpcode {
		condition: self.condition
		rm: self.rm
	}
}