package minesweeper.ui;

import wyjc.runtime.*;
import minesweeper.logic.*;

/**
 * This is a Java wrapper for the Whiley Board type and associated functions.
 * 
 * @author David J. Pearce
 * 
 */
public class BoardWrapper {
	private WyRecord state;
	
	public Board() {
		this.state = GameLogic.Board();
	}
}
