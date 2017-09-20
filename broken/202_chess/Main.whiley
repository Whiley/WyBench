import std::ascii
import ShortRound from ShortMove

public method main(ascii::string[] args):
    if |args| == 0:
        usage(sys)
        return
    File.Reader file = File.Reader(sys.args[0])
    ASCII.string contents = ASCII.fromBytes(file.readAll())

    [ShortRound]|null game = Parser.parseChessGame(contents)
    if game is null:
        // error
        sys.out.println_s("error")
    else:
        //
        sys.out.println_s("Moves taken:\n")
        Board board = Board.startingChessBoard  
        ASCII.string r = ""       
        int i = 0
        bool invalid = false
        bool sign = false
        ShortMove white
        ShortMove|null black 
        // process each move in turn, updating the board
        while i < |game|:
            sys.out.print_s([i+1] ++ ". ")
            white,black = game[i]
            // test white
            Board|null tmp = ShortMove.apply(white,board)
            if tmp is null:
                sys.out.println_s("error")
            else:
                board = tmp
            sys.out.print(ShortMove.toString(white))
            // test black
            if black != null:
                tmp = ShortMove.apply(black,board)
                if tmp is null:
                    sys.out.println_s("error")
                else:
                    board = tmp
                sys.out.print(" ")
                sys.out.println_s(ShortMove.toString(black))
            else:
                sys.out.println_s("")
            i = i + 1
            // print out board
            sys.out.println_s("\nCurrent board:\n")
            sys.out.println_s(Board.toString(board))

method usage(System.Console sys):
    sys.out.println_s("usage: chess file")
