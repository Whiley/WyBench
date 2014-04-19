// =================================================================
// Squares
// =================================================================

// An exposed square is one which has been exposed by the user, and 
// displays its "rank".  The rank is the count of bombs in the eight 
// directly adjacent squares.
type ExposedSquare is { 
  int rank,       // Number of bombs in adjacent squares
  bool holdsBomb  // true if the square holds a bomb
}

// A hidden square is one which has yet to be revealed by the user.  A
// hidden square may contain a bomb and/or have been "flagged" by the
// user
type HiddenSquare is { 
  bool holdsBomb,  // true if the square holds a bomb
  bool flagged     // true if the square is flagged
}

// Every square on the board is either an exposed square or a hidden
// square.
type Square is ExposedSquare | HiddenSquare

// ExposedSquare constructor
function ExposedSquare(int rank, bool bomb) => ExposedSquare:
    return { rank: rank, holdsBomb: bomb }

// HiddenSquare constructor
function HiddenSquare(bool bomb, bool flag) => HiddenSquare:
    return { holdsBomb: bomb, flagged: flag }

// =================================================================
// Board
// =================================================================

type Board is {
   [Square] squares,  // List of squares making up the board
   int width,         // Width of the game board (in squares)
   int height        // Height of the game board (in squares)
}

// Create a board of given dimensions which contains no bombs, and
// where all squares are hidden.
function Board(int width, int height) => Board:
    [Square] squares = []
    //
    for i in 0 .. width * height:
      squares = squares ++ [HiddenSquare(false,false)]
    //
    return {
        squares: squares,
        width: width,
        height: height
    }

// Return the square on a given board at a given position
function getSquare(Board b, int col, int row) => Square:
    int rowOffset = b.width * row // calculate start of row
    return b.squares[rowOffset + col]

// Set the square on a given board at a given position
function setSquare(Board b, int col, int row, Square sq) => Board:
    int rowOffset = b.width * row // calculate start of row
    b.squares[rowOffset + col] = sq
    return b

// =================================================================
// Game Play
// =================================================================
