package assignment1;

import java.util.regex.Pattern;

/**
 * A basic regular expression matcher. Matches regular expressions consisting of .*$^ and any
 * character literal.
 * <p>
 * A regular expressions (or regexes) are a very small language for describing text strings. A
 * regex describes zero or more strings; a regex matcher attempts to match a text string with a
 * regex. A match occurs if the text string is described by the regex. See
 * <a href="http://en.wikipedia.org/wiki/Regex"> wikipedia </a> for
 * more details
 * <p>
 * A regular expression consists of characters which match against themselves and control
 * characters which have special behaviour, such as wildcard characters. There are many varieties
 * of regular expression languages with different syntax and semantics. The language for this
 * assignment is a small subset of the most common language, used in Perl and Java and elsewhere.
 * <p>
 * If you are unclear on whether a regex should match a text string or not you could use the Java
 * regex library to compare against, this might be useful in the edge cases. The method
 * matchWithLib will help you do this. Note that you may not use the Java regex library in your
 * solutions (only to help you understand regular expressions).
 * 
 * <ul>
 * <li>A character literal matches that character.
 * <li>. matches any character
 * <li>* matches zero or more occurrences of the preceding character (if there is no preceding char, then never matches)
 * <li>^ matches the start of a string
 * <li>$ matches the end of a string
 * </ul>
  */

public class BasicMatcher implements Matcher {

	/**
	 * {@inheritDoc}
	 */
	public boolean match(String text, String regex) {
		if (regex.length() != 0 && regex.charAt(0) == '^') {
			return matchHere(text, regex.substring(1));
		}
		//loop through the text attempting to match,
		// quit at the first success or the end of the text
		do {
			if (matchHere(text, regex)) {
				return true;
			}
			if (text.length() == 0) {
				return true;
			}
			text = text.substring(1);
		} while (text.length() != 0 && matchChar(text,regex));
		return false;
	}
	
	/**
	 * Returns whether the given regular expression can be matched against
	 * the start of the text string.
	 * This is in contrast to the {@link #match(String, String)} method
	 * which attempts to match the regular expression anywhere in the text string.
	 * 
	 * @param text some text to match
	 * @param regex a regular expression to match against
	 * @return true if the regular expression can be matched
	 *                against the start of the string; false otherwise
	 */
	protected boolean matchHere(String text, String regex) {
		if (regex.length() == 0) {
			return true;
		}
		if (regex.charAt(0) == '^') {	
			return matchHere(text, regex.substring(1));
		}
		if (regex.length() == 1 && regex.charAt(0) == '$') {
			return text.length() == 0;
		}
		// check for a starred pattern in the regex
		if (regex.length() > 1 && regex.charAt(1) == '*') {
			return matchStar(text, regex);
		}
		//recursively match the whole text with the regex, one char at a time
		if (matchChar(text, regex)) { 
			return matchHere(text.substring(1), regex.substring(1));
		}
		return false;
	}
	
	/**
	 * Assumes that the start of the regex is some character followed by a '*' character.
	 * It tries to match the first character of the regular expression zero or more times
	 * against the text input, and then attempts to match the rest of the regular expression
	 * against the rest of the text input.
	 * 
	 * @param text some text to match
	 * @param regex the regular expression;
	 *      must be at least two characters long, and the second should be '*'
	 * @return true if the match is successful, false otherwise.
	 */
	protected boolean matchStar(String text, String regex) {
		String restOfRegex = regex.substring(1);
		// we cannot use a do...while loop (although it would be nicer), why not?
		if (matchHere(text, restOfRegex)) {
			return true;
		}
		// match as few characters as possible and try to match the rest of the regex
		// this effectively backtracks when we can't match the rest of the regex and
		// tries matching more characters to the star
		while (matchChar(text, regex)) {			
			text = text.substring(1);
			if (matchHere(text, restOfRegex)) {
				return true;
			}
			if (text.length() == 0) {
				return false;
			}
		} 
		return false;
	}
	
	/**
	 * Matches the first character of the text against the first character of the regex.
	 * <p>
	 * @param text to be matched against the regular expression
	 * @param regex the regular expression used for matching
	 * @return true if the first characters match; false otherwise.
	 */
	protected boolean matchChar(String text, String regex) {
		return regex.charAt(0) == '.' ||
			(regex.charAt(0) == text.charAt(0) &&
					text.charAt(0) != '*');
	}

	/**
	 * Attempts to match text against regex using the Java regex library.
	 * <p>
	 * This method is not used by the above matching code,
	 * and you must NOT use it in your solution!
	 * 
	 * @param text - A text string to match (String)
	 * @param regex - A regular expression to match against (String)
	 * @return true if the match is successful, false otherwise
	 */
	private boolean matchWithLib(String text, String regex) {
			Pattern p = Pattern.compile(regex);
			java.util.regex.Matcher m = p.matcher(text);
			return m.find();
	}
}
