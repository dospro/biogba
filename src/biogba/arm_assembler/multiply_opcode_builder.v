module arm_assembler

import biogba {
	MULOpcode,
	Opcode,
	OpcodeCondition,
	opcode_condition_from_string,
	register_from_string,
}

pub struct MultiplyOpcodeBuilder {
mut:
	opcode_name string
	condition   OpcodeCondition
	rd          u8
	rn          u8
	rm          u8
	rs          u8
	a_bit       bool
	s_bit       bool
}

pub fn (self MultiplyOpcodeBuilder) build() !Opcode {
	return MULOpcode{
		condition: self.condition
		rd:        self.rd
		rs:        self.rs
		rm:        self.rm
		rn:        self.rn
		s_bit:     self.s_bit
		a_bit:     self.opcode_name == 'MLA'
	}
}

/*
Finite State Automata

START --+-- MUL --+-- {cond} --+-- {S} --+-- Rd --+-- Rm --+-- Rs --+-- ACCEPT
       |          |            |
       |          |            +-- Rd --+-- Rm --+-- Rs --+-- ACCEPT
       |          |
       |          +-- {S} ----+-- Rd --+-- Rm --+-- Rs --+-- ACCEPT
       |          |
       |          +-- Rd -----+-- Rm --+-- Rs --+-- ACCEPT
       |
       +-- MLA --+-- {cond} --+-- {S} --+-- Rd --+-- Rm --+-- Rs --+-- Rn --+-- ACCEPT
                 |            |
                 |            +-- Rd --+-- Rm --+-- Rs --+-- Rn --+-- ACCEPT
                 |
                 +-- {S} ----+-- Rd --+-- Rm --+-- Rs --+-- Rn --+-- ACCEPT
                 |
                 +-- Rd -----+-- Rm --+-- Rs --+-- Rn --+-- ACCEPT
*/

pub fn MultiplyOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := MultiplyOpcodeBuilder{
		opcode_name: opcode_name
		condition:   OpcodeCondition.al
	}
	end_state := -1
	bad_state := 100
	mut state := 1
	for state != bad_state && state != end_state {
		token := tokenizer.next() or { break }
		match state {
			1 { // After opcode name
				state = match token.token_type {
					.condition {
						value := opcode_condition_from_string(token.lexeme) or {
							return error('Invalid condition')
						}
						builder.condition = value
						2
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						3
					}
					.s_bit {
						builder.s_bit = true
						4
					}
					else {
						bad_state
					}
				}
			}
			2 { // After condition
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						3
					}
					.s_bit {
						builder.s_bit = true
						4
					}
					else {
						bad_state
					}
				}
			}
			3 { // After Rd
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rm = value
						5
					}
					else {
						bad_state
					}
				}
			}
			4 { // After S token
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						3
					}
					else {
						bad_state
					}
				}
			}
			5 { // After Rm
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rs = value
						if opcode_name == 'MLA' {
							6
						} else {
							end_state
						}
					}
					else {
						bad_state
					}
				}
			}
			6 { // After Rs (MLA only)
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rn = value
						end_state
					}
					else {
						bad_state
					}
				}
			}
			else {
				state = end_state
			}
		}
	}
	return builder.build()
}
