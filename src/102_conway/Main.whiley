import whiley.lang.*
import whiley.io.File
import * from whiley.lang.Errors

import nat from whiley.lang.Int

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
function Board(nat height, nat width) => Board:
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
function update(Board board) => Board:
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

function countLiving(Board board, int row, int col) => int:
    int count = isAlive(board,row-1,col-1)
    count = count + isAlive(board,row-1,col)
    count = count + isAlive(board,row-1,col+1)
    count = count + isAlive(board,row,col-1)
    count = count + isAlive(board,row,col+1)
    count = count + isAlive(board,row+1,col-1)
    count = count + isAlive(board,row+1,col)
    count = count + isAlive(board,row+1,col+1)
    return count

function isAlive(Board board, int row, int col) => int:
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

function parseConfig(string input) => (Board,int) 
throws SyntaxError:
    //
    int niters, int pos = parseInt(0,input)
    int cols, int rows, int col, int row
    //
    pos = skipWhiteSpace(pos,input)
    cols,rows,pos = parsePair(input,pos,'x')
    Board board = Board(cols,rows)
    while pos < |input|:
        col,row,pos = parsePair(input,pos,',')
        board.cells[row][col]=true
    return board,niters

function parsePair(string input, int pos, char sep) => (int,int,int)
throws SyntaxError:
    //
    int first, int second
    //
    pos = skipWhiteSpace(pos,input)
    first,pos = parseInt(pos,input)
    pos = skipWhiteSpace(pos,input)
    if pos < |input|:
        if input[pos] == sep:
            pos=pos+1
        else:
            throw SyntaxError("expected '" ++ sep ++ "', found '" ++ input[pos] ++ "'",pos,pos+1)
    else:
        throw SyntaxError("unexpected end of file",pos,pos+1)
    pos = skipWhiteSpace(pos,input)
    second,pos = parseInt(pos,input)
    pos = skipWhiteSpace(pos,input)
    return first,second,pos

function parseInt(int pos, string input) => (int,int) 
throws SyntaxError:
    //
    int start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

function skipWhiteSpace(int index, string input) => int:
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

function isWhiteSpace(char c) => bool:
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ============================================
// Main
// ============================================

method main(System.Console sys):
    File.Reader file = File.Reader(sys.args[0])
    string input = String.fromASCII(file.readAll())
    try:
        Board board, int niters = parseConfig(input)
        for i in 0..niters:
            printBoard(sys,board)
            board = update(board)
    catch(SyntaxError e):
        sys.out.println("error: " ++ e.msg)

method printBoard(System.Console sys, Board board):
    int ncols = board.width
    sys.out.print("+")
    for i in 0..ncols:
        sys.out.print("-")
    sys.out.println("+")
    for row in board.cells:
        sys.out.print("|")
        for cell in row:
            if cell:
                sys.out.print("#")
            else:
                sys.out.print(" ")
        sys.out.println("|")
    sys.out.print("+")
    for i in 0..ncols:
        sys.out.print("-")
    sys.out.println("+")
