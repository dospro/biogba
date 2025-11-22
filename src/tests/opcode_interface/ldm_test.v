import biogba {
	LDMOpcode,
	OpcodeCondition,
}
// LDM Load Multiple. Block Data Transfer

fn test_ldm_default() {
	opcode := LDMOpcode{
		condition: OpcodeCondition.al
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
	opcode := LDMOpcode{
		condition: OpcodeCondition.eq
		rn: 14
		p_bit: true
		u_bit: true
		w_bit: true
		register_list: [.r0, .r2, .r3, .r15]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x09BE_800D
}

fn test_ldm_with_s_bit() {
	opcode := LDMOpcode{
		condition: OpcodeCondition.ne
		rn: 5
		p_bit: true
		u_bit: false
		w_bit: false
		s_bit: true
		register_list: [.r4, .r6, .r8]
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x19550150
}
