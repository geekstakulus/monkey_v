module parser

import token
import lexer
import os
import ast

struct Parser {
	filename  string
mut:
	lexer     lexer.Lexer
	cur_token token.Token
	idx_token int
}

pub fn new_parser(filename string) &Parser {
	text := os.read_file(filename) or {
		panic(err)
	}
	return &Parser{
		filename: filename
		lexer: lexer.new(text)
	}
}

pub fn new_repl_p(line string) &Parser {
	return &Parser{
		filename: 'REPL'
		lexer: lexer.new(line)
	}
}

pub fn (mut p Parser) parse_top_lvl() ast.Program {
	p.next()
	mut program := []ast.Statement{}
	for p.cur_token.typ != token.eof {
		program << p.top_lvl_stmt()
		p.next()
	}
	return ast.Program{program}
}

pub fn (mut p Parser) parse_stmt() ast.Program {
	p.next()
	mut program := []ast.Statement{}
	for p.cur_token.typ != token.eof {
		program << p.stmt()
		p.next()
	}
	return ast.Program{program}
}

fn (mut p Parser) top_lvl_stmt() ast.Statement {
	stmt_token := p.cur_token
	match p.cur_token.typ {
		token.key_let { return p.let(stmt_token) }
		token.key_function { return p.function(stmt_token, false) }
		else { 
			p.error('Token $p.cur_token.typ is not a top level statement.') 
			return ast.ErrorNode{}
		}
	}
}

fn (mut p Parser) stmt() ast.Statement {
	stmt_token := p.cur_token
	match p.cur_token.typ {
		token.key_return {
			p.next()
			value := p.expression()
			p.next()
			p.expect(token.semicolon)
			return ast.ReturnStatement{
				token: stmt_token
				return_value: value
			}
		}
		token.key_let {
			return p.let(stmt_token)
		}
		else {
			p.error('Token $p.cur_token.typ is not a statement')
			return ast.ErrorNode{}
		}
	}
}

fn (mut p Parser) expression() ast.Expression {
	match p.cur_token.typ {
		token.int_t { return ast.IntegerExpression{p.cur_token.literal} }
		token.ident { return ast.Identifier{p.cur_token, p.cur_token.literal} }
		token.key_function { return p.function(p.cur_token, true) }
		else { 
			p.error('Unknown $p.cur_token.typ expression') 
			return ast.ErrorNode{}
		}
	}
}

fn (mut p Parser) function(stmt_token token.Token, anonym bool) ast.FnStatement {
	p.next()
	mut name := ast.Identifier{}
	if !anonym {
		p.expect(token.ident)
		name = ast.Identifier{p.cur_token, p.cur_token.literal}
		p.next()
	}
	p.expect(token.l_paren)
	p.next()
	mut parameter := []ast.Identifier{}
	if p.cur_token.typ != token.r_paren {
		for {
			p.expect(token.ident)
			parameter << ast.Identifier{p.cur_token, p.cur_token.literal}
			p.next()
			if p.cur_token.typ == token.r_paren {
				break
			}
			p.expect(token.colon)
			p.next()
		}
	}
	p.next()
	stmts := p.block()
	return ast.FnStatement{
		token: stmt_token
		anonym: anonym
		name: name
		parameter: parameter
		stmts: stmts
	}
}

fn (mut p Parser) let(stmt_token token.Token) ast.LetStatement {
	p.next()
	p.expect(token.ident)
	name := ast.Identifier{p.cur_token, p.cur_token.literal}
	p.next()
	if p.cur_token.typ == token.assign {
		p.next()
		value := p.expression()
		p.next()
		p.expect(token.semicolon)
		return ast.LetStatement{
			token: stmt_token
			name: name
			has_value: true
			value: value
		}
	}
	p.expect(token.semicolon)
	return ast.LetStatement{
		token: stmt_token
		name: name
		has_value: false
	}
}

fn (mut p Parser) block() []ast.Statement {
	mut statements := []ast.Statement{}
	p.expect(token.l_brace)
	p.next()
	for p.cur_token.typ != token.r_brace {
		statements << p.stmt()
		p.next()
	}
	p.expect(token.r_brace)
	return statements
}

fn (mut p Parser) expect(typ string) {
	if p.cur_token.typ != typ {
		p.error('Unexpected token. Expected $typ but got $p.cur_token.typ')
	}
}

fn (mut p Parser) next() {
	p.cur_token = p.lexer.next_token()
	p.idx_token++
}

fn (mut p Parser) error(msg string) {
	eprintln(msg)
	exit(1)
}
