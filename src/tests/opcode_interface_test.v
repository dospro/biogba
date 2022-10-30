import src.biogba

type ADCOpcode = biogba.ADCOpcode
type ADDOpcode = biogba.ADDOpcode
type ANDOpcode = biogba.ANDOpcode
type BOpcode = biogba.BOpcode
type BXOpcode = biogba.BXOpcode

type OpcodeCondition = biogba.OpcodeCondition
type ShiftType = biogba.ShiftType


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

// BIC

fn test_bic_default() {
	opcode := biogba.BICOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE3C0_0000
}

fn test_bix_complex() {
	opcode := biogba.BICOpcode{
		condition: biogba.OpcodeCondition.gt
		rd: 0x7
		rn: 0xC
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0xA
			register_shift: true
			shift_type: ShiftType.lsr
			shift_value: 0xE
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xC1DC_7E3A
}

// BX Branch and Exchange

fn test_bx() {
	opcode := biogba.BXOpcode{
		condition: biogba.OpcodeCondition.ne
		rm: 0x2
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x112F_FF12
}

// CMN Compare negative

fn text_cmn() {
	opcode := biogba.CMNOpcode{
		condition: biogba.OpcodeCondition.lt
		rd: 0x1
		rn: 0x2
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 1
			value: 1
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xB351_2101
}

// CMN Compare negative

fn text_cmp() {
	opcode := biogba.CMPOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0x1
		rn: 0x2
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 1
			value: 1
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE371_2101
}

// EOR Bit wise exclusive OR

fn test_eor_default() {
	opcode := biogba.EOROpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE220_0000
}

fn test_eor() {
	opcode := biogba.EOROpcode{
		condition: biogba.OpcodeCondition.eq
		rd: 0xA
		rn: 0xB
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 2
			value: 2
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x022B_A202
}