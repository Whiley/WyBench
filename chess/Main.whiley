import whiley.io.*

void System::main([string] args):
    if |args| == 0:
        this.usage()
        return
    file = this.openReader(args[0])
    contents = ascii2str(file.read())
    game = parseChessGame(contents)
    out.println("Moves taken:\n")
    board = startingChessBoard  
    r = ""       
    i = 0
    invalid = false
    sign = false
    // process each move in turn, updating the board
    while i < |game|:
        out.print(str(i+1) + ". ")
        white,black = game[i]
        // test white
        board = applyShortMove(white,board)        
        out.print(shortMove2str(white))
        // test black
        if black != null:
            board = applyShortMove(black,board)        
            out.print(" ")
            out.println(shortMove2str(black))
        else:
            out.println("")
        i = i + 1
        // print out board
        out.println("\nCurrent board:\n")
        out.println(board2str(board))

void System::usage():
    out.println("usage: chess file")
