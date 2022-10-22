import src.biogba

type ADCOpcode = biogba.ADCOpcode
type ADDOpcode = biogba.ADDOpcode
type ANDOpcode = biogba.ANDOpcode
type BOpcode = biogba.BOpcode

type OpcodeCondition = biogba.OpcodeCondition
type ShiftType = biogba.ShiftType

// type ShiftOperand = biogba.ShiftOperand
// type ShiftOperandImmediate = biogba.ShiftOperandImmediate
// type ShiftOperandRegister = biogba.ShiftOperandRegister

fn test_adc_opcode_default() {
	opcode := ADCOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2A0_0000
}

fn test_adc_eq_condition() {
	opcode := ADCOpcode{
		condition: OpcodeCondition.eq
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x02A0_0000
}

fn test_adc_ne_condition() {
	opcode := ADCOpcode{
		condition: OpcodeCondition.ne
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x12A0_0000
}

fn test_adc_set_rn() {
	opcode := ADCOpcode{
		rn: 0xF
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2AF_0000
}

fn test_adc_set_rd() {
	opcode := ADCOpcode{
		rd: 0xF
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2A0_F000
}

fn test_adc_set_s_bit() {
	opcode := ADCOpcode{
		s_bit: true
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2B0_0000
}

fn test_adc_operand_immediate() {
	opcode := ADCOpcode{
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xFF
			rotate: 0x2
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE2A0_02FF
}

fn test_adc_operand_register() {
	opcode := ADCOpcode{
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0xE
			register_shift: false
			shift_type: ShiftType.lsl
			shift_value: 0x1F
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0A0_0F8E
}

fn test_adc_operand_register_register() {
	opcode := ADCOpcode{
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0xE
			register_shift: true
			shift_type: ShiftType.lsl
			shift_value: 0xF
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0A0_0F1E
}

fn test_adc_operand_register_immediate_lsr() {
	opcode := ADCOpcode{
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0xE
			register_shift: false
			shift_type: ShiftType.lsr
			shift_value: 0x1F
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0A0_0FAE
}

fn test_adc_operand_register_register_lsr() {
	opcode := ADCOpcode{
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0xE
			register_shift: true
			shift_type: ShiftType.lsr
			shift_value: 0xF
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0A0_0F3E
}

// ADD

fn test_add_default() {
	opcode := ADDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE280_0000
}

fn test_and_default() {
	opcode := ANDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE200_0000
}

// B, BL

fn test_b() {
	opcode := BOpcode{
		target_address: 0xFF_FFFF
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xEAFF_FFFF
}

fn test_bl() {
	opcode := BOpcode{
		l_flag: true
		target_address: 0x80_0000
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xEB80_0000
}
