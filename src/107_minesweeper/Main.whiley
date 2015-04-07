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


// Some simple test code for the Minesweeper game
public method main(System.Console console):
    Board board = Board(10,5)
    // Place bombs along diaganol
    for b in [ (0,1), (2,3), (3,3), (4,4), (4,2), (6,4) ]:
        int x, int y = b
        board = setSquare(board,x,y,HiddenSquare(true,false))
    // Print the starting board
    printBoard(board,console)
    //
    for m in MOVES:
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
    // Done
    console.out.println_s("All moves completed")

method printBoard(Board board, System.Console console):
    for row in 0 .. board.height:
        // Print Side Wall
        console.out.print_s("|")
        for col in 0 .. board.width:
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
        // Print Side Wall
        console.out.println_s("|")