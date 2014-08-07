import whiley.lang.*

// =============================================================
// Pieces
// =============================================================

public constant PAWN is 0
public constant KNIGHT is 1 
public constant BISHOP is 2
public constant ROOK is 3
public constant QUEEN is 4
public constant KING is 5
public constant PIECE_CHARS is [ 'P', 'N', 'B', 'R', 'Q', 'K' ]

public constant PieceKind is { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }
public type Piece is { PieceKind kind, bool colour }

public constant WHITE_PAWN is { kind: PAWN, colour: true }
public constant WHITE_KNIGHT is { kind: KNIGHT, colour: true }
public constant WHITE_BISHOP is { kind: BISHOP, colour: true }
public constant WHITE_ROOK is { kind: ROOK, colour: true }
public constant WHITE_QUEEN is { kind: QUEEN, colour: true }
public constant WHITE_KING is { kind: KING, colour: true }

public constant BLACK_PAWN is { kind: PAWN, colour: false }
public constant BLACK_KNIGHT is { kind: KNIGHT, colour: false }
public constant BLACK_BISHOP is { kind: BISHOP, colour: false }
public constant BLACK_ROOK is { kind: ROOK, colour: false }
public constant BLACK_QUEEN is { kind: QUEEN, colour: false }
public constant BLACK_KING is { kind: KING, colour: false }

// =============================================================
// Positions
// =============================================================

public type RowCol is int // where 0 <= $ && $ <= 8
public type Pos is { RowCol col, RowCol row } 

public constant A1 is { col: 0, row: 0 }
public constant A2 is { col: 0, row: 1 }
public constant A3 is { col: 0, row: 2 }
public constant A4 is { col: 0, row: 3 }
public constant A5 is { col: 0, row: 4 }
public constant A6 is { col: 0, row: 5 }
public constant A7 is { col: 0, row: 6 }
public constant A8 is { col: 0, row: 7 }

public constant B1 is { col: 1, row: 0 }
public constant B2 is { col: 1, row: 1 }
public constant B3 is { col: 1, row: 2 }
public constant B4 is { col: 1, row: 3 }
public constant B5 is { col: 1, row: 4 }
public constant B6 is { col: 1, row: 5 }
public constant B7 is { col: 1, row: 6 }
public constant B8 is { col: 1, row: 7 }

public constant C1 is { col: 2, row: 0 }
public constant C2 is { col: 2, row: 1 }
public constant C3 is { col: 2, row: 2 }
public constant C4 is { col: 2, row: 3 }
public constant C5 is { col: 2, row: 4 }
public constant C6 is { col: 2, row: 5 }
public constant C7 is { col: 2, row: 6 }
public constant C8 is { col: 2, row: 7 }

// =============================================================
// board
// =============================================================

public type Square is Piece | null
public type Row is [Square] // where |$| == 8
public type Board is {
    [Row] rows, 
    bool whiteCastleKingSide,
    bool whiteCastleQueenSide,
    bool blackCastleKingSide,
    bool blackCastleQueenSide
}    

constant startingChessRows is [
    [ WHITE_ROOK,WHITE_KNIGHT,WHITE_BISHOP,WHITE_QUEEN,WHITE_KING,WHITE_BISHOP,WHITE_KNIGHT,WHITE_ROOK ], // rank 1
    [ WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN ],          // rank 2
    [ null, null, null, null, null, null, null, null ],                                                   // rank 3
    [ null, null, null, null, null, null, null, null ],                                                   // rank 4
    [ null, null, null, null, null, null, null, null ],                                                   // rank 5
    [ null, null, null, null, null, null, null, null ],                                                   // rank 6
    [ BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN ],          // rank 7
    [ BLACK_ROOK,BLACK_KNIGHT,BLACK_BISHOP,BLACK_QUEEN,BLACK_KING,BLACK_BISHOP,BLACK_KNIGHT,BLACK_ROOK ]  // rank 8
]

public constant startingChessBoard is {
    rows: startingChessRows,
    whiteCastleKingSide: true,  // White can still castle king side
    whiteCastleQueenSide: true, // White can still castle queen side
    blackCastleKingSide: true,  // Black can still castle king side
    blackCastleQueenSide: true  // Black can still castle queen side
}

// =============================================================
// Helper Functions
// =============================================================

public function squareAt(Pos p, Board b) => Square:
    return b.rows[p.row][p.col]

// The following method checks whether a given row is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
public function clearRowExcept(Pos from, Pos to, Board board) => bool:
    // check this is really a row
    if from.row != to.row || from.col == to.col:
        return false
    int inc = sign(from.col,to.col)
    int row = from.row
    int col = from.col + inc
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
public function clearColumnExcept(Pos from, Pos to, Board board) => bool:
    if from.col != to.col || from.row == to.row:
        return false
    int inc = sign(from.row,to.row)
    int row = from.row + inc
    int col = from.col
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
public function clearDiaganolExcept(Pos from, Pos to, Board board) => bool:
    // check this is really a diaganol
    int diffcol = Math.max(from.col,to.col) - Math.min(from.col,to.col)
    int diffrow = Math.max(from.row,to.row) - Math.min(from.row,to.row)
    if diffcol != diffrow:
        return false
    // determine the col and row signs
    int colinc = sign(from.col,to.col)
    int rowinc = sign(from.row,to.row)
    // finally, walk the line!
    int row = from.row + rowinc
    int col = from.col + colinc
    while row != to.row && col != to.col:
        if board.rows[row][col] is null:
            col = col + colinc
            row = row + rowinc
        else:
            return false
    // ok, looks like we're clear
    return true 

function sign(int x, int y) => int:
    if x < y:
        return 1
    else:
        return -1
    
// This method finds a given piece.  It's used primarily to locate
// kings on the board to check if they are in check.
public function findPiece(Piece p, Board b) => [Pos]:
    [Pos] matches = []
    for r in 0 .. 8:
        for c in 0 .. 8:
            if b.rows[r][c] == p:
                // ok, we've located the piece
                matches = matches ++ [{ row: r, col: c }]
    // couldn't find the piece
    return matches

// =============================================================
// I/O Functions
// =============================================================

constant BLACK_PIECE_CHARS is [ 'p', 'n', 'b', 'r', 'q', 'k' ]

public function toString(Board b) => string:
    string r = ""
    int i = 8
    while i >= 1:
        r = r ++ i ++ row2str(b.rows[i-1])
        i = i - 1
    return r ++ "  a b c d e f g h\n"

public function row2str(Row row) => string:
    string r = ""
    for square in row:
        r = r ++ "|" ++ square2str(square)
    return r ++ "|\n"

public function square2str(Square p) => string:
    if p is null:
        return "_"
    else if p.colour:
        return "" ++ PIECE_CHARS[p.kind]
    else:
        return "" ++ BLACK_PIECE_CHARS[p.kind]

public function piece2str(Piece p) => string:
    if p.kind == PAWN:
        return ""
    else:
        return "" ++ PIECE_CHARS[p.kind]
