import whiley.lang.*
import * from Board
import * from Move

// =============================================================
// Types
// =============================================================

public type RankPos is { int row }
public type FilePos is { int col }
public type ShortPos is Pos | RankPos | FilePos | null

public type ShortSingleMove is { Piece piece, ShortPos from, Pos to, bool isTake }
public type ShortCheckMove is { ShortMove check }

public type ShortMove is ShortSingleMove | ShortCheckMove | CastleMove
public type ShortRound is (ShortMove,ShortMove|null)

public function Simple(Piece piece, ShortPos from, Pos to, bool isTake) => ShortSingleMove:
    return {piece: piece, from: from, to: to, isTake: isTake}

public function Check(ShortMove move) => ShortCheckMove:
    return {check: move}

// =============================================================
// Errors
// =============================================================

public type Invalid is { ShortMove move, Board board }
public function Invalid(Board b, ShortMove m) => Invalid:
    return { board: b, move: m }

// =============================================================
// Move dispatch
// =============================================================

public function apply(ShortMove move, Board board) => Board
throws Move.Invalid|Invalid:
    //
    Move m = inferMove(move,board)
    return applyMove(m,board)

// =============================================================
// Move inference
// =============================================================

public function inferMove(ShortMove m, Board b) => Move
throws Invalid:
    //
    return inferMove(m, b, false)

public function inferMove(ShortMove move, Board b, bool isCheck) => Move 
throws Invalid:
    //
    if move is CastleMove:
        return move
    else if move is ShortCheckMove:
        try:
            Move m = inferMove(move.check,b,true)
            return {check: m}
        catch(Invalid e):
            throw Invalid(e.board,{check: e.move})
    else if move is ShortSingleMove:
        [Pos] matches = Board.findPiece(move.piece,b)
        matches = narrowTarget(move,matches,b, isCheck)
        matches = narrowShortPos(move.from,matches)
        if |matches| == 1:
            if move.isTake:
                Square piece = squareAt(move.to,b)
                // null check needed for type system, but we know it must succeed
                if piece != null:
                    return { piece: move.piece, from: matches[0], to: move.to, taken: piece }
                else:
                    // dead-code
                    return { piece: WHITE_PAWN, from: A2, to: A3 }
            else:
                return { piece: move.piece, from: matches[0], to: move.to }
        else:
            throw Invalid(b,move)
    else:
        throw Invalid(b,move)

// nawwor based on move destination
function narrowTarget(ShortSingleMove sm, [Pos] matches, Board b, bool isCheck) => [Pos]:
    [Pos] r = []
    if sm.isTake:
        Square taken = squareAt(sm.to,b)
        if taken is null:
            return r
        for pos in matches:
            Move move = Move.SingleMove(sm.piece, pos, sm.to, taken)
            if isCheck:
                move = Move.Check(move)
            if validMove(move,b):
                r = r ++ [pos]
    else:
        for pos in matches:
            Move move = Move.SingleMove(sm.piece, pos, sm.to)
            if isCheck:
                move = {check: move}
            if validMove(move,b):
                r = r ++ [pos]
    return r


// narrow matches based on short position
function narrowShortPos(ShortPos pos, [Pos] matches) => [Pos]:
    if pos is null:
        return matches
    else:
        [Pos] r = []
        for p in matches:
            if pos is RankPos && p.row == pos.row:
                r = r ++ [p]
            else if pos is FilePos && p.col == pos.col:
                r = r ++ [p]                
            else if p == pos:
                r = r ++ [p]
        return r

function shortPos2str(ShortPos p) => string:
    if p is null:
        return ""
    else if p is RankPos:
        return "" ++ ('1' + (char) p.row)
    else if p is FilePos:
        return "" ++ ('a' + (char) p.col)
    else: 
        return pos2str(p)

public function toString(ShortMove m) => string:
    if m is ShortSingleMove: 
        if m.isTake:
            return piece2str(m.piece) ++ shortPos2str(m.from) ++ "x" ++ pos2str(m.to)
        else:
            return piece2str(m.piece) ++ shortPos2str(m.from) ++ pos2str(m.to)
    else if m is CastleMove:
        if m.kingSide:
            return "O-O"
        else:
            return "O-O-O"
    else if m is CheckMove: 
        // ShortCheckMove
        return Move.toString(m.check) ++ "+"  
    else:
        return "" // dead-code

