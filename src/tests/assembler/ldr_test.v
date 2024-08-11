import biogba {
	LDROpcode,
}
import biogba.arm_assembler { opcode_from_string }

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

Note: The opcode always uses a register Rn as a base,
you cannot specify an absolute address explicitly. To
accomplish that, Rn must be zero.
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

	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Important Note:
For parsing this type of opcodes (including STR), the automata ends up with
a combination of the following tokens:
- condition
- B
- T
- register
where the first 3 may be optional.

So we have the following combinations:
1. condition-register
2. condition-b-register
3. condition-t-register
4. condition-b-t-register
5. register
6. b-register
7. t-register
8. b-t-register

*/

/*
Test LDR opcode with a condition
*/
fn test_assembler_ldr_condition() {
	opcode_string := 'LDRLE R1, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.le
		rd: 1
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

/*
Test LDR opcode for byte transfer LDRB with condition
*/
fn test_assembler_ldr_condition_byte() {
	opcode_string := 'LDREQB R2, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.eq
		rd: 2
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: true
		w_bit: false
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRT opcode with condition

When T is present in the opcode (LDRT), post index is set p_bit=0
and writeback is set w_bit=1.

This mode is used for special non-privileged access memoery management.
*/
fn test_assembler_ldrt_with_condition() {
	opcode_string := 'LDRPLT R3, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.pl
		rd: 3
		rn: 1
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: true
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRBT opcode with condition
*/
fn test_assembler_ldrbt_with_condition() {
	opcode_string := 'LDRCCBT R4, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.cc
		rd: 4
		rn: 1
		p_bit: false
		u_bit: true
		b_bit: true
		w_bit: true
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

// Combinations with no condition

/*
Test LDR with Rd

The test used a different value for Rd
*/
fn test_assembler_ldr_rd() {
	opcode_string := 'LDR R5, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		rd: 5
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

/*
Test LDR opcode for byte transfer LDRB without condition
*/
fn test_assembler_ldr_byte_without_condition() {
	opcode_string := 'LDRB R6, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 6
		rn: 1
		p_bit: true
		u_bit: true
		b_bit: true
		w_bit: false
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDR opcode with T for non-privileged mode
*/
fn test_assembler_ldr_memory_management_mode() {
	opcode_string := 'LDRT R7, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 7
		rn: 1
		p_bit: false
		u_bit: true
		b_bit: false
		w_bit: true
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

/*
Test LDRBT opcode without condition
*/
fn test_assembler_ldrbt_without_condition() {
	opcode_string := 'LDRBT R9, [R1]'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 9
		rn: 1
		p_bit: false
		u_bit: true
		b_bit: true
		w_bit: true
		address: u16(0)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}

// From now on lets focus on the address part

/*
Test Address as an absolute expression

Note: The assembler will attempt to generate an instruction
using the PC as a base and a corrected immediate offset to
address the location given by evaluating the expression.
This will be a PC relative, pre-indexed address. If the address
is out of range, an error will be generated.

Important notes when using absolute address:
- The assemlber will try to generate address using R15 as a base.
So first it will calculate address - R15

- Taking in consideration the prefetch piepline, R15 is 8 bytes already ahead
So we need to revert those 8 bytes.
offset = address - (R15 - 8)
offset = address - R15 + 8

---
TODO:
This set of tests only test for individual opcode execution. No context is considered.
To be able to test the behavior with the prefetch pipeline we need to test it
with a defined CPU state.

*/
fn test_assembler_absolute_address() {
	opcode_string := 'LDR R5, #10'

	opcode := opcode_from_string(opcode_string) or { panic(err) }
	expected_opcode := LDROpcode{
		condition: biogba.OpcodeCondition.al
		rd: 5
		rn: 15
		p_bit: true
		u_bit: true
		b_bit: false
		w_bit: false
		address: u16(0x10)
	}
	assert opcode is LDROpcode
	if opcode is LDROpcode {
		assert opcode == expected_opcode
	}
}
