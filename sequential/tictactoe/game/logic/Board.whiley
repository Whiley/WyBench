package game.logic

define BLANK as 0
define CROSS as 1
define CIRCLE as 2

/**
 * A piece is either a blank, a cross or a circle.
 */
define Piece as { BLANK, CROSS, CIRCLE }

/**
 * A Board is a 3x3 grid of pieces
 */
public define Board as [Piece] where |$| == 9 && 
	numPieces($,CIRCLE) >= numPieces($,CROSS) &&
	numPieces($,CIRCLE) <= (numPieces($,CROSS)+1) 

/**
 * A Board index (for either column or row) is between 0 and 3
 */
public define Index as int where 0 <= $ && $ < 3

/**
 * Create an empty 3x3 board.
 */
public Board Board():
	board = []
	for i in 0 .. 9:
		board = board + [BLANK]
	return board

/**
 * Return the piece at a given row and column on the board.
 */
public Piece get(Board board, Index row, Index col):
	return board[(row*3)+col]

/**
 * Set the piece at a tiven row and column on the board.
 */
public Board put(Board board, Index row, Index col, Piece piece):
	board[(row*3)+col] = piece
	return board

/**
 * Count the number of pieces which have been placed on the board.
 */
public int numPieces(Board board, Piece piece):
	count = 0
	for p in board:
		if p == piece:
			count = count + 1
	return count

/**
 * Check whether there are any more blank squares on the board.
 */
public bool isFull(Board board):
	count = 0
	for piece in board:
		if piece != BLANK:
			count = count + 1
	return count == 9	

/**
 * Check whether there is a winner, and return the 
 * corresponding piece (if there is) or BLANK (if there isn't)
 */
public Piece isWinner(Board board):
	// First, check rows
	for row in 0..3:
		p = isWinnerRow(board,row)
		if p != BLANK:
			return p
	// Second, check columns
	for col in 0..3:
		p = isWinnerCol(board,col)
		if p != BLANK:
			return p
	// Finally, check diaganols
	// TODO:
	return BLANK

/**
 * Check whether a given row is all the same piece and, if
 * so, which piece it is.
 */
public Piece isWinnerRow(Board board, int row):
	p1 = get(board,row,0)
	p2 = get(board,row,1)
	p3 = get(board,row,2)
	if p1 == p2 && p2 == p3:
		return p1
	else:
		return BLANK

/**
 * Check whether a given row is all the same piece and, if
 * so, which piece it is.
 */
public Piece isWinnerCol(Board board, int col):
	p1 = get(board,0,col)
	p2 = get(board,1,col)
	p3 = get(board,2,col)
	if p1 == p2 && p2 == p3:
		return p1
	else:
		return BLANK

