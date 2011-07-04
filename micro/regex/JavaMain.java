import java.util.regex.Pattern;
import java.io.*;

public class JavaMain {

    public static boolean match(String regex, String text) {
	if (regex.length() != 0 && regex.charAt(0) == '^') {
	    return matchHere(text, regex.substring(1));
	}
	//loop through the text attempting to match,
	// quit at the first success or the end of the text
	do {
	    if (matchHere(regex, text)) {
		return true;
	    }
	    text = text.substring(1);
	} while (text.length() != 0);
	return false;
    }
	
    protected static boolean matchHere(String regex, String text) {
	if (regex.length() == 0) {
	    return true;
	}
	// check for a starred pattern in the regex
	if (regex.length() > 1 && regex.charAt(1) == '*') {
	    return matchStar(regex.charAt(0), regex.substring(2), text);
	}
	if (regex.length() == 1 && regex.charAt(0) == '$') {
	    return text.length() == 0;
	}
	//recursively match the whole text with the regex, one char at a time
	if (text.length() > 0 && (regex.charAt(0) == '.' || regex.charAt(0) == text.charAt(0))) { 
	    return matchHere(regex.substring(1), text.substring(1));
	}
	return false;
    }
	
    protected static boolean matchStar(char c, String regex, String text) {

	if (matchHere(regex, text)) {
	    return true;
	}

	while (text.length() != 0 && (text.charAt(0) == c || c == '.')) {			
	    if (matchHere(regex, text)) {
		return true;
	    }
	    text = text.substring(1);
	} 

	return false;
    }

    private static boolean matchWithLib(String text, String regex) {
	Pattern p = Pattern.compile(regex);
	java.util.regex.Matcher m = p.matcher(text);
	return m.find();
    }


    public static void main(String[] args) {
	BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
	
	int total = 0;
	int passes = 0;
	
	while(true) {
	    String input = null;
	    String regex = null;			
	    try {
		input = reader.readLine();
		if(input == null) {
		    // end-of-file reached.
		    break;
		}				
		regex = reader.readLine();
		total = total + 1;
		
		boolean theiranswer = match(input, regex);
		boolean rightanswer = matchWithLib(input,regex);
		
		if(theiranswer == rightanswer) {					
		    System.out.println("Test " + total + ": PASSED");					
		    System.out.println("Input: " + input);
		    System.out.println("Regex: " + regex);
		    if(rightanswer) {
			System.out.println("Matched (correct)\n");
		    } else {
			System.out.println("No match (correct)\n");
		    }
		    passes ++;
		} else {					
		    System.out.println("Test " + total + ": FAILED");					
		    System.out.println("Input: " + input);
		    System.out.println("Regex: " + regex);
		    if(rightanswer) {
			System.out.println("No match (incorrect)\n");
		    } else {
			System.out.println("Matched (incorrect)\n");
		    }
		}
	    } catch(Throwable e) {				
		System.out.println("Test " + total + ": FAILED");				
		System.out.println("Input: " + input);
		System.out.println("Regex: " + regex);
		System.out.println("Exception occurred (" + e.getClass().getName() + "): " + e.getMessage());
		System.out.println();
	    }
	}
	
	System.out.println("Exactly " + passes + " / " + total + " tests passed.");
	System.err.print("= " + passes + " / " + total);
	System.exit(0);
    }
}
