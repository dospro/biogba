import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test MRS opcode loads CPSR to register R0

The test starts with CPSR flags Z and C set
and user mode set which has a value of 0x6000_0010
*/
fn test_mrs_loads_cpsr() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rd
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = true
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MRSOpcode{
		rd: 0x0
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[0] == 0x6000_0010
}

/*
Test MRS opcode loads CPSR to nother register

The test starts with CPSR flags Z and C set
and user mode set which has a value of 0x6000_0010
This time the result is stored in R9
*/
fn test_mrs_with_different_rd() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rd
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = true
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MRSOpcode{
		rd: 0x9
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[9] == 0x6000_0010
}

/*
Test MRS opcode loads CPSR with different state

The test starts with CPSR flags N and V set as well as FIQ and IRQ disabled\
The mode is now IRQ
*/
fn test_mrs_with_different_cpsr() {
	mut cpu_state := CPUState{}
	cpu_state.r[4] = 0 // rd
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	cpu_state.cpsr.i = true
	cpu_state.cpsr.f = true
	cpu_state.cpsr.mode = biogba.CPUMode.irq

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MRSOpcode{
		rd: 0x4
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[4] == 0x9000_00D2
}

/*
Test MRS opcode loads SPSR from supervisor mode

The test starts with no flags set, but in supervisor mode
SPSR has C and V flag set
*/
fn test_mrs_with_spsr() {
	mut cpu_state := CPUState{}
	cpu_state.r[2] = 0 // rd
	cpu_state.cpsr.mode = biogba.CPUMode.supervisor

	cpu_state.spsr_supervisor.c = true
	cpu_state.spsr_supervisor.v = true
	cpu_state.spsr_supervisor.mode = biogba.CPUMode.supervisor

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MRSOpcode{
		rd:    0x2
		p_bit: true
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[2] == 0x3000_0013
}
