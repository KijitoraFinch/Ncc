import tokenizer

import strutils
import options

type NodeKind* {.pure.} = enum
    Add
    Sub
    Mul
    Div
    Num

type Node* = ref object
    kind*: NodeKind
    lhs*: Node
    rhs*: Node
    val*: int
# Nimって再帰的型定義できるんか

proc newNode(kind: NodeKind, lhs: Node, rhs: Node): Node = 
    result = Node(kind: kind, lhs: lhs, rhs: rhs, val: 0)

proc newNumNode(val: int): Node =   
    result = Node(kind: NodeKind.Num, lhs: nil, rhs: nil, val: val)

type Parser = ref object
    tokenizer: Tokenizer

proc initParser*(tokenizer: Tokenizer): Parser = 
    result = Parser(tokenizer: tokenizer)


# 前方宣言
proc mul*(p: Parser): Node
proc primary*(p: Parser): Node
proc expr*(p: Parser): Node


proc expr*(p: Parser): Node = 
    let t = p.tokenizer
    var node: Node = p.mul()
    while true:
        if(let res = t.consume("+"); res[0]):
            node = newNode(NodeKind.Add, node, p.mul())
        elif (let res = t.consume("-"); res[0]):
            node = newNode(NodeKind.Sub, node, p.mul)
        else:
            return node

proc mul*(p: Parser): Node = 
    let t = p.tokenizer
    var node: Node = p.primary()
    while true:
        if(let res = t.consume("*"); res[0]):
            node = newNode(NodeKind.Mul, node, p.primary)
        elif(let res = t.consume("/"); res[0]):
            node = newNode(NodeKind.Div, node, p.primary)
        else:
            return node

proc primary*(p: Parser): Node =
    let t = p.tokenizer
    var node: Node
    if(let res = t.consume("("); res[0]):
        node = p.expr()
        let isClosed = t.consume(")")[0]
        
        if not isClosed:
            echo "Paren is not closed"
            echo t.code
            echo " ".repeat t.pos, "^"
            quit 1
        
        return node

    else:
        let token = t.readToken()
        if token.tokenType == TokenType.Integer:
            return newNumNode(parseInt(token.literal))
        else:
            echo "Unexpected token: expect=Integer, got=", token.tokenType
            echo t.code
            echo " ".repeat t.pos, "^"
            quit 1
