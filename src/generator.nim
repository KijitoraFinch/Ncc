import parser
import print
import strutils


{.experimental: "codeReordering".}
proc gen*(ast: Node) =
    # genした結果のアセンブリは、計算結果をスタックに積むという制約

    case ast.kind
    of NodeKind.Num:
        echo("  push $1" % $ast.val)
        return

    of NodeKind.Ident:
        ast.genLval()
        echo "  pop rax"
        # raxの指しているアドレスをraxに入れる
        echo "  mov rax, [rax]"
        echo "  push rax"
        return
    
    of NodeKind.Assign:
        ast.lhs.genLval()
        ast.rhs.gen()
        echo "  pop rdi"
        echo "  pop rax"
        echo "  mov [rax], rdi"
        echo "  push rdi"
        return

    of NodeKind.Return:
        ast.lhs.gen()
        echo "  pop rax"
        echo "  mov rsp, rbp"
        echo "  pop rbp"
        echo "  ret"
        return

    else:

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

        of NodeKind.Eq:
            echo "  cmp rax, rdi"
            echo "  sete al"
            echo "  movzb rax, al"
        
        of NodeKind.Ne: 
            echo "  cmp rax, rdi"
            echo "  setne al"
            echo "  movzb rax, al"

        of NodeKind.Le:
            echo "  cmp rax, rdi"
            echo "  setle al"
            echo "  movzb rax, al"

        of NodeKind.Lt:
            echo "  cmp rax, rdi"
            echo "  setl al"
            echo "  movzb rax, al"


        else:
            echo "Codegen error: argument is not a operator nevertheless it has lhs and rhs"
            print ast
            quit 1

        echo "  push rax"


proc genLval(node: Node) = 
    if node.kind != NodeKind.Ident:
        echo "Codegen error: not a lvalue"
        print node
        quit 1
    # ベースレジスタ(rbp)の値をraxにもってきて、左辺の変数のアドレスを計算してスタックにpushする
    echo "  mov rax, rbp"
    echo "  sub rax, $1" % $node.offset
    echo "  push rax"

    
    
