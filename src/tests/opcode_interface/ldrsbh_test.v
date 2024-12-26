import biogba {
	LDRSBHOpcode,
	OpcodeCondition,
	Register,
}

/*
Bits:    31   28 27   25 24 23 22 21 20 19   16 15   12 11    8 7 6 5 4 3    0
Format: [Cond][0 0 0][P U O W L][  Rn  ][  Rd  ][0 0 0 0][T S H I][  Rm  ]

Campos y significados:

- Rm (bits 0-3): Registro de offset
- S H (bits 4-5): 
    00 = SWP instruction
    01 = Unsigned halfwords
    10 = Signed byte
    11 = Signed halfwords

- T (bit 6): Source/Destination register
- Base register (bits 16-19): Rn
- Load/Store (bit 20):
    0 = store to memory
    1 = load from memory

- Write-back (bit 21):
    0 = no write-back
    1 = write address into base

- Up/Down (bit 23):
    0 = down: subtract offset from base
    1 = up: add offset to base

- Pre/Post indexing (bit 24):
    0 = post: add/subtract offset after transfer
    1 = pre: add/subtract offset before transfer

- Condition field (bits 28-31): Cond
*/

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
