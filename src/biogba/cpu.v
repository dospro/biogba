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

	operand_value := self.get_shift_operand_value(opcode)
	self.r[rd] = self.r[rn] + c_part + operand_value
}

fn (mut self ARM7TDMI) get_shift_operand_value(opcode u32) u32 {
	is_register_shift := ((opcode >> 25) & 1) == 0
	s_bit := ((opcode >> 20) & 1) != 0
	mut operand_value := u32(0)
	mut c_bit := self.cpsr.c
	if is_register_shift {
		shift_type := (opcode >> 5) & 3
		is_register_value := ((opcode >> 4) & 1) == 1
		shift_value := if is_register_value {self.r[(opcode >> 8) & 0xF]} else {(opcode >> 7) & 0x1F}
		rm := opcode & 0xF

		operand_value = match shift_type {
			0 {
				mut result := self.r[rm]
				for _ in 0 .. shift_value {
					c_bit = (result & 0x8000_0000) != 0
					result <<= 1
				}
				result
				}
			1 {
				mut result := self.r[rm]
				for _ in 0 .. shift_value {
					c_bit = (result & 1) != 0
					result >>= 1
				}
				result
			}
			2 {
				mut result := self.r[rm]
				bit := result & 0x8000_0000
				for _ in 0 .. shift_value {
					c_bit = (result & 1) != 0
					result >>= 1
					result |= bit
				}
				result
			}
			3 {
				mut result := self.r[rm]
				for _ in 0 .. shift_value {
					c_bit = (result & 1) != 0
					bit := (result & 1) << 31
					result >>= 1
					result |= bit
				}
				result
			}
			else {0}
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

	if s_bit {
		self.cpsr.c = c_bit
	}
	return operand_value
}