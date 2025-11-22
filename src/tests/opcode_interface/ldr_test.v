import biogba {
	LDROpcode,
	OpcodeCondition,
	RegisterOffset,
	ShiftType,
}

// LDR Load Register
fn test_ldr_immediate_simple() {
	opcode := LDROpcode{
		rn: 0xF
		rd: 0x5
		p_bit: false
		u_bit: false
		w_bit: false
		address: u16(0x123)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE41F_5123
}

fn test_ldr_immediate_flags() {
	opcode := LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: u16(0x321)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1531_2321
}

fn test_ldr_register_address_lsl() {
	opcode := LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: RegisterOffset{
			rm: 0x3
			shift_type: ShiftType.lsl
			shift_value: 0x11
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1731_2883
}

fn test_ldr_register_address_lsr() {
	opcode := LDROpcode{
		condition: OpcodeCondition.ne
		rn: 0x1
		rd: 0x2
		p_bit: true
		u_bit: false
		w_bit: true
		address: RegisterOffset{
			rm: 0x3
			shift_type: ShiftType.lsr
			shift_value: 0x11
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1731_28A3
}

fn test_ldr_byte() {
	opcode := LDROpcode{
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
	assert hex_value == 0x15D1_2011
}
