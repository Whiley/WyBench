import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File

void ::main(System sys, [string] args):
    if |args| == 0:
        usage(sys)
        return
    file = File.Reader(args[0])
    contents = String.fromASCII(file.read())
    game = Parser.parseChessGame(contents)
    sys.out.println("Moves taken:\n")
    board = Board.startingChessBoard  
    r = ""       
    i = 0
    invalid = false
    sign = false
    // process each move in turn, updating the board
    while i < |game|:
        sys.out.print(String.str(i+1) + ". ")
        white,black = game[i]
        // test white
        board = ShortMove.apply(white,board)        
        sys.out.print(ShortMove.toString(white))
        // test black
        if black != null:
            board = ShortMove.apply(black,board)        
            sys.out.print(" ")
            sys.out.println(ShortMove.toString(black))
        else:
            sys.out.println("")
        i = i + 1
        // print out board
        sys.out.println("\nCurrent board:\n")
        sys.out.println(Board.toString(board))

void ::usage(System sys):
    sys.out.println("usage: chess file")
