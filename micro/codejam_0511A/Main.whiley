import whiley.io.*

// ===============================================
// Definitions
// ===============================================

define Job as { int button, bool orange }

// ===============================================
// Parser
// ===============================================

([Job],int) parseJobs(int pos, string input):
    nitems,pos = parseInt(pos,input)
    jobs = []
    while nitems > 0:
        pos = skipWhiteSpace(pos,input)
        flag = (input[pos] == 'O')
        pos = skipWhiteSpace(pos+1,input)
        target,pos = parseInt(pos,input)
        jobs = jobs + { button: target, orange: flag }
        nitems = nitems - 1
    return jobs,pos

(int,int) parseInt(int pos, string input):
    pos = skipWhiteSpace(pos,input)
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
    return c == ' ' || c == '\t' || c == '\n'

// ===============================================
// Main Computation
// ===============================================

int processJobs([Job] jobs):
    Opos = 1    // current oranage position
    Bpos = 1    // current blue position 
    Osaved = 0  // spare time orange has saved
    Bsaved = 0  // spare time blue has saved
    time = 0    // total time accumulated thus far
    // now, do the work!
    for j in jobs:
        if j.orange:
            diff = abs(j.button - Opos)
            timediff = max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = j.button
        else:
            diff = abs(j.button - Bpos)
            timediff = max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = j.button
    // finally, return total time accumulated
    return time
            
void System::main([string] args):
    // first, read the input file
    file = this.openReader(args[0])
    input = ascii2str(file.read())
    ntests,pos = parseInt(0,input)
    c = 1
    while c <= ntests:
        jobs,pos = parseJobs(pos,input)
        pos = skipWhiteSpace(pos,input)
        time = processJobs(jobs)
        out.println("Case #" + str(c) + ": " + str(time))
        c = c + 1
