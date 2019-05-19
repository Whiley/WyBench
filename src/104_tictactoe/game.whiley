import Board from board
import Piece from board
import Index from board
import BLANK from board
import CIRCLE from board
import CROSS from board
import get from board

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
public function play(Game state, Index row, Index col) -> Game
// There cannot be a piece already at the position to play on
requires get(state.board,row,col) == BLANK:
	// Place a CIRCLE if its circle's turn
	if state.circlesTurn:
		state.board[(row*3)+col] = CIRCLE
	else:
		state.board[(row*3)+col] = CROSS
	// Update turn to other player
	state.circlesTurn = !state.circlesTurn
	// Done.
	return state
