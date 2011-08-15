import java.io.*;
import java.util.*;

public class JavaMain {
	public final static class Job {
		public final int button;
		public final boolean orange;
		
		public Job(boolean orange, int button) {
			this.button = button;
			this.orange = orange;
		}
		
		public String toString() {
			if(orange) {
				return "O " + button; 
			} else {
				return "B " + button;
			}
		}
	}
	
	public final static class Test {
		public final ArrayList<Job> jobs;
		public Test(ArrayList<Job> jobs) {
			this.jobs = jobs;
		}
		public String toString() {
			String r = "";
			boolean firstTime = true;
			for(Job j : jobs) {
				if(!firstTime) {
					r += ", ";
				}
				firstTime=false;
				r += j.toString();
			}
			return r;
		}
	}
	
	public static final class Parser {
		private final String input;
		private int pos;
		public Parser(String input) {
			this.input = input;
			this.pos = 0;			
		}
		
		public Test parseTest() {
			int nitems = parseInt();
			ArrayList<Job> jobs = new ArrayList(); 
			while(nitems > 0) {
				skipWhiteSpace();
				boolean orange = input.charAt(pos++) == 'O';
				skipWhiteSpace();
				int target = parseInt();
				jobs.add(new Job(orange,target));
				nitems--;
			}
			return new Test(jobs);
		}
	
		public int parseInt() {
			skipWhiteSpace();
			int start = pos;
			while (pos < input.length() && Character.isDigit(input.charAt(pos))) {
				pos = pos + 1;
			}
			return Integer.parseInt(input.substring(start, pos));
		}
		
		public void skipWhiteSpace() {
			while (pos < input.length()
					&& (input.charAt(pos) == ' ' || input.charAt(pos) == '\t')) {
				pos = pos + 1;
			}
		}
	}
	
	public static List<Test> readFile(InputStream in) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(in));
		int ntests = Integer.parseInt(reader.readLine());
		ArrayList<Test> tests = new ArrayList<Test>();
		while(ntests > 0) {
			Parser p = new Parser(reader.readLine());			
			tests.add(p.parseTest());
			ntests--;
		}
		return tests;
	}
	
	public static int process(Test t) {
		int Opos = 1;  // current oranage position
		int Bpos = 1;  // current blue position 
		int Osaved = 0;  // spare time orange has saved
		int Bsaved = 0;  // spare time blue has saved
		int time = 0;  // total time accumulated thus far
		
		for(Job j : t.jobs) {									
			// now calculate movement time
			if(j.orange){
				int diff = Math.abs(j.button - Opos);
				int timediff = Math.max(0, diff - Osaved) + 1;
				time = time + timediff;
				Bsaved += timediff;
				Osaved = 0;
				Opos = j.button;
			} else {
				int diff = Math.abs(j.button - Bpos);
				int timediff = Math.max(0, diff - Bsaved) + 1;
				time = time + timediff;
				Osaved += timediff;
				Bsaved = 0;
				Bpos = j.button;
			}
			/*
			System.out.println("==============================================");
			System.out.println("TIME: " + time);
			System.out.println("ORANGE: at " + Opos + ", saved " + Osaved + "s");
			System.out.println("BLUE: at " + Bpos + ", saved " + Bsaved + "s");
			*/
		}
		
		//System.out.println("--");
		
		return time;
	}
	
	public static void main(String[] args) {
		try {
		    List<Test> tests = readFile(new FileInputStream(args[0]));
		    int c = 1;
		    for(Test t : tests) {
			int time = process(t);
			System.out.println("Case #" + c + ": " + time);
			c++;
		    }
		} catch(IOException e) {
			System.err.println("I/O error: " + e.getMessage());
		}
	}
}
