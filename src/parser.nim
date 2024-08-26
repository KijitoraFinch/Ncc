type NodeKind {.pure.} = enum
    Add
    Sub
    Mul
    Div
    Num

type Node = ref object
    kind: NodeKind
    lhs: Node
    rhs: Node
    val: int
# Nimって再帰的型定義できるんか

proc newNode(kind: NodeKind, lhs: Node, rhs: Node, val: int): Node = 
    result = Node(kind: kind, lhs: lhs, rhs: rhs, val: val)

proc newNumNode(val: int): Node =   
    result = Node(kind: NodeKind.Num, lhs: nil, rhs: nil, val: val)
