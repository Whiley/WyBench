import whiley.lang.*
import whiley.lang.System:*
import whiley.io.File:*

// ========================================================
// Benchmark
// ========================================================

define MAX_BUFFER_SIZE as 5

define Link as process { [int] items, null|Link next }
	 
int Link::get():
    item = this.items[0]
    this.items = this.items[1..]
    return item
	 
void Link::push(int item):
    tmp = this.next
    if tmp == null || |this.items| < MAX_BUFFER_SIZE:
        this.items = this.items + [item]
    else:
        tmp!push(item)

bool Link::isEmpty():
    return |this.items| == 0

void Link::flush():
    // use of tmp here is less than ideal ...
    tmp = this.next
    if tmp != null:
        for d in this.items:
            tmp!push(d)
        tmp.flush()    

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

(Link,Link) ::create(int n):
    if n <= 1:
        end = spawn {items: [], next: null}
        return end,end
    else:
        start,end = create(n-1)
        return spawn {items: [], next: start}, end

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
    // second, create the chain
    (start,end) = create(10)
    // third, push all the data into the chain
    for d in data:
        start!push(d)
    // fourth, flush the chain
    start.flush()
    // fifth get all the data out of the chain
    while !end.isEmpty():
       sys. out.println(String.str(end.get()))
    
