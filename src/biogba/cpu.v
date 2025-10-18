module biogba

import math.bits { rotate_left_32 }

pub enum CPUMode {
	user       = 0b10000
	fiq        = 0b10001
	irq        = 0b10010
	supervisor = 0b10011
	abort      = 0b10111
	undefined  = 0b11011
	system     = 0b11111
}

// Processor Satus Register
pub struct PSR {
pub mut:
	c bool // carry/overflow flag
	v bool // overflow flag
	z bool // zero flag
	n bool // negative flag

	i bool // IRQ disabled flag
	f bool // FIQ disabled flag
	t bool // Thumb mode flag

	mode CPUMode = .user
}

pub fn (psr PSR) to_hex() u32 {
	n_part := if psr.n { u32(0x8000_0000) } else { u32(0) }
	z_part := if psr.z { u32(0x4000_0000) } else { u32(0) }
	c_part := if psr.c { u32(0x2000_0000) } else { u32(0) }
	v_part := if psr.v { u32(0x1000_0000) } else { u32(0) }

	i_part := if psr.i { u32(0x80) } else { u32(0) }
	f_part := if psr.f { u32(0x40) } else { u32(0) }
	t_part := if psr.t { u32(0x20) } else { u32(0) }
	mode_part := u32(psr.mode)
	return n_part | z_part | c_part | v_part | i_part | f_part | t_part | mode_part
}

pub fn (mut psr PSR) from_value(value u32) {
	psr.n = (value & 0x8000_0000) != 0
	psr.z = (value & 0x4000_0000) != 0
	psr.c = (value & 0x2000_0000) != 0
	psr.v = (value & 0x1000_0000) != 0

	psr.i = (value & 0x80) != 0
	psr.f = (value & 0x40) != 0
	psr.t = (value & 0x20) != 0

	psr.mode = match value & 0x1F {
		0b10000 { .user }
		0b10001 { .fiq }
		0b10010 { .irq }
		0b10011 { .supervisor }
		0b10111 { .abort }
		0b11011 { .undefined }
		0b11111 { .system }
		else { panic('Undefined PSR mode ${value.hex()}') }
	}
}

pub struct CPUState {
pub mut:
	r               [16]u32
	r_fiq			[16]u32
	cpsr            PSR
	spsr_fiq        PSR
	spsr_irq        PSR
	spsr_supervisor PSR
	spsr_abort      PSR
	spsr_undefined  PSR
	spsr_system     PSR
}

pub struct ARM7TDMI {
mut:
	r               [16]u32
	r_fiq			[16]u32
	cpsr            PSR
	spsr_fiq        PSR
	spsr_irq        PSR
	spsr_supervisor PSR
	spsr_abort      PSR
	spsr_undefined  PSR
	spsr_system     PSR
pub mut:
	memory MemoryInterface
}

pub fn (mut self ARM7TDMI) set_state(state CPUState) {
	for i, _ in self.r {
		self.r[i] = state.r[i]
	}
	for i, _ in self.r_fiq {
		self.r_fiq[i] = state.r_fiq[i]
	}
	self.cpsr = state.cpsr
	self.spsr_fiq = state.spsr_fiq
	self.spsr_irq = state.spsr_irq
	self.spsr_supervisor = state.spsr_supervisor
	self.spsr_abort = state.spsr_abort
	self.spsr_undefined = state.spsr_undefined
	self.spsr_system = state.spsr_system
}

pub fn (self ARM7TDMI) get_state() CPUState {
	mut result := CPUState{}
	for i, reg in self.r {
		result.r[i] = reg
	}
	for i, reg in self.r_fiq {
		result.r_fiq[i] = reg
	}
	result.cpsr = self.cpsr
	result.spsr_fiq = self.spsr_fiq
	result.spsr_irq = self.spsr_irq
	result.spsr_supervisor = self.spsr_supervisor
	result.spsr_abort = self.spsr_abort
	result.spsr_undefined = self.spsr_undefined
	result.spsr_system = self.spsr_system
	return result
}

pub fn (self ARM7TDMI) get_current_spsr() PSR {
	return match self.cpsr.mode {
		.fiq { self.spsr_fiq }
		.irq { self.spsr_irq }
		.supervisor { self.spsr_supervisor }
		.abort { self.spsr_abort }
		.undefined { self.spsr_undefined }
		.system { self.spsr_system }
		else { panic('Loading SPSR from user mode or wrong mode') }
	}
}

pub fn (mut self ARM7TDMI) set_current_spsr(value u32) {
	match self.cpsr.mode {
		.fiq { self.spsr_fiq.from_value(value) }
		.irq { self.spsr_irq.from_value(value) }
		.supervisor { self.spsr_supervisor.from_value(value) }
		.abort { self.spsr_abort.from_value(value) }
		.undefined { self.spsr_undefined.from_value(value) }
		.system { self.spsr_system.from_value(value) }
		else { panic('Writing to an unkown PSR') }
	}
}

pub fn (mut self ARM7TDMI) execute_opcode(opcode u32) {
	// Conditional
	condition := OpcodeCondition.from_u32(opcode >> 28) or { panic(err) }
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
			} else if (opcode & 0x0F80_00F0) == 0x80_0090 { // MULL
				rdhi := (opcode >> 16) & 0xF
				rdlo := (opcode >> 12) & 0xF
				rs := (opcode >> 8) & 0xF
				rm := opcode & 0xF
				is_signed := ((opcode >> 22) & 1) == 1
				accumulate := ((opcode >> 21) & 1) == 1
				s_bit := ((opcode >> 20) & 1) == 1
				product := if is_signed {
					u64(i64(int(self.r[rs])) * i64(int(self.r[rm])))
				} else {
					u64(self.r[rs]) * u64(self.r[rm])
				}
				final_sum := if accumulate {
					((u64(self.r[rdhi]) << 32) | u64(self.r[rdlo])) + product
				} else {
					product
				}
				if s_bit {
					self.cpsr.z = final_sum == 0
					self.cpsr.n = (final_sum >> 63) == 1
				}
				self.r[rdhi] = u32(final_sum >> 32)
				self.r[rdlo] = u32(final_sum & 0xFFFF_FFFF)
			} else if (opcode & 0x0FC0_0090) == 0x90 { // MUL
				rd := (opcode >> 16) & 0xF
				rn := (opcode >> 12) & 0xF
				rs := (opcode >> 8) & 0xF
				rm := opcode & 0xF
				is_mla := ((opcode >> 21) & 1) == 1
				s_bit := ((opcode >> 20) & 1) == 1
				self.r[rd] = if is_mla {
					self.r[rn] + self.r[rs] * self.r[rm]
				} else {
					self.r[rs] * self.r[rm]
				}
				if s_bit {
					self.cpsr.n = false
					self.cpsr.z = false
					if (self.r[rd] & 0x8000_0000) != 0 {
						self.cpsr.n = true
					}
					if self.r[rd] == 0 {
						self.cpsr.z = true
					}
				}
			} else if (opcode & 0xE00_0090) == 0x90 { // LDRSBH
				rd := (opcode >> 12) & 0xF
				rn := (opcode >> 16) & 0xF
				u_bit := (opcode >> 23) & 1
				is_immediate := ((opcode >> 22) & 1) == 1
				is_preindex := ((opcode >> 24) & 1) == 1
				writeback := ((opcode >> 21) & 1) == 1
				is_signed := ((opcode >> 6) & 1) == 1
				is_halfword := ((opcode >> 5) & 1) == 1
				offset := match is_immediate {
					true { u32(((opcode >> 4) & 0xF0) | (opcode & 0xF)) }
					false { self.r[opcode & 0xF] }
				}
				address := match u_bit {
					0 { self.r[rn] - offset }
					1 { self.r[rn] + offset }
					else { panic('u_bit is not binary!') }
				}
				// println('R${rn}: ${self.r[rn].hex()}, Offset: ${offset.hex()}')
				value := match is_preindex {
					true {
						if writeback {
							self.r[rn] = address
						}
						self.memory.read16(address) // First add base + offset and then read
					}
					false {
						result := self.memory.read16(self.r[rn]) // First read from base and then add offset
						self.r[rn] = address
						result
					}
				}
				mask := if is_halfword { u32(0xFFFF_0000) } else { u32(0xFFFF_FF00) }
				check_bit := if is_halfword { u32(0x8000) } else { u32(0x80) }
				self.r[rd] = if is_signed && (value & check_bit) != 0 {
					mask | u32(value)
				} else {
					u32(value)
				}
			} else if (opcode & 0x1B0_F000) == 0x120_F000 { // MSR
				is_immediate := ((opcode >> 25) & 1) == 1
				p_bit := ((opcode >> 22) & 1) == 1
				f_mask := ((opcode >> 19) & 1) == 1
				c_mask := ((opcode >> 16) & 1) == 1
				mut value := match is_immediate {
					true {
						rot_part := 2 * ((opcode >> 8) & 0xF)
						mut operand_value := opcode & 0xFF

						for _ in 0 .. rot_part {
							bit := operand_value & 1
							operand_value >>= 1
							operand_value |= (bit << 31)
						}
						operand_value
					}
					false {
						rm := opcode & 0xF
						self.r[rm]
					}
				}

				if p_bit {
					mut current_psr_value := self.get_current_spsr().to_hex()
					if c_mask && self.cpsr.mode != .user {
						current_psr_value = (current_psr_value & 0xFFFF_FF00) | (value & 0xFF)
					}
					if f_mask {
						current_psr_value = (current_psr_value & 0x0FFF_FFFF) | (value & 0xF000_0000)
					}
					self.set_current_spsr(current_psr_value)
				} else {
					mut current_psr_value := self.cpsr.to_hex()
					if c_mask && self.cpsr.mode != .user {
						current_psr_value = (current_psr_value & 0xFFFF_FF00) | (value & 0xFF)
					}
					if f_mask {
						current_psr_value = (current_psr_value & 0x0FFF_FFFF) | (value & 0xF000_0000)
					}
					self.cpsr.from_value(current_psr_value)
				}
			} else if (opcode & 0x1BF_0FFF) == 0x010F_0000 { // MRS
				p_bit := (opcode >> 22) & 1
				value := match p_bit {
					0 { self.cpsr.to_hex() }
					1 { self.get_current_spsr().to_hex() }
					else { panic('p_bit is not binary!') }
				}

				rd := (opcode >> 12) & 0xF
				self.r[rd] = value
			} else {
				data_processing_opcode := (opcode >> 21) & 0xF
				rn := (opcode >> 16) & 0xF
				rd := (opcode >> 12) & 0xF
				operand_value := self.get_shift_operand_value(opcode)
				s_bit := ((opcode >> 20) & 1) == 1
				result := match data_processing_opcode {
					0 { // AND
						self.r[rd] = self.r[rn] & operand_value
						self.r[rd]
					}
					1 { // EOR
						self.r[rd] = self.r[rn] ^ operand_value
						self.r[rd]
					}
					3 { // RSB
						self.r[rd] = operand_value - self.r[rn]
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
					6 { // SBC
						self.r[rd] = self.r[rn] - operand_value + c_part - 1
						self.r[rd]
					}
					7 { // RSC
						self.r[rd] = operand_value - self.r[rn] + c_part - 1
						self.r[rd]
					}
					0xA { // CMP
						self.r[rn] - operand_value
					}
					0xB { // CMN
						self.r[rn] + operand_value
					}
					0xC { // ORR
						self.r[rd] = self.r[rn] | operand_value
						self.r[rd]
					}
					0xD { // MOV
						self.r[rd] = operand_value
						operand_value
					}
					0xE { // BIC
						self.r[rd] = self.r[rn] & ~operand_value
						self.r[rd]
					}
					0xF { // MVN
						self.r[rd] = operand_value ^ 0xFFFF_FFFF
						operand_value ^ 0xFFFF_FFFF
					}
					else {
						0
					}
				}
				if s_bit {
					if rd == 15 {
						self.cpsr = self.get_current_spsr()
					} else {
						self.cpsr.v = ((self.r[rn] ^ operand_value ^ result) & 0x8000_0000) != 0
						self.cpsr.z = result == 0
						self.cpsr.n = (result & 0x8000_0000) != 0
					}
				}
			}
		}
		1 {
			// LDR
			self.ldr_opcode(opcode)
		}
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
			} else if (opcode & 0xE10_0000) == 0x810_0000 { // LDM
				self.ldm_opcode(opcode)
			} else if (opcode & 0xE10_0000) == 0x800_0000 { // STM
				rn := (opcode >> 16) & 0xF
				p_flag := (opcode & 0x100_0000) != 0
				u_flag := (opcode & 0x80_0000) != 0
				s_flag := (opcode & 0x40_0000) != 0
				w_flag := (opcode & 0x20_0000) != 0
				mut offset := self.r[rn]
				mut rn_offset := u32(0)
				mut replace_rn_value := false
				// println('Offset ${offset}')
				if u_flag {
					for i in 0 .. 16 {
						if (opcode & (1 << i)) != 0 {
							// println('Writing register R${i} with value ${self.r[i]} at ${offset}')
							// println('Rn = ${rn} and i=${i}. Offset=${offset} Rn value=${self.r[rn]}')
							if rn == i && offset != self.r[rn] {
								rn_offset = offset
								replace_rn_value = true
							}
							if p_flag {
								offset += 4
								self.memory.write32(offset, self.r[i])
							} else {
								if self.cpsr.mode != .user && !s_flag {
									self.memory.write32(offset, self.r_fiq[i])
								} else {
									self.memory.write32(offset, self.r[i])
								}
								offset += 4
							}
						}
					}
				} else {
					for i := 15; i >= 0; i -= 1 {
						if (opcode & (1 << i)) != 0 {
							if p_flag {
								offset -= 4
								self.memory.write32(offset, self.r[i])
							} else {
								self.memory.write32(offset, self.r[i])
								offset -= 4
							}
						}
					}
				}
				if w_flag {
					self.r[rn] = offset
					if replace_rn_value {
						self.memory.write32(rn_offset, self.r[rn])
					}
				}
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
		condition == .cs
			&& !self.cpsr.c, condition == .cc && self.cpsr.c,
		condition == .mi
			&& !self.cpsr.n, condition == .pl && self.cpsr.n,
		condition == .vs
			&& !self.cpsr.v, condition == .vc && self.cpsr.v,
		condition == .hi
			&& !self.cpsr.c && self.cpsr.z,
		condition == .ls && !(!self.cpsr.c
			|| self.cpsr.z),
		condition == .ge
			&& self.cpsr.n != self.cpsr.v,
		condition == .lt
			&& self.cpsr.n == self.cpsr.v,
		condition == .gt && !(!self.cpsr.z
			&& self.cpsr.n == self.cpsr.v),
		condition == .le
			&& !(self.cpsr.z || self.cpsr.n != self.cpsr.v) {
			return false
		}
		else {
			return true
		}
	}
}

pub fn (mut self ARM7TDMI) get_shift_operand_value(opcode u32) u32 {
	is_register_shift := ((opcode >> 25) & 1) == 0
	s_bit := ((opcode >> 20) & 1) != 0
	mut operand_value := u32(0)
	mut c_bit := self.cpsr.c
	if is_register_shift {
		shift_type := ShiftType.from_u32((opcode >> 5) & 3) or { panic('') }
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

fn (mut self ARM7TDMI) ldm_opcode(opcode u32) {
	rn := (opcode >> 16) & 0xF
	u_flag := (opcode & 0x80_0000) != 0
	p_flag := (opcode & 0x100_0000) != 0
	w_flag := (opcode & 0x20_0000) != 0

	// If u_flag is set then we increment, otherwise decrement
	delta := if u_flag { u32(4) } else { u32(-4) }

	mut offset := self.r[rn]
	if u_flag {
		for i in 0 .. 16 {
			if (opcode & (1 << i)) != 0 {
				if p_flag {
					offset += delta
					value := self.memory.read32(offset)
					self.r[i] = value
				} else {
					value := self.memory.read32(offset)
					self.r[i] = value
					offset += delta
				}
			}
		}
	} else {
		for i := 15; i >= 0; i -= 1 {
			if (opcode & (1 << i)) != 0 {
				if p_flag {
					offset += delta
					value := self.memory.read32(offset)
					self.r[i] = value
				} else {
					value := self.memory.read32(offset)
					self.r[i] = value
					offset += delta
				}
			}
		}
	}
	if w_flag {
		self.r[rn] = offset
	}
}

fn (mut self ARM7TDMI) ldr_opcode(opcode u32) {
	rn := (opcode >> 16) & 0xF
	rd := (opcode >> 12) & 0xF
	i_bit := (opcode & 0x200_0000) != 0
	p_bit := (opcode & 0x100_0000) != 0
	u_bit := (opcode & 0x80_0000) != 0
	b_bit := (opcode & 0x40_0000) != 0
	w_bit := (opcode & 0x20_0000) != 0
	mut address := self.r[rn]
	mut offset := u32(0)
	if i_bit {
		rm := self.r[opcode & 0xF]
		shift_value := (opcode >> 7) & 0x1F
		shift_type := ShiftType.from_u32((opcode >> 5) & 3) or { panic('') }
		real_offset := match shift_type {
			.lsl {
				rm << shift_value
			}
			.lsr {
				rm >> shift_value
			}
			.asr {
				bit := rm & 0x8000_0000
				mut final_offset := rm
				for _ in 0 .. shift_value {
					final_offset >>= 1
					final_offset |= bit
				}
				final_offset
			}
			.ror {
				mut final_offset := rm
				for _ in 0 .. shift_value {
					bit := final_offset & 1
					final_offset >>= 1
					final_offset |= (bit << 31)
				}
				final_offset
			}
		}
		offset = if u_bit { real_offset } else { -real_offset }
	} else {
		offset = if u_bit { (opcode & 0xFFF) } else { -(opcode & 0xFFF) }
	}

	if p_bit {
		address += offset
	}

	if b_bit {
		self.r[rd] = self.memory.read8(address)
	} else {
		unalignment_shift := (address & 3) << 3
		mut value := self.memory.read32(address & 0xFFFF_FFFC) // truncate to word aligned
		value = rotate_left_32(value, -int(unalignment_shift))
		self.r[rd] = value
	}

	if !p_bit {
		// Post index. Writeback is always enabled
		self.r[rn] = address + offset
	} else {
		// Preindex. Writeback is optional
		if w_bit {
			self.r[rn] = address
		}
	}
}
