import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

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
// Parser
// ========================================================

function parseReal(nat pos, string input) -> (real,int):
    //
    int start = pos
    while pos < |input| && (ASCII.isDigit(input[pos]) || input[pos] == '.'):
        pos = pos + 1
    //
    if pos == start:
        return 0.0,-1
    //
    return Real.parse(input[start..pos]),pos

function skipWhiteSpace(nat index, string input) -> nat:
    //
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    //
    return index

function isWhiteSpace(char c) -> bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// Main
// ========================================================

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: average <file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = String.fromASCII(file.readAll())
        int pos = 0
        [real] data = []
        pos = skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input| where pos >= 0:
            real r
            r,pos = parseReal(pos,input)
            if(pos < 0):
                sys.out.println("Syntax Error")
                break
            data = data ++ [r]
            pos = skipWhiteSpace(pos,input)
        // second, run the benchmark
        if |data| == 0:
            sys.out.println("no data provided!")
        else:
            real avg = average(data)
            sys.out.println(avg)    
