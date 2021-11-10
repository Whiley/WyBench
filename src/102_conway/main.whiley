import std::ascii
import uint from std::integer

// ============================================
// Game Logic
// ============================================

type Board is ({
    bool[][] cells,
    uint width,
    uint height
} b) where |b.cells| == b.height && all { i in 0..|b.cells| | |b.cells[i]| == b.width }

// Create an empty board of size width x height.  That is, where each
// square is "off".
function Board(uint height, uint width) -> Board:
    bool[] row = [false; width]
    bool[][] cells = [row; height]
    return { 
        cells: cells, 
        height: height, 
        width: width
    }

// Set a given cell on the board
function set(Board b, uint x, uint y) -> Board
// Ensure cell within bounds!
requires x < b.width && y < b.height:
    b.cells[y][x] = true
    return b

// Take the current board and determine the next state based on the
// current state of all cells.
function update(Board board) -> Board:
    bool[][] ncells = board.cells
    uint height = board.height
    uint width = board.width
    uint i = 0
    while i < height where |ncells| == height && all { k in 0..|ncells| | |ncells[k]| == width }:
        uint j = 0
        while j < width
        where |ncells| == height
        where all { k in 0..|ncells| | |ncells[k]| == width }:
            int c = countLiving(board,i,j)
            assume i < |board.cells|    // FIXME
            assume j < |board.cells[i]| // FIXME
            bool alive = board.cells[i][j]
            if alive:        
                switch c:
                    case 0,1:
                        // Any live cell with fewer than two live neighbours dies, 
                        // as if caused by under-population.
                        ncells[i][j] = false
                    case 2,3:
                        // Any live cell with two or three live neighbours lives
                        // on to the next generation.
                    case 4,5,6,7,8:
                        // Any live cell with more than three live neighbours dies, 
                        // as if by overcrowding.
                        ncells[i][j] = false
                // end switch
            else if c == 3:
                // Any dead cell with exactly three live neighbours 
                // becomes a live cell, as if by reproduction.
                ncells[i][j] = true
            j = j + 1
        i = i + 1
    // done
    return { 
        cells: ncells, 
        height: height, 
        width: width
    }                    

function countLiving(Board board, int row, int col) -> int:
    int count = isAlive(board,row-1,col-1)
    count = count + isAlive(board,row-1,col)
    count = count + isAlive(board,row-1,col+1)
    count = count + isAlive(board,row,col-1)
    count = count + isAlive(board,row,col+1)
    count = count + isAlive(board,row+1,col-1)
    count = count + isAlive(board,row+1,col)
    count = count + isAlive(board,row+1,col+1)
    return count

function isAlive(Board board, int row, int col) -> int:
    if row < 0 || row >= board.height:
        return 0
    if col < 0 || col >= board.width:
        return 0
    if board.cells[row][col]:
        return 1
    else:
        return 0      

// ============================================
// Tests
// ============================================

final bool X = true
final bool _ = false

unsafe public method test_01():
    Board b = Board(5,5)
    // Initialise board
    b = set(b,2,1)
    b = set(b,2,2)
    b = set(b,2,3)
    // Run one step
    b = update(b)
    // Check
    assume b.cells == [[_,_,_,_,_],
                       [_,_,_,_,_],
                       [_,X,X,X,_],
                       [_,_,_,_,_],
                       [_,_,_,_,_]]

unsafe public method test_02():
    Board b = Board(5,5)
    // Initialise board
    b = set(b,1,2)
    b = set(b,2,2)
    b = set(b,3,2)
    // Run one step
    b = update(b)
    // Check
    assume b.cells == [[_,_,_,_,_],
                       [_,_,X,_,_],
                       [_,_,X,_,_],
                       [_,_,X,_,_],
                       [_,_,_,_,_]]

unsafe public method test_03():
    Board b = Board(5,5)
    // Initialise board
    b = set(b,1,0)
    b = set(b,2,1)
    b = set(b,0,2)
    b = set(b,1,2)
    b = set(b,2,2)    
    // Run one step
    b = update(b)
    // Check
    assume b.cells == [[_,X,_,_,_],
                       [_,_,X,_,_],
                       [X,X,X,_,_],
                       [_,_,_,_,_],
                       [_,_,_,_,_]]