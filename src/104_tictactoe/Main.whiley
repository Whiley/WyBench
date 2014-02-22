import * from whiley.lang.System
import game.logic.*

import * from game.logic.Game
import * from game.logic.Board

constant GAME is [
	(0,0), // circle
	(1,1), // cross
	(0,1), // circle
	(2,2), // cross
	(0,2), // circle
	(2,2)  // should be impossible
]

public method main(System.Console console):
	Game game = Game()
	for m in GAME:
		int r, int c = m
		game = Game.play(game,r,c)	
		printBoard(console, game.board)
		console.out.println("")
		Piece p = Board.isWinner(game.board)
		if p != Board.BLANK:
			console.out.println("we have a winner!")
			break

public method printBoard(System.Console console, Board board):
	for row in 0..3:
		if row != 0:
			console.out.println("---- | ---- | ----")
		printRowTop(console,board,row)
		printRowUpperMiddle(console,board,row)
		printRowLowerMiddle(console,board,row)
		printRowBottom(console,board,row)
	// done
	console.out.println("")

public method printRowTop(System.Console console, Board board, int row):
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

public method printRowBottom(System.Console console, Board board, int row):
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

public method printRowUpperMiddle(System.Console console, Board board, int row):
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

public method printRowLowerMiddle(System.Console console, Board board, int row):
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
