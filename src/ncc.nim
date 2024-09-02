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
    let node = expr(parser)

    echo asm_boilerplate

    node.gen()
    
    echo "  pop rax"
    echo "  ret"
    # スタックの一番上をpopしてretする

main()
