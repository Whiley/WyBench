import whiley.io.*

// ========================================================
// Benchmark
// ========================================================

define MAX_BUFFER_SIZE as 5

define Link as process { [int] items, null|Link next }
	 
int Link::get():
    item = items[0]
    this.items = items[1..]
    return item
	 
void Link::push(int item):
    tmp = this.next
    if tmp == null || |items| < MAX_BUFFER_SIZE:
        this.items = items + [item]
    else:
        tmp!push(item)

bool Link::isEmpty():
    return |items| == 0

void Link::flush():
    // use of tmp here is less than ideal ...
    tmp = this.next
    if tmp != null:
        for d in items:
            tmp!push(d)
        tmp.flush()    

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

(Link,Link) System::create(int n):
    if n <= 1:
        end = spawn {items: [], next: null}
        return end,end
    else:
        start,end = this.create(n-1)
        return spawn {items: [], next: start}, end

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
    // second, create the chain
    (start,end) = this.create(10)
    // third, push all the data into the chain
    for d in data:
        start!push(d)
    // fourth, flush the chain
    start.flush()
    // fifth get all the data out of the chain
    while !end.isEmpty():
        out.println(str(end.get()))
    
