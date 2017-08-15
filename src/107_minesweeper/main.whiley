import std::io
import std::ascii
import * from minesweeper

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

type Point is {
    int x,
    int y
}

constant BOMBS is [
 Point{x:0,y:1}, Point{x:2,y:3}, Point{x:3,y:3}, Point{x:4,y:4}, Point{x:4,y:2}, Point{x:6,y:4} 
]

// Some simple test code for the Minesweeper game
public method main(ascii::string[] args):
    Board board = Board(10,5)
    // Place bombs along diaganol
    int i = 0
    while i < |BOMBS|:
        Point p = BOMBS[i]
        board = setSquare(board,p.x,p.y,HiddenSquare(true,false))
        i = i + 1

    // Print the starting board
    printBoard(board)
    //
    i = 0
    while i < |MOVES|:
        Move m = MOVES[i]
        // Apply the move
        if m.expose:
            io::print("Player exposes square at ")
            io::print(m.col)
            io::print(", ")
            io::println(m.row)
            board = exposeSquare(board,m.col,m.row)
        else:
            io::println("Player flags square at ")
            io::print(m.col)
            io::print(", ")
            io::println(m.row)
            board = flagSquare(board,m.col,m.row)
        // Print the board
        printBoard(board)
        // Check for game over
        bool isOver
        bool hasWon
        isOver, hasWon = isGameOver(board)
        if isOver:
            if hasWon:
                io::println("Game Over --- Player has Won!")
            else:
                io::println("Game Over --- Player has Lost!")
        i = i + 1
    // Done
    io::println("All moves completed")

method printBoard(Board board):
    int row = 0
    while row < board.height: 
        // Print Side Wall
        io::print("|")
        int col = 0
        while col < board.width:
            Square sq = getSquare(board,col,row)
            if sq is HiddenSquare:
                if sq.flagged:
                    io::print("P")
                else:
                    io::print("X")
            else if sq.holdsBomb:
                io::print("*")
            else if sq.rank == 0:
                io::print(" ")
            else:
                io::print(sq.rank)
            col = col + 1
        // Print Side Wall
        io::println("|")
        row = row + 1
