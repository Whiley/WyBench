import std::ascii
import std::math
import std::io
import std::array

import uint from std::integer

type Pos is {int row, int col}

function Pos(int row, int col) -> Pos:
    //
    return {row:row, col:col}

function conflict(Pos p, uint row, uint col) -> bool:
    if p.row == row || p.col == col:
        return true
    int colDiff = math::abs(p.col - col)
    int rowDiff = math::abs(p.row - row)
    return colDiff == rowDiff

/**
 * Find all solutions at a given dimension
 */
function run(uint dim) -> (Pos[][] solutions):
    Pos[] init = [Pos(0,0); dim]
    return run(init,0,dim)

function run(Pos[] queens, uint n, int dim) -> Pos[][] 
// The number of allocated queens is at most the number of queens
requires n <= |queens|
// Dim matches the size of the array
requires dim == |queens|:
    //
    if dim == n:
        return [queens]
    else:
        Pos[][] solutions = [[Pos(0,0);0];0]
        uint col = 0
        while col < dim where n < |queens| && dim == |queens|:
            bool solution = true
            uint i = 0
            while i < n where n < |queens|:
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

public method test_01():
    assume |run(1)| == 1

public method test_02():
    assume |run(2)| == 0

public method test_03():
    assume |run(3)| == 0

public method test_04():
    assume |run(4)| == 2

public method test_05():
    assume |run(5)| == 10

public method test_06():
    assume |run(6)| == 4

public method test_07():
    assume |run(7)| == 40

public method test_08():
    assume |run(8)| == 92
