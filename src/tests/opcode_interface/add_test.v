import biogba {
	ADDOpcode,
	OpcodeCondition,
	ShiftOperandImmediate,
	ShiftOperandRegister,
	ShiftType,
}

fn test_add_default() {
	opcode := ADDOpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE280_0000
}

fn test_add_shift_operand_immediate() {
	opcode := ADDOpcode{
		condition: OpcodeCondition.cc
		rd: 9
		rn: 10
		shift_operand: ShiftOperandImmediate {
			value: 0xFF
			rotate: 2
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x328A_92FF
}

fn test_add_shift_operand_register() {
	opcode := ADDOpcode{
		condition: OpcodeCondition.eq
		rd: 8
		rn: 7
		shift_operand: ShiftOperandRegister{
			rm: 6
			register_shift: false
			shift_type: ShiftType.lsl
			shift_value: 1
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x0087_8086
}
