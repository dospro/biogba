module biogba

pub enum OpcodeCondition {
	eq
	ne
	cs
	cc
	mi
	pl
	vs
	vc
	hi
	ls
	ge
	lt
	gt
	le
	al
}

fn OpcodeCondition.from_u32(value u32) ?OpcodeCondition {
	return match value {
		0 {.eq}
		1 {.ne}
		2 {.cs}
		3 {.cc}
		4 {.mi}
		5 {.pl}
		6 {.vs}
		7 {.vc}
		8 {.hi}
		9 {.ls}
		0xA {.ge}
		0xB {.lt}
		0xC {.gt}
		0xD {.le}
		0xE {.al}
		else {
			error('Unknown opcode condition for value $value')
		}
	}
}

// Parses a string into a OpcodeCondition
fn OpcodeCondition.from_string(condition_string string) ?OpcodeCondition {
	return match condition_string.to_lower() {
		'eq' { OpcodeCondition.eq }
		'ne' { OpcodeCondition.ne }
		'cs' { OpcodeCondition.cs }
		'cc' { OpcodeCondition.cc }
		'mi' { OpcodeCondition.mi }
		'pl' { OpcodeCondition.pl }
		'vs' { OpcodeCondition.vs }
		'vc' { OpcodeCondition.vc }
		'hi' { OpcodeCondition.hi }
		'ls' { OpcodeCondition.ls }
		'ge' { OpcodeCondition.ge }
		'lt' { OpcodeCondition.lt }
		'gt' { OpcodeCondition.gt }
		'le' { OpcodeCondition.le }
		'al' { OpcodeCondition.al }
		else { none }
	}
}