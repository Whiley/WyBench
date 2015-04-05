import whiley.lang.*
import whiley.io.File
import string from whiley.lang.ASCII
import nat from whiley.lang.Int

import wybench.Parser

// ============================================
// Game Logic
// ============================================

type Board is {
    [[bool]] cells,
    nat width,
    nat height
} where |cells| == height && all { row in cells | |row| == width }

// Create an empty board of size width x height.  That is, where each
// square is "off".
function Board(nat height, nat width) -> Board:
    [bool] row = []
    int i = 0
    while i < width where i >= 0:
        row = row ++ [false]
        i = i + 1
    assume |row| == width
    [[bool]] cells = []
    i = 0
    while i < height where i >= 0 && all { r in cells | |r| == width }:
        cells = cells ++ [row]
        i = i + 1
    assume |cells| == height
    return { 
        cells: cells, 
        height: height, 
        width: width
    }

// Take the current board and determine the next state based on the
// current state of all cells.
function update(Board board) -> Board:
    [[bool]] ncells = board.cells
    int height = board.height
    int width = board.width
    int i = 0
    while i < height where i >= 0 && |ncells| == height && all { row in ncells | |row| == width }:
        int j = 0
        while j < width where j >= 0 && all { row in ncells | |row| == width }:
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

function parseConfig([int] data) -> (Board,int):
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
    string input = ASCII.fromBytes(file.readAll())
    [int]|null data = Parser.parseInts(input)
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
    for i in 0..ncols:
        sys.out.print_s("-")
    sys.out.println_s("+")
    for row in board.cells:
        sys.out.print_s("|")
        for cell in row:
            if cell:
                sys.out.print_s("#")
            else:
                sys.out.print_s(" ")
        sys.out.println_s("|")
    sys.out.print_s("+")
    for i in 0..ncols:
        sys.out.print_s("-")
    sys.out.println_s("+")
