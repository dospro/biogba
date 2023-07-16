module biogba

pub enum ShiftType {
	lsl
	lsr
	asr
	ror
}

fn ShiftType.from_u32(value u32) !ShiftType {
	return match value {
		0 {.lsl}
		1 {.lsr}
		2 {.asr}
		3 {.ror}
		else {
			error('Unknown opcode shift operand type for value $value')
		}
	}
}

/*
Returns a ShiftType value from a string
*/
fn ShiftType.from_string(value string) !ShiftType {
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