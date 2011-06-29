// =============================================================
// Pieces
// =============================================================

define PAWN as 0
define KNIGHT as 1 
define BISHOP as 2
define ROOK as 3
define QUEEN as 4
define KING as 5
define PIECE_CHARS as [ 'P', 'N', 'B', 'R', 'Q', 'K' ]

define PieceKind as { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
define Piece as { PieceKind kind, bool colour }

define WHITE_PAWN as { kind: PAWN, colour: true }
define WHITE_KNIGHT as { kind: KNIGHT, colour: true }
define WHITE_BISHOP as { kind: BISHOP, colour: true }
define WHITE_ROOK as { kind: ROOK, colour: true }
define WHITE_QUEEN as { kind: QUEEN, colour: true }
define WHITE_KING as { kind: KING, colour: true }

define BLACK_PAWN as { kind: PAWN, colour: false }
define BLACK_KNIGHT as { kind: KNIGHT, colour: false }
define BLACK_BISHOP as { kind: BISHOP, colour: false }
define BLACK_ROOK as { kind: ROOK, colour: false }
define BLACK_QUEEN as { kind: QUEEN, colour: false }
define BLACK_KING as { kind: KING, colour: false }

// =============================================================
// Positions
// =============================================================

define RowCol as int // where 0 <= $ && $ <= 8
define Pos as { RowCol col, RowCol row } 

define A1 as { col: 0, row: 0 }
define A2 as { col: 0, row: 1 }
define A3 as { col: 0, row: 2 }
define A4 as { col: 0, row: 3 }
define A5 as { col: 0, row: 4 }
define A6 as { col: 0, row: 5 }
define A7 as { col: 0, row: 6 }
define A8 as { col: 0, row: 7 }

define B1 as { col: 1, row: 0 }
define B2 as { col: 1, row: 1 }
define B3 as { col: 1, row: 2 }
define B4 as { col: 1, row: 3 }
define B5 as { col: 1, row: 4 }
define B6 as { col: 1, row: 5 }
define B7 as { col: 1, row: 6 }
define B8 as { col: 1, row: 7 }

define C1 as { col: 2, row: 0 }
define C2 as { col: 2, row: 1 }
define C3 as { col: 2, row: 2 }
define C4 as { col: 2, row: 3 }
define C5 as { col: 2, row: 4 }
define C6 as { col: 2, row: 5 }
define C7 as { col: 2, row: 6 }
define C8 as { col: 2, row: 7 }

// =============================================================
// board
// =============================================================

define Square as Piece | null
define Row as [Square] // where |$| == 8
define Board as {
    [Row] rows, 
    bool whiteCastleKingSide,
    bool whiteCastleQueenSide,
    bool blackCastleKingSide,
    bool blackCastleQueenSide
}    

define startingChessRows as [
    [ WHITE_ROOK,WHITE_KNIGHT,WHITE_BISHOP,WHITE_QUEEN,WHITE_KING,WHITE_BISHOP,WHITE_KNIGHT,WHITE_ROOK ], // rank 1
    [ WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN ],          // rank 2
    [ null, null, null, null, null, null, null, null ],                                                   // rank 3
    [ null, null, null, null, null, null, null, null ],                                                   // rank 4
    [ null, null, null, null, null, null, null, null ],                                                   // rank 5
    [ null, null, null, null, null, null, null, null ],                                                   // rank 6
    [ BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN ],          // rank 7
    [ BLACK_ROOK,BLACK_KNIGHT,BLACK_BISHOP,BLACK_QUEEN,BLACK_KING,BLACK_BISHOP,BLACK_KNIGHT,BLACK_ROOK ]  // rank 8
]

define startingChessBoard as {
    rows: startingChessRows,
    whiteCastleKingSide: true,  // White can still castle king side
    whiteCastleQueenSide: true, // White can still castle queen side
    blackCastleKingSide: true,  // Black can still castle king side
    blackCastleQueenSide: true  // Black can still castle queen side
}

// =============================================================
// Helper Functions
// =============================================================

Square squareAt(Pos p, Board b):
    return b.rows[p.row][p.col]

// The following method checks whether a given row is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearRowExcept(Pos from, Pos to, Board board):
    // check this is really a row
    if from.row != to.row || from.col == to.col:
        return false
    inc = sign(from.col,to.col)
    row = from.row
    col = from.col + inc
    while col != to.col:
        if board.rows[row][col] is null:
            col = col + inc
        else:
            return false        
    return true

// The following method checks whether a given column is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearColumnExcept(Pos from, Pos to, Board board):
    if from.col != to.col || from.row == to.row:
        return false
    inc = sign(from.row,to.row)
    row = from.row + inc
    col = from.col
    while row != to.row:
        if board.rows[row][col] is null:
            row = row + inc
        else:
            return false            
    return true

// The following method checks whether the given diaganol is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
bool clearDiaganolExcept(Pos from, Pos to, Board board):
    // check this is really a diaganol
    diffcol = max(from.col,to.col) - min(from.col,to.col)
    diffrow = max(from.row,to.row) - min(from.row,to.row)
    if diffcol != diffrow:
        return false
    // determine the col and row signs
    colinc = sign(from.col,to.col)
    rowinc = sign(from.row,to.row)
    // finally, walk the line!
    row = from.row + rowinc
    col = from.col + colinc
    while row != to.row && col != to.col:
        if board.rows[row][col] is null:
            col = col + colinc
            row = row + rowinc
        else:
            return false
    // ok, looks like we're clear
    return true 

int sign(int x, int y):
    if x < y:
        return 1
    else:
        return -1
    
// This method finds a given piece.  It's used primarily to locate
// kings on the board to check if they are in check.
Pos|null findPiece(Piece p, Board b):
    for r in range(0,8):
        for c in range(0,8):
            if b.rows[r][c] == p:
                // ok, we've located the piece
                return { row: r, col: c }            
    // could find the piece
    return null

// range should be built in!
[int] range(int start, int end):
    r = []
    while start < end:
        r = r + [start]
        start = start + 1
    return r

// max should be in standard library!
int max(int a, int b):
    if a < b:
        return b
    else:
        return a

// min should be in standard library!
int min(int a, int b):
    if a > b:
        return b
    else:
        return a

