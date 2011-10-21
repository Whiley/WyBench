import whiley.lang.*
import * from Board

// A simple chess model
//
// David J. Pearce, 2010

// =============================================================
// Moves
// =============================================================

define SingleMove as { Piece piece, Pos from, Pos to }
define SingleTake as { Piece piece, Pos from, Pos to, Piece taken }
define SimpleMove as SingleMove | SingleTake

define CastleMove as { bool isWhite, bool kingSide }
define CheckMove as { Move check }
define Move as CheckMove | CastleMove | SimpleMove

define Invalid as { Move move, Board board }
public Invalid Invalid(Board b, Move m):
    return { board: b, move: m }

// castling
// en passant

// =============================================================
// Valid Move Dispatch
// =============================================================

// The purpose of the validMove method is to check whether or not a
// move is valid on a given board.
bool validMove(Move move, Board board):
    try:
        nboard = applyMoveDispatch(move,board)
        return validMove(move,board,nboard)
    catch(Invalid e):
        return false

bool validMove(Move move, Board board, Board nboard):
    // first, test the check status of this side, and the opposition
    // side.
    if move is CheckMove:
        move = move.check
        oppCheck = true
    else:
        // normal expectation of opposition
        oppCheck = false
    // Now, identify what colour I am
    if move is CastleMove:
        isWhite = move.isWhite
    else if move is SingleMove:
        isWhite = move.piece.colour
    else:
        isWhite = false // deadcode
    // finally, check everything is OK
    return !inCheck(isWhite,nboard) && // I'm in check?
        oppCheck == inCheck(!isWhite,nboard) && // oppo in check?
        internalValidMove(move, board) // move otherwise ok?

bool internalValidMove(Move move, Board board):
    if move is SingleTake:
        return validPieceMove(move.piece,move.from,move.to,true,board) &&
            validPiece(move.taken,move.to,board)
    else if move is SingleMove:
        return validPieceMove(move.piece,move.from,move.to,false,board) &&
            squareAt(move.to,board) is null
    else if move is CastleMove:
        return validCastle(move, board)
    // the following should be dead-code, but to remove it requires
    // more structuring of CheckMoves
    return false

bool validPieceMove(Piece piece, Pos from, Pos to, bool isTake, Board board):
    if validPiece(piece,from,board):
        if piece.kind == PAWN:
            return validPawnMove(piece.colour,from,to,isTake,board)        
        else if piece.kind == KNIGHT:
            return validKnightMove(piece.colour,from,to,isTake,board)
        else if piece.kind == BISHOP:
            return validBishopMove(piece.colour,from,to,isTake,board)
        else if piece.kind == ROOK:
            return validRookMove(piece.colour,from,to,isTake,board)
        else if piece.kind == QUEEN:
            return validQueenMove(piece.colour,from,to,isTake,board)
        else if piece.kind == KING:
            return validKingMove(piece.colour,from,to,isTake,board)
    return false

// Check whether a given piece is actually at a given position in the
// board.
bool validPiece(Piece piece, Pos pos, Board board):
    sq = squareAt(pos,board)
    if sq is null:
        return false
    else:
        return sq == piece

// Determine whether the board is in check after the given move, with
// respect to the opposite colour of the move.
bool inCheck(bool isWhite, Board board):
    if isWhite:
        kpos = findPiece(WHITE_KING,board)[0]
    else:
        kpos = findPiece(BLACK_KING,board)[0]     
    // check every possible piece cannot take king
    for r in range(0,8):
        for c in range(0,8):
            tmp = board.rows[r][c]
            if !(tmp is null) && tmp.colour == !isWhite && 
                validPieceMove(tmp,{row: r, col: c},kpos,true,board):
                return true
    // no checks found
    return false

bool validCastle(CastleMove move, Board board):
    // FIXME: this functionis still broken, since we have to check
    // that we're not castling through check :(
    if move.isWhite:
        if move.kingSide:
            return board.whiteCastleKingSide && 
                board.rows[0][5] == null && board.rows[0][6] == null
        else:
            return board.whiteCastleQueenSide && 
                board.rows[0][1] == null && board.rows[0][2] == null && board.rows[0][3] == null
    else:
        if move.kingSide:
            return board.blackCastleKingSide && 
                board.rows[7][5] == null && board.rows[7][6] == null
        else:
            return board.blackCastleQueenSide && 
                board.rows[7][1] == null && board.rows[7][2] == null && board.rows[7][3] == null

// =============================================================
// Individual Piece Moves
// =============================================================

bool validPawnMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    // calculate row difference
    if (isWhite):
        rowdiff = to.row - from.row
    else:
        rowdiff = from.row - to.row        
    // check row difference either 1 or 2, and column 
    // fixed (unless take)
    if rowdiff <= 0 || rowdiff > 2 || (!isTake && from.col != to.col):
        return false
    // check that column difference is one for take
    if isTake && from.col != (to.col - 1) && from.col != (to.col + 1):
        return false
    // check if rowdiff is 2 that on the starting rank
    if isWhite && rowdiff == 2 && from.row != 1:
        return false
    else if !isWhite && rowdiff == 2 && from.row != 6:
        return false
    // looks like we're all good
    return true    

bool validKnightMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    diffcol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    diffrow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
    return (diffcol == 2 && diffrow == 1) || (diffcol == 1 && diffrow == 2)

bool validBishopMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearDiaganolExcept(from,to,board)

bool validRookMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board)

bool validQueenMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board) ||
        clearDiaganolExcept(from,to,board)

bool validKingMove(bool isWhite, Pos from, Pos to, bool isTake, Board board):
    diffcol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    diffrow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
    return diffcol == 1 || diffrow == 1

// =============================================================
// Apply Move
// =============================================================

Board applyMove(Move move, Board board) throws Invalid:
    nboard = applyMoveDispatch(move,board)
    if !validMove(move,board,nboard):
        throw Invalid(board,move)
    else:
        return nboard

Board applyMoveDispatch(Move move, Board board) throws Invalid:
    if move is SingleMove:
        // SingleTake is processed in the same way
        return applySingleMove(move,board)
    else if move is CheckMove:
        return applyMove(move.check,board)
    else if move is CastleMove:
        return applyCastleMove(move,board)
    return board

Board applySingleMove(SingleMove move, Board board):
    from = move.from
    to = move.to
    board.rows[from.row][from.col] = null
    board.rows[to.row][to.col] = move.piece
    return board

Board applyCastleMove(CastleMove move, Board board):
    row = 7
    if move.isWhite:
        row = 0
    king = board.rows[row][4]
    board.rows[row][4] = null   
    if move.kingSide:
        rook = board.rows[row][7]
        board.rows[row][7] = null
        board.rows[row][6] = king
        board.rows[row][5] = rook
    else:
        rook = board.rows[row][0]
        board.rows[row][0] = null
        board.rows[row][2] = king
        board.rows[row][3] = rook
    return board

string pos2str(Pos p):
    return "" + ('a' + p.col) + ('1' + p.row)

string toString(Move m):
    if m is SingleMove:
        return piece2str(m.piece) + pos2str(m.from) + "x" + pos2str(m.to)
    else if m is SingleTake:
        return piece2str(m.piece) + pos2str(m.from) + pos2str(m.to)
    else if m is CastleMove:
        if m.kingSide:
            return "O-O"
        else:
            return "O-O-O"
    else: 
        // CheckMove
        // return toString(m.check) + "+"  FIXME
        return "???+"
