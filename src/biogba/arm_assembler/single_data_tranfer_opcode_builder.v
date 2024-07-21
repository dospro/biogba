module arm_assembler

import biogba {
	LDROpcode,
	Opcode,
	OpcodeCondition,
	Register,
	Offset,
	opcode_condition_from_string,
	register_from_string,
}

pub struct SingleDataTransferOpcodeBuilder {
mut:
	opcode_name   string
	condition	  OpcodeCondition
	rd            u8
	rn            u8
	p_bit         bool
	u_bit         bool
	b_bit         bool
	w_bit         bool
	address       Offset
}

pub fn SingleDataTransferOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := SingleDataTransferOpcodeBuilder{
		opcode_name: opcode_name
		condition: OpcodeCondition.al
		rn: 1
		p_bit: true
		b_bit: false
		address: u16(0)
	}
	end_state := -1
	bad_state := 100

	mut state := 1
	for state != bad_state && state != end_state {
		token := tokenizer.next() or {
			break
		 }
		 println(token)
		 match state {
			1 {
				state = match token.token_type {
					.condition {
						value := opcode_condition_from_string(token.lexeme) or {
							return error('Invalid condition')
						}
						builder.condition = value
						2
					}
					.opcode_name {
						if token.lexeme == 'B' {
							builder.b_bit = true
							3
						} else {
							bad_state
						}
					}
					.t_mode {
						builder.p_bit = false
						builder.w_bit = true
						4
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						5
					}
					else {
						end_state
					}
				}
			}
			2 {
				state = match token.token_type {
					.opcode_name {
						// Not an actual opcode name. The token B is 
						// parsed as an opcode, but in the second stage it is
						// it is interpreted as Byte for LDR
						if token.lexeme == 'B' {
							builder.b_bit = true
							3
						} else {
							bad_state
						}
					}
					.t_mode {
						builder.p_bit = false
						builder.w_bit = true
						4
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						5
					}
					else {
						end_state
					}
				}
			}
			3 {
				state = match token.token_type {
					.t_mode {
						builder.p_bit = false
						builder.w_bit = true
						4
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						5
					} 
					else {
						end_state
					}
				}
			}
			4 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rd = value
						5
					}
					else {
						end_state
					}
				}
			}
			5 {
				state = match token.token_type {
					.expression {
						value := u16(token.lexeme[1..].parse_uint(16, 32) or { return err })
						builder.rn = 15
						builder.address = u16(value)
						end_state
					}
					else {
						end_state
					}
				}
			}
			else {
				state = end_state
			}
		 }
	}
	return LDROpcode{
		condition: builder.condition
		rd: builder.rd
		rn: builder.rn
		p_bit: builder.p_bit
		u_bit: true
		b_bit: builder.b_bit
		w_bit: builder.w_bit
		address: builder.address
	}
}