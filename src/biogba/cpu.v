module biogba

pub struct CPSR {
pub mut:
	c bool
	v bool
	z bool
	n bool

	t bool
}

pub struct CPUState {
pub mut:
	r    [16]u32
	cpsr CPSR
}

pub struct ARM7TDMI {
mut:
	r    [16]u32
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
	// Conditional
	condition := opcode_condition_from_value(opcode >> 28) or { panic(err) }
	if !self.should_execute(condition) {
		return
	}

	// Get higher 2 bits after condition
	opcode_high_bits := (opcode >> 26) & 3
	c_part := if self.cpsr.c { u32(1) } else { u32(0) }
	match opcode_high_bits {
		0 {
			if (opcode & 0x0FFF_FFF0) == 0x12F_FF10 { // BX
				rm := opcode & 0xF
				if (self.r[rm] & 1) != 0 {
					self.cpsr.t = true
				}
				self.r[15] = self.r[rm] & 0xFFFF_FFFE
			} else {
				data_processing_opcode := (opcode >> 21) & 0xF
				rn := (opcode >> 16) & 0xF
				rd := (opcode >> 12) & 0xF
				operand_value := self.get_shift_operand_value(opcode)
				result := match data_processing_opcode {
					0 { // AND
						self.r[rd] = self.r[rn] & operand_value
						self.r[rd]
					}
					4 { // ADD
						self.r[rd] = self.r[rn] + operand_value
						self.r[rd]
					}
					5 { // ADC
						self.r[rd] = self.r[rn] + c_part + operand_value
						self.r[rd]
					}
					0xA { // CMP
						self.r[rn] - operand_value
					}
					0xB { // CMN
						self.r[rn] + operand_value
					}
					0xE { // BIC
						self.r[rd] = self.r[rn] & ~operand_value
						self.r[rd]
					}
					else {0}
				}
				self.cpsr.v = ((self.r[rn] ^ operand_value ^ result) & 0x8000_0000) != 0
				self.cpsr.z = result == 0
				self.cpsr.n = (result & 0x8000_0000) != 0
			}
		}
		1 {}
		2 {
			// B BL
			if ((opcode >> 25) & 0xF) == 5 {
				mut target_address := (opcode & 0xFF_FFFF) << 2
				l_flag := ((opcode >> 24) & 1) != 0
				if (target_address & 0x200_0000) != 0 {
					target_address |= 0xFC00_0000
				}
				if l_flag {
					self.r[14] = self.r[15] + 4
				}
				self.r[15] += target_address
			}
		}
		3 {}
		else {}
	}
}

/*
Evaluate condition. Opcode should execute if the result is true
*/
fn (self ARM7TDMI) should_execute(condition OpcodeCondition) bool {
	match true {
		condition == .eq && !self.cpsr.z, condition == .ne && self.cpsr.z,
		condition == .cs && !self.cpsr.c, condition == .cc && self.cpsr.c,
		condition == .mi && !self.cpsr.n, condition == .pl && self.cpsr.n,
		condition == .vs && !self.cpsr.v, condition == .vc && self.cpsr.v,
		condition == .hi && !self.cpsr.c && self.cpsr.z,
		condition == .ls && !(!self.cpsr.c || self.cpsr.z),
		condition == .ge && self.cpsr.n != self.cpsr.v,
		condition == .lt && self.cpsr.n == self.cpsr.v,
		condition == .gt && !(!self.cpsr.z && self.cpsr.n == self.cpsr.v),
		condition == .le && !(self.cpsr.z || self.cpsr.n != self.cpsr.v) {
			return false
		}
		else {
			return true
		}
	}
}

fn (mut self ARM7TDMI) get_shift_operand_value(opcode u32) u32 {
	is_register_shift := ((opcode >> 25) & 1) == 0
	s_bit := ((opcode >> 20) & 1) != 0
	mut operand_value := u32(0)
	mut c_bit := self.cpsr.c
	if is_register_shift {
		shift_type := shift_type_from_value((opcode >> 5) & 3) or { panic('') }
		is_register_value := ((opcode >> 4) & 1) == 1
		shift_value := if is_register_value {
			self.r[(opcode >> 8) & 0xF]
		} else {
			(opcode >> 7) & 0x1F
		}
		rm := opcode & 0xF
		mut result := self.r[rm]

		operand_value = match shift_type {
			.lsl {
				for _ in 0 .. shift_value {
					c_bit = (result & 0x8000_0000) != 0
					result <<= 1
				}
				result
			}
			.lsr {
				final_shift_value := if shift_value == 0 { 32 } else { shift_value }
				for _ in 0 .. final_shift_value {
					c_bit = (result & 1) != 0
					result >>= 1
				}
				result
			}
			.asr {
				final_shift_value := if shift_value == 0 { 32 } else { shift_value }
				bit := result & 0x8000_0000
				for _ in 0 .. final_shift_value {
					c_bit = (result & 1) != 0
					result >>= 1
					result |= bit
				}
				result
			}
			.ror {
				if shift_value == 0 {
					bit := result & 1
					result >>= 1
					c_flag_bit := if c_bit { u32(1) } else { u32(0) }
					result |= c_flag_bit << 31
					c_bit = bit != 0
				} else {
					for _ in 0 .. shift_value {
						c_bit = (result & 1) != 0
						bit := (result & 1) << 31
						result >>= 1
						result |= bit
					}
				}
				result
			}
		}
	} else {
		rot_part := 2 * ((opcode >> 8) & 0xF)
		operand_value = opcode & 0xFF

		for _ in 0 .. rot_part {
			bit := operand_value & 1
			c_bit = bit != 0
			operand_value >>= 1
			operand_value |= (bit << 31)
		}
	}

	if s_bit {
		self.cpsr.c = c_bit
	}
	return operand_value
}
