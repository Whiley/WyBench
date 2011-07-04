import whiley.io.*

// ===============================================
// Definitions
// ===============================================

define Job as { int button, bool orange }
define Test as [Job]

// ===============================================
// Parser
// ===============================================

(Test,int) parseTest(int pos, string input):
    nitems,pos = parseInt(pos,input)
    jobs = []
    while nitems > 0:
        pos = skipWhiteSpace(pos,input)
        orange = input[pos] == 'O'
        pos = skipWhiteSpace(pos+1,input)
        target,pos = parseInt(pos,input)
        jobs = jobs + target
        nitems = nitems - 1
    return jobs,pos

(int,int) parseInt(int pos, string input):
    pos = skipWhiteSpace(pos,input)
    start = pos
    while pos < |input| && isDigit(input[pos]):
        pos = pos + 1
    return str2int(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n'

void System::main([string] args):
    // first, read the input file
    file = this.openReader(args[0])
    input = ascii2str(file.read())
    pos = 0
    c = 1
    while pos < |input|:
        test,job = parseTest(pos,input)
        pos = skipWhiteSpace(pos,input)
        out.println("Case #" + str(c) + ": ???")
        c = c + 1
