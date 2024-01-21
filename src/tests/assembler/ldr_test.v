import biogba {
	LDROpcode
	Register
}
import biogba.arm_assembler {opcode_from_string}

/*
LDR Opcodes has the following format
LDR{cond}{B}{T} Rd,<Address>

{B} is for byte load LDRB
{T} has a special use for non-priviled mode. See docs. Implemented for completeness

<Address> has multiple modes
- expression	which is an immediate expression. It will use R15(PC) as the base register
- [Rn]			Preindex with an offset of zero. Rn is the base register
- [Rn,<#{+/-}expression>]{!} Preindex with a signed exspression and writeback
- [Rn,{+/-}Rm{,<shift>#exp}]{!} Preindex using signed register mode as offset which can be added a shift mode
- [Rn], exp			Post-index mode. exp can be the same as preindex but outside []

Examples:
LDR R1,[R2,#-10]
LDR R1,[R2,R3,LSL#2]!
LDREQBT R1,[R2],R4
*/

/*
Test LDR most simple form

Load a word into R0 from address specified in R1
No writeback
Offset is 0
*/
fn test_assembler_ldr_simple() {
	opcode_string := 'LDR R0, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0)
	}

	assert opcode is biogba.LDROpcode
	if opcode is biogba.LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDR opcode with a condition
*/
fn test_assembler_ldr_condition() {
	opcode_string := 'LDRLE R0, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.le
		rd: 0
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}