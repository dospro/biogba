import biogba {
	LDRSBHOpcode,
	RegisterOffset,
}
import biogba.arm_assembler { AsmState, Assembler, opcode_from_string }

/*
LDRSBH is not an actual opcode, it is a set of opcode, mainly:
- LDRH Loads an unsigned halfword
- LDRSB Loads a signed byte
- LDRSH Loads a signed halfword

Relationship with the "other" LDR opcode:
This set of opcode are of the same transfer opcode family.
LDR opcode handles unsigned words and bytes loads
while LDRSBH opcodes handle signed bytes and signed/unsigned half words

Some differences:
- The address portion is almost the same, except that these opcode don't
  support shift operands.
- There is no T in these opcodes
- The absolute offset is 8 bytes wide instead of 12

LDR Opcodes has the following format
LDR{cond}<H|SH|SB> Rd,<Address>

<Address> has multiple modes
- expression	which is an immediate expression. It will use R15(PC) as the base register. It can be a negative value
- [Rn]			Preindex with an offset of zero. Rn is the base register
- [Rn,<#{+/-}expression>]{!} Preindex with a signed expression and writeback
- [Rn,{+/-}Rm]{!} Preindex using signed register mode as offset which can be added a shift mode
- [Rn], exp			Post-index mode. exp can be the same as preindex but outside []

Examples:
LDRH R1,[R2,#-10]
LDRSB R1,[R2,R3]!
LDREQSH R1,[R2],R4

Note: The opcode always uses a register Rn as a base,
you cannot specify an absolute address explicitly. To
accomplish that, Rn must be zero.
*/

/*
Test LDRH most simple form

Load a half-word into R0 from address specified in R1
No writeback
Offset is 0
*/
fn test_assembler_ldrh_simple() {
	opcode_string := 'LDRH R0, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd: 0
		rn: 1
		p_bit: true
		u_bit: true
		w_bit: false
		s_bit: false
		h_bit: true
		address: u8(0)
	}

	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}