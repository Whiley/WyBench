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
public export void Global::move(int y):
    this->game = Game.movePiece(this->game, 0, y)
	
public void Global::moveX(int x):
	this->game = Game.movePiece(this->game, x, 0)
	
public export void Global::hardDrop():
	this->game = Game.hardDrop(this->game)
	
public export void Global::rotate(bool clockwise):
	this->game = Game.rotate(this->game, clockwise)

void ::main(System.Console sys):	
	ui = UIFrame.Frame("Tetris")
	global = Global()
	UIFrame.setGlobal(global)
	//Move Direction
	x = -1 // -1 = Down
	y = 0 // 1-> Right, -1 -> Left
	sleepTime = 500
	iterate = true
	while iterate:
		sleepTime = global->game.tickTime
		ui.setNext(global->game.next.type)
		ui.render(Game.getUIString(global->game))
		global.moveX(-1)
		ui.updateStats(global->game.filled, global->game.score, global->game.level)
		Thread.sleep(sleepTime)
		
		
		
		
