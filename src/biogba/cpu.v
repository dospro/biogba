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

// Processor Status Register
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
	r_fiq           [7]u32 // FIQ banked registers R8-R14 (indexed 0-6)
	r13_irq         u32
	r14_irq         u32
	r13_supervisor  u32
	r14_supervisor  u32
	r13_abort       u32
	r14_abort       u32
	r13_undefined   u32
	r14_undefined   u32
	cpsr            PSR
	spsr_fiq        PSR
	spsr_irq        PSR
	spsr_supervisor PSR
	spsr_abort      PSR
	spsr_undefined  PSR
	spsr_system     PSR
}

// Set a register value for a specific CPU mode
// Handles banked registers correctly based on mode
pub fn (mut state CPUState) set_register(reg_num u32, mode CPUMode, value u32) {
	match mode {
		.fiq {
			// FIQ mode: R8-R14 are banked (stored in r_fiq[0-6])
			if reg_num >= 8 && reg_num <= 14 {
				state.r_fiq[reg_num - 8] = value
			} else {
				state.r[reg_num] = value
			}
		}
		.irq {
			// IRQ mode: R13-R14 are banked
			if reg_num == 13 {
				state.r13_irq = value
			} else if reg_num == 14 {
				state.r14_irq = value
			} else {
				state.r[reg_num] = value
			}
		}
		.supervisor {
			// Supervisor mode: R13-R14 are banked
			if reg_num == 13 {
				state.r13_supervisor = value
			} else if reg_num == 14 {
				state.r14_supervisor = value
			} else {
				state.r[reg_num] = value
			}
		}
		.abort {
			// Abort mode: R13-R14 are banked
			if reg_num == 13 {
				state.r13_abort = value
			} else if reg_num == 14 {
				state.r14_abort = value
			} else {
				state.r[reg_num] = value
			}
		}
		.undefined {
			// Undefined mode: R13-R14 are banked
			if reg_num == 13 {
				state.r13_undefined = value
			} else if reg_num == 14 {
				state.r14_undefined = value
			} else {
				state.r[reg_num] = value
			}
		}
		.user, .system {
			// User and System modes share the same register bank
			state.r[reg_num] = value
		}
	}
}

// Get a register value for a specific CPU mode
// Handles banked registers correctly based on mode
pub fn (state CPUState) get_register(reg_num u32, mode CPUMode) u32 {
	match mode {
		.fiq {
			// FIQ mode: R8-R14 are banked (stored in r_fiq[0-6])
			if reg_num >= 8 && reg_num <= 14 {
				return state.r_fiq[reg_num - 8]
			}
			return state.r[reg_num]
		}
		.irq {
			// IRQ mode: R13-R14 are banked
			if reg_num == 13 {
				return state.r13_irq
			}
			if reg_num == 14 {
				return state.r14_irq
			}
			return state.r[reg_num]
		}
		.supervisor {
			// Supervisor mode: R13-R14 are banked
			if reg_num == 13 {
				return state.r13_supervisor
			}
			if reg_num == 14 {
				return state.r14_supervisor
			}
			return state.r[reg_num]
		}
		.abort {
			// Abort mode: R13-R14 are banked
			if reg_num == 13 {
				return state.r13_abort
			}
			if reg_num == 14 {
				return state.r14_abort
			}
			return state.r[reg_num]
		}
		.undefined {
			// Undefined mode: R13-R14 are banked
			if reg_num == 13 {
				return state.r13_undefined
			}
			if reg_num == 14 {
				return state.r14_undefined
			}
			return state.r[reg_num]
		}
		.user, .system {
			// User and System modes share the same register bank
			return state.r[reg_num]
		}
	}
}

pub struct ARM7TDMI {
pub mut:
	state  CPUState
	memory MemoryInterface
}

@[inline]
pub fn (mut self ARM7TDMI) set_state(state CPUState) {
	self.state = state
}

@[inline]
pub fn (self ARM7TDMI) get_state() CPUState {
	return self.state
}

@[inline]
pub fn (self ARM7TDMI) get_current_spsr() PSR {
	return match self.state.cpsr.mode {
		.fiq { self.state.spsr_fiq }
		.irq { self.state.spsr_irq }
		.supervisor { self.state.spsr_supervisor }
		.abort { self.state.spsr_abort }
		.undefined { self.state.spsr_undefined }
		.system { self.state.spsr_system }
		else { panic('Loading SPSR from user mode or wrong mode') }
	}
}

@[inline]
pub fn (mut self ARM7TDMI) set_current_spsr(value u32) {
	match self.state.cpsr.mode {
		.fiq { self.state.spsr_fiq.from_value(value) }
		.irq { self.state.spsr_irq.from_value(value) }
		.supervisor { self.state.spsr_supervisor.from_value(value) }
		.abort { self.state.spsr_abort.from_value(value) }
		.undefined { self.state.spsr_undefined.from_value(value) }
		.system { self.state.spsr_system.from_value(value) }
		else { panic('Writing to an unknown PSR') }
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
	c_part := if self.state.cpsr.c { u32(1) } else { u32(0) }
	match opcode_high_bits {
		0 {
			if (opcode & 0x0FFF_FFF0) == 0x12F_FF10 { // BX
				rm := opcode & 0xF
				if (self.state.r[rm] & 1) != 0 {
					self.state.cpsr.t = true
				}
				self.state.r[15] = self.state.r[rm] & 0xFFFF_FFFE
			} else if (opcode & 0x0F80_00F0) == 0x80_0090 { // MULL
				rdhi := (opcode >> 16) & 0xF
				rdlo := (opcode >> 12) & 0xF
				rs := (opcode >> 8) & 0xF
				rm := opcode & 0xF
				is_signed := ((opcode >> 22) & 1) == 1
				accumulate := ((opcode >> 21) & 1) == 1
				s_bit := ((opcode >> 20) & 1) == 1
				product := if is_signed {
					u64(i64(int(self.state.r[rs])) * i64(int(self.state.r[rm])))
				} else {
					u64(self.state.r[rs]) * u64(self.state.r[rm])
				}
				final_sum := if accumulate {
					((u64(self.state.r[rdhi]) << 32) | u64(self.state.r[rdlo])) + product
				} else {
					product
				}
				if s_bit {
					self.state.cpsr.z = final_sum == 0
					self.state.cpsr.n = (final_sum >> 63) == 1
				}
				self.state.r[rdhi] = u32(final_sum >> 32)
				self.state.r[rdlo] = u32(final_sum & 0xFFFF_FFFF)
			} else if (opcode & 0x0FC0_0090) == 0x90 { // MUL
				rd := (opcode >> 16) & 0xF
				rn := (opcode >> 12) & 0xF
				rs := (opcode >> 8) & 0xF
				rm := opcode & 0xF
				is_mla := ((opcode >> 21) & 1) == 1
				s_bit := ((opcode >> 20) & 1) == 1
				self.state.r[rd] = if is_mla {
					self.state.r[rn] + self.state.r[rs] * self.state.r[rm]
				} else {
					self.state.r[rs] * self.state.r[rm]
				}
				if s_bit {
					self.state.cpsr.n = false
					self.state.cpsr.z = false
					if (self.state.r[rd] & 0x8000_0000) != 0 {
						self.state.cpsr.n = true
					}
					if self.state.r[rd] == 0 {
						self.state.cpsr.z = true
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
					false { self.state.r[opcode & 0xF] }
				}
				address := match u_bit {
					0 { self.state.r[rn] - offset }
					1 { self.state.r[rn] + offset }
					else { panic('u_bit is not binary!') }
				}
				// println('R${rn}: ${self.state.r[rn].hex()}, Offset: ${offset.hex()}')
				value := match is_preindex {
					true {
						if writeback {
							self.state.r[rn] = address
						}
						self.memory.read16(address) // First add base + offset and then read
					}
					false {
						result := self.memory.read16(self.state.r[rn]) // First read from base and then add offset
						self.state.r[rn] = address
						result
					}
				}
				mask := if is_halfword { u32(0xFFFF_0000) } else { u32(0xFFFF_FF00) }
				check_bit := if is_halfword { u32(0x8000) } else { u32(0x80) }
				self.state.r[rd] = if is_signed && (value & check_bit) != 0 {
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
						self.state.r[rm]
					}
				}

				if p_bit {
					mut current_psr_value := self.get_current_spsr().to_hex()
					if c_mask && self.state.cpsr.mode != .user {
						current_psr_value = (current_psr_value & 0xFFFF_FF00) | (value & 0xFF)
					}
					if f_mask {
						current_psr_value = (current_psr_value & 0x0FFF_FFFF) | (value & 0xF000_0000)
					}
					self.set_current_spsr(current_psr_value)
				} else {
					mut current_psr_value := self.state.cpsr.to_hex()
					if c_mask && self.state.cpsr.mode != .user {
						current_psr_value = (current_psr_value & 0xFFFF_FF00) | (value & 0xFF)
					}
					if f_mask {
						current_psr_value = (current_psr_value & 0x0FFF_FFFF) | (value & 0xF000_0000)
					}
					self.state.cpsr.from_value(current_psr_value)
				}
			} else if (opcode & 0x1BF_0FFF) == 0x010F_0000 { // MRS
				p_bit := (opcode >> 22) & 1
				value := match p_bit {
					0 { self.state.cpsr.to_hex() }
					1 { self.get_current_spsr().to_hex() }
					else { panic('p_bit is not binary!') }
				}

				rd := (opcode >> 12) & 0xF
				self.state.r[rd] = value
			} else {
				data_processing_opcode := (opcode >> 21) & 0xF
				rn := (opcode >> 16) & 0xF
				rd := (opcode >> 12) & 0xF
				operand_value := self.get_shift_operand_value(opcode)
				s_bit := ((opcode >> 20) & 1) == 1
				result := match data_processing_opcode {
					0 { // AND
						self.state.r[rd] = self.state.r[rn] & operand_value
						self.state.r[rd]
					}
					1 { // EOR
						self.state.r[rd] = self.state.r[rn] ^ operand_value
						self.state.r[rd]
					}
					3 { // RSB
						self.state.r[rd] = operand_value - self.state.r[rn]
						self.state.r[rd]
					}
					4 { // ADD
						self.state.r[rd] = self.state.r[rn] + operand_value
						self.state.r[rd]
					}
					5 { // ADC
						self.state.r[rd] = self.state.r[rn] + c_part + operand_value
						self.state.r[rd]
					}
					6 { // SBC
						self.state.r[rd] = self.state.r[rn] - operand_value + c_part - 1
						self.state.r[rd]
					}
					7 { // RSC
						self.state.r[rd] = operand_value - self.state.r[rn] + c_part - 1
						self.state.r[rd]
					}
					0xA { // CMP
						self.state.r[rn] - operand_value
					}
					0xB { // CMN
						self.state.r[rn] + operand_value
					}
					0xC { // ORR
						self.state.r[rd] = self.state.r[rn] | operand_value
						self.state.r[rd]
					}
					0xD { // MOV
						self.state.r[rd] = operand_value
						operand_value
					}
					0xE { // BIC
						self.state.r[rd] = self.state.r[rn] & ~operand_value
						self.state.r[rd]
					}
					0xF { // MVN
						self.state.r[rd] = operand_value ^ 0xFFFF_FFFF
						operand_value ^ 0xFFFF_FFFF
					}
					else {
						0
					}
				}
				if s_bit {
					if rd == 15 {
						self.state.cpsr = self.get_current_spsr()
					} else {
						self.state.cpsr.v = ((self.state.r[rn] ^ operand_value ^ result) & 0x8000_0000) != 0
						self.state.cpsr.z = result == 0
						self.state.cpsr.n = (result & 0x8000_0000) != 0
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
					self.state.r[14] = self.state.r[15] + 4
				}
				self.state.r[15] += target_address
			} else if (opcode & 0xE10_0000) == 0x810_0000 { // LDM
				self.ldm_opcode(opcode)
			} else if (opcode & 0xE10_0000) == 0x800_0000 { // STM
				self.stm_opcode(opcode)
			}
		}
		3 {}
		else {}
	}
}

/*
Evaluate condition. Opcode should execute if the result is true
*/
@[inline]
fn (self ARM7TDMI) should_execute(condition OpcodeCondition) bool {
	match true {
		condition == .eq && !self.state.cpsr.z, condition == .ne && self.state.cpsr.z,
		condition == .cs && !self.state.cpsr.c, condition == .cc && self.state.cpsr.c,
		condition == .mi && !self.state.cpsr.n, condition == .pl && self.state.cpsr.n,
		condition == .vs && !self.state.cpsr.v, condition == .vc && self.state.cpsr.v,
		condition == .hi && !self.state.cpsr.c && self.state.cpsr.z,
		condition == .ls
			&& !(!self.state.cpsr.c || self.state.cpsr.z),
		condition == .ge
			&& self.state.cpsr.n != self.state.cpsr.v,
		condition == .lt
			&& self.state.cpsr.n == self.state.cpsr.v,
		condition == .gt
			&& !(!self.state.cpsr.z && self.state.cpsr.n == self.state.cpsr.v),
		condition == .le && !(self.state.cpsr.z
			|| self.state.cpsr.n != self.state.cpsr.v) {
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
	mut c_bit := self.state.cpsr.c
	if is_register_shift {
		shift_type := ShiftType.from_u32((opcode >> 5) & 3) or { panic('') }
		is_register_value := ((opcode >> 4) & 1) == 1
		shift_value := if is_register_value {
			self.state.r[(opcode >> 8) & 0xF]
		} else {
			(opcode >> 7) & 0x1F
		}
		rm := opcode & 0xF
		mut result := self.state.r[rm]

		operand_value = match shift_type {
			.lsl {
				for _ in 0 .. shift_value {
					c_bit = (result & 0x8000_0000) != 0
					result <<= 1
				}
				result

				// Possible optimization. Need to review for values > 32
				// if shift_value != 0 {
				// 	c_bit = (result >> (32 - shift_value)) & 1 != 0
				// }
				// result << shift_value
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
		self.state.cpsr.c = c_bit
	}
	return operand_value
}

fn (mut self ARM7TDMI) ldm_opcode(opcode u32) {
	rn := (opcode >> 16) & 0xF
	p_flag := (opcode & 0x100_0000) != 0
	u_flag := (opcode & 0x80_0000) != 0
	s_flag := (opcode & 0x40_0000) != 0
	w_flag := (opcode & 0x20_0000) != 0

	mut address := self.state.r[rn]
	delta := if u_flag { u32(4) } else { u32(-4) }

	// Single loop that handles both increment and decrement modes
	// For increment: iterate 0->15, for decrement: iterate 15->0
	for i in 0 .. 16 {
		reg_idx := if u_flag { u32(i) } else { u32(15 - i) }

		if (opcode & (1 << reg_idx)) != 0 {
			// Apply offset before loading if pre-indexed (p_flag set)
			if p_flag {
				address += delta
			}

			// Load value from memory into register
			value := self.memory.read32(address)
			self.state.set_register(reg_idx, if s_flag { .user } else { self.state.cpsr.mode }, value)

			// Apply offset after loading if post-indexed (p_flag not set)
			if !p_flag {
				address += delta
			}
		}
	}

	// Write-back: update base register
	// ARM spec: "A LDM will always overwrite the updated base if the base is in the list"
	if w_flag {
		self.state.r[rn] = address
	}

	if s_flag && (opcode & (1 << 15)) != 0 {
		// If S bit is set and R15 is in the list, load CPSR from SPSR
		self.state.cpsr = self.get_current_spsr()
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
	mut address := self.state.r[rn]
	mut offset := u32(0)
	if i_bit {
		rm := self.state.r[opcode & 0xF]
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
		self.state.r[rd] = self.memory.read8(address)
	} else {
		unalignment_shift := (address & 3) << 3
		mut value := self.memory.read32(address & 0xFFFF_FFFC) // truncate to word aligned
		value = rotate_left_32(value, -int(unalignment_shift))
		self.state.r[rd] = value
	}

	if !p_bit {
		// Post index. Writeback is always enabled
		self.state.r[rn] = address + offset
	} else {
		// Preindex. Writeback is optional
		if w_bit {
			self.state.r[rn] = address
		}
	}
}

fn (mut self ARM7TDMI) stm_opcode(opcode u32) {
	rn := (opcode >> 16) & 0xF
	p_flag := (opcode & 0x100_0000) != 0
	u_flag := (opcode & 0x80_0000) != 0
	s_flag := (opcode & 0x40_0000) != 0
	w_flag := (opcode & 0x20_0000) != 0
	mut offset := self.state.r[rn]
	mut rn_offset := u32(0)
	mut replace_rn_value := false

	delta := if u_flag { u32(4) } else { u32(-4) }
	// Determine which mode's registers to use
	// When s_flag is set, use user mode registers regardless of current mode
	// When s_flag is not set, use current mode's banked registers
	mode := if s_flag { CPUMode.user } else { self.state.cpsr.mode }

	for index in 0 ..16 {
		mut i := if u_flag { index } else { 15 - index }
		if (opcode & (1 << i)) != 0 {
			// Track when base register (Rn) is being stored and offset has changed
			// This implements the ARM spec: "STM which includes storing the base, with
			// the base as the first register to be stored, will store the unchanged value"
			if rn == i && offset != self.state.r[rn] {
				// Base is in the list but not the first register (offset has changed)
				// Save this address to potentially write the modified base value later
				rn_offset = offset
				replace_rn_value = true
			}
			if p_flag {
				offset += delta
			}

			reg_value := self.state.get_register(u32(i), mode)
			self.memory.write32(offset, reg_value)

			if !p_flag {
				offset += delta
			}
		}
	}
	// Write-back: update base register at the end of the second cycle
	// This implements the ARM spec: "the base is written back at the end of the second cycle"
	if w_flag {
		self.state.r[rn] = offset
		// If the base register was stored and it wasn't the first register,
		// we need to update memory with the modified (written-back) value
		// This implements: "with the base second or later in the transfer order,
		// will store the modified value"
		if replace_rn_value {
			self.memory.write32(rn_offset, self.state.r[rn])
		}
	}
}
