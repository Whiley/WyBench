package game.logic

public constant BLANK is 0
public constant CROSS is 1
public constant CIRCLE is 2

/**
 * A piece is either a blank, a cross or a circle.
 */
public constant PieceEnum is { BLANK, CROSS, CIRCLE }

public type Piece is PieceEnum // THIS IS A HACK!

/**
 * A Board is a 3x3 grid of pieces
 */
public type Board is ([Piece] ps) where |ps| == 9 && 
	numPieces(ps,CIRCLE) >= numPieces(ps,CROSS) &&
	numPieces(ps,CIRCLE) <= (numPieces(ps,CROSS)+1) 

/**
 * A Board index (for either column or row) is between 0 and 3
 */
public type Index is (int x) where 0 <= x && x < 3

/**
 * Create an empty 3x3 board.
 */
public function Board() => Board:
	Board board = []
	for i in 0 .. 9:
		board = board ++ [BLANK]
	return board

/**
 * Return the piece at a given row and column on the board.
 */
public function get(Board board, Index row, Index col) => Piece:
	return board[(row*3)+col]

/**
 * Set the piece at a tiven row and column on the board.
 */
public function put(Board board, Index row, Index col, Piece piece) => Board:
	board[(row*3)+col] = piece
	return board

/**
 * Count the number of pieces which have been placed on the board.
 */
public function numPieces(Board board, Piece piece) => int:
	int count = 0
	for p in board:
		if p == piece:
			count = count + 1
	return count

/**
 * Check whether there are any more blank squares on the board.
 */
public function isFull(Board board) => bool:
	int count = 0
	for piece in board:
		if piece != BLANK:
			count = count + 1
	return count == 9	

/**
 * Check whether there is a winner, and return the 
 * corresponding piece (if there is) or BLANK (if there isn't)
 */
public function isWinner(Board board) => Piece:
	// First, check rows
	for row in 0..3:
		Piece p = isWinnerRow(board,row)
		if p != BLANK:
			return p
	// Second, check columns
	for col in 0..3:
		Piece p = isWinnerCol(board,col)
		if p != BLANK:
			return p
	// Finally, check diaganols
	// TODO:
	return BLANK

/**
 * Check whether a given row is all the same piece and, if
 * so, which piece it is.
 */
public function isWinnerRow(Board board, int row) => Piece:
	Piece p1 = get(board,row,0)
	Piece p2 = get(board,row,1)
	Piece p3 = get(board,row,2)
	if p1 == p2 && p2 == p3:
		return p1
	else:
		return BLANK

/**
 * Check whether a given row is all the same piece and, if
 * so, which piece it is.
 */
public function isWinnerCol(Board board, int col) => Piece:
	Piece p1 = get(board,0,col)
	Piece p2 = get(board,1,col)
	Piece p3 = get(board,2,col)
	if p1 == p2 && p2 == p3:
		return p1
	else:
		return BLANK

