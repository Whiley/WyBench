define RankPos as { int row }
define FilePos as { int col }
define ShortPos as Pos | RankPos | FilePos | null

define ShortSingleMove as { Piece piece, ShortPos from, Pos to, bool isTake }
define ShortCheckMove as { ShortSingleMove move }

define ShortMove as ShortSingleMove | ShortCheckMove | CastleMove
define ShortRound as (ShortMove,ShortMove|null)

Board applyShortMove(ShortMove move, Board board) throws InvalidMove:
    move = inferMove(move,board)
    return applyMove(move,board)

Move inferMove(ShortMove m, Board b) throws InvalidMove:
    if m is CastleMove:
        return m
    else if m is ShortCheckMove:
        m = inferMove(m.move, b)
        return { check: m }
    else if m is ShortSingleMove:
        matches = findPiece(m.piece,b)
        matches = narrowTarget(m,matches,b)
        matches = narrowShortPos(m.from,matches)
        if |matches| == 1:
            return { piece: m.piece, from: matches[0], to: m.to }
        else:
            throw { board: b, move: m }
    // following line should cause an error
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