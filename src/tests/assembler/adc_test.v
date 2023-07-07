import biogba

/*
Test assembler with simple adc instruction
*/
fn test_assembler_adc_simple() {
	opcode_string := 'ADC R5, R3, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test assembler adc with a condition set
*/

fn test_assembler_adc_condition() {
	opcode_string := 'ADCNE R5, R3, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.ne
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test assemblder adc with different Rd
*/
fn test_assembler_adc_rd() {
	opcode_string := 'ADCGE R15, R3, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.ge
		rd: 0xf
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test assembler adc with different Rn
*/
fn test_assembler_adc_rn() {
	opcode_string := 'ADC R5, R13, #10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0xd
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test assembler adc with 3rd token as immediate value
*/
fn test_assembler_adc_immediate() {
	opcode_string := 'ADC R5, R3, #EF'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xEF
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test s bit with no condition
*/
fn test_assembler_adc_s_bit() {
	opcode_string := 'ADCS R0, R1, #01'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0x01
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test s bit with condition
*/
fn test_assembler_adc_s_bit_and_condition() {
	opcode_string := 'ADCHIS R0, R1, #01'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.hi
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0x01
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test simple register mode ( LSL expression )
*/
fn test_assembler_adc_register_mode() {
	opcode_string := 'ADCEQS R15, R14, R2, LSL, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.eq
		rd: 15
		rn: 14
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test register mode different Rm
*/
fn test_assembler_adc_register_mode_rm() {
	opcode_string := 'ADC R0, R1, R10, LSL, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 10
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test different shiftName (ASR) (covers LSR)
*/
fn test_assembler_adc_register_mode_asr() {
	opcode_string := 'ADCNES R0, R1, R2, ASR, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.ne
		rd: 0
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test Register Mode with a different expression
Expression has a 5 bits width. 0x1F
*/
fn test_assembler_adc_register_mode_expression() {
	opcode_string := 'ADC R0, R1, R2, LSR, #1F'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x1F
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test RXX shift type. Opcode should be interpreted as ROR 0
*/
fn test_assembler_adc_register_mode_rxx() {
	opcode_string := 'ADC R0, R1, R2, RXX'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test register-register mode.
*/
fn test_assembler_adc_register_mode_register() {
	opcode_string := 'ADC R0, R1, R2, LSL R3'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: true
			shift_type: biogba.ShiftType.lsl
			shift_value: 3
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
The following tests validate how the assembler generates a pair of value/rotation
values when immediate is used.

Not all values in the expression can be represented by this fields, but the algorithm should
be able to handle all valid cases correctly.

The following set of tests will validate the main cases
*/

/*
Test simple whole byte shift. The value fits perfectly into a byte
*/
fn test_assembler_adc_immediate_generation_whole_byte() {
	opcode_string := 'ADC R5, R3, #FF00'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xFF
			rotate: 12
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test simple half byte shift. The value is shifted 4 bits
*/
fn test_assembler_adc_immediate_generation_half_byte() {
	opcode_string := 'ADC R5, R3, #FF0'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xFF
			rotate: 14
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test immediate value with 3 shifted bits.
*/
fn test_assembler_adc_immediate_generation_irregular() {
	opcode_string := 'ADC R5, R3, #2F8'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xBE
			rotate: 15
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test immediate value with 3 shifted bits.
*/
fn test_assembler_adc_immediate_generation_big_value() {
	opcode_string := 'ADC R5, R3, #3740_0000'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xDD
			rotate: 5
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode == expected_opcode
	}
}

// Errors

/*
Test invalid opcode arguments
*/
fn test_assembler_adc_invalid_arguments() {
	biogba.opcode_from_string('ADC R0, R1, R2, R3') or { return }
	assert false
}

/*
Test invalid opcode name
*/
fn test_assembler_adc_invalid_opcode_name() {
	biogba.opcode_from_string('ACC R0, R1, #1') or { return }
	assert false
}

/*
Test invalid register number
*/
fn test_assembler_adc_invalid_register_number() {
	biogba.opcode_from_string('ADC R16, R1, #1') or { return }
	assert false
}

/*
Test invalid immediate value
*/
fn test_assembler_adc_invalid_immediate_value() {
	biogba.opcode_from_string('ADC R0, R1, #SS') or { return }
	assert false
}

/*
Test invalid shiftname
*/
fn test_assembler_adc_invalid_shift_name() {
	biogba.opcode_from_string('ADC R0, R1, R2, LSK, #1') or { return }
	assert false
}

/*
Test invalid extra parameters
*/
fn test_assembler_adc_invalid_extra_parameters() {
	biogba.opcode_from_string('ADC R0, R1, R2, ASR, #1, R2') or { return }
	assert false
}

/*
Test invalid register-immediate mode value
Values are limited to 5 bits (0-31)
*/
fn test_assembler_adc_invalid_register_shift_value() {
	biogba.opcode_from_string('ADC R0, R1, R2, ASR, #20') or { return }
	assert false
}