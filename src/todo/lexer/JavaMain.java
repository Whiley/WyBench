import java.io.*;

public class JavaMain {
    public interface Rule {
	int apply(int pos, String input);
    }

    public static final class Rule_1 implements Rule {
	public int apply(int pos, String input) {	    
	    return pos;
	}
    }

    public static final class CommentRule implements Rule {
	public int apply(int pos, String input) {
	    if((pos+1) < input.length() && input.charAt(pos) == '/' && input.charAt(pos+1) == '*') {
		pos = pos + 2;
		while((pos+1) < input.length() && (input.charAt(pos) != '*' || input.charAt(pos+1) != '/')) {
		    pos = pos + 1;
		}
		pos = pos + 1; // skip "/"
	    }
	    return pos;
	}
    }

    public static final class WhiteSpaceRule implements Rule {
	public int apply(int pos, String input) {
	    while(Character.isWhitespace(input.charAt(pos))) {
		pos++;
	    }
	    return pos;
	}
    }

    public static final Rule[] rules = {
	new CommentRule(),
	new WhiteSpaceRule()
    };

    public static int apply(int pos, String input) {
	for(Rule r : rules) {
	    int p = r.apply(pos,input);
	    if(p > pos) {
		return p;
	    }
	}
	// no application possible
	return pos;
    }

    public static void main(String[] args) {
	try {
	    BufferedReader reader = new BufferedReader(new FileReader(args[0]));
	    StringBuilder tmp = new StringBuilder();	    
	    int len = 0;
	    char[] buf = new char[1024]; 
	    while((len = reader.read(buf)) != -1) {
		tmp.append(buf,0,len);	    	
	    }		
	    String input = tmp.toString();	
	    
	    int opos = 0;
	    int pos = 0;
	    while((pos = apply(pos,input)) != opos) {
		opos = pos;
	    }
	    if(pos == input.length()) {
		System.out.println("Entire file was processed!");
	    } else {
		System.out.println("Error, file not completely processed!");
		System.out.println("Final position: " + pos);
	    }
	} catch(IOException e) {
	    System.out.println("I/O Error - " + e.getMessage());
	}
    }
}