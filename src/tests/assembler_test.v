import src.biogba


/*
Test assembler with simple adc instruction
*/
fn test_assembler_adc_simple() {
	opcode_string := 'ADC R5, R3, #0x10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x10
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/* 
Test assembler adc with a condition set
*/

fn test_assemblder_adc_condition() {
	opcode_string := 'ADCNE R5, R3, #0x10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.ne
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x10
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}

}

/*
Test assemblder adc with different Rd
*/
fn test_assembler_adc_rd() {
	opcode_string := 'ADCGE R15, R3, #0x10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.ge
		rd: 0xf
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x10
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}


/*
Test assembler adc with different Rn
*/
fn test_assembler_adc_rn() {
	opcode_string := 'ADC R5, R13, #0x10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0xd
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x10
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/*
Test assembler adc with 3rd token as immediate value
*/
fn test_assembler_adc_immediate() {
	opcode_string := 'ADC R5, R3, #0xEF'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.al
		rd: 0x5
		rn: 0x3
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0xEF
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/* 
Test s bit with no condition
*/
fn test_assembler_adc_s_bit() {
	opcode_string := 'ADCS R0, R1, #0x01'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.al
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x01
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/*
Test s bit with condition
*/
fn test_assembler_adc_s_bit_and_condition() {
	opcode_string := 'ADCHIS R0, R1, #0x01'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.hi
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x01
			rotate: 0
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/*
Test simple register mode ( LSL expression )
*/
fn test_assembler_adc_register_mode() {
	opcode_string := 'ADCEQS R15, R14, R2, LSL, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.eq
		rd: 15
		rn: 14
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/*
Test register mode different Rm
*/
fn test_assembler_adc_register_mode_rm() {
	opcode_string := 'ADC R0, R1, R10, LSL, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister {
			rm: 10
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

/*
Test different shiftName (ASR) (covers LSR)
*/
fn test_assembler_adc_register_mode_asr() {
	opcode_string := 'ADCNES R0, R1, R2, ASR, #1'

	opcode := biogba.opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.ADCOpcode {
		condition: biogba.OpcodeCondition.ne
		rd: 0
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 1
		}
	}

	assert opcode is biogba.ADCOpcode
	if opcode is biogba.ADCOpcode {
		assert opcode  == expected_opcode
	}
}

// Test RXX
// Test register-register mode

// Errors
// Test bad expression in immediate
// Test bad register?
// Test mal formed opcode
// Register-register expression can only take values 0-31
