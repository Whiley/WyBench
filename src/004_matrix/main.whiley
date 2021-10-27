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

// ========================================================
// Tests
// ========================================================

public method test_01():
    Matrix A = Matrix(1,1,[[2]])
    Matrix B = Matrix(1,1,[[3]])
    Matrix C = Matrix(1,1,[[6]])
    assume multiply(A,B) == C

public method test_02():
    Matrix A = Matrix(1,2,[[3],[2]])
    Matrix B = Matrix(2,1,[[2,5]])    
    Matrix C = Matrix(2,2,[[6,15],[4,10]])
    assume multiply(A,B) == C

public method test_03():
    Matrix A = Matrix(2,2,[[2,5],[4,3]])
    Matrix B = Matrix(2,2,[[3,2],[5,6]])
    Matrix C = Matrix(2,2,[[31,34],[27,26]])
    assume multiply(A,B) == C

public method test_04():
    Matrix A = Matrix(2,3,[[2,2],[3,3],[4,4]])
    Matrix B = Matrix(2,2,[[5,6],[7,8]])
    Matrix C = Matrix(2,3,[[24,28],[36,42],[48,56]])
    assume multiply(A,B) == C
