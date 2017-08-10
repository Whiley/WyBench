import std.ascii
import std.fs
import std.io

import wybench.parser

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
    nat width,
    nat height,
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

property sized(int height, int width, int[][] C)
where height == |C|
where all { k in 0..|C| | width == |C[k]| }

property sized(Matrix A, Matrix B, int[][] C)
where sized(A.height,B.width,C)

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
    while i < A.height where sized(A,B,C_data):
        nat j = 0
        while j < B.width where sized(A,B,C_data):
            int r = 0
            nat k = 0
            while k < A.width where sized(A,B,C_data):
                r = r + (A.data[i][k] * B.data[k][j])
                k = k + 1
            C_data[i][j] = r
            j = j + 1
        i = i + 1
    //
    return Matrix(B.width,A.height,C_data)

function buildMatrix(nat width, nat height, int[] data, nat pos) -> Matrix
requires |data| > pos + (width * height):
    //
    int[][] rows = [[0; width]; height]
    //
    nat i = 0
    while i < height where sized(height,width,rows):
        nat j = 0
        while j < width where sized(height,width,rows):
            assume (pos+j) < |data| // FIXME
            rows[i][j] = data[pos+j]
            j = j + 1   
        i = i + 1
        pos = pos + width
    //
    return Matrix(width,height,rows)

// ========================================================
// Main
// ========================================================

method printMat(Matrix A):
    nat i = 0 
    while i < A.height:
        nat j = 0
        while j < A.width:
            io.print(A.data[i][j])
            io.print(" ")
            j = j + 1
        i = i + 1
        io.println(" ")

method main(ascii.string[] args):
    if |args| == 0:
        io.println("usage: matrix <input-file>")
    else:
        fs.File file = fs.open(args[0])
        // first, read data
        ascii.string input = ascii.fromBytes(file.readAll())
        int[]|null data = parser.parseInts(input)
        if data is null || |data| < 2:
            io.println("error reading file")
        else:
            int width = data[0]
            int height = data[1]
            int size = width*height
            if(|data| != 2+(size * 2)): 
                io.println("file geometry incorrect")           
            else:
                // second, build the matrices
                Matrix A = buildMatrix(width,height,data,2)
                Matrix B = buildMatrix(width,height,data,2+(width*height))
                // third, run the benchmark
                Matrix C = multiply(A,B)
                // finally, print the result!
                printMat(C)
          
