import whiley.lang.*
import whiley.io.File
import nat from whiley.lang.Int

import wybench.Parser

// ============================================
// Game Logic
// ============================================

type Board is {
    bool[][] cells,
    nat width,
    nat height
} where |cells| == height && all { i in 0..|cells| | |cells[i]| == width }

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
    int height = board.height
    int width = board.width
    int i = 0
    while i < height where i >= 0 && |ncells| == height && all { k in 0..|ncells| | |ncells[k]| == width }:
        int j = 0
        while j < width where j >= 0 && all { k in 0..|ncells| | |ncells[k]| == width }:
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

function parseConfig(int[] data) -> (Board,int):
    //
    int niters = data[0]
    int cols = data[1]
    int rows = data[2]
    Board board = Board(cols,rows)
    int i = 3
    while i < |data|:
        int col = data[i]
        int row = data[i+1]
        board.cells[row][col] = true
        i = i + 2
    //
    return board,niters

// ============================================
// Main
// ============================================

method main(System.Console sys):
    // First, parse input file
    File.Reader file = File.Reader(sys.args[0])
    ASCII.string input = ASCII.fromBytes(file.readAll())
    int[]|null data = Parser.parseInts(input)
    // Second, construct and iterate board
    if data != null:
        Board board, int niters = parseConfig(data)
        int i = 0
        while i < niters:
            printBoard(sys,board)
            board = update(board)
            i = i + 1
        //
    else:
        sys.out.println_s("error parsing file")

method printBoard(System.Console sys, Board board):
    int ncols = board.width
    sys.out.print_s("+")
    int i = 0
    while i < ncols:
        sys.out.print_s("-")
        i = i + 1
    sys.out.println_s("+")
    i = 0
    while i < |board.cells|:
        bool[] row = board.cells[i]
        sys.out.print_s("|")
        int j = 0
        while j < |row|:
            if row[j]:
                sys.out.print_s("#")
            else:
                sys.out.print_s(" ")
            j = j + 1        
        sys.out.println_s("|")
        i = i + 1
    //
    sys.out.print_s("+")
    i = 0
    while i < ncols:
        sys.out.print_s("-")
        i = i + 1
    sys.out.println_s("+")
