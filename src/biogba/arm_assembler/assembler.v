module arm_assembler

import biogba

/*
Returns a Result type with either an Opcode struct from a string
representation or an error in case something goes wrong
*/
pub fn opcode_from_string(opcode_text string) !biogba.Opcode {
	assembler := Assembler{}
	return assembler.parse_opcode(opcode_text)
}

pub struct AsmState {
pub mut:
	r15 u32
}

/*
The functions takes an absolute memory address and returns a relative address
taking PC as the base and calculating the offset. It also considers prefetched
instructions which normally are 8 words ahead
*/
pub fn (self AsmState) get_real_address(value u16) u16 {
	return u16(value - self.r15 + 8)
}
pub struct Assembler {
pub mut:
	state AsmState
}

pub fn (self Assembler) parse_opcode(opcode_text string) !biogba.Opcode {
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
			SingleDataTransferOpcodeBuilder.parse(opcode_name.lexeme, mut tokenizer, self.state)!
		}
		else {
			return error('Opcode not implemented')
		}
	}

	return value
}
