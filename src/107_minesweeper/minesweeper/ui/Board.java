package minesweeper.ui;

import java.math.BigInteger;
import java.util.*;
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
	
    public Board(int width, int height, int nBombs) {
	this.state = GameLogic.Board(BigInteger.valueOf(width),BigInteger.valueOf(height));
	initialiseBoard(nBombs);
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

    private void initialiseBoard(int nBombs) {
	Random rand = new Random(System.currentTimeMillis());
	int nSquares = getWidth() * getHeight();
	ArrayList<Boolean> bombs = new ArrayList<Boolean>();
	for(int i=0;i!=nSquares;++i) {
	    bombs.add(false);
	}
	for(int i=0;i!=nBombs;++i) {
	    bombs.set(i,true);
	}
	Collections.shuffle(bombs,rand);
	for(int x=0;x!=getWidth();++x) {
	    for(int y=0;y!=getWidth();++y) {
		int i = x + (y * getWidth());
		if(bombs.get(i)) {
		    WyRecord sq = GameLogic.HiddenSquare(true,false);		    
		    state = GameLogic.setSquare(state,BigInteger.valueOf(x),BigInteger.valueOf(y),sq);
		}
	    }
	}
    }
}
