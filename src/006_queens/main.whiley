import std::ascii
import std::math
import std::io
import std::array

import nat from std::integer

type Pos is {int row, int col}

function Pos(int row, int col) -> Pos:
    //
    return {row:row, col:col}

function conflict(Pos p, nat row, nat col) -> bool:
    if p.row == row || p.col == col:
        return true
    int colDiff = math::abs(p.col - col)
    int rowDiff = math::abs(p.row - row)
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
                solutions = array::append(solutions,run(queens,n+1,dim))
            col = col + 1
        return solutions

method main(ascii::string[] args):
    int dim = 10
    Pos[] init = [Pos(0,0); dim]
    //
    Pos[][] solutions = run(init,0,dim)
    io::print("Found ")
    io::print(|solutions|)
    io::println(" solutions.")
