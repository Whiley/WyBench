import whiley.io.*

// ========================================================
// Benchmark
// ========================================================

define Queue as process { [int] items }
	 
int Queue::get():
    item = items[0]
    this.items = items[1..]
    return item
	 
void Queue::put(int item):
    this.items = items + [item]

bool Queue::isEmpty():
    return |items| == 0

// ========================================================
// Parser
// ========================================================

(int,int) parseInt(int pos, string input):
    start = pos
    while pos < |input| && isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw "Missing number"
    return str2int(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

bool isWhiteSpace(char c):
    return c == ' ' || c == '\t' || c == '\n' || c == '\r'

// ========================================================
// Main
// ========================================================

void System::main([string] args):
    file = this.openReader(args[0])
    input = ascii2str(file.read())
    pos = 0
    data = []
    pos = skipWhiteSpace(pos,input)
    // first, read data
    while pos < |input|:
        i,pos = parseInt(pos,input)
        data = data + i
        pos = skipWhiteSpace(pos,input)
    // second, run the benchmark
    queue = spawn { items: [] }
    for d in data:
        queue.put(d)
    while !queue.isEmpty():
        out.println(str(queue.get()))
    