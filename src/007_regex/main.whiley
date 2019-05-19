import string from std::ascii
import char from std::ascii
import std::ascii
import std::filesystem
import std::io

import nat from std::integer
import wybench::parser

// match: search for regexp anywhere in text
function match(string regex, string text) -> bool:
    if |regex| > 0 && regex[0] == '^':
        return matchHere(regex,1,text,0)
    if matchHere(regex,0,text,0):
        return true
    nat i = 0
    while i < |text|:
        if matchHere(regex,0,text,i):
            return true
        else:
            i = i + 1
    return false

// matchHere: search for regex at beginning of text
function matchHere(string regex, nat rIndex, string text, nat tIndex) -> bool
requires rIndex <= |regex|:
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
function matchStar(char c, string regex, nat rIndex, string text, nat tIndex) -> bool
requires rIndex <= |regex|:
    // first, check for zero matches
    if matchHere(regex,rIndex,text,tIndex):
        return true
    // second, check for one or more matches
    while tIndex < |text| && (text[tIndex] == c || c == '.'):
        if matchHere(regex,rIndex,text,tIndex):    
            return true
        else:
            tIndex = tIndex + 1
    if matchHere(regex,rIndex,text,tIndex):
        return true
    return false

public method main(string[] args):
    if |args| == 0:
        io::println("usage: regex <input-file>")
    else:
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        string input = ascii::from_bytes(file.read_all())
        int[][] data = parser::parseStrings(input)
        int i = 0
        int nmatches = 0
        int total = 0
        while (i+1) < |data| where i >= 0:
            // FIXME: Needed to verify
            assume data[i] is string
            assume data[i+1] is string
            //
            string text = data[i]
            string regex = data[i+1]
            if match(regex,text):
                nmatches = nmatches + 1
            total = total + 1
            i = i + 2
        //
        io::print("Matched ")
        io::print(nmatches)
        io::print(" / ")
        io::print(total)
        io::println(" inputs.")
