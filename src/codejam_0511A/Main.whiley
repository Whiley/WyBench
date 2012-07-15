import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

// ===============================================
// Definitions
// ===============================================

define Job as { int button, bool orange }

// ===============================================
// Parser
// ===============================================

([Job],int) parseJobs(int pos, string input) throws SyntaxError:
    nitems,pos = parseInt(pos,input)
    jobs = []
    while nitems > 0:
        pos = skipWhiteSpace(pos,input)
        flag = (input[pos] == 'O')
        pos = skipWhiteSpace(pos+1,input)
        target,pos = parseInt(pos,input)
        jobs = jobs + [{button: target, orange: flag}]
        nitems = nitems - 1
    return jobs,pos

(int,int) parseInt(int pos, string input) throws SyntaxError:
    pos = skipWhiteSpace(pos,input)
    start = pos
    while pos < |input| && Char.isDigit(input[pos]):
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",pos,pos)
    return Int.parse(input[start..pos]),pos

int skipWhiteSpace(int index, string input):
    while index < |input| && isWhiteSpace(input[index]):
        index = index + 1
    return index

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
            diff = Math.abs(j.button - Opos)
            timediff = Math.max(0, diff - Osaved) + 1
            time = time + timediff
            Bsaved = Bsaved + timediff
            Osaved = 0
            Opos = j.button
        else:
            diff = Math.abs(j.button - Bpos)
            timediff = Math.max(0, diff - Bsaved) + 1
            time = time + timediff
            Osaved = Osaved + timediff
            Bsaved = 0
            Bpos = j.button
    // finally, return total time accumulated
    return time
            
void ::main(System.Console sys):
    // first, read the input file
    file = File.Reader(sys.args[0])
    input = String.fromASCII(file.read())
    try:
        ntests,pos = parseInt(0,input)
        c = 1
        while c <= ntests:
            jobs,pos = parseJobs(pos,input)
            pos = skipWhiteSpace(pos,input)
            time = processJobs(jobs)
            sys.out.println("Case #" + c + ": " + time)
            c = c + 1
    catch(SyntaxError e):
        sys.out.println("error - " + e.msg)
