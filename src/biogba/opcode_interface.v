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

pub enum ShiftType {
	lsl
	lsr
	asr
	ror
}

type ShiftOperand = ShiftOperandImmediate | ShiftOperandRegister

pub struct ShiftOperandImmediate {
	value u8
	rotate u8
}

pub fn (shift_operand ShiftOperandImmediate) as_hex() u32 {	
	return (u32(shift_operand.rotate) << 8) | shift_operand.value | 0x0200_0000
}

pub struct ShiftOperandRegister {
	rm u8
	register_shift bool
	shift_type ShiftType
	shift_value u8
}

pub fn (shift_operand ShiftOperandRegister) as_hex() u32 {
	shift_type_part := (u32(shift_operand.shift_type) & 3) << 5
	if shift_operand.register_shift {		
		return ((u32(shift_operand.shift_value) & 0xF) << 8) | shift_type_part | 0x10 | shift_operand.rm
	}
	return ((u32(shift_operand.shift_value) & 0x1F) << 7) | shift_type_part | shift_operand.rm

}

pub struct ArithmeticOpcode {
	condition OpcodeCondition = OpcodeCondition.al
	shift_operand ShiftOperand = ShiftOperandImmediate{}
	rn u8
	rd u8
	s_bit bool
}

pub fn (opcode ArithmeticOpcode) get_opcode_part() u32 {
	return 0
}

pub fn (opcode &ArithmeticOpcode) as_hex() u32 {
	condition_part := (u32(opcode.condition) & 0xF) << 28
	rn_part := u32(opcode.rn) << 16
	rd_part := u32(opcode.rd) << 12
	s_part := u32(if opcode.s_bit { 0x10_0000 } else { 0x0 })
	shift_operand_part := match opcode.shift_operand {
		ShiftOperandImmediate {
			u32(opcode.shift_operand.as_hex())
		}
		ShiftOperandRegister {
			u32(opcode.shift_operand.as_hex())
		}
	}	
	return condition_part | rn_part | rd_part | s_part | shift_operand_part
}


pub struct ADCOpcode {
	ArithmeticOpcode
}

pub fn (opcode ADCOpcode) get_opcode_part() u32 {
	return 0x00A0_0000
}

pub fn (opcode ADCOpcode) as_hex() u32 {
 	opcode_part := opcode.get_opcode_part()
 	return opcode.ArithmeticOpcode.as_hex() | opcode_part
}

pub struct ADDOpcode {
	ArithmeticOpcode
}

pub fn (opcode ADDOpcode) as_hex() u32 {
	opcode_part := u32(0x0080_0000)
	return (opcode.ArithmeticOpcode).as_hex() | opcode_part
}


pub struct ANDOpcode {
	ArithmeticOpcode
}

pub fn (opcode ANDOpcode) as_hex() u32 {
	opcode_part := u32(0)
	return (opcode.ArithmeticOpcode).as_hex() | opcode_part
}

pub struct BOpcode {
	condition OpcodeCondition = OpcodeCondition.al
	l_flag bool = false
	target_address u32
}

pub fn (self BOpcode) as_hex() u32 {
	opcode_part := u32(0xA00_0000)
	condition_part := (u32(self.condition) & 0xF) << 28
	l_part := if self.l_flag { u32(0x100_0000) } else { u32(0) }
	return condition_part | l_part | self.target_address | opcode_part
}