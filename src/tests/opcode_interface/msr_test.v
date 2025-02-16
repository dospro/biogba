import biogba {
	MSROpcode,
	OpcodeCondition,
	ShiftOperandImmediate,
}

/*
By default, field mask is set to 9 which means 1001:
condition and control flags are writable
any other flags (unused) are not
*/

/*
Test MRS opcode interface with default values
*/
fn test_msr_default() {
	opcode := MSROpcode{}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE129_F000
}

/*
Test MSR ocpode interface with a different condition
*/
fn test_msr_condition() {
	opcode := MSROpcode{
		condition: OpcodeCondition.pl
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x5129_F000
}

/*
Test MSR ocpode interface register mode
*/
fn test_msr_register_mode() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.eq
		shift_operand: u8(7)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x0129_F007
}

/*
Test MSR ocpode interface immediate mode
*/
fn test_msr_immediate_mode() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.eq
		shift_operand: ShiftOperandImmediate{
			value:  0xF
			rotate: 15
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x0329_FF0F
}

/*
Test MSR ocpode interface immediate mode
with different values
*/
fn test_msr_immediate_mode_different_values() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.eq
		shift_operand: ShiftOperandImmediate{
			value:  0x45
			rotate: 3
		}
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0x0329_F345
}

/*
Test MSR ocpode interface with p set
The test uses register mode (simpler)
*/
fn test_msr_p() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.al
		p_bit:         true
		shift_operand: u8(1)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE169_F001
}

/*
Test MSR ocpode interface with mask flags all set
*/
fn test_msr_mask_flags_set() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.al
		p_bit:         true
		c_flag: true
		x_flag: true
		s_flag: true
		f_flag: true
		shift_operand: u8(1)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE16F_F001
}

/*
Test MSR ocpode interface with mask flags all unset
Just for testing purposes, this should neves happen
*/
fn test_msr_mask_flags_unset() {
	opcode := MSROpcode{
		condition:     OpcodeCondition.al
		p_bit:         true
		c_flag: false
		x_flag: false
		s_flag: false
		f_flag: false
		shift_operand: u8(1)
	}
	hex_value := opcode.as_hex()
	assert hex_value == 0xE160_F001
}