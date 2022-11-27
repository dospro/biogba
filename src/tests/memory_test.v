import src.biogba
import src.tests.mocks

type CPUState = biogba.CPUState
type ARM7TDMI = biogba.ARM7TDMI




/*
Test read memory from offset 0
The test first sets a value at offset 0 and then reads it using
the read method
*/
fn test_read_from_offset_0() {
	mut memory := mocks.MemoryFake {}
	memory.set_values32(0x0, [u32(0x1234_1234)])
	mut cpu := ARM7TDMI{
		memory: memory
	}
	offset := u32(0)
	obtained := cpu.memory.read32(offset)
	assert obtained == 0x1234_1234
}