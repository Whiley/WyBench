import whiley.lang.*
import whiley.lang.System:*
import whiley.io.File:*

// ========================================================
// Benchmark
// ========================================================

define Queue as process { [int] items }
	 
int Queue::get():
    item = this.items[0]
    this.items = this.items[1..]
    return item
	 
void Queue::put(int item):
    this.items = this.items + [item]

bool Queue::isEmpty():
    return |this.items| == 0

Queue ::Queue():
    return spawn { items: [] }

// ========================================================
// Parser
// ========================================================

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

// ========================================================
// Main
// ========================================================

void ::main(System sys, [string] args):
    file = File.Reader(args[0])
    input = String.fromASCII(file.read())
    pos = 0
    data = []
    pos = skipWhiteSpace(pos,input)
    // first, read data
    while pos < |input|:
        i,pos = parseInt(pos,input)
        data = data + i
        pos = skipWhiteSpace(pos,input)
    // second, run the benchmark
    queue = Queue()
    for d in data:
        queue.put(d)
    while !queue.isEmpty():
        sys.out.println(String.str(queue.get()))
    
