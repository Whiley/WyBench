import java.awt.BorderLayout;

import java.awt.event.KeyEvent;
import java.math.BigInteger;
import java.util.HashMap;

import javax.swing.JFrame;
import javax.swing.JTextArea;

import wyjc.runtime.Actor;


/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class UIFrame$native {
	static UIFrame$native name = new UIFrame$native();
	static TetrisCanvas c;
	//Java Side Variables to Store the Values to be rendered
	static int filledRows = 0;
	static int score = 0;
	static int level = 1;
	static char[][] grid;
	static Actor global;
	
	/*
	 * 4*2 Grids to Render the next piece played.
	 */
	static final char[][] BLOCK_I = {{'R','R','R','R'}, {'X', 'X', 'X', 'X'}}; 
	static final char[][] BLOCK_J = {{'X', 'O', 'O', 'X'}, {'X', 'O', 'O', 'X'}}; 
	static final char[][] BLOCK_L = {{'Y', 'Y', 'Y', 'X'}, {'X', 'Y', 'X', 'X'}}; 
	static final char[][] BLOCK_O = {{'X', 'X', 'G', 'G'}, {'X', 'G','G', 'X'}}; 
	static final char[][] BLOCK_S = {{'X', 'B', 'B', 'X'}, {'X', 'X', 'B', 'B'}};
	static final char[][] BLOCK_T = {{'X', 'I', 'X', 'X'}, {'X', 'I', 'I', 'I'}}; 
	static final char[][] BLOCK_Z = {{'X', 'X', 'X', 'V'}, {'X', 'V', 'V', 'V'}}; 
	static char[][] block = BLOCK_I; //First Block. Avoids NullPointers in Constructor
	
	public static void setGlobal(Actor g) {
		global = g;
	}
	
	public static Actor Frame(String title) {
		JFrame frame = new JFrame(title);
		c = new TetrisCanvas(name);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.add(c, BorderLayout.CENTER);
		frame.setSize(285, 690);
		frame.pack();
		frame.setVisible(true);
		grid = new char[10][22];
		c.setFocusable(true);
		frame.transferFocus(); // Moves Focus to the Canvas.
		frame.setResizable(true);
		Actor a = new Actor(frame);
		a.start();
		return a;
    }
	/*
	 * Updates the Information to be rendered
	 */
	public static void updateStats(Actor a, BigInteger i, BigInteger sc, BigInteger lvl) {
	filledRows=i.intValue();
	score = sc.intValue();
	level = lvl.intValue();
	}
	/*
	 * Renders the Grid
	 */
	public static void render(Actor a, String str) {
		int x = 0;
		int y = 20;
		for(int i=0;i<str.length();i++) {
			if(y < 0) {
				y =20;
				x++;
			}
			if(str.charAt(i) == '\'')  {
				//debug("Apostrophe Detected. Ignoring");
			}
			else {
			grid[x][y] = str.charAt(i);
			y--;
			}
			
				
		}
		c.repaint();
	}


	/*
	 * Sends a key command to the main program.
	 */
	public void sendKeyPress(KeyEvent e) {
		int code = e.getKeyCode();
		if(code == KeyEvent.VK_LEFT) {
			Tetris.move(global,new BigInteger("-1")); }
		else if(code == KeyEvent.VK_RIGHT) {
			Tetris.move(global,new BigInteger("1"));
		}
		else if(code == KeyEvent.VK_UP)  {
			Tetris.rotate(global, true);
		} else if(code == KeyEvent.VK_SPACE) {
			Tetris.hardDrop(global); 
		}
		
	}
	public char[][] getNextBlock() {
		return block;
	}
	
	public static void setNext(Actor a, BigInteger i) {
		switch(i.intValue()) {
		case 1:
			block = BLOCK_I;
			return;
		case 2:
			block = BLOCK_J;
			return;
		case 3:
			block = BLOCK_L;
			return;
		case 4:
			block = BLOCK_O;
			return;
		case 5:
			block = BLOCK_S;
			return;
		case 6:
			block = BLOCK_T;
			return;
		case 7:
			block = BLOCK_Z;
			return;
		default: 
			block = BLOCK_I;
		}
	}
	
	
}
