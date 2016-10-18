import java.math.BigInteger;
import java.util.*;
import wyjc.runtime.*;

/**
 * This is a Java wrapper for the Whiley Board type and associated functions.
 * 
 * @author David J. Pearce
 * 
 */
public class BoardAdaptor {
    private WyRecord state;
	
    public BoardAdaptor(int width, int height, int nBombs) {
	this.state = Minesweeper.Board(BigInteger.valueOf(width),BigInteger.valueOf(height));
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
	WyRecord square = Minesweeper.getSquare(state,c,r);
	return square.containsKey("rank");
    }

    public int getRank(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = Minesweeper.getSquare(state,c,r);
	return ((BigInteger)square.get("rank")).intValue();
    }

    public boolean holdsBomb(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = Minesweeper.getSquare(state,c,r);
	return ((WyBool) square.get("holdsBomb")) == WyBool.TRUE;
    }

    public boolean isFlagged(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	WyRecord square = Minesweeper.getSquare(state,c,r);
	return ((WyBool) square.get("flagged")) == WyBool.TRUE;
    }

    public void exposeSquare(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	this.state = Minesweeper.exposeSquare(state,c,r);
    }

    public void flagSquare(int col, int row) {
	BigInteger c = BigInteger.valueOf(col);
	BigInteger r = BigInteger.valueOf(row);
	this.state = Minesweeper.flagSquare(state,c,r);
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
		    WyRecord sq = Minesweeper.HiddenSquare(WyBool.TRUE,WyBool.FALSE);		    
		    state = Minesweeper.setSquare(state,BigInteger.valueOf(x),BigInteger.valueOf(y),sq);
		}
	    }
	}
    }
}
