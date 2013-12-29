import java.math.BigInteger;

import lander.ui.*;

import lander.swing.*;

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
					lander.ui.LanderCanvas.dump(BigInteger.ZERO,BigInteger.ZERO,BigInteger.TEN,BigInteger.TEN);
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
