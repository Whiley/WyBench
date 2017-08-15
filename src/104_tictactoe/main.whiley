import std::ascii
import std::io

import * from game
import * from board

type Pos is { int x, int y }

constant GAME is [
	{x:0, y:0}, // circle
	{x:1, y:1}, // cross
	{x:0, y:1}, // circle
	{x:2, y:2}, // cross
	{x:0, y:2}, // circle
	{x:2, y:2}  // should be impossible
]

public method main(ascii::string[] args):
    Game game = Game()
    int i = 0
    while i < |GAME|:
        Pos pos = GAME[i]
        game = play(game,pos.y,pos.x)	
        printBoard(game.board)
        io::println(" ")
        Piece piece = board::isWinner(game.board)
        if piece != board::BLANK:
            io::println("we have a winner!")
            break
        i = i + 1

public method printBoard(Board board):
    int row = 0
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

public method printRowTop(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = board::get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case board::BLANK:
                io::print("    ")
            case board::CROSS:
                io::print("\\  /")
            case board::CIRCLE:
                io::print(" -- ")
        col = col + 1
    //
    io::println(" ")

public method printRowBottom(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = board::get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case board::BLANK:
                io::print("    ")
            case board::CROSS:
                io::print("/  \\")
            case board::CIRCLE:
                io::print(" -- ")
        col = col + 1
    //
    io::println(" ")

public method printRowUpperMiddle(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = board::get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case board::BLANK:
                io::print("    ")
            case board::CROSS:
                io::print(" \\/ ")
            case board::CIRCLE:
                io::print("|  |")
        col = col + 1
    io::println(" ")

public method printRowLowerMiddle(Board brd, int row):
    int col = 0
    while col < 3:
        Piece p = board::get(brd,row,col)
        if col != 0:
            io::print(" | ")
        switch p:
            case board::BLANK:
                io::print("    ")
            case board::CROSS:
                io::print(" /\\")
            case board::CIRCLE:
                io::print("|  |")
        col = col + 1
    //
    io::println(" ")
