module biogba

pub struct CPUState {
pub mut:
	r [16]u32
	c_flag bool
}

pub struct ARM7TDMI {
mut:
	r [16]u32
}

pub fn (self ARM7TDMI) set_state(state CPUState) {
	
}

pub fn (self ARM7TDMI) get_state() CPUState {
	mut result := CPUState{}
	for i, reg in self.r {
		result.r[i] = reg
	}
	return result
}

pub fn (mut self ARM7TDMI) execute_opcode(opcode u32) {
	self.r[0xE] = 0x3030_7070
}