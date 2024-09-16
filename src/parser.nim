import tokenizer

import strutils
import options

type NodeKind* {.pure.} = enum
    Assign
    Add
    Sub
    Mul
    Div
    Eq
    Ne
    Lt
    Le
    Ident
    Num

type Node* = ref object
    kind*: NodeKind
    lhs*: Node
    rhs*: Node
    val*: int
    offset*: int
# Nimって再帰的型定義できるんか

proc newNode(kind: NodeKind, lhs: Node, rhs: Node): Node = 
    result = Node(kind: kind, lhs: lhs, rhs: rhs)

proc newNumNode(val: int): Node =   
    result = Node(kind: NodeKind.Num, val: val)

proc newLvarNode(offset: int): Node =
    result = Node(kind:NodeKind.Ident, lhs:nil, rhs: nil, offset: offset)

type Parser = ref object
    tokenizer: Tokenizer

proc initParser*(tokenizer: Tokenizer): Parser = 
    result = Parser(tokenizer: tokenizer)


# 前方宣言
proc stmt*(p: Parser): Node # stmt = expr ";"
proc expr*(p: Parser): Node
proc assign*(p: Parser): Node
proc equality*(p: Parser): Node
proc relational*(p: Parser): Node
proc add*(p: Parser): Node
proc mul*(p: Parser): Node
proc unary*(p: Parser): Node
proc primary*(p: Parser): Node

proc program*(p:Parser): seq[Node] =
    let t = p.tokenizer
    var program = newSeq[Node]()
    while not t.consume($'\0')[0]:
        program.add(p.stmt())
    return program
    
        

proc stmt*(p: Parser): Node = 
    result = p.expr()
    if not(let res = p.tokenizer.consume(";"); res[0]):
        echo "Expected ';', but got=", res[1].literal
        echo p.tokenizer.code
        echo " ".repeat p.tokenizer.pos, "^"
        quit 1

proc expr*(p: Parser): Node = 
    return p.assign()

proc assign*(p: Parser): Node = 
    let t = p.tokenizer
    var node = p.equality
    while true:
        if(let res = t.consume("="); res[0]):
            node = newNode(NodeKind.Assign, node, p.assign())
        else:
            return node

proc equality*(p: Parser): Node = 
    let t = p.tokenizer
    var node = p.relational()
    while true:
        if(let res = t.consume("=="); res[0]):
            node = newNode(NodeKind.Eq, node, p.relational())
        elif(let res = t.consume("!="); res[0]):
            node = newNode(NodeKind.Ne, node, p.relational())
        else:
            return node

proc relational*(p: Parser): Node =
    let t = p.tokenizer
    var node  = p.add()
    while true:
        if(let res = t.consume("<"); res[0]):
            node = newNode(NodeKind.Lt, node, p.add())
        elif(let res = t.consume("<="); res[0]):
            node = newNode(NodeKind.Le, node, p.add())
        elif(let res = t.consume(">"); res[0]):
            node = newNode(NodeKind.Lt, p.add(), node)
        elif(let res = t.consume(">="); res[0]):
            node = newNode(NodeKind.Le, p.add(), node)
        else:
            return node

proc add*(p: Parser): Node =
    let t = p.tokenizer
    var node = p.mul()
    while true:
        if(let res = t.consume("+"); res[0]):
            node = newNode(NodeKind.Add, node, p.mul())
        elif(let res = t.consume("-"); res[0]):
            node = newNode(NodeKind.Sub, node, p.mul())
        else:
            return node


proc mul*(p: Parser): Node = 
    let t = p.tokenizer
    var node: Node = p.unary()
    while true:
        if(let res = t.consume("*"); res[0]):
            node = newNode(NodeKind.Mul, node, p.unary())
        elif(let res = t.consume("/"); res[0]):
            node = newNode(NodeKind.Div, node, p.unary())
        else:
            return node


proc unary*(p: Parser): Node = 
    let t = p.tokenizer
    if(let res = t.consume("+"); res[0]):
        return p.primary()
    elif(let res = t.consume("-"); res[0]):
        return newNode(NodeKind.Sub, newNumNode(0), p.unary())
    # どちらにもマッチしない→通常のprimary
    else:
        return p.primary()


proc primary*(p: Parser): Node =
    let t = p.tokenizer
    var node: Node
    if(let res = t.consume("("); res[0]):
        node = p.expr()
        let isClosed = t.consume(")")[0]
        
        if not isClosed:
            echo "Parentheses are not closed"
            echo t.code
            echo " ".repeat t.pos, "^"
            quit 1
        
        return node

    else:
        let token = t.readToken()
        if token.tokenType == TokenType.Integer:
            return newNumNode(parseInt(token.literal))
        
        elif token.tokenType == TokenType.Ident:
            
            return newLvarNode((token.literal[0].int()-'a'.int()+1 )*8)

        else:
            echo "Unexpected token: expect=Integer, got=", token.tokenType
            echo t.code
            echo " ".repeat t.pos, "^"
            quit 1

