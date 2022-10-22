import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ADDOpcode = biogba.ADDOpcode

fn test_immediate_simple() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x1] = 0x0000_1000
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0xD
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0x1
			rotate: 0x1
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 0x4000_0000
}

fn test_immediate_complex() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xD] = 0x1234_1234
	cpu_state.r[0x7] = 0x4321_4321
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0xD
		rn: 0x7
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0xF8
			rotate: 0xF
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 0x3E0
}

/*
In register mode using LSL shift_operand will take Rm and do a left shift
by shift_value.

The tests shifts left 1F times the value at R3 which is 1 resulting in 0x8000_0000
*/
fn test_register_lsl_immediate() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_0001
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x3
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x1F
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 0x8000_0000
}

/*
In register-register mode using LSL shift_operand will take Rm and do a right shift
by the value in R4.

The test shifts left 2 times (the value of r4) the value at R3 which is 0x1_0003 resulting in 0x4_000C
*/
fn test_register_lsl_register() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0001_0003
	cpu_state.r[0x4] = 0x0000_0002
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x4
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 0x4_000C
}

/*
In register-immediate mode using LSR, shift_operand will take Rm and do a right shift
by shift_value.

The tests shifts right 2 times the value at R3 which is 0xF resulting in 3
*/
fn test_register_lsr_immediate() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_000F
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x3
			register_shift: false
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x2
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 3
}

/*
In register-register mode using LSR, shift_operand will take Rm and do a right shift
by the value at R4.

The tests shifts right 3 times the value at R3 which is 0xFF resulting in 0x1F
*/
fn test_register_lsr_register() {
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_00FF
	cpu_state.r[0x4] = 0x0000_0003
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADDOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x4
		}
	}
	shift_operand_value := cpu.get_shift_operand_value(opcode.as_hex())
	assert shift_operand_value == 0x1F
}
