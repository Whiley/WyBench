package lander.ui;

import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferStrategy;

public class SimpleCanvas extends Canvas implements KeyListener {
	private BufferStrategy strategy;
	private Graphics graphics;
	
	public SimpleCanvas() {
		this.setPreferredSize(new Dimension(600,600));
		addKeyListener(this);		
		// Add the hook for the native call back from whiley
		lander.ui.LanderCanvas$native.canvas = this;
	}
	
	public void init() {
		createBufferStrategy(2);
		strategy = getBufferStrategy();
		graphics = strategy.getDrawGraphics();
	}
		
	public void paint(Graphics g) {
			strategy.show();
			graphics.dispose();
			graphics = strategy.getDrawGraphics();
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
