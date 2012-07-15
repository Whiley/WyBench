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
import wyjc.runtime.List;

/*
 * This File is part of the Tetris Benchmark for Whiley
 * @author LeeTrezise
 * 
 */
public class Display$native extends Canvas {
    
	private static final int WIDTH = 256;
	private static final int HEIGHT = 256;
	
	private static BufferedImage offscreen = null;
	public void paint(Graphics g) {	
		// transfer offscreen to window
		g.drawImage(offscreen, 0, 0, this);
	}

	private static void initialiseOffscreen() {
		offscreen = new BufferedImage(WIDTH,HEIGHT,BufferedImage.TYPE_INT_RGB);
		// clear the exposed area
		Graphics offgc = offscreen.getGraphics();
		offgc.setColor(Color.BLACK);
		offgc.fillRect(0, 0, WIDTH, HEIGHT);		
	}
	
	private static JFrame frame;
	private static Display$native display;

        public static void paint(List reds, List greens, List blues) {
	    int size = reds.size();
	    int[] data = new int[size];
	    for(int i=0;i!=size;++i) {
		int red = ((BigInteger)reds.get(i)).byteValue();
		int green = ((BigInteger)greens.get(i)).byteValue();
		int blue = ((BigInteger)blues.get(i)).byteValue();
		int rgb = ((red & 0xFF) << 16) | ((green & 0xFF) << 8) | ((blue & 0xFF));
		data[i] = rgb;
	    }
	    paint(data);
	}
	
	public static void paint(int[] data) {	
		if(display == null) {
			frame = new JFrame("Raytracer Display");
			display = new Display$native();
			display.setSize(WIDTH,HEIGHT);
			frame.add(display);
			frame.setSize(WIDTH,HEIGHT);
			frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
			frame.pack();
			initialiseOffscreen();
		}
		offscreen.setRGB(0,0,WIDTH,HEIGHT,data,0,WIDTH);
		display.repaint();
		frame.setVisible(true);
	}    

    public static void main(String[] args) {
	int[] data = new int[WIDTH*HEIGHT];
	for(int i=0;i!=100;++i) {
	    data[i + (i*WIDTH)] = 100;
	}
	paint(data);
    }
}
