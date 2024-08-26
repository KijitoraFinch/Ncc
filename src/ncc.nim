import os
import strformat
import strutils
import sequtils
import nre
import results


type TokenType {.pure.} = enum
    BinOp
    Integer
    OpenParen
    CloseParen
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


type TokenResult = Result[Token, int]

proc getOne(t: Tokenizer): TokenResult = 

    # WSは飛ばす。proc eatWS(t: Tokenizer)とかに分割したほうがいいかp
    while t.cur == ' ':
        t.pos += 1

    if t.cur == '\0':
        return ok(Token(tokenType: TokenType.Eof, literal: "\0"))
    
    if t.cur.isDigit:
        var literal: string
        while t.cur.isDigit:
            literal.add t.cur
            t.pos += 1
        return ok(Token(tokenType: TokenType.Integer, literal: literal))
    
    if "+-*/".contains t.cur:
        let literal = $t.cur
        t.pos += 1
        return ok(Token(tokenType: TokenType.BinOp, literal: literal))

    if t.cur == '(':
        let literal = $t.cur
        t.pos += 1
        return ok(Token(tokenType: TokenType.OpenParen, literal: literal))


    if t.cur == ')':
        let literal = $t.cur
        t.pos += 1
        return ok(Token(tokenType: TokenType.CloseParen, literal: literal))
    else:
        return err(t.pos)


proc main() = 
    let code = "3 +    4* (2 - 1)"
    var tokenizer = initTokenizer(code)

    while true:
        let tokenResult = tokenizer.getOne()
        if tokenResult.isOk:
            echo "Token Type: ", tokenResult.value.tokenType
            echo "Literal: ", tokenResult.value.literal
            if tokenResult.value.tokenType == TokenType.Eof:
                break
        else:
            echo "Error at position: ", tokenizer.pos

main()