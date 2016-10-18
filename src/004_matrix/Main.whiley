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

type Matrix is ({
    int width,
    int height,
    int[][] data
} m) where |m.data| == m.height && all { i in 0..|m.data| | |m.data[i]| == m.width }

function Matrix(nat width, nat height, int[][] data) -> (Matrix r)
// Input array must match matrix height
requires |data| == height
// Elements of input array must match matrix width
requires all { i in 0..|data| | |data[i]| == width }
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
    int[][] C_data = [[0;B.width];A.height]
    nat i = 0
    //
    // NOTE: the following loops can be more elegantly written using
    // "for" statements.  However, for the moment I use "while"
    // statements as these work better with verification.
    //
    while i < A.height where i >= 0:
        nat j = 0
        while j < B.width where j >= 0:
            int r = 0
            nat k = 0
            while k < A.width where k >= 0:
                r = r + (A.data[i][k] * B.data[k][j])
                k = k + 1
            C_data[i][j] = r
            j = j + 1
        i = i + 1
    //
    return Matrix(B.width,A.height,C_data)

function buildMatrix(nat width, nat height, int[] data, int pos) -> Matrix
requires |data| > pos + (width * height):
    //
    int[][] rows = [[0; width]; height]
    //
    int i = 0
    while i < height:
        int j = 0
        while j < width:
            rows[i][j] = data[pos+j]
            j = j + 1   
        i = i + 1
        pos = pos + width
    //
    return Matrix(width,height,rows)

// ========================================================
// Main
// ========================================================

method printMat(System.Console sys, Matrix A):
    int i = 0 
    while i < A.height:
        int j = 0
        while j < A.width:
            sys.out.print(A.data[i][j])
            sys.out.print_s(" ")
            j = j + 1
        i = i + 1
        sys.out.println_s("")

method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println_s("usage: matrix <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        // first, read data
        string input = ASCII.fromBytes(file.readAll())
        int[]|null data = Parser.parseInts(input)
        if data == null || |data| < 2:
            sys.out.println_s("error reading file")
        else:
            int width = data[0]
            int height = data[1]
            int size = width*height
            if(|data| != 2+(size * 2)): 
                sys.out.println_s("file geometry incorrect")           
            else:
                // second, build the matrices
                Matrix A = buildMatrix(width,height,data,2)
                Matrix B = buildMatrix(width,height,data,2+(width*height))
                // third, run the benchmark
                Matrix C = multiply(A,B)
                // finally, print the result!
                printMat(sys,C)
          
