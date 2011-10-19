import * from whiley.io.File
import * from whiley.lang.System
import whiley.lang.*

define Graph as {(int,int)} // FIXME

[Graph] parseGraphs(string input) throws string:
    graphs = []
    pos = 0
    while pos < |input|:
        graph,pos = parseGraph(pos,input)
        graphs = graphs + [graph]
    return graphs

(Graph,int) parseGraph(int pos, string input) throws string:
    graph = {}
    pos = match("{",pos,input)
    firstTime = true
    while pos < |input| && input[pos] != '}':
        if !firstTime:
            pos = match(",",pos,input)
        firstTime=false
        from,pos = parseInt(pos,input)
        pos = match(">",pos,input)
        to,pos = parseInt(pos,input)
    pos = match("}",pos,input)    
    pos = skipWhiteSpace(pos,input) // parse any newline junk
    return graph,pos

int match(string match, int pos, string input) throws string:
    end = pos + |match|
    if end < |input|:
        tmp = input[pos..end]
        if tmp == match:
            return end
        else:
            throw "expected " + match + ",found " + tmp
    else:
        throw "unexpected end-of-file"

(int,int) parseInt(int pos, string input):
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw "Missing number"
    return String.toInt(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())
    graphs = parseGraphs(input)
    // third, print output
    sys.out.print(String.str(graphs))
