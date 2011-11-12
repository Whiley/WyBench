import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

// ========================================================
// Benchmark
// ========================================================

define Matrix as [[int]]

Matrix run(Matrix A, Matrix B):
    C = []
    for i in 0 .. |A|:
        row = []
        for j in 0 .. |B|:
            r = 0
            for k in 0 .. |A|:
                r = r + (A[j][k] * B[k][i])
            row = row + [r]
        C = C + [row]
    return C

// ========================================================
// Parser
// ========================================================

(Matrix,Matrix) parseFile(string input) throws SyntaxError:
    data,pos = parseLine(2,0,input)    
    nrows = data[0]
    ncols = data[1]
    A,pos = parseMatrix(nrows,ncols,pos,input)
    B,pos = parseMatrix(nrows,ncols,pos,input)
    return A,B

(Matrix,int) parseMatrix(int nrows, int ncols, int pos, string input) throws SyntaxError:    
    rows = []
    for i in 0..nrows:
        row,pos = parseLine(ncols,pos,input)
        rows = rows + [row]
    return rows,pos
        
([int],int) parseLine(int count, int pos, string input) throws SyntaxError:
    pos = skipWhiteSpace(pos,input)
    ints = []
    while pos < |input| && |ints| != count:       
        i,pos = parseInt(pos,input)
        ints = ints + [i]
        pos = skipWhiteSpace(pos,input)
    if |ints| != count:  
        throw SyntaxError("invalid input file",pos,pos)
    return ints,pos

(int,int) parseInt(int pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",start,pos)
    return String.toInt(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '-'

// ========================================================
// Main
// ========================================================

void ::printMat(System sys, Matrix A):
    for i in 0 .. |A|:
        row = A[i]
        for j in 0 .. |row|:
            sys.out.print(row[j])
            sys.out.print(" ")
        sys.out.println("")

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    // first, read data
    input = String.fromASCII(file.read())
    try:
        // second, build the matrices    
        A,B = parseFile(input)
        // third, run the benchmark
        C = run(A,B)    
        // finally, print the result!
        printMat(sys,C)
    catch(SyntaxError e):
        sys.out.println("error - " + e.msg)
