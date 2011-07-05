import whiley.io.*

// match: search for regexp anywhere in text
bool match(string regex,string text):
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
bool matchHere(string regex, string text):
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
bool matchStar(char c, string regex, string text):
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

(string,int) readLine(int pos, string input):
    start = pos
    while pos < |input| && input[pos] != '\n' && input[pos] != '\r':
        pos = pos + 1
    line = input[start..pos]
    pos = pos + 1
    if pos < |input| && input[pos] == '\n':
        pos = pos + 1
    return line,pos

void System::main([string] args):
    file = this.openReader(args[0])
    input = ascii2str(file.read())
    out.println(input)
    pos = 0
    nmatches = 0
    total = 0
    while pos < |input|:
        text,pos = readLine(pos,input)        
        regex,pos = readLine(pos,input)
        if match(regex,text):
            nmatches = nmatches + 1
        else:
            out.println(regex + " did not match " + text)
        total = total + 1
    out.println("Matched " + str(nmatches) + " / " + str(total) + " inputs.")