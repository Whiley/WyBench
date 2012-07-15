/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public define Frame as ref { string fileName }

public native Frame ::Frame ( string title ):

public native void Frame::render(string str):

public define Global as ref { Game.GameState game }

public Global ::Global():
	return new { game: Game.Initial }

public native void ::setGlobal(Global g):

public native void Frame::updateStats(int rows, int score, int lvl):

public native void Frame::setNext(int i):
