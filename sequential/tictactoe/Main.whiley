import * from whiley.lang.System
import game.logic.*

define GAME as [
	(0,0), // circle
	(1,1), // cross
	(0,1), // circle
	(2,2), // cross
	(0,2), // circle
	(2,2)  // should be impossible
]

public void ::main(System.Console console):
	game = Game()
	for m in GAME:
		r,c = m
		game = Game.play(game,r,c)	
		printBoard(console, game.board)
		console.out.println("")
		p = Board.isWinner(game.board)
		if p != Board.BLANK:
			console.out.println("we have a winner!")
			break

public void ::printBoard(System.Console console, Board board):
	for row in 0..3:
		if row != 0:
			console.out.println("---- | ---- | ----")
		printRowTop(console,board,row)
		printRowUpperMiddle(console,board,row)
		printRowLowerMiddle(console,board,row)
		printRowBottom(console,board,row)
	// done
	console.out.println("")

public void ::printRowTop(System.Console console, Board board, int row):
	for col in 0 .. 3:
		p = Board.get(board,row,col)
		if col != 0:
			console.out.print(" | ")
		switch p:
			case Board.BLANK:
				console.out.print("    ")
			case Board.CROSS:
				console.out.print("\\  /")
			case Board.CIRCLE:
				console.out.print(" -- ")
	console.out.println("")

public void ::printRowBottom(System.Console console, Board board, int row):
	for col in 0 .. 3:
		piece = Board.get(board,row,col)
		if col != 0:
			console.out.print(" | ")
		switch piece:
			case Board.BLANK:
				console.out.print("    ")
			case Board.CROSS:
				console.out.print("/  \\")
			case Board.CIRCLE:
				console.out.print(" -- ")
	console.out.println("")

public void ::printRowUpperMiddle(System.Console console, Board board, int row):
	for col in 0 .. 3:
		piece = Board.get(board,row,col)
		if col != 0:
			console.out.print(" | ")
		switch piece:
			case Board.BLANK:
				console.out.print("    ")
			case Board.CROSS:
				console.out.print(" \\/ ")
			case Board.CIRCLE:
				console.out.print("|  |")
	console.out.println("")

public void ::printRowLowerMiddle(System.Console console, Board board, int row):
	for col in 0 .. 3:
		piece = Board.get(board,row,col)
		if col != 0:
			console.out.print(" | ")
		switch piece:
			case Board.BLANK:
				console.out.print("    ")
			case Board.CROSS:
				console.out.print(" /\\")
			case Board.CIRCLE:
				console.out.print("|  |")
	console.out.println("")
