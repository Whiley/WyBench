import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*
import * from whiley.lang.Errors

// ============================================
// Game Logic
// ============================================

define Board as [[bool]]

Board Board(int nrows, int ncols):
    row = []
    for i in 0..ncols:
        row = row + [false]
    board = []
    for i in 0..nrows:
        board = board + [row]
    return board

Board update(Board board):
    nboard = board
    nrows = |board|
    ncols = |board[0]|
    for i in 0..nrows:
        for j in 0..ncols:
            c = countLiving(board,i,j)
            alive = board[i][j]
            if alive:        
                switch c:
                    case 0,1:
                        // Any live cell with fewer than two live neighbours dies, 
                        // as if caused by under-population.
                        nboard[i][j] = false
                    case 2,3:
                        // Any live cell with two or three live neighbours lives
                        // on to the next generation.
                    case 4,5,6,7,8:
                        // Any live cell with more than three live neighbours dies, 
                        // as if by overcrowding.
                        nboard[i][j] = false
                // end switch
            else if c == 3:
                // Any dead cell with exactly three live neighbours 
                // becomes a live cell, as if by reproduction.
                nboard[i][j] = true
    // done                    
    return nboard

int countLiving(Board board, int row, int col):
    count = isAlive(board,row-1,col-1)
    count = count + isAlive(board,row-1,col)
    count = count + isAlive(board,row-1,col+1)
    count = count + isAlive(board,row,col-1)
    count = count + isAlive(board,row,col+1)
    count = count + isAlive(board,row+1,col-1)
    count = count + isAlive(board,row+1,col)
    count = count + isAlive(board,row+1,col+1)
    return count

int isAlive(Board board, int row, int col):
    nrows = |board|
    if row < 0 || row >= nrows:
        return 0
    ncols = |board[0]|
    if col < 0 || col >= ncols:
        return 0
    if board[row][col]:
        return 1
    else:
        return 0
       

// ============================================
// Parser
// ============================================

(Board,int) parseConfig(string input) throws SyntaxError:
    niters,pos = parseInt(0,input)
    pos = skipWhiteSpace(pos,input)
    cols,rows,pos = parsePair(input,pos,'x')
    board = Board(cols,rows)
    while pos < |input|:
        col,row,pos = parsePair(input,pos,',')
        board[row][col]=true
    return board,niters

(int,int,int) parsePair(string input, int pos, char sep) throws SyntaxError:
    pos = skipWhiteSpace(pos,input)
    first,pos = parseInt(pos,input)
    pos = skipWhiteSpace(pos,input)
    if pos < |input|:
        if input[pos] == sep:
            pos=pos+1
        else:
            throw SyntaxError("expected '" + sep + "', found '" + input[pos] + "'",pos,pos+1)
    else:
        throw SyntaxError("unexpected end of file",pos,pos+1)
    pos = skipWhiteSpace(pos,input)
    second,pos = parseInt(pos,input)
    pos = skipWhiteSpace(pos,input)
    return first,second,pos

(int,int) parseInt(int pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ============================================
// Main
// ============================================

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())
    try:
        board,niters = parseConfig(input)
        for i in 0..niters:
            printBoard(sys,board)
            board = update(board)
    catch(SyntaxError e):
        sys.out.println("error: " + e.msg)

void ::printBoard(System sys, Board board):
    ncols = |board[0]|
    sys.out.print("+")
    for i in 0..ncols:
        sys.out.print("-")
    sys.out.println("+")
    for row in board:
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
