import lander.ui.*;

/**
 * The Main entry point for the lander game. This creates the Lander Frame and
 * controls how often it is refreshed.
 * 
 * @author David J. Pearce
 * 
 */
public class Main {

	/**
	 * The timer thread controls how often the Lander Frame is called.
	 * Effectively, this drives the game since it determines what the user
	 * actually sees.
	 * 
	 * @author David J. Pearce
	 * 
	 */
	public static class Timer extends Thread {

		private final LanderFrame frame;
		
		public Timer(LanderFrame frame) {
			this.frame = frame;
		}
		
		public void run() {
			while(1==1) {
				try {
					Thread.sleep(10); // 1ms delay
					frame.repaint();
				} catch(InterruptedException e) {
					// impossible
				}
			}
		}
	}
	
	/**
	 * Start the lander game by Creating a new LanderFrame and starting the
	 * timer thread.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		new Timer(new LanderFrame()).run();
	}
}
