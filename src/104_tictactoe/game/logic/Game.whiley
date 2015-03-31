package game.logic

/**
 * The Game State consists of a board and a boolean
 * indicating whether or not it's circles turn to play.
 */
public type Game is {
	Board board,
	bool circlesTurn // true if circles turn
}

/**
 * Return the initial board state
 */
public function Game() -> Game:
	return {
		board: Board(),
		circlesTurn: true // circle always goes first
	}

/**
 * Place a piece on the board at a given row and column 
 * by the next player. 
 */
public function play(Game state, Board.Index row, Board.Index col) -> Game
// There cannot be a piece already at the position to play on
requires Board.get(state.board,row,col) == Board.BLANK:
	// Place a CIRCLE if its circle's turn
	if state.circlesTurn:
		state.board[(row*3)+col] = Board.CIRCLE
	else:
		state.board[(row*3)+col] = Board.CROSS
	// Update turn to other player
	state.circlesTurn = !state.circlesTurn
	// Done.
	return state