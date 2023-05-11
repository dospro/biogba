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
	return match register_string {
		'R0' {0x0}
		'R1' {0x1}
		'R2' {0x2}
		'R3' {0x3}
		'R4' {0x4}
		'R5' {0x5}
		'R6' {0x6}
		'R7' {0x7}
		'R8' {0x8}
		'R9' {0x9}
		'R10' {0xA}
		'R11' {0xB}
		'R12' {0xC}
		'R13' {0xD}
		'R14' {0xE}
		'R15' {0xF}
		else {
			error("Invalid register ${register_string}")
		}
	}
}


fn opcode_from_string(opcode_text string) !Opcode {

	cleaned_opcode_text := opcode_text.replace(',', ' ')
	mut scanner := textscanner.new(cleaned_opcode_text)
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
		println('Next character : ${next_character}')
		match next_character {
			' ', ',', '\n', '\r', '\t' {scanner.skip()}
			else {
				if next_state := opcode_name_transitions[state][next_character] {
					state = next_state
					token += next_character
					scanner.skip()
				} else {
					println('Invalid character ${next_character}')
					break
				}
			}
		}
		match state {
			3, 4, 5 {
				break
			} else {
				continue
			}
		}
	}
	scanner.free()

	opcode_name := token
	println('Opcode name : ${opcode_name}')
	mut condition_string := utf32_to_str(u32(scanner.next()))
	condition_string += utf32_to_str(u32(scanner.next()))
	println('Condition string : ${condition_string}')

	tokens := cleaned_opcode_text.fields()
	println('Tokens : ${tokens}')


	mut rd := register_number_from_string(tokens[1]) or {0xFF}
	conditionb := if condition := condition_from_string(condition_string) {
		condition
	} else {
		rd = register_number_from_string(opcode_text[4..6])!
		OpcodeCondition.al
	}

	if opcode_name == 'ADC' {
		return biogba.ADCOpcode{
			condition: conditionb
			rd: rd
			rn: 0x3
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
