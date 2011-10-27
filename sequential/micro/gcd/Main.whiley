import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

(int,int) parseInt(int pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",start,pos)
    return String.toInt(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

int gcd(int a, int b):
    if(a == 0):
        return b		   
    while(b != 0):
        if(a > b):
            a = a - b
        else:
            b = b - a
    return a

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())
    try:
        pos = 0
        data = []
        pos = skipWhiteSpace(pos,input)
        // first, read data
        while pos < |input|:
            i,pos = parseInt(pos,input)
            data = data + i
            pos = skipWhiteSpace(pos,input)
        // second, compute gcds
        for i in 0..|data|:
            for j in i+1..|data|:
                sys.out.println(gcd(i,j))
    catch(SyntaxError e):
        sys.out.println("error - " + e.msg)

