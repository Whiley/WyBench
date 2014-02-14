import whiley.lang.*
import * from whiley.lang.System
import * from whiley.io.File

import nat from whiley.lang.Int

// match: search for regexp anywhere in text
function match(string regex,string text) => bool:
    if |regex| > 0 && regex[0] == '^':
        return matchHere(regex[1..],text)
    if matchHere(regex,text):
        return true
    while |text| > 0:
        if matchHere(regex,text):
            return true
        else:
            text = text[1..]
    return false

// matchHere: search for regex at beginning of text
function matchHere(string regex, string text) => bool:
    if |regex| == 0:
        return true
    else if |regex| > 1 && regex[1] == '*':
        return matchStar(regex[0],regex[2..],text)
    else if |regex| == 1 && regex[0] == '$':
        return |text| == 0
    else if |text| > 0 && (regex[0]=='.' || regex[0] == text[0]):
        return matchHere(regex[1..],text[1..])
    else:
        return false

// matchstar: search for c*regex at beginning of text
function matchStar(char c, string regex, string text) => bool:
    // first, check for zero matches
    if matchHere(regex,text):
        return true
    // second, check for one or more matches
    while |text| != 0 && (text[0] == c || c == '.'):
        if matchHere(regex,text):    
            return true
        else:
            text = text[1..]
    if matchHere(regex,text):
        return true
    return false

function readLine(nat pos, string input) => (string,nat):
    int start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r':
        pos = pos + 1
    string line = input[start..pos]
    pos = pos + 1
    if pos < |input| && input[pos] == '\n':
        pos = pos + 1
    return line,pos

public method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: regex <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = String.fromASCII(file.readAll())
        string text, string regex
        int pos = 0
        int nmatches = 0
        int total = 0
        while pos < |input| where pos >= 0:
            text,pos = readLine(pos,input)        
            regex,pos = readLine(pos,input)
            if match(regex,text):
                nmatches = nmatches + 1
            total = total + 1
        sys.out.println("Matched " ++ nmatches ++ " / " ++ total ++ " inputs.")
