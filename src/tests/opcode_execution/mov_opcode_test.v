import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

/*
The MOV opcode is a Dataprocessing Opcode
which is already tested.
The following tests only very behavior specific to
the MOV opcode and not the data processing features.
*/


/*
Test MOV opcode loads a value into a register

Note: For MOV opcode, Rn is ignored. The operation is:
Rd = 0xFF ROR 4 (rotate right)
*/
fn test_mov() {
	mut cpu_state := CPUState{}
	cpu_state.r[3] = 0 // rd
	cpu_state.r[5] = 0x0101_FFFF // rn (ignored)

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MOVOpcode{
		rd: 0x3
		rn: 0x5
		shift_operand: biogba.ShiftOperandImmediate {
			rotate: 2
			value: 0xFF
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()

	assert result.r[3] == 0xF000_000F
}

/*
Test MOV opcode when Rd=15 and S=true
This is an edge case. R15 is updated but also
CPSR is updated with SPSR of the current mode.

Documentation says it should never occur in user mode
but at the end we will have CPSR<-CPSR so only R15 will
be updated.

The test will first start in supervisor mode
with specific CPSR and then the MOVS R15, #10
should copy spsr into cpsr
*/
fn test_mov_r15_s_edge_case() {
	mut cpu_state := CPUState{}
	spsr := biogba.PSR{
		mode: biogba.CPUMode.system
		i: false
		f: false
		t: false
		c: true
		v: false
		z: true
		n: false
	}
	cpu_state.spsr_supervisor = spsr
	cpu_state.cpsr.mode = biogba.CPUMode.supervisor
	cpu_state.r[15] = 0

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := biogba.MOVOpcode{
		rd: 15
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			rotate: 2
			value: 0xFF
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr == spsr
	assert result.r[15] == 0xF000_000F
}
