module biogba

pub enum ShiftType {
	lsl
	lsr
	asr
	ror
}

pub fn ShiftType.from_u32(value u32) !ShiftType {
	return match value {
		0 {.lsl}
		1 {.lsr}
		2 {.asr}
		3 {.ror}
		else {
			error('Unknown opcode shift operand type for value ${value}')
		}
	}
}

pub fn shift_type_from_u32(value u32) !ShiftType {
	return ShiftType.from_u32(value)!
}

/*
Returns a ShiftType value from a string
*/
pub fn ShiftType.from_string(value string) !ShiftType {
	return match value.to_lower() {
		'lsl' {.lsl}
		'lsr' {.lsr}
		'asr' {.asr}
		'ror' {.ror}
		else {
			error('Invalid opcode shift operand string ${value}')
		}
	}
}

pub fn shift_type_from_string(value string) !ShiftType {
	return ShiftType.from_string(value)!
}
