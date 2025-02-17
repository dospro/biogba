import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
Test MSR opcode loads CPSR from register R0

The test starts with CPSR flags Z and C set
and R0 with a value of 0
At the end Z and C flags should be zero
*/
fn test_msr_loads_cpsr() {
	mut cpu_state := CPUState{}
	cpu_state.r[0] = 0 // rm
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = true
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		shift_operand: u8(0x0)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.z == false
	assert result.cpsr.c == false
}

/*
Test MSR opcode loads CPSR from register R10

The test starts with CPSR flags Z and C set
and R0 with a value of 0
At the end Z and C flags should be zero
*/
fn test_msr_loads_cpsr_rm() {
	mut cpu_state := CPUState{}
	cpu_state.r[10] = 0 // rm
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = true
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		shift_operand: u8(10)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.z == false
	assert result.cpsr.c == false
}

/*
Test MSR opcode updates N and V flags

The test starts with CPSR flags unset
and R8 with a value of 0x9000_0000
which must set N and V flags un CPSR
*/
fn test_msr_loads_cpsr_sets_condition_flags() {
	mut cpu_state := CPUState{}
	cpu_state.r[8] = 0x9000_0000 // rm
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		shift_operand: u8(8)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.n == true
	assert result.cpsr.v == true
}

/*
Test MSR opcode in immediate mode

The test doesn't use a register, insted it uses an
immediate value of 0xF000_0000 which is built from a base
value of 0xF rotated 2x2 times right.

This sets all conditional flags in cpsr
*/
fn test_msr_immediate_mode() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.mode = biogba.CPUMode.user

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		shift_operand: biogba.ShiftOperandImmediate{
			value:  0xF
			rotate: 2
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.n == true
	assert result.cpsr.z == true
	assert result.cpsr.c == true
	assert result.cpsr.v == true
	assert result.cpsr.to_hex() == 0xF000_0010
}

/*
Test MSR opcode with p bit set

When p bit is set, we update SPSR instead of CPSR
That can't happen in user mode, so we start in IRQ mode.

We start with CPSR and SPSR set conditional flags set to zero
Using immediate mode we load a value to set C and V flags in SPSR
We validate also that CPSR is not changed

We also explicitly set c mask flag to false so mode is not modified
*/
fn test_msr_p_bit() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.mode = biogba.CPUMode.irq
	cpu_state.spsr_irq.mode = biogba.CPUMode.irq

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		p_bit:         true
		c_flag:        false
		shift_operand: biogba.ShiftOperandImmediate{
			value:  3
			rotate: 2
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.to_hex() == 0x0000_0012
	assert result.spsr_irq.to_hex() == 0x3000_0012
}

/*
Test MSR opcode with with full mask

By default, full mask is alwaya enabled, but in this test
we set it explicitly and then try to modify the mode and the interrupt flags

The test start in IRQ mode again, but with p bit unset, so changes will occur on cpsr
Using register mode, we change the mode to user user mode with all interrupts disabled
This means I and F are set and M is set to 0x10
*/
fn test_msr_full_mask() {
	mut cpu_state := CPUState{}
	cpu_state.r[14] = 0xF000_00D0
	cpu_state.cpsr.mode = biogba.CPUMode.irq

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		shift_operand: u8(14)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.to_hex() == 0xF000_00D0
}

/*
Test MSR opcode with control mask

The opcode tests the rare case where conditional flags
are protected but control flags are writable

The test changes the mode from FIQ to IRQ
Condition flags are not changed even if there is a value to set them
*/
fn test_msr_with_control_mask() {
	mut cpu_state := CPUState{}
	cpu_state.r[11] = 0xF000_0012
	cpu_state.cpsr.mode = biogba.CPUMode.fiq

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MSROpcode{
		f_flag:        false
		shift_operand: u8(11)
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.cpsr.to_hex() == 0x0000_0012
}
