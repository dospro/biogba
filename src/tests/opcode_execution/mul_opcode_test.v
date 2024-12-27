import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
MUL and MLA opcodes performas a 32bit multiplication
The general form is:
Rd = (Rm * Rs) + Rn

When the MUL opcode is used, no addition is performed so Rn is ignored
When S bit is used (MLAS or MULS):
- N flag is set to bit 31
- Z flag is set if the result is zero
- C flag is set to a random value (destroyed)
*/

/*
Test MUL opcode multiplies 2 values
Rs = 0xFFFF_FFF6
Rm = 0x0000_0014

Rd must be 0xFFFF_FF38
*/
fn test_mul() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rd
	cpu_state.r[1] = 0xFFFF_FFF6 // rs
	cpu_state.r[2] = 0x0000_0014 // rm

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULOpcode{
		rm: 2
		rs: 1
		rd: 0
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0xFFFF_FF38
}

/*
Test MLA opcode multiplies 2 values and adds Rn to the result
Rs = 0x100
Rm = 0x200
Rn = 0x1000

Rd must be 0x2_1000
*/
fn test_mla() {
	mut cpu_state := CPUState{}
	cpu_state.r[14] = 0 // rd
	cpu_state.r[8] = 0x100 // rs
	cpu_state.r[5] = 0x200 // rm
	cpu_state.r[3] = 0x1000 // rn

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULOpcode{
		rn:    3
		rm:    5
		rs:    8
		rd:    14
		a_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[14] == 0x2_1000
}

/*
Test MUL opcode sets N flag

S-Flag is set for CSPR to be updated

The multiplication will result in bit 31 set
so n flag will also be set.
*/
fn test_mul_updated_n_flag() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rd
	cpu_state.r[1] = 0x8_0000 // rs
	cpu_state.r[2] = 0x1000 // rm

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULOpcode{
		rd:    0
		rs:    1
		rm:    2
		s_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x8000_0000
	assert cpu.cpsr.n
}

/*
Test MUL opcode sets Z flag

S-Flag is set for CSPR to be updated

The multiplication will result in zero, so 
z flag will be set.
*/
fn test_mul_updated_z_flag() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rd
	cpu_state.r[1] = 0 // rs
	cpu_state.r[2] = 0x1000 // rm

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULOpcode{
		rd:    0
		rs:    1
		rm:    2
		s_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0
	assert cpu.cpsr.z
}

/* 
Test MUL special cases
- Rd must not be the same as Rm
- R15 must not be used
TODO: I will not test this cases right now.
When this cases happens it is not clear what should happen.
On the assembler, checks are put in place to avoid this cases.
*/