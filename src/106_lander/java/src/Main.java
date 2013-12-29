import lander.ui.*;

public class Main {

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
	
	public static void main(String[] args) {
		new Timer(new LanderFrame()).run();
	}
}
