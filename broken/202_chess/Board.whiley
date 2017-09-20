
// =============================================================
// Pieces
// =============================================================

public int PAWN = 0
public int KNIGHT = 1 
public int BISHOP = 2
public int ROOK = 3
public int QUEEN = 4
public int KING = 5
public int PIECE_CHARS = [ 'P', 'N', 'B', 'R', 'Q', 'K' ]

public type PieceKind is (int x) where PAWN <= x && x <= KING
public type Piece is { PieceKind kind, bool colour }

public Piece WHITE_PAWN = { kind: PAWN, colour: true }
public Piece WHITE_KNIGHT = { kind: KNIGHT, colour: true }
public Piece WHITE_BISHOP = { kind: BISHOP, colour: true }
public Piece WHITE_ROOK = { kind: ROOK, colour: true }
public Piece WHITE_QUEEN = { kind: QUEEN, colour: true }
public Piece WHITE_KING = { kind: KING, colour: true }

public Piece BLACK_PAWN = { kind: PAWN, colour: false }
public Piece BLACK_KNIGHT = { kind: KNIGHT, colour: false }
public Piece BLACK_BISHOP = { kind: BISHOP, colour: false }
public Piece BLACK_ROOK = { kind: ROOK, colour: false }
public Piece BLACK_QUEEN = { kind: QUEEN, colour: false }
public Piece BLACK_KING = { kind: KING, colour: false }

// =============================================================
// Positions
// =============================================================

public type RowCol is int // where 0 <= $ && $ <= 8
public type Pos is { RowCol col, RowCol row } 

public Pos A1 = { col: 0, row: 0 }
public Pos A2 = { col: 0, row: 1 }
public Pos A3 = { col: 0, row: 2 }
public Pos A4 = { col: 0, row: 3 }
public Pos A5 = { col: 0, row: 4 }
public Pos A6 = { col: 0, row: 5 }
public Pos A7 = { col: 0, row: 6 }
public Pos A8 = { col: 0, row: 7 }

public Pos B1 = { col: 1, row: 0 }
public Pos B2 = { col: 1, row: 1 }
public Pos B3 = { col: 1, row: 2 }
public Pos B4 = { col: 1, row: 3 }
public Pos B5 = { col: 1, row: 4 }
public Pos B6 = { col: 1, row: 5 }
public Pos B7 = { col: 1, row: 6 }
public Pos B8 = { col: 1, row: 7 }

public Pos C1 = { col: 2, row: 0 }
public Pos C2 = { col: 2, row: 1 }
public Pos C3 = { col: 2, row: 2 }
public Pos C4 = { col: 2, row: 3 }
public Pos C5 = { col: 2, row: 4 }
public Pos C6 = { col: 2, row: 5 }
public Pos C7 = { col: 2, row: 6 }
public Pos C8 = { col: 2, row: 7 }

// =============================================================
// board
// =============================================================

public type Square is Piece | null
public type Row is Square[] // where |$| == 8
public type Board is {
    Row[] rows, 
    bool whiteCastleKingSide,
    bool whiteCastleQueenSide,
    bool blackCastleKingSide,
    bool blackCastleQueenSide
}    

Piece startingChessRows = [
    [ WHITE_ROOK,WHITE_KNIGHT,WHITE_BISHOP,WHITE_QUEEN,WHITE_KING,WHITE_BISHOP,WHITE_KNIGHT,WHITE_ROOK ], // rank 1
    [ WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN,WHITE_PAWN ],          // rank 2
    [ null, null, null, null, null, null, null, null ],                                                   // rank 3
    [ null, null, null, null, null, null, null, null ],                                                   // rank 4
    [ null, null, null, null, null, null, null, null ],                                                   // rank 5
    [ null, null, null, null, null, null, null, null ],                                                   // rank 6
    [ BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN,BLACK_PAWN ],          // rank 7
    [ BLACK_ROOK,BLACK_KNIGHT,BLACK_BISHOP,BLACK_QUEEN,BLACK_KING,BLACK_BISHOP,BLACK_KNIGHT,BLACK_ROOK ]  // rank 8
]

public Piece startingChessBoard = {
    rows: startingChessRows,
    whiteCastleKingSide: true,  // White can still castle king side
    whiteCastleQueenSide: true, // White can still castle queen side
    blackCastleKingSide: true,  // Black can still castle king side
    blackCastleQueenSide: true  // Black can still castle queen side
}

// =============================================================
// Helper Functions
// =============================================================

public function squareAt(Pos p, Board b) -> Square:
    return b.rows[p.row][p.col]

// The following method checks whether a given row is completely
// clear, excluding the end points. Observe that this doesn't
// guarantee a given diaganol move is valid, since this function does not
// ensure anything about the relative positions of the given pieces.
public function clearRowExcept(Pos from, Pos to, Board board) -> bool:
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
public function clearColumnExcept(Pos from, Pos to, Board board) -> bool:
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
public function clearDiaganolExcept(Pos from, Pos to, Board board) -> bool:
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

function sign(int x, int y) -> int:
    if x < y:
        return 1
    else:
        return -1
    
// This method finds a given piece.  It's used primarily to locate
// kings on the board to check if they are in check.
public function findPiece(Piece p, Board b) -> Pos[]:
    Pos[] matches = [A1;0]
    int r = 0
    while r < 8:
        int c = 0
        while c < 8:
            if b.rows[r][c] == p:
                // ok, we've located the piece
                matches = matches ++ [{ row: r, col: c }]
            c = c + 1
        r = r + 1
    // couldn't find the piece
    return matches

// =============================================================
// I/O Functions
// =============================================================

Piece BLACK_PIECE_CHARS = [ 'p', 'n', 'b', 'r', 'q', 'k' ]

public function toString(Board b) -> ASCII.string:
    ASCII.string r = ""
    int i = 8
    while i >= 1:
        r = r ++ [i] ++ row2str(b.rows[i-1])
        i = i - 1
    return r ++ "  a b c d e f g h\n"

public function row2str(Row row) -> ASCII.string:
    ASCII.string r = ""
    int i = 0
    while i < |row|:
        r = r ++ "|" ++ square2str(row[i])
        i = i + 1
    return r ++ "|\n"

public function square2str(Square p) -> ASCII.string:
    if p is null:
        return "_"
    else if p.colour:
        return [PIECE_CHARS[p.kind]]
    else:
        return [BLACK_PIECE_CHARS[p.kind]]

public function piece2str(Piece p) -> ASCII.string:
    if p.kind == PAWN:
        return ""
    else:
        return [PIECE_CHARS[p.kind]]
