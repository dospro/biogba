import biogba
import biogba.arm_assembler { opcode_from_string }

/*
Test CMP opcode
The format is pretty much the same as CMN so the tests only
covers a general case
*/
fn test_assembler_cmp() {
	opcode_string := 'CMPLE R2, R4, ASR, #F'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.CMPOpcode{
		condition: biogba.OpcodeCondition.le
		rn: 2
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 4
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0xF
		}
	}

	assert opcode is biogba.CMPOpcode
	if opcode is biogba.CMPOpcode {
		assert opcode == expected_opcode
	}
}
