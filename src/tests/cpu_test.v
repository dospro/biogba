import biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ADCOpcode = biogba.ADCOpcode

fn test_adc_default() {
	mut cpu_state := CPUState {	}
	cpu_state.r[0] = 0

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{}.as_hex()
	cpu.execute_opcode(opcode)

	result := cpu.get_state()

	obtained := result.r[0]
	expected := cpu_state.r[0]
	assert obtained == expected

}

fn test_adc_with_rn() {
	mut cpu_state := CPUState {	}
	cpu_state.r[0xE] = 0x3030_7070
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rn: 0xE
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()

	obtained := result.r[0]
	expected := cpu_state.r[0xE]
	assert obtained == expected
}

fn test_adc_rd_rn() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xD] = 0x1234_1234
	cpu_state.r[0x7] = 0x4321_4321
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x7
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0xD]
	expected := cpu_state.r[0x7]
	assert obtained == expected
}

fn test_adc_with_c() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xD] = 0x1234_1234
	cpu_state.r[0x7] = 0x4321_4321
	cpu_state.cpsr.c = true
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x7
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0xD]
	expected := cpu_state.r[0x7] + 1
	assert obtained == expected
}

fn test_adc_immediate_simple() {
	mut cpu_state := CPUState {}
	cpu_state.r[0x1] = 0x0000_1000
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0x1
			rotate: 0x1
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0xD]
	expected := 0x4000_1000
	assert obtained == expected
}

fn test_adc_immediate() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xD] = 0x1234_1234
	cpu_state.r[0x7] = 0x4321_4321
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x7
		shift_operand: biogba.ShiftOperandImmediate {
			value: 0xF8
			rotate: 0xF
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0xD]
	expected := 0x4321_4321 + 0x3E0
	assert obtained == expected
}

fn test_adc_register_lsl_immediate() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_0001
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x1F
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := u32(result.r[0x2])
	expected := u32(0x9000_1000)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_lsl_register() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0001_0003
	cpu_state.r[0x4] = 0x0000_0002
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := 0x1000_1000 + (0x1_0003 << 2)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_lsr_immediate() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_000F
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: false
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x2
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := 0x1000_1000 + (0xF >> 2)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_lsr_register() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_00FF
	cpu_state.r[0x4] = 0x0000_0003
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := 0x1000_1000 + (0xFF >> 3)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_asr_immediate() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x8000_00F0
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := 0x1000_1000 + 0xF800_000F
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_asr_register() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0xFFF0_10FF
	cpu_state.r[0x4] = 0x0000_0010
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.asr
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := u32((0x1000_1000 + 0xFFFF_FFF0) & 0xFFFF_FFFF)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_ror_immediate() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x8000_0BF1
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0x8
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := u32((0x1000_1000 + 0xF180_000B) & 0xFFFF_FFFF)
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_ror_register() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_10FF
	cpu_state.r[0x4] = 0x0000_0010
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.ror
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.r[0x2]
	expected := 0x1000_1000 + 0x10FF_0000
	assert obtained == expected
	assert !result.cpsr.c
}

fn test_adc_register_lsl_with_carry() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x8000_0BF1
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0x1
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.cpsr.c
	expected := true
	assert obtained == expected
}

fn test_adc_register_lsr_with_carry() {
	mut cpu_state := CPUState {}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_00FF
	cpu_state.r[0x4] = 0x0000_0003
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister {
			rm: 0x3
			register_shift: true
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x4
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	obtained := result.cpsr.c
	expected := true
	assert obtained == expected
}