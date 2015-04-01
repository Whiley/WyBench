import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

type nat is (int x) where x >= 0

function parseInt(nat pos, string input) -> (null|int,nat):
    //
    int start = pos
    while pos < |input| && ASCII.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        return null,pos
    return Int.parse(input[start..pos]), pos

function skipWhiteSpace(nat pos, string input) -> nat:
    //
    while pos < |input| && isWhiteSpace(input[pos]):
        pos = pos + 1
    //
    return pos

function gcd(nat a, nat b) -> nat:
    if(a == 0):
        return b		   
    while(b != 0) where a >= 0:
        if(a > b):
            a = a - b
        else:
            b = b - a
    return a

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: gcd <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        int pos = 0
        [int] data = []
        pos = skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input| where all { d in data | d >= 0 } && pos >= 0:
            int|null i
            i,pos = parseInt(pos,input)
            if(i is null):
                sys.out.println("Syntax Error")
            else:
                data = data ++ [i]
                pos = skipWhiteSpace(pos,input)
        // second, compute gcds
        for i in 0..|data|:
            for j in i+1..|data|:
                sys.out.println(gcd(data[i],data[j]))

