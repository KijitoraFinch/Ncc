import os
import strformat
import strutils
import sequtils
import nre

type TokenType {.pure.} = enum
    BinOp
    Integer
    Eof


type Token = ref object
    tokenType: TokenType
    literal: string


type Tokenizer = ref object
    code: string
    pos: int

func cur(t: Tokenizer):char = 
    if t.pos < t.code.len:
        return t.code[t.pos]
    else:
        return '\0'

proc initTokenizer(code: string): Tokenizer = 
    result = Tokenizer(code:code, pos:0)

func peek(t: Tokenizer): char = 
    if t.pos+1 < t.code.len:
        return t.code[t.pos+1]
    else:
        return '\0'


proc getOne(t: Tokenizer): Token = 

    # WSは飛ばす。proc eatWS(t: Tokenizer)とかに分割したほうがいいかp
    while t.cur == ' ':
        t.pos += 1

    if t.cur == '\0':
        return Token(tokenType: TokenType.Eof, literal: "\0")
    
    if t.cur.isDigit:
        var literal: string
        while t.cur.isDigit:
            literal.add t.cur
            t.pos += 1
        return Token(tokenType: TokenType.Integer, literal: literal)
    
    if "+-*/".contains t.cur:
        var literal: string
        literal.add t.cur
        t.pos += 1
        return Token(tokenType: TokenType.BinOp, literal: literal)

let tokenizer  = initTokenizer("10  + 200 / 4000 * 100 - 30")
