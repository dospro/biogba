module arm_assembler

import biogba

enum OpcodeType {
	data_processing
	branch
}

fn get_opcode_type_from_name(opcode_name string) ?OpcodeType {
	data_processing := ['ADC', 'ADD', 'AND']
	branch := ['B', 'BL']
	if data_processing.contains(opcode_name) {
		return .data_processing
	} else if branch.contains(opcode_name) {
		return .branch
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
	}

	return error('Invalid opcode')
}
