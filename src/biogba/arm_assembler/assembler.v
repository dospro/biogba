module arm_assembler

import biogba

enum OpcodeType {
	data_processing
	branch
	branch_and_exchange
}

fn get_opcode_type_from_name(opcode_name string) ?OpcodeType {
	if opcode_name in data_processing_opcodes {
		return .data_processing
	} else if opcode_name in branch_opcodes {
		return .branch
	} else if opcode_name in branch_and_exchange_opcodes {
		return .branch_and_exchange
	} else {
		return none
	}
}

/*
Returns a Result type with either an Opcode struct from a string
representation or an error in case something goes wrong
*/
pub fn opcode_from_string(opcode_text string) !biogba.Opcode {
	parsed_tokens := tokens_from_string(opcode_text)!
	tokens_list := parsed_tokens.tokens
	general_state := parsed_tokens.state
	opcode_name := tokens_list[0].token_value as string
	opcode_type := get_opcode_type_from_name(opcode_name)
	match opcode_type {
		.data_processing {
			return build_data_processing_opcode(general_state, tokens_list)!
		}
		.branch {
			return build_branch_opcode(general_state, tokens_list)!
		}
		.branch_and_exchange {
			return build_branch_and_exchange_opcode(tokens_list)!
		}
	}

	return error('Invalid opcode')
}
