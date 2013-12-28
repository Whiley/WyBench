
public class Main {

	public class Timer extends Thread {
		public void run() {
			while(1==1) {
				try {
					Thread.sleep(10); // 1ms delay					
				} catch(InterruptedException e) {
					// impossible
				}
			}
		}
	}
	
	public static void main(String[] args) {
		new LanderFrame();
	}
}
