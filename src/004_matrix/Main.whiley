import whiley.lang.*
import whiley.lang.System
import whiley.io.File
import wybench.Parser

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII

// Author: David J. Pearce

// ========================================================
// Description
// ========================================================

// This is a very naive implementation of matrix multiplication.  It does
// not perform any optimisations, and does not represent matrices in any
// special manner (e.g. sparse representations, etc).
//
// In the future, it would be interesting to consider chain
// multiplication problem:
//
// http://en.wikipedia.org/wiki/Matrix_chain_multiplication
//

// ========================================================
// Benchmark Code
// ========================================================

type nat is (int x) where x >= 0

type Matrix is {
    int width,
    int height,
    [[int]] data
} where |data| == height && no { i in data | |i| != width }

function Matrix(nat width, nat height, [[int]] data) -> (Matrix r)
// Input array must match matrix height
requires |data| == height
// Elements of input array must match matrix width
requires no { i in data | |i| != width }
// 
ensures r.width == width && r.height == height && r.data == data:
    //
    return {
        width: width,
        height: height,
        data: data
    }

function multiply(Matrix A, Matrix B) -> (Matrix C) 
// Must be possible to multiply matrices
requires A.width == B.height
// Specify dimensions of result
ensures C.width == B.width && C.height == A.height:
    //
    [[int]] C_data = []
    nat i = 0
    //
    // NOTE: the following loops can be more elegantly written using
    // "for" statements.  However, for the moment I use "while"
    // statements as these work better with verification.
    //
    while i < A.height where i >= 0:
        [int] row = []
        nat j = 0
        while j < B.width where j >= 0:
            int r = 0
            nat k = 0
            while k < A.width where k >= 0:
                r = r + (A.data[i][k] * B.data[k][j])
                k = k + 1
            row = row ++ [r]
            j = j + 1
        C_data = C_data ++ [row]
        i = i + 1
    //
    return Matrix(B.width,A.height,C_data)

// ========================================================
// Parser Code
// ========================================================

function parseFile(string input) -> (Matrix|null,Matrix|null):
    Matrix|null A // 1st result
    Matrix|null B // 2nd result
    [int]|null data, int pos = parseLine(2,0,input)
    if data != null:
        int nrows = data[0]
        int ncols = data[1]
        pos = skipBreak(pos,input)
        A,pos = parseMatrix(nrows,ncols,pos,input)
        pos = skipBreak(pos,input)
        B,pos = parseMatrix(nrows,ncols,pos,input)
        return A,B
    else:
        return null,null

function parseMatrix(nat height, nat width, int pos, string input) -> (Matrix|null,int):
    //
    [[int]] rows = []
    [int]|null row
    //
    for i in 0 .. height:
        row,pos = parseLine(width,pos,input)
        if row != null:
            rows = rows ++ [row]
        else:
            return null,pos
    //
    return Matrix(width,height,rows),pos

function parseLine(int count, int pos, string input) -> ([int]|null,int):
    //
    pos = Parser.skipWhiteSpace(pos,input)
    [int] ints = []
    int|null i
    //
    while pos < |input| && |ints| != count:
        i,pos = Parser.parseInt(pos,input)
        if i is null:
            return null,pos
        else:
            ints = ints ++ [i]
            pos = Parser.skipWhiteSpace(pos,input)
    //
    return ints,pos

function skipBreak(int index, string input) -> int:
    while index < |input| && input[index] == '-':
        index = index + 1
    //
    return Parser.skipWhiteSpace(index,input)

// ========================================================
// Main
// ========================================================

method printMat(System.Console sys, Matrix A):
    for i in 0 .. A.height:
        for j in 0 .. A.width:
            sys.out.print(A.data[i][j])
            sys.out.print(" ")
        sys.out.println("")

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: matrix <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        // first, read data
        string input = ASCII.fromBytes(file.readAll())
        // second, build the matrices
        Matrix|null A, Matrix|null B = parseFile(input)
        if A != null && B != null:            
            // third, run the benchmark
            Matrix C = multiply(A,B)
            // finally, print the result!
            printMat(sys,C)
        else:
            sys.out.println("Error reading file")

