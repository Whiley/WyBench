import std::ascii
import std::io
import nat from std::integer

import Game from game
import Index from board
import Piece from board
import Board from board
import BLANK from board
import CIRCLE from board
import CROSS from board
import get from board
import play from game
import isWinner from board

// ========================================================================
// Tests
// ========================================================================

public method test_01():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    //
    assume game.board == [CIRCLE,BLANK,BLANK,
                          BLANK,BLANK,BLANK,
                          BLANK,BLANK,BLANK]

public method test_02():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,0)
    //    
    assume game.board == [CIRCLE,CROSS,BLANK,
                          BLANK,BLANK,BLANK,
                          BLANK,BLANK,BLANK]

public method test_03():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,0)
    // Circle move
    game = play(game,2,0)    
    //    
    assume game.board == [CIRCLE,BLANK,CIRCLE,
                          BLANK,BLANK,BLANK,
                          BLANK,BLANK,BLANK]

public method test_04():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,1)
    //    
    assume game.board == [CIRCLE,BLANK,BLANK,
                          BLANK,CROSS,BLANK,
                          BLANK,BLANK,BLANK]

public method test_05():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,1)
    // Circle move
    game = play(game,2,2)
    //    
    assume game.board == [CIRCLE,BLANK,BLANK,
                          BLANK,BLANK,BLANK,
                          BLANK,BLANK,CIRCLE]

public method test_06():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,0)
    // Circle move
    game = play(game,1,1)
    //    
    assume game.board == [CIRCLE,CROSS,BLANK,
                          BLANK,CIRCLE,BLANK,
                          BLANK,BLANK,BLANK]

public method test_07():
    Game game = Game()
    // Circle move
    game = play(game,0,0)
    // Cross move
    game = play(game,1,0)
    // Circle move
    game = play(game,1,1)
    // Cross move
    game = play(game,2,0)
    // Circle move
    game = play(game,2,2)    
    //    
    assume game.board == [CIRCLE,CROSS,CROSS,
                          BLANK,CIRCLE,BLANK,
                          BLANK,BLANK,CIRCLE]
    // Check winner
    assume isWinner(game.board) == CIRCLE