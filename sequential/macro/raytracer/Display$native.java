import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Font;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.image.BufferedImage;
import java.math.BigInteger;

import javax.swing.JFrame;

/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class Display$native extends Canvas {
    
	private static final int WIDTH = 512;
	private static final int HEIGHT = 512;
	
	private static BufferedImage offscreen = null;
	public void paint(Graphics g) {	
		// transfer offscreen to window
		g.drawImage(offscreen, 0, 0, this);
	}

	private static void initialiseOffscreen() {
		offscreen = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_RGB);
		// clear the exposed area
		Graphics offgc = offscreen.getGraphics();
		offgc.setColor(Color.WHITE);
		offgc.fillRect(0, 0, WIDTH, HEIGHT);		
	}
	
	private static JFrame frame;
	private static Display$native display;

	public static void draw(BigInteger x, BigInteger y, BigInteger r, BigInteger g, BigInteger b) {
		draw(x.intValue(),y.intValue(),r.byteValue(),g.byteValue(),b.byteValue());
	}
	
	public static void draw(int x, int y, int r, int g, int b) {	
		if(display == null) {
			frame = new JFrame("Raytracer Display");
			display = new Display$native();
			display.setSize(WIDTH,HEIGHT);
			frame.add(display);
			frame.setSize(WIDTH,HEIGHT);
			frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
			frame.pack();
			frame.setVisible(true);
			initialiseOffscreen();
		}
		int rgb = ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | ((b & 0xFF));
		offscreen.setRGB(x, y, rgb);
		display.repaint();
	}    
}
