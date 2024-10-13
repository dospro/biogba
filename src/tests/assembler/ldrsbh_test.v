import biogba {
	LDRSBHOpcode,
	Register,
}
import biogba.arm_assembler { AsmState, Assembler }

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
- The address portion is almost the same, except that these opcodes don't
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

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        0
		rn:        1
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0)
	}

	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDREQH which is the same as LDRH but with the condiciont EQ
*/
fn test_assembler_ldrh_with_condition() {
	opcode_string := 'LDREQH R0, [R1]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.eq
		rd:        0
		rn:        1
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDR with signed halfword LDRSH
*/
fn test_assembler_ldrsh() {
	opcode_string := 'LDRSH R0, [R1]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        0
		rn:        1
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     true
		h_bit:     true
		address:   u8(0)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDR with signed byte LDRSB
*/
fn test_assembler_ldrsb() {
	opcode_string := 'LDRCCSB R0, [R1]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.cc
		rd:        0
		rn:        1
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     true
		h_bit:     false
		address:   u8(0)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRH with Rd
*/
fn test_assembler_ldrsh_rd() {
	opcode_string := 'LDRSH R4, [R1]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }
	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        4
		rn:        1
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     true
		h_bit:     true
		address:   u8(0)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRH Opcode with immediate address.

The test takes into account the state of PC, in this case 0x20
then it adds 8 bytes for the fetching pipeline resulting in 0x28
Finally the distance between offset 0x28 and 0x100 is 0xD8
*/
fn test_assembler_absolute_address() {
	opcode_string := 'LDRH R5, #100'

	assembler := Assembler{
		state: AsmState{
			r15: 0x20
		}
	}

	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        5
		rn:        15
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0xD8)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDR Opcode with immediate address outside limit.

LDR Opcode only has 8 bits for absolute address (256)
The test will try an offset larger than 255. It also considers the
fetch pipeline. So the address can go up to 255+8 = 0x107

To test the whole calculation, the test takes 0x20 as the base.
In this case, having a value greater than 0x107+0x20 should fail the assembly
*/
fn test_assembler_absolute_address_limit() {
	opcode_string := 'LDRSH R5, #128'

	assembler := Assembler{
		state: AsmState{
			r15: 0x20
		}
	}

	opcode := assembler.parse_opcode(opcode_string) or { return }
	assert false
}

/*
Test LDRH Opcode with Rn as base and offset 0.
*/
fn test_assembler_ldrsbh_preindex() {
	opcode_string := 'LDRSB R5, [R14]'

	assembler := Assembler{}

	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        5
		rn:        14
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     true
		h_bit:     false
		address:   u8(0)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode that uses Rn as the base address with a positive offset
*/
fn test_assembler_ldrh_preindex_with_offset() {
	opcode_string := 'LDRH R6, [R7, #0F]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        6
		rn:        7
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0xF)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode that uses Rn as the base address with a negative sign
*/
fn test_assembler_ldrh_preindex_with_negative_offset() {
	opcode_string := 'LDREQSH R11, [R10, #-30]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.eq
		rd:        11
		rn:        10
		p_bit:     true
		u_bit:     false
		w_bit:     false
		s_bit:     true
		h_bit:     true
		address:   u8(0x30)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode with preindex and writeback
*/
fn test_assembler_ldrh_preindex_with_writeback() {
	opcode_string := 'LDRSH R11, [R10, #FF]!'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        11
		rn:        10
		p_bit:     true
		u_bit:     true
		w_bit:     true
		s_bit:     true
		h_bit:     true
		address:   u8(0xFF)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode with register offset Rm
*/
fn test_assembler_ldrh_preindex_with_rm() {
	opcode_string := 'LDRSB R1, [R3, R5]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        3
		p_bit:     true
		u_bit:     true
		w_bit:     false
		s_bit:     true
		h_bit:     false
		address:   Register.r5
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode with register negative offset Rm
*/
fn test_assembler_ldrh_preindex_with_negative_rm() {
	opcode_string := 'LDRH R1, [R3, -R12]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        3
		p_bit:     true
		u_bit:     false
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   Register.r12
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH fails when used with shift operands
*/
fn test_assembler_ldrh_no_shifts() {
	opcode_string := 'LDRH R1, [R2, R3, LSL#1]'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { return }
	assert false
}

/*
Test LDRSBH Opcode post-index with expression
*/
fn test_assembler_ldrh_postindex_with_expression() {
	opcode_string := 'LDRH R1, [R4], #10'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        4
		p_bit:     false
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0x10)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode post-index with negative expression
*/
fn test_assembler_ldrh_postindex_with_negative_expression() {
	opcode_string := 'LDRH R1, [R4], #-20'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        4
		p_bit:     false
		u_bit:     false
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   u8(0x20)
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode post-index with register offset Rm
*/
fn test_assembler_ldrh_postindex_with_register_offset() {
	opcode_string := 'LDRH R1, [R2], R3'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        2
		p_bit:     false
		u_bit:     true
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   Register.r3
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH Opcode post-index with negative register offset Rm
*/
fn test_assembler_ldrh_postindex_with_negative_register_offset() {
	opcode_string := 'LDRH R1, [R2], -R3'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { panic(err) }

	expected_opcode := LDRSBHOpcode{
		condition: biogba.OpcodeCondition.al
		rd:        1
		rn:        2
		p_bit:     false
		u_bit:     false
		w_bit:     false
		s_bit:     false
		h_bit:     true
		address:   Register.r3
	}
	assert opcode is LDRSBHOpcode
	if opcode is LDRSBHOpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRSBH fails when used with shift operands in postindex
*/
fn test_assembler_ldrh_postindex_no_shifts() {
	opcode_string := 'LDRH R1, [R2], R3, ROR#2'

	assembler := Assembler{}
	opcode := assembler.parse_opcode(opcode_string) or { return }
	assert false
}