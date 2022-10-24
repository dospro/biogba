import src.biogba

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI

type ADCOpcode = biogba.ADCOpcode

fn test_adc_default() {
	mut cpu_state := CPUState{}
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
	mut cpu_state := CPUState{}
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
	mut cpu_state := CPUState{}
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
	mut cpu_state := CPUState{}
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
	mut cpu_state := CPUState{}
	cpu_state.r[0x1] = 0x0000_1000
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x1
		shift_operand: biogba.ShiftOperandImmediate{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xD] = 0x1234_1234
	cpu_state.r[0x7] = 0x4321_4321
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0xD
		rn: 0x7
		shift_operand: biogba.ShiftOperandImmediate{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_0001
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0001_0003
	cpu_state.r[0x4] = 0x0000_0002
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_000F
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_00FF
	cpu_state.r[0x4] = 0x0000_0003
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x8000_00F0
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0xFFF0_10FF
	cpu_state.r[0x4] = 0x0000_0010
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x8000_0BF1
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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
	mut cpu_state := CPUState{}
	cpu_state.r[0xE] = 0x1000_1000
	cpu_state.r[0x2] = 0x0001_0001
	cpu_state.r[0x3] = 0x0000_10FF
	cpu_state.r[0x4] = 0x0000_0010
	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)
	opcode := ADCOpcode{
		rd: 0x2
		rn: 0xE
		shift_operand: biogba.ShiftOperandRegister{
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

// Testing C flag cases

/*
When S bit is set, c flag is affected
The test will add 1 to a value of 3 rotated left once
This will shift a 1 into de carry bit resulting in a value of true
*/
fn test_adc_immediate_with_cflag_set() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0x3
			rotate: 0x1
		}
	}
	cpu.execute_opcode(opcode.as_hex())

	result := cpu.get_state()
	assert result.cpsr.c
}

/*
When rotation is 0 in immediate mode, c flag is unchanged
*/
fn test_adc_immediate_no_rot_c_unchanged() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.cpsr.c = true

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandImmediate{
			value: 0x3
			rotate: 0x0
		}
	}
	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.c
}

/*
When doing register mode with LSL c flag should be
set when s=1 and the last bit of the shift is 1
We set the rm msb to 1 so it can be shifted out into c
*/
fn test_adc_register_lsl_with_c_flag_set() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x8000_0000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.c
}

/*
When doing register mode with LSL c flag should be
not set when s=1 and the last bit of the shift is not 1
*/
fn test_adc_register_lsl_with_c_flag_reset() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x8000_0000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 0x2
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert !result.cpsr.c
}

/*
When doing register mode with LSR, c flag should be
set when s=1 and the last bit of the shift is 1
We set the rm lsb to 1 so it can be shifted out into c
*/
fn test_adc_register_lsr_with_cflag() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsr
			shift_value: 0x1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.c
}

/*
When doing register mode with ASR, c flag should be
set when s=1 and the last bit of the shift is 1
In this test we shift 13 times until the 1 is shifted out
*/
fn test_adc_register_asr_with_cflag() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x0000_1000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 13
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.c
}

/*
When doing register mode with ASR, c flag should be
set when s=1 and the last bit of the shift is 1
In this test we shift 5 times until the first 1 is shifted out
*/
fn test_adc_register_ror_with_cflag() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x0000_1010

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 5
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.c
}

// Corner cases

/*
In register immediate mode when we use LSR #0 it is interpreted as LSR #32
Rm will be 0 and c flag should have bit31 of Rm
In this test rm=0xFFFF_0000 will be shifted 32 bits right leaving it with a value 0
That is added to Rn which has 1 resulting in 1 as the final result in rd.
*/
fn test_adc_lsr32() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0xFFFF_0000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsr
			shift_value: 0
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.r[0] == 0x1
	assert result.cpsr.c
}

/*
In register immediate mode when we use ASR #0 it is interpreted as ASR #32
Rm and c flag will be filled with bit31 of Rm.
In this test rm=0x8000_0000 will be arithmetically shifted 32 bits right
leaving it with a value of 0xFFFF_FFFF.
That is added to Rn which has 1 resulting in 0 as the final result in rd.
*/
fn test_adc_asr32() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x8000_0000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 0
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.r[0] == 0x0
	assert result.cpsr.c
}

/*
In register immediate mode when we use ROR #0 it is interpreted as RXX
A rotate right including C occurs

This test verifies multiple things:
* First, that RXX works
* Also that c flag is added before being modified
* Finally that c flag is updated correctly

The test starts with c flag set so it is considered when doing the rotation.
rm=0x8000_0000 is rotated right leaving it at 0x4000_0000, but since c flag was
set, then that bit is moved to the msb resulting in 0xC000_0000.
Then it gets added to rn resulting in 0xC000_0001, but since the ADC opcode
also adds c flag we end up with 0xC000_0002.
At the end the c flag gets reset because the last shifted value was a 0
*/
fn test_adc_rxx() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x0000_0001
	cpu_state.r[0x2] = 0x8000_0000
	cpu_state.cpsr.c = true

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.ror
			shift_value: 0
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.r[0] == 0xC000_0002
	assert !result.cpsr.c
}

// Other flags

/*
Flag v is set when there is an overflow in bit 31
This means that whenever 2 operands have the same sign bit
the result should have the same sign bit
In this test we add 1 to 0x7FFF_FFFF which sets bit 31 of the result
So since both operands had bit 31 unset, the v flag gets set.
*/
fn test_adc_v_flag_set() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x7FFF_FFFF
	cpu_state.r[0x2] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.v
}

/*
Flag v is reset when there is no overflow in bit 31

In this test we add 1 to 0x8FFF_FF00 which results in
0x8FFF_FF01. Bit 31 remains as 1
*/

fn test_adc_v_flag_reset() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0x0000_0000
	cpu_state.r[0x1] = 0x8FFF_FF00
	cpu_state.r[0x2] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert !result.cpsr.v
}

/*
z flag is set when the result is 0
even if there was an overflow

In the test we add 1 to 0xFFFF_FFFF which results in 0
*/
fn test_adc_z_flag_set() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0xFFFF_FFFF
	cpu_state.r[0x1] = 0xFFFF_FFFF
	cpu_state.r[0x2] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 0
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.z
}

/*
z flag is reset if result is not 0
*/
fn test_adc_z_flag_reset() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0xFFFF_FFFF
	cpu_state.r[0x1] = 0x7FFF_FFFF
	cpu_state.r[0x2] = 0x0000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.lsl
			shift_value: 0
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert !result.cpsr.z
}

/*
n flag is set when the result bit 31 is set
*/
fn test_adc_n_flag_set() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0xFFFF_FFFF
	cpu_state.r[0x1] = 0x7FFF_FFFF
	cpu_state.r[0x2] = 0x1000_0001

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert result.cpsr.n
}

/*
n flag is reset when the result bit 31 is not set
*/
fn test_adc_n_flag_reset() {
	mut cpu_state := CPUState{}
	cpu_state.r[0x0] = 0xFFFF_FFFF
	cpu_state.r[0x1] = 0x7FFF_0000
	cpu_state.r[0x2] = 0x0000_1000

	mut cpu := ARM7TDMI{}
	cpu.set_state(cpu_state)

	mut opcode := ADCOpcode{
		rd: 0x0
		rn: 0x1
		s_bit: true
		shift_operand: biogba.ShiftOperandRegister{
			rm: 0x2
			register_shift: false
			shift_type: biogba.ShiftType.asr
			shift_value: 1
		}
	}

	cpu.execute_opcode(opcode.as_hex())
	result := cpu.get_state()
	assert !result.cpsr.n
}
