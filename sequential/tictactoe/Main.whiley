import * from whiley.lang.System
import game.logic.*

public void ::main(System.Console console):
	game = Game()
	printBoard(console, game.board)
	game = Game.play(game,0,0)
	console.out.println("")
	printBoard(console, game.board)

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
