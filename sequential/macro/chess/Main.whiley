import whiley.lang.*
import * from whiley.lang.Errors
import * from whiley.lang.System
import * from whiley.io.File

void ::main(System sys, [string] args):
    if |args| == 0:
        usage(sys)
        return
    file = File.Reader(args[0])
    contents = String.fromASCII(file.read())
    try:
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
    catch(Error e):
        sys.out.println("syntax error: " + e.msg)
    catch(Move.InvalidMove im):
        sys.out.println("invalid move: " + Move.toString(im.move))
    catch(ShortMove.Invalid ism):
        sys.out.println("invalid move: " + ShortMove.toString(ism.move))

void ::usage(System sys):
    sys.out.println("usage: chess file")
