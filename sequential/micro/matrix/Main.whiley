import whiley.io.*

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

(Matrix,Matrix) parseFile(string input):
    data,pos = parseLine(2,0,input)    
    nrows = data[0]
    ncols = data[1]
    A,pos = parseMatrix(nrows,ncols,pos,input)
    B,pos = parseMatrix(nrows,ncols,pos,input)
    return A,B

(Matrix,int) parseMatrix(int nrows, int ncols, int pos, string input):    
    rows = []
    for i in 0..nrows:
        row,pos = parseLine(ncols,pos,input)
        rows = rows + [row]
    return rows,pos
        
([int],int) parseLine(int count, int pos, string input):
    pos = skipWhiteSpace(pos,input)
    ints = []
    while pos < |input| && |ints| != count:       
        i,pos = parseInt(pos,input)
        ints = ints + i
        pos = skipWhiteSpace(pos,input)
    if |ints| != count:  
        throw { msg: "invalid input file" }
    return ints,pos

(int,int) parseInt(int pos, string input):
    start = pos
    while pos < |input| && isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw "Missing number"
    return str2int(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '-'

// ========================================================
// Main
// ========================================================

void System::printMat(Matrix A):
    for i in 0 .. |A|:
        row = A[i]
        for j in 0 .. |row|:
            out.print(str(row[j]))
            out.print(" ")
        out.println("")

void System::main([string] args):
    file = this.openReader(args[0])
    // first, read data
    input = ascii2str(file.read())
    // second, build the matrices
    A,B = parseFile(input)
    // third, run the benchmark
    C = run(A,B)    
    // finally, print the result!
    this.printMat(C)