import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File
import * from whiley.lang.Errors

// Implementation of Fast Matrix Multiplication.  This uses

// http://en.wikipedia.org/wiki/Matrix_chain_multiplication

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


Matrix multiply(Matrix A, Matrix B) 
    requires A.width == B.height,
    ensures $.width == B.width && $.height == A.height:
    //
    C_data = []
    i = 0
    //
    // NOTE: the following loops can be more elegantly written using
    // "for" statements.  However, for the moment I use "while"
    // statements as these work better with verification.
    //
    while i < A.height where i >= 0:
        row = []
        j = 0
        while j < B.width where j >= 0:
            r = 0
            k = 0
            while k < A.width where k >= 0:
                r = r + (A.data[i][k] * B.data[k][j])
                k = k + 1
            row = row + [r]
            j = j + 1
        C_data = C_data + [row]
        i = i + 1
    //
    return Matrix(B.width,A.height,C_data)

(Matrix, Matrix) divHor(Matrix mat) requires mat.width > 1:
    m0d = []
    m1d = []
    w0 = mat.width / 2
    w1 = mat.width - mat.width / 2
    for row in mat.data:
        r0 = row[0..w0]
        r1 = row[w0..]
        m0d = m0d + [r0]
        m1d = m1d + [r1]
    return (Matrix(w0, mat.height, m0d), Matrix(w1, mat.height, m1d))

Matrix mergeHor(Matrix m0, Matrix m1) 
requires m0.height == m1.height, 
ensures $.width == m0.width + m1.width,
ensures $.height == m0.height:
    //
    dat = []
    for i in 0 .. m0.height:
        dat = dat + [m0.data[i] + m1.data[i]]
    return Matrix(m0.width + m1.width, m0.height, dat)

(Matrix, Matrix) divVer(Matrix mat) requires mat.height > 1:
    h0 = mat.height / 2
    h1 = mat.height - mat.height / 2
    m0d = mat.data[0..h0]
    m1d = mat.data[h0..]
    return (Matrix(mat.width, h0, m0d), Matrix(mat.width, h1, m1d))

Matrix mergeVer(Matrix m0, Matrix m1) requires m0.width == m1.width, ensures $.width == m0.width && $.height == m0.height + m1.height:
    return Matrix(m0.width, m0.height + m1.height, m0.data + m1.data)

Matrix matAdd(Matrix A, Matrix B) requires A.width == B.width && A.height == B.height, ensures $.width == B.width && $.height == A.height:
    dat = []
    for i in 0 .. A.height:
        row = []
        for j in 0 .. A.width:
             row = row + [A.data[i][j] + B.data[i][j]]
        dat = dat + [row]
    return Matrix(A.width, A.height, dat)

Matrix matSub(Matrix A, Matrix B) requires A.width == B.width && A.height == B.height, ensures $.width == B.width && $.height == A.height:
    dat = []
    for i in 0 .. A.height:
        row = []
        for j in 0 .. A.width:
             row = row + [A.data[i][j] - B.data[i][j]]
        dat = dat + [row]
    return Matrix(A.width, A.height, dat)

Matrix fastMultiply(Matrix A, Matrix B):// requires A.width == B.height, ensures $.width == B.width && $.height == A.height:
    if A.width <= 3 || A.height <= 3 || B.width <= 3 || B.height <= 3:
        return multiply(A, B)
    else:
        ab, cd = divVer(A)
        a, b = divHor(ab)
        c, d = divHor(cd)
        ef, gh = divVer(B)
        e, f = divHor(ef)
        g, h = divHor(gh)
        p1 = fastMultiply(a, matSub(f, h))
        p2 = fastMultiply(matAdd(a, b), h)
        p3 = fastMultiply(matAdd(c, d), e)
        p4 = fastMultiply(d, matSub(g, e))
        p5 = fastMultiply(matAdd(a, d), matAdd(e, h))
        p6 = fastMultiply(matSub(b, d), matAdd(g, h))
        p7 = fastMultiply(matSub(a, c), matAdd(e, f))
        q1 = matAdd(matSub(matAdd(p5, p4), p2), p6)
        q2 = matAdd(p1, p2)
        q3 = matAdd(p3, p4)
        q4 = matSub(matSub(matAdd(p1, p5), p3), p7)
        return mergeVer(mergeHor(q1, q2), mergeHor(q3, q4))

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
    if |sys.args| == 0:
        sys.out.println("usage: matrix <input-file>")
    else:
        file = File.Reader(sys.args[0])
        // first, read data
        input = String.fromASCII(file.read())
        try:
            // second, build the matrices
            A,B = parseFile(input)
            // third, run the benchmark
            C = fastMultiply(A, B)
            // finally, print the result!
            printMat(sys,C)
        catch(SyntaxError e):
            sys.out.println("error - " + e.msg)

