module arm_assembler

import biogba {
	LDROpcode,
	Offset,
	Opcode,
	OpcodeCondition,
	RegisterOffset,
	ShiftType,
	opcode_condition_from_string,
	register_from_string,
}

pub struct SingleDataTransferOpcodeBuilder {
mut:
	opcode_name string
	condition   OpcodeCondition
	rd          u8
	rn          u8
	p_bit       bool
	u_bit       bool
	b_bit       bool
	w_bit       bool
	address     Offset
}

pub struct RegisterOffsetBuilder {
pub mut:
	rm          u8
	shift_type  ShiftType
	shift_value u8
}

pub fn SingleDataTransferOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer, asm_state AsmState) !Opcode {
	mut builder := SingleDataTransferOpcodeBuilder{
		opcode_name: opcode_name
		condition: OpcodeCondition.al
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0)
	}

	mut address_builder := RegisterOffsetBuilder{}
	mut with_register_offset := false
	end_state := -1
	bad_state := 100

	mut state := 1
	for state != bad_state && state != end_state {
		token := tokenizer.next() or { break }
		println('${state} ${token}')
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
						// parsed as an opcode, but in the second stage
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
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						builder.rn = 15
						if value < 0 {
							return error('Absolute offset cannot be a negative value')
						}
						mut real_address := u16(0)
						if asm_state.r15 > value {
							real_address = u16(asm_state.r15 - value + 8)
							builder.u_bit = false
						} else {
							real_address = asm_state.get_real_address(u16(value))
						}
						if real_address >= 0x1000 {
							return error('Absolute address cannot be bigger than 11 bits. Value: ${value}')
						}
						builder.address = real_address
						state // Final state
					}
					.open_bracket {
						6
					}
					else {
						end_state
					}
				}
			}
			6 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.rn = value
						7
					}
					else {
						end_state
					}
				}
			}
			7 {
				state = match token.token_type {
					.close_bracket {
						end_state
					}
					.expression {
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						if value >= 0x1000 || value <= -0x1000 {
							return error('Absolute address cannot be bigger than 12 bits. Value: ${value}')
						}

						if value < 0 {
							builder.address = u16(-value)
							builder.u_bit = false
						} else {
							builder.address = u16(value)
							builder.u_bit = true
						}
						8
					}
					.sign {
						if token.lexeme == '-' {
							builder.u_bit = false
							9
						} else if token.lexeme == '+' {
							builder.u_bit = true
							9
						}
						 else {
							bad_state
						}
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						// From here the opcode now uses a register offset
						address_builder.rm = value
						with_register_offset = true
						8
					}
					else {
						bad_state
					}
				}
			}
			8 {
				state = match token.token_type {
					.close_bracket {
						11
					}
					else {
						bad_state
					}
				}
			}
			9 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						address_builder.rm = value
						with_register_offset = true
						8
					}
					else {
						bad_state
					}
				}
			}
			11 {
				state = match token.token_type {
					.write_back {
						builder.w_bit = true
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
	println('final state was ${state}')
	// There state that are in the middle of the state machine which
	// are also end states. If the parser stopped at one of those, it
	// is considered an end_state.
	if state == 11 || state == 5 {
		state = end_state
	}
	if state != end_state {
		return error('Did not reach a final state')
	}

	// We may be able to get rid of this boolean flag
	if with_register_offset {
		builder.address = RegisterOffset {
			rm: address_builder.rm
			shift_type: address_builder.shift_type
			shift_value: address_builder.shift_value
		}
	}
	return LDROpcode{
		condition: builder.condition
		rd: builder.rd
		rn: builder.rn
		p_bit: builder.p_bit
		u_bit: builder.u_bit
		b_bit: builder.b_bit
		w_bit: builder.w_bit
		address: builder.address
	}
}
