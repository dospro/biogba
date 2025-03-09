import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
MULL and MLAL opcodes performas a 64bit multiplication
The general form is:
RdHi:RdLo = (Rm * Rs) for MULL
RdHi:RdLo += (Rm * Rs) for MLAL


When S bit is used (MLALS or MULLS):
- N flag is set to bit 31
- Z flag is set if the result is zero
- C flag is set to a random value (destroyed)
*/

/*
Test UMULL opcode multiplies 2  32 bits values
and results in a 64 bits value
RdHi = 1
RdLo = 2
Rm = 0x1000_000F
Rs = 0x0200_0002

Result is 0x20_0000_3E00_001E which splits like this:
RdHi = 0x0020_0000
RdLo = 0x3E00_001E

*/
fn test_umull() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // rdhi
	cpu_state.r[2] = 0 // rdlo
	cpu_state.r[3] = 0x1000_000F // rm
	cpu_state.r[4] = 0x0200_0002 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   4
		rdhi: 1
		rdlo: 2
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x0020_0000
	assert result.r[2] == 0x3E00_001E
	assert !result.cpsr.z
	assert !result.cpsr.n
}

/*
Test UMULL opcode uses different RdLo register
RdHi = 1
RdLo = 8
Rm = 0x1000_1234
Rs = 0x0200_0002

Result is 0x20_0024_8800_2468 which splits like this:
RdHi = 0x0020_0024
RdLo = 0x8800_2468
*/
fn test_umull_rdlo() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // rdhi
	cpu_state.r[8] = 0 // rdlo
	cpu_state.r[3] = 0x1000_1234 // rm
	cpu_state.r[4] = 0x0200_0002 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   4
		rdhi: 1
		rdlo: 8
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x0020_0024
	assert result.r[8] == 0x8800_2468
}

/*
Test UMULL opcode uses different RdHi register
RdHi = 7
RdLo = 5
Rm[3] = 0x1000_1234
Rs[13] = 0x0200_0002

Result is 0x20_0024_8800_2468 which splits like this:
RdHi = 0x0020_0024
RdLo = 0x8800_2468
*/
fn test_umull_rdhi() {
	mut cpu_state := CPUState{}
	cpu_state.r[7] = 0 // rdhi
	cpu_state.r[5] = 0 // rdlo
	cpu_state.r[3] = 0x1000_1234 // rm
	cpu_state.r[13] = 0x0200_0002 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   13
		rdhi: 7
		rdlo: 5
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[7] == 0x0020_0024
	assert result.r[5] == 0x8800_2468
}

/*
Test UMULL opcode uses different rs register
RdHi = 1
RdLo = 2
Rm[3] = 0x1000_1234
Rs[13] = 0x0200_0002

Result is 0x20_0024_8800_2468 which splits like this:
RdHi = 0x0020_0024
RdLo = 0x8800_2468
*/
fn test_umull_rs() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // rdhi
	cpu_state.r[2] = 0 // rdlo
	cpu_state.r[3] = 0x1000_1234 // rm
	cpu_state.r[13] = 0x0200_0002 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   13
		rdhi: 1
		rdlo: 2
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x0020_0024
	assert result.r[2] == 0x8800_2468
}

/*
Test UMULL opcode uses different rm register
RdHi = 1
RdLo = 2
Rm[9] = 0x1000_1234
Rs[5] = 0x0200_0002

Result is 0x20_0024_8800_2468 which splits like this:
RdHi = 0x0020_0024
RdLo = 0x8800_2468
*/
fn test_umull_rm() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // rdhi
	cpu_state.r[2] = 0 // rdlo
	cpu_state.r[9] = 0x1000_1234 // rm
	cpu_state.r[5] = 0x0200_0002 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   9
		rs:   5
		rdhi: 1
		rdlo: 2
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x0020_0024
	assert result.r[2] == 0x8800_2468
}

/*
Test SMULL opcode multiplies 2 signed 32 bits values
and results in a signed 64 bits value
RdHi = 3
RdLo = 4
Rm[1] = 0x0001_4444
Rs[2] = -0x0000_0002

Result is ffff_ffff_fffd_7778 which splits like this:
RdHi = 0xFFFF_FFFF
RdLo = 0xFFFD_7778

*/
fn test_smull() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rdhi
	cpu_state.r[4] = 0 // rdlo
	cpu_state.r[1] = 0x0001_4444 // rm
	cpu_state.r[2] = u32(-2) // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   1
		rs:   2
		rdhi: 3
		rdlo: 4
		u_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0xFFFF_FFFF
	assert result.r[4] == 0xFFFD_7778
}

/*
Test SMULL opcode multiplies for 2 simple negative numbers
RdHi = 3
RdLo = 4
Rm[1] = -2 (0xF...F_FFFE)
Rs[2] = -3 (0xF...F_FFFD)

Result is 6 which splits like this:
RdHi = 0
RdLo = 6

*/
fn test_smull_two_negatives() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rdhi
	cpu_state.r[4] = 0 // rdlo
	cpu_state.r[1] = u32(-2) // rm
	cpu_state.r[2] = u32(-3) // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   1
		rs:   2
		rdhi: 3
		rdlo: 4
		u_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0
	assert result.r[4] == 6
}

/*
Test UMLAL opcode which adds to current Rd
RdHi[1] = 0x1000
RdLo[2] = 0x2000
Rm[9] = 0x1000_1234
Rs[5] = 0x0300_0003

Result is 0x30_1036_CC00_569C which splits like this:
RdHi = 0x0030_1036
RdLo = 0xCC00_569C
*/
fn test_umlal() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0x1000 // rdhi
	cpu_state.r[2] = 0x2000 // rdlo
	cpu_state.r[9] = 0x1000_1234 // rm
	cpu_state.r[5] = 0x0300_0003 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   9
		rs:   5
		rdhi: 1
		rdlo: 2
		a_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x0030_1036
	assert result.r[2] == 0xCC00_569C
}

/*
Test SMLAL opcode which adds to current Rd the result
of a signed multiplication
RdHi[1] = 0x1000
RdLo[2] = 0x2000
Rm[3] = 0x10
Rs[4] = -0x5

Result is 0x1000_0000_1FB0 which splits like this:
RdHi = 0x1000
RdLo = 0x1FB0
*/
fn test_smlal() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0x1000 // rdhi
	cpu_state.r[2] = 0x2000 // rdlo
	cpu_state.r[3] = 0x10 // rm
	cpu_state.r[4] = -0x5 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   4
		rdhi: 1
		rdlo: 2
		a_bit: true
		u_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0x1000
	assert result.r[2] == 0x1FB0
}

/*
Test UMULL opcode updates Z flag

RdHi = 1
RdLo = 2
Rm = 0xFFFF_0000
Rs = 0

Result is 0 which sets z flag

*/
fn test_umull_z_flag() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0 // rdhi
	cpu_state.r[2] = 0 // rdlo
	cpu_state.r[3] = 0xFFFF_0000 // rm
	cpu_state.r[4] = 0 // rs
	cpu_state.cpsr.z = false

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   4
		rdhi: 1
		rdlo: 2
		s_bit : true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.z
}

/*
Test SMLAL opcode sets N flag when result is negative
of a signed multiplication
RdHi[1] = 0x1000
RdLo[2] = 0x2000
Rm[3] = 0x1000_0000
Rs[4] = -0x5_0000

Result is 0xFFFF_C000_0000_2000 which is negative
*/
fn test_smlal_n_flag() {
	mut cpu_state := CPUState{}
	cpu_state.r[1] = 0x1000 // rdhi
	cpu_state.r[2] = 0x2000 // rdlo
	cpu_state.r[3] = 0x1000_0000 // rm
	cpu_state.r[4] = -0x5_0000 // rs

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := biogba.MULLOpcode{
		rm:   3
		rs:   4
		rdhi: 1
		rdlo: 2
		a_bit: true
		u_bit: true
		s_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[1] == 0xFFFF_C000
	assert result.r[2] == 0x2000
	assert result.cpsr.n
}