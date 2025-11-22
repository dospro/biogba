import biogba {
	OpcodeCondition,
	STROpcode,
}
// STR Store. Single Data Transfer

/*
Test STR opcode default values

- Immediate mode
- Post index
- Decrement
- No writeback
- Word transfer
- Offset 0x0
- Rn = R0
- Rd = R0
*/
fn test_str_default() {
	opcode := STROpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE400_0000
}

fn test_str_with_condition() {
	opcode := STROpcode{
		condition: OpcodeCondition.ls
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x9400_0000
}

fn test_str_rd() {
	opcode := STROpcode{
		rd: 0x7
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE400_7000
}

fn test_str_rn() {
	opcode := STROpcode{
		rn: 0x3
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE403_0000
}

fn test_str_immediate_address() {
	opcode := STROpcode{
		rd: 0x1
		rn: 0x2
		address: u16(0x123)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE402_1123
}

fn test_str_register_address() {
	opcode := STROpcode{
		rd: 0x4
		rn: 0x5
		address: biogba.RegisterOffset{
			rm:          0x6
			shift_type:  biogba.ShiftType.lsl
			shift_value: 0x2
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE605_4106
}

fn test_str_preindex() {
	opcode := STROpcode{
		rd: 0x2
		rn: 0x3
		p_bit: true
		address: u16(0x45)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE503_2045
}

fn test_str_u_bit() {
	opcode := STROpcode{
		rd: 0x2
		rn: 0x3
		u_bit: true
		address: u16(0x321)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE483_2321
}

fn test_str_b_bit() {
	opcode := STROpcode{
		rd: 0x2
		rn: 0x3
		b_bit: true
		address: u16(0x321)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE443_2321
}

fn test_str_w_bit() {
	opcode := STROpcode{
		rd: 0x2
		rn: 0x3
		w_bit: true
		address: u16(0x321)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE423_2321
}

fn test_str_register_address_ror() {
	opcode := STROpcode{
		rd: 0x2
		rn: 0x3
		address: biogba.RegisterOffset{
			rm:          0x4
			shift_type:  biogba.ShiftType.ror
			shift_value: 0x4
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE603_2264
}