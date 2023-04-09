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

fn test_cmn() {
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
	assert hex_value == 0xB372_1101
}

// CMP Compare negative

fn test_cmp() {
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
	assert hex_value == 0xE352_1101
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

// LDM Load Multiple. Block Data Transfer
fn test_ldm_default() {
	opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 0x1
		p_bit: false
		u_bit: true
		w_bit: false
		register_list: [.r0]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE891_0001
}

fn test_ldm() {
	opcode := biogba.LDMOpcode{
		condition: biogba.OpcodeCondition.eq
		rn: 14
		p_bit: true
		u_bit: true
		w_bit: true
		register_list: [.r0, .r2, .r3, .r15]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x09BE_800D
}

// LDR Load Register
fn test_ldr_immediate_simple() {
	opcode := biogba.LDROpcode{		
		rn: 0xF
		rd: 0x5
		p_bit: false
		u_bit: false
		w_bit: false
		address: u16(0x123)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE40F_5123
}

fn test_ldr_immediate_flags() {
	opcode := biogba.LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: u16(0x321)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1521_2321
}

fn test_ldr_register_address_lsl() {
	opcode := biogba.LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: biogba.RegisterOffset{
			rm: 0x3
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x11
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1721_2883
}

fn test_ldr_register_address_lsr() {
	opcode := biogba.LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: biogba.RegisterOffset{
			rm: 0x3
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x11
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1721_28A3
}

fn test_ldr_byte() {
	opcode := biogba.LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: true
		b_bit: true
		w_bit: false
		address: u16(0x11)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x15C1_2011
}
