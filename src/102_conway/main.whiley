import std::ascii
import std::filesystem
import std::io
import wybench::parser

type nat is (int x) where x >= 0

// ============================================
// Game Logic
// ============================================

type Board is ({
    bool[][] cells,
    nat width,
    nat height
} b) where |b.cells| == b.height && all { i in 0..|b.cells| | |b.cells[i]| == b.width }

// Create an empty board of size width x height.  That is, where each
// square is "off".
function Board(nat height, nat width) -> Board:
    bool[] row = [false; width]
    bool[][] cells = [row; height]
    return { 
        cells: cells, 
        height: height, 
        width: width
    }

// Take the current board and determine the next state based on the
// current state of all cells.
function update(Board board) -> Board:
    bool[][] ncells = board.cells
    nat height = board.height
    nat width = board.width
    nat i = 0
    while i < height where |ncells| == height && all { k in 0..|ncells| | |ncells[k]| == width }:
        nat j = 0
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
// Parser
// ============================================

function parseConfig(nat[] data) -> (Board board, int nIterations)
requires |data| >= 3:
    //
    int niters = data[0]
    nat cols = data[1]
    nat rows = data[2]
    Board brd = Board(cols,rows)
    nat i = 3
    while (i+1) < |data|:
        int col = data[i]
        int row = data[i+1]
        //if col < cols && row < rows:
        brd.cells[row][col] = true
        i = i + 2
    //
    return brd,niters

// ============================================
// Main
// ============================================

method main(ascii::string[] args):
    Board board
    int niters
    if |args| == 0:
        io::println("usage: conway <file>")
    else:
        // First, parse input file
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::from_bytes(file.read_all())
        int[]|null data = parser::parseInts(input)
        // Second, construct and iterate board
        if data is int[] && |data| >= 3:
            board,niters = parseConfig(data)
            int i = 0
            while i < niters:
                printBoard(board)
                board = update(board)
                i = i + 1
            //
        else:
            io::println("error parsing file")

method printBoard(Board board):
    int ncols = board.width
    io::print("+")
    int i = 0
    while i < ncols:
        io::print("-")
        i = i + 1
    io::println("+")
    i = 0
    while i < |board.cells|:
        bool[] row = board.cells[i]
        io::print("|")
        int j = 0
        while j < |row|:
            if row[j]:
                io::print("#")
            else:
                io::print(" ")
            j = j + 1        
        io::println("|")
        i = i + 1
    //
    io::print("+")
    i = 0
    while i < ncols:
        io::print("-")
        i = i + 1
    io::println("+")
