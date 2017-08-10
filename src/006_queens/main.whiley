import std.ascii
import std.math
import std.io

import nat from std.integer

type Pos is {int row, int col}

function Pos(int row, int col) -> Pos:
    //
    return {row:row, col:col}

function conflict(Pos p, nat row, nat col) -> bool:
    if p.row == row || p.col == col:
        return true
    int colDiff = math.abs(p.col - col)
    int rowDiff = math.abs(p.row - row)
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
        nat col = 0
        while col < dim where n < |queens| && dim == |queens|:
            bool solution = true
            nat i = 0
            while i < n where n < |queens| && dim == |queens|:
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

method main(ascii.string[] args):
    int dim = 10
    Pos[] init = [Pos(0,0); dim]
    //
    Pos[][] solutions = run(init,0,dim)
    io.print("Found ")
    io.print(|solutions|)
    io.println(" solutions.")

// This will be deprecated once the Array.append function is generic.
function append(Pos[][] xs, Pos[][] ys) -> Pos[][]:
    Pos[][] zs =  [[Pos(0,0);0]; |xs| + |ys|]
    zs = copy(xs,0,zs,0,|xs|)
    return copy(ys,0,zs,|xs|,|ys|)

function copy(Pos[][] xs, nat xsStart, Pos[][] ys, nat ysStart, int len) -> (Pos[][] zs)
requires xsStart + len <= |xs|
requires ysStart + len <= |ys|
ensures |zs| == |ys|:
    nat ysLen = |ys|
    nat i = 0
    while i < len where |ys| == ysLen:
        ys[i+ysStart] = xs[i+xsStart]
        i = i + 1
    //
    return ys