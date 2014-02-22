/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public type Frame is { string fileName }

public native method Frame(string title) => &Frame

public native method render(&Frame this, string str)

public type Global is { Game.GameState game }

public method Global() => &Global:
	return new { game: Game.Initial }

public native method setGlobal(&Global g)

public native method updateStats(&Frame this, int rows, int score, int lvl)

public native method setNext(&Frame this, int i)
