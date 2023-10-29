module arm_assembler

struct Queue[T] {
	elements []T
mut:
	index int
}

fn Queue.from_array[T](elements []T) Queue[T] {
	return Queue[T]{
		elements: elements.clone()
		index: 0
	}
}

fn (self Queue[T]) peek() T {
	return self.elements[self.index]
}

fn (mut self Queue[T]) dequeue() T {
	defer {
		self.index += 1
	}
	return self.elements[self.index]
}

fn (self Queue[T]) len() int {
	return self.elements.len
}

fn (self Queue[T]) elements_left() int {
	return self.elements.len - self.index
}
