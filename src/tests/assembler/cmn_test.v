import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test CMN opcode
*/
fn test_assembler_cmn() {
	opcode_string := 'CMN R1, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.CMNOpcode{
		condition: biogba.OpcodeCondition.al
		rn: 1
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 14
			value: 1
		}
	}

	assert opcode is biogba.CMNOpcode
	if opcode is biogba.CMNOpcode {
		assert opcode == expected_opcode
	}
}