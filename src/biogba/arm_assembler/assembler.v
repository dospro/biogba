module arm_assembler

import biogba

/*
Returns a Result type with either an Opcode struct from a string
representation or an error in case something goes wrong
*/
pub fn opcode_from_string(opcode_text string) !biogba.Opcode {
	mut tokenizer := Tokenizer{
		text: opcode_text
	}
	opcode_name := tokenizer.next() or { return error('Error parsing line of code') }

	value := match opcode_name.lexeme {
		'ADC', 'ADD', 'AND', 'BIC', 'EOR' {
			DataProcessingOpcodeBuilder.parse(opcode_name.lexeme, mut tokenizer)!
		}
		'B', 'BL' {
			BranchOpcodeBuilder.parse(opcode_name.lexeme, mut tokenizer)!
		}
		'BX' {
			BranchExchangeOpcodeBuilder.parse(mut tokenizer)!
		}
		'CMN', 'CMP' {
			DataProcessingOpcodeBuilder.parse_compare_opcode(opcode_name.lexeme, mut tokenizer)!
		}
		'LDM' {
			BlockDataTransferOpcodeBuilder.parse(opcode_name.lexeme, mut tokenizer)!
		}
		'LDR' {
			SingleDataTransferOpcodeBuilder.parse(opcode_name.lexeme, mut tokenizer)!
		}
		else {
			return error('Opcode not implemented')
		}
	}

	return value
}
