import std::ascii
import std::io
import nat from std::integer

import Game from game
import Index from board
import Piece from board
import Board from board
import BLANK from board
import CIRCLE from board
import CROSS from board
import get from board
import play from game
import isWinner from board

type Pos is { Index x, Index y }

Pos[] GAME = [
	{x:0, y:0}, // circle
	{x:1, y:1}, // cross
	{x:0, y:1}, // circle
	{x:2, y:2}, // cross
	{x:0, y:2}, // circle
	{x:2, y:2}  // should be impossible
]

public method main(ascii::string[] args):
    Game game = Game()
    nat i = 0
    while i < |GAME|:
        Pos pos = GAME[i]
        // FIXME: this should be unnecessary
        assume get(game.board,pos.y,pos.x) == BLANK
        game = play(game,pos.y,pos.x)	
        printBoard(game.board)
        io::println(" ")
        Piece piece = isWinner(game.board)
        if piece != BLANK:
            io::println("we have a winner!")
            break
        i = i + 1

public method printBoard(Board board):
    nat row = 0
    while row < 3:
        if row != 0:
            io::println("---- | ---- | ----")
        printRowTop(board,row)
        printRowUpperMiddle(board,row)
        printRowLowerMiddle(board,row)
        printRowBottom(board,row)
        row = row + 1
    // done
    io::println(" ")

public method printRowTop(Board brd, nat row)
requires row < 3:
    nat col = 0
    while col < 3:
        Piece p = get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case BLANK:
                io::print("    ")
            case CROSS:
                io::print("\\  /")
            case CIRCLE:
                io::print(" -- ")
        col = col + 1
    //
    io::println(" ")

public method printRowBottom(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case BLANK:
                io::print("    ")
            case CROSS:
                io::print("/  \\")
            case CIRCLE:
                io::print(" -- ")
        col = col + 1
    //
    io::println(" ")

public method printRowUpperMiddle(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case BLANK:
                io::print("    ")
            case CROSS:
                io::print(" \\/ ")
            case CIRCLE:
                io::print("|  |")
        col = col + 1
    io::println(" ")

public method printRowLowerMiddle(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case BLANK:
                io::print("    ")
            case CROSS:
                io::print(" /\\")
            case CIRCLE:
                io::print("|  |")
        col = col + 1
    //
    io::println(" ")
