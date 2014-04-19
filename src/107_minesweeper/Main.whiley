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
