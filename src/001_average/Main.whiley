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
        sys.out.println_s("usage: average <file>")
    else:
        // first, read the input data
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        [real]|null data = Parser.parseReals(input)
        // second, run the benchmark
        if data == null:
            sys.out.println_s("error parsing input")
        else if |data| == 0:
            sys.out.println_s("no data provided!")
        else:
            real avg = average(data)
            sys.out.println(avg)    
