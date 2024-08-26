import strutils
import results

include tokenizer
include parser

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