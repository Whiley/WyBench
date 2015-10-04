import whiley.lang.System
import string from whiley.lang.ASCII

import game.logic.*
import * from game.logic.Game
import * from game.logic.Board

type Pos is { int x, int y }

constant GAME is [
	{x:0, y:0}, // circle
	{x:1, y:1}, // cross
	{x:0, y:1}, // circle
	{x:2, y:2}, // cross
	{x:0, y:2}, // circle
	{x:2, y:2}  // should be impossible
]

public method main(System.Console console):
    Game game = Game()
    int i = 0
    while i < |GAME|:
        Pos pos = GAME[i]
        game = Game.play(game,pos.y,pos.x)	
        printBoard(console, game.board)
        console.out.println_s("")
        Piece piece = Board.isWinner(game.board)
        if piece != Board.BLANK:
            console.out.println_s("we have a winner!")
            break
        i = i + 1

public method printBoard(System.Console console, Board board):
    int row = 0
    while row < 3:
        if row != 0:
            console.out.println_s("---- | ---- | ----")
        printRowTop(console,board,row)
        printRowUpperMiddle(console,board,row)
        printRowLowerMiddle(console,board,row)
        printRowBottom(console,board,row)
        row = row + 1
    // done
    console.out.println_s("")

public method printRowTop(System.Console console, Board board, int row):
    int col = 0
    while col < 3:
        Piece p = Board.get(board,row,col)
        if col != 0:
            console.out.print_s(" | ")
        switch p:
            case Board.BLANK:
                console.out.print_s("    ")
            case Board.CROSS:
                console.out.print_s("\\  /")
            case Board.CIRCLE:
                console.out.print_s(" -- ")
        col = col + 1
    //
    console.out.println_s("")

public method printRowBottom(System.Console console, Board board, int row):
    int col = 0
    while col < 3:
        Piece p = Board.get(board,row,col)
        if col != 0:
            console.out.print_s(" | ")
        switch p:
            case Board.BLANK:
                console.out.print_s("    ")
            case Board.CROSS:
                console.out.print_s("/  \\")
            case Board.CIRCLE:
                console.out.print_s(" -- ")
        col = col + 1
    //
    console.out.println_s("")

public method printRowUpperMiddle(System.Console console, Board board, int row):
    int col = 0
    while col < 3:
        Piece p = Board.get(board,row,col)
        if col != 0:
            console.out.print_s(" | ")
        switch p:
            case Board.BLANK:
                console.out.print_s("    ")
            case Board.CROSS:
                console.out.print_s(" \\/ ")
            case Board.CIRCLE:
                console.out.print_s("|  |")
        col = col + 1
    console.out.println_s("")

public method printRowLowerMiddle(System.Console console, Board board, int row):
    int col = 0
    while col < 3:
        Piece p = Board.get(board,row,col)
        if col != 0:
            console.out.print_s(" | ")
        switch p:
            case Board.BLANK:
                console.out.print_s("    ")
            case Board.CROSS:
                console.out.print_s(" /\\")
            case Board.CIRCLE:
                console.out.print_s("|  |")
        col = col + 1
    //
    console.out.println_s("")
