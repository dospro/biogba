module mocks

import encoding.binary {little_endian_u32_at, little_endian_put_u32_at}

pub struct MemoryFake {
mut:
	memory []u8 = []u8{len: 0x2000}
}

pub fn (mut self MemoryFake) set_value8(offset u32, value u8) {
	if offset >= 100 {
		panic("Offset is above 100 for the test")
	}
	self.memory[offset] = value
}

pub fn (mut self MemoryFake) set_values32(offset u32, values []u32) {
	self.set_values_32_le(offset, values)
}

pub fn (mut self MemoryFake) set_values_32_le(offset u32, values []u32) {
	// for i in 0 .. values.len {
	// 	self.memory[offset] = u8(values[i] & 0xFF)
	// 	self.memory[offset + 1] = u8((values[i] >> 8) & 0xFF)
	// 	self.memory[offset + 2] = u8((values[i] >> 16) & 0xFF)
	// 	self.memory[offset + 3] = u8((values[i] >> 24) & 0xFF)
	// 	println("Writing value ${values[i]:X} at ${offset:X} which is stored as ${self.memory[offset..4].hex()}")
	// }
	for i in 0 .. values.len {
		// println("Writing value ${values[i]:X} at ${int(offset + (i * 4)):X}")
		little_endian_put_u32_at(mut &self.memory, values[i], int(offset + (i * 4)))
	}
}

pub fn (mut self MemoryFake) set_values_32_be(offset u32, values []u32) {
	for i in 0 .. values.len {
		for j := 3; j >=0; j -= 1 {
			byte_value := u8(values[i] >> (j * 8))
			address := offset + u32(4 * i) + (3 - u32(j))
			self.memory[address] = byte_value
		}
	}
}

pub fn (self MemoryFake) read8(offset u32) u8 {
	return self.memory[offset]
}

pub fn (self MemoryFake) read32(offset u32) u32 {
	// return (u32(self.memory[offset + 3]) << 24) | 
	// (u32(self.memory[offset + 2]) << 16) | 
	// (u32(self.memory[offset + 1]) << 8) | 
	// u32(self.memory[offset])
	return little_endian_u32_at(self.memory, int(offset))
}