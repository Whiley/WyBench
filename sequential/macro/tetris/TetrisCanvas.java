import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Font;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class TetrisCanvas extends Canvas implements KeyListener {
	static final int dimension = 25;
	Graphics graf;
	UIFrame$native frame;
	Color empty = Color.DARK_GRAY;
	static final int startX = 10;
	static final int startY = 10;
	public TetrisCanvas(UIFrame$native frame) {
		this.setSize(285, 690);
		this.addKeyListener(this);
		this.frame = frame;
		this.requestFocus();	}
	
	public void paint(Graphics g) {
		Image offscreen = createImage(285, 690);
		Graphics gra = offscreen.getGraphics();
		gra.setColor(empty);
		gra.fillRect(0, 0, 270, 750);
		//Draw Bounding Lines
		gra.setColor(Color.GRAY);
		gra.fillRect(startX-2, startY, 2, 21*dimension);
		gra.fillRect(startX+10*dimension, startY, 2, 21*dimension);
		gra.fillRect(startX-2, startY+21*dimension, 10*dimension+4,2 );
		//Render the Pieces.
		char[][] grid = UIFrame$native.grid;
		int x = startX;
		int y = startY;
		for(int i=0;i<grid.length;i++) {
			for(int j=0;j<grid[0].length;j++) {
				Color c = getColour(grid[i][j]);
				if(!c.equals(Color.WHITE)) {
				gra.setColor(c);
				gra.fillRect(x, y, dimension, dimension);
				if(!gra.getColor().equals(Color.white)) {
					gra.setColor(Color.GRAY);
					gra.drawRect(x, y, dimension-1, dimension-1);
					}
				}
				y = y + dimension;
				}
			y = startY;
			x = x+dimension;
		}
		gra.setColor(Color.GREEN);
		Font f = new Font("Serif", Font.BOLD, 20);
		gra.setFont(f);
		gra.drawString("Score: " + UIFrame$native.score, startX, 560);
		gra.drawString("Rows: " + UIFrame$native.filledRows, startX, 581);
		gra.drawString("Level: " + UIFrame$native.level, startX, 602);
		drawBlock(gra, 130, 560 );
		g.drawImage(offscreen, 0, 0, this);
		
	}
	/*
	 * Renders the Next Piece on the Canvas. 
	 * @param gra - Graphics to be Drawn on
	 * @param i - X Corner
	 * @param j - Y Corner
	 */
	private void drawBlock(Graphics gra, int i, int j) {
		if(frame == null)
			return; // To Fix Constructor Bug.
		char[][] block = frame.getNextBlock();
		
		gra.drawString("Next Block: ", i+10, j);
		j = j+7;
		i+=10;
		int hold = j;
		for(int l=0;l<block[0].length;l++) {
			for(int k=0;k<block.length;k++) {
			
				Color c = getColour(block[k][l]);
				if(!c.equals(Color.WHITE)) {
				//If we get here, the block isn't null. Draw it in colour
				gra.setColor(c);
				gra.fillRect(i, j, dimension, dimension); }
				j+=dimension + 1;
				
			}
			i+=dimension+1;
			j = hold;
		}
		
	}
	/*
	 * Get the Colour Associated with that piece
	 * @param c - The Character associated with the piece.
	 */
	public Color getColour(char c) {
		if(c == 'X' || c == '\0')
			return Color.WHITE;
		switch(c) {
			case 'R': return Color.CYAN;
			case 'O': return Color.BLUE;
			case 'Y': return Color.ORANGE;
			case 'G': return Color.YELLOW;
			case 'B': return Color.GREEN;
			case 'I': return Color.MAGENTA;
			case 'V': return Color.RED;
			default: return Color.WHITE;
		}
	}

	@Override
	public void keyTyped(KeyEvent e) {
		//Template to Fulfill KeyListener Implementation
		
	}

	@Override
	public void keyPressed(KeyEvent e) {
		frame.sendKeyPress(e);
	
		
	}

	@Override
	public void keyReleased(KeyEvent e) {
		//Template to Fulfill KeyListener Implementation
		
	}
		
}
