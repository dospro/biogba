import biogba {
	OpcodeCondition,
	STMOpcode,
}
// STM Store Multiple. Block Data Transfer

/*
Test STM opcode default interface
Defaults are
- Rn 0
- postindex
- increment
- no writeback
There is no default register list, so R1 is used
*/
fn test_stm_default() {
	opcode := STMOpcode{
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE880_0002
}

/*
Test STM opcode with condition
*/
fn test_stm_condition() {
	opcode := STMOpcode{
		condition:     OpcodeCondition.ne
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x1880_0002
}

/*
Test STM opcode with different Rn
*/
fn test_stm_rn() {
	opcode := STMOpcode{
		rn:            5
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE885_0002
}

/*
Test STM opcode with preindex
*/
fn test_stm_preindex() {
	opcode := STMOpcode{
		p_bit:         true
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE980_0002
}

/*
Test STM opcode with decrement
*/
fn test_stm_decrement() {
	opcode := STMOpcode{
		u_bit:         false
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE800_0002
}

/*
Test STM opcode with writeback
*/
fn test_stm_writeback() {
	opcode := STMOpcode{
		w_bit:         true
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE8A0_0002
}

/*
Test STM opcode with register list
*/
fn test_stm_register_list() {
	opcode := STMOpcode{
		register_list: [.r3, .r5, .r8, .r13]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE880_2128
}

/*
Test STM opcode with s bit
*/
fn test_stm_s_bit() {
	opcode := STMOpcode{
		s_bit: true
		register_list: [.r1]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE8C0_0002
}