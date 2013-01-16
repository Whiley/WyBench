import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

import nat from whiley.lang.Int

// ========================================================
// Benchmark
// ========================================================

real average([real] data) requires |data| > 0:
    sum = 0.0
    for r in data:
        sum = sum + r
    return sum / |data|

// ========================================================
// Parser
// ========================================================

(real,nat) parseReal(nat pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && (Char.isDigit(input[pos]) || input[pos] == '.') where pos >= 0:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Real.parse(input[start..pos]),pos

nat skipWhiteSpace(nat index, string input):
    while index < |input| && isWhiteSpace(input[index]) where index >= 0:
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// Main
// ========================================================

void ::main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: average <file>")
    else:
        try:
            file = File.Reader(sys.args[0])
            input = String.fromASCII(file.read())
            pos = 0
            data = []
            pos = skipWhiteSpace(pos,input)
            // first, read data
            while pos < |input| where pos >= 0:
                i,pos = parseReal(pos,input)
                data = data + [i]
                pos = skipWhiteSpace(pos,input)
            // second, run the benchmark
            if |data| == 0:
                sys.out.println("no data provided!")
            else:
                avg = average(data)
                sys.out.println(avg)    
        catch(SyntaxError e):
            sys.out.println("syntax error")
