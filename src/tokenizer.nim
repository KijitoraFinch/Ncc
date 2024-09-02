import results
import strutils

type TokenType*{.pure.} = enum
    BinOp
    Integer
    OpenParen
    CloseParen
    Eof


type Token* = ref object
    tokenType*: TokenType
    literal*: string

func newToken(tokenType: TokenType, literal: string): Token = 
    result = Token(tokenType: tokenType, literal: literal)

type Tokenizer* = ref object
    code*: string
    pos*: int

func cur(t: Tokenizer):char = 
    if t.pos < t.code.len:
        return t.code[t.pos]
    else:
        return '\0'

proc initTokenizer*(code: string): Tokenizer = 
    result = Tokenizer(code:code, pos:0)

func peek(t: Tokenizer): char = 
    if t.pos+1 < t.code.len:
        return t.code[t.pos+1]
    else:
        return '\0'

proc readToken*(t: Tokenizer): Token = 
    # Skip WS
    while t.cur == ' ':
        t.pos += 1
    
    var lit: string

    if t.cur.isDigit:
        while t.cur.isDigit:
            lit.add(t.cur)
            t.pos += 1
        return newToken(TokenType.Integer, lit)

    if "+-*/".contains t.cur:
        lit = $t.cur
        t.pos += 1
        return newToken(TokenType.BinOp, lit)

    if t.cur == '(':
        lit = $t.cur
        t.pos += 1
        return newToken(TokenType.OpenParen, lit)

    if t.cur == ')':
        lit = $t.cur
        t.pos += 1
        return newToken(TokenType.CloseParen, lit)

    if t.cur == '\0':
        lit = $t.cur
        t.pos += 1
        return newToken(TokenType.Eof, lit)

    echo "Tokenizer: error at position: ", t.pos
    echo t.code
    echo " ".repeat t.pos, "^"
    quit 1

proc peekToken*(t: Tokenizer): Token = 
    let restore = t.pos
    let token = t.readToken()
    t.pos = restore
    return token


proc consume*(t: Tokenizer, expected_literal: string): (bool, Token) = 
    let restore = t.pos

    let token = t.readToken()

    if token.literal != expected_literal:
        t.pos = restore
        return (false, nil)

    else:
        return (true, token)
