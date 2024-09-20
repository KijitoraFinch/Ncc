import strutils
import results
import print
import tokenizer
import parser
import generator
import os

const asm_boilerplate = """
.intel_syntax noprefix
.globl main
main:
"""

proc main() = 
    if paramCount() < 1:
        stderr.writeLine("引数が不足しています")
        quit(1)

    let code = paramStr(1)

    var tokenizer = initTokenizer(code)


    while true:
        let token = readToken(tokenizer)
        if token.tokenType == TokenType.Eof:
            break
        stderr.writeLine token.literal
    tokenizer.pos = 0
    let parser = initParser(tokenizer)
    let nodes = parser.program()

    echo asm_boilerplate
    # プロローグ
    echo "  push rbp"
    echo "  mov rbp, rsp"
    echo "  sub rsp, $1" % $parser.locals.offset

    for node in nodes:
        node.gen()
        echo "  pop rax"

    echo "  mov rsp, rbp"
    echo "  pop rbp"
    echo "  ret"

main()
