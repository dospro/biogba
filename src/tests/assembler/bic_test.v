import biogba
import biogba.arm_assembler {opcode_from_string}

/*
Test assembler BIC opcode simple case
*/
fn test_assembler_bic_opcode() {
	opcode_string := 'BICNES R0, R1 #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := biogba.BICOpcode{
		condition: biogba.OpcodeCondition.ne
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 1
			rotate: 14
		}
	}

	assert opcode is biogba.BICOpcode
	if opcode is biogba.BICOpcode {
		assert opcode == expected_opcode
	}
}
