module arm_assembler

import biogba {
	LDROpcode,
	LDRSBHOpcode,
	Offset,
	LDRSBHOffset,
	Opcode,
	OpcodeCondition,
	Register
	RegisterOffset,
	ShiftType,
	opcode_condition_from_string,
	register_from_string
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
	s_bit       bool
	h_bit       bool
	ldr_address Offset
	ldrsbh_address LDRSBHOffset
}

pub fn (self SingleDataTransferOpcodeBuilder) build() !Opcode {
	 match self.opcode_name {
		'LDR' {
			return LDROpcode{
				condition: self.condition
				rd: self.rd
				rn: self.rn
				p_bit: self.p_bit
				u_bit: self.u_bit
				b_bit: self.b_bit
				w_bit: self.w_bit
				address: self.ldr_address
			}
		}
		'LDRH' {
			return LDRSBHOpcode{
				condition: self.condition
				rd: self.rd
				rn: self.rn
				p_bit: self.p_bit
				u_bit: self.u_bit
				w_bit: self.w_bit
				s_bit: self.s_bit
				h_bit: true
				address: u8(0)
			}
		}
		else {
			return error('Invalid opcode name ${self.opcode_name}')
		}
	}
}

pub fn (mut self SingleDataTransferOpcodeBuilder) set_rm(value u16) SingleDataTransferOpcodeBuilder {
	if self.opcode_name == 'LDR'{
		if mut self.ldr_address is u16 {
			self.ldr_address = RegisterOffset {
				rm: u8(value)
			}
		} else if mut self.ldr_address is RegisterOffset{
			self.ldr_address.rm = u8(value)
		}
	}
	return self
}

pub fn (mut self SingleDataTransferOpcodeBuilder) set_shift_type(value ShiftType) SingleDataTransferOpcodeBuilder {
	if self.opcode_name == 'LDR'{
		if mut self.ldr_address is u16 {
			self.ldr_address = RegisterOffset {
				shift_type: value
			}
		} else if mut self.ldr_address is RegisterOffset{
			self.ldr_address.shift_type = value
		}
	}
	return self
}

pub fn (mut self SingleDataTransferOpcodeBuilder) set_shift_value(value u8) SingleDataTransferOpcodeBuilder {
	if self.opcode_name == 'LDR'{
		if mut self.ldr_address is u16 {
			self.ldr_address = RegisterOffset {
				shift_value: value
			}
		} else if mut self.ldr_address is RegisterOffset{
			self.ldr_address.shift_value = value
		}
	}
	return self

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
		ldr_address: u16(0)
		ldrsbh_address: u8(0)
	}

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
						builder.ldr_address = real_address
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
						14 // End state or possible post index expression
					}
					.expression {
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						if value >= 0x1000 || value <= -0x1000 {
							return error('Absolute address cannot be bigger than 12 bits. Value: ${value}')
						}

						if value < 0 {
							builder.ldr_address = u16(-value)
							builder.u_bit = false
						} else {
							builder.ldr_address = u16(value)
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
						} else {
							bad_state
						}
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						// From here the opcode now uses a register offset
						builder.set_rm(value)
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
					.shift_name {
						shift_type := ShiftType.from_string(token.lexeme) or {
							return error('Invalid shift type ${token.lexeme}')
						}
						builder.set_shift_type(shift_type)
						12
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
						builder.set_rm(value)
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
			12 {
				state = match token.token_type {
					.expression {
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						if value < 0 || value >= 256 {
							return error('Shift value cannot be longer than 8 bits')
						}
						builder.set_shift_value(u8(value))
						13
					}
					else {
						bad_state
					}
				}
			}
			13 {
				state = match token.token_type {
					.close_bracket {
						11
					}
					else {
						bad_state
					}
				}
			}
			14 {
				state = match token.token_type {
					.expression {
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						if value >= 0x1000 || value <= -0x1000 {
							return error('Absolute address cannot be bigger than 12 bits. Value: ${value}')
						}

						if value < 0 {
							builder.ldr_address = u16(-value)
							builder.u_bit = false
						} else {
							builder.ldr_address = u16(value)
							builder.u_bit = true
						}
						builder.p_bit = false
						end_state
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rm(value)
						builder.p_bit = false
						15
					}
					.sign {
						if token.lexeme == '-' {
							builder.u_bit = false
							builder.p_bit = false
							17
						} else if token.lexeme == '+' {
							builder.u_bit = true
							builder.p_bit = false
							17
						} else {
							bad_state
						}
					}
					else {
						bad_state
					}
				}
			}
			15 {
				state = match token.token_type {
					.shift_name {
						shift_type := ShiftType.from_string(token.lexeme) or {
							return error('Invalid shift type ${token.lexeme}')
						}
						builder.set_shift_type(shift_type)
						16
					}
					else {
						bad_state
					}
				}
			}
			16 {
				state = match token.token_type {
					.expression {
						value := token.lexeme[1..].parse_int(16, 32) or { return err }
						if value < 0 || value >= 256 {
							return error('Shift value cannot be longer than 8 bits')
						}
						builder.set_shift_value(u8(value))
						end_state
					}
					else {
						bad_state
					}
				}
			}
			17 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rm(value)
						15
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
	if state == 11 || state == 5 || state == 14 || state == 15 {
		state = end_state
	}
	if state != end_state {
		return error('Did not reach a final state')
	}

	return builder.build()
}
