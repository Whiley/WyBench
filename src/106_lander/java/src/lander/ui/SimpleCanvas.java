package lander.ui;

import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferStrategy;

/**
 * The SimpleCanvas provides a simple canvas on which we can draw graphics and
 * receive keyboard events. These are then hooked into the LanderCanvas on the
 * Whiley side.
 * 
 * @author David J. Pearce
 * 
 */
public class SimpleCanvas extends Canvas implements KeyListener {
	private BufferStrategy strategy;
	private Graphics2D graphics;
	
	public SimpleCanvas() {
		this.setPreferredSize(new Dimension(600,600));
		addKeyListener(this);		
		// Add the hook for the native call back from whiley
		lander.ui.LanderCanvas$native.canvas = this;
	}
	
	public void init() {
		createBufferStrategy(2);
		strategy = getBufferStrategy();
	}
		
	public void paint(Graphics g) {
			strategy.show();
			graphics = (Graphics2D) strategy.getDrawGraphics();
			LanderCanvas.paint();
			graphics.dispose();
			// flip/draw the backbuffer to the canvas component.
			strategy.show();
			// synchronize with the display refresh rate.
			Toolkit.getDefaultToolkit().sync();
	}

	// ======================================================================
	// Drawing Functions
	// ======================================================================	

	public void fillRect(int x, int y, int width, int height, Color color) {
		graphics.setColor(color);
		graphics.fillRect(x, y, width, height);
	}
	
	// ======================================================================
	// Key Handlers
	// ======================================================================	
	public void keyPressed(KeyEvent e) {
		int code = e.getKeyCode();
		if (code == KeyEvent.VK_RIGHT || code == KeyEvent.VK_KP_RIGHT) {
			
		} else if (code == KeyEvent.VK_LEFT || code == KeyEvent.VK_KP_LEFT) {
			
		} else if (code == KeyEvent.VK_UP) {

		} else if (code == KeyEvent.VK_DOWN) {

		}
	}
	
	public void keyReleased(KeyEvent e) {		
	}
	
	public void keyTyped(KeyEvent e) {
		
	}
}
