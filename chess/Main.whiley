import whiley.io.*

void System::main([string] args):
    if |args| == 0:
        this.usage()
        return
    file = this.openReader(args[0])
    contents = ascii2str(file.read())
    game = parseChessGame(contents)
    out.println("Moves taken:\n")
    board = startingChessBoard  
    r = ""       
    i = 0
    invalid = false
    sign = false
    // process each move in turn, updating the board
    while i < |game| && !invalid:
        out.println(str(i) + ". ")
        white,black = game[i]
        out.println(move2str(white))
        if black != null:
            out.println(move2str(black))
        i = i + 1
/*
            if validMove(move,board):
                board = applyMove(move,board)
                if !sign:
                    r = move2str(move)
                else:
                    out.println(str((i/2)+1) + " " + r + " " + move2str(move))
                sign = !sign
                i = i + 1
            else:
                invalid = true
        if sign:
            out.println(str((i/2)+1) + " " + r)
        // print out board
        out.println("\nCurrent board:\n")
        out.println(board2str(board))
        // now check whether last move was invalid
        if invalid:
            out.println("Invalid move:\n")
            if sign:
                out.println(str((i/2)+1) + " ... " + move2str(game[i]))
            else:
                out.println(move2str(game[i]))
*/

void System::usage():
    out.println("usage: chess file")

define BLACK_PIECE_CHARS as [ 'p', 'n', 'b', 'r', 'q', 'k' ]

string board2str(Board b):
    r = ""
    i=8
    while i >= 1:
        r = r + str(i) + row2str(b.rows[i-1])
        i = i - 1
    return r + "  a b c d e f g h\n"

string row2str(Row row):
    r = ""
    for square in row:
        r = r + "|" + square2str(square)
    return r + "|\n"

string square2str(Square p):
    if p is null:
        return "_"
    else if p.colour:
        return "" + PIECE_CHARS[p.kind]
    else:
        return "" + BLACK_PIECE_CHARS[p.kind]

string move2str(ShortMove m):
    if m is ShortSingleMove: 
        if m.isTake:
            return piece2str(m.piece) + pos2str(m.from) + "x" + pos2str(m.to)
        else:
            return piece2str(m.piece) + pos2str(m.from) + pos2str(m.to)
    else if m is CastleMove:
        if m.kingSide:
            return "O-O"
        else:
            return "O-O-O"
    else if m is ShortCheckMove:
        // check move
        return move2str(m.move) + "+"  
    return ""

string piece2str(Piece p):
    if p.kind == PAWN:
        return ""
    else:
        return "" + PIECE_CHARS[p.kind]

string pos2str(ShortPos p):
    if p is null:
        return ""
    else if p is RankPos:
        return "" + ('1' + p.row)
    else if p is FilePos:
        return "" + ('a' + p.col)
    else: 
        return pos2str(p)

string pos2str(Pos p):
    return "" + ('a' + p.col) + ('1' + p.row)
