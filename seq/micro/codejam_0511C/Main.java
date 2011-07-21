import java.io.*;
import java.util.*;

public class Main {	
	
	public final static class Test {
		public final int[] candies;
		
		public Test(int[] candies) {
			this.candies = candies;
		}
		public String toString() {
			String r = "";
			for(int c : candies) {
				r += " " + c;
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
		
		public Test parseTest(int ncandies) {			
			int[] candies = new int[ncandies];			
			for(int i=0;i<ncandies;++i) {
				skipWhiteSpace();					
				candies[i] = parseInt(); 				
			}			
			return new Test(candies);
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
			int ncandies = Integer.parseInt(reader.readLine());
			Parser p = new Parser(reader.readLine());			
			tests.add(p.parseTest(ncandies));
			ntests--;
		}
		return tests;
	}
	
	public static String toString(BitSet partition, int max) {
		String r = "";
		for(int i=0;i!=max;++i) {
			if(partition.get(i)) {
				r += "1";
			} else {
				r += "0";
			}
		}
		return r;
	}
	
	public static boolean next(BitSet partition, int max) {
		int i;		
		for(i=0;i!=partition.size();++i) {
			if(partition.get(i)) {				
				partition.set(i,false);
			} else {
				partition.set(i,true);
				break;
			}
		}
		return i >= max;
	}	
	
	public static int valueOf(BitSet partition, int[] candies) {
		// true in the partition is for sean
		int max = candies.length;
		int sean = 0;
		int patrick_left = 0;
		int patrick_right = 0;
		
		for(int i=0;i!=max;++i) {
			int candy = candies[i];
			if(partition.get(i)) {
				int old = sean;
				patrick_left = patrick_left ^ candy;
				sean = sean + candy;
				if(old > sean) {
					throw new RuntimeException("Integer Overflow");
				}
			} else {
				// patrick's addition is XOR
				patrick_right = patrick_right ^ candy;				
			}
		}
		
		if(patrick_left == patrick_right) {
			return sean;
		} else {
			return -1;
		}
		
	}
	
	public static int process(Test t) {
		int max = t.candies.length;		
		BitSet partition = new BitSet(t.candies.length);
		next(partition,max);
		int maxValue = -1;		
		do {
			if(partition.cardinality() != max) {
				int v = valueOf(partition, t.candies);
				maxValue = Math.max(maxValue,v);
			}
		} while(!next(partition,max));		
		return maxValue;
	}
	
	public static void main(String[] args) {
		try {
			List<Test> tests = readFile(System.in);
			int c = 1;
			for(Test t : tests) {
				int r = process(t);
				if(r < 0) {
					System.out.println("Case #" + c + ": NO");
				} else {
					System.out.println("Case #" + c + ": " + r);
				}
				c++;
			}
		} catch(IOException e) {
			System.err.println("I/O error: " + e.getMessage());
		}
	}
}
