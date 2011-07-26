import java.util.*;
import java.io.*;

class JavaMain {
    public static final class Parser {
	private final String input;
	private int pos;
	
	public Parser(String input) {
	    this.input = input;
	    this.pos = 0;			
	}

	public int[] parse() {
	    ArrayList<Integer> rs = new ArrayList<Integer>();
	    skipWhiteSpace();
	    while(pos < input.length()) {
		int i = parseInt();
		rs.add(i);
		skipWhiteSpace();
	    }
	    int[] is = new int[rs.size()];
	    for(int i=0;i!=is.length;++i) {
		is[i] = rs.get(i);
	    }
	    return is;
	}
	
	public int parseInt() {
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

    public static int[] readFile(String filename) throws IOException {
	BufferedReader reader = new BufferedReader(new FileReader(filename));
	return new Parser(reader.readLine()).parse();
    }


    public static int gcd(int a, int b) {
	if(a == 0) {
	    return b;
	}		   
	while(b != 0) {
	    if(a > b) {
		a = a - b;
	    } else {
		b = b - a;
	    }
	}
	return a;
    }

    public static void main(String[] args) {
	try {
	    int[] data = readFile(args[0]);
	    for(int i=0;i<data.length;++i) {
		for(int j=i+1;j<data.length;++j) {
		    System.out.println(gcd(i,j));
		}
	    }
	} catch(IOException e) {
	    e.printStackTrace();
	}

    }
}
