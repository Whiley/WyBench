import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*
import * from whiley.lang.Errors

// ============================================
// Board
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

// ============================================
// Parser
// ============================================

Board parseConfig(string input) throws SyntaxError:
    cols,rows,pos = parsePair(input,0,'x')
    board = Board(cols,rows)
    while pos < |input|:
        col,row,pos = parsePair(input,pos,',')
        board[row][col]=true
    return board

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
    return String.toInt(input[start..pos]),pos

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
        board = parseConfig(input)
        printBoard(sys,board)
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
