import whiley.lang.*
import * from Board
import * from Move

// =============================================================
// Types
// =============================================================

public define RankPos as { int row }
public define FilePos as { int col }
public define ShortPos as Pos | RankPos | FilePos | null

public define ShortSingleMove as { Piece piece, ShortPos from, Pos to, bool isTake }
public define ShortCheckMove as { ShortMove check }

public define ShortMove as ShortSingleMove | ShortCheckMove | CastleMove
public define ShortRound as (ShortMove,ShortMove|null)

public ShortSingleMove Simple(Piece piece, ShortPos from, Pos to, bool isTake):
    return {piece: piece, from: from, to: to, isTake: isTake}

public ShortCheckMove Check(ShortMove move):
    return {check: move}

// =============================================================
// Errors
// =============================================================

public define Invalid as { ShortMove move, Board board }
public Invalid Invalid(Board b, ShortMove m):
    return { board: b, move: m }

// =============================================================
// Move dispatch
// =============================================================

Board apply(ShortMove move, Board board) throws Move.Invalid|Invalid:
    move = inferMove(move,board)
    return applyMove(move,board)

// =============================================================
// Move inference
// =============================================================

Move inferMove(ShortMove m, Board b) throws Invalid:
    return inferMove(m, b, false)

Move inferMove(ShortMove m, Board b, bool isCheck) throws Invalid:
    if m is CastleMove:
        return m
    else if m is ShortCheckMove:
        try:
            m = inferMove(m.check,b,true)
            return {check: m}
        catch(Invalid e):
            throw Invalid(e.board,{check: e.move})
    else if m is ShortSingleMove:
        matches = Board.findPiece(m.piece,b)
        matches = narrowTarget(m,matches,b, isCheck)
        matches = narrowShortPos(m.from,matches)
        if |matches| == 1:
            if m.isTake:
                piece = squareAt(m.to,b)
                // null check needed for type system, but we know it must succeed
                if piece != null:
                    return { piece: m.piece, from: matches[0], to: m.to, taken: piece }
                else:
                    // dead-code
                    return { piece: WHITE_PAWN, from: A2, to: A3 }
            else:
                return { piece: m.piece, from: matches[0], to: m.to }
        else:
            throw Invalid(b,m)
    else:
        throw Invalid(b,m)

// nawwor based on move destination
[Pos] narrowTarget(ShortSingleMove sm, [Pos] matches, Board b, bool isCheck):
    if sm.isTake:
        taken = squareAt(sm.to,b)
        if taken is null:
            return []
        r = []
        for pos in matches:
            move = Move.SingleMove(sm.piece, pos, sm.to, taken)
            if isCheck:
                move = Move.Check(move)
            if validMove(move,b):
                r = r + [pos]
    else:
        r = []
        for pos in matches:
            move = Move.SingleMove(sm.piece, pos, sm.to)
            if isCheck:
                move = {check: move}
            if validMove(move,b):
                r = r + [pos]
    return r


// narrow matches based on short position
[Pos] narrowShortPos(ShortPos pos, [Pos] matches):
    if pos is null:
        return matches
    else:
        r = []
        for p in matches:
            if pos is RankPos && p.row == pos.row:
                r = r + [p]
            else if pos is FilePos && p.col == pos.col:
                r = r + [p]                
            else if p == pos:
                r = r + [p]
        return r

string shortPos2str(ShortPos p):
    if p is null:
        return ""
    else if p is RankPos:
        return "" + (char) ('1' + p.row)
    else if p is FilePos:
        return "" + (char) ('a' + p.col)
    else: 
        return pos2str(p)

string toString(ShortMove m):
    if m is ShortSingleMove: 
        if m.isTake:
            return piece2str(m.piece) + shortPos2str(m.from) + "x" + pos2str(m.to)
        else:
            return piece2str(m.piece) + shortPos2str(m.from) + pos2str(m.to)
    else if m is CastleMove:
        if m.kingSide:
            return "O-O"
        else:
            return "O-O-O"
    else if m is CheckMove: 
        // ShortCheckMove
        return Move.toString(m.check) + "+"  
    else:
        return "" // dead-code

