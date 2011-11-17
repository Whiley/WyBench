import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

// ========================================================
// Benchmark
// ========================================================

real average([real] data):
    sum = 0.0
    for r in data:
        sum = sum + r
    return sum / |data|

// ========================================================
// Parser
// ========================================================

(real,int) parseReal(int pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && (Char.isDigit(input[pos]) || input[pos] == '.'):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return String.toReal(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// Main
// ========================================================

void ::main(System sys, [string] args):
    try:
        file = File.Reader(args[0])
        input = String.fromASCII(file.read())
        pos = 0
        data = []
        pos = skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input|:
            i,pos = parseReal(pos,input)
            data = data + [i]
            pos = skipWhiteSpace(pos,input)
        // second, run the benchmark
        avg = average(data)
        sys.out.println(avg)    
    catch(SyntaxError e):
        sys.out.println("syntax error")
