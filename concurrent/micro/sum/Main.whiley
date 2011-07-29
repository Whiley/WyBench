import whiley.io.*

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
    for i in start..end:
        sum = sum + items[i]
    this.result = sum    

int Sum::get():
    return result

Sum System::create([int] items, int start, int end):
    return spawn { items: items, start: start, end: end, result: 0 }

int System::run([int] items):
    while |items| != 1:
        // first calculate how many actors required
        nworkers = max(1,|items| / N)
        // second, count block size actors
        size = |items| / nworkers
        // third, start actors
        pos = 0
        workers = []
        for i in 0..nworkers:
            if i < (nworkers-1):    
                worker = this.create(items,pos,pos+size)
            else:
                // last actor has to pick up the slack
                worker = this.create(items,pos,|items|)
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
    sum = this.run(data)
    out.println(str(sum))    