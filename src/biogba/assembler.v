module biogba

import strings.textscanner

/* Function that parses a string into a OpcodeCondition*/
fn condition_from_string(condition_string string) ?OpcodeCondition {
	return match condition_string {
		'EQ' {biogba.OpcodeCondition.eq}
		'NE' {biogba.OpcodeCondition.ne}
		'CS' {biogba.OpcodeCondition.cs}
		'CC' {biogba.OpcodeCondition.cc}
		'MI' {biogba.OpcodeCondition.mi}
		'PL' {biogba.OpcodeCondition.pl}
		'VS' {biogba.OpcodeCondition.vs}
		'VC' {biogba.OpcodeCondition.vc}
		'HI' {biogba.OpcodeCondition.hi}
		'LS' {biogba.OpcodeCondition.ls}
		'GE' {biogba.OpcodeCondition.ge}
		'LT' {biogba.OpcodeCondition.lt}
		'GT' {biogba.OpcodeCondition.gt}
		'LE' {biogba.OpcodeCondition.le}
		'AL' {biogba.OpcodeCondition.al}
		else {none}
	}
}

/* Returns the register number from a register string 
Example
R15 -> 0xF
*/
fn register_number_from_string(register_string string) !u8 {
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
			error("Invalid register ${register_string}")
		}
	}
}


fn opcode_from_string(opcode_text string) !Opcode {

	// Remove commas
	cleaned_opcode_text := opcode_text.replace(',', ' ')

	// Separate tokens
	tokens := cleaned_opcode_text.fields()

	// Parse first token
	mut scanner := textscanner.new(tokens[0])
	mut token := ''
	mut state := 0

	opcode_name_transitions := {
		0: {
			'A': 1
			'B': 5
		}
		1: {
			'D': 2
		}
		2: {
			'C': 3
			'D': 4
		}
	}

	for {
		next_character := utf32_to_str(u32(scanner.peek()))
		if next_state := opcode_name_transitions[state][next_character] {
			state = next_state
			token += next_character
			scanner.skip()
		} else {
			println('Invalid character ${next_character}')
			break
		}
	}

	// Review if we are on a final state
	final_states := [3, 4, 5]
	if !final_states.contains(state) {
		error('Invalid opcode name ${token[0]}')
	}

	scanner.free()
	opcode_name := token

	// Get condition part
	mut condition_string := utf32_to_str(u32(scanner.next()))
	condition_string += utf32_to_str(u32(scanner.next()))
	condition := condition_from_string(condition_string) or {OpcodeCondition.al}

	rd := register_number_from_string(tokens[1]) or {0xFF}
	rn := register_number_from_string(tokens[2]) or {0xFF}

	if opcode_name == 'ADC' {
		return biogba.ADCOpcode{
			condition: condition
			rd: rd
			rn: rn
			shift_operand: biogba.ShiftOperandImmediate{
				value: 0x10
				rotate: 0
			}
		}
	} else {
		return biogba.ADDOpcode{
			rd: 0x0
			rn: 0x0
		}
	}
}
