package minesweeper.ui;

import java.math.BigInteger;
import wyjc.runtime.*;
import minesweeper.logic.*;

/**
 * This is a Java wrapper for the Whiley Board type and associated functions.
 * 
 * @author David J. Pearce
 * 
 */
public class Board {
    private WyRecord state;
	
    public Board(int width, int height) {
	this.state = GameLogic.Board(BigInteger.valueOf(width),BigInteger.valueOf(height));
    }

    public int getWidth() {
	return ((BigInteger)state.get("width")).intValue();
    }

    public int getHeight() {
	return ((BigInteger)state.get("height")).intValue();
    }

    public boolean isExposedSquare(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = GameLogic.getSquare(state,c,r);
	return square.containsKey("rank");
    }

    public int getRank(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = GameLogic.getSquare(state,c,r);
	return ((BigInteger)square.get("rank")).intValue();
    }

    public boolean holdsBomb(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = GameLogic.getSquare(state,c,r);
	return (Boolean) square.get("holdsBomb");
    }


    public boolean isFlagged(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = GameLogic.getSquare(state,c,r);
	return (Boolean) square.get("flagged");
    }
}
