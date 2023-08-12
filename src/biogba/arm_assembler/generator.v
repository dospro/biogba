module arm_assembler

import biogba {
	ADCOpcode,
	ADDOpcode,
	ANDOpcode,
	BICOpcode,
	ArithmeticOpcode,
	BOpcode,
	Opcode,
	OpcodeCondition,
	ShiftOperandImmediate,
	ShiftOperandRegister,
	ShiftType,
}

enum OpcodeFinalState {
	immediate = 11
	register_immediate = 9
	register_register = 8
	rrx = 10
}

fn OpcodeFinalState.from_int(value int) !OpcodeFinalState {
	return match value {
		8 { .register_register }
		9 { .register_immediate }
		10 { .rrx }
		11 { .immediate }
		else { error('Unknown final state') }
	}
}

fn build_data_processing_opcode(general_state int, tokens_list []OpcodeToken) !Opcode {
	opcode_name := tokens_list[0].token_value as string
	mut condition := OpcodeCondition.al
	mut s_bit := false
	mut rd := u8(0x0)
	mut rn := u8(0x0)
	mut rm := u8(0x0)
	mut immediate_value := u32(0x0)

	mut current_token := 1
	if tokens_list[current_token].token_type == TokenType.condition {
		condition = tokens_list[1].token_value as OpcodeCondition
		current_token += 1
	} else {
		condition = OpcodeCondition.al
	}
	if tokens_list[current_token].token_type == TokenType.s_bit {
		s_bit = true
		current_token += 1
	} else {
		s_bit = false
	}
	if tokens_list[current_token].token_type == TokenType.register {
		rd = tokens_list[current_token].token_value as u8
		current_token += 1
		println('Rd ${rd}')
	} else {
		return error('Expected register Rd')
	}
	if tokens_list[current_token].token_type == TokenType.register {
		rn = tokens_list[current_token].token_value as u8
		println('Rn ${rn}')
		current_token += 1
	} else {
		error('Expected register Rn')
	}

	state_name := OpcodeFinalState.from_int(general_state)!

	opcode := match state_name {
		.register_register {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			rs := tokens_list[current_token].token_value as u8

			ArithmeticOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandRegister{
					rm: rm
					register_shift: true
					shift_type: shift_type
					shift_value: rs
				}
			}
		}
		.register_immediate {
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			shift_type := tokens_list[current_token].token_value as ShiftType
			current_token += 1
			expression := tokens_list[current_token].token_value as u8
			if expression > 0x1F {
				return error('Shift expression too big')
			}
			ArithmeticOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandRegister{
					rm: rm
					register_shift: false
					shift_type: shift_type
					shift_value: expression
				}
			}
		}
		.rrx {
			// In final state 10 we are parsing an RRX which
			// is build as a ROR #0
			rm = tokens_list[current_token].token_value as u8
			current_token += 1
			println('Rm ${rm}')
			ArithmeticOpcode{
				condition: condition
				rd: rd
				rn: rn
				s_bit: s_bit
				shift_operand: ShiftOperandRegister{
					rm: rm
					register_shift: false
					shift_type: ShiftType.ror
					shift_value: 0
				}
			}
		}
		.immediate {
			if tokens_list[current_token].token_type == TokenType.expression {
				immediate_value = tokens_list[current_token].token_value as u32
				println('Immediate value ${immediate_value}')
			} else {
				return error('Invalid expression ${tokens_list[current_token].token_value}')
			}
			shift_operand := get_immediate_value(immediate_value)!
			ArithmeticOpcode{
				condition: condition
				shift_operand: shift_operand
				rn: rn
				rd: rd
				s_bit: s_bit
			}
		}
	}
	match opcode_name {
		'ADC' {
			return ADCOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		'ADD' {
			return ADDOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		'AND' {
			return ANDOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		'BIC' {
			return BICOpcode{
				condition: opcode.condition
				shift_operand: opcode.shift_operand
				rn: opcode.rn
				rd: opcode.rd
				s_bit: opcode.s_bit
			}
		}
		else {
			return error('Data Processing Opcode ${opcode_name} is not implemented')
		}
	}
}

fn build_branch_opcode(general_state int, tokens_list []OpcodeToken) !Opcode {
	mut condition := OpcodeCondition.al
	mut current_token := 1
	if tokens_list[current_token].token_type == TokenType.condition {
		condition = tokens_list[1].token_value as OpcodeCondition
		current_token += 1
	}
	target_address := tokens_list[current_token].token_value as u32
	if (target_address & 3) != 0 {
		return error('Target address for B opcode must have lower bits set to 0')
	}
	opcode_name := tokens_list[0].token_value as string
	return BOpcode{
		condition: condition
		l_flag: if opcode_name == 'BL' { true } else { false }
		target_address: target_address >> 2
	}
}

/*
From a 32 bits value generates a value/rotation pair that represents
the value given in the parameter.
Returns a ShiftOperandImmediate struct with the values
*/
fn get_immediate_value(immediate u32) !ShiftOperandImmediate {
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

	return ShiftOperandImmediate{
		value: u8(immediate_value)
		rotate: u8(((32 - shift_counter) / 2) & 0xF)
	}
}
