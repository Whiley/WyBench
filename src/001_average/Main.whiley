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

function average(int[] data) -> int
// Input list cannot be empty
requires |data| > 0:
    //
    int sum = 0
    int i = 0
    while i < |data|:
        sum = sum + data[i]
        i = i + 1
    return sum / |data|

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
        int[]|null data = Parser.parseInts(input)
        // second, run the benchmark
        if data == null:
            sys.out.println_s("error parsing input")
        else if |data| == 0:
            sys.out.println_s("no data provided!")
        else:
            int avg = average(data)
            sys.out.println(avg)    
