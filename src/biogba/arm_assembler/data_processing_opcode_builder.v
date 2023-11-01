module arm_assembler

import biogba {
	ADCOpcode,
	ADDOpcode,
	ANDOpcode,
	BICOpcode,
	CMNOpcode,
	CMPOpcode,
	EOROpcode,
	Opcode,
	OpcodeCondition,
	ShiftOperand,
	ShiftOperandImmediate,
	ShiftOperandRegister,
	ShiftType,
	opcode_condition_from_string,
	register_from_string,
	shift_type_from_string,
}

pub struct Pair[T] {
pub:
	first  T
	second T
}

pub type ShiftOperandBuilder = ShiftOperandImmediateBuilder | ShiftOperandRegisterBuilder

pub struct ShiftOperandImmediateBuilder {
mut:
	value  u8
	rotate u8
}

/*
From a 32 bits value generates a value/rotation pair that represents
the value given in the parameter.
Returns a ShiftOperandImmediate struct with the values
*/
pub fn (mut shift_operand ShiftOperandImmediateBuilder) set_value(value Pair[u8]) ShiftOperandImmediateBuilder {
	shift_operand.value = value.first
	shift_operand.rotate = value.second
	return shift_operand
}

pub fn (mut shift_operand ShiftOperandImmediateBuilder) build() ShiftOperandImmediate {
	return ShiftOperandImmediate{
		value: shift_operand.value
		rotate: shift_operand.rotate
	}
}

pub struct ShiftOperandRegisterBuilder {
mut:
	rm             u8
	register_shift bool
	shift_type     ShiftType
	shift_value    u8
}

pub fn (mut shift_operand ShiftOperandRegisterBuilder) set_rm(value u8) ShiftOperandRegisterBuilder {
	shift_operand.rm = value
	return shift_operand
}

pub fn (mut shift_operand ShiftOperandRegisterBuilder) set_register_shift(value bool) ShiftOperandRegisterBuilder {
	shift_operand.register_shift = value
	return shift_operand
}

pub fn (mut shift_operand ShiftOperandRegisterBuilder) set_shift_type(value ShiftType) ShiftOperandRegisterBuilder {
	shift_operand.shift_type = value
	return shift_operand
}

pub fn (mut shift_operand ShiftOperandRegisterBuilder) set_shift_value(value u8) ShiftOperandRegisterBuilder {
	shift_operand.shift_value = value
	return shift_operand
}

pub fn (mut shift_operand ShiftOperandRegisterBuilder) build() ShiftOperandRegister {
	return ShiftOperandRegister{
		rm: shift_operand.rm
		register_shift: shift_operand.register_shift
		shift_type: shift_operand.shift_type
		shift_value: shift_operand.shift_value
	}
}

pub struct DataProcessingOpcodeBuilder {
mut:
	opcode_name   string
	condition     OpcodeCondition = OpcodeCondition.al
	shift_operand ShiftOperand    = ShiftOperandImmediate{}
	rn            u8
	rd            u8
	s_bit         bool
}

pub fn DataProcessingOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := DataProcessingOpcodeBuilder{
		opcode_name: opcode_name
	}
	mut shift_operand_immediate_builder := ShiftOperandImmediateBuilder{}
	mut shift_operand_register_builder := ShiftOperandRegisterBuilder{}
	mut state := 1
	for state != -1 && state != 100 {
		token := tokenizer.next() or {
			state = -1
			break
		}
		println('State ${state}: Lexeme: ${token.lexeme}')
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
					.s_bit {
						builder.set_s_bit()
						3
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rd(value)
						4
					}
					else {
						-1
					}
				}
			}
			2 {
				state = match token.token_type {
					.s_bit {
						builder.set_s_bit()
						3
					}
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rd(value)
						4
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
						builder.set_rd(value)
						4
					}
					else {
						-1
					}
				}
			}
			4 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						builder.set_rn(value)
						5
					}
					else {
						-1
					}
				}
			}
			5 {
				state = match token.token_type {
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or { return err })
						value_pair := get_immediate_value(value) or { return err }
						shift_operand_immediate_builder.set_value(value_pair)
						builder.set_shift_operand(shift_operand_immediate_builder.build())
						100
					}
					.register {
						value := register_from_string(token.lexeme) or { return err }
						shift_operand_register_builder.set_rm(value)
						6
					}
					else {
						-1
					}
				}
			}
			6 {
				state = match token.token_type {
					.shift_name {
						if token.lexeme == 'RRX' {
							shift_operand_register_builder.set_shift_type(ShiftType.ror)
							shift_operand_register_builder.set_shift_value(0)
							builder.set_shift_operand(shift_operand_register_builder.build())
							100
						} else {
							value := shift_type_from_string(token.lexeme) or { return err }
							shift_operand_register_builder.set_shift_type(value)
							7
						}
					}
					else {
						-1
					}
				}
			}
			7 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						shift_operand_register_builder.set_register_shift(true)
						shift_operand_register_builder.set_shift_value(value)
						builder.set_shift_operand(shift_operand_register_builder.build())
						100
					}
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or {
							return error('Invalid expression')
						})
						if value >= 32 {
							return error('Value must be between 0 and 31')
						}
						shift_operand_register_builder.set_register_shift(false)
						shift_operand_register_builder.set_shift_value(u8(value))
						builder.set_shift_operand(shift_operand_register_builder.build())
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
	println(state)
	println(builder)
	if state != 100 {
		return error('Opcode is not valid')
	}

	if next_token := tokenizer.next() {
		return error('Unexpected token ${next_token}')
	} else {
		return builder.build()!
	}
}

pub fn DataProcessingOpcodeBuilder.parse_compare_opcode(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := DataProcessingOpcodeBuilder{
		opcode_name: opcode_name
	}
	mut shift_operand_immediate_builder := ShiftOperandImmediateBuilder{}
	mut shift_operand_register_builder := ShiftOperandRegisterBuilder{}
	mut state := 1
	for state != -1 && state != 100 {
		token := tokenizer.next() or {
			state = -1
			break
		}
		println('State ${state}: Lexeme: ${token.lexeme}')
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
							return error('Invalid register')
						}
						builder.set_rn(value)
						3
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
							return error('Invalid register')
						}
						builder.set_rn(value)
						3
					}
					else {
						-1
					}
				}
			}
			3 {
				state = match token.token_type {
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or { return err })
						value_pair := get_immediate_value(value) or { return err }
						shift_operand_immediate_builder.set_value(value_pair)
						builder.set_shift_operand(shift_operand_immediate_builder.build())
						100
					}
					.register {
						value := register_from_string(token.lexeme) or { return err }
						shift_operand_register_builder.set_rm(value)
						4
					}
					else {
						-1
					}
				}
			}
			4 {
				state = match token.token_type {
					.shift_name {
						if token.lexeme == 'RRX' {
							shift_operand_register_builder.set_shift_type(ShiftType.ror)
							shift_operand_register_builder.set_shift_value(0)
							builder.set_shift_operand(shift_operand_register_builder.build())
							100
						} else {
							value := shift_type_from_string(token.lexeme) or { return err }
							shift_operand_register_builder.set_shift_type(value)
							5
						}
					}
					else {
						-1
					}
				}
			}
			5 {
				state = match token.token_type {
					.register {
						value := register_from_string(token.lexeme) or {
							return error('Invalid register')
						}
						shift_operand_register_builder.set_register_shift(true)
						shift_operand_register_builder.set_shift_value(value)
						builder.set_shift_operand(shift_operand_register_builder.build())
						100
					}
					.expression {
						value := u32(token.lexeme[1..].parse_uint(16, 32) or {
							return error('Invalid expression')
						})
						if value >= 32 {
							return error('Value must be between 0 and 31')
						}
						shift_operand_register_builder.set_register_shift(false)
						shift_operand_register_builder.set_shift_value(u8(value))
						builder.set_shift_operand(shift_operand_register_builder.build())
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

pub fn (mut self DataProcessingOpcodeBuilder) set_condition(condition OpcodeCondition) DataProcessingOpcodeBuilder {
	self.condition = condition
	return self
}

pub fn (mut self DataProcessingOpcodeBuilder) set_rn(rn u8) DataProcessingOpcodeBuilder {
	self.rn = rn
	return self
}

pub fn (mut self DataProcessingOpcodeBuilder) set_rd(rd u8) DataProcessingOpcodeBuilder {
	self.rd = rd
	return self
}

pub fn (mut self DataProcessingOpcodeBuilder) set_s_bit() DataProcessingOpcodeBuilder {
	self.s_bit = true
	return self
}

pub fn (mut self DataProcessingOpcodeBuilder) set_shift_operand(value ShiftOperand) DataProcessingOpcodeBuilder {
	self.shift_operand = value
	return self
}

pub fn (self DataProcessingOpcodeBuilder) build() !Opcode {
	match self.opcode_name {
		'ADC' {
			return ADCOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				rd: self.rd
				s_bit: self.s_bit
			}
		}
		'ADD' {
			return ADDOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				rd: self.rd
				s_bit: self.s_bit
			}
		}
		'AND' {
			return ANDOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				rd: self.rd
				s_bit: self.s_bit
			}
		}
		'BIC' {
			return BICOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				rd: self.rd
				s_bit: self.s_bit
			}
		}
		'CMN' {
			return CMNOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				s_bit: true
			}
		}
		'CMP' {
			return CMPOpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				s_bit: true
			}
		}
		'EOR' {
			return EOROpcode{
				condition: self.condition
				shift_operand: self.shift_operand
				rn: self.rn
				rd: self.rd
				s_bit: self.s_bit
			}
		}
		else {
			return error('Opcode ${self.opcode_name} not implemented')
		}
	}
}

fn get_immediate_value(immediate u32) !Pair[u8] {
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

	return Pair{u8(immediate_value), u8(((32 - shift_counter) / 2) & 0xF)}
}
