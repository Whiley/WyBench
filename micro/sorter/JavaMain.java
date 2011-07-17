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

    public static int[] tmp;
    
    public static void sort(int[] data) {
	tmp = new int[data.length];
	sort(data,0,data.length);
    }

    public static void sort(int[] data, int low, int high) {
	int length = high-low;
	if(length > 1) {
	    int pivot = (high + low) / 2;
	    sort(data,low,pivot);
	    sort(data,pivot,high);
	    int left = low;
	    int right = pivot;
	    int index = low;
	    while(left < pivot && right < high) {
		int l = data[left];
		int r = data[right];
		if(l < r) {
		    tmp[index++] = l;
		    left++;
		} else {
		    tmp[index++] = r;
		    right++;
		}
	    } 
	    // tidy up loose ends
	    while(left < pivot) {
		tmp[index++] = data[left++];
	    }
	    while(right < high) {
		tmp[index++] = data[right++];
	    }
	    // final copy
	    for(int i=low;i<high;++i) {
		data[i]=tmp[i];
	    }
	}
    }

    public static void main(String[] args) {
	try {
	    int[] data = readFile(args[0]);
	    sort(data);
	    System.out.print(Arrays.toString(data));
	} catch(IOException e) {
	    e.printStackTrace();
	}
    }
}
