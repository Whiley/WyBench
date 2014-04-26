import * from Minesweeper

type Move is {
    bool expose, // true == exposing, false == flagging
    int col,     // col of square to expose or flag
    int row     // row of square to expose or flag
}
        
constant MOVES is [
    // First move, expose square 0,0
    {expose: true, col: 0, row: 0}
]

// Some simple test code for the Minesweeper game
public method main(System.Console console):
    Board board = Board(10,10)
    // Place bombs along diaganol
    for i in 0 .. 10:
        board = setSquare(board,i,i,HiddenSquare(true,false))
    // Print the starting board
    printBoard(board,console)
    //
    for m in MOVES:
        // Apply the move
        if m.expose:
            console.out.println("Player exposes square at " ++ m.col ++ ", " ++ m.row)
            board = exposeSquare(board,m.col,m.row)
        else:
            console.out.println("Player flags square at " ++ m.col ++ ", " ++ m.row)
            board = flagSquare(board,m.col,m.row)
        // Print the board
        printBoard(board,console)
        // Check for game over
        bool isOver, bool hasWon = isGameOver(board)
        if isOver:
            if hasWon:
                console.out.println("Game Over --- Player has Won!")
            else:
                console.out.println("Game Over --- Player has Lost!")
    // Done
    console.out.println("All moves completed")

method printBoard(Board board, System.Console console):
    for row in 0 .. board.height:
        // Print Side Wall
        console.out.print("|")
        for col in 0 .. board.width:
            Square sq = getSquare(board,col,row)
            if sq is HiddenSquare:
                if sq.flagged:
                    console.out.print("P")
                else:
                    console.out.print("O")
            else if sq.holdsBomb:
                console.out.print("*")
            else:
                console.out.print(sq.rank)
        // Print Side Wall
        console.out.println("|")