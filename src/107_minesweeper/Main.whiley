import whiley.lang.System
import whiley.lang.Int

import * from Minesweeper

type Move is {
    bool expose, // true == exposing, false == flagging
    int col,     // col of square to expose or flag
    int row     // row of square to expose or flag
}
        
constant MOVES is [
    // First move, expose square 0,0
    {expose: true, col: 0, row: 0},
    {expose: false, col: 0, row: 1},
    {expose: true, col: 2, row: 0}
]

constant BOMBS is [
 (0,1), (2,3), (3,3), (4,4), (4,2), (6,4) 
]

// Some simple test code for the Minesweeper game
public method main(System.Console console):
    Board board = Board(10,5)
    // Place bombs along diaganol
    int i = 0
    while i < |BOMBS|:
        int x, int y = BOMBS[i]
        board = setSquare(board,x,y,HiddenSquare(true,false))
        i = i + 1

    // Print the starting board
    printBoard(board,console)
    //
    i = 0
    while i < |MOVES|:
        Move m = MOVES[i]
        // Apply the move
        if m.expose:
            console.out.println_s("Player exposes square at " ++ Int.toString(m.col) ++ ", " ++ Int.toString(m.row))
            board = exposeSquare(board,m.col,m.row)
        else:
            console.out.println_s("Player flags square at " ++ Int.toString(m.col) ++ ", " ++ Int.toString(m.row))
            board = flagSquare(board,m.col,m.row)
        // Print the board
        printBoard(board,console)
        // Check for game over
        bool isOver, bool hasWon = isGameOver(board)
        if isOver:
            if hasWon:
                console.out.println_s("Game Over --- Player has Won!")
            else:
                console.out.println_s("Game Over --- Player has Lost!")
        i = i + 1
    // Done
    console.out.println_s("All moves completed")

method printBoard(Board board, System.Console console):
    int row = 0
    while row < board.height: 
        // Print Side Wall
        console.out.print_s("|")
        int col = 0
        while col < board.width:
            Square sq = getSquare(board,col,row)
            if sq is HiddenSquare:
                if sq.flagged:
                    console.out.print_s("P")
                else:
                    console.out.print_s("X")
            else if sq.holdsBomb:
                console.out.print_s("*")
            else if sq.rank == 0:
                console.out.print_s(" ")
            else:
                console.out.print(sq.rank)
            col = col + 1
        // Print Side Wall
        console.out.println_s("|")
        row = row + 1