package lander.ui;
import java.awt.Color;
import java.math.BigInteger;

/**
 * A native hook providing a way for Whiley programs to draw graphics on a Java
 * Swing Canvas.
 * 
 * @author David J. Pearce
 * 
 */
public class LanderCanvas$native {
	
	/**
	 * A global hook to the canvas itself.
	 */
	public static lander.ui.SimpleCanvas canvas;
	
	public static void fillRectangle(BigInteger x, BigInteger y, BigInteger width, BigInteger height) {
		canvas.fillRect(x.intValue(),y.intValue(),width.intValue(),height.intValue(), Color.BLACK);
	}
}
