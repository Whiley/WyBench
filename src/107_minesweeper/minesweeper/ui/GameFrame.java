package minesweeper.ui;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;
import javax.swing.border.Border;

/**
 * Implements the outer window of the Robot War game. This includes any buttons,
 * the window frame itself and its title.
 * 
 * @author David J. Pearce
 * 
 */
public class GameFrame extends JFrame implements ActionListener {
	private JPanel centerPanel;
	private GameCanvas canvas;

	public GameFrame(Board board) {
		super("Minewseeper");

		canvas = new GameCanvas(board);
		centerPanel = new JPanel();
		centerPanel.setLayout(new BorderLayout());
		Border cb = BorderFactory.createCompoundBorder(
				BorderFactory.createEmptyBorder(3, 3, 3, 3),
				BorderFactory.createLineBorder(Color.gray));
		centerPanel.setBorder(cb);		
		centerPanel.add(canvas, BorderLayout.CENTER);
		
		add(centerPanel, BorderLayout.CENTER);
		
		setFocusable(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		pack();
		setVisible(true);

	}

	@Override
	public void actionPerformed(ActionEvent arg0) {
		// TODO Auto-generated method stub
		
	}
}
