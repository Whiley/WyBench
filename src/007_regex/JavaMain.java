import java.util.regex.Pattern;
import java.io.*;

public class JavaMain {

    public static boolean match(String regex, String text) {
	if (regex.length() != 0 && regex.charAt(0) == '^') {
	    return matchHere(regex.substring(1),text);
	}

	if (matchHere(regex, text)) {
	    return true;
	} 

	 while (text.length() != 0) {
	    if (matchHere(regex, text)) {
		return true;
	    }
	    text = text.substring(1);
	}

	return false;
    }
	
    protected static boolean matchHere(String regex, String text) {
	if (regex.length() == 0) {
	    return true;
	}
	if (regex.length() > 1 && regex.charAt(1) == '*') {
	    return matchStar(regex.charAt(0), regex.substring(2), text);
	}
	if (regex.length() == 1 && regex.charAt(0) == '$') {
	    return text.length() == 0;
	}
	if (text.length() > 0 && (regex.charAt(0) == '.' || regex.charAt(0) == text.charAt(0))) { 
	    return matchHere(regex.substring(1), text.substring(1));
	}
	return false;
    }
	
    protected static boolean matchStar(char c, String regex, String text) {

	if (matchHere(regex, text)) {
	    return true;
	} 

	while(text.length() != 0  && (text.charAt(0) == c || c == '.')) {
	    if (matchHere(regex, text)) {
		return true;
	    }
	    text = text.substring(1);
	} 

	if (matchHere(regex, text)) {
	    return true;
	}	

	return false;
    }

    private static boolean matchWithLib(String regex, String text) {
	Pattern p = Pattern.compile(regex);
	java.util.regex.Matcher m = p.matcher(text);
	return m.find();
    }


    public static void main(String[] args) {
	try {
	    BufferedReader reader = new BufferedReader(new FileReader(args[0]));
	    
	    int total = 0;
	    
	    while(true) {
		String input = null;
		String regex = null;			
		
		input = reader.readLine();
		if(input == null) {
		    // end-of-file reached.
		    break;
		}				
		regex = reader.readLine();
		total = total + 1;
		System.out.println("putlic method test_" + total + "():");
		System.out.print("    assume ");
		if(!match(regex, input)) {
		    System.out.print("!");
		}
		System.out.println("match(\"" + regex + "\",\"" + input + "\")");
		System.out.println();
	    }
	    
	} catch(Throwable e) {				
	    e.printStackTrace();
	}
	
    }
}
