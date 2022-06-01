module biogba

pub enum OpcodeCondition {
	eq
	ne
	cs
	cc
	mi
	pl
	vs
	vc
	hi
	ls
	ge
	lt
	gt
	le
	al
}

pub struct ADCOpcode {
	condition OpcodeCondition = OpcodeCondition.al
}

pub fn (opcode ADCOpcode) as_hex() u32 {
	condition_part := (u32(opcode.condition) & 0xF) << 28
	return condition_part | 0x00A0_0000
}