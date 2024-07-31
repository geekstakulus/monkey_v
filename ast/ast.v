module ast

import token
import strings

pub struct ErrorNode {}

pub type Node = LetStatement | ReturnStatement | ErrorNode

pub type Statement = FnStatement | LetStatement | ReturnStatement | ErrorNode

pub type Expression = ExpressionStatement | FnStatement | Identifier | IntegerExpression |
	StringExpression | ErrorNode

pub struct Program {
pub:
	statements []Statement
}

pub fn (p Program) str() string {
	mut sb := strings.new_builder(32)
	for s in p.statements {
		// sb.write(s.str())
		match s {
			LetStatement { sb.write_string(s.str()) }
			else {}
		}
	}
	return sb.str()
}

pub fn (p Program) token_literals() string {
	if p.statements.len > 0 {
		return p.statements[0].token_literal()
	}
	return ''
}

pub struct Identifier {
pub:
	token token.Token
	value string
}

pub fn (ident Identifier) expression_node() {
}

pub fn (stmt Statement) token_literal() string {
	match stmt {
		LetStatement {
			return stmt.token_literal()
		}
		else {
			return ''
		}
	}
}

pub struct LetStatement {
pub:
	token     token.Token
	name      Identifier
	has_value bool
	value     Expression
}

pub fn (ls LetStatement) str() string {
	mut sb := strings.new_builder(32)
	sb.write_string(ls.token_literal() + ' ')
	sb.write_string(ls.name.str())
	sb.write_string(' = ')
	/*
	if ls.value is FnStatement | Identifier | IntegerExpression | StringExpression | ExpressionStatement
		sb.write(ls.value)
	}
	*/
	sb.write_string(';')
	return sb.str()
}

pub fn (ls LetStatement) token_literal() string {
	return ls.name.token.literal
}

pub struct StringExpression {
pub:
	value string
}

pub struct IntegerExpression {
pub:
	value string
}

pub struct ReturnStatement {
pub:
	token        token.Token // the `return` token
	return_value Expression
}

pub fn (rs ReturnStatement) token_literal() string {
	return rs.token.literal
}

pub struct FnStatement {
pub:
	token     token.Token
	anonym    bool
	name      Identifier
	parameter []Identifier
	stmts     []Statement
}

pub struct ExpressionStatement {
pub:
	token      token.Token
	expression Expression
}

pub fn (expstmt ExpressionStatement) token_literal() string {
	return expstmt.token.literal
}
