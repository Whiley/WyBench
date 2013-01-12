import whiley.lang.*
import * from whiley.lang.System

import nat from whiley.lang.Int

define Pos as (int,int)

int abs(int x):
    if x < 0:
        return -x
    else:
        return x

bool conflict(Pos p, int row, int col):
    r,c = p
    if r == row || c == col:
        return true
    colDiff = abs(c - col)
    rowDiff = abs(r - row)
    return colDiff == rowDiff
    

[[Pos]] run([Pos] queens, nat n, int dim) requires n <= |queens| && dim == |queens|:
    if dim == n:
        return [queens]
    else:
        solutions = []
        for col in 0 .. dim where n < |queens| && dim == |queens|:
            solution = true
            i = 0
            while i < n where n < |queens| && i >= 0 && dim == |queens|:
                p = queens[i]
                if conflict(p,n,col):
                    solution = false
                    break
                i = i + 1
            if solution:
                queens[n] = (n,col)
                solutions = solutions + run(queens,n+1,dim)                    
        return solutions

void ::main(System.Console sys):
    dim = 10
    init = []
    for i in 0..dim:
        init = init + [(0,0)]
    assume |init| == dim
    solutions = run(init,0,dim)
    sys.out.println("Found " + |solutions| + " solutions.")
