import biogba {
	LDRSBHOpcode,
	OpcodeCondition,
	Register,
}

/*
LDRSBH is not an actual opcode. I used this name to represent the following opcodes:
* LDRH - Load Unsigned Haldfword
* LDRSH - Load Signed Halfword
* LDRSB - Load Signed Byte
Notes: There is already a LDRB opcode which is represented by the LDROpcode struct

The assembler will read the right opcode names and translate them into the correct
struct.
*/

/*
Test LDRH Opcode interface with default values

Configuration:
preindex increment unsigned halfword immediate no writeback
*/
fn test_ldrh_default() {
	opcode := LDRSBHOpcode{
		rn: 0xF
		rd: 0x5
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE1DF_5ABB
}

/*
Test LDRH Opcode interface with Rn value

Configuration:
preindex increment unsigned halfword immediate no writeback
*/
fn test_ldrh_condition() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.ne
		rn: 0xF
		rd: 0x5
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x11DF_5ABB
}

/*
Test LDRH Opcode interface with Rn value
*/
fn test_ldrh_rn() {
	opcode := LDRSBHOpcode{
		rn: 0x1
		rd: 0x5
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE1D1_5ABB
}

/*
Test LDRH Opcode interface with Rd value
*/
fn test_ldrh_rd() {
	opcode := LDRSBHOpcode{
		rn: 0x1
		rd: 0xE
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE1D1_EABB
}

/*
Test LDRH Opcode interface with post-index
*/
fn test_ldrh_p_bit() {
	opcode := LDRSBHOpcode{
		rn: 0xE
		rd: 0xF
		p_bit: false
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE0DE_FABB
}

/*
Test LDRH Opcode interface decrement bit
*/
fn test_ldrh_u_bit() {
	opcode := LDRSBHOpcode{
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: false
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE15E_FABB
}

/*
Test LDRH Opcode interface writeback bit
*/
fn test_ldrh_w_bit() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.eq
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: true
		w_bit: true
		s_bit: false
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x01FE_FABB
}

/*
Test LDRSH Opcode interface with s bit set
*/
fn test_ldrsh_s_bit() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.eq
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: true
		h_bit: true
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x01DE_FAFB
}

/*
Test LDRSB Opcode interface with s bit and h bit unset
*/
fn test_ldrsb_h_bit() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.eq
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: true
		h_bit: false
		address: u8(0xAB)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x01DE_FADB
}

/*
Test LDRH Opcode interface with immediate offset
*/
fn test_ldrh_immediate() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.eq
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0x11)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x01DE_F1B1
}

/*
Test LDRH Opcode interface with register offset
*/
fn test_ldrh_register() {
	opcode := LDRSBHOpcode{
		condition: OpcodeCondition.eq
		rn: 0xE
		rd: 0xF
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: Register.r2
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x019E_F0B2
}
