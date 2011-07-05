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
        
void System::main([string] args):
    regex = args[0]
    text = args[1]
    r = match(regex,text)
    if r:
        out.println(str(regex) + " matches " + str(text))
    else:
        out.println(str(regex) + " does not match " + str(text))