module mocks

pub struct MemoryFake {
mut:
	memory [100]u8 = [100]u8{}
}

pub fn (mut self MemoryFake) set_value8(offset u32, value u8) {
	if offset >= 100 {
		panic("Offset is above 100 for the test")
	}
	self.memory[offset] = value
}

pub fn (mut self MemoryFake) set_values32(offset u32, values []u32) {
	for i in 0 .. values.len {
		for j := 3; j >=0; j -= 1 {
			byte_value := u8(values[i] >> (j * 8))
			address := offset + u32(4 * i) + (3 - u32(j))
			self.memory[address] = byte_value
		}
	}
}

pub fn (self MemoryFake) read32(offset u32) u32 {
	return (u32(self.memory[offset]) << 24) | 
	(u32(self.memory[offset + 1]) << 16) | 
	(u32(self.memory[offset + 2]) << 8) | 
	u32(self.memory[offset + 3])
}