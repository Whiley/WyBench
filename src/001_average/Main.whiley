import whiley.lang.*
import whiley.lang.System
import whiley.io.File
import wybench.Parser

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII
import nat from whiley.lang.Int

// ========================================================
// Benchmark
// ========================================================

function average([real] data) -> real
// Input list cannot be empty
requires |data| > 0:
    //
    real sum = 0.0
    for r in data:
        sum = sum + r
    return sum / (real) |data|

// ========================================================
// Main
// ========================================================

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: average <file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        int pos = 0
        [real] data = []
        pos = Parser.skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input| where pos >= 0:
            real|null r
            r,pos = Parser.parseReal(pos,input)
            if(r is null):
                sys.out.println("Syntax Error")
                break
            else:
                data = data ++ [r]
                pos = Parser.skipWhiteSpace(pos,input)
        // second, run the benchmark
        if |data| == 0:
            sys.out.println("no data provided!")
        else:
            real avg = average(data)
            sys.out.println(avg)    
