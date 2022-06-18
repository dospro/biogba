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

	assert result.r[0] == cpu_state.r[0]

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
	println(result)

	assert result.r[0xE] == cpu_state.r[0xE]
}