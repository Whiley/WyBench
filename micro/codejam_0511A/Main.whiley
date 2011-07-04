// ===============================================
// Parser
// ===============================================

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
    r = parseInt(0,args[0])
    out.println("GOT: " + str(r))
