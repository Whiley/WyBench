define RankPos as { int row }
define FilePos as { int col }
define ShortPos as Pos | RankPos | FilePos | null

define ShortSingleMove as { Piece piece, ShortPos from, Pos to, bool isTake }
define ShortCheckMove as { ShortSingleMove move }

define ShortMove as ShortSingleMove | ShortCheckMove | CastleMove
define ShortRound as (ShortMove,ShortMove|null)

Board applyShortMove(ShortMove move, Board board) throws SyntaxError:
    move = inferMove(move,board)
    return applyMove(move,board)

Move inferMove(ShortMove move, Board board) throws SyntaxError:
    return { piece: WHITE_PAWN, from: A2, to: A3 }