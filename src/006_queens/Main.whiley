import whiley.lang.*
import * from whiley.lang.System

import nat from whiley.lang.Int

type Pos is {int row, int col}

function Pos(int row, int col) -> Pos:
    //
    return {row:row, col:col}

function conflict(Pos p, nat row, nat col) -> bool:
    if p.row == row || p.col == col:
        return true
    int colDiff = Math.abs(p.col - col)
    int rowDiff = Math.abs(p.row - row)
    return colDiff == rowDiff

function run(Pos[] queens, nat n, int dim) -> Pos[][] 
// The number of allocated queens is at most the number of queens
requires n <= |queens|
// Dim matches the size of the array
requires dim == |queens|:
    //
    if dim == n:
        return [queens]
    else:
        Pos[][] solutions = [[Pos(0,0);0];0]
        int col = 0
        while col < dim where n < |queens| && dim == |queens|:
            bool solution = true
            int i = 0
            while i < n where n < |queens| && i >= 0 && dim == |queens|:
                Pos p = queens[i]
                if conflict(p,n,col):
                    solution = false
                    break
                i = i + 1
            if solution:
                queens[n] = Pos(n,col)
                solutions = append(solutions,run(queens,n+1,dim))
            col = col + 1
        return solutions

method main(System.Console sys):
    int dim = 10
    Pos[] init = [Pos(0,0); dim]
    //
    Pos[][] solutions = run(init,0,dim)
    sys.out.print_s("Found ")
    sys.out.print_s(Int.toString(|solutions|))
    sys.out.println_s(" solutions.")

// This will be deprecated once the Array.append function is generic.
function append(Pos[][] xs, Pos[][] ys) -> Pos[][]:
    Pos[][] zs =  [[Pos(0,0);0]; |xs| + |ys|]
    zs = copy(xs,0,zs,0,|xs|)
    return copy(ys,0,zs,|xs|,|ys|)

function copy(Pos[][] xs, int xsStart, Pos[][] ys, int ysStart, int len) -> Pos[][]:
    int i = xsStart
    int j = ysStart
    int end = xsStart + len
    while i < end:
        ys[j] = xs[i]
        i = i + 1
        j = j + 1
    //
    return ys