module biogba

pub interface MemoryInterface {
	read8(offset u32) u8
	read16(offset u32) u16
	read32(offset u32) u32
mut:
	write32(offset u32, value u32)
}

pub struct Memory {
mut:
	memory [100]u8 = [100]u8{}
}

pub fn (self Memory) read8(offset u32) u8 {
	return self.memory[offset]
}

pub fn (self Memory) read16(offset u32) u16 {
	return (u16(self.memory[offset]) << 8) | u16(self.memory[offset + 1])
}

pub fn (self Memory) read32(offset u32) u32 {
	return (u32(self.memory[offset]) << 24) | (u32(self.memory[offset + 1]) << 16) | (u32(self.memory[
		offset + 2]) << 8) | u32(self.memory[offset + 3])
}

pub fn (mut self Memory) write32(offset u32, value u32) {
	self.memory[offset] = u8(value & 0xFF)
	self.memory[offset + 1] = u8((value >> 8) & 0xFF)
	self.memory[offset + 2] = u8((value >> 16) & 0xFF)
	self.memory[offset + 3] = u8((value >> 24) & 0xFF)
}
