import parser
import os
//import repl

fn main() {
	println('Hello, this is the Monkey programming language implementation in V!')
/*
	mut typ := repl.Type.lexer
	if os.args.len > 0 {
		if '-parser' in os.args {
			typ = repl.Type.parser
		}
	}
	repl.start(typ)
*/
	if os.args.len > 1 {
		mut p:= parser.new_parser(os.args[1])
		p.parse_top_lvl()
	} else {
		println('USAGE: monkey_v <filename>')
	}
}
