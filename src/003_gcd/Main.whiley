import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

type nat is (int x) where x >= 0

function parseInt(nat pos, string input) -> (nat,nat)
throws SyntaxError:
    //
    int start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",start,pos)
    int r = Math.abs(Int.parse(input[start..pos]))
    return r,pos

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
        string input = String.fromASCII(file.readAll())
        try:
            int pos = 0
            [int] data = []
            pos = skipWhiteSpace(pos,input)
            // first, read data
            while pos < |input| where all { d in data | d >= 0 } && pos >= 0:
                int i
                i,pos = parseInt(pos,input)
                data = data ++ [i]
                pos = skipWhiteSpace(pos,input)
            // second, compute gcds
            for i in 0..|data|:
                for j in i+1..|data|:
                    sys.out.println(gcd(data[i],data[j]))
        catch(SyntaxError e):
            sys.out.println("error - " ++ e.msg)

