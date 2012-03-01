import * from whiley.lang.System
import game.logic.*

public void ::main(System.Console console):
	game = Game()
	printBoard(console, game.board)
	game = Game.play(game,0,0)
	console.out.println("======")
	printBoard(console, game.board)

public void ::printBoard(System.Console console, Board board):
	for row in 0..3:
		if row != 0:
			console.out.println("-----")
		for col in 0..3:
			if col != 0:
				console.out.print("|")
			piece = Board.get(board,row,col)
			switch piece:
				case Board.BLANK:
					console.out.print(" ")
				case Board.CROSS:
					console.out.print("X")
				case Board.CIRCLE:
					console.out.print("O")
			// done
		console.out.println("")
