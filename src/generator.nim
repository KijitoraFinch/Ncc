import parser
import print
import strutils

proc gen*(ast: Node) = 
    # genした結果のアセンブリは、計算結果をスタックに積むという制約

    if ast.kind == NodeKind.Num:
        echo("  push $1" % $ast.val)
        return;

    ast.lhs.gen()
    ast.rhs.gen()

    # 先程の制約によればlhs, rhsの計算結果はスタックに積まれているハズである
    echo "  pop rdi"
    echo "  pop rax"

    case ast.kind
    of NodeKind.Add:
        echo "  add rax, rdi"

    of NodeKind.Sub:
        echo "  sub rax, rdi"
    
    of NodeKind.Mul:
        echo "  imul rax, rdi"
    
    of NodeKind.Div:
        echo "  cqo"
        echo "  idiv rdi"
    
    else:
        echo "コード生成エラー： 右辺と左辺を持つノードにもかかわらず、演算ノードではありません"
        print ast
        quit 1

    echo "  push rax"