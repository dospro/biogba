import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test MOV opcode in immediate mode
*/
fn test_assembler_mov_immediate_mode() {
	opcode_string := 'MOV R1, #1'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.MOVOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 0
		}
	}

	assert opcode is biogba.MOVOpcode
	if opcode is biogba.MOVOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test MOV opcode in register immediate mode
*/
fn test_assembler_mov_register_immediate_mode() {
	opcode_string := 'MOVNES R2, R1, ASR, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.MOVOpcode{
		condition: biogba.OpcodeCondition.ne
		rd: 2
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 1
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0x10
		}
	}

	assert opcode is biogba.MOVOpcode
	if opcode is biogba.MOVOpcode {
		assert opcode == expected_opcode
	}
}

// Note: All other mode are not directly tested as they are covered as a general case for all data processing opcodes
