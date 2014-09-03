import whiley.lang.*
import * from Board

// A simple chess model
//
// David J. Pearce, 2010

// =============================================================
// Moves
// =============================================================

public type SingleMove is { Piece piece, Pos from, Pos to }
public type SingleTake is { Piece piece, Pos from, Pos to, Piece taken }
public type SimpleMove is SingleMove | SingleTake

public type CastleMove is { bool isWhite, bool kingSide }
public type CheckMove is { Move check }

public type Move is CheckMove | CastleMove | SimpleMove

// constructors

public function SingleMove(Piece piece, Pos from, Pos to) => SingleMove:
    return {piece: piece, from: from, to: to}

public function SingleMove(Piece piece, Pos from, Pos to, Piece taken) => SingleTake:
    return {piece: piece, from: from, to: to, taken: taken}

public function Check(Move move) => CheckMove:
    return {check: move}

public function Castle(bool isWhite, bool kingSide) => CastleMove:
    return {isWhite: isWhite, kingSide: kingSide}

// =============================================================
// Errors
// =============================================================

public type Invalid is { Move move, Board board }

public function Invalid(Board b, Move m) => Invalid:
    return { board: b, move: m }

// en passant

// =============================================================
// Valid Move Dispatch
// =============================================================

// The purpose of the validMove method is to check whether or not a
// move is valid on a given board.
public function validMove(Move move, Board board) => bool:
    Board nboard = applyMoveDispatch(move,board)
    return validMove(move,board,nboard)

function validMove(Move move, Board board, Board nboard) => bool:
    bool oppCheck
    bool isWhite
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

function internalValidMove(Move move, Board board) => bool:
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

function validPieceMove(Piece piece, Pos from, Pos to, bool isTake, Board board) => bool:
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
function validPiece(Piece piece, Pos pos, Board board) => bool:
    Square sq = squareAt(pos,board)
    if sq is null:
        return false
    else:
        return sq == piece

// Determine whether the board is in check after the given move, with
// respect to the opposite colour of the move.
function inCheck(bool isWhite, Board board) => bool:
    Pos kpos
    //
    if isWhite:
        kpos = findPiece(WHITE_KING,board)[0]
    else:
        kpos = findPiece(BLACK_KING,board)[0]     
    // check every possible piece cannot take king
    for r in 0 .. 8:
        for c in 0 .. 8:
            Square tmp = board.rows[r][c]
            if !(tmp is null) && tmp.colour == !isWhite && 
                validPieceMove(tmp,{row: r, col: c},kpos,true,board):
                return true
    // no checks found
    return false

function validCastle(CastleMove move, Board board) => bool:
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

function validPawnMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    int rowdiff
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

function validKnightMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    int diffCol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    int diffRow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
    return (diffCol == 2 && diffRow == 1) || (diffCol == 1 && diffRow == 2)

function validBishopMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    return clearDiaganolExcept(from,to,board)

function validRookMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board)

function validQueenMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    return clearRowExcept(from,to,board) || clearColumnExcept(from,to,board) ||
        clearDiaganolExcept(from,to,board)

function validKingMove(bool isWhite, Pos from, Pos to, bool isTake, Board board) => bool:
    int diffCol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    int diffRow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
    int total = diffCol + diffRow
    return total > 0 && diffRow >= 0 && diffRow <= 1 && diffCol >= 0 && diffCol <= 1

// =============================================================
// Apply Move
// =============================================================

public function applyMove(Move move, Board board) => Board
throws Invalid:
    //
    Board nboard = applyMoveDispatch(move,board)
    if !validMove(move,board,nboard):
        throw Invalid(board,move)
    else:
        return nboard

function applyMoveDispatch(Move move, Board board) => Board:
    //
    if move is SingleMove|SingleTake:
        // SingleTake is processed in the same way
        return applySingleMove(move,board)
    else if move is CheckMove:
        return applyMoveDispatch(move.check,board)
    else if move is CastleMove:
        return applyCastleMove(move,board)
    return board

function applySingleMove(SingleMove|SingleTake move, Board board) => Board:
    Pos from = move.from
    Pos to = move.to
    board.rows[from.row][from.col] = null
    board.rows[to.row][to.col] = move.piece
    return board

function applyCastleMove(CastleMove move, Board board) => Board:
    int row = 7
    if move.isWhite:
        row = 0
    Square king = board.rows[row][4]
    board.rows[row][4] = null   
    if move.kingSide:
        Square rook = board.rows[row][7]
        board.rows[row][7] = null
        board.rows[row][6] = king
        board.rows[row][5] = rook
    else:
        Square rook = board.rows[row][0]
        board.rows[row][0] = null
        board.rows[row][2] = king
        board.rows[row][3] = rook
    return board

public function pos2str(Pos p) => string:
    return ("" ++ ('a' + (char) p.col)) ++ ('1' + (char) p.row)

public function toString(Move m) => string:
    if m is SingleMove:
        return piece2str(m.piece) ++ pos2str(m.from) ++ "x" ++ pos2str(m.to)
    else if m is SingleTake:
        return piece2str(m.piece) ++ pos2str(m.from) ++ pos2str(m.to)
    else if m is CastleMove:
        if m.kingSide:
            return "O-O"
        else:
            return "O-O-O"
    else: 
        // CheckMove
        // return toString(m.check) + "+"  FIXME
        return "???+"
