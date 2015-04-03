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
        sys.out.println_s("usage: gcd <input-file>")
    else:
        // First, parse input
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        [int]|null data = Parser.parseInts(input)
        // Second, compute gcds
        if data == null:
            sys.out.println_s("error parsing input")
        else:
            int i = 0
            while i < |data|:
                int j = i+1
                while j < |data|:
                    sys.out.println(gcd(data[i],data[j]))
                    j = j + 1
                i = i + 1
            //

