package game.logic

/**
 * The Game State consists of a board and a boolean
 * indicating whether or not it's circles turn to play.
 */
public define Game as {
	Board board,
	bool circlesTurn // true if circles turn
}

/**
 * Return the initial board state
 */
public Game Game():
	return {
		board: Board(),
		circlesTurn: true // circle always goes first
	}

/**
 * Place a piece on the board at a given row and column 
 * by the next player. 
 */
public Game play(Game state, Board.Index row, Board.Index col) requires Board.get(state.board,row,col) == Board.BLANK:
	// Place a CIRCLE if its circle's turn
	if state.circlesTurn:
		state.board[(row*3)+col] = Board.CIRCLE
	else:
		state.board[(row*3)+col] = Board.CROSS
	// Update turn to other player
	state.circlesTurn = !state.circlesTurn
	// Done.
	return state