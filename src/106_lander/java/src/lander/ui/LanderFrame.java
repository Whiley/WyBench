package lander.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Toolkit;

import javax.swing.JFrame;

public class LanderFrame extends JFrame {
	private final SimpleCanvas canvas;
	
	public LanderFrame() {
		super("Moon Lander");		
				
		canvas = new SimpleCanvas();				
		setLayout(new BorderLayout());			
		add(canvas, BorderLayout.CENTER);		
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);						

		// Center window in screen
		Toolkit toolkit = Toolkit.getDefaultToolkit();
		Dimension scrnsize = toolkit.getScreenSize();
		int width = 600;
		int height = 600;
		setBounds((scrnsize.width - width) / 2, (scrnsize.height - height) / 2,
				width, height);

		pack();			
		setResizable(false);				
	
		// Display window
		setVisible(true);		
		canvas.requestFocus();
		canvas.init();
	}	
}