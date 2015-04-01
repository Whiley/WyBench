import whiley.lang.System
import whiley.io.File
import wybench.Parser

import string from whiley.lang.ASCII

type nat is (int x) where x >= 0

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
        pos = Parser.skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input| where all { d in data | d >= 0 } && pos >= 0:
            int|null i
            i,pos = Parser.parseInt(pos,input)
            if(i is null):
                sys.out.println("Syntax Error")
            else:
                data = data ++ [i]
                pos = Parser.skipWhiteSpace(pos,input)
        // second, compute gcds
        for i in 0..|data|:
            for j in i+1..|data|:
                sys.out.println(gcd(data[i],data[j]))

