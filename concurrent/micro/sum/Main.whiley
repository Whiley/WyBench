import whiley.lang.*
import whiley.lang.System:*
import whiley.io.File:*

// ========================================================
// Benchmark
// ========================================================

// the following parameter indicates the ratio of actors to items.  If
// N is 1 we have one item per actor.  If N is 2, we have two items per
//actor, etc.  
define N as 100

define Sum as process { 
    [int] items, 
    int start, 
    int end, 
    int result 
}

void Sum::start():
    sum = 0
    for i in this.start .. this.end:
        sum = sum + this.items[i]
    this.result = sum    

int Sum::get():
    return this.result

Sum ::create([int] items, int start, int end):
    return spawn { items: items, start: start, end: end, result: 0 }

int ::run([int] items):
    while |items| != 1:
        // first calculate how many actors required
        nworkers = Math.max(1,|items| / N)
        // second, count block size actors
        size = |items| / nworkers
        // third, start actors
        pos = 0
        workers = []
        for i in 0..nworkers:
            if i < (nworkers-1):    
                worker = create(items,pos,pos+size)
            else:
                // last actor has to pick up the slack
                worker = create(items,pos,|items|)
            workers = workers + [worker]
            worker!start()
            pos = pos + size
        // finally, collect results up
        items = []
        for i in 0 .. nworkers:
            items = items + [workers[i].get()]
    
    return items[0]

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
    sum = run(data)
    sys.out.println(String.str(sum))    
