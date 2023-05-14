import src.biogba


/*
Test assembler with simple adc instruction
*/
fn test_assembler_adc_simple() {
	opcode_string := 'ADC R5, R3, #0x10'

	opcode := biogba.opcode_from_string(opcode_string) or { panic("Error") }
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

	opcode := biogba.opcode_from_string(opcode_string) or { panic("Error") }
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

	opcode := biogba.opcode_from_string(opcode_string) or { panic("Error") }
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

	opcode := biogba.opcode_from_string(opcode_string) or { panic("Error") }
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
Test assembler adc with 3rd token is immediate
*/
fn test_assembler_adc_immediate() {
	opcode_string := 'ADC R5, R3, #0xEF'

	opcode := biogba.opcode_from_string(opcode_string) or { panic("Error") }
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