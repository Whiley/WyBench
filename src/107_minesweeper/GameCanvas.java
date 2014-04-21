import java.io.File;
import java.io.IOException;
import java.awt.*;

import javax.imageio.ImageIO;

/**
 * <p>
 * Implements the battle area in which robots are drawn. This is implement as an
 * extension of java.awt.Canvas, and robots are drawn directly onto this as
 * images. The background is constructed by drawing a sequence of filled squares
 * with different colours.
 * </p>
 * 
 * <p>
 * The battle area uses "interpolation" to give the robots smoother movement
 * from one square to another. The idea behind interpolation is that we plot the
 * line from the current position to the next position and then draw the robot
 * at different positions along that line. This stops the robot from seemingly
 * "jumping" from one location to another.
 * </p>
 * 
 * @author David J. Pearce
 * 
 */
public class GameCanvas extends Canvas {

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
	 * Represents the image of an exposed blank square (i.e. with no rank).
	 */
	private static Image exposedBlankSquare = loadImage("ExposedSquare1.png");

	/**
	 * Width of the board in squares
	 */
	private int width;
	
	/**
	 * Height of the board in squares
	 */
	private int height;
	
	/**
	 * Construct a canvas to visually display a given robot battle.
	 * 
	 * @param battle
	 */
	public GameCanvas(int width, int height) {
		
		setBounds(0, 0, width * SQUARE_WIDTH, height * SQUARE_HEIGHT);
	}

	/**
	 * Paint the given battle onto the given graphics object.
	 */
	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;
		int width = getWidth();
		int height = getHeight();

		// Draw the background of the display as a rectangle of all white.
		g2d.setColor(Color.WHITE);
		g2d.fillRect(0, 0, width, height);

		// Draw the squares of the game
		for (int x = 0; x < width; x = x + 1) {
			for (int y = 0; y < height; y = y + 1) {
				int xp = x * SQUARE_WIDTH;
				int yp = y * SQUARE_HEIGHT;
				g.drawImage(exposedBlankSquare, xp, yp, SQUARE_WIDTH,
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
}
