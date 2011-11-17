import java.util.*;
import java.io.*;

public class JavaMain {
    public static final class Parser {
	private final String input;
	private int pos;
	
	public Parser(String input) {
	    this.input = input;
	    this.pos = 0;			
	}

	public double[] parse() {
	    ArrayList<Double> rs = new ArrayList<Double>();
	    skipWhiteSpace();
	    while(pos < input.length()) {
		double i = parseReal();
		rs.add(i);
		skipWhiteSpace();
	    }
	    double[] is = new double[rs.size()];
	    for(int i=0;i!=is.length;++i) {
		is[i] = rs.get(i);
	    }
	    return is;
	}
	
	public double parseReal() {
	    int start = pos;
	    while (pos < input.length() && (Character.isDigit(input.charAt(pos)) || input.charAt(pos) == '.')) {
		pos = pos + 1;
	    }	    
	    return Double.parseDouble(input.substring(start, pos));
	}
	
	public void skipWhiteSpace() {
	    while (pos < input.length()
		   && (input.charAt(pos) == ' ' || input.charAt(pos) == '\t' || input.charAt(pos) == '\r')) {
		pos = pos + 1;
	    }
	}
    }

    public static double[] readFile(String filename) throws IOException {
	BufferedReader reader = new BufferedReader(new FileReader(filename));
	String file = "";
	String line = "";
	while ( (line = reader.readLine()) != null) {
	    file = file + " " + line;
	}
	return new Parser(file).parse();
    }
    
    public static double average(double[] data) {
	double r = 0;
	for(double d : data) {
	    r = r + d;
	}
	return r / data.length;
    }

    public static void main(String[] args) {
	try {
	    double[] data = readFile(args[0]);
	    double avg = average(data);
	    System.out.print(avg);
	} catch(IOException e) {
	    e.printStackTrace();
	}
    }
}
