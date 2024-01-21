module arm_assembler

import biogba {
	LDROpcode,
	Opcode,
	OpcodeCondition,
	Register,
	Offset,
	opcode_condition_from_string,
	register_from_string,
}

pub struct SingleDataTransferOpcodeBuilder {
mut:
	opcode_name   string
	rd            u8
	rn            u8
	p_bit         bool
	u_bit         bool
	b_bit         bool
	w_bit         bool
	address       Offset
}

pub fn SingleDataTransferOpcodeBuilder.parse(opcode_name string, mut tokenizer Tokenizer) !Opcode {
	mut builder := SingleDataTransferOpcodeBuilder{
		opcode_name: opcode_name
	}
	end_state := -1
	bad_state := 100
	mut condition := OpcodeCondition.al

	mut state := 1
	for state != bad_state && state != end_state {
		token := tokenizer.next() or {
			break
		 }
		 match state {
			1 {
				state = match token.token_type {
					.condition {
						value := opcode_condition_from_string(token.lexeme) or {
							return error('Invalid condition')
						}
						condition = value
						2
					}
					else {
						end_state
					}
				}
			}
			else {
				state = end_state
			}
		 }
	}
	return LDROpcode{
		condition: condition
		rd: 0
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0)
	}
}