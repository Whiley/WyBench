import std::math with min,max
import uint from std::integer

// =================================================================
// Squares
// =================================================================

// An exposed square is one which has been exposed by the player, and 
// displays its "rank".  The rank is the count of bombs in the eight 
// directly adjacent squares.
type ExposedSquare is {
    bool holdsBomb,
    int rank
} where rank >= 0 && rank <= 8

// A hidden square is one which has yet to be revealed by the player.  A
// hidden square may contain a bomb and/or have been "flagged" by the
// player.
type HiddenSquare is {
    bool holdsBomb,
    bool flagged
}

// Every square on the board is either an exposed square or a hidden
// square.
type Square is ExposedSquare | HiddenSquare

// ExposedSquare constructor
export function ExposedSquare(uint rank, bool bomb) -> ExposedSquare
requires rank <= 8:
    return { rank: rank, holdsBomb: bomb }

// HiddenSquare constructor
export function HiddenSquare(bool bomb, bool flag) -> HiddenSquare:
    return { holdsBomb: bomb, flagged: flag }

// =================================================================
// Board
// =================================================================

type Board is {
   Square[] squares,  // Array of squares making up the board
   uint width,         // Width of the game board (in squares)
   uint height         // Height of the game board (in squares)
} where width*height == |squares|

// Create a board of given dimensions which contains no bombs, and
// where all squares are hidden.
export function Board(uint width, uint height) -> Board
requires (width * height) >= 0:
    Square[] squares = [HiddenSquare(false,false); width * height]
    //
    return {
        squares: squares,
        width: width,
        height: height
    }

// Return the square on a given board at a given position
export function get_square(Board b, uint col, uint row) -> Square
// Ensure arguments within bounds
requires col < b.width && row < b.height:
    int rowOffset = b.width * row // calculate start of row
    assume rowOffset >= 0
    assume rowOffset <= |b.squares|-b.width
    return b.squares[rowOffset + col]

// Set the square on a given board at a given position
export function set_square(Board b, uint col, uint row, Square sq) -> Board
// Ensure arguments within bounds
requires col < b.width && row < b.height:
    int rowOffset = b.width * row // calculate start of row
    assume rowOffset >= 0
    assume rowOffset <= |b.squares|-b.width
    b.squares[rowOffset + col] = sq
    return b

// =================================================================
// Game Play
// =================================================================

export
// Flag (or unflag) a given square on the board.  If this operation is not permitted, then do nothing
// and return the board; otherwise, update the board accordingly.
function flag_square(Board b, uint col, uint row) -> Board
requires col < b.width && row < b.height:
   Square sq = get_square(b,col,row)
   // check whether permitted to flag
   if sq is HiddenSquare:
      // yes, is permitted so reverse flag status and update board
      sq.flagged = !sq.flagged
      b = set_square(b,col,row,sq)
   //
   return b

// Determine the rank of a given square on the board.  That is the
// count of bombs in the adjacent 8 squares.  Observe that, in this
// implementation, we also count any bomb on the central square itself.
// This does not course any specific problem since an exposed square
// containing a bomb signals the end of the game anyway.
function determineRank(Board b, uint col, uint row) -> uint
requires col < b.width && row < b.height:
    uint rank = 0
    // Calculate the rank
    for r in max(0,row-1) .. min(b.height,row+2):
        for c in max(0,col-1) .. min(b.width,col+2):
            Square sq = get_square(b,(uint) c, (uint) r)
            if holds_bomb(sq):
                rank = rank + 1
    //
    return rank

export
// Attempt to recursively expose blank hidden square, starting from a given position.
function expose_square(Board b, uint col, uint row) -> Board
requires col < b.width && row < b.height:
    // Check whether is blank hidden square
    Square sq = get_square(b,col,row)
    uint rank = determineRank(b,col,row)
    if sq is HiddenSquare && !sq.flagged:
        // yes, so expose square
        sq = ExposedSquare(rank,sq.holdsBomb)
        b = set_square(b,col,row,sq)
        if rank == 0:
            // now expose neighbours
            return expose_neighbours(b,col,row)
    //
    return b

// Recursively expose all valid neighbouring squares on the board
function expose_neighbours(Board b, uint col, uint row) -> Board
requires col < b.width && row < b.height:
    for r in max(0,row-1) .. min(b.height,row+2):
        for c in max(0,col-1) .. min(b.width,col+2):
           b = expose_square(b,(uint) c, (uint) r)
    //
    return b

// Determine whether the game is over or not and, if so, whether or
// not the player has one.  The game is over and the player has lost 
// if there is an exposed square on the board which contains a bomb.  
// Likewise, the game is over and the player has one if there are no 
// hidden squares which don't contain a bomb.
export
function is_gameover(Board b) -> (bool gameOver, bool playerWon):
    bool isOver = true
    bool hasWon = true
    // Check all squares are hidden except mines
    for i in 0..|b.squares|:
        Square sq = b.squares[i]
        if sq is HiddenSquare && !sq.holdsBomb:
            // Hidden square which doesn't hold a bomb so game may not be over
            isOver = false
        else if sq is ExposedSquare && sq.holdsBomb:
            // Exposed square which holds a bomb so game definitely over
            isOver = true
            hasWon = false
            break
    //
    return isOver, hasWon

// This method shouldn't really be necessary but, for now, it is.
function holds_bomb(Square sq) -> bool:
    if sq is ExposedSquare:
        return sq.holdsBomb
    else:
        return sq.holdsBomb

// ============================================
// Tests
// ============================================

// A hidden empty square
final HiddenSquare HE = { holdsBomb: false, flagged: false }

// A hidden square containing a bomb
final HiddenSquare HB = { holdsBomb: true, flagged: false }

// An exposed square with rank 1
final ExposedSquare E1 = { holdsBomb: true, rank: 1 }

public method test_01():
    Board b = Board(3,3)
    assume b.squares == [ HE, HE, HE,
                          HE, HE, HE,
                          HE, HE, HE ]

public method test_02():
    Board b = Board(3,3)
    b = set_square(b,1,1,HB)
    assume b.squares == [ HE, HE, HE,
                          HE, HB, HE,
                          HE, HE, HE ]
                        
public method test_03():
    Board b = Board(3,3)
    b = set_square(b,1,1,HB)
    b = expose_square(b,0,0)
    assume b.squares == [ E1, HE, HE,
                          HE, HB, HE,
                          HE, HE, HE ]                        