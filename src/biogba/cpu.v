module biogba

pub struct CPSR {
pub mut:
	c bool
}

pub struct CPUState {
pub mut:
	r [16]u32
	cpsr CPSR
}

pub struct ARM7TDMI {
mut:
	r [16]u32
	cpsr CPSR
}

pub fn (mut self ARM7TDMI) set_state(state CPUState) {
	for i, _ in self.r {
		self.r[i] = state.r[i]
	}
	self.cpsr = state.cpsr
}

pub fn (self ARM7TDMI) get_state() CPUState {
	mut result := CPUState{}
	for i, reg in self.r {
		result.r[i] = reg
	}
	result.cpsr = self.cpsr
	return result
}

pub fn (mut self ARM7TDMI) execute_opcode(opcode u32) {
	rn := (opcode >> 16) & 0xF
	rd := (opcode >> 12) & 0xF
	c_part := if self.cpsr.c {u32(1)} else {u32(0)}
	is_register_shift := ((opcode >> 25) & 1) == 0

	mut operand_value := u32(0)
	if is_register_shift {
		is_register_value := ((opcode >> 4) & 1) == 1
		rm := opcode & 0xF
		if is_register_value {
			value := (opcode >> 8) & 0xF
			operand_value = self.r[rm] << self.r[value]
		} else {
			value := (opcode >> 7) & 0x1F
			operand_value = self.r[rm] << value
		}
	} else {
		rot_part := 2 * ((opcode >> 8) & 0xF)
		operand_value = opcode & 0xFF

		for _ in 0 .. rot_part {
			bit := operand_value & 1
			operand_value >>= 1
			operand_value |= (bit << 31)
		}
	}
	self.r[rd] = self.r[rn] + c_part + operand_value
}