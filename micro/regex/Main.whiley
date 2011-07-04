
// top-level call
bool match(string regexp, string text):
    return match(0,regexp,0,text)

// match: search for regexp anywhere in text
bool match(int rpos, string regexp, int tpos, string text):
    if regexp[0] == '^':
        return matchhere(rpos+1,regexp,tpos,text)
    while rpos < |regexp|:
        if matchhere(rpos,regexp,tpos,text):
            return true
        else:
            rpos = rpos + 1
    return false

// matchhere: search for regexp at beginning of text
bool matchhere(int rpos, string regexp, int tpos, string text):
    if rpos == |regexp|:
        return true
    else if (rpos+1) < |regexp| && regexp[rpos+1] == '*':
        return matchstart(regexp[rpos],rpos+2,regexp,tpos,text)
    else if regexp[rpos] == '$' && (rpos+1) == |regexp|:
        return tpos == |text|
    else if tpos < |text| && (regexp[rpos]=='.' || regexp[rpos] == text[rpos]):
        return matchhere(rpos+1,regexp,tpos+1,text)
    else:
        return false

// matchstar: search for c*regexp at beginning of text
bool matchstart(char c, int rpos, string regexp, int tpos, string text):
    // first, check for zero matches
    if matchhere(rpos,regexp,tpos,text):
        return true
    // second, check for one or more matches
    while tpos < |text| && (text[tpos] == c || c == '.'):
        if matchhere(rpos,regexp,tpos,text):    
            return true
        else:
            tpos = tpos + 1
    return false
        
void System::main([string] args):
    regexp = args[0]
    text = args[1]
    r = match(regexp,text)
    if r:
        out.println(str(regexp) + " matches " + str(text))
    else:
        out.println(str(regexp) + " does not match " + str(text))