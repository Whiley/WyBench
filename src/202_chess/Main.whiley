import whiley.lang.*
import * from whiley.lang.Errors
import * from whiley.lang.System
import * from whiley.io.File
import ShortRound from ShortMove

public method main(System.Console sys):
    if |sys.args| == 0:
        usage(sys)
        return
    File.Reader file = File.Reader(sys.args[0])
    string contents = String.fromASCII(file.readAll())
    try:
        [ShortRound] game = Parser.parseChessGame(contents)
        sys.out.println("Moves taken:\n")
        Board board = Board.startingChessBoard  
        string r = ""       
        int i = 0
        bool invalid = false
        bool sign = false
        ShortMove white
        ShortMove|null black 
        // process each move in turn, updating the board
        while i < |game|:
            sys.out.print((i+1) ++ ". ")
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
    catch(Error e):
        sys.out.println("syntax error: " ++ e.msg)
    catch(Move.Invalid im):
        sys.out.println("invalid move: " ++ Move.toString(im.move))
    catch(any x):
        // FYI, this is because of a compiler bug
        if x is ShortMove.Invalid:
            sys.out.println("invalid move: " ++ ShortMove.toString(x.move))
        else:
            sys.out.println("error: " ++ x)

method usage(System.Console sys):
    sys.out.println("usage: chess file")
