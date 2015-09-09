// ======================================================
// Squares 
// ======================================================
constant BLANK is 0
constant START is 1
constant DOUBLE_LETTER is 2
constant TRIPLE_LETTER is 3
constant DOUBLE_WORD is 4
constant TRIPLE_WORD is 5

type Square is (int kind) where 0 <= kind && kind <= 4

// ======================================================
// Tiles
// ======================================================
type Tile is {
    int letter,
    int value
}

constant TILE_A is { letter: 'A', value: 1 }
constant TILE_B is { letter: 'B', value: 1 }
constant TILE_C is { letter: 'C', value: 1 }
constant TILE_D is { letter: 'D', value: 1 }
constant TILE_E is { letter: 'E', value: 1 }
constant TILE_F is { letter: 'F', value: 1 }
constant TILE_G is { letter: 'G', value: 1 }
constant TILE_H is { letter: 'H', value: 1 }
constant TILE_I is { letter: 'I', value: 1 }
constant TILE_J is { letter: 'J', value: 1 }
constant TILE_K is { letter: 'K', value: 1 }
constant TILE_L is { letter: 'L', value: 1 }
constant TILE_M is { letter: 'M', value: 1 }
constant TILE_N is { letter: 'N', value: 1 }
constant TILE_O is { letter: 'O', value: 1 }
constant TILE_P is { letter: 'P', value: 1 }
constant TILE_Q is { letter: 'Q', value: 1 }
constant TILE_R is { letter: 'R', value: 1 }
constant TILE_S is { letter: 'S', value: 1 }
constant TILE_T is { letter: 'T', value: 1 }
constant TILE_U is { letter: 'U', value: 1 }
constant TILE_V is { letter: 'V', value: 1 }
constant TILE_W is { letter: 'W', value: 1 }
constant TILE_X is { letter: 'X', value: 1 }
constant TILE_Y is { letter: 'Y', value: 1 }
constant TILE_Z is { letter: 'Z', value: 1 }

// ======================================================
// Tile Rack
// ======================================================

// Wildcard is a blank tile which, when placed, can be turned
// into any tile
type WILDCARD is null

type Rack is {
   (Tile|WILDCARD)[] tiles
} where |tiles| == 7

// ======================================================
// Player
// ======================================================

type Player is {
    Rack tiles,
    int score
} where score >= 0

// ======================================================
// Board
// ======================================================

type Board is {
    // Arrange of tiles and squares
    (Tile|Square)[] squares,
    // Remaining tiles
    Tile[] bag,
    // Players in the game
    Player[] players
} 

