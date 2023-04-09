import src.biogba
import src.tests.mocks


/*
Test read word from memory offset 0
The test first sets a value at offset 0 and then reads it using
the read method
*/
fn test_read32_from_offset_0() {
	mut memory := mocks.MemoryFake {}
	memory.set_values32(0x0, [u32(0x1234_1234)])
	mut cpu := biogba.ARM7TDMI{
		memory: memory
	}
	offset := u32(0)
	obtained := cpu.memory.read32(offset)
	assert obtained == 0x1234_1234
}

/*
Test read byte from memory

The test starts with a word preloaded in memory
and then reads a byte at address 3

Note: Since memory is in little endian format
values are stored in reversed order and because
reading a single byte has no endianess, then
the value returned may seem off.
*/
fn test_read8() {
	mut memory := mocks.MemoryFake {}
	memory.set_values32(0, [u32(0x1234_4321)])
	mut cpu := biogba.ARM7TDMI{
		memory: memory
	}
	offset := u8(0x3)
	obtained := cpu.memory.read8(offset)
	assert obtained == 0x12
}