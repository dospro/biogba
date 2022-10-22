import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ADCOpcode = biogba.ADCOpcode

/*
This set of tests will excersise the conditional bits.

We just run an adc opcode which will result in rd being 0 if the
opcode is skipped or something different than 0 if the opcode gets
executed.

The conditional function will do the actual opcode execution and asserts

In each test case we just set the right flags to either execute or skip de opcode.

*/

fn conditional(original_cpu_state CPUState, conditional biogba.OpcodeCondition, skipped bool) {
	mut cpu_state := original_cpu_state
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0xF0F0_F0F0
	cpu_state.r[0x2] = 0x0000_1000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := ADCOpcode{
		condition: conditional
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate {value: 1, rotate: 1}
	}
	cpu.execute_opcode(opcode.as_hex())
	if skipped {
		assert cpu.get_state().r[0] == 0
	} else {
		assert cpu.get_state().r[0] != 0
	}
}

/*
Equal
Runs opcode when z is set
*/
fn test_adc_eq_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.z = false
	conditional(cpu_state, biogba.OpcodeCondition.eq, true)
	cpu_state.cpsr.z = true
	conditional(cpu_state, biogba.OpcodeCondition.eq, false)
}

/*
Not equal
Runs opcode when z is not set
*/
fn test_adc_ne_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.z = true
	conditional(cpu_state, biogba.OpcodeCondition.ne, true)
	cpu_state.cpsr.z = false
	conditional(cpu_state, biogba.OpcodeCondition.ne, false)
}

/*
Carry set
Runs opcode when c is set
*/
fn test_adc_cs_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.c = false
	conditional(cpu_state, biogba.OpcodeCondition.cs, true)
	cpu_state.cpsr.c = true
	conditional(cpu_state, biogba.OpcodeCondition.cs, false)
}

/*
Carry clear
Runs opcode when c is not set
*/
fn test_adc_cc_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.c = true
	conditional(cpu_state, biogba.OpcodeCondition.cc, true)
	cpu_state.cpsr.c = false
	conditional(cpu_state, biogba.OpcodeCondition.cc, false)
}

/*
Minus or negative
Runs opcode when n is set
*/
fn test_adc_mi_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.n = false
	conditional(cpu_state, biogba.OpcodeCondition.mi, true)
	cpu_state.cpsr.n = true
	conditional(cpu_state, biogba.OpcodeCondition.mi, false)
}

/*
Plus or positive
Runs opcode when n is not set
*/
fn test_adc_pl_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.n = true
	conditional(cpu_state, biogba.OpcodeCondition.pl, true)
	cpu_state.cpsr.n = false
	conditional(cpu_state, biogba.OpcodeCondition.pl, false)
}

/*
Overflow
Runs opcode when v is set
*/
fn test_adc_vs_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.vs, true)
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.vs, false)
}

/*
No Overflow
Runs opcode when v is not set
*/
fn test_adc_vc_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.vc, true)
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.vc, false)
}

/*
Unsigned higher
Runs opcode when c is set and z is not set
*/
fn test_adc_hi_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.c = false
	cpu_state.cpsr.z = true
	conditional(cpu_state, biogba.OpcodeCondition.hi, true)
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = false
	conditional(cpu_state, biogba.OpcodeCondition.hi, false)
}

/*
Unsigned lower or same
Runs opcode when c is not set or z is set
c=0 or z=1
=> 
not (c=0 and z=1)
*/
fn test_adc_ls_condition() {
	mut cpu_state := CPUState{}
	// Run when c=0 && z=0
	cpu_state.cpsr.c = false
	cpu_state.cpsr.z = false
	conditional(cpu_state, biogba.OpcodeCondition.ls, false)

	// Run when c=0 && z=1
	cpu_state.cpsr.c = false
	cpu_state.cpsr.z = true
	conditional(cpu_state, biogba.OpcodeCondition.ls, false)

	// Run when c=1 && z=1
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = true
	conditional(cpu_state, biogba.OpcodeCondition.ls, false)

	// Skip when c=1 && z=0
	cpu_state.cpsr.c = true
	cpu_state.cpsr.z = false
	conditional(cpu_state, biogba.OpcodeCondition.ls, true)
}

/*
Signed greater than or equal
Runs opcode when n=v
*/
fn test_adc_ge_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.ge, false)

	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.ge, false)

	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.ge, true)

	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.ge, true)
}

/*
Signed less than
Runs opcode when n!=v
*/
fn test_adc_lt_condition() {
	mut cpu_state := CPUState{}
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.lt, true)

	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.lt, true)

	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.lt, false)

	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.lt, false)
}

/*
Signed greater than
Runs opcode when z=0 and n=v
*/
fn test_adc_gt_condition() {
	mut cpu_state := CPUState{}

	// Run opcode cases
	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.gt, false)

	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.gt, false)

	// Skip opcode cases
	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)

	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.gt, true)
}

/*
Signed less than or equal
Runs opcode when z=1 or n!=v
*/
fn test_adc_le_condition() {
	mut cpu_state := CPUState{}

	// Run opcode cases
	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	cpu_state.cpsr.z = true
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.le, false)

	// Skips ipcode cases
	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = false
	cpu_state.cpsr.v = false
	conditional(cpu_state, biogba.OpcodeCondition.le, true)

	cpu_state.cpsr.z = false
	cpu_state.cpsr.n = true
	cpu_state.cpsr.v = true
	conditional(cpu_state, biogba.OpcodeCondition.le, true)
}

/*
Always
Opcode always runs
*/
fn test_adc_al_condition() {
	mut cpu_state := CPUState{}
	for i in 0 .. 0xF {
		cpu_state.cpsr.z = (i & 1) != 0
		cpu_state.cpsr.c = (i & 2) != 0
		cpu_state.cpsr.n = (i & 4) != 0
		cpu_state.cpsr.v = (i & 8) != 0
		conditional(cpu_state, biogba.OpcodeCondition.al, false)
	}
}