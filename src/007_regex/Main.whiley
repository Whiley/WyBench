import whiley.lang.*
import whiley.lang.System
import whiley.io.File

import wybench.Parser

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII

// match: search for regexp anywhere in text
function match(string regex, string text) -> bool:
    if |regex| > 0 && regex[0] == '^':
        return matchHere(regex,1,text,0)
    if matchHere(regex,0,text,0):
        return true
    int i = 0
    while i < |text|:
        if matchHere(regex,0,text,i):
            return true
        else:
            i = i + 1
    return false

// matchHere: search for regex at beginning of text
function matchHere(string regex, int rIndex, string text, int tIndex) -> bool:
    if rIndex == |regex|:
        return true
    else if (rIndex+1) < |regex| && regex[rIndex+1] == '*':
        return matchStar(regex[rIndex],regex,rIndex+2,text,tIndex)
    else if rIndex + 1 == |regex| && regex[rIndex] == '$':
        return tIndex == |text|
    else if tIndex < |text| && (regex[rIndex]=='.' || regex[rIndex] == text[tIndex]):
        return matchHere(regex,rIndex+1,text,tIndex+1)
    else:
        return false

// matchstar: search for c*regex at beginning of text
function matchStar(char c, string regex, int rIndex, string text, int tIndex) -> bool:
    // first, check for zero matches
    if matchHere(regex,rIndex,text,tIndex):
        return true
    // second, check for one or more matches
    while tIndex != |text| && (text[tIndex] == c || c == '.'):
        if matchHere(regex,rIndex,text,tIndex):    
            return true
        else:
            tIndex = tIndex + 1
    if matchHere(regex,rIndex,text,tIndex):
        return true
    return false

public method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println_s("usage: regex <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        string[] data = Parser.parseStrings(input)
        int i = 0
        int nmatches = 0
        int total = 0
        while (i+1) < |data| where i >= 0:
            string text = data[i]
            string regex = data[i+1]
            if match(regex,text):
                nmatches = nmatches + 1
            total = total + 1
            i = i + 2
        //
        sys.out.print_s("Matched ")
        sys.out.print_s(Int.toString(nmatches))
        sys.out.print_s(" / ")
        sys.out.print_s(Int.toString(total))
        sys.out.println_s(" inputs.")
