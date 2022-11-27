module biogba

interface MemoryInterface {
	read32(offset u32) u32
}

pub struct Memory {
mut:
	memory [100]u8 = [100]u8{}
}

fn (self Memory) read32(offset u32) u32 {
	return (u32(self.memory[offset]) << 24) | 
	(u32(self.memory[offset + 1]) << 16) | 
	(u32(self.memory[offset + 2]) << 8) | 
	u32(self.memory[offset + 3])
}