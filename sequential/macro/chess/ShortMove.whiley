import whiley.lang.*
import Board:*
import Move:*

define RankPos as { int row }
define FilePos as { int col }
define ShortPos as Pos | RankPos | FilePos | null

define ShortSingleMove as { Piece piece, ShortPos from, Pos to, bool isTake }
define ShortCheckMove as { ShortMove check }

define ShortMove as ShortSingleMove | ShortCheckMove | CastleMove
define ShortRound as (ShortMove,ShortMove|null)

Board apply(ShortMove move, Board board) throws InvalidMove:
    move = inferMove(move,board)
    return applyMove(move,board)

Move inferMove(ShortMove m, Board b) throws InvalidMove:
    if m is CastleMove:
        return m
    else if m is ShortCheckMove:
        m = inferMove(m.check, b)
        return { check: m }
    else:
        matches = findPiece(m.piece,b)
        matches = narrowTarget(m,matches,b)
        matches = narrowShortPos(m.from,matches)
        if |matches| == 1:
            if m.isTake:
                piece = squareAt(m.to,b)
                // null check needed for type system, but we know it must succeed
                if piece != null:
                    return { piece: m.piece, from: matches[0], to: m.to, taken: piece }
            else:
                return { piece: m.piece, from: matches[0], to: m.to }
        else:
            throw { board: b, move: m }
    // BUG: what does the following line do??
    return { piece: WHITE_PAWN, from: A2, to: A3 }

// nawwor based on move destination
[Pos] narrowTarget(ShortSingleMove sm, [Pos] matches, Board b):
    if sm.isTake:
        taken = squareAt(sm.to,b)
        if taken is null:
            return []
        r = []
        for pos in matches:
            move = { piece: sm.piece, from: pos, to: sm.to, taken: taken }
            if validMove(move,b):
                r = r + [pos]
    else:
        r = []
        for pos in matches:
            move = { piece: sm.piece, from: pos, to: sm.to }
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
        return "" + ('1' + p.row)
    else if p is FilePos:
        return "" + ('a' + p.col)
    else: 
        return pos2str(p)

// FIXME: this name is wrong.
string toShortMoveString(ShortMove m):
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
    else: 
        // ShortCheckMove
        return toShortMoveString(m.check) + "+"  

