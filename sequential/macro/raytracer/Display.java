import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Font;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.math.BigInteger;

import javax.swing.JFrame;

/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class Display extends Canvas {
    
	private static final int WIDTH = 1024;
	private static final int HEIGHT = 1024;
	
	public Display(JFrame frame) {
		this.setSize(WIDTH, HEIGHT);			
		this.requestFocus();		
    }
    
	public void paint(Graphics g) {
		
	}

	private static JFrame frame;
	private static Display display;

	public static void draw(BigInteger x, BigInteger y, BigInteger r, BigInteger g, BigInteger b) {
		if(display == null) {
			frame = new JFrame("Raytracer Display");
			display = new Display(frame);
			frame.setSize(500, 500);
			frame.pack();
			frame.setVisible(true);
		}
	}    
	
	public void paint(Graphics g) {
		int width = WIDTH;
		int height = HEIGHT;
		g.drawImage(offscreen, 0);
		g.draw
	}
	
	private Image offscreen = null;
	public void update(Graphics g) {	
		if(offscreen == null) {
			initialiseOffscreen();			
		} 
		Image localOffscreen = offscreen;
		Graphics offgc = offscreen.getGraphics();		
		// do normal redraw
		paint(offgc);
		// transfer offscreen to window
		g.drawImage(localOffscreen, 0, 0, this);
	}

	private void initialiseOffscreen() {
		Dimension d = size();
		offscreen = createImage(d.width, d.height);
		// clear the exposed area
		Graphics offgc = offscreen.getGraphics();
		offgc.setColor(getBackground());
		offgc.fillRect(0, 0, d.width, d.height);
		offgc.setColor(getForeground());
		
		// First, draw the board
		
		for(int x=0;x!=WIDTH;++x) {
			for(int y=0;y!=HEIGHT;++y) {
				
			}
		}
		
	}
	
	public static void main(String[] args) {
		draw(null,null,null,null,null);
	}
}
