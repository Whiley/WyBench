import java.io.File;
import java.io.IOException;
import java.awt.*;
import java.awt.event.MouseListener;
import java.awt.event.MouseEvent;

import javax.imageio.ImageIO;

import javax.swing.*;
import javax.swing.border.Border;

/**
 * Implements the graphical user interface for the Minesweeper
 * game. The outer frame includes any buttons, the window frame itself
 * and its title.  The inner canvas is where the graphics are actually
 * drawn.
 * 
 * @author David J. Pearce
 * 
 */
public class GraphicalUserInterface extends JFrame {
	private JPanel centerPanel;
	private GameCanvas canvas;

	public GraphicalUserInterface(BoardAdaptor board) {
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

    static class GameCanvas extends Canvas implements MouseListener {
	
	/**
	 * The image path simply determines where images are stored relative to this
	 * class.
	 */
	private static final String IMAGE_PATH = "images" + File.separator;
	
	/**
	 * The square width constant determines the width (in pixels) of a square in
	 * the battle area. Changing this constant should automatically reshape the
	 * display. The optimal size is 24x24, based on the dimensions of the images
	 * used for the robots.
	 */
	private static final int SQUARE_WIDTH = 24;
	
	/**
	 * The square height constant determines the height (in pixels) of a square
	 * in the battle area. Changing this constant should automatically reshape
	 * the display. The optimal size is 24x24, based on the dimensions of the
	 * images used for the robots.
	 */
	private static final int SQUARE_HEIGHT = 24;

	/**
	 * Represents the image of an exposed square containing a bomb
	 */
	private static Image exposedBomb = loadImage("ExposedBombSquare.png");

	/**
	 * Contains the images of exposed blank squares of various rank
	 */
	private static Image[] exposedSquares = {
	    loadImage("ExposedBlankSquare.png"),
	    loadImage("ExposedSquare1.png"),
	    loadImage("ExposedSquare2.png"),
	    loadImage("ExposedSquare3.png"),
	    loadImage("ExposedSquare4.png")
	};

	/**
	 * Represents the image of a hidden square (i.e. not flagged).
	 */
	private static Image hiddenSquare = loadImage("HiddenSquare.png");

	/**
	 * Represents the image of a hidden square (i.e. not flagged).
	 */
	private static Image flaggedSquare = loadImage("HiddenSquareFlagged.png");

	/**
	 * The game board
	 */
        private BoardAdaptor board;
	
	/**
	 * Construct a canvas to visually display the minesweeper game
	 * 
	 * @param battle
	 */
	public GameCanvas(BoardAdaptor board) {
	    this.board = board;
	    setBounds(0, 0, board.getWidth() * SQUARE_WIDTH, board.getHeight() * SQUARE_HEIGHT);
	    addMouseListener(this);
	}

	/**
	 * Paint the minesweeepr board onto the given graphics object.
	 */
	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;

		// Draw the background of the display as a rectangle of all white.
		g2d.setColor(Color.WHITE);
		g2d.fillRect(0, 0, board.getWidth(), board.getHeight());

		// Draw the squares of the game
		for (int x = 0; x < board.getWidth(); x = x + 1) {
		    for (int y = 0; y < board.getHeight(); y = y + 1) {
			Image image;
			if(board.isExposedSquare(x,y)) {
			    if(board.holdsBomb(x,y)) {
				image = exposedBomb;
			    } else {
				int rank = board.getRank(x,y);
				image = exposedSquares[rank];
			    }
			} else if(board.isFlagged(x,y)) {
			    image = flaggedSquare;			    
			} else {
			    image = hiddenSquare;
			}
			int xp = x * SQUARE_WIDTH;
			int yp = y * SQUARE_HEIGHT;
			g.drawImage(image, xp, yp, SQUARE_WIDTH,
				    SQUARE_HEIGHT, null, null);
		    }
		}
	}
	
	/**
	 * An offscreen buffer used to reduce flicker between frames.
	 */
	private Image offscreen = null;
	
	public void update(Graphics g) {
	    int width = getWidth();
	    int height = getHeight();
	    if (offscreen == null || offscreen.getWidth(this) != width
		|| offscreen.getHeight(this) != height) {
		offscreen = createImage(width, height);
	    }
	    Image localOffscreen = offscreen;
	    Graphics2D offgc = (Graphics2D) offscreen.getGraphics();
	    // do normal redraw
	    paint(offgc);
	    // transfer offscreen to window
	    g.drawImage(localOffscreen, 0, 0, this);
	}
	
	private static Image loadImage(String filename) {
	    // using the URL means the image loads when stored
		// in a jar or expanded into individual files.
		java.net.URL imageURL = GameCanvas.class.getResource(IMAGE_PATH
				+ filename);

		try {
			Image img = ImageIO.read(imageURL);
			return img;
		} catch (IOException e) {
			// we've encountered an error loading the image. There's not much we
			// can actually do at this point, except to abort the game.
			throw new RuntimeException("Unable to load image: " + filename);
		}
	}

	public void mousePressed(MouseEvent e) {
	}
	
	public void mouseReleased(MouseEvent e) {
	}
	
	public void mouseEntered(MouseEvent e) {
	}
	
	public void mouseExited(MouseEvent e) {
	}
	
	public void mouseClicked(MouseEvent e) {	
	    int x = e.getX() / SQUARE_WIDTH;
	    int y = e.getY() / SQUARE_HEIGHT;
	    if(e.getButton() == MouseEvent.BUTTON1) {
		board.exposeSquare(x,y);
	    } else if(e.getButton() > MouseEvent.BUTTON1) {
		board.flagSquare(x,y);
	    }
	    repaint();
	}
    }
}
