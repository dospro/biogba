module biogba

pub enum Register {
	r0
	r1
	r2
	r3
	r4
	r5
	r6
	r7
	r8
	r9
	r10
	r11
	r12
	r13
	r14
	r15
}


/*
Returns the register number from a register string
Example
R15 -> 0xF
*/
fn Register.from_string(register_string string) !u8 {
	return match register_string.to_lower() {
		'r0' {0x0}
		'r1' {0x1}
		'r2' {0x2}
		'r3' {0x3}
		'r4' {0x4}
		'r5' {0x5}
		'r6' {0x6}
		'r7' {0x7}
		'r8' {0x8}
		'r9' {0x9}
		'r10' {0xA}
		'r11' {0xB}
		'r12' {0xC}
		'r13' {0xD}
		'r14' {0xE}
		'r15' {0xF}
		else {
			error('Invalid register ${register_string}')
		}
	}
}

pub fn register_from_string(register_string string) !u8 {
	return Register.from_string(register_string)!
}

fn Register.from_int(value int) !Register {
	return match value {
		0 {.r0}
		1 {.r1}
		2 {.r2}
		3 {.r3}
		4 {.r4}
		5 {.r5}
		6 {.r6}
		7 {.r7}
		8 {.r8}
		9 {.r9}
		10 {.r10}
		11 {.r11}
		12 {.r12}
		13 {.r13}
		14 {.r14}
		15 {.r15}
		else {
			error('Invalid register ${value}')
		}
	}
}
