import whiley.lang.*
import * from whiley.lang.Errors
import * from whiley.lang.System
import * from UIFrame
import * from Game
/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public export method move(&Global this, int y):
    this->game = Game.movePiece(this->game, 0, y)
	
public method moveX(&Global this, int x):
	this->game = Game.movePiece(this->game, x, 0)
	
public export method hardDrop(&Global this):
	this->game = Game.hardDrop(this->game)
	
public export method rotate(&Global this, bool clockwise):
	this->game = Game.rotate(this->game, clockwise)

public method main(System.Console sys):	
	&Frame ui = UIFrame.Frame("Tetris")
	&Global global = Global()
	UIFrame.setGlobal(global)
	//Move Direction
	int x = -1 // -1 = Down
	int y = 0 // 1-> Right, -1 -> Left
	int sleepTime = 500
	bool iterate = true
	while iterate:
		sleepTime = global->game.tickTime
		setNext(ui,global->game.next.type)
		render(ui,Game.getUIString(global->game))
		moveX(global,-1)
		updateStats(ui,global->game.filled, global->game.score, global->game.level)
		Thread.sleep(sleepTime)
		
		
		
		
