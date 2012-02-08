import java.io.*;
import java.util.*;

public class JavaMain {
	public final static class Combination {
		public final char first;
		public final char second;
		
		public Combination(char f, char s) {
			if(s < f) {
				this.first = s;
				this.second = f;			
			} else {
				this.first = f;
				this.second = s;
			}
		}
		
		public boolean equals(Object o) {
			if (o instanceof Combination) {
				Combination c = (Combination) o;
				return first == c.first && second == c.second;
			}
			return false;
		}

		public int hashCode() {
			return first + second;
		}
		
		public String toString() {
			return first + "," + second;
		}
	}
	
	public final static class Test {
		public final HashMap<Combination,Character> combines;
		public final HashSet<Combination> opposes;
		public final ArrayList<Character> sequence;
		
		public Test(HashMap<Combination,Character> combines, HashSet<Combination> opposes, ArrayList<Character> sequence) {
			this.combines = combines;
			this.opposes = opposes;
			this.sequence = sequence;
		}
		public String toString() {
			String r = "";
			boolean firstTime = true;
			for(Map.Entry<Combination,Character> c : combines.entrySet()) {
				if(!firstTime) {
					r += ", ";
				}
				firstTime=false;
				r += c.getKey() + "=>" + c.getValue();
			}
			firstTime=true;
			r += " : ";
			for(Combination c : opposes) {
				if(!firstTime) {
					r += ", ";
				}
				firstTime=false;
				r += c.first + "<X>" + c.second;
			}			
			r += " :";
			for(Character c : sequence) {
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
		
		public Test parseTest() {			
			HashMap<Combination,Character> combines = new HashMap();
			HashSet<Combination> opposes = new HashSet();
			ArrayList<Character> sequence = new ArrayList();
			int ncombs = parseInt();
			while(ncombs > 0) {
				skipWhiteSpace();
				char c1 = input.charAt(pos++);
				char c2 = input.charAt(pos++);
				char c3 = input.charAt(pos++);
				combines.put(new Combination(c1,c2),c3);
				ncombs--;
			}
			int nopps = parseInt();
			while(nopps > 0) {
				skipWhiteSpace();
				char c1 = input.charAt(pos++);
				char c2 = input.charAt(pos++);				
				if(c1 == c2) {
					throw new RuntimeException("MUTUAL OPPOSITION: " + c1);
				}
				opposes.add(new Combination(c1,c2));
				nopps--;
			}
			int nseqs = parseInt();
			skipWhiteSpace();
			while(nseqs > 0) {
				sequence.add(input.charAt(pos++));
				nseqs--;
			}
			return new Test(combines,opposes,sequence);
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
	
	public static List<Character> process(Test t) {
		ArrayList<Character> stack = new ArrayList();			
		for(Character c : t.sequence) {
			if(stack.size() < 1) {
				stack.add(c);
			} else {
				char l = stack.get(stack.size()-1);
				Character n = t.combines.get(new Combination(c,l));
				if(n != null) {					
					// combination applies
					stack.remove(stack.size()-1);
					stack.add(n);
				} else {
					// now test for oppositions
					boolean opposed = false;
					for(Character o : stack) {						
						if(t.opposes.contains(new Combination(c,o))) {
							opposed = true;
							break;
						}
					}
					if(opposed) {
						stack.clear();
					} else {
						stack.add(c);
					}
				}
			} 
		}
		
		return stack;		
	}
	
	public static void main(String[] args) {
		try {
		    List<Test> tests = readFile(new FileInputStream(args[0]));
		    int c = 1;
		    for(Test t : tests) {
			//System.out.println(t);
			System.out.println("Case #" + c + ": " + process(t));
			c++;
		    }
		} catch(IOException e) {
			System.err.println("I/O error: " + e.getMessage());
		}
	}
}
