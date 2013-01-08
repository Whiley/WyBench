import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

define nat as int where $ >= 0

// ========================================================
// Benchmark
// ========================================================

define Matrix as {
    int width,
    int height,
    [[int]] data
} where |data| == height && no { i in data | |i| != width }

Matrix Matrix(nat width, nat height, [[int]] data) 
    requires |data| == height && no { i in data | |i| != width },
    ensures $.width == width && $.height == height && $.data == data:
    //
    return {
        width: width,
        height: height,
        data: data
    }

Matrix run(Matrix A, Matrix B) requires A.width == B.height,
    ensures $.width == B.width && $.height == A.height:
    //
    C_data = []
    for i in 0 .. A.height:
        row = []
        for j in 0 .. B.width:
            r = 0
            for k in 0 .. A.width:
                r = r + (A.data[i][k] * B.data[k][j])
            row = row + [r]
        C_data = C_data + [row]
    //
    return Matrix(B.width,A.height,C_data)

// ========================================================
// Parser
// ========================================================

(Matrix,Matrix) parseFile(string input) throws SyntaxError:
    data,pos = parseLine(2,0,input)    
    nrows = data[0]
    ncols = data[1]
    pos = skipBreak(pos,input)
    A,pos = parseMatrix(nrows,ncols,pos,input)
    pos = skipBreak(pos,input)
    B,pos = parseMatrix(nrows,ncols,pos,input)
    return A,B

(Matrix,int) parseMatrix(nat height, nat width, int pos, string input) throws SyntaxError:    
    rows = []
    for i in 0 .. height:
        row,pos = parseLine(width,pos,input)
        rows = rows + [row]
    return Matrix(width,height,rows),pos
        
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
    // check for negative input
    if pos < |input| && input[pos] == '-': 
        pos = pos + 1
    // match remainder
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    // check for error
    if pos == start:
        throw SyntaxError("Missing number",start,pos)
    // done
    return Int.parse(input[start..pos]),pos

int skipBreak(int index, string input):
    while index < |input| && input[index] == '-':
        index = index + 1
    return skipWhiteSpace(index,input)

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\r' || c == '\n'

// ========================================================
// Main
// ========================================================

void ::printMat(System.Console sys, Matrix A):
    for i in 0 .. A.height:
        for j in 0 .. A.width:
            sys.out.print(A.data[i][j])
            sys.out.print(" ")
        sys.out.println("")

void ::main(System.Console sys):
    file = File.Reader(sys.args[0])
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
