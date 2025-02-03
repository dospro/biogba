module biogba

pub type ShiftOperand = ShiftOperandImmediate | ShiftOperandRegister

pub struct ShiftOperandImmediate {
pub:
	value  u8
	rotate u8
}

pub fn (shift_operand ShiftOperandImmediate) as_hex() u32 {
	return (u32(shift_operand.rotate) << 8) | shift_operand.value | 0x0200_0000
}

pub struct ShiftOperandRegister {
pub:
	rm             u8
	register_shift bool
	shift_type     ShiftType
	shift_value    u8
}

pub fn (shift_operand ShiftOperandRegister) as_hex() u32 {
	shift_type_part := (u32(shift_operand.shift_type) & 3) << 5
	if shift_operand.register_shift {
		return ((u32(shift_operand.shift_value) & 0xF) << 8) | shift_type_part | 0x10 | shift_operand.rm
	}
	return ((u32(shift_operand.shift_value) & 0x1F) << 7) | shift_type_part | shift_operand.rm
}

fn (self ShiftOperand) as_hex() u32 {
	return match self {
		ShiftOperandImmediate { self.as_hex() }
		ShiftOperandRegister { self.as_hex() }
	}
}

pub interface Opcode {
	as_hex() u32
}

pub struct DataProcessingOpcode {
pub:
	condition     OpcodeCondition = OpcodeCondition.al
	shift_operand ShiftOperand    = ShiftOperandImmediate{}
	rn            u8
	rd            u8
	s_bit         bool
}

pub fn (opcode DataProcessingOpcode) get_opcode_part() u32 {
	return 0
}

pub fn (opcode &DataProcessingOpcode) as_hex() u32 {
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rn_part := u32(opcode.rn) << 16
	rd_part := u32(opcode.rd) << 12
	s_part := u32(if opcode.s_bit { 0x10_0000 } else { 0x0 })
	shift_operand_part := opcode.shift_operand.as_hex()
	return condition_part | rn_part | rd_part | s_part | shift_operand_part
}

pub struct ADCOpcode {
	DataProcessingOpcode
}

pub fn (opcode ADCOpcode) get_opcode_part() u32 {
	return 0x00A0_0000
}

pub fn (opcode ADCOpcode) as_hex() u32 {
	opcode_part := opcode.get_opcode_part()
	return opcode.DataProcessingOpcode.as_hex() | opcode_part
}

pub struct ADDOpcode {
	DataProcessingOpcode
}

pub fn (opcode ADDOpcode) as_hex() u32 {
	opcode_part := u32(0x0080_0000)
	return (opcode.DataProcessingOpcode).as_hex() | opcode_part
}

pub struct ANDOpcode {
	DataProcessingOpcode
}

pub fn (opcode ANDOpcode) as_hex() u32 {
	opcode_part := u32(0)
	return (opcode.DataProcessingOpcode).as_hex() | opcode_part
}

pub struct BOpcode {
pub:
	condition      OpcodeCondition = OpcodeCondition.al
	l_flag         bool            = false
	target_address u32
}

pub fn (self BOpcode) as_hex() u32 {
	opcode_part := u32(0xA00_0000)
	condition_part := (u32(self.condition) & 0xF) << 28
	l_part := if self.l_flag { u32(0x100_0000) } else { u32(0) }
	return condition_part | l_part | self.target_address | opcode_part
}

pub struct BICOpcode {
	DataProcessingOpcode
}

pub fn (opcode BICOpcode) as_hex() u32 {
	opcode_part := u32(0x1C0_0000)
	return (opcode.DataProcessingOpcode).as_hex() | opcode_part
}

pub struct BXOpcode {
pub:
	condition OpcodeCondition = OpcodeCondition.al
	rm        u8
}

pub fn (opcode BXOpcode) as_hex() u32 {
	condition_part := (u32(opcode.condition) & 0xF) << 28
	opcode_part := u32(0x012F_FF10)
	return condition_part | opcode_part | opcode.rm
}

pub struct CMNOpcode {
	DataProcessingOpcode
pub:
	s_bit bool = true
}

pub fn (opcode CMNOpcode) as_hex() u32 {
	opcode_part := u32(0x170_0000)
	if !opcode.s_bit {
		panic('CMN Opcode always has S bit set')
	}
	return opcode_part | opcode.DataProcessingOpcode.as_hex()
}

pub struct CMPOpcode {
	DataProcessingOpcode
pub:
	s_bit bool = true
}

pub fn (opcode CMPOpcode) as_hex() u32 {
	opcode_part := u32(0x150_0000)
	if !opcode.s_bit {
		panic('CMP Opcode always has S bit set')
	}
	return opcode_part | opcode.DataProcessingOpcode.as_hex()
}

pub struct EOROpcode {
	DataProcessingOpcode
}

pub fn (opcode EOROpcode) as_hex() u32 {
	opcode_part := u32(0x0020_0000)
	return opcode_part | opcode.DataProcessingOpcode.as_hex()
}

pub struct LDMOpcode {
pub:
	condition     OpcodeCondition = OpcodeCondition.al
	rn            u8
	p_bit         bool
	u_bit         bool
	w_bit         bool
	register_list []Register
}

pub fn (opcode LDMOpcode) as_hex() u32 {
	opcode_part := u32(0x810_0000)
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rn_part := u32(opcode.rn) << 16
	p_part := if opcode.p_bit { u32(0x100_0000) } else { u32(0) }
	u_part := if opcode.u_bit { u32(0x80_0000) } else { u32(0) }
	w_part := if opcode.w_bit { u32(0x20_0000) } else { u32(0) }
	mut register_list_part := u32(0)
	for elem in opcode.register_list {
		register_list_part |= (1 << u32(elem))
	}
	return condition_part | p_part | u_part | w_part | rn_part | opcode_part | register_list_part
}

pub struct RegisterOffset {
pub mut:
	rm          u8
	shift_type  ShiftType
	shift_value u8
}

pub fn (self RegisterOffset) as_hex() u32 {
	return (u32(self.shift_value) << 7) | (u32(self.shift_type) << 5) | u32(self.rm)
}

pub type Offset = RegisterOffset | u16

pub struct LDROpcode {
pub:
	condition OpcodeCondition = OpcodeCondition.al
	rn        u8
	rd        u8
	p_bit     bool
	u_bit     bool
	b_bit     bool
	w_bit     bool
	address   Offset
}

pub fn (opcode LDROpcode) as_hex() u32 {
	opcode_part := u32(0x0400_0000)
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rn_part := u32(opcode.rn) << 16
	rd_part := u32(opcode.rd) << 12
	p_part := if opcode.p_bit { u32(0x100_0000) } else { u32(0) }
	u_part := if opcode.u_bit { u32(0x80_0000) } else { u32(0) }
	b_part := if opcode.b_bit { u32(0x40_0000) } else { u32(0) }
	w_part := if opcode.w_bit { u32(0x20_0000) } else { u32(0) }
	address_part := match opcode.address {
		u16 { u32(opcode.address) }
		RegisterOffset { opcode.address.as_hex() | 0x200_0000 }
	}
	return opcode_part | condition_part | rn_part | rd_part | p_part | u_part | b_part | w_part | address_part
}

pub type LDRSBHOffset = Register | u8

pub struct LDRSBHOpcode {
pub:
	condition OpcodeCondition = OpcodeCondition.al
	rn        u8
	rd        u8
	p_bit     bool = true
	u_bit     bool = true
	w_bit     bool = false
	s_bit     bool = false
	h_bit     bool = true
	address   LDRSBHOffset
}

pub fn (opcode LDRSBHOpcode) as_hex() u32 {
	opcode_part := u32(0x0010_0090)
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rn_part := u32(opcode.rn) << 16
	rd_part := u32(opcode.rd) << 12
	p_part := if opcode.p_bit { u32(0x100_0000) } else { u32(0) }
	u_part := if opcode.u_bit { u32(0x80_0000) } else { u32(0) }
	w_part := if opcode.w_bit { u32(0x20_0000) } else { u32(0) }
	s_part := if opcode.s_bit { u32(0x40) } else { u32(0) }
	h_part := if opcode.h_bit { u32(0x20) } else { u32(0) }
	address_part := match opcode.address {
		u8 {
			((u32(opcode.address) & 0xF0) << 4) | (opcode.address & 0xF) | 0x40_0000
		}
		Register {
			u32(opcode.address)
		}
	}

	if !opcode.s_bit && !opcode.h_bit {
		panic('Bad Opcode: S and H flags cannot be both zero.')
	}
	return condition_part | rn_part | rd_part | p_part | u_part | w_part | s_part | h_part | address_part | opcode_part
}

pub struct MULOpcode {
pub:
	condition OpcodeCondition = OpcodeCondition.al
	rd        u8
	rn        u8
	rs        u8
	rm        u8
	s_bit     bool
	a_bit     bool
}

pub fn (opcode MULOpcode) as_hex() u32 {
	opcode_part := u32(0x0000_0090)
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rm_part := u32(opcode.rm)
	rs_part := u32(opcode.rs) << 8
	rn_part := u32(opcode.rn) << 12
	rd_part := u32(opcode.rd) << 16
	s_part := if opcode.s_bit { u32(0x10_0000) } else { u32(0) }
	a_part := if opcode.a_bit { u32(0x20_0000) } else { u32(0) }
	return condition_part | rd_part | rn_part | rs_part | rm_part | s_part | a_part | opcode_part
}

pub struct MOVOpcode {
	DataProcessingOpcode
}

pub fn (opcode MOVOpcode) as_hex() u32 {
	opcode_part := u32(0x01A0_0000)
	return opcode_part | opcode.DataProcessingOpcode.as_hex()
}

pub struct MRSOpcode {
pub:
	condition OpcodeCondition = OpcodeCondition.al
	rd        u8
	p_bit     bool
}

pub fn (opcode MRSOpcode) as_hex() u32 {
	opcode_part := u32(0x010F_0000)
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rd_part := u32(opcode.rd) << 12
	p_part := if opcode.p_bit { u32(0x40_0000) } else { u32(0) }
	return condition_part | rd_part | p_part | opcode_part
}
