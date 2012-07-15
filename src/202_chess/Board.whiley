import whiley.lang.*

// =============================================================
// Pieces
// =============================================================

public define PAWN as 0
public define KNIGHT as 1 
public define BISHOP as 2
public define ROOK as 3
public define QUEEN as 4
public define KING as 5
public define PIECE_CHARS as [ 'P', 'N', 'B', 'R', 'Q', 'K' ]

public define PieceKind as { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
public define Piece as { PieceKind kind, bool colour }

public define WHITE_PAWN as { kind: PAWN, colour: true }
public define WHITE_KNIGHT as { kind: KNIGHT, colour: true }
public define WHITE_BISHOP as { kind: BISHOP, colour: true }
public define WHITE_ROOK as { kind: ROOK, colour: true }
public define WHITE_QUEEN as { kind: QUEEN, colour: true }
public define WHITE_KING as { kind: KING, colour: true }

public define BLACK_PAWN as { kind: PAWN, colour: false }
public define BLACK_KNIGHT as { kind: KNIGHT, colour: false }
public define BLACK_BISHOP as { kind: BISHOP, colour: false }
public define BLACK_ROOK as { kind: ROOK, colour: false }
public define BLACK_QUEEN as { kind: QUEEN, colour: false }
public define BLACK_KING as { kind: KING, colour: false }

// =============================================================
// Positions
// =============================================================

public define RowCol as int // where 0 <= $ && $ <= 8
public define Pos as { RowCol col, RowCol row } 

public define A1 as { col: 0, row: 0 }
public define A2 as { col: 0, row: 1 }
public define A3 as { col: 0, row: 2 }
public define A4 as { col: 0, row: 3 }
public define A5 as { col: 0, row: 4 }
public define A6 as { col: 0, row: 5 }
public define A7 as { col: 0, row: 6 }
public define A8 as { col: 0, row: 7 }

public define B1 as { col: 1, row: 0 }
public define B2 as { col: 1, row: 1 }
public define B3 as { col: 1, row: 2 }
public define B4 as { col: 1, row: 3 }
public define B5 as { col: 1, row: 4 }
public define B6 as { col: 1, row: 5 }
public define B7 as { col: 1, row: 6 }
public define B8 as { col: 1, row: 7 }

public define C1 as { col: 2, row: 0 }
public define C2 as { col: 2, row: 1 }
public define C3 as { col: 2, row: 2 }
public define C4 as { col: 2, row: 3 }
public define C5 as { col: 2, row: 4 }
public define C6 as { col: 2, row: 5 }
public define C7 as { col: 2, row: 6 }
public define C8 as { col: 2, row: 7 }

// =============================================================
// board
// =============================================================

public define Square as Piece | null
public define Row as [Square] // where |$| == 8
public define Board as {
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

public define startingChessBoard as {
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
    diffcol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    diffrow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
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
[Pos] findPiece(Piece p, Board b):
    matches = []
    for r in range(0,8):
        for c in range(0,8):
            if b.rows[r][c] == p:
                // ok, we've located the piece
                matches = matches + [{ row: r, col: c }]
    // couldn't find the piece
    return matches

// range should be built in!
[int] range(int start, int end):
    r = []
    while start < end:
        r = r + [start]
        start = start + 1
    return r

// =============================================================
// I/O Functions
// =============================================================

define BLACK_PIECE_CHARS as [ 'p', 'n', 'b', 'r', 'q', 'k' ]

string toString(Board b):
    r = ""
    i=8
    while i >= 1:
        r = r + i + row2str(b.rows[i-1])
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

string piece2str(Piece p):
    if p.kind == PAWN:
        return ""
    else:
        return "" + PIECE_CHARS[p.kind]
