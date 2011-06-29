// This file implements a parse for chess games in Portable Game
// Notation (PGN) format.  This is based around short-algebraic notation.
// Such moves are, by themselves, incomplete.  We must have access to the 
// current board state in order to decode them.
//
// See http://en.wikipedia.org/wiki/Algebraic_chess_notation for more.

define state as {string input, int pos}
define SyntaxError as {string msg}

[ShortRound] parseChessGame(string input) throws SyntaxError:
    pos = 0
    finished = false
    moves = []
    while pos < |input| && !finished:        
        line = parseLine(input,pos)
        split = splitLine(line)
        whiteMove = parseMove(split[0], true)
        if |split| == 2:
            blackMove = parseMove(split[1], false) 
        else:   
            blackMove = null
            finished = true
        moves = moves + [(whiteMove,blackMove)]
        pos = nextLine(input,pos+|line|)
    return moves

string parseLine(string input, int pos):
    start = pos
    while pos < |input| && input[pos] != '\n':
        pos = pos + 1
    return input[start..pos]

int nextLine(string input, int pos):
    while pos < |input| && (input[pos] == '\n' || input[pos] == '\r'):
        pos = pos + 1
    return pos

[string] splitLine(string input):
    pos = 0
    while pos < |input| && input[pos] != ' ':
        pos = pos + 1
    splits = [input[0..pos]]
    pos = pos + 1
    if pos < |input|:
        start = pos
        while pos < |input| && input[pos] != ' ':
            pos = pos + 1
        splits = splits + [input[start..pos]]    
    return splits        

ShortMove parseMove(string input, bool isWhite):
    // first, we check for castling moves
    if |input| >= 5 && input[0..5] == "O-O-O":
        move = { isWhite: isWhite, kingSide: false }
        index = 5
    else if |input| >= 3 && input[0..3] == "O-O":
        move = { isWhite: isWhite, kingSide: true }
        index = 3
    else:
        // not a castling move
        index = parseWhiteSpace(0,input)
        p,index = parsePiece(index,input,isWhite)
        f,index = parseShortPos(index,input)
        if input[index] == 'x':
            index = index + 1
            flag = true
        else:
            flag = false
        t = parsePos(input[index..index+2])
        move = { piece: p, from: f, to: t, isTake: flag }
    // finally, test for a check move
    //if index < |input| && input[index] == '+':
    //    move = {check: move} 
    return move

(Piece,int) parsePiece(int index, string input, bool isWhite):
    lookehead = input[index]
    switch index:
        case 'N':
            piece = KNIGHT
            break
        case 'B':
            piece = BISHOP
            break
        case 'R':
            piece = ROOK
            break
        case 'K':
            piece = KING
            break
        case 'Q':
            piece = QUEEN
            break
        default:
            index = index - 1
            piece = PAWN
    return {kind: PAWN, colour: isWhite}, index+1
    
Pos parsePos(string input):
    c = input[0] - 'a'
    r = input[1] - '1'
    return { col: c, row: r }

(ShortPos,int) parseShortPos(int index, string input):
    c = input[index]
    if isDigit(c):
        // signals rank only
        return { row: (c - '1') },index+1
    else if c != 'x' && isLetter(c):
        // so, could be file only, file and rank, or empty
        d = input[index+1]
        if isLetter(d):
            // signals file only
            return { col: (c - 'a') },index+1         
        else if (index+2) < |input| && isLetter(input[index+2]):
            // signals file and rank
            return { col: (c - 'a'), row: (d - '1') },index+2
    // no short move given
    return null,index

int parseWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t'


