import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test EOR opcode in immediate mode
*/
fn test_assembler_eor_immediate_mode() {
	opcode_string := 'EOR R0, R1, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.EOROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.EOROpcode
	if opcode is biogba.EOROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test EOR opcode in register immediate mode
*/
fn test_assembler_eor_register_immediate_mode() {
	opcode_string := 'EOR R0, R1, R2, ASR, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.EOROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0x10
		}
	}

	assert opcode is biogba.EOROpcode
	if opcode is biogba.EOROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test EOR opcode in register rrx mode
*/
fn test_assembler_eor_rrx() {
	opcode_string := 'EOR R0, R1, R2, RRX'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.EOROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		s_bit: false
		shift_operand: biogba.ShiftOperandRegister{
			rm: 2
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0
		}
	}

	assert opcode is biogba.EOROpcode
	if opcode is biogba.EOROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test EOR opcode in register-register mode
*/
fn test_assembler_eor_register_register_mode() {
	opcode_string := 'EORCCS R0, R1, R2, LSL R3'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.EOROpcode{
		condition: biogba.OpcodeCondition.cc
		rd: 0
		rn: 1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: true
			shift_type: biogba.ShiftType.lsl
			shift_value: 3
		}
	}

	assert opcode is biogba.EOROpcode
	if opcode is biogba.EOROpcode {
		assert opcode == expected_opcode
	}
}
